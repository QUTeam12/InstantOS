	**	queueの作成
	.section .text
Start:
	movem.l	%a0,-(%sp)	/*走行レベルの退避*/
	move.w 	#0x2700,%SR		/*割り込み禁止(走行レベル7)*/
	lea.l	top0,%a0
	move.l	%a0,in0
	move.l  %a0,out0
	move.l	#0,s0
	lea.l	top1,%a0
	move.l	%a0,in1
	move.l  %a0,out1
	move.l	#0,s1



	
TEST:
	lea.l in_data,%a0
	lea.l out_data,%a2
	lea.l in_status,%a1
	lea.l out_status,%a3
	move.w #260,%d4
	
PUT_CHECK_Loop:
	move.l	#1,%d0  		/*1番キューに飲み書き込み*/
	subq.w  #1, %d4
	bcs     TO_GET_CHECK_Loop     /* 書き込み回数が0の時に終了 */
	move.b	(%a0),%d1
	jsr     INQ /* 書き込み処理 */
	move.l	%d0,(%a1)+
	add.l	#1,%a0
	bra     PUT_CHECK_Loop

TO_GET_CHECK_Loop:
	move.l  #260, %d4
	jmp     GET_CHECK_Loop

GET_CHECK_Loop:
	move.l	#1,%d0  		/*1番キューに飲み書き込み*/
	subq.w  #1, %d4
	bcs     END_program     /* 書き込み回数が0の時に終了 */
	jsr     OUTQ /* 読み込み処理 */
	move.b	%d1,(%a2)+
	move.l	%d0,(%a3)+
	bra     GET_CHECK_Loop
    
END_program:
	stop #0x2700




	

INQ:
	**	番号noのキューにデータをいれる
	**	入力 no->d0.l	書き込む8bitdata->d1.b
	**	出力 失敗0/成功1 ->d0.l
	movem.l	%a0/%a1,-(%sp)	/*走行レベルの退避*/
	move.w 	#0x2700,%SR		/*割り込み禁止(走行レベル7)*/
	cmp.l 	#0,%d0			/*キュー番号が0*/
	beq	INQ0
	cmp.l 	#1,%d0			/*キュー番号が1*/
	beq	INQ1
	jmp	Queue_fail		/*キュー番号が存在しない*/

	
INQ0:	
	cmp.l	#256,s0
	beq	Queue_fail		/*キューが満杯で失敗*/
	move.l	in0,%a0			
	move.b	%d1,(%a0)		/*データをキューに書き込み*/
	lea.l	bottom0,%a1
	cmp.l	%a1,%a0
	beq	INQ0_step1		/*in==bottomのときin=top*/
	add.l	#1,in0			/*in++*/
	jmp	INQ0_step2

INQ0_step1:
	move.l top0,in0

INQ0_step2:
	add.l	#1,s0 			/*s++*/
	move.l	#1,%d0			/*成功を報告*/
	movem.l (%sp)+,%a0/%a1		/*走行レベルの回復*/
	rts

INQ1:	
	cmp.l	#256,s1
	beq	Queue_fail		/*キューが満杯で失敗*/
	move.l	in1,%a0			
	move.b	%d1,(%a0)		/*データをキューに書き込み*/
	lea.l	bottom1,%a1
	cmp.l	%a1,%a0
	beq	INQ1_step1		/*in==bottomのときin=top*/
	add.l	#1,in1			/*in++*/
	jmp	INQ1_step2

INQ1_step1:
	move.l top1,in1

INQ1_step2:
	add.l	#1,s1 			/*s++*/
	move.l	#1,%d0			/*成功を報告*/
	movem.l (%sp)+,%a0/%a1		/*走行レベルの回復*/
	rts


OUTQ:
	**	番号noのキューからデータを一つ取り出す
	**	入力 no->d0.l
	**	出力 失敗0/成功1 ->d0.l		取り出した8bitdata ->d1.b
	movem.l	%a0/%a1,-(%sp)	/*走行レベルの退避*/
	move.w 	#0x2700,%SR		/*割り込み禁止(走行レベル7)*/
	cmp.l 	#0,%d0			/*キュー番号が0*/
	beq	OUTQ0
	cmp.l 	#1,%d0			/*キュー番号が1*/
	beq	OUTQ1
	jmp	Queue_fail		/*キュー番号が存在しない*/
	

OUTQ0:	
	cmp.l	#0,s0
	beq	Queue_fail		/*キューが満杯で失敗*/
	move.l	out0,%a0			
	move.b	(%a0),%d1		/*データをキューから取り出し*/
	lea.l	bottom0,%a1
	cmp.l	%a1,%a0
	beq	OUTQ0_step1		/*out==bottomのときout=top*/
	add.l	#1,out0			/*out++*/
	jmp	OUTQ0_step2

OUTQ0_step1:
	move.l top0,out0

OUTQ0_step2:
	sub.l	#1,s0 			/*s--*/
	move.l	#1,%d0			/*成功を報告*/
	movem.l (%sp)+,%a0/%a1		/*走行レベルの回復*/
	rts

OUTQ1:	
	cmp.l	#0,s1
	beq	Queue_fail		/*キューが満杯で失敗*/
	move.l	out1,%a0			
	move.b	(%a0),%d1		/*データをキューから取り出し*/
	lea.l	bottom1,%a1
	cmp.l	%a1,%a0
	beq	OUTQ1_step1		/*out==bottomのときout=top*/
	add.l	#1,out1			/*out++*/
	jmp	OUTQ1_step2

OUTQ1_step1:
	move.l top1,out1

OUTQ1_step2:
	sub.l	#1,s1 			/*s--*/
	move.l	#1,%d0			/*成功を報告*/
	movem.l (%sp)+,%a0/%a1		/*走行レベルの回復*/
	rts

	
Queue_fail:
	move.l #0,%d0			/*失敗の報告*/
	movem.l (%sp)+,%a0/%a1		/*走行レベルの回復*/
	rts
	
	
	
	








.section .bss
top0:		.ds.b	255			/*キューの戦闘の番地*/
bottom0:	.ds.b	1			/*キューの末尾の番地*/
out0:		.ds.l	1			/*次に取り出すデータのある番地*/
in0:		.ds.l	1 			/*次にデータを入れるべき番地*/
s0:		.ds.l	1			/*キューに溜まっているデータの数*/

top1:		.ds.b	255			/*キューの戦闘の番地*/
bottom1:	.ds.b	1			/*キューの末尾の番地*/
out1:		.ds.l	1			/*次に取り出すデータのある番地*/
in1:		.ds.l	1 			/*次にデータを入れるべき番地*/
s1:		.ds.l	1			/*キューに溜まっているデータの数*/
	
out_data:	 .ds.l 	300
out_status:	 .ds.l 	300
in_status:	 .ds.l 	300
in_data:	 .ds.l	300


.end
	
	
	
