

*************************************************************
* SET UP INITIAL POSITION OF PLAYER *************************
*************************************************************

INITPLAYER:
 move.l StartRoom,Roompt
 move.l Roompt,a0
 move.l 2(a0),yoff
 move.l StartRoom,OldRoompt
 move.l initxoff,xoff
 move.l initzoff,zoff 
 rts

*************************************************
* Floor lines:                                  *
* A floor line is a line seperating two rooms.  *
* The data for the line is therefore:           *
* x,y,dx,dy,Room1,Room2                         *
* For ease of editing the lines are initially   *
* stored in the form startpt,endpt,Room1,Room2  *
* and the program calculates x,y,dx and dy from *
* this information and stores it in a buffer.   *
*************************************************

PointsToRotatePtr: dc.l 0

***************************************
 include "ab3:level1/testlevel"
***************************************

*************************************************************
* ROOM GRAPHICAL DESCRIPTIONS : WALLS AND FLOORS ************
************************************************************* 

ListOfGraphRooms: dc.l 0

wall SET 0
floor SET 1
roof SET 2
setclip SET 3
object SET 4
curve SET 5

GreenStone SET 0
MetalA SET 4096
MetalB SET 4096*2
MetalC SET 4096*3
Marble SET 4096*4
BulkHead SET 4096*5
SpaceWall SET 4096*6

ZoneGraph0:
 
 dc.w 0
 
 dc.w wall,0,1,0,128
 dc.l 4096*4
 dc.w 0,0,0
 dc.l -1024*12,1024*4

 dc.w wall,1,2,0,128
 dc.l 4096*4
 dc.w 0,0,0
 dc.l -1024*12,1024*4

 dc.w wall,3,0,0,128
 dc.l 4096*4
 dc.w 0,0,0
 dc.l -1024*12,1024*4
 
 dc.w floor,4*4,3
 dc.w 0,1,2,3,0
 dc.w -1,2,0

 dc.w roof,-12*4,3
 dc.w 0,1,2,3,0
 dc.w -1,2,0
 
 dc.w setclip,-1,-1
 
 dc.l -1
 
ZoneGraph1:

 dc.w 1

 dc.w wall,2,4,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*8
 dc.w wall,5,6,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*8
 dc.w wall,7,8,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*8
 dc.w wall,8,9,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*8
 dc.w wall,9,3,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*8

 dc.w wall,3,2,0,128
 dc.l 4096*4
 dc.w 0,0,0
 dc.l 1024*4,1024*8
 
 dc.w wall,3,2,0,128
 dc.l 4096*4
 dc.w 0,0,0
 dc.l -1024*24,-1024*12
 
 dc.w wall,4,5,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,-1024*8
 
 dc.w wall,6,7,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,-1024*12
 
 dc.w floor,8*4,7
 dc.w 3,2,4,5,6,7,8,9,3
 dc.w -1,0,0
 
; dc.w roof,-24*4,7
; dc.w 3,2,4,5,6,7,8,9,3
; dc.w -1,2,-20
 
 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph2:

 dc.w 2

 dc.w wall,6,10,0,128
 dc.l 4096
 dc.w 0,0,0
 dc.l -1024*12,1024*12

 dc.w wall,11,7,0,128
 dc.l 4096
 dc.w 0,0,0
 dc.l -1024*12,1024*12

 dc.w wall,7,6,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l 1024*8,1024*12

 dc.w roof,-4*12,3
 dc.w 6,10,11,7,6
 dc.w 0,256,0
 dc.w floor,4*12,3
 dc.w 6,10,11,7,6
 dc.w -1,2,0

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph3:

 dc.w 3

 dc.w wall,10,12,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*16
 dc.w wall,12,13,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*16
 dc.w wall,14,15,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*16
 dc.w wall,15,16,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*16
 dc.w wall,16,17,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*16
 dc.w wall,17,11,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*16
 dc.w wall,11,10,0,128
 dc.l 4096
 dc.w 0,0,0
 dc.l 1024*12,1024*16
 dc.w wall,11,10,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,-1024*12
 dc.w wall,13,14,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,0
 
