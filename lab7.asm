;ЛР  №7
;------------------------------------------------------------------------------
; Архітектура комп'ютера
; Завдання:     написати програму, що реалізує текстовий інтерфейс
;				 і підпрограми, які викликаються через нього.
; ВУЗ:          НТУУ "КПІ"
; Факультет:    ФІОТ
; Курс:         1
; Група:        ІТ-01
;------------------------------------------------------------------------------
; Дата:         06.05.2021
;---------------------------------
				;I.ЗАГОЛОВОК ПРОГРАМИ
IDEAL			; Директива - тип Асемблера tasm 
MODEL small		; Директива - тип моделі пам’яті 
STACK 256		; Директива - розмір стеку 
				
				;II.ПОЧАТОК СЕГМЕНТУ ДАНИХ 
DATASEG
	menuMessage1 db "press y for count", 10, 13	
	menuMessage2 db "press U for beep", 10, 13
	menuMessage3 db "press i for exit", 10, 13
	menuMessage4 db "Input: ", 10, 13, "$"
	
	errorMessage1 db "wrong input", 10, 13, "$"

	buffStart db 254

	exCode db 0
	
				;III. ПОЧАТОК СЕГМЕНТУ КОДУ
CODESEG

Start:

	mov ax,@data	; @data ідентифікатор, що створюються директивою model
	mov ds, ax	; Завантаження початку сегменту даних в регістр ds
	mov es, ax	; иніціалізація регістру ES
	
	Main:
	call displayMenu
	
	mov ah, 0ah ; 0a - зчитування в буфер
	mov dx, offset buffstart ; запис початку буфера в dx
	int 21h ; виклик переривання 21
	mov bx, offset buffstart ; запис початку буфера в bx
	mov ax, [bx+1] ; занесення введеного знаку до ax
	
	shr ax, 8 ; зсув в регістрі ах

	cmp ax, 079h ; перевірка на ввід 'y'
	je DoCount
	
	cmp ax, 055h ; перевірка на ввід 'U'
	je DoBeep
	
	cmp ax, 069h ; перевірка на ввід 'i'
	je DoExit
	
	call errorMessage ; вивід помилки при помилковому вводі
	jmp Main ; повернення до почактку програми

	DoCount:
		call count ; виклик розрахунку
		jmp Main ; повернення до почактку програми

	DoBeep:
		call beep ; виклик виведення звуку
		jmp Main ; повернення до почактку програми

	DoExit:
		mov ah,4ch 		;Завантаження числа 4ch до регістру ah(Функція DOS 4ch - завершення програми)
		mov al,[exCode]	;отримання коду виходу 
		int 21h			;виклик функції DOS 4ch



	PROC displayMenu
		mov dx, offset menumessage1 ; вивід повідомлення меню
		mov ah,09h
		int 21h	
		ret
	endp displayMenu

	PROC errorMessage
		mov dx, offset errorMessage1 ; вивід повідомлення помилки
		mov ah,09h
		int 21h	
		ret
	endp errorMessage

	PROC count

		mov ax, -7 ; запис а1 до ах

		mov bx, 3 ; записл а2 до bx
		add ax, bx ; додавання а1 і а2
		
		mov bx, 2 ; запис а3 до bx
		imul bx ; ділення на а3

		mov bl, 4 ; запис а4 до bl
		idiv bl ; ділення на а4
		
		mov bl, 3 ; запис а5 до bl
		add al, bl ; додавання а5

		add al, '0' ; переведення у строку 
		mov [ES:0101h], al ; запис виводу до ES
		mov [ES:0102h], 10
		mov [ES:0103h], 13
		mov [ES:0104h], '$'
		mov dx, 100h ; запис адреси рядка в dx
		mov ah, 09h 
		int 21h ; вивід числа
		ret
	endp count

	PROC beep
		in al, 61h ; отримати стан динаміка
		push ax ; зберігаємо його
		or al, 3
		out 61h, al
		or al, 10110110b ; встановлюємо біти для каналу 
		out 43h, al ; ввімкнути динамік
		mov ax, 4000 ; частота звуку
		out 42h, al ; ввімкнути таймер, який видає імпульси до динаміку
		mov al, ah  ; ah -> al
		out 42h, al ; відправка старшого байту
		
		mov cx,0030h ;старше слово паузи
		mov dx,0000h ; молодше слово паузи
		mov ah,86h ; функция 86h
		int 15h ; пауза


		pop ax ; отримуємо дефолтний стан
		and AL, 11111100B ; скидаємо два молодших біти
		out 61h, AL ; вимкнення динаміку
		ret
	endp beep
END Start