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

所有配方数据集中在 `green_gem_exchange/scripts/gg_exchange_config.lua`，可自行增删条目：

- `name`：配方名（唯一）
- `product_prefab`：产物包裹 prefab 名（多产物时自动分发）
- `icon_item`：图标对应的原版物品贴图名（不带 `.tex`），图集自动定位
- `icon_atlas` / `icon_image`：仅在需要手工指定图标时填写（一般留空即可）
- `tech`：解锁科技等级，丢至完整远古科技塔请保持 `"ANCIENT_THREE"`
- `nounlock`：是否不可永久解锁（远古配方建议 `true`）
- `ingredients`：投入材料 `{ name = prefab名, count = 数量 }`
- `results`：产出物品 `{ name = prefab名, count = 数量, durability_fraction = 剩余耐久比例 }`

## 图标机制（改配置前请先读）

DST 的原版物品图标**不在单一图集里**，而是分散在 `images/inventoryimages.xml`
以及分卷 `images/inventoryimages1.xml` / `2.xml` / `3.xml` 中，且图集内的
sprite 名是**贴图文件名（带 `.tex` 后缀）**。

- 若把图集写成不存在的路径（例如 `images/inventoryimages/greengem.xml`），
  `AddRecipe2` 会抛 `Could not find an asset matching ...`，**整个 mod 加载失败、
  服务器无法启动**。
- 若图集存在但 sprite 名不对（例如 `"greenstaff"` 少了 `.tex`），不会报错，
  但制作栏只会显示**白色方块**。

因此 `gg_exchange_config.lua` 会在运行时用 `TheSim:AtlasContains` 逐卷探测，
自动选出真正包含该图标的图集，并把图集路径先经 `resolvefilepath` 校验存在性；
探测全部失败时回退到确定存在的 `images/inventoryimages.xml`。
最坏情况只是图标空白，绝不会再导致服务器启动失败。

## 更新日志

### 1.1.0（2026-10-12）

- 修复：制作栏与背包图标不再显示白色方块。原先写死的
  `images/inventoryimages.xml` + `"greenstaff"` 既不命中 sprite，也缺少 `.tex` 后缀；
  现改为运行时自动定位图集与 sprite 名
- 修复：不再因图集路径不存在而导致服务器启动失败（`Failed mSimulation->Reset()`）
- 修复：`GiveResult` 不再使用被 `strict.lua` 禁止的全局变量
  （原写法会导致制作时抛出 LUA ERROR，材料扣了却拿不到任何产物）
- 优化：配方表改为惰性加载 + O(1) 查表，纯客户端不再解析配方配置
- 优化：产物分发加固（生成失败时记录日志、入包失败时稳定落地）

### 1.0.0

- 初版：完整的远古科技塔配方，铥矿 + 噩梦燃料 + 绿宝石 + 活木 兑换铥矿、
  噩梦燃料与 20% 耐久拆解魔杖

## 兼容性

- 版本：`1.1.0`，DST 专属（`dst_compatible = true`）
- `api_version = 10`
- `all_clients_require_mod = true`（所有客户端都需开启该 Mod）
- 更新日期：2026-10-12