shiftsum MACRO	;shifts whole sum and returns shifted away part in al
mov bx,[VARsum]
mov al,bl
and al,07h	;last three bits are in al now

shr bx,3	;shift for sum
mov cx,[VARsum+2]
shl cx,13
or bx,cx
mov [VARsum],bx

mov bx,[VARsum+2]
shr bx,3	;shift for sum+2
mov cx,[VARsum+4]
shl cx,13
or bx,cx
mov [VARsum+2],bx

mov bx,[VARsum+4]
shr bx,3	;shift for sum+4
mov cx,[VARsum+6]
shl cx,13
or bx,cx
mov [VARsum+4],bx

mov bx,[VARsum+6]
shr bx,3	;shift for sum+6
mov [VARsum+6],bx
#EM


sumzero MACRO ;conditional, check if sum is zero
mov bx,[VARsum]
or bx,[VARsum+2] 
or bx,[VARsum+4]
or bx,[VARsum+6]
cmp bx,00h	;probably can be omitted
#EM



pushsum MACRO 
mov ah, 0h
push bp
mov bp,sp	;create a new stack scope

sumzero		;if the result is zero, just push a zero
jnz nozero	;else work as usual
mov al, '0'
push ax
jmp endpushsum

nozero:		;pushing loop
shiftsum
add al,'0'
push ax
sumzero
jnz nozero

endpushsum:
#EM



popsum MACRO


popsumputc:	;pop and print characters loop
pop dx		
mov ah,02h
int 21h		;print next character
cmp sp,bp	;check if everything is popped
jne popsumputc

pop bp		;restore old stack
#EM 

SHIFT MACRO
    
    shl cx,3
    mov dx,bx
    shr dx,13
    or cx,dx
    shl bx,3
    or bl,al
#em


GETCstar MACRO          ;read to al
    getcstarbegin:
    mov ah,01h
    int 21h             ;read a character
    sub al,'0'      
    mov ah, 00h
    cmp al,-6           ;check if it is '*'
    je endgetcstar
    SHIFT             
    jmp getcstarbegin
    endgetcstar:
#EM      

GETCnull MACRO          ;reads to al 
    getcnullbegin:
    mov ah,01h
    int 21h
    sub al,'0'
    mov ah, 00h
    cmp al,0ddh         ;check if it is endl
    je endgetcnull
    SHIFT
    jmp getcnullbegin
    endgetcnull:
#EM 


SUMMER MACRO		;sum the VARacc and VARsum and write it in VARsum
    
    mov ax,[VARacc]	;summing the least significant parts
    mov bx,[VARsum]
    add ax,bx
    mov [VARsum],ax
    
    mov ax,[VARacc+2]
    mov bx,[VARsum+2]
    adc ax,bx
    mov [VARsum+2],ax
    
    mov ax,[VARacc+4]
    mov bx,[VARsum+4]
    adc ax,bx
    mov [VARsum+4],ax
    
    mov ax,[VARacc+6]	;summing the most significant parts
    mov bx,[VARsum+6]
    adc ax,bx
    mov [VARsum+6],ax


#EM
    

    
data segment		; initilaze global variables
   
   VARa DW 0
   VARb DW 0
   VARc DW 0
   VARd DW 0
   VARsum DW 0,0,0,0
   VARacc DW 0,0,0,0 

data ends    



code segment
 
mov [VARa],00h		;initialize all global variables and registers to remove garbage data
mov [VARb],00h
mov [VARc],00h
mov [VARd],00h
mov [VARsum],00h
mov [VARsum+2],00h
mov [VARsum+4],00h
mov [VARsum+6],00h
mov [VARacc],00h
mov [VARacc+2],00h
mov [VARacc+4],00h
mov [VARacc+6],00h
mov bx,00h
mov ax,00h
mov cx,00h
mov dx,00h


 
 GETCstar		;read the first number and move them to the global variables
 mov [VARa],cx
 mov [VARb],bx
 mov cx,00h
 mov bx,00h
 GETCnull		;read the second number and move them to the global variables
 mov [VARc],cx
 mov [VARd],bx
 
 
 mov ax,[VARb]		;multiply the least significant parts of number then move them gloabl var for summing
 mov bx,[VARd]
 mul bx
 mov [VARsum],ax
 mov [VARsum+2],dx
 
 mov ax,[VARa]
 mov bx,[VARd]
 mul bx
 mov [VARacc+2],ax
 mov [VARacc+4],dx
 
 SUMMER 		
 
 mov ax,[VARc]		;multiply middle parts of number then move them gloabl var for summing
 mov bx,[VARb]
 mul bx
 mov [VARacc+2],ax
 mov [VARacc+4],dx
 
 SUMMER
 
 mov [VARacc+2],00h	;multiply the most significant parts of number then move them gloabl var for summing
 mov ax,[VARa]
 mov bx,[VARc]			
 mul bx
 mov [VARacc+4],ax
 mov [VARacc+6],dx
 
 SUMMER
 
 pushsum		;push the the least significant 3 bit to the stack every iterations until it become zero
 
 mov dl, 10		;print newl
 mov ah, 2
 int 21h
 
 popsum			;pop from the stack char by char then print it
  
 mov ax, 00h		;exit process
 int 20h

code ends
