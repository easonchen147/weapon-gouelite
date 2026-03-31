extends RefCounted

const SCRIPT_PATH = "res://scripts/data/weapon_catalog.gd"

func run() -> Array[String]:
    var failures: Array[String] = []

    if not ResourceLoader.exists(SCRIPT_PATH):
        failures.append("weapon_catalog.gd should exist")
        return failures

    var script = load(SCRIPT_PATH)
    if script == null or not (script is Script) or not script.can_instantiate():
        failures.append("weapon_catalog.gd should load successfully")
        return failures

    var catalog = script.new()

    if not catalog.has_method("get_all_weapon_ids"):
        failures.append("WeaponCatalog should expose get_all_weapon_ids()")
        return failures

    var weapon_ids: Array = catalog.get_all_weapon_ids()
    var required_ids = ["boomerang_sword", "split_bow", "flame_staff", "thunder_hammer"]

    for weapon_id in required_ids:
        if not weapon_ids.has(weapon_id):
            failures.append("Missing weapon id: %s" % weapon_id)

    if weapon_ids.size() != 4:
        failures.append("WeaponCatalog should define exactly 4 MVP weapons")

    if not catalog.has_method("get_level_data"):
        failures.append("WeaponCatalog should expose get_level_data()")
        return failures

    var level_data: Dictionary = catalog.get_level_data("boomerang_sword", 3)

    if level_data.is_empty():
        failures.append("Boomerang sword level 3 data should not be empty")
    elif not level_data.get("is_evolution", false):
        failures.append("Boomerang sword level 3 should be marked as a visible evolution point")

    return failures
