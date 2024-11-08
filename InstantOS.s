***************************************************************
** 各種レジスタ定義
***************************************************************
***************
** システムコール番号
***************
.equ SYSCALL_NUM_GETSTRING, 1
.equ SYSCALL_NUM_PUTSTRING, 2
.equ SYSCALL_NUM_RESET_TIMER, 3
.equ SYSCALL_NUM_SET_TIMER, 4
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
****************************************************************
*** 初期値のあるデータ領域
****************************************************************
.section .data
TMSG:
.ascii "\n\r" | \r: 行頭へ (キャリッジリターン)
.even | \n: 次の行へ (ラインフィード)
ANS:
.ascii "="
TTC:
.dc.w 0
.even
***************************************************************
** スタック領域の確保
***************************************************************
.section .bss
.even
task_p: .ds.l	1
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

top2:		.ds.b	255			/*キューの戦闘の番地*/
bottom2:	.ds.b	1			/*キューの末尾の番地*/
out2:		.ds.l	1			/*次に取り出すデータのある番地*/
in2:		.ds.l	1 			/*次にデータを入れるべき番地*/
s2:		.ds.l	1			/*キューに溜まっているデータの数*/
***************************************************************
**計算要スタック領域
***************************************************************
STK:		.ds.w	256			/* スタック領域 */
STK_P:		.ds.l	1			/* スタックポインター */
STK_S:		.ds.l	1			/* スタックの要素数 */
***************************************************************
** 計算結果
***************************************************************
NUM:		.ds.b	8
NUM_ANS:	.ds.w	1
**************************************************************
**演算結果表示用フラグ
**************************************************************
NQ:		.ds.l	1
**************************************************************
**　からループ用変数
**************************************************************
Yusei:		.ds.l	1
**************************************************************
*** 初期値の無いデータ領域
****************************************************************
BUF:
.ds.b 256 | BUF[256]
.even
USR_STK:
.ds.b 0x4000 | ユーザスタック領域
.even
USR_STK_TOP: | ユーザスタック領域の最後尾


WORK:		.ds.b 256			/* 受信制御部テスト　*/

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
move.l #SYSCALL_INTERFACE, 0x080 | システムコールを設定
move.l #HardwareInterface ,0x110| 送受信割込みを設定
move.l #TimerInterface, 0x118 | タイマ割り込みの設定
move.l #Mask_None,IMR 			| All Mask

****************
** 送受信 (UART1) 関係の初期化 (割り込みレベルは 4 に固定されている)
****************
move.w #U_Reset, USTCNT1 		| リセット
move.w #U_Putpull, USTCNT1 	|受信割り込みのみ許可
move.w #0x0038, UBAUD1 			| baud rate = 230400 bps

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
lea.l	top2,%a0
move.l	%a0,in2
move.l  %a0,out2
move.l	#0,s2
********************
**計算用スタック初期化
********************
lea.l	STK, %a0
move.l %a0,STK_P
move.l	#0,STK_S
move.l	#1,NQ	/* キュー2へのPUT可能*/
**jsr	TEST
*********************
**からループ変数初期化
*********************
move.l	#0x5ff, Yusei
bra MAIN
TEST:
	move.b	#'e',%d1
	move.l #2 , %d0          /* キュー2を選択 */
	jsr	INQ		        /*data->%D1.b  %D0に結果を格納*/
	move.b	#'e',%d1
	move.l #2 , %d0          /* キュー2を選択 */
	jsr	INQ		        /*data->%D1.b  %D0に結果を格納*/
	move.b	#'*',%d1
	move.l #2 , %d0          /* キュー2を選択 */
	jsr	INQ		        /*data->%D1.b  %D0に結果を格納*/
	
	move.b	#0xd,%d1
	move.l #1 , %d0          /* キュー1を選択 */
	jsr	INQ		        /*data->%D1.b  %D0に結果を格納*/
	move.l	#0,%d1
	jsr	INTERPUT
	stop	#0x2700
