# Weapon Gouelite

`Weapon Gouelite` 是一个使用 Godot 4 开发的极简横版武器进化爬塔
Roguelite MVP。

核心目标很明确：

- 自动战斗
- 左右移动
- 高频升级
- 三选一强化
- 四把核心武器
- 层数推进与 Boss
- 本地存档
- 广告结构预留

当前版本优先验证玩法闭环，不追求重度内容厚度。

## MVP 内容

当前可运行版本已经包含：

- 开始页
- 局外基础成长
- 战斗主场景
- 自动攻击
- 左右移动
- 怪物持续刷新
- 经验与升级
- 三选一强化弹窗
- 层数推进
- 第 5 层 Boss
- Game Over / Restart
- 四把武器
  - 回旋剑
  - 分裂弓
  - 火焰杖
  - 雷暴锤
- 本地最高层与局外货币保存
- 广告服务占位接口

## 运行环境

- Godot `4.6.1`
- Linux / macOS / Windows 均可，仓库内验证命令使用 Godot headless

如果本机 Godot 可执行文件不在 PATH 中，可以直接替换为你的 Godot 4
可执行文件路径。

## 如何运行

### 1. 打开项目

使用 Godot 4 打开仓库根目录：

```bash
godot4 --path .
```

如果本机 Godot 安装在自定义位置，例如本环境中的：

```bash
/data/Godot/godot4 --path .
```

### 2. 直接运行主场景

```bash
godot4 --path .
```

项目主入口已经配置为：

```text
res://scenes/main_menu.tscn
```

### 3. 直接运行战斗场景 smoke

```bash
godot4 --headless --path . --scene res://scenes/game/game_scene.tscn --quit-after 240
```

## 操作说明

- `A`：向左移动
- `D`：向右移动
- `R`：战斗中快速重开当前局

攻击为自动触发，不需要额外按键。

## 测试命令

### 逻辑测试

```bash
godot4 --headless --path . --script tests/run_all_tests.gd
```

### 资源导入验证

```bash
godot4 --headless --path . --import
```

### 主菜单 smoke

```bash
godot4 --headless --path . --quit-after 120
```

### 战斗场景 smoke

```bash
godot4 --headless --path . --scene res://scenes/game/game_scene.tscn --quit-after 240
```

## 项目结构

```text
autoload/                全局服务：存档、当前局状态、广告占位
docs/                    产品、设计与拆分文档
scenes/                  Godot 场景
scripts/data/            数值与目录数据
scripts/game/            战斗流程与刷怪
scripts/entities/        玩家与敌人
scripts/weapons/         武器与投射物逻辑
scripts/ui/              主菜单、升级面板、结算面板
tests/                   Headless GDScript 测试
```

## 本地存档

当前版本通过 `SaveManager` 将以下数据保存到 `user://`：

- 最高层
- 局外货币 `essence`
- 基础攻击升级等级
- 基础生命升级等级
- 基础设置项

## 广告结构预留

当前未接入真实广告 SDK，但已经保留：

- `AdService.show_rewarded_ad(reward_type)`
- 菜单广告入口
- 战败复活广告入口

桌面版默认返回“未接入广告 SDK”的提示，后续接微信小游戏广告能力时只需替换
`AdService` 的平台实现。

## 微信小游戏后续适配方向

本仓库当前交付的是 Godot 桌面可运行 MVP。

为了后续转换到微信小游戏，已经提前做了这几项隔离：

- 存档逻辑集中在 `autoload/save_manager.gd`
- 广告逻辑集中在 `autoload/ad_service.gd`
- 输入仅依赖 Godot Input Map
- 没有引入桌面专属第三方插件

下一步若进行微信小游戏适配，重点会落在：

1. Godot Web / 微信小游戏导出链路
2. 文件系统与本地持久化桥接
3. 激励广告与插屏广告 SDK 对接
4. 性能与加载体积优化

## 已知取舍

- 当前美术与特效以几何图形和色块为主
- 怪物 AI 保持极简，优先服务成长爽感
- 广告为结构预留，不是真实商业化接入
- 局外成长只保留最小闭环

## License

本项目使用 MIT License，详见根目录 [LICENSE](LICENSE)。
