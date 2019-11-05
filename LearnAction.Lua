do --LearnAction 1.0 by Tasyen
    LearnAction = {}
    function LearnActionInit()
        LearnAction[0] = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(LearnAction[0], EVENT_PLAYER_HERO_SKILL)
        TriggerAddAction(LearnAction[0], function() if LearnAction[GetLearnedSkill()] then LearnAction[GetLearnedSkill()]() end end)
    end
end
