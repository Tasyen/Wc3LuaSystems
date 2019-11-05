--[[FrameGrid by Tasyen
--Got that Idea from CanFight, he mentioned something about a FPS game in which he clustered the screen with Frames to know the mouse position.

function FrameGrid.show(flag, player)
    show/hide the grid for player nil or GetLocalPlayer affect all players
--]]

FrameGrid = {}
FrameGrid.Boss = nil --the parent hide/show it to enable/disable the functionality of this system.
FrameGrid.GridFrames = {} --all grid frames
onGameStart(function()
    --        print("FrameGrid.Init")
        
    FrameGrid.ClickTrigger = CreateTrigger() 
    FrameGrid.ClickTriggerAction = TriggerAddAction(FrameGrid.ClickTrigger, function()
        local eventFrame = BlzGetTriggerFrame()
        local x = FrameGrid[eventFrame][1]
        local y = FrameGrid[eventFrame][2]
        --print( string.format( "%%.3f",x), string.format( "%%.3f",y))
        if GetLocalPlayer() == GetTriggerPlayer() then
            --MoveAbleFrame.moveFrame(x, y, true)
            FrameGrid.show(false)
        end
        --print(x,y)
        BlzFrameSetEnable(eventFrame, false)
        BlzFrameSetEnable(eventFrame, true)
    end)

    FrameGrid.EnterTrigger = CreateTrigger()
    FrameGrid.EnterTriggerAction = TriggerAddAction(FrameGrid.EnterTrigger, function()
        local eventFrame = BlzGetTriggerFrame()
        local x = FrameGrid[eventFrame][1]
        local y = FrameGrid[eventFrame][2]
        if GetLocalPlayer() == GetTriggerPlayer() then
            MoveAbleFrame.moveFrame(x, y)
        end
        --print( string.format( "%%.3f",x), string.format( "%%.3f",y))

    end)
    FrameGrid.Boss = BlzCreateFrameByType("BUTTON", "FrameGridBoss", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0),"",0)

    BlzFrameSetLevel(FrameGrid.Boss, 7) --be above other frames

    local xSize = 0.01 --dont go to low
    local ySize = 0.01 --dont go to low
    local yStart = ySize/2
    local xStart = xSize/2
    for x = xStart, 0.8, xSize do
        for y = yStart, 0.6, ySize do
            local newButton = BlzCreateFrameByType("BUTTON", "", FrameGrid.Boss,"",0)
            BlzFrameSetAbsPoint(newButton, FRAMEPOINT_CENTER, x, y)
            BlzFrameSetSize(newButton, xSize, ySize)
            FrameGrid[newButton] = {x, y}
            table.insert(FrameGrid.GridFrames, newButton)
            BlzTriggerRegisterFrameEvent(FrameGrid.ClickTrigger, newButton, FRAMEEVENT_MOUSE_UP)
            BlzTriggerRegisterFrameEvent(FrameGrid.EnterTrigger, newButton, FRAMEEVENT_MOUSE_ENTER)
        end
    end
    BlzFrameSetVisible(FrameGrid.Boss, false)
end)

function FrameGrid.show(flag, player)
    if not player or GetLocalPlayer() == player then
        BlzFrameSetVisible(FrameGrid.Boss, flag)
    end
end



