TrainerEVDataPointers: ; 39d3b (e:5d3b)
	dw YoungsterEVData,BugCatcherEVData,LassEVData,SailorEVData,JrTrainerMEVData
	dw JrTrainerFEVData,PokemaniacEVData,SuperNerdEVData,HikerEVData,BikerEVData
	dw BurglarEVData,EngineerEVData,Juggler1EVData,FisherEVData,SwimmerEVData
	dw CueBallEVData,GamblerEVData,BeautyEVData,PsychicEVData,RockerEVData
	dw JugglerEVData,TamerEVData,BirdKeeperEVData,BlackbeltEVData,Green1EVData
	dw ProfOakEVData,ChiefEVData,ScientistEVData,GiovanniEVData,RocketEVData
	dw CooltrainerMEVData,CooltrainerFEVData,BrunoEVData,BrockEVData,MistyEVData
	dw LtSurgeEVData,ErikaEVData,KogaEVData,BlaineEVData,SabrinaEVData
	dw GentlemanEVData,Green2EVData,Green3EVData,LoreleiEVData,ChannelerEVData
	dw AgathaEVData,LanceEVData

; byte is doubled for all EVs currently. in the future there'll be more of a variation.

YoungsterEVData:
; Route 3
	db 2
	db 2
; Mt. Moon 1F
	db 1
; Route 24
	db 1
; Route 25
	db 1
	db 1
	db 1
; SS Anne 1F Rooms
	db 1
; Route 11
	db 1
	db 1
	db 1
	db 1
; Unused
	db 1
BugCatcherEVData:
; Viridian Forest
	db 1
	db 1
	db 1
; Route 3
	db 2
	db 2
	db 2
; Mt. Moon 1F
	db 1
	db 1
; Route 24
	db 1
; Route 6
	db 1
	db 1
; Unused
	db 1
; Route 9
	db 1
	db 1
;Extra: Viridian Forest
	db 1
LassEVData:
; Route 3
	db 2
	db 2
	db 2
; Route 4
	db 1
; Mt. Moon 1F
	db 1
	db 1
; Route 24
	db 1
	db 1
; Route 25
	db 1
	db 1
; SS Anne 1F Rooms
	db 1
; SS Anne 2F Rooms
	db 1
; Route 8
	db 1
	db 1
	db 1
	db 1
; Celadon Gym
	db 1
	db 1
;Extra: Viridian Forest
	db 1
SailorEVData:
; SS Anne Stern
	db 1
	db 1
; SS Anne B1F Rooms
	db 1
	db 1
	db 1
	db 1
	db 1
; Vermilion Gym
	db 1
JrTrainerMEVData:
; Pewter Gym
	db 1
; Route 24/Route 25
	db 1
; Route 24
	db 1
; Route 6
	db 1
	db 1
; Unused
	db 1
; Route 9
	db 1
	db 1
; Route 12
	db 1
JrTrainerFEVData:
; Cerulean Gym
	db 1
; Route 6
	db 1
	db 1
; Unused
	db 1
; Route 9
	db 1
	db 1
; Route 10
	db 1
	db 1
; Rock Tunnel B1F
	db 1
	db 1
; Celadon Gym
	db 1
; Route 13
	db 1
	db 1
	db 1
	db 1
; Route 20
	db 1
; Rock Tunnel 1F
	db 1
	db 1
	db 1
; Route 15
	db 1
	db 1
	db 1
	db 1
; Route 20
	db 1
PokemaniacEVData:
; Route 10
	db 1
	db 1
; Rock Tunnel B1F
	db 1
	db 1
	db 1
; Victory Road 2F
	db 1
; Rock Tunnel 1F
	db 1
SuperNerdEVData:
; Mt. Moon 1F
	db 1
; Mt. Moon B2F
	db 1
; Route 8
	db 1
	db 1
	db 1
; Unused
	db 1
	db 1
	db 1
; Cinnabar Gym
	db 1
	db 1
	db 1
	db 1
HikerEVData:
; Mt. Moon 1F
	db 1
