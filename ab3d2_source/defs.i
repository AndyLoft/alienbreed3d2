;
; *****************************************************************************
; *
; * defs.i
; *
; * Structure and limt definitions
; *
; * DO NOT EDIT THIS FILE WITHOUT MAKING THE CORRESPONDING CHANGES IN c/defs.h
; *
; *****************************************************************************

;*****************************
;* Structure Padding Macro ***
;*****************************

PADDING		MACRO
SOFFSET		SET    SOFFSET+\1
			ENDM

;*****************************
;* Structure definitions *****
;*****************************

MAX_LEVEL_OBJ_DIST_COUNT	EQU	256+32		;
MAX_OBJS_IN_LINE_COUNT		EQU 400			;
LVL_OBJ_DEFINITION_SIZE		EQU	64			; Runtime size of level object

NUM_LEVELS			EQU	16
NUM_BULLET_DEFS		EQU 20
NUM_GUN_DEFS		EQU 10
NUM_ALIEN_DEFS		EQU 20
NUM_OBJECT_DEFS		EQU 30
NUM_SFX				EQU 64
NUM_WALL_TEXTURES	EQU 16

	; Player Definition (runtime)
	STRUCTURE PlrT,0
		; Long fields
		ULONG PlrT_ObjectPtr_l				;   0, 4
		ULONG PlrT_XOff_l					;   4, 4 - sometimes accessed as w - todo understand real size
		ULONG PlrT_YOff_l					;   8, 4
		ULONG PlrT_ZOff_l					;  12, 4 - sometimes accessed as w - todo understand real size
		ULONG PlrT_ZonePtr_l				;  16, 4
		ULONG PlrT_Height_l					;  20, 4
		ULONG PlrT_AimSpeed_l				;  24, 4
		ULONG PlrT_SnapXOff_l				;  28, 4
		ULONG PlrT_SnapYOff_l				;  32, 4
		ULONG PlrT_SnapYVel_l				;  36, 4
		ULONG PlrT_SnapZOff_l				;  40, 4
		ULONG PlrT_SnapTYOff_l				;  44, 4
		ULONG PlrT_SnapXSpdVal_l			;  48, 4
		ULONG PlrT_SnapZSpdVal_l			;  52, 4
		ULONG PlrT_SnapHeight_l				;  56, 4
		ULONG PlrT_SnapTargHeight_l			;  60, 4
		ULONG PlrT_TmpXOff_l				;  64, 4 - also accessed as w, todo determine correct size
		ULONG PlrT_TmpZOff_l				;  68, 4
		ULONG PlrT_TmpYOff_l				;  72, 4

		; Private
		ULONG PlrT_ListOfGraphRoomsPtr_l	;  76, 4
		ULONG PlrT_PointsToRotatePtr_l		;  80, 4
		ULONG PlrT_BobbleY_l				;  84, 4
		ULONG PlrT_TmpHeight_l				;  88, 4
		ULONG PlrT_OldX_l					;  92, 4
		ULONG PlrT_OldZ_l					;  96, 4
		ULONG PlrT_OldRoomPtr_l				; 100, 4
		ULONG PlrT_SnapSquishedHeight_l		; 104, 4
		ULONG PlrT_DefaultEnemyFlags_l		; 108, 4


		; Word fields
		UWORD PlrT_Energy_w					; 112, 2
		UWORD PlrT_CosVal_w					; 114, 2
		UWORD PlrT_SinVal_w					; 116, 2
		UWORD PlrT_AngPos_w					; 118, 2
		UWORD PlrT_Zone_w					; 120, 2
		UWORD PlrT_FloorSpd_w				; 122, 2
		UWORD PlrT_RoomBright_w				; 124, 2
		UWORD PlrT_Bobble_w					; 126, 2
		UWORD PlrT_SnapAngPos_w				; 128, 2
		UWORD PlrT_SnapAngSpd_w				; 130, 2
		UWORD PlrT_TmpAngPos_w				; 132, 2
		UWORD PlrT_TimeToShoot_w			; 134, 2

		; This section is saved/loaded in game save
		UWORD PlrT_Health_w					; 136, 2
		UWORD PlrT_JetpackFuel_w			; 138, 2
		UWORD PlrT_AmmoCounts_vw			; 140, 40 - UWORD[20]
		PADDING (NUM_BULLET_DEFS*2)-2
		UWORD PlrT_Shield_w					; 180, 2
		UWORD PlrT_Jetpack_w				; 182, 2
		UWORD PlrT_Weapons_vb				; 184, 20 - UWORD[10]
		PADDING (NUM_GUN_DEFS*2)-2

		UWORD PlrT_GunFrame_w				; 204, 2
		UWORD PlrT_NoiseVol_w				; 206, 2
		; Private

		UWORD PlrT_TmpHoldDown_w			; 208, 2
		UWORD PlrT_TmpBobble_w				; 210, 2
		UWORD PlrT_SnapCosVal_w				; 212, 2
		UWORD PlrT_SnapSinVal_w				; 214, 2
		UWORD PlrT_WalkSFXTime_w			; 216, 2

		; Byte data
		UBYTE PlrT_Keys_b					; 218
		UBYTE PlrT_Path_b					; 219
		UBYTE PlrT_Mouse_b					; 220
		UBYTE PlrT_Joystick_b				; 221
		UBYTE PlrT_GunSelected_b			; 222
		UBYTE PlrT_StoodInTop_b				; 223
		UBYTE PlrT_Ducked_b					; 224
		UBYTE PlrT_Squished_b				; 225
		UBYTE PlrT_Echo_b					; 226
		UBYTE PlrT_Fire_b					; 227
		UBYTE PlrT_Clicked_b				; 228
		UBYTE PlrT_Used_b					; 229
		UBYTE PlrT_TmpClicked_b				; 230
		UBYTE PlrT_TmpSpcTap_b				; 231
		UBYTE PlrT_TmpGunSelected_b			; 232
		UBYTE PlrT_TmpFire_b				; 233

 		; Private
		UBYTE PlrT_Teleported_b				; 234
		UBYTE PlrT_Dead_b					; 235
		UBYTE PlrT_TmpDucked_b				; 236
		UBYTE PlrT_StoodOnLift_b			; 237

		UBYTE PlrT_InvMouse_b				; 238
		UBYTE PlrT_Reserved2_b				; 239

		; Tables
		UWORD PlrT_ObjectDistances_vw		; 240, MAX_LEVEL_OBJ_DIST_COUNT*2 : UWORD[MAX_LEVEL_OBJ_DIST_COUNT]
		PADDING (MAX_LEVEL_OBJ_DIST_COUNT*2)-2
		UBYTE PlrT_ObjectsInLine_vb			; ..., MAX_OBJS_IN_LINE_COUNT : UBYTE[MAX_OBJS_IN_LINE_COUNT]
		PADDING (MAX_OBJS_IN_LINE_COUNT-1)
		LABEL PlrT_SizeOf_l

	; Bullet definition
	STRUCTURE BulT,0
		ULONG BulT_IsHitScan_l			;   0, 4
		ULONG BulT_Gravity_l			;   4, 4
		ULONG BulT_Lifetime_l			;   8, 4
		ULONG BulT_AmmoInClip_l			;  12, 4
		ULONG BulT_BounceHoriz_l		;  16, 4
		ULONG BulT_BounceVert_l			;  20, 4
		ULONG BulT_HitDamage_l			;  24, 4
		ULONG BulT_ExplosiveForce_l		;  28, 4
		ULONG BulT_Speed_l				;  32, 4
		ULONG BulT_AnimFrames_l			;  36, 4
		ULONG BulT_PopFrames_l			;  40, 4
		ULONG BulT_BounceSFX_l			;  44, 4
		ULONG BulT_ImpactSFX_l			;  48, 4
		ULONG BulT_GraphicType_l		;  52, 4
		ULONG BulT_ImpactGraphicType_l	;  56, 4
		STRUCT BulT_AnimData_vb,120		;  60, 120
		STRUCT BulT_PopData_vb,120		; 180, 0
		LABEL BulT_SizeOf_l				; 300

	; Bullet shoot definition
	STRUCTURE ShootT,0
		UWORD ShootT_BulType_w			; 0, 2
		UWORD ShootT_Delay_w			; 2, 2
		UWORD ShootT_BulCount_w			; 4, 2
		UWORD ShootT_SFX_w				; 6, 2
		LABEL ShootT_SizeOf_l			; 8

	; Alien Data Definition
	STRUCTURE AlienT,0
		UWORD AlienT_GFXType_w				;  0, 2
		UWORD AlienT_DefaultBehaviour_w		;  2, 2
		UWORD AlienT_ReactionTime_w			;  4, 2
		UWORD AlienT_DefaultSpeed_w			;  6, 2
		UWORD AlienT_ResponseBehaviour_w	;  8, 2
		UWORD AlienT_ResponseSpeed_w		; 10, 2
		UWORD AlienT_ResponseTimeout_w		; 12, 2
		UWORD AlienT_DamageToRetreat_w		; 14, 2
		UWORD AlienT_DamageToFollowup_w		; 16, 2
		UWORD AlienT_FollowupBehaviour_w	; 18, 2
		UWORD AlienT_FollowupSpeed_w		; 20, 2
		UWORD AlienT_FollowupTimeout_w		; 22, 2
		UWORD AlienT_RetreatBehaviour_w		; 24, 2
		UWORD AlienT_RetreatSpeed_w			; 26, 2
		UWORD AlienT_RetreatTimeout_w		; 28, 2
		UWORD AlienT_BulType_w				; 30, 2
		UWORD AlienT_HitPoints_w			; 32, 2
		UWORD AlienT_Height_w				; 34, 2
		UWORD AlienT_Girth_w				; 36, 2
		UWORD AlienT_SplatType_w			; 38, 2 - either the projectile class, or spanwed alien class
		UWORD AlienT_Auxilliary_w			; 40, 2
		LABEL AlienT_SizeOf_l				; 42

	; Object Data Definition
	STRUCTURE ODefT,0
		UWORD ODefT_Behaviour_w		;  0, 2
		UWORD ODefT_GFXType_w		;  2, 2
		UWORD ODefT_ActiveTimeout_w	;  4, 2
		UWORD ODefT_HitPoints_w		;  6, 2
		UWORD ODefT_ExplosiveForce_w	;  8, 2 unused
		UWORD ODefT_Impassible_w		; 10, 2 unused
		UWORD ODefT_DefaultAnimLen_w	; 12, 2 unused
		UWORD ODefT_CollideRadius_w	; 14, 2
		UWORD ODefT_CollideHeight_w	; 16, 2
		UWORD ODefT_FloorCeiling_w	; 18, 2
		UWORD ODefT_LockToWall_w		; 20, 2 unused
		UWORD ODefT_ActiveAnimLen_w	; 22, 2 unused
		UWORD ODefT_SFX_w			; 24, 2
		PADDING 14					; 26, 14
		LABEL ODefT_SizeOf_l			; 40

