; #########################################################################
;
;   game.asm - Assembly file for CompEng205 Assignment 4/5
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
include game.inc
include keys.inc

include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

include windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib

	
.DATA

	player Sprite<OFFSET bird, OFFSET birdup, OFFSET birddown, 100, 200, 0, 0, -2, 0, 0>
	pipe_arr Sprite 1000 DUP(<OFFSET pipe, 0, 0, 0, 0, 5, 0, 0, 0, 0>)
	pipe_arr2 Sprite 1000 DUP(<OFFSET pipe, 0, 0, 0, 0, 5, 0, 0, 205887, 0>)
	collision DWORD 0
	pause_val DWORD 0
	score DWORD 0
	current_edx DWORD 0
	current_esi DWORD 0
	back_arr Sprite 1000 DUP (<OFFSET back, 0, 0, 0, 180, 1, 0, 0, 0, 0>)
	ground_arr Sprite 1000 DUP(<OFFSET ground, 0, 0, 0, 430, 5, 0, 0, 0, 0>)
	ground_arr2 Sprite 1000 DUP(<OFFSET ground, 0, 0, 0, 0, 5, 0, 0, 205887, 0>)
	
	endStr BYTE "Game Over!", 0
	psStr BYTE "Paused!", 0
	fmtStr BYTE "Pipes Cleared: %d", 0
	outStr BYTE 256 DUP(0)
	hit BYTE "sfx_hit.wav",0
	pipescore BYTE "sfx_point.wav",0
	wing BYTE "sfx_wing.wav",0
	endGame DWORD 0

.CODE
	
UpdatePlayer PROC USES eax ebx
;; checks whether space or mouse pressed to update player velocity
	mov eax, KeyPress
	cmp eax, 020h
	jne checkmouse
	jmp playerup
checkmouse:
	mov eax, MouseStatus.buttons
	cmp eax, 0001h
	jne skipPlayerVelocityUpdate
playerup:
	mov eax, -16
	mov player.y_velocity, eax
	invoke PlaySound, offset wing, 0, SND_FILENAME OR SND_ASYNC

	;; updates rest of screen
skipPlayerVelocityUpdate:

;; this updates player pos
	mov eax, player.y_velocity
	shl eax, 12
	mov player.angle, eax
	mov eax, player.gravity
	mov ebx, player.y_velocity
	sub ebx, eax
	mov player.y_velocity, ebx
	mov eax, player.y_center
	add eax, ebx
	mov player.y_center, eax


;; this handles player sprite animation
	mov eax, player.state
	cmp eax, 1
	jg render1
	INVOKE RotateBlit, player.bitmapPtr2, player.x_center, player.y_center, player.angle
	add eax, 1
	mov player.state, eax
	jmp Return
render1:
	cmp eax, 3
	jg render2
	INVOKE RotateBlit, player.bitmapPtr3, player.x_center, player.y_center, player.angle
	add eax, 1
	mov player.state, eax
	jmp Return
render2:
	cmp eax, 5
	jge subtract
	INVOKE RotateBlit, player.bitmapPtr1, player.x_center, player.y_center, player.angle
	add eax, 1
	mov player.state, eax
	jmp Return
subtract:
	INVOKE RotateBlit, player.bitmapPtr1, player.x_center, player.y_center, player.angle
	sub eax, 5
	mov player.state,eax

Return:
	ret
UpdatePlayer ENDP

UpdatePipes PROC USES eax ebx ecx edx edi esi
	;; this just moves the pipes to the left and draws them and checks for collisions between player
	
	mov eax, SIZEOF pipe_arr
	mov ebx, 0
	mov ecx, TYPE pipe_arr
	mov edi, OFFSET pipe_arr

