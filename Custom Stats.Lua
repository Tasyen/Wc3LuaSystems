--[[
CustomStatFrame 1.2a
By Tasyen
That are the stuff one uses to access the customstat frames.
	CustomStatFrames.BoxS a parent for simpleframes hide it to easyly hide all of them
	CustomStatFrames.BoxF parent of the frames
	CustomStatFrames[index].Frame
	CustomStatFrames[index].FrameIcon = The icon of that CustomStat
	CustomStatFrames[index].FrameText = The Text of that CustomStat
	CustomStatFrames[index].FrameHover = Handle the mousehovering
	CustomStatFrames[index].ToolTipBox = The box of the tooltip
	CustomStatFrames[index].ToolTipTitle = The Title of the tooltip
	CustomStatFrames[index].ToolTipText = The text of the tooltip

--]]

CustomStatFrames = {Count = 0}
CustomStatSelectedUnit = {}
function CustomStatAdd(icon, text)
	CustomStatFrames.Count = CustomStatFrames.Count + 1
	
	local fh = BlzCreateSimpleFrame("CustomStat", CustomStatFrames.BoxS, CustomStatFrames.Count)
	local tooltipBox = BlzCreateFrame("BoxedText", CustomStatFrames.BoxF,0, CustomStatFrames.Count)
	local fhHover = BlzCreateFrameByType("FRAME", "CustomStatHover", CustomStatFrames.BoxF, "", CustomStatFrames.Count)	
	
	BlzFrameSetPoint(fhHover, FRAMEPOINT_BOTTOMLEFT, fh, FRAMEPOINT_BOTTOMLEFT, 0, 0)
	BlzFrameSetPoint(fhHover, FRAMEPOINT_TOPRIGHT, BlzGetFrameByName("CustomStatText", CustomStatFrames.Count), FRAMEPOINT_TOPRIGHT, 0, 0)
	BlzFrameSetTooltip(fhHover, tooltipBox) --when faceHover is hovered with the mouse frame tooltip becomes visible.
	
	BlzFrameSetAbsPoint(tooltipBox, FRAMEPOINT_BOTTOM, 0.6, 0.2)
	BlzFrameSetSize(tooltipBox, 0.15, 0.08)

	BlzFrameSetText(BlzGetFrameByName("CustomStatText", CustomStatFrames.Count), text)
	BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", CustomStatFrames.Count), "TooltipTitle")
	BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", CustomStatFrames.Count), text)
	BlzFrameSetTexture(BlzGetFrameByName("CustomStatIcon", CustomStatFrames.Count), icon, 0, true)
	
	
	--Dissallow having the TEXT-Tooltip-Frames gaining mouse control. This might produce problems, if the TEXT Frame has an disabled Color.
	BlzFrameSetEnable(BlzGetFrameByName("BoxedTextValue", CustomStatFrames.Count), false)
	BlzFrameSetEnable(BlzGetFrameByName("BoxedTextTitle", CustomStatFrames.Count), false)

	--[[ 4x3
	if CustomStatFrames.Count == 1 then
		BlzFrameSetAbsPoint(fh, FRAMEPOINT_TOPLEFT, 0.31, 0.08)
	elseif CustomStatFrames.Count == 5 then
		BlzFrameSetAbsPoint(fh, FRAMEPOINT_TOPLEFT, 0.375, 0.08)
	elseif CustomStatFrames.Count == 9 then
		BlzFrameSetAbsPoint(fh, FRAMEPOINT_TOPLEFT, 0.435, 0.08)
	else
		BlzFrameSetPoint(fh, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("CustomStat", CustomStatFrames.Count - 1), FRAMEPOINT_BOTTOMLEFT, 0, 0)
	end
	--]]
	--[[ 4x4
	if CustomStatFrames.Count == 1 then
		BlzFrameSetAbsPoint(fh, FRAMEPOINT_TOPLEFT, 0.31, 0.08)
	elseif CustomStatFrames.Count == 5 then
		BlzFrameSetAbsPoint(fh, FRAMEPOINT_TOPLEFT, 0.36, 0.08)
	elseif CustomStatFrames.Count == 9 then
		BlzFrameSetAbsPoint(fh, FRAMEPOINT_TOPLEFT, 0.41, 0.08)
	elseif CustomStatFrames.Count == 13 then
		BlzFrameSetAbsPoint(fh, FRAMEPOINT_TOPLEFT, 0.46, 0.08)
	else
		BlzFrameSetPoint(fh, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("CustomStat", CustomStatFrames.Count - 1), FRAMEPOINT_BOTTOMLEFT, 0, 0)
	end
	--]]

	--3x3
	if CustomStatFrames.Count == 1 then
		BlzFrameSetAbsPoint(fh, FRAMEPOINT_TOPLEFT, 0.31, 0.08)
	elseif CustomStatFrames.Count == 4 then
		BlzFrameSetAbsPoint(fh, FRAMEPOINT_TOPLEFT, 0.375, 0.08)
	elseif CustomStatFrames.Count == 7 then
		BlzFrameSetAbsPoint(fh, FRAMEPOINT_TOPLEFT, 0.435, 0.08)
	else
		BlzFrameSetPoint(fh, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("CustomStat", CustomStatFrames.Count - 1), FRAMEPOINT_BOTTOMLEFT, 0, -0.005)
	end
	
	--save into table
	CustomStatFrames[CustomStatFrames.Count] = {}
	CustomStatFrames[CustomStatFrames.Count].Frame = fh
	CustomStatFrames[CustomStatFrames.Count].FrameIcon = BlzGetFrameByName("CustomStatIcon", CustomStatFrames.Count)
	CustomStatFrames[CustomStatFrames.Count].FrameText = BlzGetFrameByName("CustomStatText", CustomStatFrames.Count)
	CustomStatFrames[CustomStatFrames.Count].FrameHover = fhHover
	CustomStatFrames[CustomStatFrames.Count].ToolTipBox = tooltipBox
	CustomStatFrames[CustomStatFrames.Count].ToolTipTitle = BlzGetFrameByName("BoxedTextTitle", CustomStatFrames.Count)
	CustomStatFrames[CustomStatFrames.Count].ToolTipText = BlzGetFrameByName("BoxedTextValue", CustomStatFrames.Count)
