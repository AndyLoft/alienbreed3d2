;
; *****************************************************************************
; *
; * modules/dev_inst.s
; *
; * Developer mode instrumentation
; *
; *****************************************************************************

; DEVMODE INSTRUMENTATION

				IFD	DEV

				section bss,bss
				align 4
dev_GraphBuffer_vb:			ds.b	DEV_GRAPH_BUFFER_SIZE*2 ; array of times

; EClockVal stamps
dev_ECVDrawDone_q:			ds.l	2	; timestamp at the end of drawing
dev_ECVChunkyDone_q:		ds.l	2	; timestamp at the end of chunky to planar

dev_SkipFlags_l:			ds.l	1	; Mask of disabled flags (i.e. set when something is skipped)

; Counters
dev_Counters_vw:
dev_VisibleSimpleWalls_w:	ds.w	1	; simple walls drawn this frame
dev_VisibleShadedWalls_w:	ds.w	1	; shaded walls drawn this frame

dev_VisibleModelCount_w:	ds.w	1	; visible polygon models this frame
dev_VisibleGlareCount_w:	ds.w	1	; visible glare bitmaps this frame

dev_VisibleLightMapCount_w:	ds.w	1	; visible lightsource bitmaps this frame
dev_VisibleAdditiveCount_w:	ds.w	1	; visible additive bitmaps this frame

dev_VisibleBitmapCount_w:	ds.w	1	; visible bitmaps this fame
dev_Reserved0_w:			ds.w	1

dev_TotalCounters_vw:
dev_VisibleWalls_w:			ds.w	1	; Total visible walls this frame
dev_VisibleFlats_w:			ds.w	1	; Total visible flats this frame

dev_VisibleObjectCount_w:	ds.w	1	; Total visible objects this frame
dev_DrawObjectCallCount_w:	ds.w	1	; Number of calls to Draw_Object

dev_DrawTimeMsAvg_w:		ds.w	1   ; two frame average of draw time
dev_FPSIntAvg_w:			ds.w	1

dev_FPSFracAvg_w:			ds.w	1
dev_Reserved1_w:			ds.w	1

dev_Reserved2_w:			ds.w	1
dev_Reserved3_w:			ds.w	1
dev_Reserved4_w:			ds.w	1
dev_Reserved5_w:			ds.w	1
; Not cleared per frame
dev_FrameIndex_w:			ds.w	1	; frame number % DEV_GRAPH_BUFFER_SIZE


; Character buffer for printing
dev_CharBuffer_vb:			dcb.b	64

;//////////////////////////////////////////////////////////////////////////////

				section code,code
				align 4


;******************************************************************************
;*
;* Initialise developer options (timer stuff has moved to system.s)
;*
;******************************************************************************
Dev_Init:
				rts

;******************************************************************************
;*
;* Reset Metrics Data
;*
;******************************************************************************
Dev_DataReset:
				lea		dev_GraphBuffer_vb,a0
				move.l	#(DEV_GRAPH_BUFFER_SIZE/16)-1,d0
.loop:
				clr.l	(a0)+
				clr.l	(a0)+
				clr.l	(a0)+
				clr.l	(a0)+
				dbra	d0,.loop
				clr.w	dev_DrawTimeMsAvg_w
				rts

;******************************************************************************
;*
;* Clears the chunky draw buffer to mid grey
;*
;******************************************************************************
Dev_ClearFastBuffer:
				move.l	Vid_FastBufferPtr_l,a0
				move.l	#(VID_FAST_BUFFER_SIZE/16)-1,d0
				move.l	#$0A0A0A0A,d1
.loop:
				move.l	d1,(a0)+
				move.l	d1,(a0)+
				move.l	d1,(a0)+
				move.l	d1,(a0)+
				dbra	d0,.loop
				rts


;******************************************************************************
;*
;* Mark frame beginning for instrumentation
;*
;******************************************************************************
Dev_MarkFrameBegin:
				move.w	dev_FrameIndex_w,d0
				addq.w	#1,d0
				and.w	#DEV_GRAPH_BUFFER_MASK,d0
				move.w	d0,dev_FrameIndex_w

				; Reset the divisor extrema
				bne.s	.skip_reset_divisor
				move.w	#32767,dev_Reserved4_w
				move.w	#-32768,dev_Reserved5_w

