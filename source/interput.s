/* INTERPUT(ch)　チャンネルchの送信キューからデータを一つ取り出し実際に送信する（UTX1に書き込む）
入力：ch->%D1.l */
INTERPUT:
	move.w	#0x2700,%SR 	/*割り込み禁止（走行レベルを７に設定）*/
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

INTERPUT_END:	rts