startLoop:
	cmp ebx, eax
	jge initloop2
	mov edx, (Sprite PTR [edi + ebx]).bitmapPtr1
	mov eax, (Sprite PTR [edi + ebx]).x_center
	mov ecx, (Sprite PTR [edi + ebx]).x_velocity
	sub eax, ecx
	mov (Sprite PTR [edi + ebx]).x_center, eax
	mov ecx, (Sprite PTR [edi + ebx]).y_center
	
	cmp eax, -80
	jl skipCheck
	cmp eax, 720
	jg skipCheck
	INVOKE BasicBlit, edx, eax, ecx
	
	;; check for score
	mov esi, (Sprite PTR [edi + ebx]).state
	cmp esi, 0
	jne skipScore
	cmp eax, 0
	jg skipScore
	inc esi
	mov (Sprite PTR [edi + ebx]).state, esi
	mov esi, score
	inc esi
	mov score, esi
	invoke PlaySound, offset pipescore, 0, SND_FILENAME OR SND_ASYNC

skipScore:

	mov esi, collision
	mov eax, (Sprite PTR [edi + ebx]).x_center
	mov ecx, (Sprite PTR [edi + ebx]).y_center
	mov edx, (Sprite PTR [edi + ebx]).bitmapPtr1
	INVOKE CheckIntersect, player.x_center, player.y_center, player.bitmapPtr1, eax, ecx, edx
	add esi, eax
	mov collision, esi

skipCheck:
	mov ecx, TYPE pipe_arr
	add ebx, ecx
	mov eax, SIZEOF pipe_arr
	jmp startLoop

initloop2:
	mov eax, SIZEOF pipe_arr2
	mov ebx, 0
	mov ecx, TYPE pipe_arr2
	mov edi, OFFSET pipe_arr2

startLoop2:
	cmp ebx, eax
	jge done
	mov edx, (Sprite PTR [edi + ebx]).bitmapPtr1
	mov eax, (Sprite PTR [edi + ebx]).x_center
	mov ecx, (Sprite PTR [edi + ebx]).x_velocity
	mov esi, (Sprite PTR [edi + ebx]).angle
	sub eax, ecx
	mov (Sprite PTR [edi + ebx]).x_center, eax
	mov ecx, (Sprite PTR [edi + ebx]).y_center
	cmp eax, -80
	jl skipCheck2
	cmp eax, 720
	jg skipCheck2
	
	INVOKE RotateBlit, edx, eax, ecx, esi
	
	mov esi, collision
	INVOKE CheckIntersect, player.x_center, player.y_center, player.bitmapPtr1, eax, ecx, edx
	add esi, eax
	mov collision, esi
skipCheck2:
	mov ecx, TYPE pipe_arr2
	add ebx, ecx
	mov eax, SIZEOF pipe_arr2
	jmp startLoop2

done:
	ret
UpdatePipes ENDP

UpdateGround PROC USES eax ebx ecx edx edi esi
	;; this just moves the pipes to the left and draws them and checks for collisions between player
	
	mov eax, SIZEOF ground_arr
	mov ebx, 0
	mov ecx, TYPE ground_arr
	mov edi, OFFSET ground_arr

startLoop:
	cmp ebx, eax
	jge initloop2
	mov edx, (Sprite PTR [edi + ebx]).bitmapPtr1
	mov eax, (Sprite PTR [edi + ebx]).x_center
	mov ecx, (Sprite PTR [edi + ebx]).x_velocity
	sub eax, ecx
	mov (Sprite PTR [edi + ebx]).x_center, eax
	mov ecx, (Sprite PTR [edi + ebx]).y_center
	
	cmp eax, -320
	jl skipCheck
	cmp eax, 960
	jg skipCheck
	INVOKE BasicBlit, edx, eax, ecx
	
	mov esi, collision
	INVOKE CheckIntersect, player.x_center, player.y_center, player.bitmapPtr1, eax, ecx, edx
	add esi, eax
	mov collision, esi

skipCheck:
	mov ecx, TYPE ground_arr
	add ebx, ecx
	mov eax, SIZEOF ground_arr
	jmp startLoop

initloop2:
	mov eax, SIZEOF ground_arr2
	mov ebx, 0
	mov ecx, TYPE ground_arr2
	mov edi, OFFSET ground_arr2

