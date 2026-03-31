class_name UpgradeCatalog
extends RefCounted

const WeaponCatalogScript := preload("res://scripts/data/weapon_catalog.gd")

const GENERIC_UPGRADES := [
    {"id": "stat_attack_up", "name": "攻击强化", "type": "stat", "key": "attack_bonus", "value": 0.20, "description": "攻击力 +20%"},
    {"id": "stat_speed_up", "name": "高速打击", "type": "stat", "key": "attack_speed_bonus", "value": 0.15, "description": "攻速 +15%"},
    {"id": "stat_crit_up", "name": "致命一击", "type": "stat", "key": "crit_chance_bonus", "value": 0.10, "description": "暴击率 +10%"},
    {"id": "stat_health_up", "name": "强健体魄", "type": "stat", "key": "max_health_bonus", "value": 25, "description": "最大生命 +25"},
    {"id": "stat_move_up", "name": "轻盈步伐", "type": "stat", "key": "move_speed_bonus", "value": 0.12, "description": "移速 +12%"},
    {"id": "mechanic_range_up", "name": "范围扩张", "type": "stat", "key": "range_bonus", "value": 0.18, "description": "攻击范围 +18%"},
    {"id": "mechanic_split_up", "name": "分裂强化", "type": "stat", "key": "split_bonus", "value": 1, "description": "分裂 +1"},
    {"id": "mechanic_chain_up", "name": "连锁强化", "type": "stat", "key": "chain_bonus", "value": 1, "description": "连锁目标 +1"},
    {"id": "mechanic_lifesteal_up", "name": "嗜血战意", "type": "stat", "key": "lifesteal_bonus", "value": 0.02, "description": "吸血 +2%"},
]

var _weapon_catalog: RefCounted = WeaponCatalogScript.new()

func build_candidate_pool(context: Dictionary) -> Array[Dictionary]:
    var pool: Array[Dictionary] = []
    for upgrade in GENERIC_UPGRADES:
        pool.append(upgrade.duplicate(true))

    var owned_weapons: Array = context.get("owned_weapons", [])
    var weapon_levels: Dictionary = context.get("weapon_levels", {})

    for weapon_id in _weapon_catalog.get_all_weapon_ids():
        var current_level := int(weapon_levels.get(weapon_id, 0))
        var max_level: int = _weapon_catalog.get_max_level(weapon_id)

        if current_level <= 0 and not owned_weapons.has(weapon_id):
            pool.append({
                "id": "unlock_%s" % weapon_id,
                "name": "解锁%s" % _weapon_catalog.get_weapon_definition(weapon_id).get("name", weapon_id),
                "type": "weapon_unlock",
                "weapon_id": weapon_id,
                "description": "获得新武器",
            })
            continue

        if current_level < max_level:
            pool.append({
                "id": "upgrade_%s_%d" % [weapon_id, current_level + 1],
                "name": "%s Lv.%d" % [_weapon_catalog.get_weapon_definition(weapon_id).get("name", weapon_id), current_level + 1],
                "type": "weapon_upgrade",
                "weapon_id": weapon_id,
                "target_level": current_level + 1,
                "description": "提升武器等级并接近进化",
            })

    return pool

func roll_choices(context: Dictionary, count: int = 3, rng: RandomNumberGenerator = null) -> Array:
    var generator := rng
    if generator == null:
        generator = RandomNumberGenerator.new()
        generator.randomize()

    var pool := build_candidate_pool(context)
    var choices: Array = []
    var used_ids := {}

    while choices.size() < count and not pool.is_empty():
        var index := generator.randi_range(0, pool.size() - 1)
        var candidate: Dictionary = pool[index]
        pool.remove_at(index)

        if used_ids.has(candidate.id):
            continue

        used_ids[candidate.id] = true
        choices.append(candidate)

    return choices

func get_upgrade_by_id(upgrade_id: String, context: Dictionary = {}) -> Dictionary:
    for candidate in build_candidate_pool(context):
        if candidate.id == upgrade_id:
            return candidate
    return {}
