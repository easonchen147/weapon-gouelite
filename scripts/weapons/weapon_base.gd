extends Node2D

const WeaponCatalogScript = preload("res://scripts/data/weapon_catalog.gd")

var controller: Node
var player: Node2D
var weapon_id = ""
var level = 0
var cooldown_timer = 0.0
var _catalog: RefCounted = WeaponCatalogScript.new()

func setup(game_controller: Node, owner_player: Node2D, id: String) -> void:
    controller = game_controller
    player = owner_player
    weapon_id = id

func set_level(new_level: int) -> void:
    level = new_level
    _on_level_changed()

func get_level_data() -> Dictionary:
    return _catalog.get_level_data(weapon_id, level)

func get_damage(base_scale: float) -> float:
    return float(controller.get_run_state().get_effective_stat("attack")) * base_scale

func get_bonus_stat(stat_key: String) -> Variant:
    return controller.get_run_state().get_snapshot().get("stats", {}).get(stat_key, 0)

func _process(delta: float) -> void:
    if controller == null or player == null or level <= 0:
        return
    if controller.is_battle_frozen():
        return

    cooldown_timer -= delta
    if cooldown_timer <= 0.0:
        _fire()
        cooldown_timer = _get_cooldown()

func _get_cooldown() -> float:
    var level_data: Dictionary = get_level_data()
    var attack_speed = max(float(controller.get_run_state().get_effective_stat("attack_speed")), 0.25)
    return float(level_data.get("cooldown", 1.0)) / attack_speed

func _fire() -> void:
    pass

func _on_level_changed() -> void:
    pass
