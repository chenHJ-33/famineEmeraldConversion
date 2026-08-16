PrefabFiles = { "gg_exchange_bundle" }

local config = require("scripts/config")

STRINGS.NAMES.GG_EXCHANGE_BUNDLE = "物质兑换"

local function RegisterRecipe(recipe)
    local ingredients = {}
    for _, ing in ipairs(recipe.ingredients or {}) do
        table.insert(ingredients, Ingredient(ing.name, ing.count))
    end

    local tech = GLOBAL.TECH[recipe.tech]
    if tech == nil then
        print("[gg_exchange] Unknown TECH: " .. tostring(recipe.tech))
        return
    end

    AddRecipe2(
        recipe.name,
        ingredients,
        tech,
        {
            product = recipe.product_prefab,
            numtogive = 1,
            nounlock = recipe.nounlock == true,
            atlas = recipe.icon_atlas,
            image = recipe.icon_image,
        },
        { "MODS" }
    )
end

for _, recipe in ipairs(config.recipes or {}) do
    RegisterRecipe(recipe)
end