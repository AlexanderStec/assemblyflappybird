; #########################################################################
;
;   game.inc - Includes for CompEng205 Assignment 4/5
;
;
; #########################################################################

;; Library Definitions
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

_Sprite STRUCT
    bitmapPtr1 DWORD PTR ?
    bitmapPtr2 DWORD PTR ?
    bitmapPtr3 DWORD PTR ?
    x_center DWORD ?
    y_center DWORD ?
    x_velocity DWORD ?
    y_velocity DWORD ?
    gravity DWORD ?
    angle FXPT ?
    state DWORD ?
_Sprite ENDS

Sprite TYPEDEF _Sprite

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD
EXTERNDEF bird:EECS205BITMAP
EXTERNDEF birdup:EECS205BITMAP
EXTERNDEF birddown:EECS205BITMAP
EXTERNDEF pipe:EECS205BITMAP
EXTERNDEF back:EECS205BITMAP
EXTERNDEF ground:EECS205BITMAP

;; User Defined Functions
GameInit PROTO
GamePlay PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP 




