--[[
    ToggleIconButton 1.0 by Tasyen

function CreateToggleIconButton(parent, valueOn, sharedByAll, text, textureOn[, textureOff, textOff])
 create an IconButton that swaps between 2 states. (0 and valueOn, visualy shown by textureOff/textureOn)
 the IconButton starts with 0
 textureOff is automatically calced when it is nil
 sharedByAll(false) the value and texture changes only for the local player.
 You can add an Action function with object.Action = function(object, player, enabled)
 that function will consider SharedByAll. object is the active ToggleIconButtonTable and player the clicking player.

function ToggleIconButtonSetValue(object, player[, enable])
 can be used to set the current value to x (true, false) or to toggle the current value(nil)
 will not call the object's Action.

to read the current Value read: <object>.Value
--]]

ToggleIconButton = {
    DefaultSizeX = 0.024,
    DefaultSizeY = 0.024,
}

ToggleIconButton.Trigger = CreateTrigger()
ToggleIconButton.TriggerAction = TriggerAddAction(ToggleIconButton.Trigger, function()
    xpcall(function()
    local frame = BlzGetTriggerFrame()
    local object = ToggleIconButton[frame]
    local player = GetTriggerPlayer()
    --ToggleIconButtonSetValue(object, GetTriggerPlayer(), object.Value ~= object.ValueOn)
    ToggleIconButtonSetValue(object, player)
    if object.Action and (object.SharedByAll or GetLocalPlayer() == player) then object.Action(object, player, object.Value == object.ValueOn) end
    -- remove focus
    BlzFrameSetEnable(frame, false)
    BlzFrameSetEnable(frame, true)
    end, print)
end)


function ToggleIconButtonSetValue(object, player, enable)
    if object.SharedByAll or GetLocalPlayer() == player then
        -- wana toggle?
        if enable == nil then
            --currently off?
            if object.Value ~= object.ValueOn then
                object.Value = object.ValueOn
                BlzFrameSetTexture(object.Icon, object.Texture, 0, false)
                BlzFrameSetText(object.ToolTip, object.Text)
            else
                object.Value = 0
                BlzFrameSetTexture(object.Icon, object.TextureOff, 0, false)
                BlzFrameSetText(object.ToolTip, object.TextOff)
            end
        -- specific state
        else
            if enable then
                object.Value = object.ValueOn
                BlzFrameSetTexture(object.Icon, object.Texture, 0, false)
                BlzFrameSetText(object.ToolTip, object.Text)
            else
                object.Value = 0
                BlzFrameSetTexture(object.Icon, object.TextureOff, 0, false)
                BlzFrameSetText(object.ToolTip, object.TextOff)
            end
        end
    end
end

function getDisabledIcon(icon)
    --ReplaceableTextures\CommandButtons\BTNHeroPaladin.tga -> ReplaceableTextures\CommandButtonsDisabled\DISBTNHeroPaladin.tga
    return string.gsub(icon , "CommandButtons\\BTN", "CommandButtonsDisabled\\DISBTN")
end

function ToggleIconButton.CreateTooltip(frame, text)
    --local toolTip = BlzCreateFrame("EscMenuMainPanelDialogTextTemplate", frame, 0, 0)
    local toolTip = BlzCreateFrameByType("TEXT", "TasCategoryButtonTooltip", frame, "", 0)
    BlzFrameSetEnable(toolTip, false)
    BlzFrameSetPoint(toolTip, FRAMEPOINT_BOTTOM, frame, FRAMEPOINT_TOP, 0, 0)
    BlzFrameSetText(toolTip, text)
    BlzFrameSetScale(toolTip, 1.2)
    BlzFrameSetTooltip(frame, toolTip)
    return toolTip
end


function CreateToggleIconButton(parent, valueOn, sharedByAll, text, textureOn, textureOff, textOff)
    if not textureOff then textureOff = getDisabledIcon(textureOn) end
    if not textOff then textOff = text end

    local frame = BlzCreateFrameByType("BUTTON", "TasCategoryButton", parent, "ScoreScreenTabButtonTemplate", 0)
    local backdrop = BlzCreateFrameByType("BACKDROP", "TasCategoryButtonIcon", frame, "", 0)
    BlzFrameSetAllPoints(backdrop, frame)
    BlzFrameSetSize(frame, ToggleIconButton.DefaultSizeX, ToggleIconButton.DefaultSizeY)
    BlzFrameSetTexture(backdrop, textureOff, 0, false)
    BlzTriggerRegisterFrameEvent(ToggleIconButton.Trigger, frame, FRAMEEVENT_CONTROL_CLICK)

    local object = {
        Button = frame,
        Icon = backdrop,
        SharedByAll = sharedByAll,
        Value = 0,
        ValueOn = valueOn,
        Texture = textureOn,
        TextureOff = textureOff,
        Text = text,
        TextOff = textOff,
        ToolTip = ToggleIconButton.CreateTooltip(frame, textOff)
    }
    ToggleIconButton[frame] = object
    
    return object
end
