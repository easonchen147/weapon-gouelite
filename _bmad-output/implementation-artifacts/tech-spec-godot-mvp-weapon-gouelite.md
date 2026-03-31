---
title: 'Godot MVP：极简横版武器进化爬塔 Roguelite'
slug: 'godot-mvp-weapon-gouelite'
created: '2026-03-31T14:50:00+08:00'
status: 'Implementation Complete'
stepsCompleted: [1, 2, 3, 4]
tech_stack:
  - 'Godot 4.6.1'
  - 'GDScript'
  - 'Godot UI/Control'
  - 'Headless GDScript test runner'
files_to_modify:
  - 'project.godot'
  - 'icon.svg'
  - 'autoload/save_manager.gd'
  - 'autoload/run_state.gd'
  - 'autoload/ad_service.gd'
  - 'scripts/data/balance.gd'
  - 'scripts/data/weapon_catalog.gd'
  - 'scripts/data/upgrade_catalog.gd'
  - 'scripts/game/game_controller.gd'
  - 'scripts/game/enemy_spawner.gd'
  - 'scripts/entities/player.gd'
  - 'scripts/entities/enemy.gd'
  - 'scripts/ui/main_menu.gd'
  - 'scripts/ui/upgrade_panel.gd'
  - 'scripts/ui/game_over_panel.gd'
  - 'scripts/weapons/weapon_base.gd'
  - 'scripts/weapons/boomerang_sword.gd'
  - 'scripts/weapons/split_bow.gd'
  - 'scripts/weapons/flame_staff.gd'
  - 'scripts/weapons/thunder_hammer.gd'
  - 'tests/run_all_tests.gd'
code_patterns:
  - 'Clean Slate: root-level Godot project'
  - 'Autoload singletons for save/run/ad services'
  - 'Data-driven catalogs for weapons/upgrades/floor balance'
  - 'Thin scene scripts, reusable projectile/effect scenes'
  - 'UI driven by signals and direct service calls'
test_patterns:
  - 'Headless Godot script runner via --headless --script'
  - 'Pure-logic assertions for save, upgrades, run progression, weapon data'
---

# Tech-Spec: Godot MVP：极简横版武器进化爬塔 Roguelite

**Created:** 2026-03-31T14:50:00+08:00

## Overview

### Problem Statement

当前仓库只有产品方向文档与 BMAD/GDS 工作流，没有可运行的游戏工程。
需要基于既有产品文档，在 Godot 4 中从零交付一个可运行的 MVP，
覆盖开始页、战斗场景、自动攻击、左右移动、怪物刷新、经验升级、
三选一强化、层数推进、Boss、Game Over / Restart、四把核心武器、
本地存档以及广告结构预留，并最终可继续适配微信小游戏。

### Solution

在仓库根目录直接创建 Godot 4 项目，采用 GDScript +
场景拆分 + 少量 Autoload 单例的结构。
先用数据驱动方式固化武器、强化、层数与数值表，再搭建核心战斗循环、
UI 流程与本地存档，最后补全 README、LICENSE 与 Git 交付。

### Scope

**In Scope:**
- Godot 4 可运行单机 MVP
- 主界面 / 战斗 / 升级弹窗 / 结算页
- 自动战斗与左右移动
- 四把武器与至少一次明显进化
- 普通怪、精英/Boss、层数推进
- 本地最高层与局外货币保存
- 广告接口预留与调用结构
- 面向微信小游戏后续移植的代码组织

**Out of Scope:**
- 多角色系统
- 剧情系统
- 联机与社交
- 复杂局外天赋树
- 正式广告 SDK 接入
- 正式美术、音频、商业化素材

## Context for Development

### Codebase Patterns

当前为确认的 Clean Slate 状态，仓库内没有历史 Godot 代码。
因此直接采用适合小体量 Roguelite 的新结构：

- 根目录直接作为 Godot 项目目录
- `autoload/` 放少量全局服务
- `scripts/data/` 放纯逻辑与数值目录
- `scripts/game/`、`scripts/entities/`、`scripts/weapons/`、`scripts/ui/`
  分层处理场景控制、实体、武器与界面
- `scenes/` 与脚本目录一一对应
- `tests/` 使用 headless 脚本测试纯逻辑，不依赖第三方插件

### Files to Reference

| File | Purpose |
| ---- | ------- |
| docs/01-plan.md | 产品方向与核心循环 |
| docs/02-prd.md | MVP 目标与非目标 |
| docs/03-dev-breakdown.md | 系统拆分与优先级 |
| docs/04-balance-sheet-v1.md | 首版数值节奏 |
| docs/05-weapons-and-traits-v1.md | 武器与词条设计 |

