extends RefCounted

const SCRIPT_PATH := "res://scripts/entities/player.gd"

class MockRunState:
    extends RefCounted

    func get_effective_stat(stat_key: String) -> Variant:
        if stat_key == "move_speed":
            return 420.0
        return 0

class MockController:
    extends Node

    var _run_state := MockRunState.new()

    func get_run_state() -> RefCounted:
        return _run_state

func run() -> Array[String]:
    var failures: Array[String] = []

    if not ResourceLoader.exists(SCRIPT_PATH):
        failures.append("player.gd should exist")
        return failures

    var script := load(SCRIPT_PATH)
    if script == null or not (script is Script) or not script.can_instantiate():
        failures.append("player.gd should load successfully")
        return failures

    var player = script.new()
    player.controller = MockController.new()
    player.current_health = 40.0
    player.max_health = 100.0

    player.sync_from_snapshot({
        "stats": {
            "max_health": 125,
        },
        "weapon_levels": {},
    }, false)

    if abs(player.current_health - 65.0) > 0.001:
        failures.append("sync_from_snapshot() should preserve current HP and only add the max-health delta, not full-heal")

    player.controller.free()
    player.free()
    return failures
