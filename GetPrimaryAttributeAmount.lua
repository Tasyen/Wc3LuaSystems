function GetHeroPrim(unit, includeBoni)
    if IsUnitType(unit, UNIT_TYPE_HERO) then
        local primary = ConvertHeroAttribute(BlzGetUnitIntegerField(unit, UNIT_IF_PRIMARY_ATTRIBUTE))

        if primary == HERO_ATTRIBUTE_STR then
            return GetHeroStr(unit, includeBoni)
        elseif primary == HERO_ATTRIBUTE_AGI then
            return GetHeroAgi(unit, includeBoni)
        elseif primary == HERO_ATTRIBUTE_INT then
            return GetHeroInt(unit, includeBoni)
        else
            return 0
        end
    else
        return 0
    end
end