;	Assignment #4
; 	Author: Keith Beauvais
; 	Section: 1001
; 	Date Last Modified: 9/30/2021
; 	Program Description: This program will explore the use of macros


section .data
;	System Service Constants
	SYSTEM_EXIT equ 60
	SUCCESS equ 0
	SYSTEM_READ equ 0 
	STANDARD_IN equ 0
	SYSTEM_WRITE equ 1
	STANDARD_OUT equ 1

;	Labels
	stringMacro db "getStringLength: ", NULL
	testString db "Testing Length", LINEFEED, NULL
	pass db "PASS", LINEFEED, NULL
	fail db "FAIL", LINEFEED, NULL
	newline db LINEFEED, NULL
	daysLabel db "getDays: ", NULL

	integerTest1 db "String to Integer 1 (-41632): ", NULL
	integerTest2 db "String to Integer 2 (9055): ", NULL
	integerTest3 db "String to Integer 3 (+3): ", NULL

	integerTest4 db "Integer to String (-88,216): ", NULL
	integerTest5 db "Integer to String (372,441): ", NULL

;	Character Constants
	NULL equ 0
	LINEFEED equ 10

;	Time constants
	SECONDS_PER_MINUTE equ 60
	MINUTES_PER_HOUR equ 60
	HOURS_PER_DAY equ 24

;	Time Variables
	secondsInput dd 321265
	secondsOutput dd -1
	minutesOutput dd -1
	hoursOutput dd -1
	daysOutput dd -1

;	Conversion Tests
	stringLength dq -1
	integerString1 db "-41632", NULL
	integerString2 db "9055", NULL
	integerString3 db "+3", NULL
	integerOutput1 dd -1
	integerOutput2 dd -1
	integerOutput3 dd -1
	integerInput1 dd -88216
	integerInput2 dd 372441

section .bss
	stringBuffer resb 1000
	stringOutput1 resb 12
	stringOutput2 resb 12

section .text

;	Calculates the length of a null terminated string (not including null)
;	Argument 1: String Address
;	Argument 2: 64 bit register/memory segment to store the length
%macro getStringLength 2
	
	
	mov rcx, 0 ; moving 0 into rcx counter 
	mov rdx, %1 ; moving the string address in rdx register 

	%%stringLoop:

		mov bl, byte[rdx] ; moving byte (first character into bl register)
		cmp bl, NULL ; compare rax (which is the string address) pointer to NULL
		je %%endStringLoop 
		inc rcx ; increases the count 
		inc rdx ; moves the pointer to next character 
		jmp %%stringLoop

	%%endStringLoop:

	mov %2, rcx ; moves the length of %1 into %2

%endmacro

;	Calculates the number of days, hours, and seconds equal
;	to a given amount of time (in seconds).
;	
;	Argument 1: Total time in seconds (32 bit signed integer)
;	Argument 2: Days (32 bit signed integer)
;	Argument 3: Hours (32 bit signed integer)
;	Argument 4: Minutes (32 bit signed integer)
;	Argument 5: Seconds (32 bit signed integer)
%macro getDays 5
	
	mov eax, %1 ; initial time in seconds
	cdq ; expand signed
	mov ebx, 60 ; moving 60 into ebx register
	idiv ebx ; dividing intial time by 60 
	mov %5, edx ; moving the remainder into argument 5 (seconds)
	cdq
	idiv ebx ; dividing eax register 
	mov %4, edx ; moving the remainder into argument 4 (minutes)
	mov ebx, 24 ; moving 24 into ebx register
	cdq
	idiv ebx ; dividing eax register 
	mov %3, edx ; moving the remainder into argument 3 (minutes)
	mov %2, eax ; moving the quotient into argument 2 (days)


%endmacro

;	Converts a string representing an integer decimal value to an
;	unsigned dword integer
;	Argument 1: An address to a null terminated string
;	Argument 2: A 32 bit register/memory segment to store the value

%macro stringToInt32 2
	mov rcx, 0 ; counter 
	mov rdx, 0 ; moves 0 into rdx register 

	mov r8d, 1 ; sets sign to automatically be 1 unless it has a '-'
	mov bl, byte[%1] ; seeing what the first character is from rdx 
	cmp bl, '-' ; comparing the first character to minus
	jne %%carryOn ; if it is not a minus then it is a plus and it sets r8d to 1 
	mov r8d, -1 ; reset sign to -1 if '-'
	inc rcx ; increment past the '-'

	%%carryOn:
		mov eax, 0 ; setting the sum to 0 eax is sum register
		cmp bl, '+' ; compare to see if the first character is '+' if not then jump to conversion loop because it is either '-' and rcx has be incremented or the first char is a number 
		jne %%conversionLoop
		inc rcx ; increase rcx counter 

	%%conversionLoop:

		mov r11b, byte[%1+rcx] ; moves the character in the index (signaled by rcx counter)
		cmp r11b, NULL ; compares the character to NULL if NULL come out of loop 
		je %%doneConversionLoop
		sub r11b, '0' ; subtracting the first char wiht '0' 
		mov r10b, 10 ; moving 10 into 10 register
		movzx r12w, r11b ; expanding r11b to r12w to do conversion 
		mul r10w ; multiplying ax (sum) by 10
		add ax, r12w ; adding r12w with ax 
		inc rcx ; increase the index counter
		jmp %%conversionLoop

	%%doneConversionLoop:
	movzx eax, ax ; expand ax to eax 16 bit to 32 bit
	mul r8d ; multiply with new sign
	mov %2, eax ; move eax into new memory segment


