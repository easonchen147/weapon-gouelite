extends RefCounted

const SCRIPT_PATH = "res://autoload/ad_service.gd"

func run() -> Array[String]:
    var failures: Array[String] = []

    if not ResourceLoader.exists(SCRIPT_PATH):
        failures.append("ad_service.gd should exist")
        return failures

    var script = load(SCRIPT_PATH)
    if script == null or not (script is Script) or not script.can_instantiate():
        failures.append("ad_service.gd should load successfully")
        return failures

    var ad_service = script.new()

    if not ad_service.has_method("show_rewarded_ad"):
        failures.append("AdService should expose show_rewarded_ad()")
        return failures

    var result: Dictionary = ad_service.show_rewarded_ad("revive")
    if not result.has("status"):
        failures.append("AdService result should include a status field")

    ad_service.free()
    return failures
