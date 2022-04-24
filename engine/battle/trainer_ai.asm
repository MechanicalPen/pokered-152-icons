; creates a set of moves that may be used and returns its address in hl
; unused slots are filled with 0, all used slots may be chosen with equal probability
AIEnemyTrainerChooseMoves: ; 39719 (e:5719)
	ld a, $a
	ld hl, wBuffer  ; init temporary move selection array. Only the moves with the lowest numbers are chosen in the end
	ld [hli], a   ; move 1
	ld [hli], a   ; move 2
	ld [hli], a   ; move 3
	ld [hl], a    ; move 4
	ld a, [W_ENEMYDISABLEDMOVE] ; forbid disabled move (if any)
	swap a
	and $f
	jr z, .noMoveDisabled
	ld hl, wBuffer
	dec a
	ld c, a
	ld b, $0
	add hl, bc    ; advance pointer to forbidden move
	ld [hl], $50  ; forbid (highly discourage) disabled move
.noMoveDisabled
	ld hl, TrainerClassMoveChoiceModifications ; 589B
	ld a, [W_TRAINERCLASS]
	ld b, a
.loopTrainerClasses
	dec b
	jr z, .readTrainerClassData
.loopTrainerClassData
	ld a, [hli]
	and a
	jr nz, .loopTrainerClassData
	jr .loopTrainerClasses
.readTrainerClassData
	ld a, [hl]
	and a
	jp z, .useOriginalMoveSet
	push hl
.nextMoveChoiceModification
	pop hl
	ld a, [hli]
	and a
	jr z, .loopFindMinimumEntries
	push hl
	ld hl, AIMoveChoiceModificationFunctionPointers ; $57a3
	dec a
	add a
	ld c, a
	ld b, $0
	add hl, bc    ; skip to pointer
	ld a, [hli]   ; read pointer into hl
	ld h, [hl]
	ld l, a
	ld de, .nextMoveChoiceModification  ; set return address
	push de
	jp [hl]       ; execute modification function
.loopFindMinimumEntries ; all entries will be decremented sequentially until one of them is zero
	ld hl, wBuffer  ; temp move selection array
	ld de, wEnemyMonMoves  ; enemy moves
	ld c, $4
.loopDecrementEntries
	ld a, [de]
	inc de
	and a
	jr z, .loopFindMinimumEntries
	dec [hl]
	jr z, .minimumEntriesFound
	inc hl
	dec c
	jr z, .loopFindMinimumEntries
	jr .loopDecrementEntries
.minimumEntriesFound
	ld a, c
.loopUndoPartialIteration ; undo last (partial) loop iteration
	inc [hl]
	dec hl
	inc a
	cp $5
	jr nz, .loopUndoPartialIteration
	ld hl, wBuffer  ; temp move selection array
	ld de, wEnemyMonMoves  ; enemy moves
	ld c, $4
.filterMinimalEntries ; all minimal entries now have value 1. All other slots will be disabled (move set to 0)
	ld a, [de]
	and a
	jr nz, .moveExisting ; 0x3978a $1
	ld [hl], a
.moveExisting
	ld a, [hl]
	dec a
	jr z, .slotWithMinimalValue
	xor a
	ld [hli], a     ; disable move slot
	jr .next
.slotWithMinimalValue
	ld a, [de]
	ld [hli], a     ; enable move slot
.next
	inc de
	dec c
	jr nz, .filterMinimalEntries
	ld hl, wBuffer   ; use created temporary array as move set
	ret
.useOriginalMoveSet
	ld hl, wEnemyMonMoves    ; use original move set
	ret

AIMoveChoiceModificationFunctionPointers: ; 397ab (e:57ab)
	dw AIMoveChoiceModification1
	dw AIMoveChoiceModification2
	dw AIMoveChoiceModification3
	dw AIMoveChoiceModification4
	dw AIMoveChoiceModification5
	dw AIMoveChoiceModification6
; discourages moves that cause no damage but only a status ailment if player's mon already has one
; Don't use Focus Energy if focused. Don't stat up if full?
; Don't use disable if enemy disabled.
;Don't use Haze if not statused.
;just look at how pokecrystal does AI
AIMoveChoiceModification1: ; 397ab (e:57ab)
	ld hl, wBuffer - 1 ; temp move selection array (-1 byte offest)
	ld de, wEnemyMonMoves ; enemy moves
	ld b, NUM_MOVES + 1
.nextMove
	dec b
	ret z         ; processed all 4 moves
	inc hl
	ld a, [de]
	and a
	ret z         ; no more moves in move set
	inc de
	call ReadMove
	ld a, [W_ENEMYMOVEPOWER]
	and a
	ld a, [W_ENEMYMOVEEFFECT] ;preload move effect for dream eater check.
	;Dream Eater is the only move that A.) Has > 0 BP B.) Can fail.
	;So we can skip most of the checks if our BP is not 0.
	jp nz, .checkDreamEater
	push hl
	push de
	push bc
	ld hl, StatusAilmentMoveEffects
	ld de, $0001
	call IsInArray
	pop bc
	pop de
	pop hl
	jp c, .isStatused
.continueCheck
	ld a, [W_ENEMYMOVEEFFECT]
	push hl
	push de
	push bc
	ld hl, SubsituteBlockedMoveEffects
	ld de, $0001
	call IsInArray
	pop bc
	pop de
	pop hl
	jp c, .isProtected
.checkStaus3
	ld a, [W_ENEMYMOVEEFFECT]
	cp LIGHT_SCREEN_EFFECT
	jr nz, .checkReflect
	ld a,[W_ENEMYBATTSTATUS3]
	bit HasLightScreenUp, a
	jp nz, .discourageMove
	jp .nextMove
.checkReflect
	cp REFLECT_EFFECT
	jr nz, .checkPlayerSeeded
	ld a,[W_ENEMYBATTSTATUS3]
	bit HasReflectUp, a
	jp nz, .discourageMove
	jp .nextMove
.checkPlayerSeeded
	cp LEECH_SEED_EFFECT 
	jr nz, .checkSubstitute
	ld a,[W_PLAYERBATTSTATUS2]
	bit Seeded, a
	jp nz, .discourageMove
	jp .nextMove
.checkSubstitute
	cp SUBSTITUTE_EFFECT
	jr nz, .checkFocus
	ld a,[W_ENEMYBATTSTATUS2]
	bit HasSubstituteUp, a
	jp nz, .discourageMove
	push bc
	push de
	push hl
	ld a,$4
	call AICheckIfHPBelowFraction
	pop hl
	pop de
	pop bc
	jp c, .discourageMove
	jp .nextMove
.checkFocus
	cp FOCUS_ENERGY_EFFECT
	jr nz, .checkConfused
	ld a,[W_ENEMYBATTSTATUS2]
	bit GettingPumped, a
	jp nz, .discourageMove
	jp .nextMove
.checkConfused
	cp CONFUSION_EFFECT
	jr nz, .checkPoison
	ld a,[W_PLAYERBATTSTATUS1]
	bit Confused, a
	jp nz, .discourageMove
	jp .nextMove
.checkPoison
	cp POISON_EFFECT
	jr nz, .checkDisabled
	ld a,[wBattleMonType1]
	cp POISON ;can't poison poison types...
	jp z, .discourageMove
	ld a,[wBattleMonType2]
	cp POISON ;can't poison poison types...
	jp z, .discourageMove
	jp .nextMove
.checkDisabled
	cp DISABLE_EFFECT
	jr nz, .checkDreamEater
	ld a, [W_PLAYERDISABLEDMOVE]
	and a
	jp nz, .discourageMove
	jp .nextMove
.checkDreamEater
	cp DREAM_EATER_EFFECT
	jr nz, .checkHeal
	ld a, [wBattleMonStatus]
	and $7 ;Sleep bit.
	jp z, .discourageMove ;not sleeping
	jp .nextMove
.checkHeal
	cp HEAL_EFFECT
	jr nz, .checkStatUps
	push hl
	ld de, wEnemyMonHP
	ld hl, wEnemyMonMaxHP
	ld c, $2
	call StringCmp
	pop hl
	jp nz, .nextMove ;health is not full.
	push hl
	ld de, wEnemyMonSpeed
	ld hl, wBattleMonSpeed
	ld c, $2
	call StringCmp ; compare speed values
	pop hl
	jp c, .discourageMove ;move will fail; player is faster and we are full on health.
	jp .nextMove