### Technical Decisions

- 引擎固定为 Godot 4.6.x
- 脚本语言固定为 GDScript
- 代码组织以场景节点 + 纯逻辑脚本 + Autoload 服务为主
- 先保证桌面/本地运行，再为微信小游戏导出保留兼容边界
- 开始界面承载本地进度展示与轻量局外成长
- 战斗中仅保留左右移动，跳跃与复杂动作不进入 MVP
- 武器以数据驱动升级，达到指定等级触发显著形态变化
- Boss 首次出现在第 5 层，其后每 5 层重复出现并按层数缩放
- 广告仅保留接口层、按钮位与奖励枚举，不接入真实 SDK

## Implementation Plan

### Tasks

- [x] Task 1: 初始化 Godot 项目与基础目录
  - File: `project.godot`
  - Action: 创建项目配置、输入映射、主场景与 Autoload 注册。
  - Notes: 输入至少包含 `move_left`、`move_right`、`ui_accept`、`restart_run`。
- [x] Task 2: 创建占位资源与根场景
  - File: `icon.svg`
  - File: `scenes/main_menu.tscn`
  - File: `scenes/game/game_scene.tscn`
  - Action: 建立主菜单与战斗主场景的基础节点树、背景、地面与 UI 容器。
  - Notes: 资源允许使用矢量/色块占位，优先保证可运行。
- [x] Task 3: 建立核心数据与服务层
  - File: `scripts/data/balance.gd`
  - File: `scripts/data/weapon_catalog.gd`
  - File: `scripts/data/upgrade_catalog.gd`
  - File: `autoload/save_manager.gd`
  - File: `autoload/run_state.gd`
  - File: `autoload/ad_service.gd`
  - Action: 定义玩家、怪物、层数、经验曲线、四把武器的等级数据、升级池和本地存档结构。
  - Notes: 存档需覆盖最高层、局外货币、攻击/生命升级等级与设置位。
- [x] Task 4: 建立 headless 测试基建
  - File: `tests/run_all_tests.gd`
  - File: `tests/test_weapon_catalog.gd`
  - File: `tests/test_upgrade_catalog.gd`
  - File: `tests/test_save_manager.gd`
  - File: `tests/test_run_state.gd`
  - Action: 先写失败测试，再实现通过，用于验证目录数据、升级抽取、进度保存与爬塔推进。
  - Notes: 测试命令必须能在 `--headless --script` 下执行。
- [x] Task 5: 实现主菜单与局外成长
  - File: `scripts/ui/main_menu.gd`
  - File: `scenes/main_menu.tscn`
  - Action: 展示开始按钮、最高层、局外货币、攻击升级、生命升级、广告入口状态。
  - Notes: 菜单数据完全来自 `SaveManager`。
- [x] Task 6: 实现玩家与基础敌人
  - File: `scenes/entities/player.tscn`
  - File: `scripts/entities/player.gd`
  - File: `scenes/entities/enemy.tscn`
  - File: `scripts/entities/enemy.gd`
  - Action: 玩家左右移动、受伤、死亡；敌人朝玩家移动、接触伤害、死亡掉经验/即时结算。
  - Notes: 普通怪、厚血怪、快速怪、远程怪至少通过参数差异化。
- [x] Task 7: 实现刷怪、层数推进与 Boss
  - File: `scripts/game/enemy_spawner.gd`
  - File: `scripts/game/game_controller.gd`
  - Action: 按层数生成怪物波次，控制层计时、Boss 层判定、下一层过渡和难度递增。
  - Notes: 第 5 层必须刷出 Boss，后续支持按 5 层节奏循环。
- [x] Task 8: 实现四把武器与攻击表现
  - File: `scripts/weapons/weapon_base.gd`
  - File: `scripts/weapons/boomerang_sword.gd`
  - File: `scripts/weapons/split_bow.gd`
  - File: `scripts/weapons/flame_staff.gd`
  - File: `scripts/weapons/thunder_hammer.gd`
  - File: `scenes/weapons/boomerang_sword.tscn`
  - File: `scenes/weapons/arrow_projectile.tscn`
  - File: `scenes/weapons/fire_orb.tscn`
  - File: `scenes/weapons/lightning_effect.tscn`
  - Action: 为四把武器提供独立攻击逻辑、升级成长与一次明确进化体感。
  - Notes: 起始默认拥有回旋剑，其他武器通过升级解锁。
