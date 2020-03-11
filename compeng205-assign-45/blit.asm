; #########################################################################
;
;   blit.asm - Assembly file for CompEng205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here
	
.CODE

DrawPixel PROC USES eax ebx ecx edx x:DWORD, y:DWORD, color:DWORD
	mov ebx, x
	mov eax, y
	cmp ebx, 0
	jl Return
	cmp ebx, 639
	jg Return
	cmp eax, 0
	jl Return
	cmp eax, 479
	jg Return
	mov ecx, ScreenBitsPtr
	mov edx, 640
	mul edx
	add eax, ebx
	mov edx, color

	mov BYTE PTR [ecx + eax], dl


Return:
	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES eax ebx ecx edx esi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
	LOCAL start_x:DWORD, start_y:DWORD, end_x:DWORD, end_y:DWORD, curr_x:DWORD, curr_y:DWORD, tran_value:DWORD

	mov eax, xcenter
	mov ebx, ycenter
	mov ecx, ptrBitmap
	mov edx, (EECS205BITMAP PTR [ecx]).dwWidth
	shr edx, 1
	sub eax, edx
	mov start_x, eax
	mov eax, xcenter
	add eax, edx
	mov end_x, eax
	mov edx, (EECS205BITMAP PTR [ecx]).dwHeight
	shr edx, 1
	sub ebx, edx
	mov start_y, ebx
	mov ebx, ycenter
	add ebx, edx
	mov end_y, ebx
	xor edx, edx
	mov dl, (EECS205BITMAP PTR [ecx]).bTransparent
	mov tran_value, edx
	mov curr_y, 0
	mov curr_x, 0
	jmp condition_check
Draw_x_pixels:
	mov ecx, ptrBitmap
	lea esi, (EECS205BITMAP PTR [ecx]).lpBytes
	mov eax, curr_y
	mov ebx, (EECS205BITMAP PTR [ecx]).dwWidth
	mul ebx
	add eax, curr_x
	xor ebx, ebx
	mov bl, BYTE PTR [esi + eax + 4]
	mov edx, tran_value
	cmp ebx, edx
	je Out_Draw
	mov eax, curr_x
	add eax, start_x
	mov ecx, curr_y
	add ecx, start_y
	invoke DrawPixel, eax, ecx, ebx
Out_Draw:
	mov eax, curr_x
	add eax, 1
	mov curr_x, eax
	jmp condition_check
Increment_y:
	mov eax, curr_y
	add eax, 1
	mov curr_y, eax
	mov curr_x, 0
condition_check:
	mov eax, curr_y
	add eax, start_y
	mov ebx, end_y
	cmp eax, ebx
	jge Return
	mov ecx, curr_x
	add ecx, start_x
	mov edx, end_x
	cmp ecx, edx
	jge Increment_y
	jmp Draw_x_pixels
Return:
	ret
BasicBlit ENDP


RotateBlit PROC USES eax ebx ecx edx esi edi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	LOCAL cosa:DWORD, sina:DWORD, shiftX:DWORD, shiftY:DWORD, dstWidth:DWORD, dstHeight:DWORD, dstX:DWORD, dstY:DWORD, srcX:DWORD, srcY:DWORD, X:DWORD, Y:DWORD, tran_value:DWORD
	
	; sets cosa, sina, esi
	mov ebx, angle
	invoke FixedCos, ebx
	mov cosa, eax
	invoke FixedSin, ebx
	mov sina, eax
	mov esi, lpBmp
	xor edx, edx
	mov dl, (EECS205BITMAP PTR [esi]).bTransparent
	mov tran_value, edx

	; sets shiftX
	mov ebx, cosa
	sar ebx, 1
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	shl	eax, 16	
	imul ebx
	mov ebx, edx ; moves result (edx) into ebx
	mov edx, sina
	sar edx, 1
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	shl	eax, 16	
	imul edx
	mov ecx, edx
	sub ebx, ecx
	mov shiftX, ebx ; moves result into shiftX 

	; sets shiftY
	mov ebx, cosa
	sar ebx, 1
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	shl	eax, 16	
	imul ebx
	mov ebx, edx ; moves result (edx) into ebx
	mov edx, sina
	sar edx, 1
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	shl	eax, 16	
	imul edx
	mov ecx, edx
	add ebx, ecx
	mov shiftY, ebx ; moves result into shiftX 

	; sets dstWidth and dstHeight
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	mov ebx, (EECS205BITMAP PTR [esi]).dwHeight
	add eax, ebx
	mov dstWidth, eax
	mov dstHeight, eax
	neg eax
	mov dstX, eax
	mov dstY, eax

