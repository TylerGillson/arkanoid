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
	mov		divCount,	#0
	mov		number,	r0
	ldr		temp,	='0'
	mov		string,	r1
	
	cmp		number,	#10
	blt		singleDigit
	
divLoop:
	sub		number,	#10
	add		divCount,	#1
	cmp		number,	#10	
	
	bge		divLoop
	
	blt		storeDigit

storeDigit:
	add		number,	temp
	strb	number,	[string,	counter]
	add		counter,	#1
	b		checkDivCount

checkDivCount:	
	cmp		divCount,	#10
	
	addlt	divCount,	temp
	strltb	divCount,	[string,	counter]
	blt		done
	
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
	