OBJ_TYPE_ALIEN EQU 0
OBJ_TYPE_OBJECT EQU 1
OBJ_TYPE_PROJECTILE EQU 2
OBJ_TYPE_AUX EQU 3
OBJ_TYPE_PLAYER1 EQU 4
OBJ_TYPE_PLAYER2 EQU 5

	; Runtime objects are 64 byte structures. The first 18 bytes are common, but the remainder depend on what the type
	; of the object is, e.g. decoration, bullet, alien, collectable etc.
	STRUCTURE ObjT,0
		; TODO work out what the hidden data are.
		; It appears these are accessed as bytes in some use cases, so the probability is that the
		; data is overwritten or repurposed for temporary objects (projectiles/explosions)
		ULONG ObjT_XPos_l			; 0, 4 - To be confirmed
		ULONG ObjT_ZPos_l 			; 4, 4 - To be confirmed
		ULONG ObjT_YPos_l 			; 8, 4 - To be confirmed

		UWORD ObjT_ZoneID_w			; 12, 2 - Zone where the object is located, or -1 if it's been removed
		PADDING 2					; 2     - Unknown
		UBYTE ObjT_TypeID_b			; 16    - Defines the type (alien, bullet, object etc.)
		UBYTE ObjT_SeePlayer_b      ; 17    - Line of sight to player
		LABEL ObjT_Header_SizeOf_l	; 18    - After here, the remaining structure depends on ObjT_TypeID_b
		PADDING 46
		LABEL ObjT_SizeOf_l			; 64

