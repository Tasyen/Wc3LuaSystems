--[[
BuffAction 1.0
by Tasyen

Grant a bonus as long an unit has an Ability/Buff. Has to be evoked when an unit gains the buff.

function BuffAction.add(unit, buffCode, buffActionData)
    as long unit has buffCode it benefits from buffActionData.
    buffActionData is a table it calls BuffActionData[key] with amount on gain on expire it calls the same functions with -amount.
    BuffAction.add(unit, FourCC('Binf'), {Attack = 20}) would call BuffActionData.Attack(unit, 20) granting 20 Base damage while Binf is on the unit.
--]]

BuffAction = {}
BuffAction.Timer = CreateTimer()

function BuffAction.add(unit, buffCode, buffActionData)
    local buffObject = nil
    if not BuffAction[unit] then BuffAction[unit] = {Count = 0} end
    -- new buff?
    if not BuffAction[unit][buffCode] then
        buffObject = {
            Unit = unit,
            BuffCode = buffCode,
            Data = buffActionData
        }
        
        table.insert(BuffAction, buffObject)
    
        BuffAction[unit][buffCode] = buffObject
        BuffAction[unit].Count = BuffAction[unit].Count + 1
        -- apply bonus
        if buffActionData and BuffActionData then
            for key, value in pairs(buffActionData)
            do
                --print(key)
                if BuffActionData[key] then BuffActionData[key](unit, value) end
            end
        end
        print("BuffAction[unit].Count",BuffAction[unit].Count)
        if #BuffAction == 1 then TimerStart(BuffAction.Timer, 0.1, true, BuffAction.TimerAction) end
    else
        -- rebuff
        buffObject = BuffAction[unit][buffCode]

        -- has data
        if buffActionData and BuffActionData then

            -- remove unset Boni
            for key, value in pairs(buffObject.Data)
            do
                if BuffActionData[key] then
                    if not buffActionData[key] then
                        BuffActionData[key](unit, -value)
                        buffObject.Data[key] = nil
                    end
                end
            end

            -- add/update bonus
            for key, value in pairs(buffActionData)
            do
                if BuffActionData[key] then
                    --print(key)
                    -- add a new effect?
                    if not buffObject.Data[key] then
                        BuffActionData[key](unit, value)
                        
                    -- collision
                    else
                        local diff = value - buffObject.Data[key]
                        if diff ~= 0 then
                            BuffActionData[key](unit, diff)
                        end
                    end
                    buffObject.Data[key] = value
                end
            end
            
        end
    end
    
    return buffObject
end

function BuffAction.TimerAction()
    for index = #BuffAction, 1, -1 do
        local buffObject = BuffAction[index]
        -- expired?
        if not BlzGetUnitAbility(buffObject.Unit, buffObject.BuffCode) then
            -- revert bonus
            if buffObject.Data and BuffActionData then
                for key, value in pairs(buffObject.Data)
                do
                    --print(key)
                    if BuffActionData[key] then BuffActionData[key](buffObject.Unit, -value) end
                end  
            end
           table.remove(BuffAction, index)
           BuffAction[buffObject.Unit][buffObject.BuffCode] = nil
           BuffAction[buffObject.Unit].Count = BuffAction[buffObject.Unit].Count - 1
           if BuffAction[buffObject.Unit].Count < 1 then
                BuffAction[buffObject.Unit] = nil
           end
           if #BuffAction == 0 then PauseTimer(BuffAction.Timer) end
        end
    end
end