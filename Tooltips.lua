local _, ns = ...
-- credit to Auctionator for a lot of this: https://github.com/Auctionator/Auctionator/blob/5073e35ea3206eadeb8de704b61dae2edcb386de/Source/Tooltips/Hooks.lua

local function FormatCopperPrice(copper)
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local copper = copper % 100

    local gold_icon = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:0:0|t"
    local silver_icon = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:0:0|t"
    local copper_icon = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:0:0|t"

    local str = ""
    if gold > 0 then
        local gold_str = ""
        if gold < 10 then gold_str = "0" .. gold else gold_str = gold end
        gold_str = gold_str .. " " .. gold_icon
        str = gold_str
    end

    if silver > 0 or (silver == 0 and gold > 0) then
        local silver_str = ""
        if silver < 10 then silver_str = "0" .. silver else silver_str = silver end
        silver_str = silver_str .. " " .. silver_icon
        str = str .. " " .. silver_str
    end

    --if copper > 0 then
        local copper_str = ""
        if copper < 10 then copper_str = "0" .. copper else copper_str = copper end
        copper_str = copper_str .. " " .. copper_icon
        str = str .. " " .. copper_str
    --end

    return str
end

local function RenderTooltip(tooltip, item_thing, qty)
    local lookup_price = ns.Api:Lookup(item_thing)
    if lookup_price == -1 then return end
    local formatted_price = FormatCopperPrice(lookup_price)
    if formatted_price == "" then return end

    tooltip:AddLine(" ")
    tooltip:AddLine("\124cFFFBBF24OpenTradeSkill Pricing")
    tooltip:AddDoubleLine("\124cFF2468FB  Lowest Price\124r", "\124r" .. formatted_price)
end

local tooltip_handlers = {}
tooltip_handlers["SetBagItem"] = function(tip, bag, slot)
    local item_location = ItemLocation:CreateFromBagAndSlot(bag, slot)

    if C_Item.DoesItemExist(item_location) then
        local item_link = C_Item.GetItemLink(item_location)
        local item_qty = C_Item.GetStackCount(item_location)

        RenderTooltip(tip, item_link, item_qty)
    end
end

tooltip_handlers["SetHyperlink"] = function(tip, item_thing)
    RenderTooltip(tip, item_thing, 1)
end

if TooltipDataProcessor and C_TooltipInfo then
    local function ValidateTooltip(tooltip)
        return tooltip == GameTooltip or tooltip == GameTooltipTooltip or tooltip == ItemRefTooltip or tooltip == GarrisonShipyardMapMissionTooltipTooltip or (not tooltip:IsForbidden() and (tooltip:GetName() or ""):match("^NotGameTooltip"))
    end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
        if ValidateTooltip(tooltip) then
            local info = tooltip.info or tooltip.processingInfo

            if not info or not info.getterName or info.excludeLines then
                return
            end

            local handler = tooltip_handlers[info.getterName:gsub("^Get", "Set")]
            if handler ~= nil then
                handler(tooltip, unpack(info.getterArgs))
            end
        end
    end)
else
    hooksecurefunc(ItemRefTooltip, "SetHyperlink", tooltip_handlers["SetHyperlink"])

    for func, handler in pairs(tooltip_handlers) do
        hooksecurefunc(GameTooltip, func, handler)
    end
end