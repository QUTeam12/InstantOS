******************************************************************************
** PUTSTRING(ch, p, size)
**chの送信キューにp番地から始まるsizeバイトのデータを格納し、送信割り込みを開始　
**入力： ch->%d1.l  p->%d2.l  size->%d3.l
**戻り値：実際に送信したデータ数 sz->d0.l
******************************************************************************
PUTSTRING:
	movem.l	%d4/%a0,-(%sp)
	
	cmp.l	#0,%d1
	bne	PUTSTRING_END 	/*ch≠0なら何もせず復帰*/

	move.l	#0,%d4		/*sz->%d4*/
	movea.l %d2,%a0 	/*i->a0*/ 
	
	cmp.l	#0,%d3
	beq	PUTSTRING_STEP2 /*size=0なら分岐*/
	
PUTSTRING_LOOP:
	cmp.l	%d4,%d3
	beq	PUTSTRING_STEP1 /*sz=sizeなら分岐*/

	move.l	#1,%d0
	move.b 	(%a0)+,%d1
	jsr	INQ 		/*INQ(no->d0.l,data->d1.b)*/

	cmp.l	#0,%d0
	beq	PUTSTRING_STEP1 /*INQが失敗なら分岐*/

	addq.l	#1,%d4		/*sz++*/
	bra	PUTSTRING_LOOP 
	
PUTSTRING_STEP1:
	move.w	#0xE10C,USTCNT1 /*送信割り込み許可*/
		
PUTSTRING_STEP2:
	move.l %d4,%d0

PUTSTRING_END:
	movem.l	(%sp)+,%d4/%a0
	rte
	
