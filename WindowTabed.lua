--[[
    WindowTab V1.1a
    plugin for Window by Tasyen.
    Instead of placing stuff onto the ContentPane one adds Frames as Tabs (pages). The current shown Tab is swaped by the user clicking TabButtons.
    First Create a Window then add a frame as Tab to the Window.
    Having a tab does not stopp one from placing something onto the ContentPane itself.

    function Window.addTab(windowTable, frame, [buttonText, doNotStretch, xSize, ySize])
        adds frame as Tab to windowTable
        buttonText is displayed on the Button to swap to this tab
        doNotStretch(true) does not alter the size of frame, also pos it with its center to the WindowPane center
        xSize and ySize when set, will alter the size of windowTable as long this tab is shown
        Does not support SimpleFrames, directly.
        frames parent, position, size (without doNotStretch) are altered in the process.
        returns the new created windowTabtable

    function Window.setTabButtonAction(windowTabTable, actionFunction)
        calls actionFunction when this button is clicked and shown.
        Beaware that the action is called async.
        Inside actionFunction you have windowTable, windowTabTable.
        Will instantly call the actionFunction if the tab is the current active tab

    function Window.removeTab(windowTable[, windowTabTable])
        windowTabTable can be an index, a table or nil. nil will remove the last added one
        returns if windowTable has further Tabs remaining

    function Window.showTab(windowTable, windowTabTable[, player])
        show windowTabTable of windowTable to player
        windowTabTable can be a index or a table, the table is expected to be a tabTable of the windowTable
        player can be nil to affect all players


doesn't work that well with LeaderBoard, Multiboard, TimerDialog
if you need to use SimpleFrames create a FRAME make it a Tab and create a SIMPLEFRAME put all your SIMPLEFRAMEs into SIMPLEFRAME and clone visiblity and position of FRAME with SIMPLEFRAME the visibility has to be update quite often like every 0.05s.
the frame will survive the destruction of the window, but needs to change parent and position to be visible again.
--]]
function Window.addTab(windowTable, frame, buttonText, doNotStretch, xSize, ySize)
    --each Tab is an own Table
    local windowTabTable = {}
    
    if not windowTable.Tabs then
        --this is the first time this window gets tabs
        windowTable.Tabs = {}
        windowTable.TabActive = windowTabTable
    end
    --add the new TabTable into the array of windowTable
    table.insert(windowTable.Tabs, windowTabTable)

    local tabButton = BlzCreateFrame("WindowTabButton", windowTable.WindowPane, 0, 0)
    if buttonText then
        BlzFrameSetText(tabButton, buttonText)
    else
        BlzFrameSetText(tabButton, #windowTable.Tabs)
    end
    BlzFrameSetSize(tabButton, 0.06, 0.025)

    Window[tabButton] = windowTabTable
    Window[windowTabTable] = windowTable
    --fit the given frame into the Content Pane?
    if not doNotStretch then
        BlzFrameSetAllPoints(frame, windowTable.WindowPane)
        BlzFrameSetSize(frame, BlzFrameGetWidth(windowTable.WindowPane), BlzFrameGetHeight(windowTable.WindowPane))
    else
        --only center it
        BlzFrameClearAllPoints(frame)
        BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, windowTable.WindowPane, FRAMEPOINT_CENTER, 0, 0)
    end
    BlzFrameSetParent(frame, windowTable.WindowPane)
    
    windowTabTable.Button = tabButton
    windowTabTable.Frame = frame
    windowTabTable.SizeX = xSize
    windowTabTable.SizeY = ySize

    windowTabTable.ButtonTrigger = CreateTrigger()
    windowTabTable.ButtonTriggerAction = TriggerAddAction(windowTabTable.ButtonTrigger, Window.TabButtonAction)
    BlzTriggerRegisterFrameEvent(windowTabTable.ButtonTrigger, tabButton, FRAMEEVENT_CONTROL_CLICK)

    --pos the tab button
    if #windowTable.Tabs == 1 then
        --the first button is located at Top Left of the Window
        BlzFrameSetVisible(frame, true)
        BlzFrameSetPoint(tabButton, FRAMEPOINT_TOPRIGHT, windowTable.Window, FRAMEPOINT_TOPLEFT, 0, 0)
        --hide the new tab button, there is nothing to choose yet.
        BlzFrameSetVisible(windowTable.Tabs[1].Button, false)
        Window.showTab(windowTable, windowTabTable)
    else
        --further ones are located below to the previous one
        --this is not the first added one hide it.
        
        BlzFrameSetVisible(frame, false)
        BlzFrameSetPoint(tabButton, FRAMEPOINT_TOP, windowTable.Tabs[#windowTable.Tabs - 1].Button, FRAMEPOINT_BOTTOM, 0, 0.005)
        BlzFrameSetVisible(windowTable.Tabs[1].Button, true)
    end
    return windowTabTable
end

function Window.setTabButtonAction(windowTabTable, actionFunction)
    windowTabTable.ShowAction = actionFunction
    if Window[windowTabTable].TabActive == windowTabTable then
        actionFunction(Window[windowTabTable], windowTabTable)
    end
end

-- windowTabTable can be an index, a table or nil. nil will remove the last added one
-- returns true if there are tabs remaining
function Window.removeTab(windowTable, windowTabTable)
    if #windowTable.Tabs == 0 then return false end
    if not windowTabTable then
        Window.destroyTab(windowTable, #windowTable.Tabs, true)
    elseif type(windowTabTable) == "number" then
        Window.destroyTab(windowTable, windowTabTable, true)
        
    elseif type(windowTabTable) == "table" then
        for index, value in ipairs(windowTable.Tabs)
        do
            if value == windowTabTable then
                Window.destroyTab(windowTable, index, true)
                break
            end
        end
    end
    return #windowTable.Tabs > 0
end

function Window.showTab(windowTable, windowTabTable, player)
    if player and player ~= GetLocalPlayer() then return end

    if windowTable.TabActive then
        BlzFrameSetVisible(windowTable.TabActive.Frame, false)
    end
    if type(windowTabTable) == "number" then
        windowTabTable = windowTable.Tabs[windowTabTable]
    end
    BlzFrameSetVisible(windowTabTable.Frame, true)
    windowTable.TabActive = windowTabTable

    if windowTabTable.SizeX then
        Window.setSize(windowTable, windowTabTable.SizeX + 0.02, windowTabTable.SizeY + 0.02, true)
        BlzFrameSetSize(windowTabTable.Frame, BlzFrameGetWidth(windowTable.WindowPane), BlzFrameGetHeight(windowTable.WindowPane))
    else
        Window.setSize(windowTable)
    end

    --custom user action when showing this Tab
    if windowTabTable.ShowAction then
        windowTabTable.ShowAction(windowTable, windowTabTable)
    end
end

-- this is not meant to be called manualy
function Window.destroyTab(windowTable, index, reCalc)
    local windowTabTable = windowTable.Tabs[index]

    Window[windowTabTable.Button] = nil
    Window[windowTabTable] = nil
    TriggerRemoveAction(windowTabTable.ButtonTrigger, windowTabTable.ButtonTriggerAction)
    DestroyTrigger(windowTabTable.ButtonTrigger)
    BlzDestroyFrame(windowTabTable.Button)
    
    --wana repos tab buttons, the array and the shown Active Tab when needed?
    if reCalc then
        --remove 1 have 2 or more, attach 2. to the 1. slot
        if index == 1 and #windowTable.Tabs > 1 then
            BlzFrameSetPoint(windowTable.Tabs[index + 1].Button, FRAMEPOINT_TOPRIGHT, windowTable.Window, FRAMEPOINT_TOPLEFT, 0, 0)
        --remove 2. put 3. below 1.
        elseif index > 1 and #windowTable.Tabs > index then
            BlzFrameSetPoint(windowTable.Tabs[index + 1].Button, FRAMEPOINT_TOP, windowTable.Tabs[index - 1].Button, FRAMEPOINT_BOTTOM, 0, 0.005)
        end
        
        table.remove(windowTable.Tabs, index)

        
        if windowTable.TabActive == windowTabTable then
            BlzFrameSetVisible(windowTable.TabActive.Frame, false)
            if #windowTable.Tabs > 0 then            
                Window.showTab(windowTable, windowTable.Tabs[1])
            end
        end
    end

    --this has to be done after the new shown tab was updated.
    windowTabTable.Button = nil
    windowTabTable.Frame = nil
    windowTabTable.ButtonTrigger = nil
    windowTabTable.ButtonTriggerAction = nil
    windowTabTable.ShowAction = nil
    windowTabTable.SizeX = nil
    windowTabTable.SizeY = nil
end

--this is called from Window.destroy, if the Window has tabs.
function Window.destroyTabs(windowTable)
    for index in ipairs(windowTable.Tabs)
    do
        Window.destroyTab(windowTable, index, false)
    end
    windowTable.Tabs = nil
    windowTable.TabActive = nil
end

--more of an attribute hence CamelCase
function Window.TabButtonAction()
    local button = BlzGetTriggerFrame()
    local windowTable = Window[BlzFrameGetParent(BlzFrameGetParent(button))]
    local windowTabTable = Window[button]
    if GetLocalPlayer() == GetTriggerPlayer() then
        Window.showTab(windowTable, windowTabTable)
        BlzFrameSetEnable(button, false)
        BlzFrameSetEnable(button, true)
    end
end
