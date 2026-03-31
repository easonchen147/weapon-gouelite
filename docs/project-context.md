# Weapon Gouelite 项目上下文

## 项目目标

用 Godot 4 交付一个可运行的横版轻肉鸽 MVP，强调：

- 自动战斗
- 左右移动
- 高频升级
- 武器进化
- 长线爬塔

## 实现原则

- 先保证玩法闭环，再考虑表现细节
- 代码结构优先清晰可维护
- 纯逻辑尽量数据驱动并可 headless 测试
- 平台相关能力通过集中服务隔离

## 代码结构约定

- `autoload/`：全局服务，仅放少量稳定能力
- `scripts/data/`：纯逻辑与目录数据
- `scripts/game/`：战斗流程控制
- `scripts/entities/`：玩家与敌人
- `scripts/weapons/`：武器与攻击行为
- `scripts/ui/`：界面逻辑
- `scenes/`：与脚本目录保持一致
- `tests/`：Godot headless 测试

## 关键边界

- 存档统一由 `SaveManager` 管理
- 当前局状态统一由 `RunState` 管理
- 广告入口统一由 `AdService` 管理
- 武器与升级池优先通过目录脚本配置，不把数值散落到场景里

## 产品取舍

- 不做多角色
- 不做复杂动作与连招
- 不做复杂剧情和社交
- 不做真实广告 SDK
- 不做重度局外系统