; dc.w roof,-4*24,7
; dc.w 11,10,12,13,14,15,16,17,11
; dc.w -1,2,0
 dc.w floor,4*16,7
 dc.w 11,10,12,13,14,15,16,17,11
 dc.w -1,0,0

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph4:
 
 dc.w 4

 dc.w wall,13,18,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l 0,1024*20

 dc.w wall,19,14,0,128
 dc.l 0
 dc.w -10,0,0
 dc.l 0,1024*20
 
 dc.w wall,14,13,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l 1024*16,1024*20
 
 dc.w wall,18,19,0,128
 dc.l 4096*4
 dc.w 0,0,0
 dc.l 0,1024*4
 
 dc.w floor,4*20,2
 dc.w 13,18,14,13
 dc.w -1,0,0

 dc.w floor,4*20,2
 dc.w 18,19,14,18
 dc.w -1,0,-10
 
 dc.w roof,0,3
 dc.w 13,18,19,14,13
 dc.w -1,2,0

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph5:
 
 dc.w 5

 dc.w wall,21,22,0,128
 dc.l 4096*4
 dc.w 15,0,0
 dc.l 1024*4,1024*24
 dc.w wall,22,23,0,128
 dc.l 4096*4
 dc.w 15,0,0
 dc.l 1024*20,1024*24
 dc.w wall,23,19,0,128
 dc.l 4096*4
 dc.w 0,0,0
 dc.l 1024*4,1024*24
 dc.w wall,18,20,0,128
 dc.l 4096*4
 dc.w 5,0,0
 dc.l 1024*4,1024*24

 dc.w wall,20,21,0,128
 dc.l 0
 dc.w 15,0,0
 dc.l 1024*20,1024*24
 dc.w wall,19,18,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l 1024*20,1024*24

 dc.w floor,4*24,4
 dc.w 20,21,23,19,18,20
 dc.w -1,2,-10
 dc.w floor,4*24,2
 dc.w 21,22,23,21
 dc.w -1,2,0
 dc.w roof,4*4,5
 dc.w 20,21,22,23,19,18,20
 dc.w -1,2,0

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph6:
 dc.w 6
 dc.w wall,4,24,0,256
 dc.l 0
 dc.w 10,0,0
 dc.l -1024*8,1024*8
 dc.w wall,25,5,0,256
 dc.l 0
 dc.w 10,0,0
 dc.l -1024*8,1024*8
 
 dc.w floor,8*4,3
 dc.w 4,24,25,5,4
 dc.w -1,0,0
 
 dc.w roof,-8*4,3
 dc.w 4,24,25,5,4
 dc.w -1,2,0
 
 dc.w setclip,-1,-1
 dc.l -1 
ZoneGraph7:
 dc.w 7
 dc.w wall,32,31,0,64*6
 dc.l 4096*2
 dc.w 0,0,0
 dc.l -1024*8,1024*12
 dc.w wall,26,25,0,64*3
 dc.l 4096*2
 dc.w 10,0,0
 dc.l -1024*8,1024*12
 dc.w wall,24,33,0,64*3
 dc.l 4096*2
 dc.w 10,0,0
 dc.l -1024*8,1024*12
 dc.w wall,33,32,0,64*2
 dc.l 4096*2
 dc.w 0,0,0
 dc.l 1024*10,1024*12
 
 dc.w wall,25,24,0,128
 dc.l 4096
 dc.w 10,0,0
 dc.l 1024*8,1024*12
 
 dc.w floor,4*12,3
 dc.w 32,31,26,33,32
 dc.w -1,0,-10
 dc.w floor,4*12,3
 dc.w 33,26,25,24,33
 dc.w -1,0,0

 dc.w roof,-4*8,3
 dc.w 32,31,26,33,32
 dc.w 0,256,-20
 dc.w roof,-4*8,3
 dc.w 33,26,25,24,33
 dc.w 0,256,0

 dc.w setclip,-1,-1
 dc.l -1 
