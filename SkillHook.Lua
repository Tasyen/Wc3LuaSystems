do
    --[[
    SkillHook 1.0 by Tasyen
    will hook into UnitAddAbility and UnitRemoveAbility allowing to add actions when adding/removing abilities. Custom added action only trigger when the real action was a success.
    your custom function should have 2 args (unit, abiCode)
    Preplaced abilities, morphed and Enginered will not trigger custom Gain/Lose actions
    --]]
    SkillHook = {}
    SkillHook.IncludeLearn = true --Skillpoint learned skills proc the addActions every time they are skilled, does also happen for preplaced skills.
    function SkillHook.Add(abiCode, onGain, onLose)
        SkillHook[abiCode] = {Gain = onGain, Lose = onLose}
    end
    local realUnitAddAbility = UnitAddAbility
    function UnitAddAbility(unit, abiCode)
	    print("add", GetObjectName(abiCode))
        --when the ability was added and the unit did not have it, then call the custom action.
        if realUnitAddAbility(unit, abiCode) then
            if SkillHook[abiCode] and SkillHook[abiCode].Gain then SkillHook[abiCode].Gain(unit, abiCode) end
        end
    end
    local realUnitRemoveAbility = UnitRemoveAbility
    function UnitRemoveAbility(unit, abiCode)
        --when the ability was added and the unit did not have it, then call the custom action.
        if realUnitRemoveAbility(unit, abiCode) then
            if SkillHook[abiCode] and SkillHook[abiCode].Lose then SkillHook[abiCode].Lose(unit, abiCode) end
        end
    end
    if SkillHook.IncludeLearn then
        SkillHook.LearnTrigger = CreateTrigger()
        SkillHook.LearnEvent = {}
        for index = 0, GetBJMaxPlayerSlots() - 1,1 do
            table.insert( SkillHook.LearnEvent , TriggerRegisterPlayerUnitEvent(SkillHook.LearnTrigger, Player(index), EVENT_PLAYER_HERO_SKILL, nil))
        end
        SkillHook.LearnTriggerAction = TriggerAddAction(SkillHook.LearnTrigger, function()
            local abiCode = GetLearnedSkill()
            if SkillHook[abiCode] and SkillHook[abiCode].Gain then SkillHook[abiCode].Gain(GetTriggerUnit(), abiCode) end
        end)
    end
end
