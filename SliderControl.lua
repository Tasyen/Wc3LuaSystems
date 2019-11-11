--[[
    SliderControl V0.9 by Tasyen

    This generates Sliders with a Label and tooltips showing min max current value. The idea is to simple down slider usage.

function SliderControl.new(valueChangeActionFunction[, min, max, default, step, labelText, sizeText, sizeSlider, name, parent, createContext])
    this creates an slider with Label that executes valueChangeActionFunction when the value changes, the slider can be scrolled with the mouse whell.
    valueChangeActionFunction is called for all players when the sliders value changes, the function has one argument the sliderObject, normal FrameEvent getters are valid here.
    name is an suffix for all frames created by SliderControl, it only is relevant for BlzGetFrameByName or BlzFrameGetName
    sizeText + sizeSlider is the total screensize this takes
    default is the value reseted to when using SliderControl.reset
    the Label and Slider are placed into a container FRAME. Use returnValue.Frame to move/use the container.
    returns a table
    

function SliderControl.reset(sliderObject[, player])
    sets the slider of that sliderObject to the default Value will evoke the action, when not using player all players are affected

function SliderControl.destroy(sliderObject)
--]]
BlzLoadTOCFile("war3mapimported\\templates.toc") --loads ui\framedef\ui\escmenutemplates.fdf
SliderControl = {}
SliderControl.ScrollTrigger = CreateTrigger()
SliderControl.ScrollTriggerAction = TriggerAddAction(SliderControl.ScrollTrigger, function()
    local frame = BlzGetTriggerFrame()
    --update the value of the slider when rolling the mouse wheel, for the player having rolled the wheel.
    if GetLocalPlayer() == GetTriggerPlayer() then
        if BlzGetTriggerFrameValue() > 0 then
            BlzFrameSetValue(frame, BlzFrameGetValue(frame) + SliderControl[frame].StepSize )
        else
            BlzFrameSetValue(frame, BlzFrameGetValue(frame) - SliderControl[frame].StepSize)
        end
    end
end)

SliderControl.ValueTrigger = CreateTrigger()
SliderControl.ValueTriggerAction = TriggerAddAction(SliderControl.ValueTrigger, function()
    local frame = BlzGetTriggerFrame()
    local sliderObject = SliderControl[frame]
    --update the current text to the new value, but only if the local player was the player who changed the value
    if GetLocalPlayer() == GetTriggerPlayer() then
        BlzFrameSetText(sliderObject.TextCurrent, string.format(sliderObject.Format, BlzFrameGetValue(frame)))
    end

    --when there is an action call it
    if sliderObject.Action then
        sliderObject.Action(sliderObject)
    end

end)

function SliderControl.reset(sliderObject, player)
    if not player or GetLocalPlayer() == GetTriggerPlayer() then
        BlzFrameSetValue(sliderObject.Slider, sliderObject.Default)
    end
end

