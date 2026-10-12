local assets =
{
    Asset("ANIM", "anim/gems.zip"),
}

-- 配方表只在服务器需要（分发产物时），因此这里惰性加载并缓存：
-- 客户端不会解析 gg_exchange_config.lua，同时反查由遍历变成 O(1) 查表。
-- 注意：缓存必须用 local —— DST 的 strict.lua 会拒绝任何未声明的全局变量。
local recipe_map = nil

local function GetRecipeByProduct(prefab_name)
    if recipe_map == nil then
        recipe_map = {}
        for _, recipe in ipairs(require("gg_exchange_config").recipes or {}) do
            if recipe.product_prefab ~= nil then
                recipe_map[recipe.product_prefab] = recipe
            end
        end
    end
    return recipe_map[prefab_name]
end

local function ApplyDurability(item, res)
    if res.durability_fraction ~= nil and item.components.finiteuses ~= nil
        and item.components.finiteuses.total ~= nil then
        local uses = math.max(1, math.ceil(item.components.finiteuses.total * res.durability_fraction))
        item.components.finiteuses:SetUses(uses)
    end
end

local function GiveResult(inst)
    local inventoryitem = inst.components.inventoryitem
    local owner = inventoryitem ~= nil and inventoryitem.owner or nil
    local pt = inst:GetPosition()

    local recipe = GetRecipeByProduct(inst.prefab)
    if recipe == nil then
        -- 配置缺失属于 mod 自身错误，打日志便于排查；为免卡在背包里仍然自毁。
        print("[gg_exchange] No recipe configured for product_prefab: " .. tostring(inst.prefab))
        inst:Remove()
        return
    end

    for _, res in ipairs(recipe.results or {}) do
        local count = res.count or 1

        for i = 1, count do
            local item = SpawnPrefab(res.name)
            if item == nil then
                print("[gg_exchange] SpawnPrefab failed: " .. tostring(res.name))
                break
            end

            ApplyDurability(item, res)

            -- GiveItem 返回 false 表示没能入包（背包已满 / 无 owner），
            -- 此时才把物品定位到包裹所在位置，避免它停在原点。
            local given = false
            if owner ~= nil and owner.components.inventory ~= nil then
                given = owner.components.inventory:GiveItem(item)
            end
            if not given then
                item.Transform:SetPosition(pt.x, pt.y, pt.z)
            end
        end
    end

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gems")
    inst.AnimState:SetBuild("gems")
    inst.AnimState:PlayAnimation("greengem_idle", true)

    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- 以下均为服务器逻辑：配方表由 GetRecipeByProduct 惰性 require，
    -- 客户端只负责显示包裹外观，不会加载 gg_exchange_config。
    inst:AddComponent("inventoryitem")
    -- 包裹的图标复用配置里自动定位出的图集，与制作栏保持一致
    -- （旧版写死 images/inventoryimages.xml + "greenstaff"，既渲染成白块，
    --   且 sprite 名缺少 .tex 后缀）
    local icon = require("gg_exchange_config").recipes.icon
    inst.components.inventoryitem.imagename = icon.image
    inst.components.inventoryitem.atlasname = icon.atlas
    inst.components.inventoryitem.nobounce = true

    inst:DoTaskInTime(0, GiveResult)

    return inst
end

return Prefab("gg_exchange_bundle", fn, assets)