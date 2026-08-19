# 绿宝石物质兑换 (Green Gem Exchange)

一个《饥荒：联机版》(Don't Starve Together) 的 Mod，用于在完整的远古科技塔处，用绿宝石等材料兑换铥矿、噩梦燃料与拆解魔杖。

## 功能

- 在**完整的远古科技塔**（祭坛处于完整状态）处开放兑换配方
- 兑换材料与产出见下方「兑换配方」一节
- 拆解魔杖按 20% 总耐久发放（总耐久 5 次 → 兑换后约 1 次）
- 远古科技塔配方不可永久解锁（`nounlock`），每次仍需在塔旁制作

## 兑换配方

| 类型 | 材料 / 产出 | 数量 |
| --- | --- | --- |
| 投入 | 铥矿 (thulecite) | ×5 |
| 投入 | 噩梦燃料 (nightmarefuel) | ×7 |
| 投入 | 绿宝石 (greengem) | ×2 |
| 投入 | 活木 (livinglog) | ×1 |
| 产出 | 铥矿 (thulecite) | ×12 |
| 产出 | 噩梦燃料 (nightmarefuel) | ×8 |
| 产出 | 拆解魔杖 (greenstaff) | ×1（20% 耐久） |

## 安装

1. 将 `green_gem_exchange` 文件夹复制到 DST 的 `mods` 目录
   - Windows 客户端：`<Steam安装目录>\steamapps\common\Don't Starve Together\mods\`
   - 专用服务器：`<DST服务器目录>\mods\`
2. 在游戏主菜单 Mods 界面勾选该 Mod，或写入服务器的 `modoverrides.lua`
3. 重新启动游戏 / 服务器

## 配置

所有配方数据集中在 `scripts/gg_exchange_config.lua`，可自行增删条目：

- `name`：配方名（唯一）
- `product_prefab`：产物包裹 prefab 名（多产物时自动分发）
- `icon_atlas` / `icon_image`：制造栏图标（默认复用原版 `images/inventoryimages.xml` / `greenstaff`）
- `tech`：解锁科技等级，丢至完整远古科技塔请保持 `"ANCIENT_THREE"`
- `nounlock`：是否不可永久解锁（远古配方建议 `true`）
- `ingredients`：投入材料 `{ name = prefab名, count = 数量 }`
- `results`：产出物品 `{ name = prefab名, count = 数量, durability_fraction = 剩余耐久比例 }`

## 兼容性

- 版本：`1.0.0`，DST 专属（`dst_compatible = true`）
- `api_version = 10`
- `all_clients_require_mod = true`（所有客户端都需开启该 Mod）