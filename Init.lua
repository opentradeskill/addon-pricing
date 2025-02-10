local _, ns = ...
-- define OpenTradeSkill
OpenTradeSkill = OpenTradeSkill or {}
OpenTradeSkill.Pricing = OpenTradeSkill.Pricing or {}
local Api = {}

function Api:Lookup(item_thing)
    local item_id = 0
    -- get item_id
    if tonumber(item_thing) then
        item_id = tonumber(item_thing)
    else
        item_id = tonumber(item_thing:match("item:(%d+)"))
    end

    local context = {
        region_id = GetCurrentRegion(),
        realm_id = GetRealmID()
    }

    return Api:LookupWithContext(item_id, context)
end

function Api:LookupWithContext(item_id, context)
    local region_id = context.region_id
    local realm_id = context.realm_id
    if not ns.Prices[region_id] then return -1 end
    if not ns.Prices[region_id][realm_id] then return -1 end
    if not ns.Prices[region_id][realm_id]["prices"] then return -1 end
    if not ns.Prices[region_id][realm_id]["prices"][item_id] then return -1 end

    return ns.Prices[region_id][realm_id]["prices"][item_id]
end

ns.Api = Api
OpenTradeSkill.Pricing = Api