****************
**ループ
*****************
MAIN:
**メイン以降をデバッグ
    **jsr Put
    move.w #0x2000,%SR				/* 割り込み許可．(スーパーバイザモードの場合) */
    move.l #Mask_UART1_Timer,IMR 			| All UnMask
    move.w #U_Put_Interupt, USTCNT1 	|受信割り込みのみ許可
    **jmp	INQ_OUTQ_TEST
    **jsr	PUTSTRING_TEST
    **jsr	GETSTRING_TEST
    move.w #0x0000, %SR | USER MODE, LEVEL 0
    lea.l USR_STK_TOP,%SP | user stack の設定
******************************
* sys_GETSTRING, sys_PUTSTRING のテスト
* ターミナルの入力をエコーバックする
******************************
LOOP:
sub.l	#1,Yusei
cmp.l	#0,Yusei
bne	LOOP
move.l #SYSCALL_NUM_GETSTRING, %D0
move.l #0, %D1 | ch = 0
move.l #BUF, %D2 | p = #BUF
move.l #256, %D3 | size = 256
trap #0
move.l %D0, %D3 | size = %D0 (length of given string)
move.l #SYSCALL_NUM_PUTSTRING, %D0
move.l #0, %D1 | ch = 0
move.l #BUF,%D2 | p = #BUF
trap #0
move.l	#0x5ff, Yusei
bra LOOP
TT:
	movem.l %D0-%D7/%A0-%A6,-(%SP)
	move.l #SYSCALL_NUM_RESET_TIMER,%D0
	trap #0
	move.l	#1,NQ	/* エンター処理終了*/
	movem.l (%SP)+,%D0-%D7/%A0-%A6

****************************************************
** ascii変換
***************************************************
**in->%d1(w)	out->%d1(w)
To_Ascii:
	movem.l	%d0,-(%sp)	/*切り替え前のスタックにレジスタ退避*/
	move.w 	%sr,-(%sp)				/*srの値を一時退避*/
	move.w 	#0x2700,%SR			/*割り込み禁止(走行レベル7)*/
	move.l	#'0',%d0
	cmp.l	#0x0,%d1
	beq	C_Ascii
	move.l	#'1',%d0
	cmp.l	#0x1,%d1
	beq	C_Ascii
	move.l	#'2',%d0
	cmp.l	#0x2,%d1
	beq	C_Ascii
	move.l	#'3',%d0
	cmp.l	#0x3,%d1
	beq	C_Ascii
	move.l	#'4',%d0
	cmp.l	#0x4,%d1
	beq	C_Ascii
	move.l	#'5',%d0
	cmp.l	#0x5,%d1
	beq	C_Ascii
	move.l	#'6',%d0
	cmp.l	#0x6,%d1
	beq	C_Ascii
	move.l	#'7',%d0
	cmp.l	#0x7,%d1
	beq	C_Ascii
	move.l	#'8',%d0
	cmpl.	#0x8,%d1
	beq	C_Ascii
	move.l	#'9',%d0
	cmp.l	#0x9,%d1
	beq	C_Ascii
	move.l	#'a',%d0
	cmp.l	#0xa,%d1
	beq	C_Ascii
	move.l	#'b',%d0
	cmp.l	#0xb,%d1
	beq	C_Ascii
	move.l	#'c',%d0
	cmp.l	#0xc,%d1
	beq	C_Ascii
	move.l	#'d',%d0
	cmp.l	#0xd,%d1
	beq	C_Ascii
	move.l	#'e',%d0
	cmp.l	#0xe,%d1
	beq	C_Ascii
	move.l	#'f',%d0
	cmp.l	#0xf,%d1
	beq	C_Ascii
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%d0	/*切り替え前のスタックからレジスタ回復*/
	rts
C_Ascii:
	move.l	%d0,%d1
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%d0	/*切り替え前のスタックからレジスタ回復*/
	rts
