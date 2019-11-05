--[[
V1.5
requires: Global Initialization 1.2 by Bribe   
GroupSelectionMimic is an system that mimics warcraft 3 group selection order.
That is done so one knows which unit is in current main focus when having multiple units selected.

This is an synced resource hence it might work wrong when having bad latency Through that would have to be tested.

One can get the current focuse selected unit with 
function GroupSelectionMimic.getFocusUnit(player)
--]]

--hook into remove and showUnit
--RemoveUnit and ShowUnit do not throw an deselection event hence hook in.
do
    local realShowUnit = ShowUnit
    function ShowUnit(whichUnit, show)
        if not show then
            GroupSelectionMimic.removeUnit(whichUnit)
        end
        realShowUnit(whichUnit,show)
    end
    local realRemoveUnit = RemoveUnit
    function RemoveUnit(whichUnit)
        GroupSelectionMimic.removeUnit(whichUnit)
        realRemoveUnit(whichUnit)
    end
end

GroupSelectionMimic = {}
onTriggerInit(function()
    GroupSelectionMimic.SelectedUnits = {}
    GroupSelectionMimic.DeselectionTrigger = CreateTrigger()
    GroupSelectionMimic.KeyTrigger = CreateTrigger() --pressing tab
    GroupSelectionMimic.LoadedTrigger = CreateTrigger() --needed when units can be loaded into transporters
    GroupSelectionMimic.SelectionTrigger = CreateTrigger()
    GroupSelectionMimic.DeathTrigger = {} --death, reincarnation
    GroupSelectionMimic.SummonTrigger = CreateTrigger() --needed for storm earth fire

    --add arrays for players and add Events
    ForForce(bj_FORCE_ALL_PLAYERS, function()
        local player = GetEnumPlayer()
        GroupSelectionMimic.SelectedUnits[player] = {Selected = 1, Running = false}
        BlzTriggerRegisterPlayerKeyEvent(GroupSelectionMimic.KeyTrigger, player, OSKEY_TAB, 0, true) 
        BlzTriggerRegisterPlayerKeyEvent(GroupSelectionMimic.KeyTrigger, player, OSKEY_TAB, 1, true) --shift
        BlzTriggerRegisterPlayerKeyEvent(GroupSelectionMimic.KeyTrigger, player, OSKEY_TAB, 2, true) --ctrl
        BlzTriggerRegisterPlayerKeyEvent(GroupSelectionMimic.KeyTrigger, player, OSKEY_TAB, 3, true) --shift + ctrl
        TriggerRegisterPlayerUnitEvent(GroupSelectionMimic.SelectionTrigger, player, EVENT_PLAYER_UNIT_SELECTED, nil)
        TriggerRegisterPlayerUnitEvent(GroupSelectionMimic.DeselectionTrigger, player, EVENT_PLAYER_UNIT_DESELECTED, nil)
    end)
    TriggerRegisterAnyUnitEventBJ(GroupSelectionMimic.LoadedTrigger, EVENT_PLAYER_UNIT_LOADED)
    TriggerRegisterAnyUnitEventBJ(GroupSelectionMimic.SummonTrigger, EVENT_PLAYER_UNIT_SUMMON)
    

    TriggerAddAction(GroupSelectionMimic.KeyTrigger, function()
        local player = GetTriggerPlayer()
        local playerData = GroupSelectionMimic.SelectedUnits[player]    
        if #playerData <= 1 then return end --do nothing, if only one or less is selected
        local currentUnitCode = GetUnitTypeId(playerData[playerData.Selected])
                
        if BlzBitAnd(BlzGetTriggerPlayerMetaKey(), 1) == 1 then
            if not IsUnitType(playerData[playerData.Selected], UNIT_TYPE_HERO) then
                --jump to prev group
                while (GetUnitTypeId(playerData[playerData.Selected]) == currentUnitCode)
                do
                    playerData.Selected = playerData.Selected - 1
                end
            else
                playerData.Selected = playerData.Selected - 1
            end
        else
            if not IsUnitType(playerData[playerData.Selected], UNIT_TYPE_HERO) then
                --jump to next group
                while (GetUnitTypeId(playerData[playerData.Selected]) == currentUnitCode)
                do
                    playerData.Selected = playerData.Selected + 1
                end
            else
                playerData.Selected = playerData.Selected + 1
            end
        end
    
        --overflow
        if playerData.Selected > #playerData then playerData.Selected = 1 end
        if playerData.Selected < 1 then playerData.Selected = #playerData end
    
        --debug display the new focus unit
        --print(playerData.Selected, GetUnitName(playerData[playerData.Selected]))
    end)

    TriggerAddAction(GroupSelectionMimic.SelectionTrigger, function()
        --print("Select")
        GroupSelectionMimic.addUnitToPlayer(GetTriggerPlayer(), GetTriggerUnit())
    end)
    
    TriggerAddAction(GroupSelectionMimic.DeselectionTrigger, function()
        local player = GetTriggerPlayer()
        local playerData = GroupSelectionMimic.SelectedUnits[player]
        local triggerUnit = GetTriggerUnit()   
        GroupSelectionMimic.removeUnitFromPlayerData(playerData, triggerUnit)
    end)

    TriggerAddAction(GroupSelectionMimic.LoadedTrigger, function()
        GroupSelectionMimic.removeUnit(GetTriggerUnit())
    end)

    TriggerAddAction(GroupSelectionMimic.SummonTrigger, function()
        if GetUnitCurrentOrder(GetSummoningUnit()) == OrderId("elementalfury") then
            GroupSelectionMimic.removeUnit(GetSummoningUnit())
            GroupSelectionMimic.addUnitToPlayer(GetTriggerPlayer(), GetSummonedUnit(), true)
        end
    end)
end)

