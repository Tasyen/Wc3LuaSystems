do --SpellAction 1.0 by Tasyen
    SpellAction = {}
    TimerStart(CreateTimer(), 0, false, function()
        SpellAction[1] = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(SpellAction[1], EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(SpellAction[1], function()
            if SpellAction[GetSpellAbilityId()] then SpellAction[GetSpellAbilityId()]() end --SpellType
            if SpellAction[GetSpellAbility()] then SpellAction[GetSpellAbility()]() end --This Spell
        end)
        DestroyTimer(GetExpiredTimer())
    end)
end


function Test()
	SpellAction[FourCC('AHbz')] = function() print("Cast Blizzard")end
	SpellAction[FourCC('AHfs')] = function() print("Cast Flammschenschlag")end
    SpellAction[FourCC('AHhb')] = function()
        local spell = GetSpellAbility()
        if IsUnitAlly(GetSpellTargetUnit(), GetTriggerPlayer()) then SetWidgetLife(GetSpellTargetUnit(), 99999) elseif IsUnitRace(GetSpellTargetUnit(), RACE_DEMON) then KillUnit() end
    end
	SpellAction[FourCC('AHtb')] = function() KillUnit(GetSpellTargetUnit()) end
	SpellAction[FourCC('AHds')] = function() SetWidgetLife(GetTriggerUnit(), 99999) end
	SpellAction[FourCC('AHbn')] = function() ShowUnit(GetSpellTargetUnit(), false) end
	SpellAction[FourCC('AHtc')] = function() ShowUnit(GetSpellTargetUnit(), false) end
end
Test()