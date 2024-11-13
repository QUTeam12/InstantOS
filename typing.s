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
.equ SYSCALL_NUM_PUT_TYPING_STRING, 5
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
level_msg:
	.ascii "Select typing level(0-3): "
	.even
gameover_msg:
	.ascii "\r\nGame Over\r\n"
	.even
gameclear_msg:
	.ascii "\r\nGame Clear\r\n"
	.even
continue_msg:
	.ascii "Press Enter if you wanna continue\r\n"
	.even
correct_msg:
	.ascii "collect: "
	.even
error_msg:
	.ascii "wrong: "
	.even
speed_msg:
	.ascii "typing speed(letter/min): "
	.even
newline:
	.ascii "\r\n"
	.even
level1:
	.ascii	"1"
	.even
level2:
	.ascii	"2"
	.even
level3:
	.ascii	"3"
	.even
level1_msg:
	.ascii	"level 1\r\n"
	.even
level2_msg:
	.ascii	"level 2\r\n"
	.even
level3_msg:
	.ascii	"level 3\r\n"
	.even
q1_msg:
	.ascii	"********** Q1 **********\r\n"
	.even
q2_msg:
	.ascii	"********** Q2 **********\r\n"
	.even
q3_msg:
	.ascii	"********** Q3 **********\r\n"
	.even
str1:
	.ascii	"abc"
	.even
str2:
	.ascii	"yellow"
	.even
str3:
	.ascii	"interface"
	.even
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
top0:		.ds.b	255			/*キューの先頭の番地*/
bottom0:	.ds.b	1			/*キューの末尾の番地*/
out0:		.ds.l	1			/*次に取り出すデータのある番地*/
in0:		.ds.l	1 			/*次にデータを入れるべき番地*/
s0:		.ds.l	1			/*キューに溜まっているデータの数*/

top1:		.ds.b	255			/*キューの先頭の番地*/
bottom1:	.ds.b	1			/*キューの末尾の番地*/
out1:		.ds.l	1			/*次に取り出すデータのある番地*/
in1:		.ds.l	1 			/*次にデータを入れるべき番地*/
s1:		.ds.l	1			/*キューに溜まっているデータの数*/

top2:		.ds.b	255			/*キューの先頭の番地*/
bottom2:	.ds.b	1			/*キューの末尾の番地*/
out2:		.ds.l	1			/*次に取り出すデータのある番地*/
in2:		.ds.l	1 			/*次にデータを入れるべき番地*/
s2:		.ds.l	1			/*キューに溜まっているデータの数*/

temp_top:	.ds.b	255			/*キューの先頭の番地*/
temp_bottom:	.ds.b	1			/*キューの末尾の番地*/
temp_out:	.ds.l	1			/*次に取り出すデータのある番地*/
temp_in:	.ds.l	1 			/*次にデータを入れるべき番地*/
temp_s:		.ds.l	1			/*キューに溜まっているデータの数*/
****************************************************************
*** 初期値の無いデータ領域
****************************************************************
BUF:
.ds.b 256 | BUF[256]
.even
USR_STK:
.ds.b 0x4000 | ユーザスタック領域
.even
USR_STK_TOP: | ユーザスタック領域の最後尾

chosen_level:	.ds.b 1 | レベル格納用変数
question_type:	.ds.b 1 | ループの種類を見分ける変数
loop_counter:	.ds.w 1 | 空ループ用変数
enabled_check_mode: 	.ds.b 1 | INTERGETで文字列チェックを行うかどうかのフラグ変数
is_gameover:	.ds.b 1 | ゲームオーバーかどうかのフラグ変数
.even
***************************************************************
** 初期化
** 内部デバイスレジスタには特定の値が設定されている．
** その理由を知るには，付録 B にある各レジスタの仕様を参照すること．
***************************************************************
.section .text
.even
boot: * スーパーバイザ & 各種設定を行っている最中の割込禁止
	move.w	#0x2700,%SR
	lea.l	SYS_STK_TOP, %SP 			| Set SSP

