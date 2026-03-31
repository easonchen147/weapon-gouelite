extends PanelContainer

signal upgrade_selected(choice: Dictionary)

var _title_label: Label
var _buttons: Array[Button] = []
var _current_choices: Array = []

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false
    size_flags_horizontal = Control.SIZE_EXPAND_FILL
    size_flags_vertical = Control.SIZE_EXPAND_FILL
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

    _title_label = Label.new()
    _title_label.text = "升级，三选一"
    _title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    _title_label.add_theme_font_size_override("font_size", 24)
    layout.add_child(_title_label)

    for index in 3:
        var button = Button.new()
        button.custom_minimum_size = Vector2(360, 76)
        button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        button.pressed.connect(func() -> void: _on_choice_pressed(index))
        layout.add_child(button)
        _buttons.append(button)

func show_choices(choices: Array) -> void:
    _current_choices = choices
    visible = true
    for index in _buttons.size():
        var button: Button = _buttons[index]
        if index < choices.size():
            var choice: Dictionary = choices[index]
            button.visible = true
            button.disabled = false
            button.text = "%s\n%s" % [choice.get("name", "未知强化"), choice.get("description", "")]
        else:
            button.visible = false

func hide_panel() -> void:
    visible = false

func _on_choice_pressed(index: int) -> void:
    if index >= _current_choices.size():
        return
    upgrade_selected.emit(_current_choices[index])
