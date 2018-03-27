//takes in two arguments
//r0 = integer (=score)
//r1 = string to be stored into (=scoreString)
.global scoreDemo
scoreDemo:
	counter		.req	r4
	divCount	.req	r5
	number		.req	r6
	temp		.req	r7
	string		.req	r8
	
	push 	{r4-r8, lr}
	
	mov		counter,	#0
	mov		divCount,	#0		//counts how many times 10 was subtracted
	mov		number,	r0			//integer to be converted
	ldr		temp,	='0'			//value of 48
	mov		string,	r1			//location of string for storage
	
	cmp		number,	#10
	blt		singleDigit			//if number is a single digit, convert it directly
	
divLoop:
	sub		number,	#10			//subtract 10 from the number
	add		divCount,	#1		//increment the divCount
	cmp		number,	#10			//compare the number again to see if you can continue subtraction
	
	bge		divLoop				//if greater than or equal to 10, continue subtraction
	
	blt		storeDigit			//if the number is less than 10, store that remainder into the string of chars

storeDigit:
	add		number,	temp			//add 48 to that number to convert it to ascii
	strb		number,	[string,	counter]
	add		counter,	#1		//increment the counter after storing so the next digit is stored into the next byte
	b		checkDivCount

checkDivCount:	
	cmp		divCount,	#10		//check divCount
	
	//if divCount is less than 10, add 48 and store into the string of chars
	addlt	divCount,	temp
	strltb	divCount,	[string,	counter]
	blt		done
	
	//if divCount is greater than or equal to 10, divCount becomes the new number, divCount is reset to 0, and it loops back
	movge	number,	divCount
	movge	divCount,	#0
	bge		divLoop
	
singleDigit:
	add		number,	temp
	strb	number,	[string,	counter]
	b		done
	
done:
	.unreq	counter
	.unreq	divCount
	.unreq	number
	.unreq	temp
	.unreq	string
	pop		{r4-r8, pc}
	