; Route 25
	db 1
	db 1
	db 1
; Route 9
	db 1
	db 1
; Route 10
	db 1
	db 1
; Rock Tunnel B1F
	db 1
	db 1
; Route 9/Rock Tunnel B1F
	db 1
; Rock Tunnel 1F
	db 1
	db 1
	db 1
BikerEVData:
; Route 13
	db 1
; Route 14
	db 1
; Route 15
	db 1
	db 1
; Route 16
	db 1
	db 1
	db 1
; Route 17
	db 1
	db 1
	db 1
	db 1
	db 1
; Route 14
	db 1
	db 1
	db 1
BurglarEVData:
; Unused
	db 1
	db 1
	db 1
; Cinnabar Gym
	db 1
	db 1
	db 1
; Mansion 2F
	db 1
; Mansion 3F
	db 1
; Mansion B1F
	db 1
EngineerEVData:
; Unused
	db 1
; Route 11
	db 1
	db 1
Juggler1EVData:
; none
FisherEVData:
; SS Anne 2F Rooms
	db 1
; SS Anne B1F Rooms
	db 1
; Route 12
	db 1
	db 1
	db 1
	db 1
; Route 21
	db 1
	db 1
	db 1
	db 1
; Route 12
	db 1
SwimmerEVData:
; Cerulean Gym
	db 1
; Route 19
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1
; Route 20
	db 1
	db 1
	db 1
; Route 21
	db 1
	db 1
	db 1
	db 1
CueBallEVData:
; Route 16
	db 1
	db 1
	db 1
; Route 17
	db 1
	db 1
	db 1
	db 1
	db 1
; Route 21
	db 1
GamblerEVData:
; Route 11
	db 1
	db 1
	db 1
	db 1
; Route 8
	db 1
; Unused
	db 1
; Route 8
	db 1
BeautyEVData:
; Celadon Gym
	db 1
	db 1
	db 1
; Route 13
	db 1
	db 1
; Route 20
	db 1
	db 1
	db 1
; Route 15
	db 1
	db 1
; Unused
	db 1
; Route 19
	db 1
	db 1
	db 1
; Route 20
	db 1
PsychicEVData:
; Saffron Gym
	db 1
	db 1
	db 1
	db 1
RockerEVData:
; Vermilion Gym
	db 1
; Route 12
	db 1
JugglerEVData:
; Silph Co. 5F
	db 1
; Victory Road 2F
	db 1
; Fucshia Gym
	db 1
	db 1
; Victory Road 2F
	db 1
; Unused
	db 1
; Fucshia Gym
	db 1
	db 1
TamerEVData:
; Fucshia Gym
	db 1
	db 1
; Viridian Gym
	db 1
	db 1
; Victory Road 2F
	db 1
; Unused
	db 1
BirdKeeperEVData:
; Route 13
	db 1
	db 1
	db 1
; Route 14
	db 1
	db 1
; Route 15
	db 1
	db 1
; Route 18
	db 1
	db 1
	db 1
; Route 20
	db 1
; Unused
	db 1
	db 1
; Route 14
	db 1
	db 1
	db 1
	db 1
BlackbeltEVData:
; Fighting Dojo
	db 1
	db 1
	db 1
	db 1
	db 1
; Viridian Gym
	db 1
	db 1
	db 1
; Victory Road 2F
	db 1
Green1EVData:
	db 1
	db 1
	db 1
; Route 22
	db 1
	db 1
	db 1
; Cerulean City
	db 1
	db 1
	db 1
ProfOakEVData:
; Unused
	db 1
	db 1
	db 1
ChiefEVData:
; none
ScientistEVData:
; Unused
	db 1
; Silph Co. 2F
	db 1
	db 1
; Silph Co. 3F/Mansion 1F
	db 1
; Silph Co. 4F
	db 1
; Silph Co. 5F
	db 1
; Silph Co. 6F
	db 1
; Silph Co. 7F
	db 1
; Silph Co. 8F
	db 1
; Silph Co. 9F
	db 1