****************
** 割り込みコントローラの初期化
****************
	move.b	#0x40, IVR | ユーザ割り込みベクタ番号を0x40+level に設定．
	move.l	#SYSCALL_INTERFACE, 0x080 | システムコールを設定
	move.l	#HardwareInterface ,0x110| 送受信割込みを設定
	move.l	#TimerInterface, 0x118 | タイマ割り込みの設定
	move.l	#Mask_None,IMR | All Mask

****************
** 送受信 (UART1) 関係の初期化 (割り込みレベルは 4 に固定されている)
****************
	move.w	#U_Reset, USTCNT1 | リセット
	move.w	#U_Putpull, USTCNT1 |受信割り込みのみ許可
	move.w	#0x0038, UBAUD1 | baud rate = 230400 bps

*****************
** キュー初期化
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

****************
** ループ変数の初期化
*****************
	move.w	#0x5ff,loop_counter

****************
** フラグ変数の初期化
*****************
	move.b	#0,chosen_level
	move.b	#0,question_type
	move.b	#1,enabled_check_mode		
	move.b	#0,is_gameover

	bra	MAIN

*****************
** ループ
*****************
MAIN:
** ここからいじる
	move.w	#0x2000,%SR | 割り込み許可．(スーパーバイザモードの場合)
	move.l	#Mask_UART1_Timer,IMR | All UnMask
	move.w	#U_Put_Interupt, USTCNT1 |受信割り込みのみ許可
	move.w	#0x0000, %SR | USER MODE, LEVEL 0
	lea.l	USR_STK_TOP,%SP | user stack の設定

** システムコールによる RESET_TIMER の起動
	move.l	#SYSCALL_NUM_RESET_TIMER,%D0
	trap	#0

	move.l	#SYSCALL_NUM_PUTSTRING, %d0 | "********** Q2 **********"の出力
	move.l	#0, %d1
	move.l	#q2_msg, %d2
	move.l	#26, %d3
	trap	#0
		
**  タイピングする文字列をQueue2に格納
	move.l	#SYSCALL_NUM_PUT_TYPING_STRING, %d0
	move.l	#0, %d1
	move.l	#str1, %d2
	move.l	#3, %d3
	trap	#0

** レベル選択
** システムコールによる SET_TIMER の起動
	move.l	#SYSCALL_NUM_SET_TIMER, %d0 | システムコールによるSET_TIMERの起動
	move.w	#50000, %d1 | 回答時間を５秒に設定
	move.l	#JUDGE_LEVEL, %d2
	trap	#0

	move.l	#SYSCALL_NUM_PUTSTRING, %d0 | "Select typing level: "の出力
	move.l	#0, %d1
	move.l	#level_msg, %d2
	move.l	#26, %d3
	trap	#0
	bra	JUDGE_QUESTION

******************************
* 問題の条件分岐
******************************
JUDGE_QUESTION:
	cmp.b	#0,question_type | question_typeが0ならば空ループ
	beq	JUDGE_QUESTION
	cmp.b	#1,question_type | question_typeが1ならば問題1へ
	beq	FIRST_QUESTION

******************************
* タイマ(レベル選択用)
******************************
JUDGE_LEVEL:
	move.l	#SYSCALL_NUM_GETSTRING,%d0 | levelとして1文字だけ受け取る
	move.l	#0,%d1
	move.l	#BUF,%d2
	move.l	#1,%d3
	trap	#0

	move.l	#BUF, %a0
	move.l	#level1, %a1
	move.b	(%a0), %d6
	move.b	(%a1), %d7
	cmp.b	%d6, %d7 | 入力が1かどうか
	beq	SET_LEVEL1
	move.l	#level2, %a1
	move.b	(%a1), %d7
	cmp.b	%d6, %d7 | 入力が2かどうか
	beq	SET_LEVEL2
	move.l	#level3, %a1
	move.b	(%a1), %d7
	cmp.b	%d6, %d7 | 入力が3かどうか
	beq	SET_LEVEL3
	bra	SET_LEVEL1 | それ以外はレベル1に設定