.checkStatUps
	cp ATTACK_UP1_EFFECT
	jr z, .preventStatTooHigh    
	cp DEFENSE_UP1_EFFECT
	jr z, .preventStatTooHigh 
	cp SPEED_UP1_EFFECT
	jr z, .preventStatTooHigh
	cp SPECIAL_UP1_EFFECT
	jr z, .preventStatTooHigh
	cp ACCURACY_UP1_EFFECT
	jr z, .preventStatTooHigh 
	cp EVASION_UP1_EFFECT
	jr z, .preventStatTooHigh 
	cp ATTACK_UP2_EFFECT
	jr z, .preventStatTooHigh 	
	cp DEFENSE_UP2_EFFECT
	jr z, .preventStatTooHigh 
	cp SPEED_UP2_EFFECT
	jr z, .preventStatTooHigh
	cp SPECIAL_UP2_EFFECT
	jr z, .preventStatTooHigh 
	cp ACCURACY_UP2_EFFECT
	jr z, .preventStatTooHigh 
	cp EVASION_UP2_EFFECT
	jr nz, .checkStatDowns
.preventStatTooHigh
	push bc
	push de
	call AI_Dumb_StatUp
	pop de
	pop bc
	jp .nextMove
.checkStatDowns
	cp ATTACK_DOWN1_EFFECT
	jr z, .preventStatTooLow    
	cp DEFENSE_DOWN1_EFFECT
	jr z, .preventStatTooLow 
	cp SPEED_DOWN1_EFFECT
	jr z, .preventTooFastDown
	cp SPECIAL_DOWN1_EFFECT
	jr z, .preventStatTooLow
	cp ACCURACY_DOWN1_EFFECT
	jr z, .preventStatTooLow 
	cp EVASION_DOWN1_EFFECT
	jr z, .preventStatTooLow 
	cp ATTACK_DOWN2_EFFECT
	jr z, .preventStatTooLow 	
	cp DEFENSE_DOWN2_EFFECT
	jr z, .preventStatTooLow 
	cp SPEED_DOWN2_EFFECT
	jr z, .preventTooFastDown 
	cp SPECIAL_DOWN2_EFFECT
	jr z, .preventStatTooLow 
	cp ACCURACY_DOWN2_EFFECT
	jr z, .preventStatTooLow 
	cp EVASION_DOWN2_EFFECT
	jr nz, .checkTeleport 
.preventTooFastDown
	push bc
	push de
	push hl
	ld de, wEnemyMonSpeed
	ld hl, wBattleMonSpeed
	ld c, $2
	call StringCmp ; compare speed values
	pop hl
	pop de
	pop bc
	jp nc, .discourageMove ;Enemy is faster.
.preventStatTooLow
	push bc
	push de
	call AI_Dumb_StatDown
	pop de
	pop bc
	jp .nextMove
.checkTeleport
	cp SWITCH_AND_TELEPORT_EFFECT
	jr z, .discourageMove
	jp nz, .nextMove
.isStatused
	ld a, [wBattleMonStatus]
	and a
	jp z, .continueCheck
.discourageMove
	ld a, [hl]
	add $5       ; discourage move
	ld [hl], a
	jp .nextMove
.isProtected
	ld a,[W_PLAYERBATTSTATUS2]
	bit HasSubstituteUp, a
	jr nz, .discourageMove
	ld a,[W_PLAYERBATTSTATUS1]
	bit Invulnerable, a
	jr nz, .discourageMove
	jp .checkStaus3

SubsituteBlockedMoveEffects
	db ATTACK_DOWN1_EFFECT
	db DEFENSE_DOWN1_EFFECT
	db SPEED_DOWN1_EFFECT
	db SPECIAL_DOWN1_EFFECT
	db ACCURACY_DOWN1_EFFECT
	db EVASION_DOWN1_EFFECT
	db ATTACK_DOWN2_EFFECT
	db DEFENSE_DOWN2_EFFECT
	db SPEED_DOWN2_EFFECT
	db SPECIAL_DOWN2_EFFECT
	db ACCURACY_DOWN2_EFFECT
	db EVASION_DOWN2_EFFECT
	db CONFUSION_EFFECT
	;TODO Add drain moves if you end up fixing that bug.
StatusAilmentMoveEffects ; 57e2
	db $01 ; unused sleep effect
	db SLEEP_EFFECT
ZeroPowerImmunityMoveEffects ;A subset of StatusAilmentEffects
	db POISON_EFFECT
	db PARALYZE_EFFECT
	db $FF
; slightly encourage moves with specific effects
; Add SUBSTITUTE_EFFECT
;discourage teleport_effect
AIMoveChoiceModification2: ; ????? (e:????)
	ld a, [wAILayer2Encouragement]
	cp $2
	ret nc
	ld hl, wBuffer - 1 ; temp move selection array (-1 byte offset)
	ld de, wEnemyMonMoves ; enemy moves
	ld b, NUM_MOVES + 1
.nextMove
	dec b
	ret z         ; processed all 4 moves
	inc hl
	ld a, [de]
	and a
	ret z         ; no more moves in move set
	inc de
	call ReadMove
	;ld a, [W_ENEMYMOVEEFFECT]
	;cp HEAL_EFFECT 
	;jr nz, .firstTurn
	;ld a, [wAILayer2Encouragement]
	;cp $1
	;jr z, .preferMove
	;jr nz, .nextMove
.firstTurn
	ld a, [wAILayer2Encouragement]
	cp $0
	jr nz, .nextMove
	;If player turns are large, then we must be a swap-in. It's not safe to try anything fancy.
	ld a, [wPlayerTurns]
	cp $2
	ld a, [W_ENEMYMOVEEFFECT]
	jr nc, .statusMovesOnly ;the only thing that can save us from the fear.
	cp ATTACK_UP1_EFFECT
	jr c, .nextMove ;no encourage if less than ATTACK_UP1_EFFECT
	cp HAZE_EFFECT + 1
	jr c, .preferMove ;encourage if ATTACK_UP1_EFFECT-HAZE_EFFECT
	cp SLEEP_EFFECT
	jr z, .preferMove ;encourage SLEEP_EFFECT
	cp CONFUSION_EFFECT
	jr c, .nextMove ;no encourage if less than CONFUSION_EFFECT
	cp CONFUSION_SIDE_EFFECT
	jr c, .preferMove ;encourage if CONFUSION_EFFECT-(CONFUSION_SIDE_EFFECT-1)
	jr .nextMove
.preferMove
	dec [hl]       ; slighly encourage this move
	jr .nextMove
.statusMovesOnly
	cp CONFUSION_EFFECT
	jr z, .preferMove
	cp SLEEP_EFFECT
	jr z, .preferMove
	cp POISON_EFFECT
	jr z, .preferMove
	cp PARALYZE_EFFECT
	jr z, .preferMove
	jr .nextMove
	
; encourages moves that are effective against the player's mon unless they are nondamaging
; discourage damaging moves that are ineffective or not very effective against the player's mon,
; unless there's no damaging move that deals at least neutral damage
AIMoveChoiceModification3: ; ????? (e:????)
	ld hl, wBuffer - 1  ; temp move selection array (-1 byte offest)
	ld de, wEnemyMonMoves  ; enemy moves
	ld b, $5
.nextMove
	dec b
	ret z         ; processed all 4 moves
	inc hl
	ld a, [de]
	and a
	ret z         ; no more moves in move set
	inc de
	call ReadMove
	ld a, [W_ENEMYMOVEEFFECT] ;if move is one of these effects, DO consider it effectiveness.
	push hl
	push de
	push bc
	ld hl, ZeroPowerImmunityMoveEffects
	ld de, $0001
	call IsInArray
	pop bc
	pop de
	pop hl
	jr nc, .ignoreZeroPower
	ld a, [W_ENEMYMOVENUM] ;Glare is the exception to the Paralyze rule.
	cp GLARE
	jr nz, .considerEffectiveness
.ignoreZeroPower
	ld a, [W_ENEMYMOVEPOWER] ; If move has special effect, don't consider its effectiveness.
	and a
	jr z, .nextMove
.considerEffectiveness
	push hl
	push bc
	push de
	callab AIGetTypeEffectiveness
	pop de
	pop bc
	pop hl
	ld a, [wd11e]
	cp 12 ;See fast type matchups for why 12 
	jr z, .nextMove ;we'll do normal damage to them.
	jr c, .notEffectiveMove ;we'll do less damage to them.
	dec [hl]       ; slighly encourage this move
	jr .nextMove
