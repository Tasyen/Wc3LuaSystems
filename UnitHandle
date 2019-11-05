--A simple UnitIndexer, it is required for CustomUI to tell other players the target of rightclick if an unit is hovered by async BlzGetMouseFocusUnit()
UnitIndexer = {}

onTriggerInit(function()
    xpcall(function()
   --     print("onGameStart")
    
   --preplaced units
    local group = CreateGroup()
    GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, nil)
    
    ForGroup(group, function()
        local unit = GetEnumUnit()
        UnitIndexer[GetHandleId(unit)] = unit
    end)
    
    local trigger = CreateTrigger()
    TriggerRegisterEnterRectSimple(trigger, bj_mapInitialPlayableArea)
    TriggerAddAction(trigger, function()
        local unit = GetTriggerUnit()
        UnitIndexer[GetHandleId(unit)] = unit
    end)

    UnitIndexer.TriggerEnter = trigger
    local trigger = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddAction(trigger, function()
        local unit = GetTriggerUnit()
        if not IsUnitType(unit, UNIT_TYPE_HERO) then 
            UnitIndexer[GetHandleId(unit)] = nil
        end
    end)
    UnitIndexer.TriggerDeath = trigger
    
    DestroyGroup(group)

end, err)
end)
