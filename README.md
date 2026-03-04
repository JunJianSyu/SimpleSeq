# SimpleSeq — WoW 12.0 极简序列宏插件

按 **1 键** 依次循环施放配置好的技能序列。

## 功能

- 单键循环施放技能序列（A → B → C → A → B → C ...）
- 可视化配置界面（`/sq` 命令）
- 按职业/专精独立保存配置
- 切换专精时自动加载对应技能序列
- 可调节按键延迟（100-1000ms 防抖）
- 兼容 WoW 12.0 (Midnight) API

## 安装

1. 将 `SimpleSeq/` 文件夹复制到：
   ```
   World of Warcraft/_retail_/Interface/AddOns/SimpleSeq/
   ```
2. 重启游戏，在「插件」菜单中确认启用

## 使用

### 打开配置

```
/sq
```

### 添加技能

在配置窗口输入框中输入技能**英文名称**，点击 Add 或按 Enter。

### 调整按键延迟

拖动底部滑块（100ms - 1000ms）。默认 150ms。

### 施放

配置完成后按 **1 键** 即可按顺序循环施放技能。

## 示例配置

| 职业 | 专精 | 技能序列 |
| ---- | ---- | -------- |
| Warrior | Fury | Bloodthirst, Raging Blow, Execute |
| Warrior | Arms | Mortal Strike, Overpower, Execute |
| Mage | Frost | Frostbolt, Ice Lance, Flurry |

## 注意事项

- 技能名称必须使用**英文**，拼写与游戏内技能书一致
- 未学会的技能会被自动跳过
- 使用 `SetOverrideBindingClick` 绑定 1 键，不修改动作条
- 配置跨角色共享（账号级 SavedVariables）

## 兼容性

- Interface: 120000 (WoW 12.0.x Midnight)
- 不使用 macrotext / COMBAT_LOG_EVENT / 动作条修改
- 通过 SecureActionButtonTemplate 安全路径施法

## 已知限制

- 仅支持 1 键绑定，不支持自定义按键
- 不支持条件判断、优先级或冷却跳过
- 不支持技能拖拽排序
