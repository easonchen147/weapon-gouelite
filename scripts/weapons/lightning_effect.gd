extends Node2D

var points: PackedVector2Array = PackedVector2Array()
var lifetime = 0.14

func configure(line_points: PackedVector2Array) -> void:
    points = line_points
    queue_redraw()

func _process(delta: float) -> void:
    lifetime -= delta
    if lifetime <= 0.0:
        queue_free()
        return
    modulate = Color(1.0, 0.98, 0.66, clamp(lifetime / 0.14, 0.0, 1.0))

func _draw() -> void:
    if points.size() < 2:
        return
    for index in points.size() - 1:
        draw_line(points[index], points[index + 1], Color("fde68a"), 6.0)
        draw_line(points[index], points[index + 1], Color("60a5fa"), 2.0)
