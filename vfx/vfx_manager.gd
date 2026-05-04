extends Node

const VFXAnimNames = {
	VFXType.TYPES.BLACK_FLASH : "black_flash",
	VFXType.TYPES.CASCADE : "cascade",
	VFXType.TYPES.WINDBLADE : "windblade"
}

@onready var vfx_player : PackedScene = preload("uid://0g5woiutr1wt")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("VFXManager _ready running")
	SignalBus.spawn_vfx.connect(play_anim)


func play_anim(vfx_type : VFXType.TYPES, target : Node2D) -> void:
	#print("in play anim vfx amanger")
	var vfx_player_inst : Node2D = vfx_player.instantiate()
	
	get_tree().current_scene.add_child(vfx_player_inst)
	vfx_player_inst.global_position = target.global_position + Vector2(0, -40)
	
	if vfx_type == VFXType.TYPES.HIT:
		vfx_player_inst.play_random_hit()
		return
	
	if not VFXAnimNames.has(vfx_type):
		push_warning("Vfx manager no animation mapped for vfx type")
		return
	
	var anim_name = VFXAnimNames[vfx_type]
	if vfx_player_inst:
		vfx_player_inst.play_animation(anim_name)
	else:
		print("VFX manager: vfx player instance null")
