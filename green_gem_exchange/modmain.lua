PrefabFiles = { "gg_exchange_bundle" }

local config = require("gg_exchange_config")

GLOBAL.GG_EXCHANGE_RECIPES = config.recipes

-- 显式声明图标图集资源：确保 TheSim:AtlasContains 探测时图集已经加载
local MakeAsset = GLOBAL.Asset or Asset
local icon_atlas_assets = {}
do
    local declared = {}
    local candidates = { config.FALLBACK_ICON_ATLAS }
    for _, atlas in ipairs(config.ICON_ATLAS_CANDIDATES or {}) do
        table.insert(candidates, atlas)
    end
    for _, atlas in ipairs(candidates) do
        if atlas ~= nil and not declared[atlas] then
            declared[atlas] = true
            table.insert(icon_atlas_assets, MakeAsset("ATLAS", atlas))
        end
    end
end

Assets = icon_atlas_assets

if GLOBAL.STRINGS ~= nil and GLOBAL.STRINGS.NAMES ~= nil then
    GLOBAL.STRINGS.NAMES.GG_EXCHANGE_BUNDLE = "物质兑换"
end

local function RegisterRecipe(recipe)
    local ingredients = {}
    for _, ing in ipairs(recipe.ingredients or {}) do
        table.insert(ingredients, GLOBAL.Ingredient(ing.name, ing.count))
    end

    local tech = GLOBAL.TECH[recipe.tech]
    if tech == nil then
        print("[gg_exchange] Unknown TECH: " .. tostring(recipe.tech))
        return
    end

    -- 图标图集必须指向真实存在的文件，否则 AddRecipe2 会抛
    -- "Could not find an asset matching ..." 并导致整个 mod 加载失败。
    local atlas = recipe.icon_atlas or config.FALLBACK_ICON_ATLAS
    local image = recipe.icon_image or atlas

    AddRecipe2(
        recipe.name,
        ingredients,
        tech,
        {
            product = recipe.product_prefab,
            numtogive = 1,
            nounlock = recipe.nounlock == true,
            atlas = atlas,
            image = image,
        },
        { "MODS" }
    )
end

for _, recipe in ipairs(config.recipes or {}) do
    RegisterRecipe(recipe)
end