ZoneGraph8:

 dc.w 8

 dc.w wall,31,30,0,64*6
 dc.l 4096*3
 dc.w 15,0,0
 dc.l -1024*8,1024*16

 dc.w wall,27,26,0,64*6
 dc.l 4096*3
 dc.w 15,0,0
 dc.l -1024*8,1024*16

 dc.w wall,26,31,0,128
 dc.l 4096
 dc.w 15,0,0
 dc.l 1024*12,1024*16
 
 dc.w floor,4*16,3
 dc.w 31,30,27,26,31
 dc.w -1,2,5
 
 dc.w roof,-4*8,3
 dc.w 31,30,27,26,31
 dc.w -1,256,5

 dc.w setclip,-1,-1
 dc.l -1 
ZoneGraph9:

 dc.w 9

 dc.w wall,30,29,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*12,1024*20
 dc.w wall,30,29,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*38,-1024*30
 dc.w wall,28,21,0,64*6
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*20
 dc.w wall,20,27,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*38,1024*20

 dc.w wall,27,30,0,128
 dc.l 4096
 dc.w 0,0,0
 dc.l 1024*16,1024*20
 dc.w wall,27,30,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*38,-1024*8
 
 dc.w wall,21,20,0,128
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*38,1024*4
 
; dc.w roof,-4*24,5
; dc.w 30,29,28,21,20,27,30
; dc.w -1,2,-10
 
 dc.w floor,4*20,5
 dc.w 30,29,28,21,20,27,30
 dc.w -1,0,-10

 dc.w setclip,-1,-1
 dc.l -1 
 
ZoneGraph10: dc.w 10

 dc.w wall,29,53,0,64*4
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*20
 dc.w wall,53,54,0,64*3
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*16,1024*20
 dc.w wall,54,55,0,64*4
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*20
 dc.w wall,55,51,0,64*5
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*20
 dc.w wall,52,28,0,64*4
 dc.l 0
 dc.w 0,0,0
 dc.l -1024*24,1024*20

 dc.w wall,51,52,0,128
 dc.l 4096
 dc.w 0,0,0
 dc.l 1024*16,1024*20

 dc.w wall,51,52,0,128
 dc.l 4096
 dc.w 0,0,0
 dc.l -1024*16,0

 dc.w floor,20*4,5
 dc.w 29,53,54,55,51,52,29
 dc.w -1,0,-10
 
 dc.w setclip,-1,-1
 dc.l -1 
ZoneGraph11: dc.w 11

 dc.w wall,50,46,0,64
 dc.l 4096
 dc.w -10,0,0
 dc.l 1024*12,1024*16
 dc.w wall,51,50,0,64*3
 dc.l 4096*3
 dc.w -10,0,0
 dc.l 0,1024*16
 dc.w wall,46,52,0,64*3
 dc.l 4096*3
 dc.w -10,0,0
 dc.l 0,1024*16
 dc.w floor,4*16,3
 dc.w 52,51,50,46,52
 dc.w -1,258,-15
 dc.w roof,0,3
 dc.w 52,51,50,46,52
 dc.w -1,256,-20
 
 dc.w setclip,-1,-1
 dc.l -1 
ZoneGraph12: dc.w 12

 dc.w wall,50,49,0,64
 dc.l 4096
 dc.w 10,0,0
 dc.l -1024*4,1024*12
 dc.w wall,49,48,0,64
 dc.l 4096*2
 dc.w 10,0,0
 dc.l -1024*4,1024*12
 dc.w wall,48,47,0,128
 dc.l 4096*3
 dc.w 10,0,0
 dc.l -1024*4,1024*12
 dc.w wall,47,45,0,128
 dc.l 4096
 dc.w 10,0,0
 dc.l -1024*4,1024*12
 dc.w wall,45,42,0,128
 dc.l 4096*2
 dc.w 10,0,0
 dc.l -1024*4,1024*12
 dc.w wall,43,44,0,128
 dc.l 4096*3
 dc.w 10,0,0
 dc.l -1024*4,1024*12
 dc.w wall,44,46,0,128
 dc.l 4096
 dc.w 10,0,0
 dc.l -1024*4,1024*12

 dc.w wall,46,50,0,64
 dc.l 4096*4
 dc.w 10,0,0
 dc.l -1024*4,0
 
 dc.w floor,4*12,7
 dc.w 42,43,44,46,49,48,47,45,42
 dc.w -1,2,0

 dc.w roof,-4*4,7
 dc.w 42,43,44,46,49,48,47,45,42
 dc.w -1,2,0

 dc.w setclip,-1,-1
 dc.l -1 
