--[[
    FrameFlow V0.9b by Tasyen
    FrameFlow is a system that automatic fills a Frame from TopLeft with frames. Further frame try to be placed next to the previous one, if that fails FrameFlow starts a new row.
    This new added Frame is the previous for the next frame regardless if it started a new Row or not.
    The Frame using FrameFlow and the frames added need a size for this system to work.
    

    function FrameFlow.create(frame[, addSlider, marginX, marginY])
        creates a new FrameFlow for frame returns frameFlowTable.
        Having marginX space between 2 frames in 1 row and marginY space between 2 rows
        addSlider(true) creats a slider so the user can alter the frame shown at topLeft with that moves all Content.
        The slider will take over the size of the frame on creation, when the size changes you or was not right on that moment use FrameFlow.updateSlider.

    function FrameFlow.add(frameFlowTable, frame[, noUpdate])
        adds frame to the frameFlowTable. noUpdate (true) does not fit the new Frame into the Frame managed by FrameFlow.
        frame becomes a children of the Frame managed by frameFlowTable

    function FrameFlow.remove(frameFlowTable, [frame, noUpdate])
        removes frame (can be a number) from the frameFlowTable.
        calling this will also call FrameFlow.fit(frameFlowTable, 1).
        noUpdate (true) prevents calling FrameFlow.fit. Recommented when used multiple times in a row.
        returns true if the frameFlowTable still contains frames

    function FrameFlow.fit(frameFlowTable[, startingIndex])
        update the position and visibility of all content of frameFlowTable.
        starting with Content[startingIndex] at TopLeft.
        Frames with a lower index are hidden.
        no startingIndex is the same as 1.
        Use this function to scroll or after the size of the parentFrame or one of the content changed.
        This is also used after an FrameFlow

    function FrameFlow.updateSlider(frameFlowTable)
        updates the Size of the slider to the current Size of the Frame managed by this frameFlowTable
--]]

FrameFlow = {}
-- creates a new FrameFlow filling frame
function FrameFlow.create(frame, addSlider, marginX, marginY)
    local frameFlowTable = {}
    frameFlowTable.Frame = frame --the frame filled
    frameFlowTable.Content = {} -- array of frames

    if addSlider then
        frameFlowTable.Slider = BlzCreateFrameByType("SLIDER", "FrameFlowSlider", frame, "QuestMainListScrollBar", 0)
    --  frameFlowTable.Slider = BlzCreateFrame("QuestMainListScrollBar", frame, "", 0)
        FrameFlow[frameFlowTable.Slider] = frameFlowTable
        BlzFrameClearAllPoints(frameFlowTable.Slider)
        BlzFrameSetStepSize(frameFlowTable.Slider, 1)
        BlzFrameSetSize(frameFlowTable.Slider, 0.012, BlzFrameGetHeight(frame))
        BlzFrameSetPoint(frameFlowTable.Slider, FRAMEPOINT_RIGHT, frame, FRAMEPOINT_RIGHT, 0, 0)
        BlzFrameSetVisible(frameFlowTable.Slider, true)
        BlzFrameSetMinMaxValue(frameFlowTable.Slider, 1, 1)
        frameFlowTable.SliderTrigger = CreateTrigger()
        frameFlowTable.SliderTriggerAction = TriggerAddAction(frameFlowTable.SliderTrigger, FrameFlow.SliderAction)
        BlzTriggerRegisterFrameEvent(frameFlowTable.SliderTrigger, frameFlowTable.Slider , FRAMEEVENT_SLIDER_VALUE_CHANGED)
        BlzTriggerRegisterFrameEvent(frameFlowTable.SliderTrigger, frameFlowTable.Slider , FRAMEEVENT_MOUSE_WHEEL)
    end
    if not marginX then marginX = 0 end
    frameFlowTable.MarginX = marginX --space between 2 frames in one row
    if not marginY then marginY = 0 end
    frameFlowTable.MarginY = marginY --additional space between 2 rows
    return frameFlowTable
end

function FrameFlow.calc(frameFlowTable, frame, prevFrame)
    local rowSizeX = frameFlowTable.CurrentRowRemainX
    local rowSizeY = frameFlowTable.CurrentRowSizeY
    local offsetY = frameFlowTable.CurrentOffsetY
    local parentframeSizeX = BlzFrameGetWidth(frameFlowTable.Frame)
    if frameFlowTable.Slider then --if there is an Slider reduce the used Space
        parentframeSizeX = parentframeSizeX - BlzFrameGetWidth(frameFlowTable.Slider)
    end
    local parentframeSizeY = BlzFrameGetHeight(frameFlowTable.Frame)
    rowSizeX = rowSizeX - BlzFrameGetWidth(frame) - frameFlowTable.MarginX
    BlzFrameClearAllPoints(frame)
    

    if rowSizeX >= 0 then
        BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, prevFrame, FRAMEPOINT_TOPRIGHT, frameFlowTable.MarginX, 0)
        rowSizeY = math.max( rowSizeY, BlzFrameGetHeight(frame))
    elseif rowSizeX < 0 then
        offsetY = offsetY + rowSizeY + frameFlowTable.MarginY
        rowSizeX = parentframeSizeX - BlzFrameGetWidth(frame)
        BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, frameFlowTable.Frame, FRAMEPOINT_TOPLEFT, 0, -offsetY)
        rowSizeY = BlzFrameGetHeight(frame)
    end
    BlzFrameSetVisible(frame, offsetY + BlzFrameGetHeight(frame) <= parentframeSizeY)
    prevFrame = frame

    --save this values to simple down adding 1 frame
    frameFlowTable.CurrentRowRemainX = rowSizeX
    frameFlowTable.CurrentRowSizeY = rowSizeY
    frameFlowTable.CurrentOffsetY = offsetY
