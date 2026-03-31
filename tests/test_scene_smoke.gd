extends RefCounted

const REQUIRED_SCENES = [
    "res://scenes/main_menu.tscn",
    "res://scenes/game/game_scene.tscn",
    "res://scenes/ui/upgrade_panel.tscn",
    "res://scenes/ui/game_over_panel.tscn",
]

func run() -> Array[String]:
    var failures: Array[String] = []

    for scene_path in REQUIRED_SCENES:
        if not ResourceLoader.exists(scene_path):
            failures.append("%s should exist" % scene_path)
            continue

        var packed_scene = load(scene_path)
        if packed_scene == null or not (packed_scene is PackedScene):
            failures.append("%s should load as PackedScene" % scene_path)
            continue

        var instance = packed_scene.instantiate()
        if instance == null:
            failures.append("%s should instantiate successfully" % scene_path)
            continue
        instance.free()

    var main_scene: String = ProjectSettings.get_setting("application/run/main_scene", "")
    if main_scene != "res://scenes/main_menu.tscn":
        failures.append("application/run/main_scene should point to res://scenes/main_menu.tscn")

    return failures