ZoneGraph13: dc.w 13

 dc.w wall,41,43,0,32*5
 dc.l 4096
 dc.w 10,0,0
 dc.l -1024*20,1024*12
 dc.w wall,42,40,0,32*7
 dc.l 4096*2
 dc.w 10,0,0
 dc.l -1024*20,1024*12
 dc.w wall,43,42,0,64
 dc.l 4096*4
 dc.w 10,0,0
 dc.l -1024*20,-1024*4
 dc.w floor,4*12,3
 dc.w 43,42,40,41,43
 dc.w -1,2,0
 dc.w roof,-4*20,3
 dc.w 43,42,40,41,43
 dc.w -1,256,0

 dc.w setclip,-1,-1
 dc.l -1 
ZoneGraph14: dc.w 14

 dc.w wall,38,41,0,64*3
 dc.l 4096
 dc.w -10,0,0
 dc.l -1024*20,1024*16
 dc.w wall,40,39,0,64*4
 dc.l 4096*2
 dc.w -10,0,0
 dc.l -1024*20,1024*16
 dc.w wall,41,40,0,64
 dc.l 4096*3
 dc.w -10,0,0
 dc.l 1024*12,1024*16
 
 dc.w floor,4*16,3
 dc.w 38,41,40,39,38
 dc.w -1,2,-15
 dc.w roof,-4*20,3
 dc.w 38,41,40,39,38
 dc.w -1,256,-15
 
 dc.w setclip,-1,-1
 dc.l -1 
ZoneGraph15: dc.w 15

 dc.w wall,22,38,0,64*2
 dc.l 4096*4
 dc.w 15,0,0
 dc.l -1024*20,1024*20
 dc.w wall,39,23,0,64*2
 dc.l 4096*4
 dc.w 15,0,0
 dc.l -1024*20,1024*20
 dc.w wall,23,22,0,64*2
 dc.l 4096
 dc.w 15,0,0
 dc.l -1024*20,1024*4
 dc.w wall,38,39,0,64
 dc.l 4096*2
 dc.w 15,0,0
 dc.l 1024*16,1024*20
 dc.w floor,4*20,3
 dc.w 22,38,39,23,22
 dc.w -1,2,5
 dc.w roof,-4*20,3
 dc.w 22,38,39,23,22
 dc.w -1,2,5

 dc.w setclip,-1,-1
 dc.l -1 
 
ZoneGraph16: dc.w 16

 dc.w wall,64,65,0,128
 dc.l 4096
 dc.w 5,0,0
 dc.l -1024*20,1024*10
 
 dc.w wall,33,64,0,128
 dc.l 4096
 dc.w 10,0,0
 dc.l -1024*20,1024*10

 dc.w wall,32,33,0,256
 dc.l 4096*2
 dc.w 10,0,0 
 dc.l -1024*20,-1024*8

 dc.w wall,65,32,0,128
 dc.l 4096*3
 dc.w 10,0,0
 dc.l 1024*8,1024*10
 
 dc.w floor,10*4,3
 dc.w 65,32,33,64,65
 dc.w -1,2,0
 
 dc.w roof,-20*4,3
 dc.w 65,32,33,64,65
 dc.w -1,256,0

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph17: dc.w 17

 dc.w wall,65,66,0,256
 dc.l BulkHead
 dc.w 10,0,0
 dc.l -1024*20,1024*8

 dc.w wall,67,32,0,192
 dc.l BulkHead
 dc.w 10,0,0
 dc.l -1024*20,1024*8
 
 dc.w wall,66,67,0,128
 dc.l MetalA
 dc.w 10,0,0
 dc.l 1024*6,1024*8

 dc.w floor,8*4,3
 dc.w 66,67,32,65,66
 dc.w 0,258,-5
 
 dc.w roof,-20*4,3
 dc.w 66,67,32,65,66
 dc.w 0,258,-5

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph18: dc.w 18

 dc.w wall,66,68,0,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*30,1024*6

 dc.w wall,68,69,0,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*30,1024*6

 dc.w wall,67,66,0,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*30,-1024*20
 
 dc.w wall,69,67,0,64
 dc.l MetalB
 dc.w 0,0,0
 dc.l 1024*4,1024*6
 
 dc.w wall,69,67,0,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*30,-1024*12
 
 dc.w roof,-30*4,3
 dc.w 66,68,69,67,66
 dc.w 0,256,-20
 
 dc.w floor,6*4,3
 dc.w 66,68,69,67,66
 dc.w 0,258,-15
 
 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph19: dc.w 19

 dc.w wall,69,70,0,64
 dc.l BulkHead
 dc.w 5,0,0
 dc.l -1024*12,1024*4
 
 dc.w wall,79,67,0,128
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*12,1024*4

 dc.w wall,70,79,0,128
 dc.l MetalB
 dc.w 0,0,0
 dc.l 1024*2,1024*4

 dc.w floor,4*4,3
 dc.w 69,70,79,67,69
 dc.w 0,258,0
 
 dc.w roof,-12*4,3
 dc.w 69,70,79,67,69
 dc.w 0,256,0

 dc.w setclip,-1,-1
 dc.l -1
 