OBJ_PREV	EQU (-ObjT_SizeOf_l)	; object before current
OBJ_NEXT	EQU	ObjT_SizeOf_l		; object after current

	MACRO NEXT_OBJ
	add.w #ObjT_SizeOf_l,\1
	ENDM

	MACRO PREV_OBJ
	sub.w #ObjT_SizeOf_l,\1
	ENDM

	; Runtime entity extension for ObjT
	STRUCTURE EntT,ObjT_Header_SizeOf_l
		UBYTE EntT_HitPoints_b				; 18, 1
		UBYTE EntT_DamageTaken_b			; 19, 1
		UBYTE EntT_CurrentMode_b			; 20, 1
		UBYTE EntT_TeamNumber_b				; 21, 1
		UWORD EntT_CurrentSpeed_w 			; 22, 2 unused
		UWORD EntT_DisplayText_w			; 24, 2
		UWORD EntT_ZoneID_w					; 26, 2 ; todo - how is this related to ObjT_ZoneID_w ?
		UWORD EntT_CurrentControlPoint_w	; 28, 2
		UWORD EntT_CurrentAngle_w			; 30, 2
		UWORD EntT_TargetControlPoint_w		; 32, 2
		UWORD EntT_Timer1_w					; 34, 2
		ULONG EntT_EnemyFlags_l				; 36, 4
		UWORD EntT_Timer2_w					; 40, 2
		UWORD EntT_ImpactX_w				; 42, 2
		UWORD EntT_ImpactZ_w				; 44, 2
		UWORD EntT_ImpactY_w				; 46, 2
		UWORD EntT_VelocityY_w				; 48, 2

 		; Union
		LABEL EntT_DoorsAndLiftsHeld_l		; 50, 4 ; actually accessd as a long
		PADDING 2
		UWORD EntT_Timer3_w					; 52, 2

		; union field of UWORD, UBYTE[2]
		LABEL EntT_Timer4_w					; 54, 0
		UBYTE EntT_Type_b					; 54, 1
		UBYTE EntT_WhichAnim_b				; 55, 1
		PADDING 8
		LABEL EntT_SizeOf_l					; 64 - This is the actual size in memory

