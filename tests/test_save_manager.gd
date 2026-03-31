extends RefCounted

const SCRIPT_PATH = "res://autoload/save_manager.gd"

func run() -> Array[String]:
    var failures: Array[String] = []

    if not ResourceLoader.exists(SCRIPT_PATH):
        failures.append("save_manager.gd should exist")
        return failures

    var script = load(SCRIPT_PATH)
    if script == null or not (script is Script) or not script.can_instantiate():
        failures.append("save_manager.gd should load successfully")
        return failures

    var save_manager = script.new()

    if not save_manager.has_method("get_default_save_data"):
        failures.append("SaveManager should expose get_default_save_data()")
        return failures

    var defaults: Dictionary = save_manager.get_default_save_data()

    if defaults.get("highest_floor", -1) != 0:
        failures.append("Default highest_floor should be 0")

    if defaults.get("essence", -1) != 0:
        failures.append("Default essence should be 0")

    if not save_manager.has_method("set_save_path_override"):
        failures.append("SaveManager should allow a save path override for tests")
        return failures

    if not save_manager.has_method("save_save_data") or not save_manager.has_method("load_save_data"):
        failures.append("SaveManager should support save/load roundtrip")
        return failures

    var temp_path = "user://weapon_gouelite_test_save.json"
    save_manager.set_save_path_override(temp_path)

    var modified = defaults.duplicate(true)
    modified["highest_floor"] = 7
    modified["essence"] = 42
    modified["meta_upgrades"]["attack"] = 2

    if not save_manager.save_save_data(modified):
        failures.append("save_save_data() should return true on success")
        return failures

    var loaded: Dictionary = save_manager.load_save_data()

    if loaded.get("highest_floor", -1) != 7:
        failures.append("Loaded save should preserve highest_floor")

    if loaded.get("essence", -1) != 42:
        failures.append("Loaded save should preserve essence")

    save_manager.free()
    return failures
