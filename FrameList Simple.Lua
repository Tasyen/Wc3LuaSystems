--[[
    FrameList Simple V1.0 by Tasyen
    A Frame that contains 1 Col of Frames, a fraction of the added Frames is displayed at once. The user can change the shown frames by scrolling a slider.
    FrameLists can also contain a FrameList.
    The displayed amount of Frames depends on the FrameList size, this Size only changes when changed with BlzFrameSetSize or better the special version added into this.

    FrameList Simple does not require a fdf

    function FrameList.create([parent, createContext])
        creates a new FrameList       

    function FrameList.setSize(frameListTable, xSize, ySize)
        a custom Width seter, it makes the slider more accurate without the slider can not be clicked correctly.

    function FrameList.add(frameListTable, frame)
        adds frame to as last element of frameListTable

    function FrameList.remove(frameListTable, frame, noUpdate)
        removes frame (can be a number) from frameListTable, skip noUpdate that is only used from FrameList.destory

    function FrameList.destory(frameListTable)
        Destroys the frameListTable control Frames and hides and clears all points Frames in the FrameList

    function FrameList.setContentPoints(frameListTable)
        update the shown content, should be done automatic
--]]

FrameList = {}

function FrameList.create(margin, parent, createContext)
    local frameListTable = {}
    if not createContext then createContext = 0 end
    if not parent then parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) end
    if not margin then margin = 0 end
    frameListTable.Frame = BlzCreateFrameByType("FRAME", "FrameListFrame", parent, "", createContext)
    frameListTable.Slider = BlzCreateFrameByType("SLIDER", "FrameListSlider", frameListTable.Frame, "QuestMainListScrollBar", createContext)
    frameListTable.Margin = margin

    BlzFrameSetStepSize(frameListTable.Slider, 1)
    BlzFrameClearAllPoints(frameListTable.Slider)
    BlzFrameSetVisible(frameListTable.Slider, true)
    BlzFrameSetMinMaxValue(frameListTable.Slider, 1, 1)
    
    BlzFrameSetPoint(frameListTable.Slider, FRAMEPOINT_TOPRIGHT, frameListTable.Frame, FRAMEPOINT_TOPRIGHT, 0, 0)
    FrameList.setSize(frameListTable, 0.012, 0.139)

    frameListTable.Content = {}
    FrameList[frameListTable.Slider] = frameListTable
    FrameList[frameListTable.Frame] = frameListTable
    frameListTable.SliderTrigger = CreateTrigger()
    frameListTable.SliderTriggerAction = TriggerAddAction(frameListTable.SliderTrigger, FrameList.SliderAction)
    BlzTriggerRegisterFrameEvent(frameListTable.SliderTrigger, frameListTable.Slider , FRAMEEVENT_SLIDER_VALUE_CHANGED)
    BlzTriggerRegisterFrameEvent(frameListTable.SliderTrigger, frameListTable.Slider , FRAMEEVENT_MOUSE_WHEEL)
    return frameListTable
end

function FrameList.setContentPoints(frameListTable)
    local sliderValue = math.tointeger( BlzFrameGetValue(frameListTable.Slider))
    local sizeFrameList = BlzFrameGetHeight(frameListTable.Frame)
    local contentCount = #frameListTable.Content

    for index = 1, contentCount, 1 do
        local frame = frameListTable.Content[index]
        if index < sliderValue then
            --print("Hide Prev", index)
            BlzFrameSetVisible(frame, false)
        else
            local sizeFrame = BlzFrameGetHeight(frame)
            sizeFrameList = sizeFrameList - sizeFrame
            BlzFrameClearAllPoints(frame)  
            if index == sliderValue then                
                BlzFrameSetVisible(frame, true)
                BlzFrameSetPoint(frame, FRAMEPOINT_TOPRIGHT, frameListTable.Slider, FRAMEPOINT_TOPLEFT, 0, 0)
            else
                BlzFrameSetVisible(frame, sizeFrameList >= 0)
                BlzFrameSetPoint(frame, FRAMEPOINT_TOPRIGHT, frameListTable.Content[index - 1], FRAMEPOINT_BOTTOMRIGHT, 0, -frameListTable.Margin)
            end
        end
    end
end

function FrameList.setSize(frameListTable, xSize, ySize)
    BlzFrameSetSize(frameListTable.Frame, xSize, ySize)
    BlzFrameSetSize(frameListTable.Slider, 0.012, ySize)
end

function FrameList.add(frameListTable, frame)
    table.insert(frameListTable.Content, frame)
    BlzFrameSetParent(frame, frameListTable.Frame) 
    BlzFrameSetMinMaxValue(frameListTable.Slider, 1, #frameListTable.Content)
    FrameList.setContentPoints(frameListTable)
end

function FrameList.remove(frameListTable, frame, noUpdate)
    local removed = nil
    if not frameListTable or #frameListTable.Content == 0 then return false end
    if not frame then
        removed = table.remove(frameListTable.Content)
    elseif type(frame) == "number" then
        removed = table.remove( frameListTable.Content, frame)
    else
        for index, value in ipairs(frameListTable.Content)
        do
            if frame == value then
                removed = table.remove(frameListTable.Content, index)
                break
            end
        end
    end

    if removed then
        BlzFrameClearAllPoints(removed)
        BlzFrameSetVisible(removed, false)
        if not noUpdate then
            BlzFrameSetMinMaxValue(frameListTable.Slider, 1, #frameListTable.Content)
            BlzFrameSetValue(frameListTable.Slider, 1)
            FrameList.setContentPoints(frameListTable)
        end
    end
    return #frameListTable.Content
end

function FrameList.SliderAction()
    local frame = BlzGetTriggerFrame()
    if GetLocalPlayer() == GetTriggerPlayer() then
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_WHEEL then
            if BlzGetTriggerFrameValue() > 0 then
                BlzFrameSetValue(frame, BlzFrameGetValue(frame) + 1)
            else
                BlzFrameSetValue(frame, BlzFrameGetValue(frame) - 1)
            end
        end
        FrameList.setContentPoints(FrameList[frame])
    end
end

function FrameList.destory(frameListTable)
    FrameList[frameListTable.Slider] = nil
    FrameList[frameListTable.Frame] = nil
    TriggerRemoveAction(frameListTable.SliderTrigger, frameListTable.SliderTriggerAction)
    DestroyTrigger(frameListTable.SliderTrigger)
    BlzDestroyFrame(frameListTable.Frame)
    BlzDestroyFrame(frameListTable.Slider)
    frameListTable.Mode = nil
    frameListTable.Frame = nil
    repeat until not FrameList.remove(frameListTable, nil, true)
    frameListTable.Content = nil
    
    frameListTable.SliderTrigger = nil
    frameListTable.SliderTriggerAction = nil

end