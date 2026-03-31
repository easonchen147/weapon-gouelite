class_name Balance
extends RefCounted

const PLAYER_BASE := {
    "max_health": 100,
    "attack": 10.0,
    "attack_speed": 1.0,
    "crit_chance": 0.05,
    "crit_damage": 1.5,
    "move_speed": 420.0,
}

const META_UPGRADE_VALUES := {
    "attack": 2.0,
    "health": 5,
}

const LEVEL_EXPERIENCE := [20, 28, 38, 50, 65, 82, 102, 126, 154, 186]

static func get_experience_for_level(level: int) -> int:
    if level <= 1:
        return LEVEL_EXPERIENCE[0]

    var index: int = min(level - 1, LEVEL_EXPERIENCE.size() - 1)
    return LEVEL_EXPERIENCE[index]

static func get_meta_upgrade_value(upgrade_id: String) -> Variant:
    return META_UPGRADE_VALUES.get(upgrade_id, 0)
