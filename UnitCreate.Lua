do
    --[[
    UnitCreate 1.2 by Tasyen
    Allows to add a function executed when an unit of itemCode is created, includes preplaced, code created, trained, summoned, corpse creation, unitpools, hired units, create blight mine and constructed units.

    Does not catch (pocket) factory (nor that spawing), Lava Spawn spliting, Upgraded, morphing or fusing units.

    Adding an action on unit creation:
    UnitCreate[FourCC('Hpal')] = function(unit, source)
        action
        action
    end

    Add an action to an unit creation happening delayed until the game started, there is no delay if the game already has started.
    UnitCreateAfter[FourCC('Hpal')] = function(unit, source)
        action
        action
    end

    --]]
    UnitCreate = {}
    UnitCreateAfter = {}
    local waiting = {}
    local Timer = CreateTimer()
    function UnitCreate.action(unit, source)
        local unitCode = GetUnitTypeId(unit)
        if source then
            print("UnitCreated", GetObjectName(unitCode), GetUnitName(source))
        else
            print("UnitCreated", GetObjectName(unitCode))
        end
        if UnitCreate[unitCode] then UnitCreate[unitCode](unit, source) end
        if UnitCreateAfter[unitCode] then
            if bj_gameStarted then --game did start already?
                UnitCreateAfter[unitCode](unit, source)
            else
                --no, inser an table into the waiting table
                table.insert(waiting, {unitCode, unit, source})
            end
        end
	    return unit
    end

    local realCreateUnit = CreateUnit
    function CreateUnit(id, unitid, x, y, face)        
        return UnitCreate.action(realCreateUnit(id, unitid, x, y, face))
    end

    local realCreateUnitByName = CreateUnitByName
    function CreateUnitByName(whichPlayer, unitname, x, y, face)
        return UnitCreate.action(realCreateUnitByName(whichPlayer, unitname, x, y, face))
    end

    local realCreateUnitAtLoc = CreateUnitAtLoc
    function CreateUnitAtLoc(id, unitid, whichLocation, face)
	    return UnitCreate.action(realCreateUnitAtLoc(id, unitid, whichLocation, face))
    end

    local realCreateUnitAtLocByName = CreateUnitAtLocByName
    function CreateUnitAtLocByName(id, unitname, whichLocation, face)
        return UnitCreate.action(realCreateUnitAtLocByName(id, unitname, whichLocation, face))
    end

    local realCreateCorpse = CreateCorpse
    function CreateCorpse(whichPlayer, unitid, x, y, face)
	    return UnitCreate.action(realCreateCorpse(whichPlayer, unitid, x, y, face))
    end


    local realPlaceRandomUnit = PlaceRandomUnit
    function PlaceRandomUnit(whichPlayer, unitid, x, y, face)
	    return UnitCreate.action(realPlaceRandomUnit(whichPlayer, unitid, x, y, face))
    end

    local realCreateBlightedGoldmine = CreateBlightedGoldmine
    function CreateBlightedGoldmine(id, x, y, face)
	    return UnitCreate.action(realCreateBlightedGoldmine(id, x, y, face))
    end

    local realRestoreUnit = RestoreUnit
    function RestoreUnit(cache, missionKey, key, forWhichPlayer, x, y, facing)
        local unit = realRestoreUnit(cache, missionKey, key, forWhichPlayer, x, y, facing)
        if unit then
            UnitCreate.action(unit)
            --check restored units inventory
            if ItemCreate.action then
                --execute for each restored item an itemCreate action
                local index = 0
                repeat
                    local item = UnitItemInSlot(unit, index)
                    if item then
                        ItemCreate.action(item)
                    end
                    index = index + 1
                until index == bj_MAX_INVENTORY
            end
        end
        return unit
    end

    UnitCreate[1] = {}
    UnitCreate[2] = {}
    UnitCreate[3] = {}
    UnitCreate[4] = {}
    UnitCreate[1].Trigger = CreateTrigger()
    UnitCreate[2].Trigger = CreateTrigger()
    UnitCreate[3].Trigger = CreateTrigger()
    UnitCreate[4].Trigger = CreateTrigger()
    for index = 0, GetBJMaxPlayerSlots() - 1,1 do
        table.insert(UnitCreate[1] , TriggerRegisterPlayerUnitEvent(UnitCreate[1].Trigger, Player(index), EVENT_PLAYER_UNIT_TRAIN_FINISH))
        table.insert(UnitCreate[2] , TriggerRegisterPlayerUnitEvent(UnitCreate[2].Trigger, Player(index), EVENT_PLAYER_UNIT_SUMMON))
        table.insert(UnitCreate[3] , TriggerRegisterPlayerUnitEvent(UnitCreate[3].Trigger, Player(index), EVENT_PLAYER_UNIT_SELL))
        table.insert(UnitCreate[4] , TriggerRegisterPlayerUnitEvent(UnitCreate[4].Trigger, Player(index), EVENT_PLAYER_UNIT_CONSTRUCT_START))
    end
    UnitCreate[1].TriggerAction = TriggerAddAction(UnitCreate[1].Trigger, function()
        UnitCreate.action(GetTrainedUnit(), GetTriggerUnit())
    end)
    UnitCreate[2].TriggerAction = TriggerAddAction(UnitCreate[2].Trigger, function()
        --units revived by Paladin or Death Knight to trigger creating again.
        UnitCreate.action(GetSummonedUnit(), GetSummoningUnit())

    end)
    UnitCreate[3].TriggerAction = TriggerAddAction(UnitCreate[3].Trigger, function()
        UnitCreate.action(GetSoldUnit(), GetSellingUnit())
    end)
    UnitCreate[4].TriggerAction = TriggerAddAction(UnitCreate[4].Trigger, function()
        UnitCreate.action(GetTriggerUnit(), nil)
    end)
    
    TimerStart(Timer, 0, false, function()
        --iterate the waiting stack and execute it
        for index, value in ipairs(waiting)
        do
            UnitCreateAfter[value[1]](value[2],value[3])
        end
        DestroyTimer(Timer)
        Timer = nil
        waiting = nil
    end)

end