SET_LEVEL1:
	move.l	#SYSCALL_NUM_PUTSTRING, %d0 | "level 1"の出力
	move.l	#0, %d1
	move.l	#level1_msg, %d2
	move.l	#9, %d3
	trap	#0
	move.b	#1,chosen_level | レベルを1に設定
	bra	END_JUDGE_LEVEL	
SET_LEVEL2:
	move.l	#SYSCALL_NUM_PUTSTRING, %d0 | "level 2"の出力
	move.l	#0, %d1
	move.l	#level2_msg, %d2
	move.l	#9, %d3
	trap	#0
	move.b	#2,chosen_level | レベルを2に設定
	bra	END_JUDGE_LEVEL	
SET_LEVEL3:
	move.l	#SYSCALL_NUM_PUTSTRING, %d0 | "level 3"の出力
	move.l	#0, %d1
	move.l	#level3_msg, %d2
	move.l	#9, %d3
	trap	#0
	move.b	#1,chosen_level | レベルを3に設定
	bra	END_JUDGE_LEVEL	

END_JUDGE_LEVEL:
** システムコールによる RESET_TIMER の起動
	move.l	#SYSCALL_NUM_RESET_TIMER, %d0
	trap	#0
	move.b	#1,question_type | 問題1に進むようにする
	rts

******************************
* Q1
******************************
FIRST_QUESTION:
** レベルを選択
	cmp.w	#1, chosen_level
	beq	FIRST_QUESTION_LEVEL1
	cmp.w	#2, chosen_level
	beq	FIRST_QUESTION_LEVEL2
	cmp.w	#3, chosen_level
	beq	FIRST_QUESTION_LEVEL3

FIRST_QUESTION_LEVEL1:
	move.w	#40000, %d1 | level1回答時間は4秒
	bra	PUT_FIRST_QUESTION

FIRST_QUESTION_LEVEL2:
	move.w	#30000, %d1 | level1回答時間は3秒
	bra	PUT_FIRST_QUESTION

FIRST_QUESTION_LEVEL3:
	move.w	#20000, %d1 | level1回答時間は2秒
	bra	PUT_FIRST_QUESTION

PUT_FIRST_QUESTION:	
** システムコールによるSET_TIMERの起動
	move.l	#SYSCALL_NUM_SET_TIMER, %d0
	move.l	#TIMEUP, %d2
	trap	#0

	move.l	#SYSCALL_NUM_PUTSTRING, %d0 | "********** Q1 **********"の出力
	move.l	#0, %d1
	move.l	#q1_msg, %d2
	move.l	#26, %d3
	trap	#0

** タイピングする文字列の出力
	move.l	#SYSCALL_NUM_PUTSTRING, %d0
	move.l	#0, %d1
	move.l	#str1, %d2
	move.l	#3, %d3
	trap	#0
	jsr	put_newline

**  タイピングする文字列をQueue2に格納
	move.l	#SYSCALL_NUM_PUT_TYPING_STRING, %d0
	move.l	#0, %d1
	move.l	#str1, %d2
	move.l	#3, %d3
	trap	#0

	move.b	#12,question_type | Q1-Q2のフラグ
	move.b	#1,enabled_check_mode | INTERGETで文字列チェック
	bra	ECHOBACK_LOOP

put_newline:
	move.l	#SYSCALL_NUM_PUTSTRING, %d0
	move.l	#0, %d1
	move.l	#newline, %d2
	move.l	#2, %d3
	trap	#0
	rts

TIMEUP:
	movem.l	%D0-%D7/%A0-%A6,-(%SP)
	move.b	#1,is_gameover
	movem.l	(%SP)+,%D0-%D7/%A0-%A6
	rts

******************************
* Q2
******************************
SECOND_QUESTION:
** システムコールによる RESET_TIMER の起動
	move.l	#SYSCALL_NUM_RESET_TIMER, %d0
	trap	#0

** レベルを選択
	cmp.w	#1, chosen_level
	beq	SECOND_QUESTION_LEVEL1
	cmp.w	#2, chosen_level
	beq	SECOND_QUESTION_LEVEL2
	cmp.w	#3, chosen_level
	beq	SECOND_QUESTION_LEVEL3

