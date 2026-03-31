extends Node2D

var controller: Node
var zone_radius = 48.0
var dps = 2.0
var duration = 2.5
var tick_timer = 0.0
var _body: Polygon2D

func _ready() -> void:
    _body = Polygon2D.new()
    _body.color = Color(1.0, 0.45, 0.15, 0.35)
    add_child(_body)

func configure(game_controller: Node, start_position: Vector2, radius_value: float, damage_per_second: float) -> void:
    controller = game_controller
    global_position = start_position
    zone_radius = radius_value
    dps = damage_per_second
    _body.polygon = PackedVector2Array([
        Vector2(-zone_radius, -zone_radius * 0.5),
        Vector2(zone_radius, -zone_radius * 0.5),
        Vector2(zone_radius * 0.8, zone_radius * 0.5),
        Vector2(-zone_radius * 0.8, zone_radius * 0.5),
    ])

func _process(delta: float) -> void:
    if controller == null or controller.is_battle_frozen():
        return

    duration -= delta
    tick_timer -= delta
    if tick_timer <= 0.0:
        tick_timer = 0.35
        controller.damage_enemies_in_radius(global_position, zone_radius, dps * 0.35)

    if duration <= 0.0:
        queue_free()
