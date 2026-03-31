extends Node2D

var controller: Node
var velocity = Vector2.ZERO
var damage = 8.0
var lifetime = 3.0
var collision_radius = 12.0
var pierce = 0
var split_count = 0
var _body: Polygon2D

func _ready() -> void:
    _body = Polygon2D.new()
    _body.color = Color("a7f3d0")
    _body.polygon = PackedVector2Array([
        Vector2(16, 0),
        Vector2(-10, -4),
        Vector2(-4, 0),
        Vector2(-10, 4),
    ])
    add_child(_body)

func configure(game_controller: Node, start_position: Vector2, direction: Vector2, projectile_damage: float, projectile_pierce: int, projectile_split: int) -> void:
    controller = game_controller
    global_position = start_position
    velocity = direction.normalized() * 720.0
    damage = projectile_damage
    pierce = projectile_pierce
    split_count = projectile_split
    rotation = velocity.angle()

func _process(delta: float) -> void:
    if controller == null or controller.is_battle_frozen():
        return

    lifetime -= delta
    if lifetime <= 0.0:
        queue_free()
        return

    global_position += velocity * delta
    if global_position.x < -120 or global_position.x > 1400:
        queue_free()
        return

    var enemies = controller.get_enemies_in_radius(global_position, collision_radius)
    if enemies.is_empty():
        return

    var enemy = enemies[0]
    enemy.take_damage(damage)
    if split_count > 0:
        controller.spawn_split_arrows(global_position, velocity.normalized(), damage * 0.55, split_count)

    if pierce <= 0:
        queue_free()
        return

    pierce -= 1
