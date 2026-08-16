local assets =
{
    Asset("ANIM", "anim/gems.zip"),
}

local config = require("scripts/config")

local function GetRecipeByProduct(prefab_name)
    for _, recipe in ipairs(config.recipes or {}) do
        if recipe.product_prefab == prefab_name then
            return recipe
        end
    end
    return nil
end

local function GiveResult(inst)
    local inventoryitem = inst.components.inventoryitem
    local owner = inventoryitem ~= nil and inventoryitem.owner or nil
    local pt = inst:GetPosition()

    local recipe = GetRecipeByProduct(inst.prefab)
    if recipe == nil then
        inst:Remove()
        return
    end

    for _, res in ipairs(recipe.results or {}) do
        local item = SpawnPrefab(res.name)
        if item ~= nil then
            if res.durability_fraction ~= nil and item.components.finiteuses ~= nil
                and item.components.finiteuses.total ~= nil then
                local uses = math.max(1, math.ceil(item.components.finiteuses.total * res.durability_fraction))
                item.components.finiteuses:SetUses(uses)
            end

            local dropped = true
            if owner ~= nil and owner.components.inventory ~= nil then
                dropped = not owner.components.inventory:GiveItem(item)
            end
            if dropped then
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

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "greenstaff"
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"
    inst.components.inventoryitem.nobounce = true

    inst:DoTaskInTime(0, GiveResult)

    return inst
end

return Prefab("gg_exchange_bundle", fn, assets)