.notEffectiveMove  ; discourages non-effective moves if better moves are available
	push hl
	push de
	push bc
	ld a, [W_ENEMYMOVETYPE]
	ld d, a
	ld hl, wEnemyMonMoves  ; enemy moves
	ld b, $5
	ld c, $0
.loopMoves
	dec b
	jr z, .done
	ld a, [hli]
	and a
	jr z, .done
	call ReadMove
	ld a, [W_ENEMYMOVEEFFECT]
	cp SUPER_FANG_EFFECT
	jr z, .betterMoveFound      ; Super Fang is considered to be a better move
	cp SPECIAL_DAMAGE_EFFECT
	jr z, .betterMoveFound      ; any special damage moves are considered to be better moves
	cp FLY_EFFECT
	jr z, .betterMoveFound      ; Fly is considered to be a better move
	ld a, [W_ENEMYMOVETYPE]
	cp d
	jr z, .loopMoves
	ld a, [W_ENEMYMOVEPOWER]
	and a
	jr nz, .betterMoveFound      ; damaging moves of a different type are considered to be better moves
	jr .loopMoves
.betterMoveFound
	ld c, a
.done
	ld a, c
	pop bc
	pop de
	pop hl
	and a
	jp z, .nextMove
	inc [hl]       ; slighly discourage this move
	jp .nextMove
	ret
	
	;try to set up on sleepers, dream eater?
	; if low health, try to snipe with quick attack, explode, heal, etc.
	; try to flinch if faster.
	; Context-specific scoring.
AIMoveChoiceModification4: ; 39883 (e:5883)

	ld hl, wBuffer  ; temp move selection array (-1 byte offest applied later on.)
	ld de, wEnemyMonMoves  ; enemy moves
	ld b, $5
.checkmove
	dec b
	ret z ; processed all 4 moves

	ld a, [de]
	inc de
	and a
	ret z

	push de
	push bc
	push hl
	call ReadMove

	ld a, [W_ENEMYMOVEEFFECT]
	ld hl, SmartEffectJumpTable
	ld de, 3
	call IsInArray

	inc hl
	jr nc, .nextmove

	ld a, [hli]
	ld e, a
	ld d, [hl]

	pop hl
	push hl

	ld bc, .nextmove
	push bc

	push de
	ret ;Sneakily abuses pop to change Program Counter?

.nextmove
	pop hl
	pop bc
	pop de
	inc hl
	jr .checkmove

; discourage non-damaging moves if we used an attack the previous turn.
AIMoveChoiceModification5:
	ld a, [wAILayer2Encouragement]
	cp 0
	ret z
	ld hl, wBuffer - 1 ; temp move selection array (-1 byte offest)
	ld de, wEnemyMonMoves ; enemy moves
	ld b, NUM_MOVES + 1
.nextMove
	dec b
	ret z         ; processed all 4 moves
	inc hl
	ld a, [de]
	and a
	ret z         ; no more moves in move set
	inc de
	call ReadMove
	ld a, [W_ENEMYMOVEPOWER]
	and a
	jr nz, .nextMove 
	;Attack is 0 power, we need to check if we are done setting up or not.
	ld a,[wEnemySelectedMove]
	cp 0
	jr z, .nextMove
	cp $FF
	jr z, .nextMove
	call ReadMove
	ld a, [W_ENEMYMOVEPOWER]
	and a
	jr z, .nextMove ;last turn's move was 0 power, we can keep setting up.
	;we attacked, don't use 0 power moves.
	ld a, [hl]
	add $3       ; discourage move
	ld [hl], a
	jr .nextMove

;;If you are going to use this make sure H_WHOSETURN is set to 1 (enemy)
;;Also store W_DAMAGE somewhere?	
;;Enemy uses moves that will likely faint the opponent.
AIMoveChoiceModification6:
	ld a, [H_WHOSETURN]
	push af
	ld a, $1
	ld [H_WHOSETURN], a ;enemy turn
	ld hl,W_DAMAGE
	ld a,[hli]
	push af
	ld a,[hl]
	push af
	;setup. store whoseturn and damage.
	ld hl, wBuffer - 1 ; temp move selection array (-1 byte offest)
	ld de, wEnemyMonMoves ; enemy moves
	ld b, NUM_MOVES + 1
.nextMove
	dec b
	jr z, .doneChoiceMod6         ; processed all 4 moves
	inc hl
	ld a, [de]
	and a
	jr z, .doneChoiceMod6         ; no more moves in move set
	inc de
	call ReadMove
	ld a, [W_ENEMYMOVEPOWER]
	and a
	jr z, .nextMove
	push de
	push bc
	push hl
	;check damage (warning W_DAMAGE is overwritten)
	ld hl, AICalculatePotentialDamage
	ld b, BANK(AICalculatePotentialDamage)
	call Bankswitch
	ld de, wBattleMonHP
	ld hl, W_DAMAGE
	ld c, $2
	call StringCmp ; compare damage to HP
	pop hl
	pop bc
	pop de
	jr nc, .nextMove ;de is bigger.
	;move will faint player.
	ld a, [hl]
	sub $2;$3       ; encourage move
	ld [hl], a
	jr .nextMove
.doneChoiceMod6
	pop af ;w_damage + 1?
	ld hl,W_DAMAGE + 1 ;TODO: test that W_Damage actually gets set back correctly.
	ld [hld],a
	pop af ;w_damage?
	ld [hl],a
	pop af
	ld [H_WHOSETURN], a ;restore whoseturn
	ret
	
SmartEffectJumpTable
	dbw FLINCH_SIDE_EFFECT1,     AI_Smart_Flinch
	dbw FLINCH_SIDE_EFFECT2,     AI_Smart_Flinch
	dbw DREAM_EATER_EFFECT,      AI_Smart_DreamEater
	dbw HEAL_EFFECT,             AI_Smart_Heal
	dbw SWIFT_EFFECT,            AI_Smart_Swift
	dbw EXPLODE_EFFECT,          AI_Smart_Explode
	dbw DRAIN_HP_EFFECT,         AI_Smart_Drain
	dbw FLY_EFFECT,              AI_Smart_Fly
	dbw SLEEP_EFFECT,            AI_Smart_Sleep
	dbw HAZE_EFFECT,             AI_Smart_Haze
	dbw OHKO_EFFECT,             AI_Smart_Ohko
	dbw SUBSTITUTE_EFFECT,       AI_Smart_Substitute
	dbw POISON_EFFECT, 			 AI_Smart_TryToxic
	dbw ATTACK_DOWN1_EFFECT,     AI_Smart_StatDown
	dbw DEFENSE_DOWN1_EFFECT,    AI_Smart_StatDown
	dbw SPEED_DOWN1_EFFECT,      AI_Smart_StringShot
	dbw SPECIAL_DOWN1_EFFECT,    AI_Smart_StatDown
	dbw ACCURACY_DOWN1_EFFECT,   AI_Smart_StatDown
	dbw EVASION_DOWN1_EFFECT,    AI_Smart_StatDown
	dbw ATTACK_DOWN2_EFFECT,     AI_Smart_StatDown
	dbw DEFENSE_DOWN2_EFFECT,    AI_Smart_StatDown
	dbw SPEED_DOWN2_EFFECT,      AI_Smart_StringShot
	dbw SPECIAL_DOWN2_EFFECT,    AI_Smart_StatDown
	dbw ACCURACY_DOWN2_EFFECT,   AI_Smart_StatDown
	dbw EVASION_DOWN2_EFFECT,    AI_Smart_StatDown
	dbw ATTACK_UP1_EFFECT,       AI_Smart_StatUp         
	dbw DEFENSE_UP1_EFFECT,      AI_Smart_StatUp
	dbw SPEED_UP1_EFFECT,        AI_Smart_Agility
	dbw SPECIAL_UP1_EFFECT,      AI_Smart_StatUp
	dbw ACCURACY_UP1_EFFECT,     AI_Smart_StatUp
	dbw EVASION_UP1_EFFECT,      AI_Smart_StatUp
	dbw ATTACK_UP2_EFFECT,       AI_Smart_StatUp         
	dbw DEFENSE_UP2_EFFECT,      AI_Smart_StatUp
	dbw SPEED_UP2_EFFECT,        AI_Smart_Agility
	dbw SPECIAL_UP2_EFFECT,      AI_Smart_StatUp
	dbw ACCURACY_UP2_EFFECT,     AI_Smart_StatUp
	dbw EVASION_UP2_EFFECT,      AI_Smart_StatUp
	;TODO smart Counter.
	;;TODO smart trapping; If player is Burned or Poisoned, encourage trapping moves??
	db $ff	
	
