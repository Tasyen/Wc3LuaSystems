--data Set For BuffAction by Tasyen
--this defines which data Buffs can grant and what to do with that.
BuffActionData = {}

BuffActionData.Attack = function(unit, amount)
    BlzSetUnitBaseDamage(unit, BlzGetUnitBaseDamage(unit, 0) + amount, 0)
end

BuffActionData.AttackSpeed = function(unit, amount)
    BlzSetUnitAttackCooldown(unit, BlzGetUnitAttackCooldown(unit, 0) + amount, 0)
end

BuffActionData.Life = function(unit, amount)
    local percent = GetUnitLifePercent(unit)
    BlzSetUnitMaxHP(unit, BlzGetUnitMaxHP(unit, 0) + amount)
    SetUnitLifePercentBJ(unit, percent)
end
BuffActionData.Mana = function(unit, amount)
    local percent = GetUnitManaPercent(unit)
    BlzSetUnitMaxMana(unit, BlzGetUnitMaxMana(unit) + amount)
    SetUnitManaPercentBJ(unit, percent)
end

BuffActionData.ManaReg = function(unit, amount)
    BlzSetUnitRealField(unit, UNIT_RF_MANA_REGENERATION, BlzGetUnitRealField(unit, UNIT_RF_MANA_REGENERATION) + amount)
end

BuffActionData.LifeReg = function(unit, amount)
    BlzSetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE, BlzGetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE) + amount)
end

BuffActionData.Ability = function(unit, abilityCode)
    if abilityCode > 0 then
        UnitAddAbility(unit, abilityCode)
    else
        UnitRemoveAbility(unit, - abilityCode)
    end
end
