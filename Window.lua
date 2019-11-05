--[[
    Window V1.1 by Tasyen
    The idea of Window is to have a standart Frame in which you only have to care about how to manage your content onto the ContentPane without bothering the border etc.    
    
function Window.create([title, hide, createContext, parent])
    creates a window using the local players race border.
    A Window consists of a Pane, a Head, a Title a closeButton and a Border.
    The Pane is mean to carry your custom Frame and contains only the space between the borders of the Window.
    The closeButton is part of the Head and has 2 modes:
        hide(true) close the window and head when clicked for the local Player. In such a case the user needs a way to show the window.WindowHead again, if that is wanted.
        hide (false or nil) The close Button toggles the visibility of the Window, the WindowHead remains visibile.
    createContext nil = 0, use a specific one, if you want to access frames over BlzGetFrameByName
    parent nil = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0).
    The window is posed over windowTable.WindowHead, all other frames of window are linked based on the heads position.
    returns the new created windowTable

function Window.setAbsPoint(windowTable, framepoint, x, y)
function Window.setSize(windowTable[, xSize, ySize, tempChange])
    without any arguments reset the size to the last non tempChange one
    without tempChange the window will change its current size and define a new default size
function Window.destroy(windowTable)

--]]


BlzLoadTOCFile("war3mapimported\\window.toc")
Window = {}
function Window.create(title, hide, createContext, parent)
    local windowTable = {}
    if not createContext then createContext = 0 end --user does not care use 0.
    if not parent then parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) end
    windowTable.WindowHead = BlzCreateFrame("WindowHead", parent, 0, createContext)
    windowTable.WindowHeadText = BlzGetFrameByName("WindowHeadText", createContext) --styling
    windowTable.WindowHeadBackdrop = BlzGetFrameByName("WindowHeadBackdrop", createContext)
    windowTable.WindowHeadTrigger = CreateTrigger()
    windowTable.Window = BlzGetFrameByName("Window", createContext) --this is the background and border of the ContentPane    
    if title then
        BlzFrameSetText(windowTable.WindowHead, title)
    end
    
    windowTable.WindowPane = BlzGetFrameByName("WindowPane", createContext) --the container for the stuff user wants to display
    windowTable.WindowCloseButton = BlzGetFrameByName("WindowCloseButton", createContext) --press this to hide the window
    windowTable.WindowCloseButtonText = BlzGetFrameByName("WindowCloseButtonText", createContext) --styling
    windowTable.WindowCloseButtonTrigger = CreateTrigger()
    windowTable.WindowCloseButtonType = hide
    windowTable.WindowSizeX = BlzFrameGetWidth(windowTable.Window)
    windowTable.WindowSizeY = BlzFrameGetHeight(windowTable.Window)

    Window[windowTable.Window] = windowTable --the Window and the WindowHead know the table, the others know the Window by using BlzFrameGetParent
    Window[windowTable.WindowHead] = windowTable

    windowTable.WindowHeadTriggerAction = TriggerAddAction(windowTable.WindowHeadTrigger, Window.HeadAction)
    BlzTriggerRegisterFrameEvent(windowTable.WindowHeadTrigger, windowTable.WindowHead, FRAMEEVENT_CONTROL_CLICK)

    windowTable.WindowCloseButtonTriggerAction = TriggerAddAction(windowTable.WindowCloseButtonTrigger, Window.CloseButtonAction)
    
    BlzTriggerRegisterFrameEvent(windowTable.WindowCloseButtonTrigger, windowTable.WindowCloseButton, FRAMEEVENT_CONTROL_CLICK)

    return windowTable
end

function Window.setAbsPoint(windowTable, framepoint, x, y)
    BlzFrameSetAbsPoint(windowTable.WindowHead, framepoint, x, y)
end

function Window.setSize(windowTable, xSize, ySize, tempChange)
    if xSize then
        BlzFrameSetSize(windowTable.Window, xSize, ySize)
        BlzFrameSetSize(windowTable.WindowPane, xSize - 0.03, ySize - 0.03)
        BlzFrameSetSize(windowTable.WindowHead, xSize - 0.025, 0.0275) -- -0.025 is the closebutton
        if not tempChange then
            windowTable.WindowSizeX = xSize
            windowTable.WindowSizeY = ySize
        end
    else
        BlzFrameSetSize(windowTable.Window, windowTable.WindowSizeX, windowTable.WindowSizeY)
        BlzFrameSetSize(windowTable.WindowPane, windowTable.WindowSizeX - 0.03, windowTable.WindowSizeY - 0.03)
        BlzFrameSetSize(windowTable.WindowHead, windowTable.WindowSizeX - 0.025 , 0.0275)
    end
end

function Window.destroy(windowTable)
    if windowTable.Tabs then
        Window.destroyTabs(windowTable)
    end
    Window[windowTable.Window] = nil
    TriggerRemoveAction(windowTable.WindowCloseButtonTrigger, windowTable.WindowCloseButtonTriggerAction)
    DestroyTrigger(windowTable.WindowCloseButtonTrigger)

    TriggerRemoveAction(windowTable.WindowHeadTrigger, windowTable.WindowHeadTriggerAction)
    DestroyTrigger(windowTable.WindowHeadTrigger)

    BlzDestroyFrame(windowTable.WindowCloseButtonText)
    BlzDestroyFrame(windowTable.WindowCloseButton)
    BlzDestroyFrame(windowTable.WindowPane)
    BlzDestroyFrame(windowTable.Window)
    BlzDestroyFrame(windowTable.WindowHeadBackdrop)
    BlzDestroyFrame(windowTable.WindowHeadText)
    BlzDestroyFrame(windowTable.WindowHead)
    windowTable.WindowPane = nil
    windowTable.Window = nil
    windowTable.WindowCloseButton = nil
    windowTable.WindowCloseButtonText = nil
    windowTable.WindowCloseButtonTrigger = nil
    windowTable.WindowCloseButtonTriggerAction = nil
    windowTable.WindowSizeX = nil
    windowTable.WindowSizeY = nil
    windowTable.WindowHeadText = nil
    windowTable.WindowHead = nil
    windowTable.WindowHeadBackdrop = nil
end


function Window.HeadAction()
   --when the title is clicked(released)
    local button = BlzGetTriggerFrame()
    BlzFrameSetEnable(button, false)
    BlzFrameSetEnable(button, true)
end

--more of an attribute hence CamelCase
function Window.CloseButtonAction()
    local windowTable = Window[BlzFrameGetParent(BlzGetTriggerFrame())]
    if GetLocalPlayer() == GetTriggerPlayer() then
        if not windowTable.WindowCloseButtonType then
            BlzFrameSetVisible(windowTable.Window, not BlzFrameIsVisible(windowTable.Window))
        else
            BlzFrameSetVisible(windowTable.WindowHead, false)
        end
    end
end