AI_Smart_StringShot:
	call AI_Smart_SpeedMod
	call AI_Smart_StatDown
	ret
	
AI_Smart_Agility:
	call AI_Smart_SpeedMod
	call AI_Smart_StatUp
	ret

AI_Smart_SpeedMod:
	push hl
	ld a,$2
	call AICheckIfHPBelowFraction
	pop hl
	jp c, DiscourageMove ;Setting up not so good on low health.
	push hl
	ld de, wEnemyMonSpeed
	ld hl, wBattleMonSpeed
	ld c, $2
	call StringCmp ; compare speed values
	pop hl
	jp nc, DiscourageMove ;Enemy is faster.
	;Player is faster, fallthrough to statup
	ret

AI_Smart_StatUp:
	ld a, [wBattleMonStatus]
	and (1 << FRZ) | SLP ; is mon frozen or asleep?
	jr z, .doHealthCheck ; if not, play it safe.
	jp HalfEncourage
.doHealthCheck
	push hl
	ld de, wEnemyMonHP
	ld hl, wEnemyMonMaxHP
	ld c, $2
	call StringCmp
	pop hl
	jr nz, .doStatCheck ;health is full, get greedy.
	push hl
	ld de, wEnemyMonSpeed
	ld hl, wBattleMonSpeed
	ld c, $2
	call StringCmp ; compare speed values
	pop hl
	jp c, .doStatCheck ;Player is faster.
	jp HalfEncourage
.doStatCheck
	push hl
	ld hl, wEnemyMonStatMods
	ld de, W_ENEMYMOVEEFFECT
	ld a, [de]
	sub ATTACK_UP1_EFFECT
	cp EVASION_UP1_EFFECT + $3 - ATTACK_UP1_EFFECT ; covers all +1 effects
	jr c, .checkStatHighEnough
	sub ATTACK_UP2_EFFECT - ATTACK_UP1_EFFECT ; map +2 effects to equivalent +1 effect
.checkStatHighEnough
	ld c, a
	ld b, $0
	add hl, bc
	ld b, [hl]
	inc b ; increment corresponding stat mod
	ld a, $a
	cp b ; +3 is plenty high ($a or 10 or 7 + 3)
	pop hl
	ret c
	call AI_20_80 ;20% chance of c, 80% chance of nc
	ret nc
	dec [hl] ;encourage
	ret

AI_Dumb_StatUp:
	push hl
	ld hl, wEnemyMonStatMods
	ld de, W_ENEMYMOVEEFFECT
	ld a, [de]
	sub ATTACK_UP1_EFFECT
	cp EVASION_UP1_EFFECT + $3 - ATTACK_UP1_EFFECT ; covers all +1 effects
	jr c, .checkStatTooHigh
	sub ATTACK_UP2_EFFECT - ATTACK_UP1_EFFECT ; map +2 effects to equivalent +1 effect
.checkStatTooHigh
	ld c, a
	ld b, $0
	add hl, bc
	ld b, [hl]
	inc b ; increment corresponding stat mod
	ld a, $d
	cp b ; can't raise stat past +6 ($d or 13 or 7 + 6)
	pop hl
	jp c, DiscourageMove
	ret

AI_Smart_StatDown:
	ld a, [wBattleMonStatus]
	and (1 << FRZ) | SLP ; is mon frozen or asleep?
	jr z, .doHealthCheck ; if not, play it safe.
	jp HalfEncourage
.doHealthCheck
	push hl
	ld de, wEnemyMonHP
	ld hl, wEnemyMonMaxHP
	ld c, $2
	call StringCmp
	pop hl
	jr nz, .doStatCheck ;health is full, get greedy.
	push hl
	ld de, wEnemyMonSpeed
	ld hl, wBattleMonSpeed
	ld c, $2
	call StringCmp ; compare speed values
	pop hl
	jp c, .doStatCheck ;Player is faster.
	jp HalfEncourage
.doStatCheck
	push hl
	ld hl, wPlayerMonStatMods
	ld de, W_ENEMYMOVEEFFECT
	ld a, [de]
	sub ATTACK_DOWN1_EFFECT
	cp EVASION_DOWN1_EFFECT + $3 - ATTACK_DOWN1_EFFECT ; covers al -1 effects
	jr c, .checkStatTooLow
	sub ATTACK_DOWN2_EFFECT - ATTACK_DOWN1_EFFECT ; map -2 effects to corresponding -1 effect
.checkStatTooLow
	ld c, a
	ld b, $0
	add hl, bc
	ld b, [hl]
	ld a, $4
	cp b ; -3 is plenty low ($4 or 4 or 7 - 3)
	pop hl
	ret nc
	call AI_20_80 ;20% chance of c, 80% chance of nc
	ret nc
	dec [hl] ;encourage
	ret

AI_Dumb_StatDown:
	push hl
	ld hl, wPlayerMonStatMods
	ld de, W_ENEMYMOVEEFFECT
	ld a, [de]
	sub ATTACK_DOWN1_EFFECT
	cp EVASION_DOWN1_EFFECT + $3 - ATTACK_DOWN1_EFFECT ; covers al -1 effects
	jr c, .checkStatTooLow
	sub ATTACK_DOWN2_EFFECT - ATTACK_DOWN1_EFFECT ; map -2 effects to corresponding -1 effect
.checkStatTooLow
	ld c, a
	ld b, $0
	add hl, bc
	ld b, [hl]
	ld a, $1
	cp b ; can't lower stat past -6 ($1)
	pop hl
	jp z, DiscourageMove ; if stat mod is 1 (-6), can't lower anymore
	ret

AI_Smart_Substitute:
	push hl
	ld a,$4
	call AICheckIfHPBelowFraction
	pop hl
	jp c, DiscourageMove
;.enoughHealthForSub
	ld a, [wAILayer2Encouragement]
	cp $0
	ret nz
	jp HalfEncourage
	
AI_Smart_TryToxic:
	ld a, [W_ENEMYMOVENUM]
	cp TOXIC
	ret nz ;TOXIC is really the only poison good enough worth chasing
	ld a,[W_ENEMYBATTSTATUS2]
	bit HasSubstituteUp, a
	ret z ;no Sub, Toxic is risky to chase.
	dec [hl] ;encourage
	ret
	
;AI_Smart_Rage:
;TODO: if our attackmod is looking low, maybe rage.	
	
AI_Smart_Ohko:
	push hl
	ld de, wBattleMonSpeed
	ld hl, wEnemyMonSpeed
	ld c, $2
	call StringCmp ; compare speed values
	pop hl
	jp nc, DiscourageMove ;Player is faster.
	push hl
	ld a,$2
	call AICheckIfPlayerHPBelowFraction
	pop hl
	ret nc
	inc [hl] ;discourage
	ret
	
AI_Smart_Fly:
	;TODO also get Dig in here.
	push hl
	ld de, wBattleMonSpeed
	ld hl, wEnemyMonSpeed
	ld c, $2
	call StringCmp ; compare speed values
	pop hl
	ret nc ;player is faster
	ld a, [W_PLAYERBATTSTATUS1]
	bit ChargingUp , a
	ret z ;player is not charging a move
	;Enemy is faster AND Player is charging a move. We can try and dodge.
	call AI_20_80
	ret c
	dec [hl]
	ret
	
AI_Smart_Sleep:
	;TODO: check Dream Eater?
	push hl
	ld de, wBattleMonSpeed
	ld hl, wEnemyMonSpeed
	ld c, $2
	call StringCmp ; compare speed values
	pop hl
	ret nc ;player is faster
	ld a, [W_PLAYERBATTSTATUS1]
	bit ChargingUp , a
	jp nz, HalfEncourage  ;solarbeam etc.
	ld a, [W_PLAYERBATTSTATUS2]
	bit NeedsToRecharge, a
	ret z ;no hyperbeam
	call Random
	cp $19
	ret c
rept 2
	dec [hl] ;encourage (sleep will have 100% hit rate due to ChargingUp)
endr
	ret
	
AI_Smart_Flinch:
	ld a,[W_PLAYERBATTSTATUS2]
	bit HasSubstituteUp, a
	ret nz ;can't flinch if Sub'd
	push hl
	ld de, wBattleMonSpeed
	ld hl, wEnemyMonSpeed
	ld c, $2
	call StringCmp ; compare speed values
	pop hl
	ret nc ;player is faster
