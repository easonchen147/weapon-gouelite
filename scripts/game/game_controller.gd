extends Node2D

const PlayerScene = preload("res://scenes/entities/player.tscn")
const EnemyScene = preload("res://scenes/entities/enemy.tscn")
const UpgradePanelScene = preload("res://scenes/ui/upgrade_panel.tscn")
const GameOverPanelScene = preload("res://scenes/ui/game_over_panel.tscn")
const FlameZoneScript = preload("res://scripts/weapons/flame_zone.gd")
const EnemySpawnerScript = preload("res://scripts/game/enemy_spawner.gd")
const UpgradeCatalogScript = preload("res://scripts/data/upgrade_catalog.gd")

var player: Node
var _save_manager: Node
var _run_state: Node
var _ad_service: Node
var _spawner: RefCounted = EnemySpawnerScript.new()
var _upgrade_catalog: RefCounted = UpgradeCatalogScript.new()
var _rng = RandomNumberGenerator.new()
var _battle_frozen = false
var _pending_level_ups = 0
var _revive_used = false
var _run_results_saved = false
var _current_plan: Dictionary = {}
var _floor_timer = 0.0
var _spawn_timer = 0.0
var _remaining_budget = 0
var _boss_spawned = false
var _world_width = 1280.0
var _ground_y = 560.0
var _enemy_container: Node2D
var _projectile_container: Node2D
var _effect_container: Node2D
var _hud_layer: CanvasLayer
var _hp_bar: ProgressBar
var _xp_bar: ProgressBar
var _floor_label: Label
var _status_label: Label
var _upgrade_panel: Control
var _game_over_panel: Control

func _ready() -> void:
    _save_manager = get_node("/root/SaveManager")
    _run_state = get_node("/root/RunState")
    _ad_service = get_node("/root/AdService")
    _rng.randomize()
    _build_world()
    _start_new_run()

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("restart_run"):
        get_tree().reload_current_scene()
        return

    if _battle_frozen:
        _update_hud()
        return

    _update_floor_progress(delta)
    _update_hud()

    if _pending_level_ups > 0 and not _upgrade_panel.visible:
        _show_next_upgrade()

func is_battle_frozen() -> bool:
    return _battle_frozen

func get_run_state() -> Node:
    return _run_state

func get_enemy_nodes() -> Array:
    var enemies: Array = []
    for child in _enemy_container.get_children():
        if is_instance_valid(child):
            enemies.append(child)
    return enemies

func get_enemies_in_radius(center: Vector2, radius: float) -> Array:
    var matches: Array = []
    for enemy in get_enemy_nodes():
        var total_radius = radius + enemy.get_collision_radius()
        if enemy.global_position.distance_to(center) <= total_radius:
            matches.append(enemy)

    matches.sort_custom(func(a: Node, b: Node) -> bool:
        return a.global_position.distance_squared_to(center) < b.global_position.distance_squared_to(center)
    )
    return matches

func find_nearest_enemy(center: Vector2, exclude_ids: Array = []) -> Node:
    var best_enemy: Node = null
    var best_distance = INF
    for enemy in get_enemy_nodes():
        if exclude_ids.has(enemy.get_instance_id()):
            continue
        var distance = enemy.global_position.distance_squared_to(center)
        if distance < best_distance:
            best_distance = distance
            best_enemy = enemy
    return best_enemy

func damage_enemies_in_radius(center: Vector2, radius: float, amount: float) -> void:
    for enemy in get_enemies_in_radius(center, radius):
        enemy.take_damage(amount)

func chain_lightning(start_enemy: Node, chain_targets: int, base_damage: float) -> PackedVector2Array:
    var points = PackedVector2Array([player.global_position, start_enemy.global_position])
    var exclude_ids = [start_enemy.get_instance_id()]
    start_enemy.take_damage(base_damage)
    var current_enemy = start_enemy
    var damage_scale = 0.85

    for _step in chain_targets:
        var next_enemy = find_nearest_enemy(current_enemy.global_position, exclude_ids)
        if next_enemy == null:
            break
        points.append(next_enemy.global_position)
        next_enemy.take_damage(base_damage * damage_scale)
        damage_scale *= 0.85
        exclude_ids.append(next_enemy.get_instance_id())
        current_enemy = next_enemy

    return points

func add_projectile(node: Node) -> void:
    _projectile_container.add_child(node)

func add_effect(node: Node) -> void:
    _effect_container.add_child(node)

func spawn_flame_zone(position: Vector2, radius: float, damage_per_second: float) -> void:
    var zone = FlameZoneScript.new()
    zone.configure(self, position, radius, damage_per_second)
    add_effect(zone)

func spawn_split_arrows(position: Vector2, base_direction: Vector2, damage: float, split_count: int) -> void:
    if split_count <= 0:
        return

    var ArrowProjectileScene = preload("res://scenes/weapons/arrow_projectile.tscn")
    for index in 2:
        var arrow = ArrowProjectileScene.instantiate()
        var offset = -0.35 if index == 0 else 0.35
        arrow.configure(self, position, base_direction.rotated(offset), damage, 0, max(split_count - 1, 0))
        add_projectile(arrow)

