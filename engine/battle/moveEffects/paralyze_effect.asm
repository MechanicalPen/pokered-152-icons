ParalyzeEffect_: ; 52601 (14:6601)
	ld hl, wEnemyMonStatus
	ld de, W_PLAYERMOVETYPE
	ld a, [H_WHOSETURN]
	and a
	jp z, .next
	ld hl, wBattleMonStatus 
	ld de, W_ENEMYMOVETYPE
.next
	push hl ;check subsitute.
	ld hl, W_ENEMYBATTSTATUS2
	ld a, [H_WHOSETURN]   
	and a
	jr z, .checkSub
	ld hl, W_PLAYERBATTSTATUS2
.checkSub
	bit HasSubstituteUp, [hl]         
	pop hl
	jr nz, .moveFailed ; can't paralyze a substitute target
	ld a, [hl]
	and a ; does the target already have a status ailment?
	jr nz, .moveFailed
; check if the target is immune due to types
	ld a, [de]
	cp ELECTRIC
	jr nz, .hitTest
	ld b, h
	ld c, l
	inc bc
	ld a, [bc]
	cp GROUND
	jr z, .doesntAffect
	inc bc
	ld a, [bc]
	cp GROUND
	jr z, .doesntAffect
.hitTest
	push hl
	callab MoveHitTest
	pop hl
	ld a, [W_MOVEMISSED] 
	and a
	jr nz, .didntAffect
	set PAR, [hl]
	callab QuarterSpeedDueToParalysis
	ld c, 30
	call DelayFrames
	callab PlayCurrentMoveAnimation
	ld hl, PrintMayNotAttackText
	ld b, BANK(PrintMayNotAttackText)
	jp Bankswitch
.didntAffect
	ld c, 50
	call DelayFrames
	ld hl, PrintResistedItText
	ld b, BANK(PrintResistedItText)
	jp Bankswitch
.doesntAffect
	ld c, 50
	call DelayFrames
	ld hl, PrintDoesntAffectText
	ld b, BANK(PrintDoesntAffectText)
	jp Bankswitch
.moveFailed
	ld c, 50
	call DelayFrames
	ld hl, ParalyzeFailedText ; $7ef7
	jp PrintText
	
ParalyzeFailedText:
	TX_FAR _ButItFailedText
	db "@"
