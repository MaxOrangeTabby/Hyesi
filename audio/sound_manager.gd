class_name SFX
extends Node


const POOL_SIZE : int = 12
const SFX_PATHS : Dictionary = {
	SFXType.TYPES.BEAM_BLAST : ["res://assets/sfx/beam_blast_v2.wav"],
	SFXType.TYPES.BEAM_CHARGE : ["res://assets/sfx/beam_charge_v1.mp3"],
	SFXType.TYPES.CELSPIKE_FIRE : ["res://assets/sfx/celspike_fire.wav"],
	SFXType.TYPES.CELSPIKE_RECHARGE : ["res://assets/sfx/celspike_recharge.mp3"],
	SFXType.TYPES.CONFIRM_INVENTORY : ["res://assets/sfx/confirm_inventory.wav"],
	SFXType.TYPES.ENEMY_HIT : ["res://assets/sfx/enemy_hit_edited.wav"],
	SFXType.TYPES.MC_RUN : ["res://assets/sfx/mc_run2.wav"],
	SFXType.TYPES.MC_SLASH : ["res://assets/sfx/mc_slash1.wav", "res://assets/sfx/mc_slash2.wav", "res://assets/sfx/mc_slash3.wav"]
}

static func play_2d(type : SFXType.TYPES, parent : Node, pitch : float = 1.0) -> AudioStreamPlayer2D:
	var p = AudioStreamPlayer2D.new()
	p.stream = load(SFX_PATHS[type].pick_random())
	p.bus = "SFX"
	p.pitch_scale = pitch
	p.autoplay = true
	p.finished.connect(p.queue_free)
	parent.add_child(p)
	return p

static func play_ui(type : SFXType.TYPES, parent : Node) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = load(SFX_PATHS[type].pick_random())
	p.bus ="SFX"
	p.autoplay =  true
	p.finished.connect(p.queue_free)
	parent.add_child(p)
	return p