ENT_TYPE_COLLECTABLE	EQU 0
ENT_TYPE_ACTIVATABLE	EQU 1
ENT_TYPE_DESTRUCTABLE	EQU 2
ENT_TYPE_DECORATION		EQU 3

ENT_PREV_2	EQU (-EntT_SizeOf_l*2)	; entity two before current
ENT_PREV	EQU (-EntT_SizeOf_l)	; entity before current
ENT_NEXT	EQU	EntT_SizeOf_l		; entity after current
ENT_NEXT_2	EQU	(EntT_SizeOf_l*2)	; entity two after current

	; Runtime projectile extension for ObjT
	STRUCTURE ShotT,ObjT_Header_SizeOf_l
		UWORD ShotT_VelocityX_w		; 18, 2
		PADDING 2           		; 20, 2
		UWORD ShotT_VelocityZ_w		; 22, 2
		PADDING 4           		; 24, 4
		UWORD ShotT_Power_w			; 28, 2
		UBYTE ShotT_Status_b		; 30, 1
		UBYTE ShotT_Size_b			; 31, 1
		PADDING 10          		; 32, 10
		UWORD ShotT_VelocityY_w		; 42, 2

		; union
		LABEL ShotT_AccYPos_w		; 44, 0
		UWORD ShotT_AuxOffsetX_w	; 44, 2
		UWORD ShotT_AuxOffsetY_w	; 46, 2
		PADDING 4           		; 48, 4
		UBYTE ShotT_Anim_b			; 52, 1
		PADDING 1           		; 53, 1
		UWORD ShotT_Gravity_w		; 54, 2
		UWORD ShotT_Impact_w		; 56, 2
		UWORD ShotT_Lifetime_w		; 58, 2
		UWORD ShotT_Flags_w			; 60, 2
		UBYTE ShotT_Worry_b			; 62, 1
		UBYTE ShotT_InUpperZone_b	; 63, 1
		LABEL ShotT_SizeOf_l		; 64

	; Zone Structure todo - what gives with the 16-bit alignment of these?
	; TODO - consider rearranging the data after loading into something with optimal alignment
	STRUCTURE ZoneT,0
		UWORD ZoneT_ID_w                ;  2, 2
		ULONG ZoneT_Floor_l				;  2, 4
		ULONG ZoneT_Roof_l				;  6, 4
		ULONG ZoneT_UpperFloor_l		; 10, 4
		ULONG ZoneT_UpperRoof_l			; 14, 4
		ULONG ZoneT_Water_l				; 18, 4
		UWORD ZoneT_Brightness_w		; 22, 2
		UWORD ZoneT_UpperBrightness_w	; 24, 2
		UWORD ZoneT_ControlPoint_w		; 26, 2 really UBYTE[2]
		UWORD ZoneT_BackSFXMask_w		; 28, 2 Originally long but always accessed as word
		UWORD ZoneT_Unused_w            ; 30, 2 so this is the unused half
		UWORD ZoneT_EdgeListOffset_w	; 32, 2 Offset relative to ZoneT instance
		UWORD ZoneT_Points_w			; 34, 2
		UBYTE ZoneT_Back_b				; 36, 1 unused
		UBYTE ZoneT_Echo_b				; 37, 1
		UWORD ZoneT_TelZone_w			; 38, 2
		UWORD ZoneT_TelX_w				; 40, 2
		UWORD ZoneT_TelZ_w				; 42, 2
		UWORD ZoneT_FloorNoise_w		; 44, 2
		UWORD ZoneT_UpperFloorNoise_w	; 46, 2
		UWORD ZoneT_PotVisibleZoneList_vw		; 48, 2 - Set of Potentially Visible Zones (array of 4-word tuples)
		LABEL ZoneT_SizeOf_l			; 50

	; Edge structure. The ZoneT_EdgeListOffset_w points to a list of words that are indexes
	; in an array of the following structure, pointed to by Lvl_ZoneEdgePtr_l
	STRUCTURE EdgeT,0
		WORD  EdgeT_XPos_w     ; 0 X coordinate
		WORD  EdgeT_ZPos_w     ; 2 Z coordinate
		WORD  EdgeT_XLen_w     ; 4 Length in X direction
		WORD  EdgeT_ZLen_w     ; 6 Length in Z direction
		WORD  EdgeT_JoinZone_w ; 8 Zone the edge joins to, or -1 for a solid wall
		WORD  EdgeT_Word_5     ; 10 TODO
		BYTE  EdgeT_Byte_12    ; 12
		BYTE  EdgeT_Byte_13    ; 13
		WORD  EdgeT_Flags_w    ; 14 TODO - some sort of flags
		LABEL EdgeT_SizeOf_l   ; 16

	STRUCTURE PVST,0
		WORD  PVST_Zone_w ; 0
		WORD  PVST_Dist_w ; 2
		WORD  PVST_Word_2 ; 4 TODO
		WORD  PVST_Word_3 ; 6 TODO
		LABEL PVST_SizeOf_l 8

