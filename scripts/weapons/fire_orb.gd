extends Node2D

var controller: Node
var velocity = Vector2.ZERO
var damage = 10.0
var blast_radius = 52.0
var burn_scale = 0.2
var lifetime = 2.2
var _body: Polygon2D

func _ready() -> void:
    _body = Polygon2D.new()
    _body.color = Color("fb923c")
    _body.polygon = PackedVector2Array([
        Vector2(0, -12),
        Vector2(10, -2),
        Vector2(8, 10),
        Vector2(-8, 10),
        Vector2(-10, -2),
    ])
    add_child(_body)

func configure(game_controller: Node, start_position: Vector2, direction: Vector2, projectile_damage: float, projectile_radius: float, projectile_burn_scale: float) -> void:
    controller = game_controller
    global_position = start_position
    velocity = direction.normalized() * 540.0
    damage = projectile_damage
    blast_radius = projectile_radius
    burn_scale = projectile_burn_scale

func _process(delta: float) -> void:
    if controller == null or controller.is_battle_frozen():
        return

    lifetime -= delta
    if lifetime <= 0.0:
        _explode()
        return

    global_position += velocity * delta
    var enemies = controller.get_enemies_in_radius(global_position, 16.0)
    if not enemies.is_empty():
        _explode()

func _explode() -> void:
    if controller == null:
        queue_free()
        return

    controller.damage_enemies_in_radius(global_position, blast_radius, damage)
    controller.spawn_flame_zone(global_position, blast_radius * 0.75, damage * burn_scale)
    queue_free()