%endmacro

;	Converts a signed 32 bit integer to a null terminated string representation
;	Argument 1: 32 bit integer
;	Argument 2: Address to a string (12 characters maximum)

%macro int32ToString 2

	mov rcx, 0 ; counter
	mov rdx, 0 ; moves 0 into rdx

	mov r8d, 1 ; sets sign to automatically be 1 unless it has a '-', then compared to 0 
	cmp %1, 0 ; if the number is less than 0 then it is negative and r8d gets set as -1
	jg %%movingOn 

	mov r8d, -1 ; reset sign to -1 if '-'

	%%movingOn:
		mov eax, 0 ; setting the sum to 0 eax is sum register
		mov eax, %1 ; moving 32 bits integer to register
		cmp r8d, -1 ; if it is a negative number the multiply by -1
		jne %%nextStep
		mov r15d, -1 ; if the integer is negative then it will be multiplied by -1
		imul r15d 
		%%nextStep:
		
		mov r11d, 10 ; moving 10 into r11d 
		mov r14, 1 ; using r14 as counter for inToStringLoop

	%%intToStringLoop:

		cdq ; expanding again
		idiv r11d ; dividing edx:eax by r11d which is 10
		add edx, '0'
		movsxd r13, edx ; expanding 32 bits to 64 for pushing onto stack 
		push r13 ; pushing on stack
		cmp eax, 0 ; comparing eax to 0 see if done
		je %%doneIntToString
		inc r14 ;incrementing to know how many to how many times to pop back 
		jmp %%intToStringLoop

	%%doneIntToString:

	cmp r8d, -1 ; compares register r8d to -1 if negative then add a '-' to the front of string
	jne %%popToString
	mov byte[%2], '-' ; adding '-' to front of string 
	inc rcx

	%%popToString:
	pop rax  ; pops in reverse order 
	mov byte[%2+rcx], al ; takes the byte of rax register and adds it to the string 
	dec r14 ; decreases the string length to know how many char to add
	inc rcx ; increases rcx in order to go to the next index
	cmp r14, 0 ; to see if done with all characters
	jne %%popToString 

	mov byte[%2+rcx], NULL ; adds NULL to the end of the string


%endmacro

;	---------------------------------------------------------------
;	---------------------------------------------------------------
;	  DO NOT ALTER THE _START FUNCTION
;	---------------------------------------------------------------
;	---------------------------------------------------------------
global _start
_start:
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, stringMacro
	mov rdx, 17
	syscall

	;	Test String Length
	getStringLength testString, qword[stringLength]
	cmp qword[stringLength], 15
	jne stringTestFail
		mov rsi, pass
	jmp stringTestEnd
	stringTestFail:
		mov rsi, fail
	stringTestEnd:
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rdx, 5
	syscall
	
	;	Test getDays
	getDays dword[secondsInput], dword[daysOutput], dword[hoursOutput], dword[minutesOutput], dword[secondsOutput]
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, daysLabel
	mov rdx, 9
	syscall
	
	cmp dword[daysOutput], 3
	jne daysFail
	cmp dword[hoursOutput], 17
	jne daysFail
	cmp dword[minutesOutput], 14
	jne daysFail
	cmp dword[secondsOutput], 25
	jne daysFail
		mov rsi, pass
		jmp daysPass
	daysFail:
		mov rsi, fail
	daysPass:
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rdx, 5
	syscall
	
	;	Test Integer Conversion
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, integerTest1
	mov rdx, 30
	syscall

	stringToInt32 integerString1, dword[integerOutput1]
	
	cmp dword[integerOutput1], -41632
	jne integerTest1Fail
		mov rsi, pass
	jmp integerTest1Pass
	integerTest1Fail:
		mov rsi, fail
	integerTest1Pass:
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rdx, 5
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, integerTest2
	mov rdx, 28
	syscall

	stringToInt32 integerString2, dword[integerOutput2]
	
	cmp dword[integerOutput2], 9055
	jne integerTest2Fail
		mov rsi, pass
	jmp integerTest2Pass
	integerTest2Fail:
		mov rsi, fail
	integerTest2Pass:
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rdx, 5
	syscall
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, integerTest3
	mov rdx, 26
	syscall

	stringToInt32 integerString3, dword[integerOutput3]
	
	cmp dword[integerOutput3], 3
	jne integerTest3Fail
		mov rsi, pass
	jmp integerTest3Pass
	integerTest3Fail:
		mov rsi, fail
	integerTest3Pass:
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rdx, 5
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, integerTest4
	mov rdx, 29
	syscall
	
	int32ToString dword[integerInput1], stringOutput1
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, stringOutput1
	mov rdx, 12
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, newline
	mov rdx, 1
	syscall

	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, integerTest5
	mov rdx, 29
	syscall
	
	int32ToString dword[integerInput2], stringOutput2
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, stringOutput2
	mov rdx, 12
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, newline
	mov rdx, 1
	syscall
	
endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall