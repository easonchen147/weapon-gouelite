extends "res://scripts/weapons/weapon_base.gd"

const FireOrbScene = preload("res://scenes/weapons/fire_orb.tscn")

func _fire() -> void:
    var target = controller.find_nearest_enemy(player.global_position)
    if target == null:
        return

    var level_data: Dictionary = get_level_data()
    var orb = FireOrbScene.instantiate()
    orb.configure(
        controller,
        player.global_position + Vector2(0, -8),
        target.global_position - player.global_position,
        get_damage(float(level_data.get("damage_scale", 1.0))),
        float(level_data.get("blast_radius", 48.0)) * (1.0 + float(get_bonus_stat("range_bonus"))),
        float(level_data.get("burn_scale", 0.2))
    )
    controller.add_projectile(orb)