func _build_world() -> void:
    if get_child_count() > 0:
        return

    var background = Polygon2D.new()
    background.color = Color("0b1220")
    background.polygon = PackedVector2Array([
        Vector2(0, 0),
        Vector2(1280, 0),
        Vector2(1280, 720),
        Vector2(0, 720),
    ])
    add_child(background)

    var skyline = Polygon2D.new()
    skyline.color = Color("182537")
    skyline.polygon = PackedVector2Array([
        Vector2(0, 80),
        Vector2(240, 120),
        Vector2(440, 70),
        Vector2(740, 130),
        Vector2(980, 90),
        Vector2(1280, 150),
        Vector2(1280, 360),
        Vector2(0, 360),
    ])
    add_child(skyline)

    var ground = Polygon2D.new()
    ground.color = Color("23384f")
    ground.polygon = PackedVector2Array([
        Vector2(0, _ground_y + 46),
        Vector2(1280, _ground_y + 46),
        Vector2(1280, 720),
        Vector2(0, 720),
    ])
    add_child(ground)

    _enemy_container = Node2D.new()
    add_child(_enemy_container)

    _projectile_container = Node2D.new()
    add_child(_projectile_container)

    _effect_container = Node2D.new()
    add_child(_effect_container)

    player = PlayerScene.instantiate()
    add_child(player)
    player.died.connect(_on_player_died)
    player.health_changed.connect(_on_player_health_changed)

    _build_hud()

func _build_hud() -> void:
    _hud_layer = CanvasLayer.new()
    add_child(_hud_layer)

    var hud = Control.new()
    hud.anchor_right = 1.0
    hud.anchor_bottom = 1.0
    _hud_layer.add_child(hud)

    _hp_bar = ProgressBar.new()
    _hp_bar.position = Vector2(24, 22)
    _hp_bar.custom_minimum_size = Vector2(280, 24)
    _hp_bar.max_value = 100.0
    hud.add_child(_hp_bar)

    _xp_bar = ProgressBar.new()
    _xp_bar.position = Vector2(24, 54)
    _xp_bar.custom_minimum_size = Vector2(280, 18)
    _xp_bar.max_value = 100.0
    hud.add_child(_xp_bar)

    _floor_label = Label.new()
    _floor_label.position = Vector2(24, 82)
    _floor_label.add_theme_font_size_override("font_size", 22)
    hud.add_child(_floor_label)

    _status_label = Label.new()
    _status_label.position = Vector2(24, 112)
    _status_label.modulate = Color("d5dee8")
    hud.add_child(_status_label)

    _upgrade_panel = UpgradePanelScene.instantiate()
    _upgrade_panel.anchor_left = 0.5
    _upgrade_panel.anchor_top = 0.5
    _upgrade_panel.anchor_right = 0.5
    _upgrade_panel.anchor_bottom = 0.5
    _upgrade_panel.offset_left = -220
    _upgrade_panel.offset_top = -180
    _upgrade_panel.offset_right = 220
    _upgrade_panel.offset_bottom = 180
    _upgrade_panel.upgrade_selected.connect(_on_upgrade_selected)
    hud.add_child(_upgrade_panel)

    _game_over_panel = GameOverPanelScene.instantiate()
    _game_over_panel.anchor_left = 0.5
    _game_over_panel.anchor_top = 0.5
    _game_over_panel.anchor_right = 0.5
    _game_over_panel.anchor_bottom = 0.5
    _game_over_panel.offset_left = -220
    _game_over_panel.offset_top = -190
    _game_over_panel.offset_right = 220
    _game_over_panel.offset_bottom = 190
    _game_over_panel.restart_requested.connect(func() -> void: get_tree().reload_current_scene())
    _game_over_panel.menu_requested.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
    _game_over_panel.revive_requested.connect(_on_revive_requested)
    hud.add_child(_game_over_panel)

func _start_new_run() -> void:
    _battle_frozen = false
    _pending_level_ups = 0
    _revive_used = false
    _run_results_saved = false
    _clear_container(_enemy_container)
    _clear_container(_projectile_container)
    _clear_container(_effect_container)
    _upgrade_panel.hide_panel()
    _game_over_panel.hide_panel()
    _run_state.start_new_run(_save_manager.load_save_data())
    player.configure(self, _run_state.get_snapshot())
    player.global_position = Vector2(_world_width * 0.5, _ground_y)
    _begin_floor(1)

func _begin_floor(floor: int) -> void:
    _current_plan = _spawner.build_floor_plan(floor)
    _floor_timer = float(_current_plan.get("duration", 20.0))
    _spawn_timer = 0.1
    _remaining_budget = int(_current_plan.get("enemy_budget", 0))
    _boss_spawned = false
    _status_label.text = "Build 加载中..."