.skip_reset_divisor:
				lea		dev_Counters_vw,a0
				clr.l	(a0)+
				clr.l	(a0)+
				clr.l	(a0)+
				clr.l	(a0)+
				clr.l	(a0)+
				clr.l	(a0)+
				clr.l	(a0)+
				clr.l	(a0)+
				clr.l	(a0)+

				; Check if the current skip flags require the fast buffer to be cleared

				DEV_CHECK	FASTBUFFER_CLEAR,.no_clear
				move.l		dev_SkipFlags_l,d0
				and.l		#DEV_CLEAR_FASTBUFFER_MASK,d0
				beq.s		.no_clear

				bsr		Dev_ClearFastBuffer

.no_clear:
				rts

;******************************************************************************
;*
;* Mark end of drawing for instrumentation
;*
;******************************************************************************
Dev_MarkDrawDone:
				; sum up the different rendered object types this frame
				lea		dev_Counters_vw,a0

				; Walls
				move.w	(a0)+,d0				; simple walls
				add.w	(a0)+,d0				; shaded walls
				move.w	d0,dev_VisibleWalls_w

				; Objects
				move.w	(a0)+,d0				; models
				add.w	(a0)+,d0				; glare
				add.w	(a0)+,d0				; lightmapped
				add.w	(a0)+,d0				; additive
				add.w	(a0)+,d0				; bitmaps
				move.w	d0,dev_VisibleObjectCount_w
				lea		dev_ECVDrawDone_q,a0
				bra		Sys_MarkTime


;******************************************************************************
;*
;* Mark end of c2p/transfer for instrumentation
;*
;******************************************************************************
Dev_MarkChunkyDone:
				lea		dev_ECVChunkyDone_q,a0
				bra		Sys_MarkTime

;******************************************************************************
;*
;* Basic printf() type functionality based on exec/RawDoFmt(). Keep the data
;* size shorter than dev_CharBuffer_vb or expect overflow.
;*
;* d0: coordinate pair (x16:y16)
;* a0: format template
;* a1: data stream
;*
;******************************************************************************
Dev_PrintF:
				movem.l		d2/a2/a3/a6,-(sp)
				move.l		d0,d2					; coordinate pair
				move.w		#0,.dev_Length
				lea			.dev_PutChar(pc),a2
				lea			dev_CharBuffer_vb,a3
				CALLEXEC	RawDoFmt				; Format into dev_CharBuffer_vb

				move.l		Vid_MainScreen_l,a1
				lea			sc_RastPort(a1),a1
				clr.l		d1
				move.w		d2,d1 ; d1: y coordinate
				clr.l		d0
				swap		d2
				move.w		d2,d0 ; d0: x coordinate
				CALLGRAF 	Move

				move.w		.dev_Length(pc),d0
				subq		#1,d0
				lea			dev_CharBuffer_vb,a0
				jsr			_LVOText(a6)

				movem.l		(sp)+,d2/a2/a3/a6
				rts

.dev_Length:
				dc.w 0		; tracks characters written by the following stuffer
.dev_PutChar:
				move.b		d0,(a3)+
				add.w		#1,.dev_Length
				rts

