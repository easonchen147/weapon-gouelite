extends Control

const GAME_SCENE_PATH = "res://scenes/game/game_scene.tscn"

var _save_manager: Node
var _ad_service: Node
var _title_label: Label
var _summary_label: Label
var _attack_button: Button
var _health_button: Button
var _feedback_label: Label

func _ready() -> void:
    _save_manager = get_node("/root/SaveManager")
    _ad_service = get_node("/root/AdService")
    _build_ui()
    _refresh()

func _build_ui() -> void:
    if get_child_count() > 0:
        return

    var background = ColorRect.new()
    background.anchor_right = 1.0
    background.anchor_bottom = 1.0
    background.color = Color("0d1117")
    add_child(background)

    var accent = ColorRect.new()
    accent.anchor_right = 1.0
    accent.anchor_bottom = 0.42
    accent.color = Color("1c2836")
    add_child(accent)

    var shell = MarginContainer.new()
    shell.anchor_left = 0.15
    shell.anchor_top = 0.08
    shell.anchor_right = 0.85
    shell.anchor_bottom = 0.92
    shell.add_theme_constant_override("margin_left", 24)
    shell.add_theme_constant_override("margin_top", 24)
    shell.add_theme_constant_override("margin_right", 24)
    shell.add_theme_constant_override("margin_bottom", 24)
    add_child(shell)

    var layout = VBoxContainer.new()
    layout.alignment = BoxContainer.ALIGNMENT_CENTER
    layout.add_theme_constant_override("separation", 16)
    shell.add_child(layout)

    _title_label = Label.new()
    _title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _title_label.text = "WEAPON GOUELITE"
    _title_label.add_theme_font_size_override("font_size", 36)
    layout.add_child(_title_label)

    var subtitle = Label.new()
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.text = "极简横版武器进化爬塔 Roguelite"
    subtitle.modulate = Color("c9d5e3")
    layout.add_child(subtitle)

    _summary_label = Label.new()
    _summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _summary_label.custom_minimum_size = Vector2(620, 100)
    layout.add_child(_summary_label)

    var start_button = Button.new()
    start_button.text = "开始爬塔"
    start_button.custom_minimum_size = Vector2(280, 56)
    start_button.pressed.connect(_on_start_pressed)
    layout.add_child(start_button)

    var upgrade_row = HBoxContainer.new()
    upgrade_row.alignment = BoxContainer.ALIGNMENT_CENTER
    upgrade_row.add_theme_constant_override("separation", 18)
    layout.add_child(upgrade_row)

    _attack_button = Button.new()
    _attack_button.custom_minimum_size = Vector2(220, 52)
    _attack_button.pressed.connect(func() -> void: _on_purchase_upgrade("attack"))
    upgrade_row.add_child(_attack_button)

    _health_button = Button.new()
    _health_button.custom_minimum_size = Vector2(220, 52)
    _health_button.pressed.connect(func() -> void: _on_purchase_upgrade("health"))
    upgrade_row.add_child(_health_button)

    var ad_button = Button.new()
    ad_button.text = "广告结构预留"
    ad_button.custom_minimum_size = Vector2(220, 52)
    ad_button.pressed.connect(_on_ad_button_pressed)
    layout.add_child(ad_button)

    _feedback_label = Label.new()
    _feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _feedback_label.modulate = Color("f4c95d")
    layout.add_child(_feedback_label)

    var hint_label = Label.new()
    hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint_label.modulate = Color("91a2b7")
    hint_label.text = "操作：A / D 左右移动。战斗中自动攻击，R 可快速重开。"
    layout.add_child(hint_label)

func _refresh() -> void:
    var data: Dictionary = _save_manager.load_save_data()
    _summary_label.text = "最高层：%d    余烬精华：%d\n攻击升级 Lv.%d    生命升级 Lv.%d" % [
        int(data["highest_floor"]),
        int(data["essence"]),
        int(data["meta_upgrades"]["attack"]),
        int(data["meta_upgrades"]["health"]),
    ]

    _attack_button.text = "升级攻击 (%d)" % _save_manager.get_upgrade_cost("attack", int(data["meta_upgrades"]["attack"]))
    _health_button.text = "升级生命 (%d)" % _save_manager.get_upgrade_cost("health", int(data["meta_upgrades"]["health"]))

func _on_start_pressed() -> void:
    get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_purchase_upgrade(upgrade_id: String) -> void:
    if _save_manager.purchase_meta_upgrade(upgrade_id):
        _feedback_label.text = "升级成功：%s" % ("攻击" if upgrade_id == "attack" else "生命")
        _refresh()
        return

    _feedback_label.text = "精华不足，继续爬塔获取更多奖励。"

func _on_ad_button_pressed() -> void:
    var result: Dictionary = _ad_service.show_rewarded_ad("menu_bonus")
    _feedback_label.text = str(result.get("message", "广告未准备好"))
