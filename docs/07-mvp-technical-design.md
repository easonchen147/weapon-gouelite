# Weapon Gouelite MVP 技术设计

## 技术选型

- 引擎：Godot 4.6.x
- 语言：GDScript
- 项目结构：仓库根目录即 Godot 工程
- 持久化：`user://` JSON 存档
- 测试：Godot headless 脚本测试

## 目录设计

```text
autoload/
scripts/
  data/
  game/
  entities/
  weapons/
  ui/
scenes/
  entities/
  game/
  ui/
  weapons/
tests/
docs/
```

## 核心模块

### SaveManager
- 负责读取和写入本地存档
- 保存最高层、局外货币、升级等级、设置项
- 提供默认存档回退

### RunState
- 保存当前局的临时状态
- 维护等级、经验、层数、击杀数、当前武器等级
- 提供升级应用与层数推进接口

### AdService
- 封装广告奖励入口
- 预留 `show_rewarded_ad` 等接口
- 桌面版返回“未接入”或模拟结果，不直接依赖平台 SDK

### WeaponCatalog
- 提供四把武器的等级配置
- 每把武器包含冷却、伤害、数量、范围、进化标识等字段
- 供战斗逻辑与 UI 文案共用

### UpgradeCatalog
- 提供升级池抽取
- 负责避免重复、过滤满级项、组合三选一结果

### GameController
- 负责战斗主循环
- 管理层数、刷怪、经验、升级、Boss、暂停和结算

## 场景结构

### MainMenu
- 开始按钮
- 最高层显示
- 货币显示
- 局外成长按钮
- 广告入口按钮

### GameScene
- 玩家实例
- 敌人容器
- 武器效果容器
- UI 层
- 地面与边界

### UpgradePanel
- 升级标题
- 三个选项按钮
- 每个按钮显示名称、描述、品质/类别

### GameOverPanel
- 本局层数
- 击杀数
- Build 摘要
- 重新开始
- 返回菜单
- 广告复活入口

## 数据驱动原则

- 武器等级数据写在目录脚本中
- 怪物与 Boss 的基础数值来自平衡表
- 每层刷怪强度由层数函数生成
- 局外成长通过存档加成注入开局属性

## 微信小游戏适配预留

- 文件读写集中在 `SaveManager`
- 广告逻辑集中在 `AdService`
- 输入逻辑只依赖 Godot Input Map
- 不使用桌面专属插件

## 测试设计

优先测试纯逻辑：

- 武器目录是否包含四把武器及关键等级
- 升级池是否能稳定返回 3 个有效选项
- 存档初始化、读写、默认值回退是否正确
- 层数推进与经验升级逻辑是否符合节奏

最后补充场景 smoke test，确认项目能在 headless 模式启动。