;******************************************************************************
;*
;* Display developer instrumentation
;*
;******************************************************************************
Dev_PrintStats:
				; Use the system recorded FPS average
				move.l		Sys_FPSIntAvg_w,dev_FPSIntAvg_w

				tst.b		Vid_FullScreen_b
				bne			.fullscreen_stats

				; smallscreen
				lea			dev_TotalCounters_vw,a1
				lea			.dev_ss_stats_obj_vb,a0
				move.l		#8,d0
				bsr			Dev_PrintF

				; Simple walls
				lea			dev_VisibleSimpleWalls_w,a1
				lea			.dev_ss_stats_wall_simple_vb,a0
				move.l		#24,d0
				bsr			Dev_PrintF

				; Shaded walls
				lea			dev_VisibleShadedWalls_w,a1
				lea			.dev_ss_stats_wall_shaded_vb,a0
				move.l		#40,d0
				bsr			Dev_PrintF

				; Polygon objects
				lea			dev_VisibleModelCount_w,a1
				lea			.dev_ss_stats_obj_poly_vb,a0
				move.l		#56,d0
				bsr			Dev_PrintF

				; Glare objects
				lea			dev_VisibleGlareCount_w,a1
				lea			.dev_ss_stats_obj_glare_vb,a0
				move.l		#72,d0
				bsr			Dev_PrintF

				; Lightmap bitmap objects
				lea			dev_VisibleLightMapCount_w,a1
				lea			.dev_ss_stats_obj_lightmap_vb,a0
				move.l		#88,d0
				bsr			Dev_PrintF

				; Additive bitmap objects
				lea			dev_VisibleAdditiveCount_w,a1
				lea			.dev_ss_stats_obj_additive_vb,a0
				move.l		#104,d0
				bsr			Dev_PrintF

				; Vanilla bitmap objects
				lea			dev_VisibleBitmapCount_w,a1
				lea			.dev_ss_stats_obj_bitmap_vb,a0
				move.l		#120,d0
				bsr			Dev_PrintF

				; OrderZones
				lea			dev_Reserved1_w,a1
				lea			.dev_ss_stats_order_zones_vb,a0
				move.l		#136,d0
				bsr			Dev_PrintF

				; Player 1 Gun frame
				move.w		Plr1_GunFrame_w,d0
				rol.w		#8,d0
				move.w		d0,.temp_byte_swap
				lea			.temp_byte_swap,a1
				lea			.dev_ss_stats_p1_gf_vb,a0
				move.l		#152,d0
				bsr			Dev_PrintF

				; Player 2 Gun frame
				move.w		Plr2_GunFrame_w,d0
				rol.w		#8,d0
				move.w		d0,.temp_byte_swap
				lea			.temp_byte_swap,a1
				lea			.dev_ss_stats_p2_gf_vb,a0
				move.l		#152+16,d0
				bsr			Dev_PrintF


;				; NumObjPtrs
;				lea			Lvl_NumObjectPoints_w,a1
;				lea			.dev_ss_stats_lvl_obj_vb,a0
;				move.l		#152,d0
;				bsr			Dev_PrintF

;				; Zone Ptr
;				lea			Plr1_ZonePtr_l,a1
;				lea			.dev_ss_stats_zone_vb,a0
;				move.l		#152+40,d0
;				bsr			Dev_PrintF

;				; Player Structure Size
;				lea			.player_sizeof,a1
;				lea			.dev_ss_player_size,a0
;				move.l		#152,d0
;				bsr			Dev_PrintF



;				; Long Divisions
;				lea			dev_Reserved1_w,a1
;				lea			.dev_ss_stats_long_divide_vb,a0
;				move.l		#136,d0
;				bsr			Dev_PrintF

;				; Min Divisor
;				lea			dev_Reserved4_w,a1
;				lea			.dev_ss_stats_min_divisor_vb,a0
;				move.l		#152,d0
;				bsr			Dev_PrintF

;				; Max Divisor
;				lea			dev_Reserved5_w,a1
;				lea			.dev_ss_stats_max_divisor_vb,a0
;				move.l		#168,d0
;				bsr			Dev_PrintF

				rts

.fullscreen_stats:
				lea			dev_TotalCounters_vw,a1
				lea			.dev_fs_stats_tpl_vb,a0
				move.l		#(SCREEN_WIDTH-240)<<16|(SCREEN_HEIGHT-24),d0
				bsr			Dev_PrintF

				rts

.temp_byte_swap:
.player_sizeof:
				dc.w		PlrT_SizeOf_l

.dev_fs_stats_tpl_vb:
				dc.b		"w:%2d f:%2d o:%2d/%2d d:%2dms %2d.%dfps",0

.dev_ss_stats_obj_vb:
				dc.b		"Wall:%2d, Flt:%2d, Obj:%2d/%2d, Drw:%2dms, %2d.%dfps",0

.dev_ss_stats_wall_simple_vb:
				dc.b		"WS:%3d",0
.dev_ss_stats_wall_shaded_vb:
				dc.b		"WG:%3d",0
.dev_ss_stats_obj_poly_vb:
				dc.b		"OP:%3d",0
.dev_ss_stats_obj_glare_vb:
				dc.b		"OG:%3d",0
