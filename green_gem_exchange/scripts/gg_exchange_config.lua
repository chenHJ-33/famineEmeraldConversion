-- ============================================================
-- 绿宝石物质兑换：配置 + 图标定位
--
-- 配方字段说明：
--   name            配方名（唯一）
--   product_prefab  产物包裹 prefab 名（多产物时使用包裹分发）
--   icon_item       图标对应的物品贴图名（不带 .tex）；
--                   图集由 ResolveIconAtlas 自动定位，无需手写
--   icon_atlas      若显式填写则优先使用（不推荐，见下方图标说明）
--   icon_image      显式 sprite 名（通常等于 icon_item .. ".tex"）
--   tech            解锁科技等级，对应 GLOBAL.TECH 的键；
--                   完整远古科技塔用 "ANCIENT_THREE"，破损塔无法解锁
--   nounlock        是否不可永久解锁（远古科技塔配方建议 true）
--   ingredients     投入材料：{ name = prefab 名, count = 数量 }
--   results         产出物品：{ name = prefab 名, count = 数量 }
--                   可选 durability_fraction：按总耐久百分比设置剩余耐久
--                   （如拆解魔杖总耐久 5，0.2 => 1 次）
--
-- 图标说明（重要）：
--   DST 的原版物品图标不在单一图集里，而是分散在 images/inventoryimages.xml
--   以及分卷 images/inventoryimages1.xml / 2.xml / 3.xml 中，且图集内的
--   sprite 名是贴图文件名（带 .tex 后缀）。
--
--   早期版本写死 images/inventoryimages.xml + "greenstaff"：
--     - 图集存在，所以不会报错；
--     - 但图集里没有该 sprite，制作栏只显示白色方块。
--   若写死一个不存在的图集路径（如 images/inventoryimages/greengem.xml），
--   AddRecipe2 会直接报 "Could not find an asset matching ..." 并导致
--   整个 mod 加载失败、服务器无法启动。
--
--   因此这里在运行时用 TheSim:AtlasContains 逐卷探测，自动选出真正包含
--   该图标的图集；全部探测失败时回退到确定存在的 images/inventoryimages.xml。
--   探测失败绝不会抛错，所以不会再出现"图集不存在导致服务器起不来"。
-- ============================================================

local recipes = {
    {
        name = "gg_exchange",
        product_prefab = "gg_exchange_bundle",

        -- 图标：指定"物品贴图"（不带 .tex），图集由下面的 ResolveIconAtlas 自动定位
        icon_item = "greengem",

        tech = "ANCIENT_THREE",
        nounlock = true,

        -- icon_atlas / icon_image 由 ResolveIconAtlas 写入（兼容直接写死的写法）
        ingredients = {
            { name = "thulecite",     count = 5 },
            { name = "nightmarefuel", count = 7 },
            { name = "greengem",      count = 2 },
            { name = "livinglog",     count = 1 },
        },
        results = {
            { name = "thulecite",     count = 12 },
            { name = "nightmarefuel", count = 8 },
            { name = "greenstaff",    count = 1, durability_fraction = 0.2 },
        },
    },
}

-- 原版图标图集分卷：按顺序探测，第一个命中的即被采用。
-- 把确认存在的总图集放在首位，保证最坏情况下也不会传入无效路径。
local ICON_ATLAS_CANDIDATES = {
    "images/inventoryimages.xml",
    "images/inventoryimages1.xml",
    "images/inventoryimages2.xml",
    "images/inventoryimages3.xml",
}

-- 能确认存在的总图集：即使探测全部失败，传入它也绝不会触发
-- "Could not find an asset matching ..."（旧版一直用它，服务端日志可证）。
-- 图集路径必须先校验存在性再交给 AddRecipe2，否则整个 mod 会加载失败。
local FALLBACK_ICON_ATLAS = "images/inventoryimages.xml"

-- DST 的 strict.lua 会拒绝未声明的全局变量，_G 本身也不可用；
-- 这里不强改环境，只做声明式读取（GLOBAL 是 DST 的全局表）。
local GLOBAL_ENV = rawget(getfenv(), "GLOBAL")
local THE_SIM = GLOBAL_ENV and GLOBAL_ENV.TheSim or nil

-- 图集文件是否真的存在（不存在时 resolvefilepath 会抛错，用 pcall 兜住）
local function AtlasFileExists(path)
    if resolvefilepath == nil then
        return path == FALLBACK_ICON_ATLAS
    end
    local ok = pcall(resolvefilepath, path)
    return ok
end

local function AtlasHas(atlas, image_name)
    if THE_SIM == nil or THE_SIM.AtlasContains == nil then
        return false
    end
    local ok, contains = pcall(THE_SIM.AtlasContains, THE_SIM, atlas, image_name)
    return ok and contains == true
end

-- 返回 atlas, image（image 为图集内的 sprite 名，通常是 xxx.tex）
local function ResolveIconAtlas(item)
    if item == nil or item == "" then
        return FALLBACK_ICON_ATLAS, FALLBACK_ICON_ATLAS
    end

    -- 同时尝试带/不带后缀两种名字，兼容不同图集的命名
    local names = { item .. ".tex", item }

    for _, atlas in ipairs(ICON_ATLAS_CANDIDATES) do
        if AtlasFileExists(atlas) then
            for _, image_name in ipairs(names) do
                if AtlasHas(atlas, image_name) then
                    return atlas, image_name
                end
            end
        end
    end

    -- 探测失败：用确认存在的图集 + 约定俗成的 sprite 名，最坏情况只是图标空白
    return FALLBACK_ICON_ATLAS, item .. ".tex"
end

for _, recipe in ipairs(recipes) do
    -- 显式写死的 icon_atlas 优先，否则按 icon_item / product_prefab 自动定位
    if recipe.icon_atlas == nil then
        local lookup = recipe.icon_item or recipe.product_prefab
        recipe.icon_atlas, recipe.icon_image = ResolveIconAtlas(lookup)
    end
end

-- 供 gg_exchange_bundle.lua 复用：让包裹在背包里的图标与制作栏图标一致
recipes.icon = {
    atlas = recipes[1] and recipes[1].icon_atlas or FALLBACK_ICON_ATLAS,
    image = recipes[1] and recipes[1].icon_image or FALLBACK_ICON_ATLAS,
}

return {
    recipes = recipes,
    ResolveIconAtlas = ResolveIconAtlas,
    ICON_ATLAS_CANDIDATES = ICON_ATLAS_CANDIDATES,
    FALLBACK_ICON_ATLAS = FALLBACK_ICON_ATLAS,
}
