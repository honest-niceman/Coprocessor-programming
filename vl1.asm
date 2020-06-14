model small
.stack 100h
.386
.data
	messageInL db 10,13,"Input first number: $"
	messageInR db 10,13,"Input second number $"
	messageSideEquals db 10,13,"Numbers are equals $"
	messageLeftBigger db 10,13,"First number must be smaller than second number $"
	InvalidData db 10,13,"Invalid data  $"
	leftX dq 0
	rightX dq 0
	buf db 18
	db 18 dup(0)
	ten dd 10
	c dw 0
	one dd 1
	masX dq 640 dup(0) 
	masY dq 640 dup(0) 
	maxY dq 0
	minY dq 0
	koefX dq 0
	koefY dq 0
	koef dq 0
	temp dq 0
	saveMode db ?
	two dd 2
	zero dd 0
	four dd 4
	temp2 dw 0
	koordY dw 640 dup(0) 
	err1 dw 0
	flag db 0
	wid dd 639
	hei dd 479
.code
	inputConvert PROC
		pusha 				
		mov flag,0 			
		vvod:
			mov ah, 0Ah 		
			mov dx,offset buf
			int 21h
			fldz 			
			mov si, 2 		
			cmp buf[si],0dh		
			je @err1		
			cmp buf[si],'-'
			je M1 			
			cmp buf[si],'+'		
			jne M2			
			M1: inc si
				cmp buf[si],'.'
				je @err1
			cmp buf[si],0dh 	
			je @err1		
			M2: cmp buf[si],'.' 	
			je procDrob 		 			
			cmp buf[si],0dh 	
			je endEnter 		
			cmp buf[si],'0' 	
			jb @err1		
			cmp buf[si],'9'		
			ja @err1		
			mov al,buf[si]		
			sub al,'0' 		
			xor ah,ah 		
			mov c,ax 		
			fimul ten 		
			fild c 			
			fadd 			
			inc si 			
			jmp M2 			
			@err1: add flag,1 	
				jmp EndProc 	
			procDrob: 		
				mov err1,si 
				fldz 		
				xor bx,bx 	
				mov bl,buf[1] 
				mov si,bx	
				inc si	 	
				cmp buf[si],'.'	
				je @err1		
			L1: 			
				mov al,buf[si] 	
				cmp al,'.'	
				je  endDrob 
				cmp buf[si],'0' 
				jb @err1	
				cmp buf[si],'9'	
				ja @err1	
				sub al,'0' 	
				xor ah,ah 	
				mov c,ax 	
				fild c		
				fadd 		
				fidiv ten	
				dec si 		
				jmp L1 		
			endDrob: cmp si, err1 
				jne @err1 	
				fadd 		
			endEnter: 		
			cmp buf[2],'-'		
			jne EndProc		
			fchs			
		
		EndProc: popa 		
		ret 				
	inputConvert endp		

	count PROC 				
		mov cx,640 			
		mov si,0 			
		counting:
			fld masX[si]
			fsin
			fst temp
			fmul temp
			fld masX[si]
			
			fld masX[si]
			fcos
			fmul
			fadd
			fld masX[si]
			fmul				
		
			fstp masY[si]
			add si,8
		loop counting 
	ret					
	count endp			

	scalingX PROC 		
		fld rightX		
		fsub leftX		
		fidiv wid		
		fstp temp		
		mov cx,640 		
		mov si,0 		
		fld leftX 		
		cycle: 			
			fst masX[si]	
			fld temp 		
			fadd 			
			add si,8		
		loop cycle			
	ret					
	scalingX endp 		

	@scal PROC			
		fld masY[0]		
		fst maxY		
		fst minY		
		fstp masY[0]	
	       	mov cx,640 	
		mov si,0		
		findMaxMin:		
			fld masY[si]		
			fcom maxY		
			fstsw ax 					
			sahf			
			ja bigger1		

			fcom  minY		
			fstsw ax 						
			sahf			
			jb smaller		
			fstp masY[si]	
			jmp step		
		bigger1:			
			fstp maxY		
			jmp step		
		smaller:			
			fstp minY		
			jmp step	
		step:			
			add si,8 		

		loop findMaxMin		

		fld maxY 			
		fsub minY			
		fstp koef			
		fild hei			
		fdiv koef			
		fstp koefY			
		mov si,0 			
		mov cx, 640
		mov di, 0
			go:
				fld maxY 	
				fsub  masY[si] 	
				fmul koefY	
				frndint		
				fistp koordY[di] 
				add di,2	
				add si,8					
			loop go			
	ret					
	@scal endp			

	drawing PROC 			
		mov ah, 0Fh
		int 10h 			
		mov saveMode, al	
		mov ah,0
		mov al, 12h
		int 10h
		mov si,0
		mov cx,640 			
		L:			
			push cx 	
			mov ah, 0Ch 		
			mov al, 7		
			xor bh,bh		
			xor cx,cx
			mov cx, temp2 	
			xor dx,dx
			mov dx, koordY[si] 
			int 10h 		
			add temp2,1		
			add si,2		
			pop cx			
		loop L 				
	mov ah,0
	int 16h

	mov ah,0
	mov al, saveMode 			
	int 10h
	ret					
	drawing endp

MAIN:
	mov ax, @data		
	mov ds, ax			
							
	@repeat: 			
		finit 			
		
		mov ah, 09h		
		mov dx, offset messageInL
		int 21h			
		
		Call inputConvert 
		fst leftX 			
		cmp flag,1 			
		je @wrong 			
		
		mov ah, 09h 
		mov dx, offset messageInR
		int 21h				
		
		Call inputConvert	
		fst rightX			
		cmp flag,1			
		
		je @wrong			
		fcom 				
		fstsw ax			
		
		sahf				
		je @equal 			
		jb @smaller			
		jmp @allright 			
	@equal:					
		mov ah, 09h
		mov dx, offset messageSideEquals
		int 21h 			
		jmp @repeat
	
	@smaller:
		mov ah, 09h
		mov dx,offset messageLeftBigger
		int 21h				
		jmp @repeat
	
	@wrong:
		mov ah, 09h
		mov dx,offset InvalidData
		int 21h 			
		jmp @repeat
	
	@allright:						
		call scalingX
		call count
		call @scal
		call drawing

		mov ax,4c00h
		int 21h 		
end MAIN
	