SECOND_QUESTION_LEVEL1:
	move.w	#40000, %d1 | level1回答時間は4秒
	bra	PUT_SECOND_QUESTION

SECOND_QUESTION_LEVEL2:
	move.w	#30000, %d1 | level1回答時間は3秒
	bra	PUT_SECOND_QUESTION

SECOND_QUESTION_LEVEL3:
	move.w	#20000, %d1 | level1回答時間は2秒
	bra	PUT_SECOND_QUESTION

PUT_SECOND_QUESTION:	
** システムコールによるSET_TIMERの起動
	move.l	#SYSCALL_NUM_SET_TIMER, %d0
	move.l	#TIMEUP, %d2
	trap	#0

	move.l	#SYSCALL_NUM_PUTSTRING, %d0 | "********** Q2 **********"の出力
	move.l	#0, %d1
	move.l	#q2_msg, %d2
	move.l	#26, %d3
	trap	#0

**  タイピングする文字列をQueue2に格納
	move.l	#SYSCALL_NUM_PUT_TYPING_STRING, %d0
	move.l	#0, %d1
	move.l	#str2, %d2
	move.l	#6, %d3
	trap	#0

** タイピングする文字列の出力
	move.l	#SYSCALL_NUM_PUTSTRING, %d0
	move.l	#0, %d1
	move.l	#str2, %d2
	move.l	#6, %d3
	trap	#0
	jsr	put_newline

	move.b	#23,question_type | Q2-Q3のフラグ
	move.b	#1,enabled_check_mode | INTERGETで文字列チェック
	bra	ECHOBACK_LOOP

******************************
* Q3
******************************
THIRD_QUESTION:
** システムコールによる RESET_TIMER の起動
	move.l	#SYSCALL_NUM_RESET_TIMER, %d0
	trap	#0

** レベルを選択
	cmp.w	#1, chosen_level
	beq	THIRD_QUESTION_LEVEL1
	cmp.w	#2, chosen_level
	beq	THIRD_QUESTION_LEVEL2
	cmp.w	#3, chosen_level
	beq	THIRD_QUESTION_LEVEL3

THIRD_QUESTION_LEVEL1:
	move.w	#40000, %d1 | level1回答時間は4秒
	bra	PUT_THIRD_QUESTION

THIRD_QUESTION_LEVEL2:
	move.w	#30000, %d1 | level1回答時間は3秒
	bra	PUT_THIRD_QUESTION

THIRD_QUESTION_LEVEL3:
	move.w	#20000, %d1 | level1回答時間は2秒
	bra	PUT_THIRD_QUESTION

PUT_THIRD_QUESTION:	
** システムコールによるSET_TIMERの起動
	move.l	#SYSCALL_NUM_SET_TIMER, %d0
	move.l	#TIMEUP, %d2
	trap	#0

	move.l	#SYSCALL_NUM_PUTSTRING, %d0 | "********** Q2 **********"の出力
	move.l	#0, %d1
	move.l	#q3_msg, %d2
	move.l	#26, %d3
	trap	#0

**  タイピングする文字列をQueue2に格納
	move.l	#SYSCALL_NUM_PUT_TYPING_STRING, %d0
	move.l	#0, %d1
	move.l	#str3, %d2
	move.l	#9, %d3
	trap	#0

** タイピングする文字列の出力
	move.l	#SYSCALL_NUM_PUTSTRING, %d0
	move.l	#0, %d1
	move.l	#str3, %d2
	move.l	#9, %d3
	trap	#0
	jsr	put_newline

	move.b	#34,question_type | Q3終了フラグ
	move.b	#1,enabled_check_mode | INTERGETで文字列チェック
	bra	ECHOBACK_LOOP

******************************
* エコーバックループ 
******************************
ECHOBACK_LOOP:
** 空ループ
	sub.w	#1, loop_counter
	bne	ECHOBACK_LOOP
	move.w	#0x5ff, loop_counter