******************************************************
**NUM変換
******************************************************
To_Num:
	movem.l	%d0,-(%sp)	/*切り替え前のスタックにレジスタ退避*/
	move.w 	%sr,-(%sp)				/*srの値を一時退避*/
	move.w 	#0x2700,%SR			/*割り込み禁止(走行レベル7)*/
	move.l	#0,%d0
	cmp.l	#'0',%d1
	beq	C_Num
	move.l	#1,%d0
	cmp.l	#'1',%d1
	beq	C_Num
	move.l	#2,%d0
	cmp.l	#'2',%d1
	beq	C_Num
	move.l	#3,%d0
	cmp.l	#'3',%d1
	beq	C_Num
	move.l	#4,%d0
	cmp.l	#'4',%d1
	beq	C_Num
	move.l	#5,%d0
	cmp.l	#'5',%d1
	beq	C_Num
	move.l	#6,%d0
	cmp.l	#'6',%d1
	beq	C_Num
	move.l	#7,%d0
	cmp.l	#'7',%d1
	beq	C_Num
	move.l	#8,%d0
	cmpl.	#'8',%d1
	beq	C_Num
	move.l	#9,%d0
	cmp.l	#'9',%d1
	beq	C_Num
	move.l	#0xa,%d0
	cmp.l	#'a',%d1
	beq	C_Num
	move.l	#0xb,%d0
	cmp.l	#'b',%d1
	beq	C_Num
	move.l	#0xc,%d0
	cmp.l	#'c',%d1
	beq	C_Num
	move.l	#0xd,%d0
	cmp.l	#'d',%d1
	beq	C_Num
	move.l	#0xe,%d0
	cmp.l	#'e',%d1
	beq	C_Num
	move.l	#0xf,%d0
	cmp.l	#'f',%d1
	beq	C_Num
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%d0	/*切り替え前のスタックからレジスタ回復*/
	rts
C_Num:
	move.l	%d0,%d1
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%d0	/*切り替え前のスタックからレジスタ回復*/
	rts
******************************************************
****Queue
******************************************************

INQ:
	**	番号noのキューにデータをいれる
	**	入力 no->d0.l	書き込む8bitdata->d1.b
	**	出力 失敗0/成功1 ->d0.l
	movem.l	%a0/%a1/%d2,-(%sp)	/*切り替え前のスタックにレジスタ退避*/
	move.w 	%sr,-(%sp)				/*srの値を一時退避*/
	move.w 	#0x2700,%SR			/*割り込み禁止(走行レベル7)*/
	cmp.l 	#0,%d0			/*キュー番号が0*/
	beq	INQ0
	cmp.l 	#1,%d0			/*キュー番号が1*/
	beq	INQ1
	cmp.l 	#2,%d0			/*キュー番号が2*/
	beq	INQ2
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
	lea.l	top0,%a0
	move.l	%a0,in0
	

INQ0_step2:
	add.l	#1,s0 			/*s++*/
	move.l	#1,%d0			/*成功を報告*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%a0/%a1/%d2	/*切り替え前のスタックからレジスタ回復*/
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
	lea.l	top1,%a0
	move.l	%a0,in1

INQ1_step2:
	add.l	#1,s1 			/*s++*/
	move.l	#1,%d0			/*成功を報告*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%a0/%a1/%d2	/*切り替え前のスタックからレジスタ回復*/
	rts
INQ2:
	cmp.l	#256,s2
	beq	Queue_fail		/*キューが満杯で失敗*/
	move.l	in2,%a0			
	move.b	%d1,(%a0)		/*データをキューに書き込み*/
	lea.l	bottom2,%a1
	cmp.l	%a1,%a0
	beq	INQ2_step1		/*in==bottomのときin=top*/
	add.l	#1,in2			/*in++*/
	jmp	INQ2_step2

INQ2_step1:
	lea.l	top2,%a0
	move.l	%a0,in2

INQ2_step2:
	add.l	#1,s2 			/*s++*/
	move.l	#1,%d0			/*成功を報告*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%a0/%a1/%d2	/*切り替え前のスタックからレジスタ回復*/
	rts


OUTQ:
	**	番号noのキューからデータを一つ取り出す
	**	入力 キューの番号->d0.l
	**	出力 失敗0/成功1 ->d0.l		取り出した8bitdata ->d1.b
	movem.l	%a0/%a1/%d2,-(%sp)	/*切り替え前のスタックにレジスタ退避*/
	move.w 	%sr,-(%sp)				/*srの値を一時退避*/
	move.w 	#0x2700,%sr			/*割り込み禁止(走行レベル7)*/
	cmp.l 	#0,%d0			/*キュー番号が0*/
	beq	OUTQ0
	cmp.l 	#1,%d0			/*キュー番号が1*/
	beq	OUTQ1
	cmp.l 	#2,%d0			/*キュー番号が2*/
	beq	OUTQ2
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
	lea.l	top0,%a0
	move.l	%a0,out0
	
