extends RefCounted

const SCRIPT_PATH = "res://scripts/game/enemy_spawner.gd"

func run() -> Array[String]:
    var failures: Array[String] = []

    if not ResourceLoader.exists(SCRIPT_PATH):
        failures.append("enemy_spawner.gd should exist")
        return failures

    var script = load(SCRIPT_PATH)
    if script == null or not (script is Script) or not script.can_instantiate():
        failures.append("enemy_spawner.gd should load successfully")
        return failures

    var spawner = script.new()

    if not spawner.has_method("build_floor_plan"):
        failures.append("EnemySpawner should expose build_floor_plan()")
        return failures

    var floor_one: Dictionary = spawner.build_floor_plan(1)
    var floor_five: Dictionary = spawner.build_floor_plan(5)

    if floor_one.get("is_boss_floor", true):
        failures.append("Floor 1 should not be a boss floor")

    if not floor_five.get("is_boss_floor", false):
        failures.append("Floor 5 should be a boss floor")

    if int(floor_five.get("enemy_health_scale", 0)) < int(floor_one.get("enemy_health_scale", 0)):
        failures.append("Later floors should not be weaker than early floors")

    return failures
