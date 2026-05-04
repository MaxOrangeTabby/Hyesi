class_name BaseEnemyStats
extends Resource


@export var hp : float  = 1234100.0
@export var def : float = 0.0
@export var dmg_reduction : float = 0.0
@export var invincible : bool = false
@export var speed : float = 600.0
@export var acceleration : float = 400.0

# cut down regen rate when in combat
# hp is out of 100
@export var regen_enabled : bool =  true
@export var regen_rate : float = 1.5

# how many HP points cut down
@export var attack_dmg : float = 1