HalfEncourage:
	call AI_50_50
	ret c ;50% chance of not encouraging
	dec [hl]
	ret
	
AI_Smart_Drain:
	;ld a,[W_PLAYERBATTSTATUS2]
	;bit HasSubstituteUp, a
	;ret nz ;can't drain health if Sub'd
	;.considerEffectiveness copied from above.
	push hl
	push bc
	push de
	callab AIGetTypeEffectiveness
	pop de
	pop bc
	pop hl
	ld a, [wd11e]
	cp 12 ;See fast type matchups for why 12 
	jp c, DiscourageMove ;we'll do less damage to them.
	jr nz, .considerMove ;we'll do super effective damage to them.
	push hl
	ld de, wEnemyMonHP
	ld hl, wEnemyMonMaxHP
	ld c, $2
	call StringCmp
	pop hl
	ret z ;extra heals won't help us; health is full.
	ld a, [wBattleMonStatus]
	and (1 << FRZ) | SLP ; is mon frozen or asleep?
	ret z ; if not, we're done.
.considerMove
	jp HalfEncourage
	

AI_Smart_Swift:
	ld a, [wEnemyMonAccuracyMod]
	cp $5 ;7 - 2
	jr c, .encourageSwift
	ld a, [wPlayerMonEvasionMod]
	cp $a ;7 + 3
	ret c
.encourageSwift
	call AI_20_80 ; 80% chance of encouraging.
	ret c
rept 2
	dec [hl]
endr
	ret
	
AI_Smart_Heal:
	ld a, [W_ENEMYMOVENUM] ;We can afford to be a little more dangerous with Rest.
	cp REST
	jr z, .handleRest
.normalHealProcessing
	push hl
	ld a,$3
	call AICheckIfHPBelowFraction
	pop hl
	jr c, .yesHeal
	push hl
	ld a,$2
	call AICheckIfHPBelowFraction
	pop hl
	jr c, .maybeHeal
	push hl
	ld de, wEnemyMonHP
	ld hl, wEnemyMonMaxHP
	ld c, $2
	call StringCmp
	pop hl
	jr nz, .maybeNoHeal
.noHeal ;we have full health.
	call AI_20_80 ;20% chance of c, 80% chance of nc
	ret nc ;we rarely want to heal if we have full health.
	inc [hl] ;we can undo a player's attack maybe, but that's frustrating.
	ret
.maybeNoHeal
	call AI_50_50 ;50% chance of discouraging
	ret nc
	inc [hl]
.maybeHeal
	call Random
	cp $28
	ret c
	dec [hl]
	ret
.yesHeal
	call Random
	cp $19
	ret c
rept 2
	dec [hl] ;encourage
endr
	ret
.handleRest
	ld a, [wEnemyMonStatus]
	and a
	jr nz, .normalHealProcessing ; if have a status be more careful.
	push hl
	ld a,$2
	call AICheckIfHPBelowFraction
	pop hl
	jr nc, .maybeNoHeal
	push hl
	ld a,$5
	call AICheckIfHPBelowFraction
	pop hl
	jr c, .yesHeal
	ret
	
AI_Smart_DreamEater:
	ld a, [wBattleMonStatus]
	and a,SLP ; is the target pokemon sleeping?
	ret z ;not sleeping
	call AI_20_80 ;80% chance of encouraging
	ret c
	dec [hl]       ; slighly encourage this move
	ret
	
AI_Smart_Explode:
	push hl
	call AIRateMatchupOfCurrentMon
	pop hl
	ld a, [wd11e]
	cp 12 ;See fast type matchups for why 12 
	jr z, .next ;they'll do normal damage to us.
	jr c, .next ;they'll do less damage to us.
	ret
.next
	push hl
	ld a,$2
	call AICheckIfHPBelowFraction
	pop hl
	jr nc, DiscourageMove
	push hl
	ld a,$4
	call AICheckIfHPBelowFraction
	pop hl
	ret c
	push hl
	ld a,$3
	call AICheckIfPlayerHPBelowFraction
	pop hl
	jr nc, .noExplodeMaybe
	;otherwise, player is too weak for Explosion to be worth it.
	inc [hl]
.noExplodeMaybe
	call Random
	cp $19
	ret c
rept 2
	inc [hl] ;discorage
endr
	ret
	
AI_Smart_Haze:
	push hl
	ld a, [wEnemyMonStatus]
	and a
	jr nz, .shouldHaze ; 85% encourage if have a status
	ld hl, wEnemyMonAttackMod ;is enemy's stat levels is lower than -2?
	ld c, $7
.enemyModLoop
	dec c
	jr z, .removePlayerMods
	ld a, [hli]
	cp $5
	jr c, .shouldHaze
	jr .enemyModLoop	
.removePlayerMods ;player's stat levels is higher than +2?
	ld hl, wPlayerMonAttackMod
	ld c, $7
.playerModLoop
	dec c
	jr z, .shouldNotHaze
	ld a, [hli]
	cp $a
	jr c, .playerModLoop
.shouldHaze
	pop hl
	call Random
	cp $28
	ret c
	dec [hl]
	ret
; Discourage this move otherwise:
.shouldNotHaze
	pop hl
	inc [hl]
	inc [hl]
	ret

AI_20_80: ;20% chance of c, 80% chance of nc
	call Random
	cp 50 ; 1/5
	ret
	
AI_50_50:
	call Random
	cp $80
	ret
	
DiscourageMove:
	ld a, [hl]
	add $9       ; discourage move
	ld [hl], a
	ret

ReadMove: ; 39884 (e:5884)
	push hl
	push de
	push bc
	dec a
	ld e,a
	callab AILoadMoveData
	pop bc
	pop de
	pop hl
	ret

; move choice modification methods that are applied for each trainer class
; 0 is sentinel value
TrainerClassMoveChoiceModifications: ; 3989b (e:589b)
	db 0      ; YOUNGSTER
	db 1,5,0  ; BUG CATCHER
	db 1,5,0  ; LASS
	db 1,3,0  ; SAILOR
	db 1,0    ; JR__TRAINER_M
	db 1,0    ; JR__TRAINER_F
	db 1,2,3,0; POKEMANIAC
	db 1,2,0  ; SUPER_NERD
	db 1,0    ; HIKER
	db 1,0    ; BIKER
	db 1,3,0  ; BURGLAR
	db 1,0    ; ENGINEER
	db 1,2,0  ; JUGGLER_X
	db 1,3,0  ; FISHER
	db 1,3,0  ; SWIMMER
	db 0      ; CUE_BALL
	db 1,0    ; GAMBLER
	db 1,3,0  ; BEAUTY
	db 1,2,0  ; PSYCHIC_TR
	db 1,3,0  ; ROCKER
	db 1,0    ; JUGGLER
	db 1,0    ; TAMER
	db 1,0    ; BIRD_KEEPER
	db 1,0    ; BLACKBELT
	db 1,0    ; SONY1
	db 1,3,0  ; PROF_OAK
	db 1,2,0  ; CHIEF
	db 1,2,0  ; SCIENTIST
	db 1,3,0  ; GIOVANNI
	db 1,0    ; ROCKET
	db 1,3,0  ; COOLTRAINER_M
	db 1,3,0  ; COOLTRAINER_F
	db 1,5,6,0; BRUNO
	db 1,0    ; BROCK
	db 1,3,0  ; MISTY
	db 1,3,0  ; LT__SURGE
	db 1,3,0  ; ERIKA
	db 1,3,0  ; KOGA
	db 1,3,0  ; BLAINE
	db 1,3,4,0; SABRINA
	db 1,2,0  ; GENTLEMAN
	db 1,3,0  ; SONY2
	db 1,3,4,6,0; SONY3
	db 1,2,4,6,0; LORELEI
	db 1,0    ; CHANNELER
	db 1,4,0  ; AGATHA
	db 1,3,6,0  ; LANCE

INCLUDE "engine/battle/trainer_pic_money_pointers.asm"
	
INCLUDE "text/trainer_names.asm"	

INCLUDE "engine/battle/bank_e_misc.asm"

INCLUDE "engine/battle/read_trainer_party.asm"

INCLUDE "data/trainer_moves.asm"

INCLUDE "data/trainer_parties.asm"

