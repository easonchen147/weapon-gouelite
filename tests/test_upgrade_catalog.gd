extends RefCounted

const SCRIPT_PATH := "res://scripts/data/upgrade_catalog.gd"

func run() -> Array[String]:
    var failures: Array[String] = []

    if not ResourceLoader.exists(SCRIPT_PATH):
        failures.append("upgrade_catalog.gd should exist")
        return failures

    var script := load(SCRIPT_PATH)
    if script == null or not (script is Script) or not script.can_instantiate():
        failures.append("upgrade_catalog.gd should load successfully")
        return failures

    var catalog = script.new()

    if not catalog.has_method("roll_choices"):
        failures.append("UpgradeCatalog should expose roll_choices()")
        return failures

    var rng := RandomNumberGenerator.new()
    rng.seed = 20260331
    var context := {
        "weapon_levels": {"boomerang_sword": 1},
        "owned_weapons": ["boomerang_sword"],
        "stats": {
            "attack_bonus": 0.0,
            "attack_speed_bonus": 0.0,
            "crit_chance_bonus": 0.0,
            "max_health_bonus": 0,
            "move_speed_bonus": 0.0,
            "range_bonus": 0.0,
            "split_bonus": 0,
            "chain_bonus": 0,
            "lifesteal_bonus": 0.0,
        },
    }

    var choices: Array = catalog.roll_choices(context, 3, rng)

    if choices.size() != 3:
        failures.append("roll_choices() should return exactly 3 choices")
        return failures

    var ids := {}
    for choice in choices:
        if not choice.has("id"):
            failures.append("Every upgrade choice should include an id")
            continue
        ids[choice["id"]] = true

    if ids.size() != 3:
        failures.append("roll_choices() should avoid duplicate upgrade ids")

    return failures