** エコーバック
	move.l	#SYSCALL_NUM_GETSTRING, %D0
	move.l	#0, %D1 | ch = 0
	move.l	#BUF, %D2 | p = #BUF
	move.l	#256, %D3 | size = 256
	trap	#0
	move.l	%D0, %D3 | size = %D0 (length of given string)
	move.l	#SYSCALL_NUM_PUTSTRING, %D0
	move.l	#0, %D1 | ch = 0
	move.l	#BUF,%D2 | p = #BUF
	trap	#0
	cmp.b	#1,is_gameover
	beq	GAMEOVER
	cmp.l	#0,s2
	beq	PROCEED
	bra	ECHOBACK_LOOP

GAMEOVER:
	move.l	#SYSCALL_NUM_RESET_TIMER,%d0
	trap	#0

	move.l	#SYSCALL_NUM_PUTSTRING,%d0
	move.l	#0, %d1
	move.l	#gameover_msg, %d2
	move.l	#13, %d3
	trap	#0

	move.b	#'g',LED7
	move.b	#'a',LED6
	move.b	#'m',LED5
	move.b	#'e',LED4
	move.b	#'o',LED3
	move.b	#'v',LED2
	move.b	#'e',LED1
	move.b	#'r',LED0
	bra	END

PROCEED:
	cmp.b	#12,question_type | Q1-Q2の間の場合
	beq	SECOND_QUESTION
	cmp.b	#23,question_type | Q2-Q3の間の場合
	beq	THIRD_QUESTION
	bra	SUCCESS

SUCCESS:
	move.l	#SYSCALL_NUM_RESET_TIMER,%d0
	trap	#0

	move.l	#SYSCALL_NUM_PUTSTRING,%d0
	move.l	#0, %d1
	move.l	#gameclear_msg, %d2
	move.l	#14, %d3
	trap	#0

	| move.b	#'s',LED7
	| move.b	#'u',LED6
	| move.b	#'c',LED5
	| move.b	#'c',LED4
	| move.b	#'e',LED3
	| move.b	#'s',LED2
	| move.b	#'s',LED1
	| move.b	#'!',LED0
	bra	END

END:
| TODO: continue_msgが表示されない
	move.l	#SYSCALL_NUM_PUTSTRING, %D0
	move.l	#0, %D1
	move.l	#continue_msg,%D2
	move.l	#35, %d3
	trap	#0

	move.w	#0,enabled_check_mode | INTERGETでチェックが起きないようにする
	bra	END_LOOP

END_LOOP:
** 空ループ
	sub.w	#1, loop_counter
	bne	END_LOOP

** ENTERの受け付け
	move.w	#0x5ff, loop_counter
	move.l	#SYSCALL_NUM_GETSTRING, %d0 | Please Enter if you wanna continue
	move.l	#0, %d1
	move.l	#BUF, %d2
	move.l	#1, %d3
	trap	#0
| TODO: enterが認識されない
	cmp.l	#0xd, BUF
	beq	boot
	bra	END_LOOP

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
	cmp.l   #2,%d0
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
	cmp.l	#2,%d0
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
 
***************************************************
**INTERGET(ch,data)　受信データを受信キューに格納する
**入力：ch->%d1.l data->%d2.b
***************************************************
INTERGET:
	move.w 	%sr,-(%sp)	/*srの値を一時退避*/
	move.w 	#0x2700,%sr	/*割り込み禁止(走行レベル7)*/
	cmp.l 	#0,%d1
	bne	INTERGET_END	/*chが0でないなら何もせずに復帰*/
	cmp.b	#1,enabled_check_mode | フラグ変数が1ならばチェックモード移行
	beq	INTERGET_CHECK_MODE
	jmp	INTERGET_INQ

