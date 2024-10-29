
/* PUTSTRING(ch, p, size) データを送信キューに格納し送信割り込みを開始する　
入力： ch->%D1.l  p->%D2.l  size->%D3.l */
PUTSTRING:
	movem.l	%d4-%d5,-(%sp)
	
	cmp.l	#0,%d1
	bne	PUTSTRING_END /*ch≠0なら何もせず復帰*/

	move.l	#0,%d4	/*sz=%d4*/
	move.l  %d2,%d5 /*i=%d5*/
	
	cmp.l	#0,%d3
	beq	PUTSTRING_STEP2 

PUTSTRING_LOOP:
	cmp.l	%d4,%d3
	beq	PUTSTRING_STEP1

	move.l	#1,%d0
	move.b	%d5,%d1
	jsr	INQ

	cmp.l	#0,%d0
	beq	PUTSTRING_STEP1

	add.l	#1,%d4
	add.l	#1,%d5
	bra	PUTSTRING_LOOP
	
PUTSTRING_STEP1:
	move.w	#0xE10C,USTCNT1 /*送信割り込み許可*/
		
PUTSTRING_STEP2:
	move.l	%d4,%d0

PUTSTRING_END:
	movem.l	(%sp)+,%a4-%a5
	rte
	
