return {
    -- ============================================================
    -- 兑换配方配置
    -- 如需新增兑换配方：复制一个条目，修改 name / ingredients / results
    -- 即可，modmain 会自动注册。多产物配方需要一个专属包裹 prefab。
    --
    -- 字段说明：
    --   name            配方名（唯一）
    --   product_prefab  产物包裹 prefab 名（多产物时使用包裹分发）
    --   icon_atlas      制造栏图标图集（原版 icon 直接复用）
    --   icon_image      制造栏图标名
    --   tech            解锁科技等级（字符串，对应 GLOBAL.TECH 中的键）
    --                    完整远古科技塔请使用 "ANCIENT_THREE"，
    --                    这样破损的远古科技塔无法解锁。
    --   nounlock        是否不可永久解锁（远古科技塔配方建议 true）
    --   ingredients     投入材料：{ name = prefab名, count = 数量 }
    --   results         产出物品：{ name = prefab名, count = 数量 }
    --                   可选 durability_fraction：按总耐久百分比设置剩余
    --                   耐久（如拆解魔杖总耐久5，0.2 => 1次）。
    -- ============================================================
    recipes = {
        {
            name = "gg_exchange",
            product_prefab = "gg_exchange_bundle",
            icon_atlas = "images/inventoryimages.xml",
            icon_image = "greenstaff",
            tech = "ANCIENT_THREE",
            nounlock = true,
            ingredients = {
                { name = "thulecite",    count = 5 },
                { name = "nightmarefuel", count = 7 },
                { name = "greengem",     count = 2 },
                { name = "livinglog",    count = 1 },
            },
            results = {
                { name = "thulecite",     count = 12 },
                { name = "nightmarefuel", count = 8 },
                { name = "greenstaff",    count = 1, durability_fraction = 0.2 },
            },
        },
    },
}