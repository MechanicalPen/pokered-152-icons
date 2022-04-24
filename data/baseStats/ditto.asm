DittoBaseStats: ; 39232 (e:5232)
db DEX_DITTO ; pokedex id
db 63 ; base hp
db 63 ; base attack
db 63 ; base defense
db 63 ; base speed
db 63 ; base special
db NORMAL ; species type 1
db NORMAL ; species type 2
db 35 ; catch rate
db 61 ; base exp yield
INCBIN "pic/bmon/ditto.pic",0,1 ; 55, sprite dimensions
dw DittoPicFront
dw DittoPicBack
; attacks known at lvl 0
db TRANSFORM
db 0
db 0
db 0
db 0 ; growth rate
; learnset
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db %00000000
db 0 ; padding