TrainerAI: ; 3a52e (e:652e)
;XXX called at 34964, 3c342, 3c398
	and a
	ld a,[W_ISINBATTLE]
	dec a
	ret z ; if not a trainer, we're done here
	ld a,[wLinkState]
	cp LINK_STATE_BATTLING
	ret z
	;Are we allowed to select an item?
	ld a, [W_ENEMYBATTSTATUS2]
	and (1 << NeedsToRecharge)
	jr nz, .clearCarry ;enemy cannot use item.
	ld a, [W_ENEMYBATTSTATUS1]
	and (1 << ThrashingAbout) | (1 << ChargingUp)
	jr nz, .clearCarry ;enemy can not use item.
	ld a,[W_TRAINERCLASS] ; what trainer class is this?
	dec a
	ld c,a
	ld b,0
	ld hl,TrainerAIPointers
	add hl,bc
	add hl,bc
	add hl,bc
	ld a,[wAICount]
	and a
	ret z ; if no AI uses left, we're done here
	inc hl
	inc a
	jr nz,.getpointer
	dec hl
	ld a,[hli]
	ld [wAICount],a
.getpointer
	ld a,[hli]
	ld h,[hl]
	ld l,a
	call Random
	jp [hl]
.clearCarry
	and a ; clear carry
	ret

TrainerAIPointers: ; 3a55c (e:655c)
; one entry per trainer class
; first byte, number of times (per Pokémon) it can occur
; next two bytes, pointer to AI subroutine for trainer class
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,JugglerAI ; juggler_x
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 3,JugglerAI ; juggler
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 2,BlackbeltAI ; blackbelt
	dbw 3,GenericAI
	dbw 3,GenericAI
	dbw 1,GenericAI ; chief
	dbw 3,GenericAI
	dbw 1,GiovanniAI ; giovanni
	dbw 3,GenericAI
	dbw 2,CooltrainerMAI ; cooltrainerm
	dbw 1,CooltrainerFAI ; cooltrainerf
	dbw 2,BrunoAI ; bruno
	dbw 5,BrockAI ; brock
	dbw 1,MistyAI ; misty
	dbw 1,LtSurgeAI ; surge
	dbw 1,ErikaAI ; erika
	dbw 2,KogaAI ; koga
	dbw 2,BlaineAI ; blaine
	dbw 1,SabrinaAI ; sabrina
	dbw 3,GenericAI
	dbw 1,Sony2AI ; sony2
	dbw 1,Sony3AI ; sony3
	dbw 2,LoreleiAI ; lorelei
	dbw 3,GenericAI
	dbw 2,AgathaAI ; agatha
	dbw 1,LanceAI ; lance

JugglerAI: ; 3a5e9 (e:65e9)
	cp $40
	ret nc
	jp AISwitchIfEnoughMons

BlackbeltAI: ; 3a5ef (e:65ef)
	cp $20
	ret nc
	jp AIUseXAttack

GiovanniAI: ; 3a5f5 (e:65f5)
	cp $40
	ret nc
	jp AIUseXAccuracy

CooltrainerMAI: ; 3a5fb (e:65fb)
	cp $40
	ret nc
	jp AIUseXAttack

CooltrainerFAI: ; 3a601 (e:6601)
	cp $40
	ld a,$A
	call AICheckIfHPBelowFraction
	jp c,AIUseHyperPotion
	ld a,5
	call AICheckIfHPBelowFraction
	ret nc
	jp AISwitchIfEnoughMons

BrockAI: ; 3a614 (e:6614)
; if his active monster has a status condition, use a full heal
	ld a,[wEnemyMonStatus]
	and a
	ret z
	jp AIUseFullHeal

MistyAI: ; 3a61c (e:661c)
	cp $40
	ret nc
	jp AIUseXDefend

LtSurgeAI: ; 3a622 (e:6622)
	cp $40
	ret nc
	push hl
	ld de, wEnemyMonSpeed
	ld hl, wBattleMonSpeed
	ld c, $2
	call StringCmp ; compare speed values
	pop hl
	ret nc ;Enemy is faster.
	jp AIUseXSpeed

ErikaAI: ; 3a628 (e:6628)
	cp $80
	ret nc
	ld a,$A
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseSuperPotion

KogaAI: ; 3a634 (e:6634)
	cp $40
	ret nc
	jp AIUseXAttack

BlaineAI: ; 3a63a (e:663a)
	cp $40
	ret nc
	ld a,2
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseSuperPotion

SabrinaAI: ; 3a640 (e:6640)
	cp $40
	ret nc
	ld a,$A
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseHyperPotion

Sony2AI: ; 3a64c (e:664c)
	cp $20
	ret nc
	ld a,5
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUsePotion

Sony3AI: ; 3a658 (e:6658)
	ld b, a
	push bc
	call JudgeMatchupsAI
	pop bc
	jp c, AISwitchIfEnoughMons ;they'll do a lot of damage; switch if able.
	ld a,[wEnemyMonStatus]
	bit FRZ,a ; frozen?
	jr nz,.fullRestore
	ld a, b ;resume normal AI if didn't switch.
	cp $20
	ret nc
	ld a,5
	call AICheckIfHPBelowFraction
	ret nc
.fullRestore
	jp AIUseFullRestore

LoreleiAI: ; 3a664 (e:6664)
	cp $80
	ret nc
	ld a,5
	call AICheckIfHPBelowFraction
	ret nc
	ld a,[wEnemyMonPartyPos]
	cp 0 ;DEWGONG
	ret z ;dewgong has rest, do not heal him.
	jp AIUseSuperPotion

JudgeMatchupsAI: ; 3a670 (e:6670)
	ld a, [wPlayerTurns]
	cp $0
	jr z, .noSwitch ;We cannot swap if the player just did!
	call AIRateMatchupOfCurrentMon
	ld a, [wd11e]
	cp 12 ;See fast type matchups for why 12 
	jr z, .noSwitch ;they'll do normal damage to us.
	jr c, .noSwitch ;they'll do less damage to us.
	;We got a sucky mon. See if there are any betters.
	call AIBetterMonsExist
	and a
	jr z, .noSwitch ; no other good mons.
	scf
	ret
.noSwitch
	and a ; clear carry
	ret
	
BrunoAI:
	;Use x-defend if:
	;we are fighting a pokemon with a physical type (less than fire)
	cp $40
	ret nc
	ld a,[wBattleMonType1]
	cp FIRE ; types >= FIRE are all special
	jp nc, AIUseXSpecial
	jp AIUseXDefend

AgathaAI: ; 3a676 (e:6676)
	;add:
	;Switch if mon is low HP and opponent is toxic'd.
	ld b, a
	push bc
	ld de, wEnemyMonMoves ; enemy moves
	ld b, NUM_MOVES + 1
.nextMove
	dec b
	jr z, .noFoundDreamEater ; processed all 4 moves
	ld a, [de]
	and a
	jr z, .noFoundDreamEater ; no more moves in move set
	inc de
	cp DREAM_EATER
	jr z, .foundDreamEater
	jr .nextMove
.noFoundDreamEater
	ld hl,wBattleMonStatus
	ld a,[hl]
	and a,SLP ; sleep mask
	jr z,.foundDreamEater
; sleeping
	ld a, $7F
	jr .checkSwitch ;if asleep and no-dream eater, we probably want to switch.
.foundDreamEater
	ld a, $14
.checkSwitch
	ld b, a
	pop af
	cp b
	jr c, .maybeSwitch
	cp $80
	ret nc
	ld a,4
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseSuperPotion
.maybeSwitch
	ld a, [wEnemyTurns]
	cp 0
	ret z ;you are just out, don't switch.
	ld a,[W_ENEMYBATTSTATUS2]
	bit HasSubstituteUp, a
	ret nz ;HasSubstituteUp = 1
	jp AISwitchIfEnoughMons


LanceAI: ; 3a687 (e:6687)
	cp $80
	ret nc
	ld a,5
	call AICheckIfHPBelowFraction
	ret nc
	jp AIUseHyperPotion

GenericAI: ; 3a693 (e:6693)
	and a ; clear carry
	ret

; end of individual trainer AI routines

DecrementAICount: ; 3a695 (e:6695)
	ld hl,wAICount
	dec [hl]
	scf
	ret

Func_3a69b: ; 3a69b (e:669b)
	ld a,(SFX_08_3e - SFX_Headers_08) / 3
	jp PlaySoundWaitForCurrent