NUM_PLR_SHOT_DATA	EQU		20
NUM_ALIEN_SHOT_DATA	EQU		20

;**************************
;* Game link file offsets *
;**************************

O_FrameStoreSize 	EQU		6
O_AnimSize			EQU		O_FrameStoreSize*20
AmmoGiveLen			EQU		22*2
GunGiveLen			EQU		12*2
A_FrameLen			EQU		11
A_OptLen			EQU		A_FrameLen*20
A_AnimLen			EQU		A_OptLen*11

GLFT_OBJ_NAME_LENGTH EQU 20
GLFT_GUN_NAME_LENGTH EQU 20
GLFT_BUL_NAME_LENGTH EQU 20

	; Game Link File Offsets
	; Where possible, these are defined in terms the NUM limits above.
	STRUCTURE GLFT,64
		STRUCT GLFT_LevelNames_l,(NUM_LEVELS*40)
		STRUCT GLFT_ObjGfxNames_l,(NUM_OBJECT_DEFS*64)
		STRUCT GLFT_SFXFilenames_l,(NUM_SFX*60)
		STRUCT GLFT_FloorFilename_l,64
		STRUCT GLFT_TextureFilename_l,192
		STRUCT GLFT_GunGFXFilename_l,64
		STRUCT GLFT_StoryFilename_l,64
		STRUCT GLFT_BulletDefs_l,(NUM_BULLET_DEFS*BulT_SizeOf_l)
		STRUCT GLFT_BulletNames_l,(NUM_BULLET_DEFS*GLFT_BUL_NAME_LENGTH)
		STRUCT GLFT_GunNames_l,(NUM_GUN_DEFS*GLFT_GUN_NAME_LENGTH)
		STRUCT GLFT_ShootDefs_l,(NUM_GUN_DEFS*ShootT_SizeOf_l)
		STRUCT GLFT_AlienNames_l,(NUM_ALIEN_DEFS*20)
		STRUCT GLFT_AlienDefs_l,(NUM_ALIEN_DEFS*AlienT_SizeOf_l)
		STRUCT GLFT_FrameData_l,7680 								; todo - figure out how this is derived
		STRUCT GLFT_ObjectNames_l,(NUM_OBJECT_DEFS*GLFT_OBJ_NAME_LENGTH)
		STRUCT GLFT_ObjectDefs,(NUM_OBJECT_DEFS*ODefT_SizeOf_l)
		STRUCT GLFT_ObjectDefAnims_l,(NUM_OBJECT_DEFS*O_AnimSize)
		STRUCT GLFT_ObjectActAnims_l,(NUM_OBJECT_DEFS*O_AnimSize)
		STRUCT GLFT_AmmoGive_l,(NUM_OBJECT_DEFS*AmmoGiveLen)		; ammo given per (collectable) object
		STRUCT GLFT_GunGive_l,(NUM_OBJECT_DEFS*GunGiveLen)			; guns given per (collectable) object
		STRUCT GLFT_AlienAnims_l,(NUM_ALIEN_DEFS*A_AnimLen)
		STRUCT GLFT_VectorNames_l,(NUM_OBJECT_DEFS*64)
		STRUCT GLFT_WallGFXNames_l,(NUM_WALL_TEXTURES*64)
		STRUCT GLFT_WallHeights_l,(NUM_WALL_TEXTURES*2)
		STRUCT GLFT_AlienBrights_l,(NUM_ALIEN_DEFS*2)
		STRUCT GLFT_GunObjects_l,(NUM_GUN_DEFS*2)
		UWORD  GLFT_Player1Graphic_w
		UWORD  GLFT_Player2Graphic_w
		STRUCT GLFT_FloorData_l,(16*4) ; MSW is damage, LSW is sound effect
		STRUCT GLFT_AlienShootDefs_l,(NUM_ALIEN_DEFS*ShootT_SizeOf_l)
		STRUCT GLFT_AmbientSFX_l,(16*2)
		STRUCT GLFT_LevelMusic_l,(NUM_LEVELS*64)
		STRUCT GLFT_EchoTable_l,(60)
		LABEL  GLFT_SizeOf_l

