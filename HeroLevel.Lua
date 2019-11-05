do
    --[[
    HeroLevel 1.0 by Tasyen
    
    --]]
    
    local function GetLevel(unit)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return GetHeroLevel(unit)
        else
            return GetUnitLevel(unit)
        end
    end
    local function MinLevel(unit)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 1
        else
            return 0
        end
    end
    HeroLevel = {}
    HeroLevel.Trigger = CreateTrigger()
    function HeroLevel.action(unit, oldLevel)
        if not oldLevel then oldLevel = HeroLevel[unit] or MinLevel(unit) end
        local newLevel = GetLevel(unit)
        local unitCode = GetUnitTypeId(unit)
        if HeroLevel[unitCode] and oldLevel ~= newLevel then HeroLevel[unitCode](unit, oldLevel, GetLevel(unit)) end
        HeroLevel[unit] = GetLevel(unit) --might have changed
    end
    HeroLevel.TriggerAction = TriggerAddAction(HeroLevel.Trigger, function()
        HeroLevel.action(GetTriggerUnit())
    end)

    local realBlzSetUnitIntegerField = BlzSetUnitIntegerField
    function BlzSetUnitIntegerField(whichUnit, whichField, value)
        local oldLevel = GetLevel(unit)
        local returnValue = realBlzSetUnitIntegerField(whichUnit, whichField, value)
        if whichField == UNIT_IF_LEVEL and not IsUnitType(whichUnit, UNIT_TYPE_HERO) then HeroLevel.action(whichUnit, oldLevel) end
        return returnValue
    end
    onTriggerInit(function()
        TriggerRegisterAnyUnitEventBJ(HeroLevel.Trigger, EVENT_PLAYER_HERO_LEVEL)
    --  for index = 0, GetBJMaxPlayerSlots() - 1,1 do
        --table.insert(HeroLevel, TriggerRegisterPlayerUnitEvent(HeroLevel.Trigger, Player(index), EVENT_PLAYER_HERO_LEVEL, nil))
        --end
    end)
    
    
end