; Silph Co. 10F
	db 1
; Mansion 3F
	db 1
; Mansion B1F
	db 1
GiovanniEVData:
; Rocket Hideout B4F
	db 1
; Silph Co. 11F
	db 1
; Viridian Gym
	db 1
RocketEVData:
; Mt. Moon B2F
	db 1
	db 1
	db 1
	db 1
; Cerulean City
	db 1
; Route 24
	db 1
; Game Corner
	db 1
; Rocket Hideout B1F
	db 1
	db 1
	db 1
	db 1
	db 1
; Rocket Hideout B2F
	db 1
; Rocket Hideout B3F
	db 1
	db 1
; Rocket Hideout B4F
	db 1
	db 1
	db 1
; Pokémon Tower 7F
	db 1
	db 1
	db 1
; Unused
	db 1
; Silph Co. 2F
	db 1
	db 1
; Silph Co. 3F
	db 1
; Silph Co. 4F
	db 1
	db 1
; Silph Co. 5F
	db 1
	db 1
; Silph Co. 6F
	db 1
	db 1
; Silph Co. 7F
	db 1
	db 1
	db 1
; Silph Co. 8F
	db 1
	db 1
; Silph Co. 9F
	db 1
	db 1
; Silph Co. 10F
	db 1
; Silph Co. 11F
	db 1
	db 1
CooltrainerMEVData:
; Viridian Gym
	db 1
; Victory Road 3F
	db 1
	db 1
; Unused
	db 1
; Victory Road 1F
	db 1
; Unused
	db 1
	db 1
	db 1
; Viridian Gym
	db 1
	db 1
CooltrainerFEVData:
; Celadon Gym
	db 1
; Victory Road 3F
	db 1
	db 1
; Unused
	db 1
; Victory Road 1F
	db 1
; Unused
	db 1
	db 1
	db 1
BrunoEVData: ; 3a3a9 (e:63a9)
	db 75 percent
BrockEVData: ; 3a3b5 (e:63b5)
	db 2
MistyEVData: ; 3a3bb (e:63bb)
	db 1
LtSurgeEVData: ; 3a3c1 (e:63c1)
	db 1
ErikaEVData: ; 3a3c9 (e:63c9)
	db 1
KogaEVData: ; 3a3d1 (e:63d1)
	db 1
BlaineEVData: ; 3a3db 1
	db 1
SabrinaEVData: ; 3a3e5 (e:63e5)
	db 1
GentlemanEVData: ; 3a3ef (e:63ef)
; SS Anne 1F Rooms
	db 1
	db 1
; SS Anne 2F Rooms/Vermilion Gym
	db 1
; Unused
	db 1
; SS Anne 2F Rooms
	db 1
Green2EVData: ; 3a401 (e:6401)
; SS Anne 2F
	db 1
	db 1
	db 1
; Pokémon Tower 2F
	db 1
	db 1
	db 1
; Silph Co. 7F
	db 1
	db 1
	db 1
; Route 22
	db 1
	db 1
	db 1
Green3EVData: ; 3a491 (e:6491)
	db 60 percent
	db 60 percent
	db 60 percent
LoreleiEVData: ; 3a4bb (e:64bb)
	db 50 percent
ChannelerEVData: ; 3a4c7 (e:64c7)
; Unused
	db 1
	db 1
	db 1
	db 1
; Pokémon Tower 3F
	db 1
	db 1
; Unused
	db 1
; Pokémon Tower 3F
	db 1
; Pokémon Tower 4F
	db 1
	db 1
; Unused
	db 1
; Pokémon Tower 4F
	db 1
; Unused
	db 1
; Pokémon Tower 5F
	db 1
; Unused
	db 1
; Pokémon Tower 5F
	db 1
	db 1
	db 1
; Pokémon Tower 6F
	db 1
	db 1
	db 1
; Saffron Gym
	db 1
	db 1
	db 1
AgathaEVData: ; 3a516 (e:6516)
	db 50 percent
LanceEVData: ; 3a522 (e:6522)
	db 55 percent
