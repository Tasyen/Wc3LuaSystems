--[[
UnitBonus by Tasyen
======
function UnitBonus.remove(unit, whichType)
    removes the ability providing the bonus
function UnitBonus.set(unit, whichType, amount)
    add the ability and set the bonus provided
function UnitBonus.get(unit, whichType)
function UnitBonus.add(unit, whichType, amount)
    adds amount to the current bonus
function UnitBonus.addEx(unit, whichType, amount, delay, duration)
    gain amount after delay seconds and then after duration seconds passed lose amount.
    the losing part can be skiped by not setting duration or having duration of 0 or smaller
--]]

UnitBonus = {}
function UnitBonus.updateLevel(unit, data)
    IncUnitAbilityLevel(unit, data.Skill)
    DecUnitAbilityLevel(unit, data.Skill)
end
function UnitBonus.updateInt(unit, data)
    SetHeroInt(unit, GetHeroInt(unit, false)+1, true)
    SetHeroInt(unit, GetHeroInt(unit, false)-1, true)
end
function UnitBonus.updateStr(unit, data)
    print("update Str", unit, data)
    --UnitAddAbility(unit, FourCC('AIlf'))
--    UnitRemoveAbility(unit, FourCC('AIlf'))
    SetHeroStr(unit, GetHeroStr(unit, false)+1, true)
    --SetHeroStr(unit, GetHeroStr(unit, false)-1, true)
end
UnitBonus.Data = {}

--define abilities providing the bonuses and which field is update using which function for Get and Set
--Skill = FourCC(abiliCode)
--Field = which field is read/write
--Get = which function is used in reading
--Set = which function is used in writting
--Update = the function called to apply changes, needed for some values.

--ability clone of 'Aamk' Hero Attributes
UnitBonus.Data["STR"] = {Skill = FourCC('A000'), Field = ABILITY_ILF_STRENGTH_BONUS_ISTR, Get = BlzGetAbilityIntegerLevelField, Set = BlzSetAbilityIntegerLevelField, Update = UnitBonus.updateLevel}
UnitBonus.Data["AGI"] = {Skill = FourCC('A000'), Field = ABILITY_ILF_AGILITY_BONUS, Get = BlzGetAbilityIntegerLevelField, Set = BlzSetAbilityIntegerLevelField, Update = UnitBonus.updateLevel}
UnitBonus.Data["INT"] = {Skill = FourCC('A000'), Field = ABILITY_ILF_INTELLIGENCE_BONUS, Get = BlzGetAbilityIntegerLevelField, Set = BlzSetAbilityIntegerLevelField, Update = UnitBonus.updateLevel}
--claw of attack
UnitBonus.Data["ATK"] = {Skill = FourCC('A002'), Field = ABILITY_ILF_ATTACK_BONUS, Get = BlzGetAbilityIntegerLevelField, Set = BlzSetAbilityIntegerLevelField, Update = UnitBonus.updateLevel}
UnitBonus.Data["DMG"] = UnitBonus.Data["ATK"] -- one can also use "DMG" for attack damage
--gloves
UnitBonus.Data["ATKSP"] = {Skill = FourCC('A004'), Field = ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField, Update = UnitBonus.updateLevel}
--armor item
UnitBonus.Data["DEF"] = {Skill = FourCC('A003'), Field = ABILITY_ILF_DEFENSE_BONUS_IDEF, Get = BlzGetAbilityIntegerLevelField, Set = BlzSetAbilityIntegerLevelField, Update = UnitBonus.updateLevel}

