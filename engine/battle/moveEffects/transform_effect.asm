TransformEffect_: ; 3bab1 (e:7ab1)
	ld hl, wBattleMonSpecies
	ld de, wEnemyMonSpecies
	ld bc, W_ENEMYBATTSTATUS3
	ld a, [H_WHOSETURN]
	and a
	ld a, [W_ENEMYBATTSTATUS1]
	jr nz, .hitTest ;Bug fix? Invulerable now blocks transform.
	ld hl, wEnemyMonSpecies
	ld de, wBattleMonSpecies
	ld bc, W_PLAYERBATTSTATUS3
	ld [wPlayerMoveListIndex], a
	ld a, [W_PLAYERBATTSTATUS1]
.hitTest
;TODO: DITTO cannot TRANSFORM into DITTO, he is already DITTO.
	bit Invulnerable, a ; is mon invulnerable to typical attacks? (fly/dig)
	jp nz, .failed
	push bc
	ld a, [hl]
	ld b, a
	ld a, [de]
	cp b
	pop bc
	jp z, .failed ;Don't transform if you are already the thing you are transforming into.
	push hl
	push de
	push bc
	ld hl, W_PLAYERBATTSTATUS2
	ld a, [H_WHOSETURN]
	and a
	jr z, .transformEffect
	ld hl, W_ENEMYBATTSTATUS2
.transformEffect
; animation(s) played are different if target has Substitute up
	bit HasSubstituteUp, [hl] 
	push af
	ld hl, Func_79747
	ld b, BANK(Func_79747)
	call nz, Bankswitch
	ld a, [W_OPTIONS]
	add a
	ld hl, PlayCurrentMoveAnimation
	ld b, BANK(PlayCurrentMoveAnimation)
	jr nc, .gotAnimToPlay
	ld hl, AnimationTransformMon
	ld b, BANK(AnimationTransformMon)
.gotAnimToPlay
	call Bankswitch
	ld hl, Func_79771
	ld b, BANK(Func_79771)
	pop af
	call nz, Bankswitch
	pop bc
	ld a, [bc]
	bit Transformed, a
	set Transformed, a ; mon is now Transformed
	ld [bc], a
	jr z, .copyData
	ld a, [H_WHOSETURN]
	and a
	jr z, .copyData
	;if we are here, our DVs are already in wcceb/wccec
	;make a note to skip copying them.
	ld a, 2
	ld [H_WHOSETURN], a
.copyData
	pop de
	pop hl
	push hl
; transform user into opposing Pokemon	
; species
	ld a, [hl] 
	ld [de], a
; type 1, type 2, catch rate, and moves	
	ld bc, $5
	add hl, bc 
	inc de
	inc de
	inc de
	inc de
	inc de
	inc bc
	inc bc
	call CopyData
	ld a, [H_WHOSETURN]
	cp 0
	jr z, .next
	cp 1
	jr z, .storeDVs
	ld a, 1 ;Set WHOSETURN back to its sane value
	ld [H_WHOSETURN], a
	jr .next ;we were already transformed, so don't store DVs
.storeDVs	
; save enemy mon DVs in wcceb/wccec (enemy turn only)
	ld a, [de]
	ld [wcceb], a
	inc de
	ld a, [de]
	ld [wccec], a
	dec de
.next
; DVs
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
; Attack, Defense, Speed, and Special stats	
	inc hl
	inc hl
	inc hl
	inc de
	inc de
	inc de
	ld bc, $8
	call CopyData
	ld bc, wBattleMonMoves - wBattleMonPP 
	add hl, bc ; ld hl, wBattleMonMoves
	ld b, NUM_MOVES
.copyPPLoop
; 5 PP for all moves
	ld a, [hli]
	and a
	jr z, .lessThanFourMoves
	ld a, $5
	ld [de], a
	inc de
	dec b
	jr nz, .copyPPLoop
	jr .copyStats
.lessThanFourMoves
; 0 PP for blank moves
	xor a
	ld [de], a
	inc de
	dec b
	jr nz, .lessThanFourMoves
.copyStats
; original (unmodified) stats and stat mods
	pop hl
	ld a, [hl]
	ld [wd11e], a
	call GetMonName
	ld hl, wEnemyMonUnmodifiedAttack
	ld de, wPlayerMonUnmodifiedAttack
	call .copyBasedOnTurn ; original (unmodified) stats
	ld hl, wEnemyMonStatMods
	ld de, wPlayerMonStatMods
	call .copyBasedOnTurn ; stat mods
	ld hl, TransformedText
	jp PrintText

.copyBasedOnTurn
	ld a, [H_WHOSETURN]
	and a
	jr z, .gotStatsOrModsToCopy
	push hl
	ld h, d
	ld l, e
	pop de
.gotStatsOrModsToCopy
	ld bc, $8
	jp CopyData

.failed
	ld c, 50
	call DelayFrames
	ld hl, PrintButItFailedText_
	jp BankswitchEtoF

TransformedText: ; 3bb92 (e:7b92)
	TX_FAR _TransformedText
	db "@"
