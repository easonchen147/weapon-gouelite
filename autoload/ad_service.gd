extends Node

signal ad_requested(reward_type: String)
signal ad_result(reward_type: String, result: Dictionary)

const STATUS_UNAVAILABLE = "unavailable"
const STATUS_GRANTED = "granted"
const STATUS_CANCELLED = "cancelled"

@export var simulate_rewards_on_desktop: bool = false

func show_rewarded_ad(reward_type: String) -> Dictionary:
    ad_requested.emit(reward_type)

    var result = {
        "status": STATUS_UNAVAILABLE,
        "reward_type": reward_type,
        "message": "当前版本未接入广告 SDK",
    }

    if simulate_rewards_on_desktop:
        result = {
            "status": STATUS_GRANTED,
            "reward_type": reward_type,
            "message": "调试模式：已直接发放奖励",
        }

    ad_result.emit(reward_type, result)
    return result
