extends Node

const WeaponCatalogScript = preload("res://scripts/data/weapon_catalog.gd")
const BalanceScript = preload("res://scripts/data/balance.gd")

var _weapon_catalog: RefCounted = WeaponCatalogScript.new()
var _state: Dictionary = {}

func start_new_run(meta_save: Dictionary = {}) -> void:
    var attack_meta = int(meta_save.get("meta_upgrades", {}).get("attack", 0))
    var health_meta = int(meta_save.get("meta_upgrades", {}).get("health", 0))
    _state = {
        "floor": 1,
        "level": 1,
        "experience": 0,
        "experience_to_next": BalanceScript.get_experience_for_level(1),
        "kills": 0,
        "essence_earned": 0,
        "owned_weapons": ["boomerang_sword"],
        "weapon_levels": {
            "boomerang_sword": 1,
            "split_bow": 0,
            "flame_staff": 0,
            "thunder_hammer": 0,
        },
        "stats": {
            "max_health": int(BalanceScript.PLAYER_BASE["max_health"]) + int(BalanceScript.get_meta_upgrade_value("health")) * health_meta,
            "attack": float(BalanceScript.PLAYER_BASE["attack"]) + float(BalanceScript.get_meta_upgrade_value("attack")) * attack_meta,
            "attack_speed": float(BalanceScript.PLAYER_BASE["attack_speed"]),
            "crit_chance": float(BalanceScript.PLAYER_BASE["crit_chance"]),
            "crit_damage": float(BalanceScript.PLAYER_BASE["crit_damage"]),
            "move_speed": float(BalanceScript.PLAYER_BASE["move_speed"]),
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

func get_snapshot() -> Dictionary:
    return _state.duplicate(true)

func add_experience(amount: int) -> int:
    var levels_gained = 0
    _state["experience"] = int(_state["experience"]) + amount

    while int(_state["experience"]) >= int(_state["experience_to_next"]):
        _state["experience"] = int(_state["experience"]) - int(_state["experience_to_next"])
        _state["level"] = int(_state["level"]) + 1
        _state["experience_to_next"] = BalanceScript.get_experience_for_level(int(_state["level"]))
        levels_gained += 1

    return levels_gained

func advance_floor() -> void:
    _state["floor"] = int(_state["floor"]) + 1

func add_kill() -> void:
    _state["kills"] = int(_state["kills"]) + 1
    _state["essence_earned"] = int(_state["essence_earned"]) + 1

func apply_upgrade(upgrade: Dictionary) -> void:
    match String(upgrade.get("type", "")):
        "stat":
            var key = String(upgrade.get("key", ""))
            var value: Variant = upgrade.get("value", 0)
            if _state["stats"].has(key):
                _state["stats"][key] = _state["stats"][key] + value
        "weapon_unlock":
            var weapon_id = String(upgrade.get("weapon_id", ""))
            if not _state["owned_weapons"].has(weapon_id):
                _state["owned_weapons"].append(weapon_id)
                _state["weapon_levels"][weapon_id] = 1
        "weapon_upgrade":
            var target_weapon = String(upgrade.get("weapon_id", ""))
            var next_level = int(upgrade.get("target_level", 1))
            if not _state["owned_weapons"].has(target_weapon):
                _state["owned_weapons"].append(target_weapon)
            _state["weapon_levels"][target_weapon] = clamp(next_level, 1, _weapon_catalog.get_max_level(target_weapon))

func get_weapon_level(weapon_id: String) -> int:
    return int(_state.get("weapon_levels", {}).get(weapon_id, 0))

func get_effective_stat(stat_key: String) -> Variant:
    match stat_key:
        "attack":
            return float(_state["stats"]["attack"]) * (1.0 + float(_state["stats"]["attack_bonus"]))
        "attack_speed":
            return float(_state["stats"]["attack_speed"]) * (1.0 + float(_state["stats"]["attack_speed_bonus"]))
        "crit_chance":
            return float(_state["stats"]["crit_chance"]) + float(_state["stats"]["crit_chance_bonus"])
        "max_health":
            return int(_state["stats"]["max_health"]) + int(_state["stats"]["max_health_bonus"])
        "move_speed":
            return float(_state["stats"]["move_speed"]) * (1.0 + float(_state["stats"]["move_speed_bonus"]))
        _:
            return _state["stats"].get(stat_key, null)