NUM_INVENTORY_ITEMS EQU (NUM_GUN_DEFS+2)
NUM_INVENTORY_CONSUMABLES EQU (NUM_BULLET_DEFS+2)

MAX_ACHIEVEMENTS EQU 128

	; Inventory consumables (health/fuel/ammo)
	STRUCTURE InvCT,0
		UWORD InvCT_Health_w		        ; 2
		UWORD InvCT_JetpackFuel_w			; 2
		UWORD InvCT_AmmoCounts_vw			; 40 - UWORD[NUM_BULLET_DEFS]
		PADDING (NUM_BULLET_DEFS*2)-2
		LABEL InvCT_SizeOf_l				; 44


	; Inventory items (weapons/jetpack/shield)
	STRUCTURE InvIT,0
		UWORD InvIT_Shield_w				; 2
		UWORD InvIT_JetPack_w				; 2
		UWORD InvIT_Weapons_vw				; 20 - UWORD[NUM_GUN_DEFS]
		PADDING (NUM_GUN_DEFS*2)-2
		LABEL InvIT_SizeOf_l				; 24

	; Full Inventory (player/collectable)
	STRUCTURE InvT,0
		STRUCT InvT_Consumables,(InvCT_SizeOf_l)	; 44
		STRUCT InvT_Items,(InvIT_SizeOf_l)			; 24
		LABEL InvT_SizeOf_l							; 68

	; Custom game properties
	STRUCTURE GModT,0
		; Default inventory limits
		STRUCTURE GModT_MaxInv,(InvCT_SizeOf_l)		; 44
		UWORD     GModT_NumAchievements             ; 2
		UWORD     GModT_AchievementSize             ; 2
		LABEL GModT_SizeOf_l						; 48

	; Game statistics
	STRUCTURE GStatT,0
		; Progressed inventory limits
		STRUCTURE GStatT_MaxInv,(InvCT_SizeOf_l)	; 44

		; Best time so far for each level
		ULONG GStatT_LevelBestTimes_vl              ; 64 - ULONG[NUM_LEVELS]
		PADDING (NUM_LEVELS*4)-4

		; Number of times each level attempted
		UWORD GStatT_LevelPlayCounts_vw			; 32 - UWORD[NUM_LEVELS]
		PADDING (NUM_LEVELS*2)-2

		; Number of times each level beaten
		UWORD GStatT_LevelWonCounts_vw			; 32 - UWORD[NUM_LEVELS]
		PADDING (NUM_LEVELS*2)-2

		; Number of times killed in each level
		UWORD GStatT_LevelFailCounts_vw			; 32 - UWORD[NUM_LEVELS]
		PADDING (NUM_LEVELS*2)-2

		; Number of times the player has improved their best time, per level
		UWORD GStatT_LevelImprovedTimeCounts_vw	; 32 - UWORD[NUM_LEVELS]
		PADDING (NUM_LEVELS*2)-2

		; Number of aliens killed, by type
		UWORD GStatT_AlienKills_vw
		PADDING (NUM_ALIEN_DEFS*2)-2			; 40 - UWORD[NUM_ALIEN_DEFS]

		; Total health collected
		ULONG GStatT_TotalHealthCollected_w     ; 4

		; Total fuel collected
		ULONG GStatT_TotalFuelCollected_w       ; 4

		; Total ammo collected, per ammo class
		ULONG GStatT_TotalAmmoFound_vw
		PADDING (NUM_BULLET_DEFS*4)-4           ; 80 UWORD[NUM_BULLET_DEFS]

		UBYTE GStatT_Achieved_vb
		PADDING (MAX_ACHIEVEMENTS/8)-1

		LABEL GStatT_SizeOf_l

		; TODO GPrefsT

