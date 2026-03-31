extends SceneTree

const TEST_SCRIPTS = [
    "res://tests/test_weapon_catalog.gd",
    "res://tests/test_upgrade_catalog.gd",
    "res://tests/test_save_manager.gd",
    "res://tests/test_run_state.gd",
    "res://tests/test_enemy_spawner.gd",
    "res://tests/test_ad_service.gd",
    "res://tests/test_scene_smoke.gd",
]

func _initialize() -> void:
    var total_failures: Array[String] = []
    print("Running Weapon Gouelite tests...")

    for test_path in TEST_SCRIPTS:
        var script = load(test_path)
        var suite = script.new()
        var failures: Array = suite.run()

        if failures.is_empty():
            print("[PASS] %s" % test_path)
        else:
            print("[FAIL] %s" % test_path)
            for failure in failures:
                print("  - %s" % str(failure))
                total_failures.append("%s :: %s" % [test_path, failure])

    if total_failures.is_empty():
        print("All tests passed.")
        quit(0)
        return

    print("Total failures: %d" % total_failures.size())
    quit(1)