OUTQ0_step2:
	sub.l	#1,s0 			/*s--*/
	move.l	#1,%d0			/*成功を報告*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%a0/%a1/%d2	/*切り替え前のスタックからレジスタ回復*/
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
	lea.l	top1,%a0
	move.l	%a0,out1

OUTQ1_step2:
	sub.l	#1,s1 			/*s--*/
	move.l	#1,%d0			/*成功を報告*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%a0/%a1/%d2	/*切り替え前のスタックからレジスタ回復*/
	rts

OUTQ2:	
	cmp.l	#0,s2
	beq	Queue_fail		/*キューが満杯で失敗*/
	move.l	out2,%a0			
	move.b	(%a0),%d1		/*データをキューから取り出し*/
	lea.l	bottom2,%a1
	cmp.l	%a1,%a0
	beq	OUTQ2_step1		/*out==bottomのときout=top*/
	add.l	#1,out2			/*out++*/
	jmp	OUTQ2_step2

OUTQ2_step1:
	lea.l	top2,%a0
	move.l	%a0,out2
	
OUTQ2_step2:
	sub.l	#1,s2 			/*s--*/
	move.l	#1,%d0			/*成功を報告*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%a0/%a1/%d2	/*切り替え前のスタックからレジスタ回復*/
	rts	

Queue_fail:
	move.l #0,%d0			/*失敗の報告*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%a0/%a1/%d2	/*切り替え前のスタックからレジスタ回復*/
	rts

**************************************************
** スタック管理
**************************************************
**in-> %d1 (w)	out->%d0(成功:1,失敗:0)***********
INS:
	movem.l	%a1,-(%sp)	/*切り替え前のスタックにレジスタ退避*/
	move.w 	%sr,-(%sp)				/*srの値を一時退避*/
	move.w 	#0x2700,%SR			/*割り込み禁止(走行レベル7)*/
	cmp.l	#256, STK_S	/* スタックがいっぱい */
	beq	STK_fail
	move.l STK_P, %a1
	move.w	%d1,(%a1)
	add.l	#2, STK_P		/* スタックにデータ転送 */
	add.l	#1, STK_S		/* スタックのカウンタ増加 */
	move.l	#1,%d0			/*成功を報告*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%a1	/*切り替え前のスタックからレジスタ回復*/
	rts
**out->%d1 (w),%d0(成功:1,失敗:0)***********
OUTS:
	movem.l	%a1,-(%sp)	/*切り替え前のスタックにレジスタ退避*/
	move.w 	%sr,-(%sp)				/*srの値を一時退避*/
	move.w 	#0x2700,%SR			/*割り込み禁止(走行レベル7)*/
	cmp.l	#0, STK_S	/* スタックが空 */
	beq	STK_fail
	subi.l	#2, STK_P		
	subi.l	#1, STK_S		/* スタックのカウンタ増加 */
	move.l STK_P, %a1
	move.w	(%a1),%d1		/* d1にデータ転送 */
	move.l	#1,%d0			/*成功を報告*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%a1	/*切り替え前のスタックからレジスタ回復*/
	rts
STK_fail:
	move.l #0,%d0			/*失敗の報告*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	movem.l (%sp)+,%a1	/*切り替え前のスタックからレジスタ回復*/
	rts

***************************************************
**INTERGET(ch,data)　受信データを受信キューに格納する
**入力：ch->%d1.l data->%d2.b
***************************************************
INTERGET:
	move.w 	%sr,-(%sp)	/*srの値を一時退避*/
	move.w 	#0x2700,%sr	/*割り込み禁止(走行レベル7)*/
	cmp.l 	#0,%d1
	bne	INTERGET_END	/*chが0でないなら何もせずに復帰*/
	
    	move.l	#0,%d0          /* キュー0を選択 */
	move.b	%d2,%d1		
	jsr	INQ		/*INQ(no->%d0.l,data->%d1.b) %D0.lで結果を報告*/

