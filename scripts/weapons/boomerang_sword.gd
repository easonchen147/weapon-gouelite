extends "res://scripts/weapons/weapon_base.gd"

var _blade_nodes: Array[Polygon2D] = []
var _angle = 0.0
var _hit_cooldowns = {}

func _ready() -> void:
    set_process(true)

func _process(delta: float) -> void:
    if controller == null or player == null or level <= 0:
        return
    if controller.is_battle_frozen():
        return

    _angle += delta * (2.8 + level * 0.45)
    var level_data: Dictionary = get_level_data()
    var count = int(level_data.get("projectiles", 1))
    var base_radius = float(level_data.get("radius", 92.0)) * (1.0 + float(get_bonus_stat("range_bonus")))

    for index in _blade_nodes.size():
        var blade: Polygon2D = _blade_nodes[index]
        if index >= count:
            blade.visible = false
            continue

        blade.visible = true
        var angle = _angle + TAU * (float(index) / max(count, 1))
        blade.position = Vector2(cos(angle), sin(angle)) * base_radius

    for enemy in controller.get_enemy_nodes():
        if not is_instance_valid(enemy):
            continue
        var enemy_id = enemy.get_instance_id()
        var remaining = float(_hit_cooldowns.get(enemy_id, 0.0))
        remaining = max(remaining - delta, 0.0)
        _hit_cooldowns[enemy_id] = remaining

        if remaining > 0.0:
            continue

        for blade in _blade_nodes:
            if not blade.visible:
                continue
            var hit_radius = enemy.get_collision_radius() + 18.0
            if enemy.global_position.distance_to(player.global_position + blade.position) <= hit_radius:
                enemy.take_damage(get_damage(float(level_data.get("damage_scale", 1.0)) * 0.22))
                _hit_cooldowns[enemy_id] = 0.22
                break

func _on_level_changed() -> void:
    var level_data: Dictionary = get_level_data()
    var target_count = int(level_data.get("projectiles", 1))
    while _blade_nodes.size() < max(target_count, 4):
        var blade = Polygon2D.new()
        blade.color = Color("fde68a")
        blade.polygon = PackedVector2Array([
            Vector2(0, -16),
            Vector2(8, 0),
            Vector2(0, 16),
            Vector2(-8, 0),
        ])
        add_child(blade)
        _blade_nodes.append(blade)

func _fire() -> void:
    pass