INTERGET_CHECK_MODE:
	cmp.l	#0,s2
	beq	INTERGET_END | タイピングする文字列がなければそのまま復帰

	move.b	top2,temp_top | キューをコピー
	move.b	bottom2,temp_bottom
	move.l	out2,temp_out
	move.l	in2,temp_in
	move.l	s2,temp_s
	move.l	#2,%d0 | キュー2を選択
	jsr	OUTQ | d0.l -> 0(fail) || 1(success), d1.b -> data
	cmp.l	#0,%d0
	beq	INTERGET_FAIL
	move.b	#'n',LED7 | TODO: debug
	cmp.b	%d1,%d2 | 入力とタイピング文字が同じかどうか
	bne	INTERGET_FAIL
	move.b	#'y',LED7 | TODO: debug
	jmp	INTERGET_INQ

INTERGET_INQ:
    	move.l	#0,%d0          /* キュー0を選択 */
	jsr	INQ		/*INQ(no->%d0.l,data->%d1.b) %D0.lで結果を報告*/
	jmp	INTERGET_END

INTERGET_FAIL:
	move.b	temp_top,top2
	move.b	temp_bottom,bottom2
	move.l	temp_out,out2
	move.l	temp_in,in2
	move.l	temp_s,s2
	jmp	INTERGET_END

	jmp	INTERGET_END

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
    	move.l	#1, %d0          /* キュー1を選択 */
	jsr	OUTQ		        /*data->%D1.b  %D0に結果を格納*/
	cmp.l	#0,%d0
	beq	INTERPUT_fail
	add.w	#0x0800,%d1
	move.w	%d1,UTX1	/*符号拡張してdataをUTX1に格納*/
	jmp 	INTERPUT_END
INTERPUT_fail:
	move.w	#U_Put_Interupt,USTCNT1	/*OUTQが失敗なら送信割り込み禁止にして復帰*/
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	rts
INTERPUT_END:
	move.w  (%sp)+, %sr			/*スーパースタックから走行レベル回復*/
	rts

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
** PUT_TYPING_STRING(ch, p, size)
**chのタイプ用入力キューにp番地から始まるsizeバイトのデータを格納
**入力： ch->%d1.l  p->%d2.l  size->%d3.l
**戻り値：実際に送信したデータ数 sz->d0.l
******************************************************************************
PUT_TYPING_STRING:
	movem.l	%a0/%d4,-(%sp)
	move.w 	%sr,-(%sp)			/*走行レベル退避*/
	move.w 	#0x2700,%sr			/*割り込み禁止(走行レベル7)*/
	
	cmp.l	#0,%d1
	bne	PUT_TYPING_STRING_END 	/*ch≠0なら何もせず復帰*/

	move.l	#0,%d4		/*sz->%d4*/
	movea.l %d2,%a0 	/*i->a0*/ 
	
	cmp.l	#0,%d3
	beq	PUT_TYPING_STRING_COUNT /*size=0なら分岐*/
	
PUT_TYPING_STRING_LOOP:
	cmp.l	%d4,%d3
	beq	PUT_TYPING_STRING_COUNT /*sz=sizeなら分岐*/

	move.l	#2,%d0
	move.b 	(%a0)+,%d1
	jsr	INQ 		/*INQ(no->d0.l,data->d1.b)*/

	cmp.l	#0,%d0
	beq	PUT_TYPING_STRING_COUNT /*INQが失敗なら分岐*/

	addq.l	#1,%d4		/*sz++*/
	bra	PUT_TYPING_STRING_LOOP 
	
PUT_TYPING_STRING_COUNT:
	move.l %d4,%d0

PUT_TYPING_STRING_END:
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
SET_TIMER:
	movem.l	%a0/%d1,-(%sp)
	lea.l   task_p, %a0
	move.l  %d2, (%a0) |task_p=入力d2
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
	cmp.w #0x2000,%d3 /* URX1の13bit目が1の場合INTERGET呼び出し */
	beq INTERGET_PREPARE
	move.w UTX1,%d1
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
	lea.l   task_p, %a0
	movea.l (%a0), %a1 |a1=task_p
	jsr     (%a1) |task_pへジャンプ
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
	
	cmp.l	#5,%d0
	beq	CALL_PUT_TYPING_STRING

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

CALL_PUT_TYPING_STRING:
	jsr PUT_TYPING_STRING
	rte
.end
