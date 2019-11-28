

BuffDot = {}

-- source, the unit dealing damage
-- target, the unit taking damage
-- damage the total damage amount
-- duration how long this effect keeps
-- interval seconds after this is started and every interval seconds after the first damage is dealt
-- buffCode the Ability/Buff the unit needs to have, if he does not, inside a damage intervale the dot ends.
-- returns the table managing the dot
-- one can write .EffectTime, .Effect and .EffectPoint to display an effect attached to the unit one each damage intervale
function BuffDot.add(source, target, damage, duration, intervale, buffCode, attackType, damageType)
    if not attackType then attackType = ATTACK_TYPE_NORMAL end
    if not damageType then damageType = DAMAGE_TYPE_MAGIC end

    if not BuffDot[source] then BuffDot[source] = {} end
    if not BuffDot[source][buffCode] then BuffDot[source][buffCode] = {} end
    if not BuffDot[source][buffCode][target] then 
        --local iterations = math.modf(intervale / (duration+0.00))
        local iterations = math.modf(duration / intervale)
        local data = {
            Source = source,
            Target = target,
            Damage = damage / iterations,
            TypeAttack = attackType,
            TypeDamage = damageType,
            TimerDamage = CreateTimer(),
            TimerExpire = CreateTimer(),
            BuffCode = buffCode
        }
        BuffDot[data.TimerDamage] = data
        BuffDot[data.TimerExpire] = data
        TimerStart(data.TimerDamage, intervale,true, BuffDot.TimerDamageAction)
        TimerStart(data.TimerExpire, duration, false, BuffDot.TimerExpireAction)
        BuffDot[source][buffCode][target] = data
        return data
    else
        local data = BuffDot[source][buffCode][target]
        local iterations = math.modf(duration / intervale)
        data.Damage = damage / iterations
        data.TypeAttack = attackType
        data.TypeDamage = damageType
        --TimerStart(data.TimerDamage, intervale,true, BuffDot.TimerDamageAction)
        TimerStart(data.TimerExpire, duration, false, BuffDot.TimerExpireAction)
        return data
    end
end

function BuffDot.TimerDamageAction()
    local data = BuffDot[GetExpiredTimer()]
    if BlzGetUnitAbility(data.Target, data.BuffCode) then
        UnitDamageTarget(data.Source, data.Target, data.Damage, false, true, data.TypeAttack, data.TypeDamage, nil)
        if data.Effect then
            local effect = AddSpecialEffectTarget(data.Effect, data.Target, data.EffectPoint)
            if data.EffectTime and data.EffectTime > 0 then
                TimerStart(CreateTimer(), data.EffectTime, false, function()
                    DestroyEffect(effect)
                    DestroyTimer(GetExpiredTimer())
                end)
            else
                DestroyEffect(effect)
            end
        end
    else
        TimerStart(data.TimerExpire, 0.0, false, BuffDot.TimerExpireAction)
    end

end

function BuffDot.TimerExpireAction()
    local data = BuffDot[GetExpiredTimer()]
    PauseTimer(data.TimerDamage)
    PauseTimer(data.TimerExpire)
    DestroyTimer(data.TimerDamage)
    DestroyTimer(data.TimerExpire)
    BuffDot[data.Source][data.BuffCode][data.Target] = nil
    data.Source = nil
    data.Target = nil
    data.TimerDamage = nil
    data.TimerExpire = nil

end