startLoop2:
	cmp ebx, eax
	jge done
	mov edx, (Sprite PTR [edi + ebx]).bitmapPtr1
	mov eax, (Sprite PTR [edi + ebx]).x_center
	mov ecx, (Sprite PTR [edi + ebx]).x_velocity
	mov esi, (Sprite PTR [edi + ebx]).angle
	sub eax, ecx
	mov (Sprite PTR [edi + ebx]).x_center, eax
	mov ecx, (Sprite PTR [edi + ebx]).y_center
	cmp eax, -320
	jl skipCheck2
	cmp eax, 960
	jg skipCheck2
	
	INVOKE RotateBlit, edx, eax, ecx, esi
	

	mov esi, collision
	INVOKE CheckIntersect, player.x_center, player.y_center, player.bitmapPtr1, eax, ecx, edx
	add esi, eax
	mov collision, esi
skipCheck2:
	mov ecx, TYPE ground_arr2
	add ebx, ecx
	mov eax, SIZEOF ground_arr2
	jmp startLoop2

done:
	ret
UpdateGround ENDP

UpdateBack PROC USES eax ebx ecx edx edi esi
	;; this just moves the pipes to the left and draws them and checks for collisions between player
	
	mov eax, SIZEOF back_arr
	mov ebx, 0
	mov ecx, TYPE back_arr
	mov edi, OFFSET back_arr

startLoop:
	cmp ebx, eax
	jge done
	mov edx, (Sprite PTR [edi + ebx]).bitmapPtr1
	mov eax, (Sprite PTR [edi + ebx]).x_center
	mov ecx, (Sprite PTR [edi + ebx]).x_velocity
	sub eax, ecx
	mov (Sprite PTR [edi + ebx]).x_center, eax
	mov ecx, (Sprite PTR [edi + ebx]).y_center
	
	cmp eax, -320
	jl skipCheck
	cmp eax, 960
	jg skipCheck
	INVOKE BasicBlit, edx, eax, ecx

skipCheck:
	mov ecx, TYPE back_arr
	add ebx, ecx
	mov eax, SIZEOF back_arr
	jmp startLoop

done:
	ret
UpdateBack ENDP

GameInit PROC
	rdtsc
	INVOKE nseed, eax

	mov esi, SIZEOF pipe_arr
	mov ebx, 0
	mov edx, 500
	mov edi, OFFSET pipe_arr

startLoop:
	cmp ebx, esi
	jge initground
	mov current_esi, esi
	mov esi, OFFSET pipe_arr2
	mov (Sprite PTR [edi + ebx]).x_center, edx
	mov (Sprite PTR [esi + ebx]).x_center, edx
	mov current_edx, edx
	INVOKE nrandom, 150
	add eax, 425
	mov ecx, TYPE pipe_arr
	mov edx, current_edx
	mov (Sprite PTR [edi + ebx]).y_center, eax
	sub eax, 575
	mov (Sprite PTR [esi + ebx]).y_center, eax
	add ebx, ecx
	add edx, 300
	mov esi, current_esi
	jmp startLoop

initground:
	mov esi, SIZEOF ground_arr
	mov ebx, 0
	mov edx, 320
	mov edi, OFFSET ground_arr
	mov eax, OFFSET ground_arr2
	mov ecx, TYPE ground_arr

startLoopground:
	cmp ebx, esi
	jge initBack
	mov (Sprite PTR [edi + ebx]).x_center, edx
	mov (Sprite PTR [eax + ebx]).x_center, edx
	add ebx, ecx
	add edx, 640
	jmp startLoopground

initBack:
	mov esi, SIZEOF back_arr
	mov ebx, 0
	mov edx, 320
	mov edi, OFFSET back_arr
	mov ecx, TYPE back_arr

startLoopback:
	cmp ebx, esi
	jge done
	mov (Sprite PTR [edi + ebx]).x_center, edx
	add ebx, ecx
	add edx, 640
	jmp startLoopback

done:
	ret         ;; Do not delete this line!!!
GameInit ENDP

GamePlay PROC
	;; checks collisions 
	mov ebx, collision
	cmp ebx, 0
	jne skip

	;; checks pause
	mov eax, KeyPress
	cmp eax, 050h
	jne skip1
	jmp pause1
