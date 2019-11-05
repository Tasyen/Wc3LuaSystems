--[[SpellActionEx 1.0 by Tasyen

SpellAction.setOnEffect(spell, actionFunction)
    spell (can also be a spellCode FourCC('AHhb') ) calls actionFunction onSpellEffect Event
SpellAction.setOnEnd(spell, actionFunction)
SpellAction.setOnCast(spell, actionFunction)
SpellAction.setOnChannel(spell, actionFunction)
SpellAction.setOnFinish(spell, actionFunction)
--]]
SpellAction = {}
SpellCast = {}
TimerStart(CreateTimer(), 0, false, function()
    SpellAction[1] = CreateTrigger()
    SpellAction[SpellAction[1]] = EVENT_PLAYER_UNIT_SPELL_EFFECT
    TriggerRegisterAnyUnitEventBJ(SpellAction[1], EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddAction(SpellAction[1], SpellAction.action)
    
    SpellAction[2] = CreateTrigger()
    SpellAction[SpellAction[2]] = EVENT_PLAYER_UNIT_SPELL_FINISH
    TriggerRegisterAnyUnitEventBJ(SpellAction[2], EVENT_PLAYER_UNIT_SPELL_FINISH)
    TriggerAddAction(SpellAction[2], SpellAction.action)
    
    SpellAction[3] = CreateTrigger()
    SpellAction[SpellAction[3]] = EVENT_PLAYER_UNIT_SPELL_ENDCAST
    TriggerRegisterAnyUnitEventBJ(SpellAction[3], EVENT_PLAYER_UNIT_SPELL_ENDCAST)
    TriggerAddAction(SpellAction[3], SpellAction.action)
    
    SpellAction[4] = CreateTrigger()
    SpellAction[SpellAction[4]] = EVENT_PLAYER_UNIT_SPELL_CAST
    TriggerRegisterAnyUnitEventBJ(SpellAction[4], EVENT_PLAYER_UNIT_SPELL_CAST)
    TriggerAddAction(SpellAction[4], SpellAction.action)
    
    SpellAction[5] = CreateTrigger()
    SpellAction[SpellAction[5]] = EVENT_PLAYER_UNIT_SPELL_CHANNEL
    TriggerRegisterAnyUnitEventBJ(SpellAction[5], EVENT_PLAYER_UNIT_SPELL_CHANNEL)
    TriggerAddAction(SpellAction[5], SpellAction.rememberData)
    TriggerAddAction(SpellAction[5], SpellAction.action)

    
    DestroyTimer(GetExpiredTimer())
end)
function SpellAction.rememberData()
    --print("SpellAction.rememberData")
    local spell = GetSpellAbility()
    local spellCode = GetSpellAbilityId()
    if not SpellCast[spell] then SpellCast[spell] = {} end
    local data = SpellCast[spell]
    data.Caster = GetTriggerUnit()
    data.Target = GetSpellTargetUnit()
    data.X = GetSpellTargetX()
    data.Y = GetSpellTargetX()
    data.CasterLevel = math.max(GetUnitLevel(data.Caster), GetHeroLevel(data.Caster))
    data.Code = spellCode
    data.SpellLevel = GetUnitAbilityLevel(GetTriggerUnit(), spellCode)    
    if HeroSpell[spellCode] then
        data.Data =  HeroData[GetUnitTypeId(data.Caster)].Spell[HeroSpell[spellCode]].Calc(data.Caster, data.CasterLevel, spell, spellCode, data.SpellLevel)
    else
        data.Data = {}
    end
end
function SpellAction.action()
    --print("SpellAction.action")
    local event = SpellAction[GetTriggeringTrigger()]
    local spellCode = GetSpellAbilityId()
    local spell = GetSpellAbility()

    if SpellAction[spellCode] and SpellAction[spellCode][event] then SpellAction[spellCode][event](SpellCast[spell]) end --SpellType
    if SpellAction[spell] and SpellAction[spell][event] then SpellAction[spell][event](SpellCast[spell]) end --This Spell
end

function SpellAction.setAction(spell, event, actionFunction)
    if SpellAction[spell] then
        SpellAction[spell][event] = actionFunction
    else
        SpellAction[spell] = { [event] = actionFunction}
    end
end
function SpellAction.setOnEffect(spell, actionFunction)
    SpellAction.setAction(spell, EVENT_PLAYER_UNIT_SPELL_EFFECT, actionFunction)
end
function SpellAction.setOnEnd(spell, actionFunction)
    SpellAction.setAction(spell, EVENT_PLAYER_UNIT_SPELL_ENDCAST, actionFunction)
end
function SpellAction.setOnCast(spell, actionFunction)
    SpellAction.setAction(spell, EVENT_PLAYER_UNIT_SPELL_CAST, actionFunction)
end
function SpellAction.setOnChannel(spell, actionFunction)
    SpellAction.setAction(spell, EVENT_PLAYER_UNIT_SPELL_CHANNEL, actionFunction)
end
function SpellAction.setOnFinish(spell, actionFunction)
    SpellAction.setAction(spell, EVENT_PLAYER_UNIT_SPELL_FINISH, actionFunction)
end