end

--refits all frames, startingIndex is the index of frameFlowTable.Content being placed at TopLeft of the parent Frame
function FrameFlow.fit(frameFlowTable, startingIndex)
    if not frameFlowTable.Content or #frameFlowTable.Content == 0 then return end
    if not startingIndex then startingIndex = 1 end
    
    --hide frames before the starting Index
    for index = 1, startingIndex - 1, 1
    do
        BlzFrameSetVisible(frameFlowTable.Content[index], false)
    end
   
    local frame = frameFlowTable.Content[startingIndex]
    BlzFrameClearAllPoints(frame)
    BlzFrameSetVisible(frame, true)
    BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, frameFlowTable.Frame, FRAMEPOINT_TOPLEFT, 0, 0)
    
    local prevFrame = frame

    --reset values
    frameFlowTable.CurrentRowRemainX = BlzFrameGetWidth(frameFlowTable.Frame) - BlzFrameGetWidth(frame)
    if frameFlowTable.Slider then --if there is an Slider reduce the used Space
        frameFlowTable.CurrentRowRemainX = frameFlowTable.CurrentRowRemainX - BlzFrameGetWidth(frameFlowTable.Slider)
    end
    frameFlowTable.CurrentRowSizeY = BlzFrameGetHeight(frame)
    frameFlowTable.CurrentOffsetY = 0

    for index = startingIndex + 1, #frameFlowTable.Content, 1
    do
        local frame = frameFlowTable.Content[index]
        FrameFlow.calc(frameFlowTable, frame, prevFrame)
        
        prevFrame = frame
    end
end

--fit in a new frame at the end of the table
function FrameFlow.fitNewFrame(frameFlowTable, frame)
    FrameFlow.calc(frameFlowTable, frame, frameFlowTable.Content[#frameFlowTable.Content - 1])
end

function FrameFlow.remove(frameFlowTable, frame, noUpdate)
    local removed = nil
    if not frameFlowTable or #frameFlowTable.Content == 0 then return false end
    if not frame then
        removed = table.remove(frameFlowTable.Content)
    elseif type(frame) == "number" then
        removed = table.remove( frameFlowTable.Content, frame)
    else
        for index, value in ipairs(frameFlowTable.Content)
        do
            if frame == value then
                removed = table.remove(frameFlowTable.Content, index)
                break
            end
        end
    end
    if removed then
        BlzFrameClearAllPoints(removed)
        BlzFrameSetVisible(removed, false)
        BlzFrameSetMinMaxValue(frameFlowTable.Slider, 1, #frameFlowTable.Content)
        if not noUpdate then
            FrameFlow.fit(frameFlowTable, 1)
        end
    end
    return #frameFlowTable.Content
end

function FrameFlow.destroy(frameFlowTable)
    if frameFlowTable.Slider then
        FrameFlow[frameFlowTable.Slider] = nil
        TriggerRemoveAction(frameFlowTable.SliderTrigger, frameFlowTable.SliderTriggerAction)
        DestroyTrigger(frameFlowTable.SliderTrigger)
        BlzDestroyFrame(frameFlowTable.Slider)
        frameFlowTable.Slider = nil
        frameFlowTable.SliderTrigger = nil
        frameFlowTable.SliderTriggerAction = nil
    end
    frameFlowTable.Frame = nil
    frameFlowTable.Content = nil
    frameFlowTable.CurrentRowRemainX = nil
    frameFlowTable.CurrentRowSizeY = nil
    frameFlowTable.CurrentOffsetY = nil
end

function FrameFlow.add(frameFlowTable, frame, noUpdate)
    table.insert(frameFlowTable.Content, frame)
    BlzFrameSetParent(frame, frameFlowTable.Frame)
    BlzFrameSetMinMaxValue(frameFlowTable.Slider, 1, #frameFlowTable.Content)
    if not noUpdate then
        if #frameFlowTable.Content == 1 then
            FrameFlow.fit(frameFlowTable, 1)
        else
            FrameFlow.fitNewFrame(frameFlowTable, frame)
        end
    end
end

function FrameFlow.updateSlider(frameFlowTable)
    if frameFlowTable.Slider then
        BlzFrameSetSize(frameFlowTable.Slider, 0.012, BlzFrameGetHeight(frameFlowTable.Frame))
    end
end

function FrameFlow.SliderAction()
    local frame = BlzGetTriggerFrame()
    if GetLocalPlayer() == GetTriggerPlayer() then
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_WHEEL then
            if BlzGetTriggerFrameValue() > 0 then
                BlzFrameSetValue(frame, BlzFrameGetValue(frame) + 1)
            else
                BlzFrameSetValue(frame, BlzFrameGetValue(frame) - 1)
            end
        end
        FrameFlow.fit(FrameFlow[frame],  BlzFrameGetValue(frame))
    end
end