function GroupSelectionMimic.getFocusUnit(player)
    local playerData = GroupSelectionMimic.SelectedUnits[player]
    return playerData[playerData.Selected]
end

function GroupSelectionMimic.debugPrint()
    local playerData = GroupSelectionMimic.SelectedUnits[Player(0)]
    print("Selected: ",playerData.Selected, GetUnitName(playerData[playerData.Selected]))
    for key, value in ipairs(playerData)
    do  
        print(key, GetUnitName(value), BlzGetUnitRealField(value, UNIT_RF_PRIORITY), GroupSelectionMimic.getOrderValue(value))
    end
end

function GroupSelectionMimic.getOrderValue(unit)
    --heroes use the handleId
    if IsUnitType(unit, UNIT_TYPE_HERO) then
        return GetHandleId(unit)
    else
    --units use unitCode
      return GetUnitTypeId(unit)
    end
end
function GroupSelectionMimic.createDeathDetect(unit)
    if GroupSelectionMimic.DeathTrigger[unit] then
        GroupSelectionMimic.DeathTrigger[unit].Counter = GroupSelectionMimic.DeathTrigger[unit].Counter + 1
    else
        --print("Create DeathTrigger")
        local deathTrigger = CreateTrigger()
        GroupSelectionMimic.DeathTrigger[unit] = {}
        GroupSelectionMimic.DeathTrigger[unit].Counter = 1
        GroupSelectionMimic.DeathTrigger[unit].Trigger = deathTrigger
        GroupSelectionMimic.DeathTrigger[unit].TriggerAction = TriggerAddAction(deathTrigger, function()
            GroupSelectionMimic.removeUnit(GetTriggerUnit())
        end)
        TriggerRegisterUnitLifeEvent(deathTrigger, unit, LESS_THAN_OR_EQUAL, 0.45)
    end
end
function GroupSelectionMimic.destroyDeathDetect(unit)
    if not GroupSelectionMimic.DeathTrigger[unit] then return end --do nothing, if there is none
    GroupSelectionMimic.DeathTrigger[unit].Counter = GroupSelectionMimic.DeathTrigger[unit].Counter - 1
    if GroupSelectionMimic.DeathTrigger[unit].Counter < 1 then
        --print("Destroy DeathTrigger")
        TriggerRemoveAction( GroupSelectionMimic.DeathTrigger[unit].Trigger,  GroupSelectionMimic.DeathTrigger[unit].TriggerAction)
        DestroyTrigger(GroupSelectionMimic.DeathTrigger[unit].Trigger)
        GroupSelectionMimic.DeathTrigger[unit].Trigger = nil
        GroupSelectionMimic.DeathTrigger[unit].TriggerAction = nil
        GroupSelectionMimic.DeathTrigger[unit].Counter = nil
        GroupSelectionMimic.DeathTrigger[unit] = nil
    end