INTERGET_END:
	move.w  (%sp)+, %sr	/*スーパースタックから走行レベル回復*/
	rts


/* INTERPUT(ch)　チャンネルchの送信キューからデータを一つ取り出し実際に送信する（UTX1に書き込む）
入力：ch->%D1.l */
INTERPUT:
	move.w 	%sr,-(%sp)				/*srの値を一時退避*/
	move.w 	#0x2700,%sr			/*割り込み禁止(走行レベル7)*/
	cmp.l 	#0,%d1
	bne	INTERPUT_END		/*chが0でないなら何もせずに復帰*/
    	move.l #1 , %d0          /* キュー1を選択 */
	jsr	OUTQ		        /*data->%D1.b  %D0に結果を格納*/
	cmp.l	#0,%d0
	beq	INTERPUT_fail
	cmp.l #0,NQ			/*エンターの処理中であるかないか */
	beq	ViewStep
	cmp #0x0d,%d1
	beq	Enter		/* Enterが押されたかどうか */
	move.l #2, %d0			/* キュー2を選択 */
	jsr	INQ	
ViewStep:
	add.w	#0x0800,%d1
	move.w	%d1,UTX1	/*符号拡張してdataをUTX1に格納*/
	jmp 	INTERPUT_END

INTERPUT_fail:
	move.w	#U_Put_Interupt,USTCNT1	/*OUTQが失敗なら送信割り込み禁止にして復帰*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	rts
*******エンターキーが押されたときの処理
Enter:
	move.l	#0,NQ	/* キュー2へのPUT不可能*/
	cmp.l #0, s2
	beq Enter_End
	move.l #2,%d0			/* キュー2を選択 */
	jsr	OUTQ
Enter_Step1:	/* スタックを用いて計算 */
	cmp.b	#'+',%d1
	beq	calc_add
	cmp.b	#'-',%d1
	beq	calc_sub
	cmp.b	#'*',%d1
	beq	calc_mul
	cmp.b	#'/',%d1
	beq	calc_div
	jsr	To_Num
	jsr	INS			/* スタックに転送 */
	bra Enter
	
calc_add:
	move.l	#0x0,%d1
	jsr	OUTS
	cmp.l #0,%d0
	beq	Error
	move.l	%d1,%d2
	move.l	#0x0,%d1
	jsr	OUTS
	add.w	%d2, %d1
	jsr	INS
	bra	Enter
calc_sub:
	move.l	#0x0,%d1
	jsr	OUTS
	cmp.l #0,%d0
	beq	Error
	move.l	%d1,%d2
	move.l	#0x0,%d1
	jsr	OUTS
	sub.w	%d2, %d1
	jsr	INS
	bra	Enter
calc_mul:
	move.l	#0x0,%d1
	jsr	OUTS
	move.l	%d1,%d2
	cmp.l #0,%d0
	beq	Error
	move.l	#0x0,%d1
	jsr	OUTS
	muls.w	%d2, %d1
	jsr	INS
	bra	Enter
calc_div:/* うまく動いていない*/
	move.b	#'B',LED7
	move.l	#0x0,%d1
	jsr	OUTS
	move.l	%d1,%d2
	cmp.l #0,%d0
	beq	Error
	move.l	#0x0,%d1
	jsr	OUTS
	divs.w	%d2, %d1
	move.l	%d1,%d2
	move.l	#0x0,%d1
	move.w	%d2,%d1
	jsr	INS
	bra	Enter	
Enter_End:
	jsr	OUTS
	move.l	%d1,NUM
	move.b	%d1,LED0
	/* = */
	move.l #SYSCALL_NUM_PUTSTRING,%D0
	move.l #0, %D1 | ch = 0
	move.l #ANS, %D2 | p = #TMSG
	move.l #1, %D3 | size = 1
	trap #0
	lea.l	NUM,%a0
	move.l	#5,%d5