- [x] Task 9: 实现经验、升级三选一与 Build 成型
  - File: `scripts/ui/upgrade_panel.gd`
  - File: `scenes/ui/upgrade_panel.tscn`
  - File: `scripts/game/game_controller.gd`
  - Action: 经验累积到阈值时暂停战斗，弹出三选一，应用数值与武器升级，避免无效重复项。
  - Notes: 升级选项需混合属性、机制与武器类强化。
- [x] Task 10: 实现 Game Over、复活广告预留、Restart 与结果入库
  - File: `scripts/ui/game_over_panel.gd`
  - File: `scenes/ui/game_over_panel.tscn`
  - File: `autoload/ad_service.gd`
  - File: `autoload/save_manager.gd`
  - Action: 战败后展示本局层数、击杀、Build 摘要；支持一次广告复活占位、返回主菜单、重新开始并记录最高层与货币。
  - Notes: 桌面运行时广告按钮可走 stub 流程并明确提示未接 SDK。
- [x] Task 11: 编写运行文档与开源文件
  - File: `README.md`
  - File: `LICENSE`
  - File: `docs/README.md`
  - Action: 说明项目定位、目录、运行命令、测试命令、后续微信小游戏适配方向，并加入 MIT License。
  - Notes: README 需覆盖桌面运行与 headless 测试。
- [x] Task 12: 完成里程碑提交与远端推送
  - File: `.git`
  - Action: 分阶段提交规格、工程骨架、核心玩法、完善收尾，并推送到 `origin/main`。
  - Notes: 若远端默认分支为空，则创建并推送 `main`。

### Acceptance Criteria

- [ ] AC 1: Given 玩家从主菜单点击开始，when 进入战斗场景，then 10 秒内场上已有敌人与自动攻击行为。
- [ ] AC 2: Given 玩家仅操作左右移动，when 靠近怪群并持续存活，then 攻击会自动按武器冷却触发且无需额外按键。
- [ ] AC 3: Given 玩家击杀敌人获取经验，when 经验达到当前等级阈值，then 游戏暂停并弹出 3 个可选强化。
- [ ] AC 4: Given 升级面板已显示，when 玩家选择任意强化，then 该强化立即生效且战斗继续。
- [ ] AC 5: Given 玩家持续推进层数，when 到达第 5 层，then 必定生成至少 1 个 Boss 并替代普通层结算条件。
- [ ] AC 6: Given Boss 或普通敌人对玩家造成累计伤害，when 玩家生命值归零，then 会展示 Game Over 面板并允许 Restart。
- [ ] AC 7: Given 一局内抽到武器相关强化，when 同一武器达到关键等级，then 其攻击形态或效果会出现明显变化。
- [ ] AC 8: Given 玩家完成一局战斗，when 返回主菜单，then 最高层、局外货币和升级等级会从本地存档恢复。
- [ ] AC 9: Given 存档文件不存在，when 首次启动游戏，then 系统会创建默认存档且不会报错。
- [ ] AC 10: Given 广告服务未接入真实 SDK，when 玩家点击广告相关入口，then UI 会给出明确反馈而不会中断流程。
- [ ] AC 11: Given 执行 headless 测试命令，when 项目逻辑正确，then 测试进程以 0 退出并输出全部通过。
- [ ] AC 12: Given 在桌面环境运行 Godot 项目，when 进入开始页、战斗、升级、死亡与重开流程，then 核心循环完整无阻断。

## Additional Context

### Dependencies

- Godot 4.6.1.stable
- 无第三方 Godot 插件依赖
- 仅使用 Godot 内置节点、文件存储与 GDScript

### Testing Strategy

- 先建立 headless GDScript 测试运行器
- 用测试优先覆盖纯逻辑模块：升级池、存档、元成长、武器目录
- 再进行场景级 smoke test 与项目导入检查
- 最终验证需包含：
  - `godot4 --headless --script tests/run_all_tests.gd`
  - `godot4 --headless --import`
  - `godot4 --headless --quit-after 240`

### Notes

该规格面向 MVP 交付，不追求完整版内容厚度，
以“轻操作、高反馈、可持续爬塔”为唯一优先级。

高风险点：
- Godot 场景资源从零创建时容易因缺少最小节点结构导致运行失败
- 武器差异如果仅做数值变化，会损失产品方向中的“质变爽感”
- 升级池若不做去重/无效过滤，会明显削弱三选一体验
- 微信小游戏适配暂不执行，但代码层必须隔离文件 IO 与广告接口