end

function GroupSelectionMimic.removeUnitFromPlayerData(playerData, unit)
    local unitCode = GetUnitTypeId(unit)
    for key, value in ipairs(playerData)
    do  
        if value == unit then
            --update focus when an unit was removed that has an lower index then the focused unit
            if key == playerData.Selected then
                if IsUnitType(value, UNIT_TYPE_HERO) then
                    playerData.Selected = 1
                --have more of that unit?
                elseif GetUnitTypeId(playerData[playerData.Selected + 1]) == unitCode or GetUnitTypeId(playerData[playerData.Selected - 1]) == unitCode then
                    --do nothing
                else
                    playerData.Selected = 1
                end
            elseif key < playerData.Selected then playerData.Selected = playerData.Selected - 1 end
            --pull down the selected index, do not drop below 1
            table.remove(playerData, key)
            GroupSelectionMimic.destroyDeathDetect(value)
            --when the last unit was loaded in and there is an transporter the transporter gets focus without a selection
            if #playerData == 0 and GetTransportUnit() then table.insert(playerData, GetTransportUnit())
            elseif playerData.Selected > #playerData then playerData.Selected = math.max(#playerData,1) end
            break
        end
    end
end
function GroupSelectionMimic.removeUnit(unit)
    ForForce(bj_FORCE_ALL_PLAYERS, function()
        local player = GetEnumPlayer()
        local playerData = GroupSelectionMimic.SelectedUnits[player]
        GroupSelectionMimic.removeUnitFromPlayerData(playerData, unit)
    end)
    
end

function GroupSelectionMimic.addUnitToPlayer(player, unit, ignoreMultiAdd)
    local playerData = GroupSelectionMimic.SelectedUnits[player]
    local triggerUnitCode = GetUnitTypeId(unit)
    local triggerUnitPrio = BlzGetUnitRealField(unit, UNIT_RF_PRIORITY)

    if not ignoreMultiAdd then
        --start a 0s timer when it not runs already.
        --when another selection happens in that time, then the focus unit is reseted to the first unit.
        --This is done to correct multigroup selection with mouse clicking + drag or shift + double clicking
        if not playerData.Running then
            playerData.Running = true
            TimerStart(CreateTimer(), 0, false, function()
                playerData.Running = false
                DestroyTimer(GetExpiredTimer())
            end)
        else
            playerData.Selected = 1
        end
    end
    
        --contains this unit already?
    for key, value in ipairs(playerData)
    do  
        if value == unit then
            return
        end
    end
    
    local added = false
    --Add the unit where it should be prio wise.

    --print("Add",GetUnitName(unit), GroupSelectionMimic.getOrderValue(triggerUnitCode), triggerUnitPrio)
    for key, value in ipairs(playerData)
    do 

        --same prio and trigger units handle is smaller then take values place.
        if BlzGetUnitRealField(value, UNIT_RF_PRIORITY) == triggerUnitPrio and GroupSelectionMimic.getOrderValue(value) > GroupSelectionMimic.getOrderValue(unit) then
            --print("Replace Key",key)
            table.insert( playerData, key, unit)
            added = true
            GroupSelectionMimic.createDeathDetect(unit)

            --update the focus index when this unit was added into an lower index
            if key <= playerData.Selected then playerData.Selected = playerData.Selected + 1 end
            break            
        elseif BlzGetUnitRealField(value, UNIT_RF_PRIORITY) < triggerUnitPrio then
            table.insert( playerData, key, unit)
            added = true
            GroupSelectionMimic.createDeathDetect(unit)

            --update the focus index when this unit was added into an lower index
            if key <= playerData.Selected then playerData.Selected = playerData.Selected + 1 end
            break
        end
    end
    --not added yet?
    if not added then
        --add it at the end
        table.insert(playerData, unit)
        GroupSelectionMimic.createDeathDetect(unit)
    end
end
