extends Node

signal item_slot_clicked(item_clicked : Item)
signal item_equipped(item_equipped : Item)
signal item_collected(item_collected : Item)
signal stats_updated()

signal arena_entered(arena_num : int)
signal arena_finished(arena_num : int)

# augment specific
signal augment_selected(augment_selected : Augment)
signal augment_confirm(augment_selected : Augment)
signal augment_keep(augment_selected : Augment)

# player specific
signal player_die
signal player_hp_changed(current_hp : float, max_hp : float)
signal player_damaged

signal player_heal(heal_amount : float)

signal spawn_windblade

signal punch_camera(zoom_scale : float, strengh : float)
signal trigger_camera_shake(strengh : float)
signal trigger_cont_camera_shake(strength : float)
signal stop_cont_camera_shake(strength : float, dir : Vector2)

# enemy specific
signal register_boss_hp(max_boss_hp : float, curr_boss_hp : float, boss_node, CharacterBody2D)
signal boss_health_changed(new_hp : float)
signal enemy_damaged(enemy : Enemy)
signal boss_fight_lost(arena_num : int)

# vfx
signal spawn_vfx(vfx_type : VFXType.TYPES, target : Node2D)

# time slow - connected to game manager
signal req_time_slow(scale : float, duration : float)
signal reset_time_slow() # brings it back to 1.0
signal start_time_slow(scale : float) # tween to the given time slow