ZoneGraph20: dc.w 20

 dc.w wall,70,71,0,32
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*14,1024*2

 dc.w wall,78,79,32,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*14,1024*2

 dc.w wall,71,78,0,64
 dc.l MetalC
 dc.w -5,0,0
 dc.l 0,1024*2

 dc.w wall,79,70,0,32
 dc.l BulkHead
 dc.w 5,0,0
 dc.l -1024*14,-1024*12
 
 dc.w floor,2*4,3
 dc.w 70,71,78,79,70
 dc.w 0,258,0
 
 dc.w roof,-14*4,3
 dc.w 70,71,78,79,70
 dc.w 0,256,0
 
 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph21: dc.w 21
 dc.w wall,71,72,32,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*16,1024*0

 dc.w wall,77,78,0,32
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*16,1024*0

 dc.w wall,72,77,0,64
 dc.l MetalC
 dc.w -5,0,0
 dc.l -1024*2,1024*0

 dc.w wall,78,71,0,32
 dc.l BulkHead
 dc.w 5,0,0
 dc.l -1024*16,-1024*14
 
 dc.w floor,0*4,3
 dc.w 71,72,77,78,71
 dc.w 0,258,0
 
 dc.w roof,-16*4,3
 dc.w 71,72,77,78,71
 dc.w 0,256,0
 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph22: dc.w 22

 dc.w wall,72,73,0,32
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*18,-1024*2

 dc.w wall,76,77,32,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*18,-1024*2

 dc.w wall,73,76,0,64
 dc.l MetalC
 dc.w -5,0,0
 dc.l -1024*4,-1024*2

 dc.w wall,77,72,0,32
 dc.l BulkHead
 dc.w 5,0,0
 dc.l -1024*18,-1024*16
 
 dc.w floor,-2*4,3
 dc.w 72,73,76,77,72
 dc.w 0,258,0
 
 dc.w roof,-18*4,3
 dc.w 72,73,76,77,72
 dc.w 0,256,0

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph23: dc.w 23

 dc.w wall,73,74,32,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*20,-1024*4

 dc.w wall,75,76,0,32
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*20,-1024*4

 dc.w wall,74,75,0,64
 dc.l MetalC
 dc.w 0,0,0
 dc.l -1024*6,-1024*4

 dc.w wall,76,73,0,32
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*20,-1024*18
 
 dc.w floor,-4*4,3
 dc.w 73,74,75,76,73
 dc.w 0,258,0
 
 dc.w roof,-20*4,3
 dc.w 73,74,75,76,73
 dc.w 0,256,5

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph24: dc.w 24

 dc.w wall,74,84,0,128
 dc.l SpaceWall
 dc.w 0,0,0
 dc.l -1024*22,-1024*6

 dc.w wall,85,75,0,128
 dc.l SpaceWall
 dc.w 0,0,0
 dc.l -1024*22,-1024*6

 dc.w wall,84,85,0,64
 dc.l MetalC
 dc.w 0,0,0
 dc.l -1024*8,-1024*6

 dc.w wall,75,74,0,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*22,-1024*20
 
 dc.w floor,-6*4,3
 dc.w 74,84,85,75,74
 dc.w 0,258,0
 
 dc.w roof,-22*4,3
 dc.w 74,84,85,75,74
 dc.w 0,256,0

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph25: dc.w 25

 dc.w wall,84,86,0,32
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*24,-1024*8

 dc.w wall,87,85,32,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*24,-1024*8

 dc.w wall,86,87,0,64
 dc.l MetalC
 dc.w -5,0,0
 dc.l -1024*10,-1024*8

 dc.w wall,85,84,0,64
 dc.l BulkHead
 dc.w 5,0,0
 dc.l -1024*24,-1024*22
 
 dc.w floor,-8*4,3
 dc.w 84,86,87,85,84
 dc.w 0,258,0
 
 dc.w roof,-24*4,3
 dc.w 84,86,87,85,84
 dc.w 0,256,5


 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph26: dc.w 26

 dc.w wall,86,88,32,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*26,-1024*10

 dc.w wall,89,87,0,32
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*26,-1024*10

 dc.w wall,88,89,0,64
 dc.l MetalC
 dc.w -5,0,0
 dc.l -1024*12,-1024*10

 dc.w wall,87,86,0,64
 dc.l BulkHead
 dc.w 5,0,0
 dc.l -1024*26,-1024*24
 
 dc.w floor,-10*4,3
 dc.w 86,88,89,87,86
 dc.w 0,258,0
 
 dc.w roof,-26*4,3
 dc.w 86,88,89,87,86
 dc.w 0,256,5

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph27: dc.w 27

 dc.w wall,88,90,0,32
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*28,-1024*12

 dc.w wall,91,89,32,64
 dc.l BulkHead
 dc.w 0,0,0
 dc.l -1024*28,-1024*12

 dc.w wall,90,91,0,64
 dc.l MetalC
 dc.w -5,0,0
 dc.l -1024*14,-1024*12

 dc.w wall,89,88,0,64
 dc.l BulkHead
 dc.w 5,0,0
 dc.l -1024*28,-1024*26
 
 dc.w floor,-12*4,3
 dc.w 88,90,91,89,88
 dc.w 0,258,0
 
 dc.w roof,-28*4,3
 dc.w 88,90,91,89,88
 dc.w 0,256,5

 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph28: dc.w 28

 dc.w wall,90,82,0,128
 dc.l SpaceWall
 dc.w 0,0,0
 dc.l -1024*30,-1024*14

 dc.w wall,83,91,0,64
 dc.l SpaceWall
 dc.w 0,0,0
 dc.l -1024*30,-1024*14
 
 dc.w wall,91,90,0,64
 dc.l BulkHead
 dc.w 5,0,0
 dc.l -1024*30,-1024*28
 
 dc.w floor,-14*4,3
 dc.w 90,82,83,91,90
 dc.w 0,258,0
 
 dc.w roof,-30*4,3
 dc.w 90,82,83,91,90
 dc.w 0,256,0


 dc.w setclip,-1,-1
 dc.l -1
ZoneGraph29: dc.w 29

 dc.w wall,82,81,0,64
 dc.l MetalA
 dc.w 0,0,0
 dc.l -1024*30,-1024*12

 dc.w wall,81,29,0,64
 dc.l MetalB
 dc.w 0,0,0
 dc.l -1024*30,-1024*12

 dc.w wall,30,80,0,64
 dc.l MetalC
 dc.w 0,0,0
 dc.l -1024*30,-1024*12

 dc.w wall,80,83,0,64
 dc.l MetalB
 dc.w 0,0,0
 dc.l -1024*30,-1024*12
 
 dc.w wall,83,82,0,64
 dc.l MetalC
 dc.w 0,0,0
 dc.l -1024*14,-1024*12

 dc.w roof,-30*4,5
 dc.w 29,30,80,83,82,81,29
 dc.w -1,512,-5
 
 dc.w floor,-12*4,5
 dc.w 29,30,80,83,82,81,29
 dc.w -1,2,0

 dc.w setclip,-1,-1
 dc.l -1
 
