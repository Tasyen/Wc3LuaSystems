--[[
MoveAbleFrame by Tasyen
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

function MoveAbleFrame.reset(frame)
    removes the user moved mark and moves the frame back to its defined Reset pos
function MoveAbleFrame.resetAll(player)
    batch for userMovedFrameReset for all userMoveAbleFrames

function MoveAbleFrame.defineFrameReset(frame, point, frameB, pointB, x, y, doMove)
    where the frame will be moved back to when using reset, doMove(true) move them instantly with this call
function MoveAbleFrame.defineFrameResetAbs(frame, point, x, y, doMove)
    wrapper

function MoveAbleFrame.saveInFile(fileName)
    saves userMovedFrames into a file fileName, no extension needed
    
function MoveAbleFrame.loadFile(fileName)
    Loads data from a saved File, no extension needed. 
    
function MoveAbleFrame.userMovedFrame(frame, point, frameB, pointB, x, y)
    save movement done by user
function MoveAbleFrame.userMovedFrameAbs(frame, point, x, y)
    wrapper
--]]
MoveAbleFrame = {}
MoveAbleFrame.Enabled = false --only when this is true, right clicking will have an effect on frames
MoveAbleFrame.Frame = nil -- the Frame beeing Moved
MoveAbleFrame.FramePoint = nil -- the FramePoint Frame is posed with nil = CENTER

--this should save user changed frame-data.
--this also should be async, a player doesn't care about other players UI.
MoveAbleFrame.MapName = "MoveAbleFrames" -- this is used as folder for saving user UI-Data. CABS data is store in user\Documents\Warcraft III\CustomMapData\thisValue\CABS\
MoveAbleFrame.FolderName = "\\UI\\" --inside MapName add this folder for UI stuff
MoveAbleFrame.UserMoveAbleFrames = {} --all Frames beeing moveable are insert here. They also get a number.
MoveAbleFrame.UserMovedFrames = {} --all Frames the user has moved, they safe onto their key true
MoveAbleFrame.UserFrameX = {} --last x user choosen for a frame
MoveAbleFrame.UserFrameY = {} --last y user choosen
MoveAbleFrame.UserFramePoint = {}
MoveAbleFrame.UserFramePoint2 = {}
MoveAbleFrame.UserFrameFrame2 = {}
MoveAbleFrame.UserFrameSkill = {}
--default values for moveableFrames, this values the will take when reseting.
MoveAbleFrame.UserDefaultFrameX = {}
MoveAbleFrame.UserDefaultFrameY = {}
MoveAbleFrame.UserDefaultFramePoint = {}
MoveAbleFrame.UserDefaultFramePoint2 = {}
MoveAbleFrame.UserDefaultFrameFrame2 = {}

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
    MoveAbleFrame.userMovedFrameAbs(MoveAbleFrame.Frame, MoveAbleFrame.FramePoint, x, y)
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

function MoveAbleFrame.userMovedFrame(frame, point, frameB, pointB, x, y)
    MoveAbleFrame.UserMovedFrames[frame] = true
    MoveAbleFrame.UserFrameX[frame] = x
    MoveAbleFrame.UserFrameY[frame] = y
    MoveAbleFrame.UserFramePoint[frame] = point
    --when moving to x y point2 and Frame2 are nil
    MoveAbleFrame.UserFramePoint2[frame] = pointB
    MoveAbleFrame.UserFrameFrame2[frame] = frameB
end
function MoveAbleFrame.userMovedFrameAbs(frame, point, x, y)
    --wrapper
    MoveAbleFrame.userMovedFrame(frame, point, nil, nil, x, y)
end

function MoveAbleFrame.reset(frame)
    --remove the mark that this frame was moved.
    MoveAbleFrame.UserMovedFrames[frame] = nil
    if not MoveAbleFrame.UserDefaultFrameX[frame] then return end --no x set => cant reset

    BlzFrameClearAllPoints(frame)
    if MoveAbleFrame.UserDefaultFramePoint2[frame] and MoveAbleFrame.UserDefaultFrameFrame2[frame] then
        BlzFrameSetPoint(frame, MoveAbleFrame.UserDefaultFramePoint[frame], MoveAbleFrame.UserDefaultFrameFrame2[frame], MoveAbleFrame.UserDefaultFramePoint2[frame], MoveAbleFrame.UserDefaultFrameX[frame], MoveAbleFrame.UserDefaultFrameY[frame])
    else
        BlzFrameSetAbsPoint(frame, MoveAbleFrame.UserDefaultFramePoint[frame], MoveAbleFrame.UserDefaultFrameX[frame], MoveAbleFrame.UserDefaultFrameY[frame])
    end
end
function MoveAbleFrame.resetAll(player)
    --remove the mark that this frame was moved.
    if not player or GetLocalPlayer() ~= player then return end
    for frame in pairs(MoveAbleFrame.UserMovedFrames)
    do
        MoveAbleFrame.reset(frame)
    end
end

function MoveAbleFrame.defineFrameReset(frame, point, frameB, pointB, x, y, doMove)
    --This saves for moveableFrames the position where to reset to, if you want abs Points frameB, PointB = nil
    MoveAbleFrame.UserDefaultFrameX[frame] = x
    MoveAbleFrame.UserDefaultFrameY[frame] = y
    MoveAbleFrame.UserDefaultFramePoint[frame] = point
    MoveAbleFrame.UserDefaultFramePoint2[frame] = pointB
    MoveAbleFrame.UserDefaultFrameFrame2[frame] = frameB
    if doMove then
        MoveAbleFrame.reset(frame)
    end
end

function MoveAbleFrame.defineFrameResetAbs(frame, point, x, y, doMove)
    MoveAbleFrame.defineFrameReset(frame, point, nil, nil, x, y, doMove)
