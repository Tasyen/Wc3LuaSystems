--prints orders done of any unit
TimerStart(CreateTimer(),0,false, function()
    local tr = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER )
    TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER )
    TriggerRegisterAnyUnitEventBJ(tr, EVENT_PLAYER_UNIT_ISSUED_ORDER )
    TriggerAddAction(tr,  function()
        local orderId = GetIssuedOrderId()
        local orderString = OrderId2String(orderId)
        local targetName
        -- Is Their a Target?
        if GetOrderTarget() then
            --Get Targets Name according to its type.
            if GetOrderTargetUnit() then
                targetName = GetUnitName(GetOrderTargetUnit())
            else
                if GetOrderTargetItem() then
                    targetName = GetItemName(GetOrderTargetItem())
                else
                    if GetOrderTargetDestructable() then
                        targetName = GetDestructableName(GetOrderTargetDestructable())
                    end
                end
            end
        end
        -- If no Order-String Avaible try to get Objects-Name
        if orderString == "" then
            orderString = GetObjectName(orderId)
        end

        -- Print "-> targetName" ?
        if GetOrderTarget() then
            DisplayTimedTextToPlayer(GetLocalPlayer(),0,0, 8.00,  GetUnitName(GetTriggerUnit()) ..  " - " ..  orderString .." / ".. I2S(orderId) ..  " -> " .. targetName )
        elseif GetOrderPointX() ~= 0 and GetOrderPointY() ~= 0 then
            DisplayTimedTextToPlayer(GetLocalPlayer(),0,0, 8.00,  GetUnitName(GetTriggerUnit()) ..  " - " ..  orderString .." / ".. I2S(orderId) ..  " -> (" .. string.format("%%.1f", GetOrderPointX()).. " / " .. string.format("%%.1f", GetOrderPointY())..")" )
        else
            DisplayTimedTextToPlayer(GetLocalPlayer(),0,0, 8.00,  GetUnitName(GetTriggerUnit()) ..  " - " ..  orderString .." / ".. I2S(orderId) )
        end
    end)
end)
