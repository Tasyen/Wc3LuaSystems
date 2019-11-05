do
    --[[
    ItemHook 1.1 by Tasyen
    requires: Global Initialization by Bribe
    
    Allows to setup a function that is executed when an item of itemCode enters(created) or leaves(destroyed) the game.

    Create: preplaced, code created, creep-drops, itempool and buy items. Items created by RestoreUnit are not catched by this system.
    Destroy: sold, consumed(charges), damage or RemoveItem
    
    //How to use?
    Write in a script below ItemHook the wanted ones from below

    ItemCreated[FourCC('bgst')] = function(item, source, hero)
        --item the item created
        --source the unit having sold the item or nil
        --hero the unit the item was created for/buyed it or nil, does not work for the GUI-Hero-Item-Create-Actions.
        action
        action
    end
    ItemCreatedAfter evokes the function after the game has started. Use this for actions unsafe pre 0.0s
    ItemCreatedAfter[FourCC('bgst')] = function(item, source, hero)
        action
        action
    end

    ItemDestroyed[FourCC('bgst')] = function(item)
        action
    end

    if you need a general action unrelevant to itemCode you might alter the system code inside
    function ItemDestroyed.action(item, itemCode)
    function ItemCreated.action(item, source, hero)

    item is the created/sold item. source is nil or the unit selling the item.
    --]]
    ItemCreated = {}
    ItemCreatedAfter = {}
    ItemDestroyed = {}
    local Waiting = {}

    function ItemCreated.action(item, source, hero)
        --source is nil outside of buy item Event
        --hero is a unit when the item was created for /bought by an unit
        local itemCode = GetItemTypeId(item)
        local trigger = CreateTrigger()
        --safe itemData, that is done cause inside TriggerRegisterDeathEvent reading the item was not really doable in a clean way.
        ItemDestroyed[trigger] = {}
        ItemDestroyed[trigger].Event = TriggerRegisterDeathEvent(trigger, item)
        ItemDestroyed[trigger].Action = TriggerAddAction(trigger, ItemDestroyed.TriggerAction)
        ItemDestroyed[trigger].ItemCode = itemCode
        ItemDestroyed[trigger].Item = item

        if ItemCreated[itemCode] then ItemCreated[itemCode](item, source, hero) end
        if ItemCreatedAfter[itemCode] then
            if bj_gameStarted then --game did start already?
                ItemCreatedAfter[itemCode](item, source, hero)
            else
                --no, inser an table into the Waiting table
                table.insert(Waiting, {itemCode, item, source, hero})
            end
        end
	    return item
    end
    function ItemDestroyed.action(item, itemCode)
        if ItemDestroyed[itemCode] then ItemDestroyed[itemCode](item) end
    end

    local realCreateItem = CreateItem
    function CreateItem(itemid, x, y)
        return ItemCreated.action(realCreateItem(itemid, x, y))
    end

    local realUnitAddItemToSlotById = UnitAddItemToSlotById
    function UnitAddItemToSlotById(whichUnit, itemId, itemSlot)
        local value = realUnitAddItemToSlotById(whichUnit, itemId, itemSlot)
        ItemCreated.action(UnitItemInSlot(whichUnit, itemSlot), nil, whichUnit)
        return value
    end

    local realUnitAddItemById = UnitAddItemById
    function UnitAddItemById(whichUnit, itemId)
	    return ItemCreated.action(UnitAddItemById(whichUnit, itemId), nil, whichUnit)
    end

    local realPlaceRandomItem = PlaceRandomItem
    function PlaceRandomItem(whichItemPool, x, y)
	    return ItemCreated.action(realPlaceRandomItem(whichItemPool, x, y))
    end

    --handled by TriggerRegisterDeathEvent
    --local realRemoveItem = RemoveItem
    --function RemoveItem(item)
        --ItemDestroyed.action(item, GetItemTypeId(item))
	    --realRemoveItem(item)
    --end

    onTriggerInit(function()
        ItemCreated[1] = {}
        ItemCreated[1].Trigger = CreateTrigger()
        ItemCreated[2] = {}
        ItemCreated[2].Trigger = CreateTrigger()
        for index = 0, GetBJMaxPlayerSlots() - 1,1 do
            table.insert(ItemCreated[1] , TriggerRegisterPlayerUnitEvent(ItemCreated[1].Trigger, Player(index), EVENT_PLAYER_UNIT_SELL_ITEM))
            table.insert(ItemCreated[2] , TriggerRegisterPlayerUnitEvent(ItemCreated[2].Trigger, Player(index), EVENT_PLAYER_UNIT_PAWN_ITEM))
        end
        ItemCreated[1].TriggerAction = TriggerAddAction(ItemCreated[1].Trigger, function()
            ItemCreated.action(GetSoldItem(), GetSellingUnit(), GetBuyingUnit())
        end)
        ItemCreated[2].TriggerAction = TriggerAddAction(ItemCreated[2].Trigger, function()
            ItemDestroyed.action(GetSoldItem(), GetItemTypeId(GetSoldItem()))
        end)
    end)

    function ItemDestroyed.TriggerAction()
        local trigger = GetTriggeringTrigger()
        ItemDestroyed.action(ItemDestroyed[trigger].Item, ItemDestroyed[trigger].ItemCode)
        --cleanup
        TriggerRemoveAction(trigger, ItemDestroyed[trigger].Action)
        DestroyTrigger(trigger)
        ItemDestroyed[trigger].ItemCode = nil
        ItemDestroyed[trigger].Item = nil
        ItemDestroyed[trigger].Action = nil
        ItemDestroyed[trigger].Event = nil
        ItemDestroyed[trigger] = nil
    end
    onGameStart(function()
        --iterate the Waiting stack and execute it
        for index, value in ipairs(Waiting)
        do
            ItemCreatedAfter[value[1]](value[2],value[3],value[4])
        end
        Waiting = nil
    end)

end
