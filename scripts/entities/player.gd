extends Node2D

signal died
signal health_changed(current: float, maximum: float)

const BoomerangSwordScript = preload("res://scripts/weapons/boomerang_sword.gd")
const SplitBowScript = preload("res://scripts/weapons/split_bow.gd")
const FlameStaffScript = preload("res://scripts/weapons/flame_staff.gd")
const ThunderHammerScript = preload("res://scripts/weapons/thunder_hammer.gd")

var controller: Node
var move_bounds = Vector2(120.0, 1160.0)
var move_speed = 420.0
var current_health = 100.0
var max_health = 100.0
var collision_radius = 24.0
var invulnerable_timer = 0.0
var _body: Polygon2D
var _shadow: Polygon2D
var _weapon_nodes = {}

func _ready() -> void:
    _ensure_visuals()

func _process(delta: float) -> void:
    invulnerable_timer = max(invulnerable_timer - delta, 0.0)

    if controller != null and controller.has_method("is_battle_frozen") and controller.is_battle_frozen():
        return

    var direction = Input.get_axis("move_left", "move_right")
    global_position.x = clamp(global_position.x + direction * move_speed * delta, move_bounds.x, move_bounds.y)
    _body.modulate = Color.WHITE if invulnerable_timer <= 0.0 else Color("ffb1a1")

func configure(game_controller: Node, snapshot: Dictionary) -> void:
    controller = game_controller
    if global_position == Vector2.ZERO:
        global_position = Vector2(640, 520)
    sync_from_snapshot(snapshot, false)

func sync_from_snapshot(snapshot: Dictionary, keep_ratio: bool = false) -> void:
    var previous_ratio = 1.0
    if max_health > 0.0:
        previous_ratio = current_health / max_health

    max_health = float(snapshot.get("stats", {}).get("max_health", 100))
    move_speed = float(controller.get_run_state().get_effective_stat("move_speed"))
    if keep_ratio:
        current_health = clamp(max_health * previous_ratio, 1.0, max_health)
    else:
        current_health = min(max(current_health, max_health), max_health)

    health_changed.emit(current_health, max_health)
    _sync_weapons(snapshot.get("weapon_levels", {}))

func take_damage(amount: float) -> void:
    if invulnerable_timer > 0.0:
        return

    current_health = max(current_health - amount, 0.0)
    invulnerable_timer = 0.45
    health_changed.emit(current_health, max_health)

    if current_health <= 0.0:
        died.emit()

func heal_ratio(ratio: float) -> void:
    current_health = clamp(max_health * ratio, 1.0, max_health)
    health_changed.emit(current_health, max_health)

func get_collision_radius() -> float:
    return collision_radius

func _sync_weapons(weapon_levels: Dictionary) -> void:
    for weapon_id in weapon_levels.keys():
        var level = int(weapon_levels[weapon_id])
        if level <= 0:
            continue

        if not _weapon_nodes.has(weapon_id):
            var weapon = _create_weapon_node(weapon_id)
            if weapon == null:
                continue
            add_child(weapon)
            weapon.setup(controller, self, weapon_id)
            _weapon_nodes[weapon_id] = weapon

        _weapon_nodes[weapon_id].set_level(level)

func _create_weapon_node(weapon_id: String) -> Node2D:
    match weapon_id:
        "boomerang_sword":
            return BoomerangSwordScript.new()
        "split_bow":
            return SplitBowScript.new()
        "flame_staff":
            return FlameStaffScript.new()
        "thunder_hammer":
            return ThunderHammerScript.new()
        _:
            return null

func _ensure_visuals() -> void:
    if _shadow != null:
        return

    _shadow = Polygon2D.new()
    _shadow.color = Color(0, 0, 0, 0.28)
    _shadow.polygon = PackedVector2Array([
        Vector2(-18, 20),
        Vector2(18, 20),
        Vector2(24, 30),
        Vector2(-24, 30),
    ])
    add_child(_shadow)

    _body = Polygon2D.new()
    _body.color = Color("6ee7f2")
    _body.polygon = PackedVector2Array([
        Vector2(0, -28),
        Vector2(22, -8),
        Vector2(16, 22),
        Vector2(-16, 22),
        Vector2(-22, -8),
    ])
    add_child(_body)
