; #########################################################################
;
;   lines.asm - Assembly file for CompEng205 Assignment 2
;   Alexander Stec - APS2754 
;   1/30/20
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	

.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD


DrawLine PROC USES eax ebx ecx edx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	
	
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD
	
	;; Place your code here

	LOCAL delta_x:DWORD
	LOCAL delta_y:DWORD
	LOCAL inc_x:DWORD
	LOCAL inc_y:DWORD
	LOCAL curr_x:DWORD
	LOCAL curr_y:DWORD
	LOCAL error:DWORD
	LOCAL prev_error:DWORD

	;; absolute value of x1-x0
	
	mov eax, x1 ;; eax <-- x1
	mov ebx, x0 ;; ebx <-- x0
	sub eax, ebx ;; eax <-- eax - ebx
	cmp eax, 0 ;; temp <-- eax - 0
	jge not_neg
	neg eax
not_neg:
	mov delta_x, eax ;; delta_x <-- eax

	;; absolute value of y1-y0

	mov ecx, y1 ;; ecx <-- y1
	mov edx, y0 ;; edx <-- y0
	sub ecx, edx ;; ecx <-- ecx - edx
	cmp ecx, 0 ;; temp <-- ecx - 0
	jge n_neg
	neg ecx
n_neg:
	mov delta_y, ecx ;; delta_y <-- ecx

	;; setting inc_x

	mov eax, x1 ;; eax <-- x1
	mov ecx, y1 ;; ecx <-- y1
	cmp eax, ebx ;; temp <-- eax - ebx (x1 - x0)
	jg positive
	mov inc_x, -1
	jmp continue
positive:
	mov inc_x, 1

	;; setting inc_y

continue:
	cmp ecx, edx ;; temp <-- ecx - edx (y1 - y0)
	jg pos
	mov inc_y, -1
	jmp cont
pos:
	mov inc_y, 1

	;; setting error

cont:
	mov eax, delta_x
	mov ebx, delta_y
	cmp eax, ebx ;; temp <-- eax - ebx (delta_x - delta_y)
	jg ps
	shr ebx, 1
	neg ebx
	mov error, ebx
	jmp con
ps:
	shr eax, 1
	mov error, eax

	;; setting current x and y

con:
	mov eax, x0 ;; eax <-- x0
	mov ebx, y0 ;; ebx <-- y0
	mov curr_x, eax
	mov curr_y, ebx
	INVOKE DrawPixel, curr_x, curr_y, color
	jmp WhileLoopCondition

	;; while loop

WhileLoop:
	INVOKE DrawPixel, curr_x, curr_y, color
	mov eax, error ;; eax <-- error
	mov ebx, delta_x ;; ebx <-- delta_x
	neg ebx ;; ebx <-- -delta_x
	mov ecx, delta_y ;; ecx <-- delta_y
	mov prev_error, eax
	
	;;first if

	cmp eax, ebx ;; temp <-- prev_error - -delta_x
	jle OutFirstIf
	sub eax, delta_y
	mov error, eax
	mov eax, prev_error
	mov edx, curr_x
	add edx, inc_x
	mov curr_x, edx
		
	;;second if

OutFirstIf:
	cmp ecx, eax ;; temp <-- delta_y - prev_error
	jle WhileLoopCondition
	mov eax, error
	add eax, delta_x
	mov error, eax
	mov edx, curr_y
	add edx, inc_y
	mov curr_y, edx

	;; while loop condition

WhileLoopCondition:
	mov eax, x1
	mov ebx, y1
	cmp eax, curr_x ;; temp <-- eax - curr_X
	jne WhileLoop
	cmp ebx, curr_y ;; temp <-- ebx - curr_y
	jne WhileLoop

	
	

	ret        	;;  Don't delete this line...you need it
DrawLine ENDP


END
