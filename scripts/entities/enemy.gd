extends Node2D

signal died(enemy: Node)

var controller: Node
var enemy_id = "grunt"
var display_name = ""
var current_health = 10.0
var max_health = 10.0
var damage = 4.0
var move_speed = 140.0
var collision_radius = 16.0
var attack_range = 40.0
var preferred_distance = 0.0
var attack_interval = 0.9
var attack_timer = 0.0
var xp_reward = 4
var is_boss = false
var tint = Color.WHITE
var _body: Polygon2D

func _ready() -> void:
    _ensure_visual()

func configure(game_controller: Node, type_id: String, definition: Dictionary, plan: Dictionary) -> void:
    controller = game_controller
    enemy_id = type_id
    display_name = str(definition.get("name", enemy_id))
    is_boss = bool(definition.get("is_boss", false))
    max_health = float(definition.get("health", 10.0)) * float(plan.get("enemy_health_scale", 1.0))
    current_health = max_health
    damage = float(definition.get("damage", 4.0)) * float(plan.get("enemy_damage_scale", 1.0))
    move_speed = float(definition.get("speed", 140.0))
    collision_radius = float(definition.get("radius", 16.0))
    xp_reward = int(definition.get("xp", 4))
    tint = definition.get("color", Color.WHITE)
    attack_range = collision_radius + controller.player.get_collision_radius() + (80.0 if enemy_id == "caster" else 12.0)
    preferred_distance = 180.0 if enemy_id == "caster" else 0.0
    attack_interval = 1.15 if is_boss else (1.35 if enemy_id == "caster" else 0.95)
    _ensure_visual()

func _process(delta: float) -> void:
    attack_timer = max(attack_timer - delta, 0.0)

    if controller == null or controller.is_battle_frozen():
        return

    var player: Node2D = controller.player
    var to_player = player.global_position - global_position
    var distance = to_player.length()

    if preferred_distance > 0.0 and distance < preferred_distance:
        global_position -= to_player.normalized() * move_speed * delta * 0.75
    elif distance > attack_range:
        global_position += to_player.normalized() * move_speed * delta
    elif attack_timer <= 0.0:
        player.take_damage(damage)
        attack_timer = attack_interval

func take_damage(amount: float) -> void:
    current_health = max(current_health - amount, 0.0)
    _body.modulate = Color.WHITE if current_health > 0.0 else Color(1, 1, 1, 0.35)
    if current_health <= 0.0:
        died.emit(self)
        queue_free()

func get_collision_radius() -> float:
    return collision_radius

func _ensure_visual() -> void:
    if _body == null:
        _body = Polygon2D.new()
        add_child(_body)

    _body.color = tint
    var radius = collision_radius
    _body.polygon = PackedVector2Array([
        Vector2(0, -radius),
        Vector2(radius, 0),
        Vector2(radius * 0.6, radius),
        Vector2(-radius * 0.6, radius),
        Vector2(-radius, 0),
    ])
