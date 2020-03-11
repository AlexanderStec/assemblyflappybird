; #########################################################################
;
;   stars.asm - Assembly file for CompEng205 Assignment 1
;   Alexander Stec - APS2754 
;   1/15/20
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

	;; Place your code here
      
        invoke DrawStar, 150, 200
        invoke DrawStar, 100, 150
        invoke DrawStar, 50, 20
        invoke DrawStar, 480, 259
        invoke DrawStar, 186, 478
        invoke DrawStar, 391, 220
        invoke DrawStar, 411, 245
        invoke DrawStar, 36, 240
        invoke DrawStar, 311, 177
        invoke DrawStar, 59, 181
        invoke DrawStar, 188, 95
        invoke DrawStar, 408, 353
        invoke DrawStar, 508, 263
        invoke DrawStar, 328, 192
        invoke DrawStar, 283, 310
        invoke DrawStar, 63, 437
        invoke DrawStar, 177, 311
        invoke DrawStar, 181, 59
        invoke DrawStar, 95, 188
        invoke DrawStar, 353, 408
        invoke DrawStar, 263, 500
        invoke DrawStar, 192, 328
        invoke DrawStar, 310, 283
        invoke DrawStar, 437, 63
        invoke DrawStar, 350, 25
        invoke DrawStar, 500, 150
        invoke DrawStar, 50, 400
        invoke DrawStar, 530, 25
        invoke DrawStar, 530, 400


	ret  			; Careful! Don't remove this line
DrawStarField endp



END
