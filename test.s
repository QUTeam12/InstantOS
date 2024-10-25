***************************************************************
** 各種レジスタ定義
***************************************************************
***************
** レジスタ群の先頭
***************
.equ REGBASE, 0xFFF000 | DMAP を使用．
.equ IOBASE, 0x00d00000
***************
** 割り込み関係のレジスタ
***************
.equ IVR, REGBASE+0x300 | 割り込みベクタレジスタ
.equ IMR, REGBASE+0x304 | 割り込みマスクレジスタ
.equ ISR, REGBASE+0x30c | 割り込みステータスレジスタ
.equ IPR, REGBASE+0x310 | 割り込みペンディングレジスタ
***************
** タイマ関係のレジスタ
***************
.equ TCTL1, REGBASE+0x600 | タイマ１コントロールレジスタ
.equ TPRER1, REGBASE+0x602 | タイマ１プリスケーラレジスタ
.equ TCMP1, REGBASE+0x604 | タイマ１コンペアレジスタ
.equ TCN1, REGBASE+0x608 | タイマ１カウンタレジスタ
.equ TSTAT1, REGBASE+0x60a | タイマ１ステータスレジスタ
***************
** UART1（送受信）関係のレジスタ
***************
.equ USTCNT1, REGBASE+0x900 | UART1 ステータス/コントロールレジスタ
.equ UBAUD1, REGBASE+0x902 | UART1 ボーコントロールレジスタ
.equ URX1, REGBASE+0x904 | UART1 受信レジスタ
.equ UTX1, REGBASE+0x906 | UART1 送信レジスタ
***************
** LED
***************
.equ LED7, IOBASE+0x000002f | ボード搭載の LED 用レジスタ
.equ LED6, IOBASE+0x000002d | 使用法については付録 A.4.3.1
.equ LED5, IOBASE+0x000002b
.equ LED4, IOBASE+0x0000029
.equ LED3, IOBASE+0x000003f
.equ LED2, IOBASE+0x000003d
.equ LED1, IOBASE+0x000003b
.equ LED0, IOBASE+0x0000039
**************
** 推奨値
**************
.equ Mask_None,       0xFF3FFF
.equ Mask_UART1,      0xFF3FFB
.equ Mask_UART1_Timer,0xFF3FF9
**Timer

**UART1
.equ U_Reset,   0x0000
.equ U_Putpull, 0xE100
.equ U_Putonly, 0xE108
.equ U_Pullonly,0xE10C
***************************************************************
** スタック領域の確保
***************************************************************
.section .bss
.even
SYS_STK:.ds.b 0x4000 | システムスタック領域
.even
SYS_STK_TOP: | システムスタック領域の最後尾
*****************************************************************
**キュー
*****************************************************************
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

***************************************************************
** 初期化
** 内部デバイスレジスタには特定の値が設定されている．
** その理由を知るには，付録 B にある各レジスタの仕様を参照すること．
***************************************************************
.section .text
.even
boot: * スーパーバイザ & 各種設定を行っている最中の割込禁止
move.w #0x2700,%SR
lea.l SYS_STK_TOP, %SP | Set SSP
****************
** 割り込みコントローラの初期化
****************
move.b #0x40, IVR | ユーザ割り込みベクタ番号を0x40+level に設定．
move.l #HardwareInterface ,0x110
move.l #Mask_UART1,IMR | 送受信割り込み許可
****************
** 送受信 (UART1) 関係の初期化 (割り込みレベルは 4 に固定されている)
****************
move.w #U_Reset, USTCNT1 | リセット
move.w #U_Pullonly, USTCNT1 |　受信割り込み許可
move.w #0x0038, UBAUD1 | baud rate = 230400 bps
****************
** タイマ関係の初期化 (割り込みレベルは 6 に固定されている)
*****************
move.w #0x0004, TCTL1 | restart, 割り込み不可,
| システムクロックの 1/16 を単位として計時，a
| タイマ使用停止

**キュー初期化
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
	movem.l (%sp)+,%a0      /* 走行レベルの復帰 */
**スタックレジスタ操作
move.w #0x1000, %SR
move.w #0x0800,UTX1 /* TODO: 消去(送信割り込みテスト用) */
bra MAIN
***************************************************************
**現段階での初期化ルーチンの正常動作を確認するため，最後に ’a’ を
**送信レジスタ UTX1 に書き込む．’a’ が出力されれば，OK.
***************************************************************
.section .text
.even
MAIN:
	move.w #0x2000, %SR
	jmp inter_put_test
	bra MAIN

inter_put_test:
	movem.l %a0/%a1,-(%sp)
	move.w 	#16,%a0
	lea.l	ABC,%a1
	cmp.b	#0,(%a1)
	beq	end_program
inter_put_loop:
	cmp.w	#0,%a0
	beq	to_inter_put_test
	move.l	#1,%d0
	move.b	(%a1),%d1
	sub.w	#1,%a0
	jsr	INQ
	jmp	inter_put_loop

to_inter_put_test:
	add.l	#1,%a1
	cmp.b   #0,(%a1)
	beq     end_program
	move.w	#16,%a0
	jmp	inter_put_loop

end_program:
	move.l	top1,%d2
	move.l 	%d2,out1
	move.l	#256,s1
	move.w 	#0x2000,%sr		/*(走行レベル0)*/
	move.l	#1,%d1
	move.w	#0xE10C,USTCNT1	/*送信割り込み許可にして復帰*/
	movem.l	(%sp)+,%a0/%a1
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

/* INTERPUT(ch)　チャンネルchの送信キューからデータを一つ取り出し実際に送信する（UTX1に書き込む）
入力：ch->%D1.l */
INTERPUT:
	move.w	#0x2700,%sr 	/*割り込み禁止（走行レベルを７に設定）*/
	cmp.l 	#0,%d1
	bne	INTERPUT_END		/*chが0でないなら何もせずに復帰*/
	jsr	OUTQ		/*data->%D1.b  %D0に結果を格納*/
	cmp.l	#0,%d0
	beq	INTERPUT_fail
	ori.w	#0x0800,%d1
	move.w	%d1,UTX1	/*符号拡張してdataをUTX1に格納*/
	jmp 	INTERPUT_END
INTERPUT_fail:
	move.w	#0xE108,USTCNT1	/*OUTQが失敗なら送信割り込み禁止にして復帰*/
INTERPUT_END:
	movem.l (%sp)+,%a0-%a7/%d1-%d7
	rte
	
	
sousin:
	movem.l %a0-%a7/%d1-%d7, -(%sp)
	move.w #0x0800+'b',UTX1
	movem.l (%sp)+,%a0-%a7/%d1-%d7
	rte
HardwareInterface: 
	movem.l %a0-%a7/%d1-%d7, -(%sp)
	move.w UTX1,%d1
	andi.w #0x8000,%d1 
	cmp #0x8000,%d1
	beq INTERPUT
	rte


.section .data

ABC:	.dc.b 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p',0
.end
