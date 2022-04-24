HealEffect_: ; 3b9ec (e:79ec)  ;(e:7d0c)
	ld a, [H_WHOSETURN]
	and a
	ld de, wBattleMonHP
	ld hl, wBattleMonMaxHP
	ld a, [W_PLAYERMOVENUM]
	jr z, .healEffect
	ld de, wEnemyMonHP
	ld hl, wEnemyMonMaxHP
	ld a, [W_ENEMYMOVENUM]
.healEffect
	ld b, a
	push hl
	push de
	push bc
	ld c, 2
	call StringCmp ;TODO test.
	pop bc
	pop de
	pop hl
	jp z, .failed ; no effect if user's HP is already at its maximum
	ld a, [de]
	inc de
	inc hl
	ld a, [de]
	sbc [hl]
	ld a, b
	cp REST
	jr nz, .healHP
	push hl
	push de
	push af
	ld c, 50
	call DelayFrames
	ld hl, wBattleMonStatus
	;ld de, W_PLAYERBATTSTATUS3
	ld a, [H_WHOSETURN]
	and a
	jr z, .restEffect
	ld hl, wEnemyMonStatus
	;ld de, W_PLAYERBATTSTATUS3
.restEffect
	push hl
	;; because fuck you that's why
	;push de
	;pop hl ;these two lines the same as 'ld hl, de' but restrictions make us do it this way
	;res BadlyPoisoned, [hl] ; heal toxic (Toxic is autohealed now that it is in status)
	ld a, [H_WHOSETURN]
	ld [wd11e], a
	callab CalculateModifiedStats ;no need for burn paralyze check because those are impossible.
	pop hl
	ld a, [hl]
	and a
	ld [hl], 2 ; clear status and set number of turns asleep to 2
	ld hl, StartedSleepingEffect ; if mon didn't have an status
	jr z, .printRestText
	ld hl, FellAsleepBecameHealthyText ; if mon had an status
.printRestText
	call PrintText
	pop af
	pop de
	pop hl
.healHP
	ld a, [hld]
	ld [wHPBarMaxHP], a
	ld c, a
	ld a, [hl]
	ld [wHPBarMaxHP+1], a
	ld b, a
	jr z, .gotHPAmountToHeal
; Recover and Softboiled only heal for half the mon's max HP
	srl b
	rr c
.gotHPAmountToHeal
; update HP
	ld a, [de]
	ld [wHPBarOldHP], a
	add c
	ld [de], a
	ld [wHPBarNewHP], a
	dec de
	ld a, [de]
	ld [wHPBarOldHP+1], a
	adc b
	ld [de], a
	ld [wHPBarNewHP+1], a
	inc hl
	inc de
	ld a, [de]
	dec de
	sub [hl]
	dec hl
	ld a, [de]
	sbc [hl]
	jr c, .playAnim
; copy max HP to current HP if an overflow ocurred	
	ld a, [hli]
	ld [de], a
	ld [wHPBarNewHP+1], a
	inc de
	ld a, [hl]
	ld [de], a
	ld [wHPBarNewHP], a
.playAnim
	ld hl, PlayCurrentMoveAnimation
	call BankswitchEtoF
	ld a, [H_WHOSETURN]
	and a
	hlCoord 10, 9
	ld a, $1
	jr z, .updateHPBar
	hlCoord 2, 2
	xor a
.updateHPBar
	ld [wHPBarType], a
	predef UpdateHPBar2
	ld hl, DrawHUDsAndHPBars
	call BankswitchEtoF
	ld hl, RegainedHealthText
	jp PrintText
.failed
	ld c, 50
	call DelayFrames
	ld hl, PrintButItFailedText_
	jp BankswitchEtoF

StartedSleepingEffect: ; 3baa2 (e:7aa2)
	TX_FAR _StartedSleepingEffect
	db "@"

FellAsleepBecameHealthyText: ; 3baa7 (e:7aa7)
	TX_FAR _FellAsleepBecameHealthyText
	db "@"

RegainedHealthText: ; 3baac (e:7aac)
	TX_FAR _RegainedHealthText
	db "@"
