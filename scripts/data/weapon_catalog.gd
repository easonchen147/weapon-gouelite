class_name WeaponCatalog
extends RefCounted

const WEAPONS := {
    "boomerang_sword": {
        "name": "回旋剑",
        "summary": "中距离回旋清怪，进化后形成剑环。",
        "levels": {
            1: {"cooldown": 1.2, "damage_scale": 1.0, "projectiles": 1, "radius": 92.0, "is_evolution": false, "label": "单剑回旋"},
            2: {"cooldown": 1.05, "damage_scale": 1.2, "projectiles": 2, "radius": 104.0, "is_evolution": false, "label": "双剑回旋"},
            3: {"cooldown": 0.95, "damage_scale": 1.4, "projectiles": 2, "radius": 122.0, "is_evolution": true, "label": "大范围剑旋"},
            4: {"cooldown": 0.82, "damage_scale": 1.8, "projectiles": 3, "radius": 132.0, "is_evolution": false, "label": "三剑回旋"},
            5: {"cooldown": 0.7, "damage_scale": 2.2, "projectiles": 4, "radius": 146.0, "is_evolution": true, "label": "风暴剑环"},
        },
    },
    "split_bow": {
        "name": "分裂弓",
        "summary": "弹幕型远程武器，升级后分裂铺屏。",
        "levels": {
            1: {"cooldown": 0.95, "damage_scale": 1.0, "projectiles": 1, "split_count": 0, "is_evolution": false, "label": "单发箭"},
            2: {"cooldown": 0.88, "damage_scale": 1.1, "projectiles": 2, "split_count": 0, "is_evolution": false, "label": "双发箭"},
            3: {"cooldown": 0.8, "damage_scale": 1.2, "projectiles": 2, "split_count": 1, "is_evolution": true, "label": "分裂箭"},
            4: {"cooldown": 0.74, "damage_scale": 1.35, "projectiles": 3, "split_count": 1, "is_evolution": false, "label": "三发分裂"},
            5: {"cooldown": 0.66, "damage_scale": 1.6, "projectiles": 3, "split_count": 2, "is_evolution": true, "label": "追踪箭雨"},
        },
    },
    "flame_staff": {
        "name": "火焰杖",
        "summary": "火球爆裂并留下灼烧区域。",
        "levels": {
            1: {"cooldown": 1.15, "damage_scale": 0.95, "burn_scale": 0.2, "blast_radius": 46.0, "is_evolution": false, "label": "基础火球"},
            2: {"cooldown": 1.0, "damage_scale": 1.0, "burn_scale": 0.3, "blast_radius": 54.0, "is_evolution": false, "label": "火球爆裂"},
            3: {"cooldown": 0.92, "damage_scale": 1.1, "burn_scale": 0.5, "blast_radius": 64.0, "is_evolution": true, "label": "火焰残留"},
            4: {"cooldown": 0.84, "damage_scale": 1.3, "burn_scale": 0.7, "blast_radius": 76.0, "is_evolution": false, "label": "连发火爆"},
            5: {"cooldown": 0.75, "damage_scale": 1.6, "burn_scale": 1.0, "blast_radius": 92.0, "is_evolution": true, "label": "火焰雨"},
        },
    },
    "thunder_hammer": {
        "name": "雷暴锤",
        "summary": "低频高爆发，成长后连锁雷击。",
        "levels": {
            1: {"cooldown": 1.5, "damage_scale": 1.5, "chain_count": 1, "is_evolution": false, "label": "单点雷击"},
            2: {"cooldown": 1.35, "damage_scale": 1.7, "chain_count": 1, "is_evolution": false, "label": "高伤雷击"},
            3: {"cooldown": 1.2, "damage_scale": 1.9, "chain_count": 2, "is_evolution": true, "label": "双链雷击"},
            4: {"cooldown": 1.06, "damage_scale": 2.2, "chain_count": 3, "is_evolution": false, "label": "多段雷链"},
            5: {"cooldown": 0.95, "damage_scale": 2.6, "chain_count": 4, "is_evolution": true, "label": "雷暴领域"},
        },
    },
}

func get_all_weapon_ids() -> Array:
    return WEAPONS.keys()

func get_weapon_definition(weapon_id: String) -> Dictionary:
    return WEAPONS.get(weapon_id, {})

func get_level_data(weapon_id: String, level: int) -> Dictionary:
    var definition: Dictionary = get_weapon_definition(weapon_id)
    if definition.is_empty():
        return {}

    var levels: Dictionary = definition.get("levels", {})
    return levels.get(level, {})

func get_max_level(weapon_id: String) -> int:
    var definition: Dictionary = get_weapon_definition(weapon_id)
    if definition.is_empty():
        return 0

    var levels: Dictionary = definition.get("levels", {})
    return levels.keys().max()

func is_evolution_level(weapon_id: String, level: int) -> bool:
    return get_level_data(weapon_id, level).get("is_evolution", false)