pause1:
	mov eax, pause_val
	cmp eax, 0
	jne unpause
	mov eax, 1
	mov pause_val, eax
	jmp skip1
unpause:
	mov eax, 0
	mov pause_val, eax
skip1:
	mov eax, pause_val
	cmp eax, 1
	je screenpause
	
	INVOKE UpdateBack
	INVOKE UpdatePlayer
	INVOKE UpdatePipes
	INVOKE UpdateGround

	mov eax, score
	push eax
	push offset fmtStr
	push offset outStr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outStr, 10, 5, 000h

	jmp Return
screenpause:
	INVOKE DrawStr, OFFSET psStr, 250, 200, 000h
	jmp Return
;; the skip has the you lost text
skip:
	mov eax, endGame
	cmp eax, 0
	jne skipsound
	invoke PlaySound, offset hit, 0, SND_FILENAME OR SND_ASYNC
	inc eax 
	mov endGame, eax
skipsound:
	INVOKE DrawStr, OFFSET endStr, 250, 200, 000h
Return:

	ret         ;; Do not delete this line!!!
GamePlay ENDP

CheckIntersect PROC USES ebx ecx edx edi esi oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
	LOCAL oneXwidth: DWORD, oneYheight: DWORD, oneXStart: DWORD, oneXEnd: DWORD, oneYStart: DWORD, oneYEnd: DWORD
	LOCAL twoXwidth: DWORD, twoYheight: DWORD, twoXStart: DWORD, twoXEnd: DWORD, twoYStart: DWORD, twoYEnd: DWORD

	;; gets the width and height for the first sprite
	mov esi, oneBitmap
	mov edx, (EECS205BITMAP PTR [esi]).dwWidth
	mov oneXwidth, edx
	mov edx, (EECS205BITMAP PTR [esi]).dwHeight
	mov oneYheight, edx

	;; finds the corners of the first sprite (startx/endx/starty/endy)
	mov edx, oneXwidth
	shr edx, 1
	mov ebx, oneX
	sub ebx, edx
	mov oneXStart, ebx
	mov edx, oneXwidth
	add ebx, edx
	mov oneXEnd, ebx

	mov edx, oneYheight
	shr edx, 1
	mov ebx, oneY
	sub ebx, edx
	mov oneYStart, ebx
	mov edx, oneYheight
	add ebx, edx
	mov oneYEnd, ebx

	;;gets the width and height for the second sprite
	mov esi, twoBitmap
	mov edx, (EECS205BITMAP PTR [esi]).dwWidth
	mov twoXwidth, edx
	mov edx, (EECS205BITMAP PTR [esi]).dwHeight
	mov twoYheight, edx

	;; finds the corners of the second sprite (startx/endx/starty/endy)
	mov edx, twoXwidth
	shr edx, 1
	mov ebx, twoX
	sub ebx, edx
	mov twoXStart, ebx
	mov edx, twoXwidth
	add ebx, edx
	mov twoXEnd, ebx

	mov edx, twoYheight
	shr edx, 1
	mov ebx, twoY
	sub ebx, edx
	mov twoYStart, ebx
	mov edx, twoYheight
	add ebx, edx
	mov twoYEnd, ebx

	;;condition and boundary checks
	
	mov ebx, oneXStart
	mov ecx, twoXEnd
	cmp ebx, ecx ;;temp <-- oneXstart-twoXend
	jge Return_No_Collision

	mov ebx, oneXEnd
	mov ecx, twoXStart
	cmp ebx, ecx ;;temp <-- oneXend-twoXStart
	jle Return_No_Collision

	mov ebx, oneYStart
	mov ecx, twoYEnd
	cmp ebx, ecx ;;temp <-- oneYstart-twoYend
	jge Return_No_Collision

	mov ebx, oneYEnd
	mov ecx, twoYStart
	cmp ebx, ecx ;;temp <-- oneYEnd-twoYStart
	jle Return_No_Collision

	;;If all conditions pass, there is a collision, so return 1
	mov eax, 1
	jmp Return

Return_No_Collision:
	mov eax, 0

Return:
	ret			;; Do not delete this line!!!
CheckIntersect ENDP

END
