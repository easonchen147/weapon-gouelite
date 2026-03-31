extends RefCounted

const SCRIPT_PATH = "res://autoload/run_state.gd"

func run() -> Array[String]:
    var failures: Array[String] = []

    if not ResourceLoader.exists(SCRIPT_PATH):
        failures.append("run_state.gd should exist")
        return failures

    var script = load(SCRIPT_PATH)
    if script == null or not (script is Script) or not script.can_instantiate():
        failures.append("run_state.gd should load successfully")
        return failures

    var run_state = script.new()

    if not run_state.has_method("start_new_run"):
        failures.append("RunState should expose start_new_run()")
        return failures

    run_state.start_new_run({
        "meta_upgrades": {
            "attack": 1,
            "health": 2,
        },
    })

    if not run_state.has_method("get_snapshot"):
        failures.append("RunState should expose get_snapshot()")
        return failures

    var snapshot: Dictionary = run_state.get_snapshot()

    if snapshot.get("floor", -1) != 1:
        failures.append("A new run should start at floor 1")

    if not snapshot.get("owned_weapons", []).has("boomerang_sword"):
        failures.append("A new run should start with boomerang_sword")

    if not run_state.has_method("add_experience"):
        failures.append("RunState should expose add_experience()")
        return failures

    run_state.add_experience(20)
    snapshot = run_state.get_snapshot()

    if snapshot.get("level", 1) < 2:
        failures.append("20 experience should level the player from 1 to at least 2")

    if not run_state.has_method("advance_floor"):
        failures.append("RunState should expose advance_floor()")
        return failures

    run_state.advance_floor()
    snapshot = run_state.get_snapshot()

    if snapshot.get("floor", -1) != 2:
        failures.append("advance_floor() should increment the floor")

    run_state.free()
    return failures
