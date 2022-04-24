MisdreavusBaseStats:
db DEX_MISDREAVUS ; pokedex id
db 60 ; base hp
db 60 ; base attack
db 60 ; base defense
db 85 ; base speed
db 85 ; base special
db GHOST  ; species type 1
db GHOST  ; species type 2
db 45 ; catch rate
db 147 ; base exp yield
INCBIN "pic/bmon/zubat.pic",0,1 ; 55, sprite dimensions
dw MisdreavusPicFront
dw MisdreavusPicBack
; attacks known at lvl 0
db GROWL
db PSYWAVE
db 0
db 0
db 4 ; growth rate
; learnset
db %00100000
db %00000000
db %10000000
db %10010001
db %00000000
db %00111010
db %01000010
db 0 ; padding
