--[[
MoveAbleFrame (Mini) by Tasyen
MoveAbleFrame allows to drag&drop frames you have setuped to be moveable. This System is async do not use anthing of it in a sync manner. Sadly there is no Async GetScreenMousePos in 1.31 hence it uses FrameGrid to get the ScreenMouse Position over a sync event which makes this a bit unresponsive.

function MoveAbleFrame.setup(frame)
    makes this frame moveable by user with drag and drop, only works on frameTypes supporting FRAMEEVENT_MOUSE_ENTER and FRAMEEVENT_MOUSE_LEAVE
    has to be called sync cause it creates events, unlike the other userMoveAbleFrame functions which should be used async
    The user changed position can be saved in a file and loaded. The frames are identyfied by the order, they were added to userMoveAbleFrame.
    Means when adding new userMoveAbleFrames not to the end (order wise), then a saved File can move a wrong frame when loading an File saved with an old version.

function MoveAbleFrame.enable(player[, flag])
    (dis)allows drag and drop moveable Frames for player, use GetLocalPlayer() to affect all players
    can be called without flag in such a case the current value is negated. true <-> false
    returns the value of MoveAbleFrame.Enabled
--]]
MoveAbleFrame = {}
MoveAbleFrame.Enabled = false --only when this is true, right clicking will have an effect on frames
MoveAbleFrame.Frame = nil -- the Frame beeing Moved
MoveAbleFrame.FramePoint = nil -- the FramePoint Frame is posed with nil = CENTER

function MoveAbleFrame.startMoving(frame, framePoint)
    MoveAbleFrame.Frame = frame
    if not framePoint then
       framePoint = FRAMEPOINT_CENTER
    end
    MoveAbleFrame.FramePoint = framePoint
    FrameGrid.show(true)
end

function MoveAbleFrame.moveFrame(x, y, finish)
    BlzFrameClearAllPoints(MoveAbleFrame.Frame)
    BlzFrameSetAbsPoint(MoveAbleFrame.Frame, MoveAbleFrame.FramePoint, x, y)
    if finish then
        FrameGrid.show(false)
    end
end

function MoveAbleFrame.enable(player, flag)
    if GetLocalPlayer() == player then
        if flag == nil then
            MoveAbleFrame.Enabled = not MoveAbleFrame.Enabled
        else
            MoveAbleFrame.Enabled = flag
        end
    end
    return MoveAbleFrame.Enabled
end

function MoveAbleFrame.setup(frame)
    if not MoveAbleFrame[frame] then
        MoveAbleFrame[frame] = true

        BlzTriggerRegisterFrameEvent(MoveAbleFrame.TriggerFrameEnter, frame, FRAMEEVENT_MOUSE_ENTER) --enable the hover feature
        BlzTriggerRegisterFrameEvent(MoveAbleFrame.TriggerFrameLeave , frame, FRAMEEVENT_MOUSE_LEAVE)
    end

end

onTriggerInit(function()
    xpcall(function()
    --        print("MoveAbleFrame.Init")

    MoveAbleFrame.TriggerFrameEnter = CreateTrigger()
    MoveAbleFrame.TriggerFrameEnterAction = TriggerAddAction(MoveAbleFrame.TriggerFrameEnter, function()
        if GetLocalPlayer() == GetTriggerPlayer() then
            MoveAbleFrame.PlayerHoveredFrame = BlzGetTriggerFrame()
        end
    end)
    
    MoveAbleFrame.TriggerFrameLeave = CreateTrigger()
    MoveAbleFrame.TriggerFrameLeaveAction = TriggerAddAction(MoveAbleFrame.TriggerFrameLeave, function()
        if GetLocalPlayer() == GetTriggerPlayer() then
            MoveAbleFrame.PlayerHoveredFrame = nil
        end
    end)

    MoveAbleFrame.MouseClickTrigger = CreateTrigger()
    MoveAbleFrame.MouseClickTriggerAction = TriggerAddAction(MoveAbleFrame.MouseClickTrigger, function()
        if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
            local player = GetTriggerPlayer()
            if MoveAbleFrame.PlayerHoveredFrame then
                --UI Edit Mode start moving that frame
                if MoveAbleFrame.Enabled then
                    if GetLocalPlayer() == player then
                        MoveAbleFrame.startMoving(MoveAbleFrame.PlayerHoveredFrame)
                    end
                end
            end
        end
    end)
    
    for playerIndex = 0, GetBJMaxPlayers()-1,1 do
        TriggerRegisterPlayerEvent(MoveAbleFrame.MouseClickTrigger, Player(playerIndex), EVENT_PLAYER_MOUSE_DOWN)
    end
end, err)
end)