AIUseFullRestore: ; 3a6a0 (e:66a0)
	call AICureStatus
	ld a,FULL_RESTORE
	ld [wcf05],a
	ld de,wHPBarOldHP
	ld hl,wEnemyMonHP + 1
	ld a,[hld]
	ld [de],a
	inc de
	ld a,[hl]
	ld [de],a
	inc de
	ld hl,wEnemyMonMaxHP + 1
	ld a,[hld]
	ld [de],a
	inc de
	ld [wHPBarMaxHP],a
	ld [wEnemyMonHP + 1],a
	ld a,[hl]
	ld [de],a
	ld [wHPBarMaxHP+1],a
	ld [wEnemyMonHP],a
	jr AIPrintItemUseAndUpdateHPBar

AIUsePotion: ; 3a6ca (e:66ca)
; enemy trainer heals his monster with a potion
	ld a,POTION
	ld b,20
	jr AIRecoverHP

AIUseSuperPotion: ; 3a6d0 (e:66d0)
; enemy trainer heals his monster with a super potion
	ld a,SUPER_POTION
	ld b,50
	jr AIRecoverHP

AIUseHyperPotion: ; 3a6d6 (e:66d6)
; enemy trainer heals his monster with a hyper potion
	ld a,HYPER_POTION
	ld b,200
	; fallthrough

AIRecoverHP: ; 3a6da (e:66da)
; heal b HP and print "trainer used $(a) on pokemon!"
	ld [wcf05],a
	ld hl,wEnemyMonHP + 1
	ld a,[hl]
	ld [wHPBarOldHP],a
	add b
	ld [hld],a
	ld [wHPBarNewHP],a
	ld a,[hl]
	ld [wHPBarOldHP+1],a
	ld [wHPBarNewHP+1],a
	jr nc,.next
	inc a
	ld [hl],a
	ld [wHPBarNewHP+1],a
.next
	inc hl
	ld a,[hld]
	ld b,a
	ld de,wEnemyMonMaxHP + 1
	ld a,[de]
	dec de
	ld [wHPBarMaxHP],a
	sub b
	ld a,[hli]
	ld b,a
	ld a,[de]
	ld [wHPBarMaxHP+1],a
	sbc b
	jr nc,AIPrintItemUseAndUpdateHPBar
	inc de
	ld a,[de]
	dec de
	ld [hld],a
	ld [wHPBarNewHP],a
	ld a,[de]
	ld [hl],a
	ld [wHPBarNewHP+1],a
	; fallthrough

AIPrintItemUseAndUpdateHPBar: ; 3a718 (e:6718)
	call AIPrintItemUse_
	hlCoord 2, 2
	xor a
	ld [wHPBarType],a
	predef UpdateHPBar2
	jp DecrementAICount

AIRateMatchupOfCurrentMon: ;TODO: test
	ld a,[wEnemyMonPartyPos]
	ld [wWhichPokemon],a
AIRateMatchup:
	ld a,[wBattleMonType1]
	ld d,a                 ; d = type 1 of player.
	push hl
	callab AIGetMonEffectiveness
	pop hl
	ld a, [wd11e]
	push af
	ld a,[wBattleMonType2]
	ld d,a                 ; d = type 2 of player.
	push hl
	callab AIGetMonEffectiveness
	pop hl
	ld a, [wd11e]
	ld b, a
	pop af
	add b
	srl a	; /2 to average.
	ld [wd11e],a ; a score of how badly we want to switch. higher is more likely.
	ret
	
;TODO; try and reduce this down, almost all of this code is copied from AIEnemySendOutWhichMonGood.
;OUTPUT: a = 1 if a better choice exists.
;		a = 0 if no better choice exists.
AIBetterMonsExist:
	ld b, 5 + 1
.loopEnemyParty
	dec b
	ld a, b
	cp $ff
	jr z, .noBetterMonExists
	ld hl,wEnemyMon1
	ld [wWhichPokemon],a
	push bc
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	pop bc
	inc hl ;enemymonHP
	ld a, [hli]
	ld c, a
	ld a, [hl]
	or c ;HP isn't 0?
	jr z,.loopEnemyParty
	;check effectiveness
	push bc
	call AIRateMatchup
	pop bc
	ld a, [wd11e]
	cp 12 ;See fast type matchups for why 12 
	jr z, .aBetterMonExists ;they'll do normal damage than us. (wWhichPokemon contains an ok choice)
	jr c, .aBetterMonExists ;they'll do less damage to us. (wWhichPokemon contains a good choice)
	jr .loopEnemyParty
.aBetterMonExists
	ld a, 1
	ret
.noBetterMonExists
	xor a
	ret
	

AISwitchIfEnoughMons: ; 3a72a (e:672a)
; enemy trainer switches if there are 3 or more unfainted mons in party
	ld a,[wEnemyPartyCount]
	ld c,a
	ld hl,wEnemyMon1HP

	ld d,0 ; keep count of unfainted monsters

	; count how many monsters haven't fainted yet
.loop
	ld a,[hli]
	ld b,a
	ld a,[hld]
	or b
	jr z,.Fainted ; has monster fainted?
	inc d
.Fainted
	push bc
	ld bc,$2C
	add hl,bc
	pop bc
	dec c
	jr nz,.loop

	ld a,d ; how many available monsters are there?
	cp 2 ; don't bother if only 1 or 2
	jp nc,SwitchEnemyMon
	and a
	ret

SwitchEnemyMon: ; 3a74b (e:674b)
;Also used in core to switch link cable battlers, so don't call any sort of random in here.

; prepare to withdraw the active monster: copy hp, number, and status to roster

	ld a,[wEnemyMonPartyPos]
	ld hl,wEnemyMon1HP
	ld bc,wEnemyMon2 - wEnemyMon1
	call AddNTimes
	ld d,h
	ld e,l
	ld hl,wEnemyMonHP
	ld bc,4
	call CopyData

	ld hl, AIBattleWithdrawText
	call PrintText

	; This wIsFirstMons variable is abused to prevent the player from
	; switching in a new mon in response to this switch.
	ld a,2
	ld [wd11d],a
	callab EnemySendOut
	xor a
	ld [wd11d],a

	ld a,[wLinkState]
	cp LINK_STATE_BATTLING
	ret z
	scf
	ret
	
AIEnemySendOutAtWhichMon: ;2d:5493
	xor a
	ld b, a
	ld a, [wd11d]
	cp 1
	jr z, TryDeployFirstMon
	jp AIEnemySendOutWhichMonExecellent ;TODO: make some trainers not have our best AI.
AIEnemySendOutAtWhichMonAny:
	call Random
	cp 5 + 1 ; 0 - 5
	jr nc, AIEnemySendOutAtWhichMonAny
	ld b, a ;b holds the pokemon we want to switch to.
	ld a,[wEnemyMonPartyPos]
	cp b
	jr z, AIEnemySendOutAtWhichMonAny ;Not the mon that is already out.
TryDeployFirstMon:
	ld hl,wEnemyMon1
	ld a, b
	ld [wWhichPokemon], a
	push bc
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	pop bc
	inc hl ;enemymonHP
	ld a, [hli]
	ld c, a
	ld a, [hl]
	or c ;HP isn't 0?
	jr z, AIEnemySendOutAtWhichMonAny
	;if wd11d is set to a high value, pick a useful pokemon
	;wWhichPokemon now contains a random choice.
	ret

	;TODO; try and reduce this down, almost all of this code is copied from AIEnemySendOutWhichMonGood.
AIEnemySendOutWhichMonPoor:
	ld b, 5 + 1
.loopEnemyPartyPoor
	dec b
	ld a, b
	cp $ff
	jr z, AIEnemySendOutAtWhichMonAny
	ld hl,wEnemyMon1
	ld [wWhichPokemon],a
	push bc
	ld b, a
	ld a,[wEnemyMonPartyPos]
	cp b
	pop bc
	jr z, .loopEnemyPartyPoor ;Not the mon that is already out.
	push bc
	ld a,[wWhichPokemon]
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	pop bc
	inc hl ;enemymonHP
	ld a, [hli]
	ld c, a
	ld a, [hl]
	or c ;HP isn't 0?
	jr z,.loopEnemyPartyPoor
	;check effectiveness
	push bc
	call AIRateMatchup
	pop bc
	ld a, [wd11e]
	cp 16 ;See fast type matchups for why 16 
	ret z ;they'll do x2 damage than us. (wWhichPokemon contains an ok choice)
	ret c ;they'll do less than x2 damage to us. (wWhichPokemon contains a good choice)
	jr .loopEnemyPartyPoor
	