Equal_Loop1:
	sub.l	#1,%d5
	beq	Equal_End
	move.b	(%a0)+,%d4
	cmp.l	#0,%d4
	beq	Equal_Loop1
	bra	Equal_Loop3
Equal_Loop2:
	sub.l	#1,%d5
	beq	Equal_End
	move.b	(%a0)+,%d4
Equal_Loop3:
	move.l	%d4, %d1
	and.w	#0xf0,%d1
	ROL.b	#4,%d1
	jsr	To_Ascii
	move.w	%d1,NUM_ANS
	/* 数字を表示 */
	move.l #SYSCALL_NUM_PUTSTRING,%D0
	move.l #0, %D1 | ch = 0
	move.l #NUM_ANS, %D2 | p = #TMSG
	move.l #4, %D3 | size = 1
	trap #0
	move.l	%d4, %d1
	and.w	#0x0f,%d1
	jsr	To_Ascii
	move.w	%d1,NUM_ANS
	/* 数字を表示 */
	move.l #SYSCALL_NUM_PUTSTRING,%D0
	move.l #0, %D1 | ch = 0
	move.l #NUM_ANS, %D2 | p = #TMSG
	move.l #4, %D3 | size = 1
	trap #0
	bra	Equal_Loop2
Equal_End:
	/* 改行  */
	move.l #SYSCALL_NUM_PUTSTRING,%D0
	move.l #0, %D1 | ch = 0
	move.l #TMSG, %D2 | p = #TMSG
	move.l #2, %D3 | size = 2
	trap #0
	** システムコールによる RESET_TIMER の起動
    	move.l #SYSCALL_NUM_RESET_TIMER,%D0
    	trap #0
** システムコールによる SET_TIMER の起動
    	move.l #SYSCALL_NUM_SET_TIMER, %D0
    	move.w #5000, %D1
    	move.l #TT, %D2
    	trap #0
	bra	INTERPUT_END
Error:
	move.b	#'E',LED4
	move.b	#'r',LED3
	move.b	#'r',LED2
	move.b	#'o',LED1
	move.b	#'r',LED0
	move.l	#0,STK_S
INTERPUT_END:
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	rts

Overflow:
	move.b #'S',LED0
	stop #0x2700
******************************************************************************
** PUTSTRING(ch, p, size)
**chの送信キューにp番地から始まるsizeバイトのデータを格納し、送信割り込みを開始　
**入力： ch->%d1.l  p->%d2.l  size->%d3.l
**戻り値：実際に送信したデータ数 sz->d0.l
******************************************************************************
PUTSTRING:
	movem.l	%a0/%d4,-(%sp)
	move.w 	%sr,-(%sp)			/*走行レベル退避*/
	move.w 	#0x2700,%sr			/*割り込み禁止(走行レベル7)*/
	
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
	move.w  (%sp)+, %sr			/*走行レベル回復*/
	movem.l	(%sp)+,%a0/%d4
	rts


 ******************************************************************************
** GETSTRING(ch, p, size)
**chの受信キューからsizeバイトのデータを取り出し、p番地以降にコピーする
**入力： ch->%d1.l  p->%d2.l  size->%d3.l
**戻り値：読みだしたデータ数 sz->d0.l
******************************************************************************
GETSTRING:
	movem.l	%a0/%d4,-(%sp)
	move.w 	%sr,-(%sp)			/*走行レベル退避*/
	move.w 	#0x2700,%sr			/*割り込み禁止(走行レベル7)*/
	
	cmp.l	#0,%d1
	bne	GETSTRING_END 	/*ch≠0なら何もせず復帰*/

	move.l	#0,%d4		/*sz->%d4*/
	movea.l %d2,%a0 	/*i->a0*/ 
	
GETSTRING_LOOP:
	cmp.l	%d4,%d3
	beq	GETSTRING_STEP1 /*sz=sizeなら分岐*/

	move.l	#0,%d0
	jsr	OUTQ 
	
	cmp.l	#0,%d0
	beq	GETSTRING_STEP1 /*OUTQが失敗なら分岐*/
	move.b %d1,(%a0)	/*i番地にデータをコピー*/

	addq.l	#1,%d4		/*sz++*/
	addq.l	#1,%a0		/*i++*/
	bra	GETSTRING_LOOP 
		
