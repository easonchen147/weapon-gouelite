extends "res://scripts/weapons/weapon_base.gd"

const LightningEffectScene = preload("res://scenes/weapons/lightning_effect.tscn")

func _fire() -> void:
    var start_enemy = controller.find_nearest_enemy(player.global_position)
    if start_enemy == null:
        return

    var level_data: Dictionary = get_level_data()
    var chain_targets = int(level_data.get("chain_count", 1)) + int(get_bonus_stat("chain_bonus"))
    var points = controller.chain_lightning(start_enemy, chain_targets, get_damage(float(level_data.get("damage_scale", 1.0))))

    if points.size() >= 2:
        var effect = LightningEffectScene.instantiate()
        effect.global_position = Vector2.ZERO
        effect.configure(points)
        controller.add_effect(effect)