end

function CustomStatUpdate()
	local isVisible = BlzFrameIsVisible(CustomStatFrames.BoxS)
	
	BlzFrameSetText(CustomStatFrames[1].FrameText, BlzFrameGetText(BlzGetFrameByName("InfoPanelIconValue", 0))) --copy normal damage text
	BlzFrameSetText(CustomStatFrames[2].FrameText, BlzFrameGetText(BlzGetFrameByName("InfoPanelIconValue", 2))) --copy normal armor field
	
	BlzFrameSetText(CustomStatFrames[6].FrameText, GetUnitMoveSpeed(CustomStatSelectedUnit[GetLocalPlayer()]))
	BlzFrameSetVisible(CustomStatFrames.BoxF, BlzFrameIsVisible(CustomStatFrames.BoxS))
end

function CustomStatInit()

    --move the default unit infos out of the screen and scale it down
    local function CustomStatMoveOutOfScreen(frame)
        BlzFrameClearAllPoints(frame)
        BlzFrameSetAbsPoint(frame, FRAMEPOINT_CENTER, 3, 0)
    end
    for index = 0, 5, 1 do
        CustomStatMoveOutOfScreen(BlzGetFrameByName("InfoPanelIconBackdrop", index))		
    end
    CustomStatMoveOutOfScreen(BlzGetFrameByName("InfoPanelIconHeroIcon", 6))
	CustomStatMoveOutOfScreen(BlzGetFrameByName("InfoPanelIconAllyTitle", 7))
	CustomStatMoveOutOfScreen(BlzGetFrameByName("InfoPanelIconAllyGoldIcon", 7))

	--Create a Selection Trigger thats a pretty naive approach.
	local trig = CreateTrigger()
	TriggerAddAction(trig, function () CustomStatSelectedUnit[GetTriggerPlayer()] = GetTriggerUnit() end)
	
	local index = 0
	repeat
		TriggerRegisterPlayerSelectionEventBJ(trig, Player(index), true)
		--TriggerRegisterPlayerSelectionEventBJ(trig, Player(index), false)
		index = index + 1
	until index == bj_MAX_PLAYER_SLOTS


	--create a Parent for the Stats so you can easyly hide/show them-
	--Stats use SimpleUnitStatsPanel as parent that way they are only shown when an unit is selected which does not build.
	CustomStatFrames.BoxS = BlzCreateFrameByType("SIMPLEFRAME", "CustomStatFrames.BoxSBoss", BlzGetFrameByName("SimpleUnitStatsPanel",0), "", 0) 
	CustomStatFrames.BoxF = BlzCreateFrameByType("FRAME", "CustomStatFrames.BoxFBoss", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0) 
	
	
	
	BlzLoadTOCFile("war3mapimported\\CustomStat.toc")
	BlzLoadTOCFile("war3mapimported\\BoxedText.toc")
	
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test1")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test2")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test3")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test4")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test5")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test6")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test7")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test8")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test9")
	--[[
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test10")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test11")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test12")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test13")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test14")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test15")
	CustomStatAdd(udg_UnitStatIcon[CustomStatFrames.Count + 1],"Test16")
	--]]
	TimerStart(CreateTimer(), 0.1, true, CustomStatUpdate)
	print("Done")
end