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
.equ TCTL1, REGBASE+0x600 	| タイマ１コントロールレジスタ
.equ TPRER1, REGBASE+0x602  | タイマ１プリスケーラレジスタ
.equ TCMP1, REGBASE+0x604 	| タイマ１コンペアレジスタ
.equ TCN1, REGBASE+0x608 	| タイマ１カウンタレジスタ
.equ TSTAT1, REGBASE+0x60a 	| タイマ１ステータスレジスタ
***************
** UART1（送受信）関係のレジスタ
***************
.equ USTCNT1, REGBASE+0x900 | UART1 ステータス/コントロールレジスタ
.equ UBAUD1, REGBASE+0x902 	| UART1 ボーコントロールレジスタ
.equ URX1, REGBASE+0x904 	| UART1 受信レジスタ
.equ UTX1, REGBASE+0x906 	| UART1 送信レジスタ
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
.equ U_Reset,   	  		0x0000
.equ U_Putpull,		  		0xE100
.equ U_Put_Interupt,  		0xE108
.equ U_PutPull_Interupt,	0xE10C
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
***************************************************************
** 初期化
** 内部デバイスレジスタには特定の値が設定されている．
** その理由を知るには，付録 B にある各レジスタの仕様を参照すること．
***************************************************************
.section .text
.even
boot: * スーパーバイザ & 各種設定を行っている最中の割込禁止
move.w #0x2700,%SR
lea.l SYS_STK_TOP, %SP 			| Set SSP

****************
** 割り込みコントローラの初期化
****************
move.b #0x40, IVR 				| ユーザ割り込みベクタ番号を0x40+level に設定．
move.l #HardwareInterface ,0x110| 送受信割込みを設定
move.l #Mask_UART1,IMR 			| 送受信割り込み許可

****************
** 送受信 (UART1) 関係の初期化 (割り込みレベルは 4 に固定されている)
****************
move.w #U_Reset, USTCNT1 		| リセット
move.w #U_Pullonly, USTCNT1 	|受信割り込み許可
move.w #0x0038, UBAUD1 			| baud rate = 230400 bps

****************
** タイマ関係の初期化 (割り込みレベルは 6 に固定されている)
*****************
move.w #0x0004, TCTL1 | restart, 割り込み不可,
| システムクロックの 1/16 を単位として計時，a
| タイマ使用停止

*****************
**キュー初期化
*****************
lea.l	top0,%a0
move.l	%a0,in0
move.l  %a0,out0
move.l	#0,s0
lea.l	top1,%a0
move.l	%a0,in1
move.l  %a0,out1
move.l	#0,s1
bra MAIN

MAIN:
Loop:
	bra Loop

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
INTERPUT:
	moveq.l #0,%d1
	move.b #'1',LED7
	movem.l (%sp)+,%a0-%a7/%d1-%d7
	rte
interupt:
	movem.l %a0-%a7/%d1-%d7, -(%sp)
	move.w URX1, %d0
	add.w #0x0800,%d0
	move.w %d0,UTX1
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
	and.w #0x4000,%d1 
	cmp #0x4000,%d1
	beq INTERPUT
	rte

.end
