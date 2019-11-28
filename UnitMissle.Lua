
function Unit2UnitMissle(sourceUnit, targetUnit, speed, modelName, damage, attackType, damageType, actionFunction)
    speed = speed * 0.02 --convert Speed a second into speed a timeout
    local loc = GetUnitLoc(sourceUnit)
    local locTarget = GetUnitLoc(targetUnit)
    local eff = AddSpecialEffectLoc(modelName, loc)
    local flyingTime = 0
    BlzSetSpecialEffectColorByPlayer(eff, GetOwningPlayer(sourceUnit))
    BlzSetSpecialEffectYaw(eff, AngleBetweenPoints(loc, locTarget)*bj_DEGTORAD)
    BlzSetSpecialEffectHeight(eff, 60)
    TimerStart(CreateTimer(), 0.02, true, function()
        flyingTime = flyingTime + 0.02
        if not IsUnitInRangeLoc(targetUnit, loc, 0) and GetUnitTypeId(targetUnit) > 0 then
            MoveLocation(locTarget, GetUnitX(targetUnit), GetUnitY(targetUnit))
            local radians = AngleBetweenPoints(loc, locTarget)*bj_DEGTORAD
            MoveLocation(loc, GetLocationX(loc) + Cos(radians) * speed, GetLocationY(loc) + Sin(radians) * speed)
            
            BlzSetSpecialEffectPositionLoc(eff, loc)
            BlzSetSpecialEffectHeight(eff, 60)
            BlzSetSpecialEffectYaw(eff, radians)
        else
            if GetUnitTypeId(targetUnit) > 0 then
                UnitDamageTarget(sourceUnit, targetUnit, damage, true, true, attackType, damageType, nil)
                if actionFunction then
                    actionFunction(sourceUnit, targetUnit, flyingTime)
                end
            end
            RemoveLocation(loc)
            RemoveLocation(locTarget)
            DestroyEffect(eff)
            PauseTimer(GetExpiredTimer())
            DestroyTimer(GetExpiredTimer())
        end
    end)
end