outer:
	mov eax, dstX
	mov ebx, dstWidth
	cmp eax, ebx ; temp<-- dstX-dstWidth
	jge Return
Inner:
	mov eax, dstY
	mov ebx, dstHeight
	cmp eax, ebx ; temp<-- dstY-dstHeight
	jge inc_x_reset_y
	
	; sets srcX
	mov eax, dstX
	sal eax, 16
	mov ebx, cosa
	imul ebx
	mov srcX, edx

	mov eax, dstY
	sal eax, 16
	mov ebx, sina
	imul ebx
	mov ecx, srcX
	add ecx, edx
	mov srcX, ecx

	; sets srcY
	mov eax, dstY
	sal eax, 16
	mov ebx, cosa
	imul ebx
	mov srcY, edx

	mov eax, dstX
	sal eax, 16
	mov ebx, sina
	imul ebx
	mov ecx, srcY
	sub ecx, edx
	mov srcY, ecx
	
	;HELLA IFS
	mov eax, srcX
	cmp eax, 0
	jl skip_draw
	mov eax, srcX
	mov ebx, (EECS205BITMAP PTR [esi]).dwWidth
	cmp eax, ebx
	jge skip_draw

	mov eax, srcY
	cmp eax, 0
	jl skip_draw

	mov eax, srcY
	mov ebx, (EECS205BITMAP PTR [esi]).dwHeight
	cmp eax, ebx
	jge skip_draw

	mov eax, xcenter
	mov ebx, dstX
	add eax, ebx
	mov ebx, shiftX
	sub eax, ebx
	cmp eax, 0
	jl skip_draw 
	cmp eax, 640
	jge skip_draw

	mov eax, ycenter
	mov ebx, dstY
	add eax, ebx
	mov ebx, shiftY
	sub eax, ebx
	cmp eax, 0
	jl skip_draw
	cmp eax, 480
	jge skip_draw

	;finds X for draw
	mov eax, xcenter
	mov ebx, dstX
	mov ecx, shiftX
	add eax, ebx
	sub eax, shiftX
	mov X, eax
	
	;finds Y for draw
	mov eax, ycenter
	mov ebx, dstY
	mov ecx, shiftY
	add eax, ebx
	sub eax, shiftY
	mov Y, eax

	;finds pixel value
	lea edi, (EECS205BITMAP PTR [esi]).lpBytes
	mov eax, srcY
	mov ebx, (EECS205BITMAP PTR [esi]).dwWidth
	mul ebx
	mov ecx, srcX
	add eax, ecx
	xor ebx, ebx
	mov bl, BYTE PTR [edi + eax + 4]
	mov edx, tran_value
	cmp edx, ebx
	je skip_draw
	mov eax, X
	mov ecx, Y
	invoke DrawPixel, eax, ecx, ebx 

skip_draw:
	mov eax, dstY
	add eax, 1
	mov dstY, eax
	jmp Inner

inc_x_reset_y:
	mov eax, dstX
	add eax, 1
	mov dstX, eax
	mov eax, dstHeight
	neg eax
	mov dstY, eax
	jmp outer

Return:
	ret	
RotateBlit ENDP



END
