extends PanelContainer

signal restart_requested
signal menu_requested
signal revive_requested

var _summary_label: Label
var _feedback_label: Label
var _revive_button: Button

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false
    _build_ui()

func _build_ui() -> void:
    if get_child_count() > 0:
        return

    var margin = MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 28)
    margin.add_theme_constant_override("margin_top", 24)
    margin.add_theme_constant_override("margin_right", 28)
    margin.add_theme_constant_override("margin_bottom", 24)
    add_child(margin)

    var layout = VBoxContainer.new()
    layout.add_theme_constant_override("separation", 14)
    margin.add_child(layout)

    var title = Label.new()
    title.text = "Game Over"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 28)
    layout.add_child(title)

    _summary_label = Label.new()
    _summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    layout.add_child(_summary_label)

    _revive_button = Button.new()
    _revive_button.text = "看广告复活"
    _revive_button.custom_minimum_size = Vector2(300, 52)
    _revive_button.pressed.connect(func() -> void: revive_requested.emit())
    layout.add_child(_revive_button)

    var restart_button = Button.new()
    restart_button.text = "重新开始"
    restart_button.custom_minimum_size = Vector2(300, 52)
    restart_button.pressed.connect(func() -> void: restart_requested.emit())
    layout.add_child(restart_button)

    var menu_button = Button.new()
    menu_button.text = "返回开始页"
    menu_button.custom_minimum_size = Vector2(300, 52)
    menu_button.pressed.connect(func() -> void: menu_requested.emit())
    layout.add_child(menu_button)

    _feedback_label = Label.new()
    _feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _feedback_label.modulate = Color("f4c95d")
    layout.add_child(_feedback_label)

func show_results(snapshot: Dictionary, can_revive: bool) -> void:
    visible = true
    _feedback_label.text = ""
    _revive_button.disabled = not can_revive
    _summary_label.text = "到达层数：%d\n击杀数：%d\n武器：%s" % [
        int(snapshot.get("floor", 1)),
        int(snapshot.get("kills", 0)),
        _summarize_weapons(snapshot.get("weapon_levels", {})),
    ]

func hide_panel() -> void:
    visible = false

func set_feedback(message: String) -> void:
    _feedback_label.text = message

func _summarize_weapons(weapon_levels: Dictionary) -> String:
    var parts: Array[String] = []
    for weapon_id in weapon_levels.keys():
        var level = int(weapon_levels[weapon_id])
        if level > 0:
            parts.append("%s Lv.%d" % [weapon_id, level])
    if parts.is_empty():
        return "无"
    return ", ".join(parts)
