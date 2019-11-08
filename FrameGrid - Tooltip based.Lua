--[[FrameGrid by Tasyen
--Got that Idea from CanFight, he mentioned something about a FPS game in which he clustered the screen with Frames to know the mouse position.

function FrameGrid.show(flag, player)
    show/hide the grid for player nil or GetLocalPlayer affect all players

--]]

FrameGrid = {}
FrameGrid.Boss = nil --the parent hide/show it to enable/disable the functionality of this system.
FrameGrid.GridFrames = {} --all grid frames
FrameGrid.GridFrames2 = {} --the tooltip frames of the grid
FrameGrid.LastFrame = 0 --the index of the frame hovered by the mouse, might be incorrect sometimes
onGameStart(function()
    --        print("FrameGrid.Init")
        
    FrameGrid.Timer = CreateTimer()
    TimerStart(FrameGrid.Timer, 0.01, true, FrameGrid.update)

    --the Grid Boss Frame its a BUTTON so it can have a higher Frame Level.
    --This Frame is used as on/off, when showing it the FrameGrid becomes active while it does nothing when Boss is disabled.
    FrameGrid.Boss = BlzCreateFrameByType("BUTTON", "FrameGridBoss", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0),"",0)

    --be above other frames, using this allows to move into other frames but also stops their mouse enter events while FrameGrid is active.
    --I wasn't able to change this value at a later time hence there is no swap for this.
    --BlzFrameSetLevel(FrameGrid.Boss, 7)
    

    local xSize = 0.01 --dont go to low
    local ySize = 0.01 --dont go to low
    local yStart = ySize/2
    local xStart = xSize/2
    FrameGrid.FramesEachCol = 0.6 / ySize
    for x = xStart, 0.8, xSize do
        for y = yStart, 0.6, ySize do
            local newButton = BlzCreateFrameByType("FRAME", "", FrameGrid.Boss,"",0)
            local tooltipButton = BlzCreateFrameByType("FRAME", "", FrameGrid.Boss,"",0)
            BlzFrameSetAbsPoint(newButton, FRAMEPOINT_CENTER, x, y)
            BlzFrameSetSize(newButton, xSize, ySize)
            BlzFrameSetTooltip(newButton, tooltipButton)
            BlzFrameSetEnable(newButton, false)
            BlzFrameSetEnable(tooltipButton, false)
            FrameGrid[newButton] = {x, y}
            FrameGrid[tooltipButton] = {x, y}
            table.insert(FrameGrid.GridFrames, newButton)
            table.insert(FrameGrid.GridFrames2, tooltipButton)
        end
    end
    
    BlzFrameSetVisible(FrameGrid.Boss, false)
end)

function FrameGrid.updateSimple()
    --Grid visible?
    if BlzFrameIsVisible(FrameGrid.Boss) then
        --loop all Tooltip Frames and find the visible one. The visible one is the position of the mouse on the screen.
        --this is a bit inefficent in worst case one iterates 4800 times, frames are saved in col wise means as farer left the mouse is as faster this is done.
        --when beeing at left it only takes no os.clock time while it takes ~ 0.003 or 0.005  seconds on the right

        --local count = 0
        --local time = os.clock()
        for index, value in ipairs(FrameGrid.GridFrames2)
        do
            --count = count + 1
            if BlzFrameIsVisible(value) then
          --      FrameGrid.LastY = FrameGrid[value][2]
                MoveAbleFrame.moveFrame(FrameGrid[value][1], FrameGrid[value][2])
                break
            end
        end
        --print(count)
        --print("count:",count, "os.clock", os.clock() - time)
       -- print(os.clock() - time)
    end
end


function FrameGrid.update()
    --Grid visible?
    if BlzFrameIsVisible(FrameGrid.Boss) then
        --search the visible Tooltip Frame in both directions from the last found position.
        --this way speeds it up when doing only small steps, average was for me 60 to 240 steps and resulting into 0 or sometimes ~0.0009 ~0.001 os.clock dif
        
        --local count = 0
        --local time = os.clock()

        local yA = FrameGrid.LastFrame
        local yB = FrameGrid.LastFrame
        
        while (yA > 0 or yB < #FrameGrid.GridFrames2)
        do 
            --count = count + 1
            if yA > 0 then
                if BlzFrameIsVisible(FrameGrid.GridFrames2[yA]) then
                    FrameGrid.LastFrame = yA
                    MoveAbleFrame.moveFrame(FrameGrid[FrameGrid.GridFrames2[yA]][1], FrameGrid[FrameGrid.GridFrames2[yA]][2])
                    break
                end
                yA = yA - 1
            end
            if BlzFrameIsVisible(FrameGrid.GridFrames2[yB]) then
                FrameGrid.LastFrame = yB
                MoveAbleFrame.moveFrame(FrameGrid[FrameGrid.GridFrames2[yB]][1], FrameGrid[FrameGrid.GridFrames2[yB]][2])
                break
            else
                yB = yB + 1
            end
        end
        --print("count:",count, "os.clock", os.clock() - time)
        --print(os.clock() - time)
    end
end


function FrameGrid.show(flag, player)
    if not player or GetLocalPlayer() == player then
        BlzFrameSetVisible(FrameGrid.Boss, flag)
    end
end



