; #########################################################################
;
;   trig.asm - Assembly file for CompEng205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE

FixedSinHelper PROC USES ebx angle:FXPT
    mov ebx, angle
	sub ebx, PI
	invoke FixedSin, ebx
	neg eax
	ret 		; Don't delete this line!!!	
FixedSinHelper ENDP	

FixedSin PROC USES ebx ecx edx angle:FXPT ;UPDATE USES LINE

	mov eax, angle

StartCompare:
	cmp eax, PI_HALF
	je ret1
	jg Bet_90_180
	cmp eax, 0 ; temp <- eax - 0
	jl LessThan0
	
calc:
	mov ecx, PI_INC_RECIP
	imul ecx
	mov ebx, OFFSET SINTAB
	xor eax, eax
	mov ax, WORD PTR [ebx + edx*2]
	jmp Return

Bet_90_180:
	cmp eax, PI
	je ret0
	jg Bet_180_360
	mov ebx, PI
	sub ebx, eax
	mov eax, ebx
	jmp calc

Bet_180_360:
	cmp eax, TWO_PI
	jg GreaterThan360
	invoke FixedSinHelper, eax
	jmp Return
	

implement_later:
	xor eax, eax
	jmp Return

ret0: 
	mov eax, 0
	jmp Return

ret1: 
	mov eax, 1
	shl eax, 16
	jmp Return

GreaterThan360:
	sub eax, TWO_PI
	jmp StartCompare

LessThan0:
	add eax, TWO_PI
	jmp StartCompare
	
Return:
	ret			; Don't delete this line!!!
FixedSin ENDP 

FixedCos PROC USES ebx angle:FXPT
    mov ebx, angle
	add ebx, PI_HALF
	invoke FixedSin, ebx
	ret 		; Don't delete this line!!!	
FixedCos ENDP	
END