GAME_EVENTBIT_KILL EQU 0
GAME_EVENTBIT_ZONE_CHANGE EQU 1
GAME_EVENTBIT_LEVEL_START  EQU 2

*****************************
* Door Definitions **********
*****************************

DR_Plr_SPC		EQU		0
DR_Plr			EQU		1
DR_Bul			EQU		2
DR_Alien		EQU		3
DR_Timeout		EQU		4
DR_Never		EQU		5
DL_Timeout		EQU		0
DL_Never		EQU		1

LVLT_MESSAGE_LENGTH EQU 160
LVLT_MESSAGE_COUNT  EQU 10

; Maximum number of zones. Note that the game doesn't yet support this limit fully.
LVL_EXPANDED_MAX_ZONE_COUNT EQU 512

; Maximum number of zones. Once this is fully working, rededine as LVL_EXPANDED_MAX_ZONE_COUNT
LVL_MAX_ZONE_COUNT EQU 256

;
; LEVEL DATA FILES
;
	; twolev.bin data header, after the text messages (first: LVLT_MESSAGE_LENGTH * LVLT_NUM_MESSAGES)
	STRUCTURE TLBT,0
		UWORD TBLT_Plr1_StartXPos_w			; 0
		UWORD TBLT_Plr1_StartZPos_w			; 2
		UWORD TBLT_Plr1_StartZoneID_w		; 4
		UWORD TBLT_Plr2_StartXPos_w			; 6
		UWORD TBLT_Plr2_StartZPos_w			; 8
		UWORD TBLT_Plr2_StartZoneID_w		; 10
		UWORD TLBT_NumControlPoints_w		; 12
		UWORD TLBT_NumPoints_w				; 14
		UWORD TLBT_NumZones_w				; 16
		UWORD TLBT_Unknown_w				; 18
		UWORD TLBT_NumObjects_w				; 20
		ULONG TLBT_PointsOffset_l			; 22
		ULONG TLBT_FloorLineOffset_l		; 26
		ULONG TLBT_ObjectDataOffset_l		; 30
		ULONG TLBT_ShotDataOffset_l			; 34 - this in twolev.bin ?
		ULONG TLBT_AlienShotDataOffset_l	; 38 - this in twolev.bin ?
		ULONG TLBT_ObjectPointsOffset_l		; 42
		ULONG TLBT_Plr1ObjectOffset_l		; 46
		ULONG TLBT_Plr2ObjectOffset_l		; 50
	LABEL TLBT_SizeOf_l						; This is the end of the header


	; twolev.graph.bin data header
	STRUCTURE TLGT,0
		; Offset values

		ULONG TLGT_DoorDataOffset_l			; 0
		ULONG TLGT_LiftDataOffset_l			; 4
		ULONG TLGT_SwitchDataOffset_l		; 8
		ULONG TLGT_ZoneGraphAddsOffset_l	; 12
		ULONG TLGT_ZoneAddsOffset_l			; 16
	LABEL TLGT_SizeOf_l


	; Level Data Structure (after message block of LVLT_MESSAGE_LENGTH*LVLT_MESSAGE_COUNT)
	STRUCTURE LvlT,0					; offset, size
		UWORD LvlT_Plr1_StartX_w		; 0, 2
		UWORD LvlT_Plr1_StartZ_w		; 2, 2
		UWORD LvlT_Plr1_Start_ZoneID_w 	; 4, 2
		UWORD LvlT_Plr2_StartX_w		; 6, 2
		UWORD LvlT_Plr2_StartZ_w		; 8, 2
		UWORD LvlT_Plr2_Start_ZoneID_w 	; 10, 2

		UWORD LvlT_NumControlPoints_w	; 12, 2
		UWORD LvlT_NumPoints_w			; 14, 2

		UWORD LvlT_NumZones_w			; 16, 2

		UWORD LvlT_Unk_0_w				; 18,2
		UWORD LvlT_NumObjectPoints_w	; 20,2

		; Offset values are typically measured relative to the start of the file (inc message block)
		ULONG LvlT_OffsetToPoints_l			; 22,4
		ULONG LvlT_OffsetToFloorLines_l		; 26,4
		ULONG LvlT_OffsetToObjects_l		; 30,4
		ULONG LvlT_OffsetToPlayerShot_l		; 34,4
		ULONG LvlT_OffsetToAlienShot_l		; 38,4
		ULONG LvlT_OffsetToObjectPoints_l	; 42,4
		ULONG LvlT_OffsetToPlr1Obj_l		; 46,4
		ULONG LvlT_OffsetToPlr2Obj_l		; 50,4

		LABEL LvlT_ControlPointCoords_vw	; 54 ?

		LABEL LvlT_SizeOf_l

