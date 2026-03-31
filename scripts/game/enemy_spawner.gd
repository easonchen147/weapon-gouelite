class_name EnemySpawner
extends RefCounted

const ENEMY_ARCHETYPES = {
    "grunt": {"name": "小型近战怪", "health": 18.0, "damage": 6.0, "speed": 170.0, "xp": 4, "color": Color("ff7e6b"), "radius": 16.0},
    "runner": {"name": "高速怪", "health": 16.0, "damage": 7.0, "speed": 235.0, "xp": 5, "color": Color("f3cf71"), "radius": 14.0},
    "tank": {"name": "厚血怪", "health": 70.0, "damage": 14.0, "speed": 120.0, "xp": 12, "color": Color("7dc7ff"), "radius": 22.0},
    "caster": {"name": "远程怪", "health": 24.0, "damage": 8.0, "speed": 145.0, "xp": 6, "color": Color("be8cff"), "radius": 16.0},
    "boss_titan": {"name": "雷甲巨像", "health": 520.0, "damage": 20.0, "speed": 125.0, "xp": 120, "color": Color("ff5c8a"), "radius": 38.0, "is_boss": true},
}

func build_floor_plan(floor: int) -> Dictionary:
    var normalized_floor: int = max(1, floor)
    var is_boss_floor: bool = normalized_floor % 5 == 0
    var tier = int((normalized_floor - 1) / 5)
    var enemy_health_scale = 1.0 + float(normalized_floor - 1) * 0.12
    var enemy_damage_scale = 1.0 + float(normalized_floor - 1) * 0.09
    var density_scale = 1.0 + float(normalized_floor - 1) * 0.06

    if is_boss_floor:
        return {
            "floor": normalized_floor,
            "is_boss_floor": true,
            "duration": 999.0,
            "spawn_interval": 999.0,
            "enemy_health_scale": enemy_health_scale,
            "enemy_damage_scale": enemy_damage_scale,
            "density_scale": density_scale,
            "boss_id": "boss_titan",
            "minions": ["grunt", "runner"] if tier > 0 else ["grunt"],
        }

    var roster = ["grunt", "runner"]
    if normalized_floor >= 3:
        roster.append("tank")
    if normalized_floor >= 4:
        roster.append("caster")

    return {
        "floor": normalized_floor,
        "is_boss_floor": false,
        "duration": 20.0 + min(float(normalized_floor - 1) * 1.5, 12.0),
        "spawn_interval": max(0.45, 1.15 - float(normalized_floor - 1) * 0.05),
        "enemy_budget": 12 + normalized_floor * 2,
        "enemy_health_scale": enemy_health_scale,
        "enemy_damage_scale": enemy_damage_scale,
        "density_scale": density_scale,
        "roster": roster,
    }

func get_enemy_definition(enemy_id: String) -> Dictionary:
    return ENEMY_ARCHETYPES.get(enemy_id, {})

func pick_enemy_id(plan: Dictionary, rng: RandomNumberGenerator) -> String:
    if plan.get("is_boss_floor", false):
        var minions: Array = plan.get("minions", ["grunt"])
        return minions[rng.randi_range(0, minions.size() - 1)]

    var roster: Array = plan.get("roster", ["grunt"])
    return roster[rng.randi_range(0, roster.size() - 1)]
