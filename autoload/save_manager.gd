extends Node

const DEFAULT_SAVE_PATH = "user://weapon_gouelite_save.json"

var _save_path_override = ""

func set_save_path_override(path: String) -> void:
    _save_path_override = path

func get_save_path() -> String:
    if _save_path_override.is_empty():
        return DEFAULT_SAVE_PATH
    return _save_path_override

func get_default_save_data() -> Dictionary:
    return {
        "highest_floor": 0,
        "essence": 0,
        "meta_upgrades": {
            "attack": 0,
            "health": 0,
        },
        "settings": {
            "master_volume": 1.0,
            "ads_enabled": true,
        },
    }

func load_save_data() -> Dictionary:
    var save_path = get_save_path()
    if not FileAccess.file_exists(save_path):
        var defaults = get_default_save_data()
        save_save_data(defaults)
        return defaults

    var file = FileAccess.open(save_path, FileAccess.READ)
    if file == null:
        return get_default_save_data()

    var raw_text = file.get_as_text()
    var parsed: Variant = JSON.parse_string(raw_text)
    if typeof(parsed) != TYPE_DICTIONARY:
        return get_default_save_data()

    return _merge_with_defaults(parsed)

func save_save_data(data: Dictionary) -> bool:
    var file = FileAccess.open(get_save_path(), FileAccess.WRITE)
    if file == null:
        return false

    file.store_string(JSON.stringify(_merge_with_defaults(data), "  "))
    return true

func purchase_meta_upgrade(upgrade_id: String) -> bool:
    var data = load_save_data()
    if not data["meta_upgrades"].has(upgrade_id):
        return false

    var current_level = int(data["meta_upgrades"][upgrade_id])
    var cost = get_upgrade_cost(upgrade_id, current_level)
    if int(data["essence"]) < cost:
        return false

    data["essence"] = int(data["essence"]) - cost
    data["meta_upgrades"][upgrade_id] = current_level + 1
    return save_save_data(data)

func get_upgrade_cost(upgrade_id: String, current_level: int) -> int:
    if upgrade_id == "attack":
        return 20 + current_level * 15
    if upgrade_id == "health":
        return 20 + current_level * 15
    return 999999

func apply_run_results(reached_floor: int, earned_essence: int) -> Dictionary:
    var data = load_save_data()
    data["highest_floor"] = max(int(data["highest_floor"]), reached_floor)
    data["essence"] = int(data["essence"]) + earned_essence
    save_save_data(data)
    return data

func _merge_with_defaults(data: Dictionary) -> Dictionary:
    var merged = get_default_save_data()
    for key in data.keys():
        if typeof(merged.get(key)) == TYPE_DICTIONARY and typeof(data[key]) == TYPE_DICTIONARY:
            var nested: Dictionary = merged[key]
            for nested_key in data[key].keys():
                nested[nested_key] = data[key][nested_key]
            merged[key] = nested
        else:
            merged[key] = data[key]
    return merged