--based on 'ACev'
UnitBonus.Data["EVADE"] = {Skill = FourCC('A00B'), Field = ABILITY_RLF_CHANCE_TO_EVADE_EEV1, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
--trunken fighter or orc crit
UnitBonus.Data["KRIT_CHANCE"] = {Skill = FourCC('A005'), Field = ABILITY_RLF_CHANCE_TO_CRITICAL_STRIKE, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["KRIT_FACTOR"] = {Skill = FourCC('A005'), Field = ABILITY_RLF_DAMAGE_MULTIPLIER_OCR2, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["KRIT_DAMAGE"] = {Skill = FourCC('A005'), Field = ABILITY_RLF_DAMAGE_BONUS_OCR3, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["KRIT_EVADE"] = {Skill = FourCC('A005'), Field = ABILITY_RLF_CHANCE_TO_EVADE_OCR4, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
--KRIT_DAMAGE is addtional spelldamage on krit.

--boots of speed skill, they don't stack anyway
UnitBonus.Data["MOVE"] = {Skill = FourCC('AIms'), Field = ABILITY_ILF_MOVEMENT_SPEED_BONUS, Get = BlzGetAbilityIntegerLevelField, Set = BlzSetAbilityIntegerLevelField, Update = UnitBonus.updateLevel}

--elunes grace 'Aegr'
UnitBonus.Data["MAGIC_RES"] = {Skill = FourCC('A006'), Field = ABILITY_RLF_MAGIC_DAMAGE_REDUCTION_DEF5, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["PIERCE_RES"] = {Skill = FourCC('A006'), Field = ABILITY_RLF_DAMAGE_TAKEN_PERCENT_DEF1, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}

--based on 'Ansk'
UnitBonus.Data["MELEE_BLOCK_AMOUNT"] = {Skill = FourCC('A007'), Field = ABILITY_RLF_IGNORED_DAMAGE, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["MELEE_BLOCK_MIN"] = {Skill = FourCC('A007'), Field = ABILITY_RLF_MINIMUM_DAMAGE, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["MELEE_BLOCK_CHANCE"] = {Skill = FourCC('A007'), Field = ABILITY_RLF_CHANCE_TO_REDUCE_DAMAGE_PERCENT, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
--based on 'Ansk'
UnitBonus.Data["RANGED_BLOCK_AMOUNT"] = {Skill = FourCC('A008'), Field = ABILITY_RLF_IGNORED_DAMAGE, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["RANGED_BLOCK_MIN"] = {Skill = FourCC('A008'), Field = ABILITY_RLF_MINIMUM_DAMAGE, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["RANGED_BLOCK_CHANCE"] = {Skill = FourCC('A008'), Field = ABILITY_RLF_CHANCE_TO_REDUCE_DAMAGE_PERCENT, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}

--'ANss'
UnitBonus.Data["SPELL_SHIELD"] = {Skill = FourCC('A009'), Field = ABILITY_RLF_COOLDOWN, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}

--'ACrn'
UnitBonus.Data["REINCARNATION_COOLDOWN"] = {Skill = FourCC('A001'), Field = ABILITY_RLF_COOLDOWN, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["REINCARNATION_DUR"] = {Skill = FourCC('A001'), Field = ABILITY_RLF_REINCARNATION_DELAY, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}

--Bash
UnitBonus.Data["BASH_CHANCE"] = {Skill = FourCC('A00A'), Field = ABILITY_RLF_CHANCE_TO_BASH, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["BASH_DAMAGE"] = {Skill = FourCC('A00A'), Field = ABILITY_RLF_DAMAGE_BONUS_HBH3, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["BASH_DUR"] = {Skill = FourCC('A00A'), Field = ABILITY_RLF_DURATION_NORMAL, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}
UnitBonus.Data["BASH_DURHERO"] = {Skill = FourCC('A00A'), Field = ABILITY_RLF_DURATION_HERO, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField}

UnitBonus.Data["LIFE_REG"] = {Skill = FourCC('A00C'), Field = ABILITY_ILF_HIT_POINTS_REGENERATED_PER_SECOND, Get = BlzGetAbilityIntegerLevelField, Set = BlzSetAbilityIntegerLevelField, Update = UnitBonus.updateStr}
UnitBonus.Data["MANA_REG"] = {Skill = FourCC('A00D'), Field = ABILITY_RLF_MANA_REGENERATION_BONUS_AS_FRACTION_OF_NORMAL, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField, Update = UnitBonus.updateInt}
--does not work, the area detected does not change
--UnitBonus.Data["TRUE_SIGHT"] = {Skill = FourCC('Adts'), Field = ABILITY_RLF_CAST_RANGE, Get = BlzGetAbilityRealLevelField, Set = BlzSetAbilityRealLevelField, Update = false}

function UnitBonus.set(unit, whichType, amount)
    local data = UnitBonus.Data[whichType]
    --if not BlzGetUnitAbility(unit, data.Skill) then UnitAddAbility(unit, data.Skill) end
    UnitAddAbility(unit, data.Skill)
    data.Set(BlzGetUnitAbility(unit, data.Skill), data.Field, 0, amount)
    if data.Update then
        data.Update(unit, data)
    end
end

function UnitBonus.get(unit, whichType)
    local spell = BlzGetUnitAbility(unit, UnitBonus.Data[whichType].Skill)
    if not spell then
        return 0
    else
        return UnitBonus.Data[whichType].Get(spell, UnitBonus.Data[whichType].Field, 0)
    end    
end
function UnitBonus.remove(unit, whichType)
    UnitRemoveAbility(unit, UnitBonus.Data[whichType].Skill)
end

function UnitBonus.add(unit, whichType, amount)
    UnitBonus.set(unit, whichType, UnitBonus.get(unit, whichType) + amount)
end

function UnitBonus.addEx(unit, whichType, amount, delay, duration)
    delay = math.max(0, delay)

    if delay > 0 then
        TimerStart(CreateTimer(), delay, false, function()
            UnitBonus.add(unit, whichType, amount)
            DestroyTimer(GetExpiredTimer())
        end)
    else
        UnitBonus.add(unit, whichType, amount)
    end

    if duration and duration > 0 then
        TimerStart(CreateTimer(), duration + duration, false, function()
            UnitBonus.add(unit, whichType, -amount)
            DestroyTimer(GetExpiredTimer())
        end)
    end
end
--[[
    function AddUnitBonusOverTime(whichUnit, whichType, amount, duration)
        local rate
        local rateTimer = CreateTimer()
        local add
        if whichType == "EVADE" or whichType == "KRIT" or whichType == "KRITDMG" or whichType == "ATKSP" then
            rate = duration/(amount*100)
            add = 0.01
        else
            rate = duration/amount
            add = 1
        end
        --print(rate, add, duration)
        TimerStart(rateTimer, rate, true, function()
            AddUnitBonus(whichUnit, whichType, add)
        end)
        TimerStart(CreateTimer(), duration + 0.001, false, function()
            PauseTimer(rateTimer)
            DestroyTimer(rateTimer)
            PauseTimer(GetExpiredTimer())
            DestroyTimer(GetExpiredTimer())
        end)
        
    end
end
--]]