; For two player victory messages
GAME_DM_VICTORY_MESSAGE_LENGTH EQU 80

; For in game option messages
OPTS_MESSAGE_LENGTH EQU 40

MSG_TAG_NARRATIVE EQU 0
MSG_TAG_DEFAULT   EQU (1<<14)
MSG_TAG_OPTIONS   EQU (2<<14)
MSG_TAG_OTHER     EQU (3<<14)

; Other stuff

SKY_BACKDROP_W    EQU 648
SKY_BACKDROP_H    EQU 240

; Rendering Stuff
	; Data structure used by wall drawing
	STRUCTURE WD,0
		LABEL WD_DWidth_l		;  0 ; union
		UWORD WD_LeftX_w		;  0
		UWORD WD_RightX_w		;  2

		LABEL WD_DBM_l			;  4 ; union
		UWORD WD_LeftBM_w		;  4
		UWORD WD_RightBM_w		;  6

		LABEL WD_DDist_l		;  8 ; union
		UWORD WD_LeftDist_w		;  8
		UWORD WD_RightDist_w	; 10

		LABEL WD_DTop_l			; 12 ; union
		UWORD WD_LeftTop_w		; 12
		UWORD WD_RightTop_w		; 14

		LABEL WD_DBot_l			; 16 ; union
		UWORD WD_LeftBot_w		; 16
		UWORD WD_RightBot_w		; 18

		UWORD WD_Unknown_0_w	; 20
		UWORD WD_Unknown_1_w	; 22

		; Whole wall for simple case, lower half for full Gouraud case
		LABEL WD_LeftBrightScaled_l	; 24 ; union
		UWORD WD_LeftBright_w	; 24
		UWORD WD_RightBright_w	; 26

		ULONG WD_DHorizBright_l	; 28

		LABEL WD_UpperLeftBrightScaled_l ; 32 ; union
		UWORD WD_UpperLeftBright_w	; 32
		UWORD WD_UpperRightBright_w ; 34

		ULONG WD_DUpperHorizBright_l ; 36

		LABEL WD_SizeOf_l

