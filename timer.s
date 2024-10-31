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
task_p: .ds.l	1
.even
SYS_STK:.ds.b 0x4000 | システムスタック領域
.even
SYS_STK_TOP: | システムスタック領域の最後尾
***************************************************************
** 初期化
** 内部デバイスレジスタには特定の値が設定されている．
** その理由を知るには，付録 B にある各レジスタの仕様を参照すること．
***************************************************************
.section .text
.even
boot: | スーパーバイザ & 各種設定を行っている最中の割込禁止
move.w #0x2700,%SR
lea.l SYS_STK_TOP, %SP 			| Set SSP

****************
** 割り込みコントローラの初期化
****************
move.b #0x40, IVR 				| ユーザ割り込みベクタ番号を0x40+level に設定．
** move.l #HardwareInterface, 0x110| 送受信割込みを設定
move.l #TimerInterface, 0x118 | タイマ割り込みの設定
move.l #Mask_UART1_Timer,IMR 			| All Mask

** タイマ関係の初期化 (割り込みレベルは 6 に固定されている)
** RESET_TIMER()  TCTL1を設定
** 入力、戻り値なし
******************
move.w #0x0004, TCTL1 | restart, 割り込み不可,
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
	lea.l   task_p, %a0
	move.l  %d2, (%a0) |task_p=入力d2 /* TODO: Step7時点ではd2に何も入ってない */
	move.w  #0xce, TPRER1 |1カウント0.1msecに設定
	move.w  #0xc350, %d1 /* TODO: タイマ間隔のテスト値。修正予定。*/
	move.w  %d1, TCMP1 |割り込み発生周期を設定
	move.w  #0x15, TCTL1 |タイマ使用許可

MAIN:
	move.w #0x2000,%SR /* 割り込み許可．(スーパーバイザモードの場合) */
LOOP:
	bra LOOP

TimerInterface:
	movem.l %a0-%a7/%d1-%d7, -(%sp)
	move.b #'2', LED6
	btst.b  #0, TSTAT1+1 |コンペアイベント発生チェック
	beq     return |発生無しで復帰
	move.b #'4', LED4
	move.w  #0x0000, TSTAT1 |ステータスレジスタのクリア
	jsr     CALL_RP
	movem.l (%sp)+,%a0-%a7/%d1-%d7 
	rte
return:
	move.b #'3', LED5
    	movem.l (%sp)+,%a0-%a7/%d1-%d7 
	rte

******************
** CALL_RP()
** 入力、戻り値なし
******************
CALL_RP:
	lea.l   task_p, %a0
	movea.l (%a0), %a1 |a1=task_p
	** jsr     (%a1) |task_pへジャンプ
	move.b #'1', LED7
	rts

.end