end

function MoveAbleFrame.setup(frame)
    if not MoveAbleFrame.UserMoveAbleFrames[frame] then
        table.insert(MoveAbleFrame.UserMoveAbleFrames, frame) --store moveAbleFrames from 1 to x
        MoveAbleFrame.UserMoveAbleFrames[frame] = #MoveAbleFrame.UserMoveAbleFrames --save the given 1 to x number for the frame

        BlzTriggerRegisterFrameEvent(MoveAbleFrame.TriggerFrameEnter, frame, FRAMEEVENT_MOUSE_ENTER) --enable the hover feature
        BlzTriggerRegisterFrameEvent(MoveAbleFrame.TriggerFrameLeave , frame, FRAMEEVENT_MOUSE_LEAVE)
    end

end

function MoveAbleFrame.userMovedFrameParse(text)
    --print("MoveAbleFrame.userMovedFrameParse")
        --expects "25,4, ,0.5349995,0.135"   moveAbleFrameIndex, ConvertFramePointTypeIndex, space , x, y
        --or "12,3,11,5,0.0015,0.0" moveAbleFrameIndex, ConvertFramePointTypeIndex, moveAbleFrameIndexRelativeFrame, ConvertFramePointTypeIndex, x, y
        if not string.mysplit then print("userMovedFrameParse","function string.mysplit missing") return end
        --print(text)
        local data = string.mysplit(text, ",")
        local frameIndex = tonumber(data[1])
        local framePoint = ConvertFramePointType(tonumber(data[2]))
        BlzFrameClearAllPoints(MoveAbleFrame.UserMoveAbleFrames[frameIndex])
        if data[3] == " " then
            --local x = tonumber(data[4])
            --local y = tonumber(data[5])
            local x = StringFraction2Number(data[4])
            local y = StringFraction2Number(data[5])
            BlzFrameSetAbsPoint(MoveAbleFrame.UserMoveAbleFrames[frameIndex], framePoint, x, y)
            MoveAbleFrame.userMovedFrameAbs(MoveAbleFrame.UserMoveAbleFrames[frameIndex], framePoint, x, y)
        else
            local frameIndex2 = tonumber(data[3])
            local framePoint2 =  ConvertFramePointType(tonumber(data[4]))
            --local x = tonumber(data[5])
            --local y = tonumber(data[6])
            local x = StringFraction2Number(data[5])
            local y = StringFraction2Number(data[6])
            BlzFrameSetPoint(MoveAbleFrame.UserMoveAbleFrames[frameIndex], framePoint, MoveAbleFrame.UserMoveAbleFrames[frameIndex2], framePoint2, x, y)
            MoveAbleFrame.userMovedFrame(MoveAbleFrame.UserMoveAbleFrames[frameIndex], framePoint, MoveAbleFrame.UserMoveAbleFrames[frameIndex2], framePoint2, x, y)
        end
    --print("Done")
end

function MoveAbleFrame.loadFile(fileName)
    xpcall(function()
    if not readFile then print("loadFile","function readFile missing") return end
    if not string.mysplit then print("loadFile","function string.mysplit missing") return end
    --print("MoveAbleFrame.loadFile", fileName)
    local ending = string.sub(fileName, string.len(fileName)-3 )
    if ending ~= ".txt" or ending ~= ".pld" then fileName = fileName .. ".txt" end
    local data = readFile(MoveAbleFrame.MapName..MoveAbleFrame.FolderName..fileName)
    --for index, value in ipairs(data) do
        --frames are sepearted with ";"
        local splited = string.mysplit(data,";")
        for indexSplited, frameText in ipairs(splited)
        do
            MoveAbleFrame.userMovedFrameParse(frameText)
        end
    --end

    --print("Done")
end, err)
end

function MoveAbleFrame.saveInFile(fileName)
   -- print("MoveAbleFrame.saveInFile", fileName)
    xpcall(function()
    if not writeFile then print("saveFile","function writeFile does not exist") return end
    if not framePoint2Index then print("saveFile","function framePoint2Index does not exist") return end
    local text = ""
    for frame in pairs(MoveAbleFrame.UserMovedFrames)
    do
        text = text .. MoveAbleFrame.UserMoveAbleFrames[frame]..","..framePoint2Index(MoveAbleFrame.UserFramePoint[frame])
        if MoveAbleFrame.UserMoveAbleFrames[MoveAbleFrame.UserFrameFrame2[frame]] then
            text = text ..",".. MoveAbleFrame.UserMoveAbleFrames[MoveAbleFrame.UserFrameFrame2[frame]]..",".. framePoint2Index(MoveAbleFrame.UserFramePoint2[frame])
        else
            text = text .. ", "
        end
        if MoveAbleFrame.UserFrameX[frame] == 0 then
            text = text ..",0" --shorten 0.000
        else
            --text = text ..","..string.format( "%%.3f",MoveAbleFrame.UserFrameX[frame])
            text = text ..","..TrimNumberFraction2String(MoveAbleFrame.UserFrameX[frame])
        end
        if MoveAbleFrame.UserFrameY[frame] == 0 then
            text = text ..",0"
        else
            --text = text ..","..string.format( "%%.3f",MoveAbleFrame.UserFrameY[frame])
            text = text ..","..TrimNumberFraction2String(MoveAbleFrame.UserFrameY[frame])
        end
        text = text .. ";" --frames are sepearted with ";"
        
    end
    if text ~= "" then
        local ending = string.sub(fileName, string.len(fileName)-3 )
        if ending ~= ".txt" or ending ~= ".pld" then fileName = fileName .. ".txt" end
        writeFile(MoveAbleFrame.MapName..MoveAbleFrame.FolderName..fileName, text)
    end
    --print("Done")
end, err)
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