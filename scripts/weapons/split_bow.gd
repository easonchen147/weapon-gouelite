extends "res://scripts/weapons/weapon_base.gd"

const ArrowProjectileScene = preload("res://scenes/weapons/arrow_projectile.tscn")

func _fire() -> void:
    var target = controller.find_nearest_enemy(player.global_position)
    if target == null:
        return

    var level_data: Dictionary = get_level_data()
    var projectile_count = int(level_data.get("projectiles", 1))
    var split_bonus = int(get_bonus_stat("split_bonus"))
    var spread = 0.18 if projectile_count > 1 else 0.0
    var base_direction = (target.global_position - player.global_position).normalized()

    for index in projectile_count:
        var arrow = ArrowProjectileScene.instantiate()
        var angle_offset = (float(index) - float(projectile_count - 1) / 2.0) * spread
        var direction = base_direction.rotated(angle_offset)
        arrow.configure(
            controller,
            player.global_position + Vector2(0, -10),
            direction,
            get_damage(float(level_data.get("damage_scale", 1.0))),
            0,
            int(level_data.get("split_count", 0)) + split_bonus
        )
        controller.add_projectile(arrow)