.dev_ss_stats_obj_lightmap_vb:
				dc.b		"OL:%3d",0
.dev_ss_stats_obj_additive_vb:
				dc.b		"OA:%3d",0
.dev_ss_stats_obj_bitmap_vb:
				dc.b		"OB:%3d",0

.dev_ss_stats_order_zones_vb:
				dc.b		"OZ:%3d",0

.dev_ss_stats_lvl_obj_vb:
				dc.b		"LO:%3d",0

.dev_ss_stats_p1_gf_vb:
				dc.b		"P1:%3d ",0

.dev_ss_stats_p2_gf_vb:
				dc.b		"P2:%3d ",0



;.dev_ss_stats_zone_vb:
;				dc.b		"ZP:%8lx",0



;.dev_ss_player_size:
;				dc.b		"PS:%3d",0

; Stats for the division pogrom 2.0
;.dev_ss_stats_long_divide_vb:
;				dc.b		"LD:%4d ",0
;.dev_ss_stats_min_divisor_vb:
;				dc.b		"mD:%4d ",0
;.dev_ss_stats_max_divisor_vb:
;				dc.b		"MD:%4d ",0

				align 4

;******************************************************************************
;*
;* Calculate the difference between a pair of ECV timestamps to milliseconds.
;* Return is 16 bit. Start timestamp pointed to by a0, end timestamp pointed
;* to by a1. Return ms in d0.
;*
;******************************************************************************
dev_ECVDiffToMs:
				move.l	4(a1),d0
				sub.l	4(a0),d0
				mulu.l	Sys_ECVToMsFactor_l,d0
				clr.w	d0
				swap	d0
				rts

;******************************************************************************
;*
;* Calculate the times and store in the graph data buffer
;*
;******************************************************************************
Dev_DrawGraph:
				movem.l	d0/d1/d2/a0/a1/a2,-(sp)
				lea		Sys_FrameTimeECV_q,a0
				lea		dev_ECVDrawDone_q,a1
				bsr.s	dev_ECVDiffToMs
				lea		dev_GraphBuffer_vb,a0			; Put the ms value into the graph buffer
				move.w	dev_FrameIndex_w,d1
				add.w	dev_DrawTimeMsAvg_w,d0
				lsr.w	#1,d0
				move.w	d0,dev_DrawTimeMsAvg_w
				lsr.b	#1,d0
				move.b	d0,(a0,d1.w*2)
				move.b	dev_VisibleObjectCount_w+1,1(a0,d1.w*2)

				; Now draw it...
				move.l	Vid_FastBufferPtr_l,a0

				; In fullscreen, we need to make a small adjustment
				IFNE	FS_HEIGHT_C2P_DIFF
				moveq	#FS_HEIGHT_C2P_DIFF,d2
				and.b	Vid_FullScreen_b,d2
				ENDC

				move.w	Vid_BottomY_w,d0
				sub.w	d2,d0

				sub.w	Vid_LetterBoxMarginHeight_w,d0
				mulu.w	#SCREEN_WIDTH,d0
				add.l	d0,a0 							; a0 points at lower left of render area
				lea		dev_GraphBuffer_vb,a1

				; draw buffer position should be one ahead of the write position.
				addq.w	#1,d1
				and.w	#DEV_GRAPH_BUFFER_MASK,d1

				; Draw loop
				move.l	#DEV_GRAPH_BUFFER_SIZE-1,d0
.loop:
				; plot draw time average
				clr.l	d2
				move.b	(a1,d1.w*2),d2
				lsr.b	#1,d2 ; restrict the maximum deflection
				muls.w	#-SCREEN_WIDTH,d2
				move.b	#DEV_GRAPH_DRAW_TIME_COLOUR,(a0,d2)

				; plot object count
				clr.l	d2
				move.b	1(a1,d1.w*2),d2
				muls.w	#-SCREEN_WIDTH,d2
				move.b	#31,(a0,d2)

				addq.l	#1,d1
				and.l	#DEV_GRAPH_BUFFER_MASK,d1
				addq.l	#1,a0
				dbra	d0,.loop

				movem.l	(sp)+,d0/d1/d2/a0/a1/a2
				rts

				ENDC
