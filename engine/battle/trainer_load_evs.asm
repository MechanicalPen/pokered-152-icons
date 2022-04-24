TrainerLoadEVs:
; don't change any moves in a link battle
	ld a, 0
	ld e, a ;return e if link battle. (UNSURE if nessisary.)
	ld a,[wLinkState]
	and a
	ret nz

; get the pointer to trainer data for this class
	ld a,[W_CUROPPONENT]
	sub $C9 ; convert value from pokemon to trainer
	add a,a
	ld hl,TrainerEVDataPointers
	ld c,a
	ld b,0
	add hl,bc ; hl points to trainer class
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld a,[W_TRAINERNO]
	ld b,a
; At this point b contains the trainer number,
; and hl points to the trainer class.
; Our next task is to iterate through the trainers,
; decrementing b each time, until we get to the right one.
.outer
	dec b
	jr z,.IterateTrainer
.inner
	ld a,[hli]
	and a
	jr nz,.inner
	jr .outer

; right now we just have one byte for EVS, this'll change in the future.
.IterateTrainer
	ld a,[hli]
	ld e, a
	ret