GETSTRING_STEP1:
	move.l %d4,%d0

GETSTRING_END:
	move.w  (%sp)+, %sr			/*走行レベル回復*/
	movem.l	(%sp)+,%a0/%d4
	rts
****************
** タイマ関係の初期化 (割り込みレベルは 6 に固定されている)
** RESET_TIMER()  TCTL1を設定
** 入力、戻り値なし
*****************
RESET_TIMER:
	move.w #0x0004, TCTL1 | restart, 割り込み不可
	rts
| システムクロックの 1/16 を単位として計時，
| タイマ使用停止

******************
** SET_TIMER(t, p)
** 入力:割り込み発生周期d1.w
**      割り込み時に起動するルーチンの先頭アドレスd2.l
** 戻り値なし
******************
/* TODO: レジスタの管理。レジスタ変更予定。*/
SET_TIMER:
	movem.l	%a0/%d1,-(%sp)
	lea.l   task_p, %a0 /* TODO: step9までお預け */
	move.l  %d2, (%a0) |task_p=入力d2 /* TODO: step9までお預け */
	move.w  #0xce, TPRER1 |1カウント0.1msecに設定
	move.w  %d1, TCMP1 |割り込み発生周期を設定
	move.w  #0x15, TCTL1 |タイマ使用許可
	movem.l	(%sp)+,%a0/%d1
	rts	

HardwareInterface: 
	movem.l %a0-%a7/%d1-%d7, -(%sp)
	move.w URX1,%d3
	move.b %d3,%d2 /* data = %d2.b */
	andi.w #0x2000,%d3
	cmpi.w #0x2000,%d3 /* URX1の13bit目が1の場合INTERGET呼び出し */
	beq INTERGET_PREPARE
	move.w UTX1,%d1
	**move #0x8000,%d1
	and.w #0x8000,%d1 
	cmp #0x8000,%d1
	beq INTERPUT_PREPARE
        movem.l (%sp)+,%a0-%a7/%d1-%d7 
	rte
INTERGET_PREPARE:
	moveq.l #0,%d1 /* ch = %d1.l = 0 */
	jsr INTERGET
    	movem.l (%sp)+,%a0-%a7/%d1-%d7
    	rte
INTERPUT_PREPARE:
    	move.l #0, %d1
    	jsr INTERPUT
    	movem.l (%sp)+,%a0-%a7/%d1-%d7
    	rte
TimerInterface:
	movem.l %a0-%a7/%d1-%d7, -(%sp)
	btst.b  #0, TSTAT1+1 |コンペアイベント発生チェック
	beq     return |発生無しで復帰
	move.w  #0x0000, TSTAT1 |ステータスレジスタのクリア
	jsr     CALL_RP
	movem.l (%sp)+,%a0-%a7/%d1-%d7 
	rte
return:
    	movem.l (%sp)+,%a0-%a7/%d1-%d7 
	rte
******************
** CALL_RP()
** 入力、戻り値なし
******************
CALL_RP:
	lea.l   task_p, %a0 /* TODO: step9までお預け */
	movea.l (%a0), %a1 |a1=task_p /* TODO: step9までお預け */
	jsr     (%a1) |task_pへジャンプ  /* TODO: step9までお預け */
	rts

	
****************************************************************
**SYSCALL_INTERFACE：システムコール番号に基づき呼び出し
**入力：システムコール番号->%d0.l　システムコール引数->%d1以降
****************************************************************
SYSCALL_INTERFACE:
	cmp.l #1,%d0
	beq   CALL_GETSTRING

	cmp.l #2,%d0
	beq   CALL_PUTSTRING

	cmp.l #3,%d0
	beq   CALL_RESET_TIMER

	cmp.l #4,%d0
	beq   CALL_SET_TIMER
	
	rte

CALL_GETSTRING:
	jsr GETSTRING
	rte

CALL_PUTSTRING:
	jsr PUTSTRING
	rte
	
CALL_RESET_TIMER:
	jsr RESET_TIMER
	rte
	
CALL_SET_TIMER:
	jsr SET_TIMER
	rte
.end