;TODO; try and reduce this down, almost all of this code is copied from AIEnemySendOutWhichMonGood.
AIEnemySendOutWhichMonOkay:
	ld b, 5 + 1
.loopEnemyPartyOkay
	dec b
	ld a, b
	cp $ff
	jr z, AIEnemySendOutWhichMonPoor
	ld hl,wEnemyMon1
	ld [wWhichPokemon],a
	push bc
	ld b, a
	ld a,[wEnemyMonPartyPos]
	cp b
	pop bc
	jr z, .loopEnemyPartyOkay ;Not the mon that is already out.
	push bc
	ld a,[wWhichPokemon]
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	pop bc
	inc hl ;enemymonHP
	ld a, [hli]
	ld c, a
	ld a, [hl]
	or c ;HP isn't 0?
	jr z,.loopEnemyPartyOkay
	;check effectiveness
	push bc
	call AIRateMatchup
	pop bc
	ld a, [wd11e]
	cp 12 ;See fast type matchups for why 12 
	ret z ;they'll do normal damage than us. (wWhichPokemon contains an ok choice)
	;ret c ;they'll do less damage to us. (wWhichPokemon contains a good choice)
	jr .loopEnemyPartyOkay
	
AIEnemySendOutWhichMonGood:
	ld b, 5 + 1
.loopEnemyPartyGood
	dec b
	ld a, b
	cp $ff
	jr z, AIEnemySendOutWhichMonOkay
	ld hl,wEnemyMon1
	ld [wWhichPokemon],a
	push bc
	ld b, a
	ld a,[wEnemyMonPartyPos]
	cp b
	pop bc
	jr z, .loopEnemyPartyGood ;Not the mon that is already out.
	push bc
	ld a,[wWhichPokemon]
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes
	pop bc
	inc hl ;enemymonHP
	ld a, [hli]
	ld c, a
	ld a, [hl]
	or c ;HP isn't 0?
	jr z,.loopEnemyPartyGood
	;check effectiveness
	push bc
	call AIRateMatchup
	pop bc
	ld a, [wd11e]
	cp 12 ;See fast type matchups for why 12 
	;ret z ;they'll do normal damage than us. (wWhichPokemon contains an ok choice)
	ret c ;they'll do less damage to us. (wWhichPokemon contains a good choice)
	jr .loopEnemyPartyGood

;TODO; try and reduce this down, almost all of this code is copied from AIEnemySendOutWhichMonGood.
;TODO; it's too obvious which mon the AI will choose ATM.
; maybe alternate between good and execellent randomly.
AIEnemySendOutWhichMonExecellent:
	ld b, 5 + 1
.loopEnemyPartyExecellent
	dec b
	ld a, b
	cp $ff
	jr z, AIEnemySendOutWhichMonGood
	ld hl,wEnemyMon1
	ld [wWhichPokemon],a
	push bc
	ld b, a
	ld a,[wEnemyMonPartyPos]
	cp b
	pop bc
	jr z, .loopEnemyPartyExecellent ;Not the mon that is already out.
	push bc
	ld a,[wWhichPokemon]
	ld bc, wEnemyMon2 - wEnemyMon1
	call AddNTimes ; add bc to hl, a times.
	pop bc
	inc hl ;enemymonHP
	ld a, [hli]
	ld c, a
	ld a, [hl]
	or c ;HP isn't 0?
	jr z,.loopEnemyPartyExecellent
	;check effectiveness
	push bc
	call AIRateMatchup
	pop bc
	ld a, [wd11e]
	cp 10 ;See fast type matchups for why 12 
	ret z ;they'll do no damage than us. (wWhichPokemon contains an Execellent choice)
	ret c ;they'll do no damage to us. (wWhichPokemon contains a Execellent choice)
	jr .loopEnemyPartyExecellent

AIBattleWithdrawText: ; 3a781 (e:6781)
	TX_FAR _AIBattleWithdrawText
	db "@"

AIUseFullHeal: ; 3a786 (e:6786)
	call Func_3a69b
	call AICureStatus
	ld a,FULL_HEAL
	jp AIPrintItemUse

AICureStatus: ; 3a791 (e:6791)
; cures the status of enemy's active pokemon
	ld a,[wEnemyMonPartyPos]
	ld hl,wEnemyMon1Status
	ld bc,wEnemyMon2 - wEnemyMon1
	call AddNTimes
	xor a
	ld [hl],a ; clear status in enemy team roster
	ld [wEnemyMonStatus],a ; clear status of active enemy
	ld hl,W_ENEMYBATTSTATUS3
	res BadlyPoisoned,[hl]
	;restore stats to normal state (burn or paralzye)
	ld a, 1
	ld [wd11e], a
	callab CalculateModifiedStats ; TODO; test.
	ret

AIUseXAccuracy: ; 0x3a7a8 unused
	call Func_3a69b
	ld hl,W_ENEMYBATTSTATUS2
	set UsingXAccuracy,[hl]
	ld a,X_ACCURACY
	jp AIPrintItemUse

AIUseGuardSpec: ; 3a7b5 (e:67b5)
	call Func_3a69b
	ld hl,W_ENEMYBATTSTATUS2
	set ProtectedByMist,[hl]
	ld a,GUARD_SPEC_
	jp AIPrintItemUse

AIUseDireHit: ; 0x3a7c2 unused
	call Func_3a69b
	ld hl,W_ENEMYBATTSTATUS2
	set GettingPumped,[hl]
	ld a,DIRE_HIT
	jp AIPrintItemUse

AICheckIfHPBelowFraction: ; 3a7cf (e:67cf)
; return carry if enemy trainer's current HP is below 1 / a of the maximum
	ld [H_DIVISOR],a
	ld hl,wEnemyMonMaxHP
	ld a,[hli]
	ld [H_DIVIDEND],a
	ld a,[hl]
	ld [H_DIVIDEND + 1],a
	ld b,2
	call Divide
	ld a,[H_QUOTIENT + 3]
	ld c,a
	ld a,[H_QUOTIENT + 2]
	ld b,a
	ld hl,wEnemyMonHP + 1
	ld a,[hld]
	ld e,a
	ld a,[hl]
	ld d,a
	ld a,d
	sub b
	ret nz
	ld a,e
	sub c
	ret
	
AICheckIfPlayerHPBelowFraction:
; return carry if player trainer's current HP is below 1 / a of the maximum
	ld [H_DIVISOR],a
	ld hl,wBattleMonMaxHP
	ld a,[hli]
	ld [H_DIVIDEND],a
	ld a,[hl]
	ld [H_DIVIDEND + 1],a
	ld b,2
	call Divide
	ld a,[H_QUOTIENT + 3]
	ld c,a
	ld a,[H_QUOTIENT + 2]
	ld b,a
	ld hl,wBattleMonHP + 1
	ld a,[hld]
	ld e,a
	ld a,[hl]
	ld d,a
	ld a,d
	sub b
	ret nz
	ld a,e
	sub c
	ret

AIUseXAttack: ; 3a7f2 (e:67f2)
	ld b,$A
	ld a,X_ATTACK
	jr AIIncreaseStat

AIUseXDefend: ; 3a7f8 (e:67f8)
	ld b,$B
	ld a,X_DEFEND
	jr AIIncreaseStat

AIUseXSpeed: ; 3a7fe (e:67fe)
	ld b,$C
	ld a,X_SPEED
	jr AIIncreaseStat

AIUseXSpecial: ; 3a804 (e:6804)
	ld b,$D
	ld a,X_SPECIAL
	; fallthrough

AIIncreaseStat: ; 3a808 (e:6808)
	ld [wcf05],a
	push bc
	call AIPrintItemUse_
	pop bc
	ld hl,W_ENEMYMOVEEFFECT
	ld a,[hld]
	push af
	ld a,[hl]
	push af
	push hl
	ld a,ANIM_AF
	ld [hli],a
	ld [hl],b
	callab StatModifierUpEffect
	pop hl
	pop af
	ld [hli],a
	pop af
	ld [hl],a
	jp DecrementAICount

AIPrintItemUse: ; 3a82c (e:682c)
	ld [wcf05],a
	call AIPrintItemUse_
	jp DecrementAICount

AIPrintItemUse_: ; 3a835 (e:6835)
; print "x used [wcf05] on z!"
	ld a,[wcf05]
	ld [wd11e],a
	call GetItemName
	ld hl, AIBattleUseItemText
	jp PrintText

AIBattleUseItemText: ; 3a844 (e:6844)
	TX_FAR _AIBattleUseItemText
	db "@"