func _update_floor_progress(delta: float) -> void:
    var floor = int(_run_state.get_snapshot().get("floor", 1))
    if bool(_current_plan.get("is_boss_floor", false)):
        if not _boss_spawned:
            _spawn_boss()
            _boss_spawned = true

        if get_enemy_nodes().is_empty():
            _advance_floor()
        return

    _floor_timer = max(_floor_timer - delta, 0.0)
    _spawn_timer -= delta

    if _spawn_timer <= 0.0 and _remaining_budget > 0:
        _spawn_timer = float(_current_plan.get("spawn_interval", 1.0))
        _remaining_budget -= 1
        _spawn_enemy(_spawner.pick_enemy_id(_current_plan, _rng))

    if floor >= 4 and _floor_timer > 0.0 and _rng.randf() < delta * 0.08:
        _spawn_enemy("caster")

    if _floor_timer <= 0.0 and _remaining_budget <= 0 and get_enemy_nodes().is_empty():
        _advance_floor()

func _advance_floor() -> void:
    _run_state.advance_floor()
    _begin_floor(int(_run_state.get_snapshot().get("floor", 1)))

func _spawn_boss() -> void:
    var boss_id = str(_current_plan.get("boss_id", "boss_titan"))
    var boss = EnemyScene.instantiate()
    _enemy_container.add_child(boss)
    boss.global_position = Vector2(_world_width - 160, _ground_y)
    boss.configure(self, boss_id, _spawner.get_enemy_definition(boss_id), _current_plan)
    boss.died.connect(_on_enemy_died)

func _spawn_enemy(enemy_id: String) -> void:
    var definition: Dictionary = _spawner.get_enemy_definition(enemy_id)
    if definition.is_empty():
        return

    var enemy = EnemyScene.instantiate()
    _enemy_container.add_child(enemy)
    var side = -60.0 if _rng.randf() < 0.5 else _world_width + 60.0
    enemy.global_position = Vector2(side, _ground_y)
    enemy.configure(self, enemy_id, definition, _current_plan)
    enemy.died.connect(_on_enemy_died)

func _show_next_upgrade() -> void:
    var choices: Array = _upgrade_catalog.roll_choices(_run_state.get_snapshot(), 3, _rng)
    if choices.is_empty():
        _battle_frozen = false
        _pending_level_ups = 0
        return

    _battle_frozen = true
    _upgrade_panel.show_choices(choices)

func _on_upgrade_selected(choice: Dictionary) -> void:
    _upgrade_panel.hide_panel()
    _run_state.apply_upgrade(choice)
    player.sync_from_snapshot(_run_state.get_snapshot(), false)
    _pending_level_ups = max(_pending_level_ups - 1, 0)
    _battle_frozen = false

func _on_enemy_died(enemy: Node) -> void:
    _run_state.add_kill()
    _pending_level_ups += _run_state.add_experience(int(enemy.xp_reward))

func _on_player_health_changed(current: float, maximum: float) -> void:
    _hp_bar.max_value = maximum
    _hp_bar.value = current

func _on_player_died() -> void:
    _battle_frozen = true
    _save_run_results_if_needed()
    _game_over_panel.show_results(_run_state.get_snapshot(), not _revive_used)

func _on_revive_requested() -> void:
    if _revive_used:
        return
    var result: Dictionary = _ad_service.show_rewarded_ad("revive")
    if str(result.get("status", "")) != "granted":
        _game_over_panel.set_feedback(str(result.get("message", "当前无法复活")))
        return
    _revive_used = true
    _battle_frozen = false
    player.heal_ratio(0.5)
    _game_over_panel.hide_panel()

func _save_run_results_if_needed() -> void:
    if _run_results_saved:
        return
    var snapshot: Dictionary = _run_state.get_snapshot()
    var reward = int(max(1.0, float(int(snapshot.get("floor", 1)) * 3) + float(int(snapshot.get("kills", 0))) / 8.0))
    _save_manager.apply_run_results(int(snapshot.get("floor", 1)), reward)
    _run_results_saved = true

func _update_hud() -> void:
    var snapshot: Dictionary = _run_state.get_snapshot()
    _floor_label.text = "Floor %d  Lv.%d" % [int(snapshot.get("floor", 1)), int(snapshot.get("level", 1))]
    _hp_bar.max_value = float(snapshot.get("stats", {}).get("max_health", 100))
    _xp_bar.max_value = float(snapshot.get("experience_to_next", 20))
    _xp_bar.value = float(snapshot.get("experience", 0))
    _status_label.text = "敌人数：%d    击杀：%d    剩余生成：%d" % [
        get_enemy_nodes().size(),
        int(snapshot.get("kills", 0)),
        _remaining_budget,
    ]

func _clear_container(node: Node) -> void:
    for child in node.get_children():
        child.queue_free()