function SliderControl.new(valueChangeActionFunction, min, max, default, step, labelText, sizeText, sizeSlider, name, parent, createContext)
    local newObject = {}
    --setup unset data
    if not createContext then createContext = 0 end
    if not parent then parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) end
    if not name then name = "" end
    if not step then step = 1 end
    if not sizeSlider then sizeSlider = 0.12 end
    if not sizeText then sizeText = 0.12 end
    if not min then min = 1 end
    if not max then max = 100 end
    if not default then default =max/2 end
    if not step then step = 1 end

    newObject.Format = "%%.1f"
    newObject.Action = valueChangeActionFunction
    --this is the container of the Slider and Label
    newObject.Frame = BlzCreateFrameByType("FRAME", "SliderControlFrame_"..name, parent, "", createContext)
    BlzFrameSetSize(newObject.Frame, sizeText + sizeSlider, 0.013)
    BlzFrameSetEnable(newObject.Frame, false)

    newObject.Slider = BlzCreateFrameByType("SLIDER", "SliderControlSlider_"..name, newObject.Frame, "EscMenuSliderTemplate", createContext)
    SliderControl[newObject.Slider] = newObject
    BlzFrameSetSize(newObject.Slider, sizeSlider, 0.012)
    BlzFrameSetMinMaxValue(newObject.Slider, min, max)
    BlzFrameSetStepSize(newObject.Slider, step)
    BlzFrameSetValue(newObject.Slider, default)
    newObject.StepSize = step
    newObject.Default = default

    BlzTriggerRegisterFrameEvent(SliderControl.ScrollTrigger, newObject.Slider , FRAMEEVENT_MOUSE_WHEEL)
    BlzTriggerRegisterFrameEvent(SliderControl.ValueTrigger, newObject.Slider , FRAMEEVENT_SLIDER_VALUE_CHANGED)
    
    newObject.Label = BlzCreateFrameByType("TEXT", "SliderControlLabel_"..name, newObject.Frame, "EscMenuMainPanelDialogTextTemplate", createContext)
    BlzFrameSetText(newObject.Label, labelText)

    newObject.Tooltip = BlzCreateFrameByType("FRAME", "SliderControlTooltip_"..name, newObject.Frame, "", createContext)
    newObject.TextMin = BlzCreateFrameByType("TEXT", "SliderControlTextMin_"..name, newObject.Tooltip, "EscMenuMainPanelDialogTextTemplate", createContext)
    newObject.TextMax = BlzCreateFrameByType("TEXT", "SliderControlTextMax_"..name, newObject.Tooltip, "EscMenuMainPanelDialogTextTemplate", createContext)
    newObject.TextCurrent = BlzCreateFrameByType("TEXT", "SliderControlTextCurrent_"..name, newObject.Tooltip, "EscMenuMainPanelDialogTextTemplate", createContext)

    BlzFrameSetText(newObject.TextMin, min)
    BlzFrameSetText(newObject.TextMax, max)
    BlzFrameSetText(newObject.TextCurrent, string.format( "%%.1f", BlzFrameGetValue(newObject.Slider)))
    BlzFrameSetEnable(newObject.Tooltip, false)
    BlzFrameSetTooltip(newObject.Slider, newObject.Tooltip)

    BlzFrameSetPoint(newObject.TextMin, FRAMEPOINT_BOTTOM, newObject.Slider, FRAMEPOINT_TOPLEFT, 0, 0)
    BlzFrameSetPoint(newObject.TextMax, FRAMEPOINT_BOTTOM, newObject.Slider, FRAMEPOINT_TOPRIGHT, 0, 0)
    BlzFrameSetPoint(newObject.TextCurrent, FRAMEPOINT_BOTTOM, newObject.Slider, FRAMEPOINT_TOP, 0, 0)

    BlzFrameSetPoint(newObject.Label, FRAMEPOINT_LEFT, newObject.Frame, FRAMEPOINT_LEFT, 0, 0)
    BlzFrameSetPoint(newObject.Slider, FRAMEPOINT_RIGHT, newObject.Frame, FRAMEPOINT_RIGHT, 0, 0)

    return newObject
end

function SliderControl.destroy(sliderObject)
    SliderControl[sliderObject.Slider] = nil
    BlzDestroyFrame(sliderObject.Label)
    BlzDestroyFrame(sliderObject.Slider)
    BlzDestroyFrame(sliderObject.TextCurrent)
    BlzDestroyFrame(sliderObject.TextMax)
    BlzDestroyFrame(sliderObject.TextMin)
    BlzDestroyFrame(sliderObject.Tooltip)
    BlzDestroyFrame(sliderObject.Frame)

    sliderObject.Label = nil
    sliderObject.Slider = nil
    sliderObject.TextCurrent = nil
    sliderObject.TextMax = nil
    sliderObject.TextMin = nil
    sliderObject.Tooltip = nil
    sliderObject.Frame = nil
end
