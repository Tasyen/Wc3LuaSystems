--[[
	CapturePoint System 1.6 Lua
	By Tasyen

Allows to Make any Unit, you Register, captureable by staying near to it.
This System has to be called before it starts working, is done in "CapturePoint Init" on default.
Uses the UnitWithinRangeEvent

=========================================================================================================
Capture Style:
=========================================================================================================
	0 = +1 Influence, if only Allies are inside the CaptureZone. -1 If only Foes.
	1 = Like 0; but Lose Influence, if no Ally is inside.
	2 = +1 Influence if more allies; -1 if more foes
	3 = Like 2; but Lose Influence, if no Ally is inside.
	4 = Influence gain/loss is done by difference of Foes and allies 
	5 = Like 4; but Lose Influence, if no Ally is inside.

to define new Styles Checkout "CapturePoint.Styles" and inser them

=========================================================================================================
CapturePointEvent
=========================================================================================================
With CapturePointEvent you can catch some nice Situations.

	CatpurePointEvent = 1  	udg_CapturePointEventMovedUnit Starts Influenceing udg_CapturePointEventUnit
	CapturePointEvent = -1	udg_CapturePointEventMovedUnit stopps Influenceing udg_CapturePointEventUnit

	InfluencePercent Steps: udg_CapturePointEventPlayer = leadingPlayer, on a negative capturePointEvent its equal to owner.

	CapturePointEvent = 25  udg_CapturePointEventPlayer reached 25%% Influence on udg_CapturePointEventUnit
	CapturePointEvent = 50  udg_CapturePointEventPlayer reached 50%% Influence on udg_CapturePointEventUnit
	CapturePointEvent = 75  udg_CapturePointEventPlayer reached 75%% Influence on udg_CapturePointEventUnit
	CapturePointEvent = -75 controlled CapturePoint udg_CapturePointEventUnit was reduced below 75%%
	CapturePointEvent = -50 controlled CapturePoint udg_CapturePointEventUnit was reduced below 50%%
	CapturePointEvent = -25 controlled CapturePoint udg_CapturePointEventUnit was reduced below 25%%

You can modify the Percent Events in the approaching Definition 
=========================================================================================================
API:
=========================================================================================================
CapturePoint.addUnit(unit[, range, influence, style, x, y, z, scale])
	Makes an Unit Captureable and generateds an CaptureBar over it.
	not set values are taken from CapturePoint.Default.
	unit has to be set

CapturePoint.removeUnit(unit, DeregisterUnitWithin )
	Makes an Captureable Unit uncaptureable again.
	If true the  will be kicked out of UnitWithin too.

CapturePoint.stopTimer()
	Stops the Influence Timer and the Grafic Update Timer of CapturePoint

CapturePoint.startTimer()
	Starts the timers of this System.
	Is done if you this System the first time.

	
function CapturePoint.enableEvent(unit, flag)
	disable or enable throwing events for that capture point
	udg_CatpurePointEvent = 1 | -1

Action API
=========================================================================================================
Actions are functions that are called when such a thing happens for an specific capturepoint

function CapturePoint.setEnterAction(unit, actionFunction)
	actionFunction will be called when an unit starts influencing unit
	actionFunction(capturePoint, enteringUnit)

function CapturePoint.setLeaveAction(unit, actionFunction)
	when an unit stops influecing
	actionFunction(capturePoint, leavingUnit)

function CapturePoint.setCaptureAction(unit, actionFunction)
	actionFunction(capturePoint, newOwner)
	This happens before the ownerShip changes use GetOwningPlayer(capturePoint) to get the old/current Owner
	Also happens when neutralising

function CapturePoint.setPercentAction(unit, actionFunction)
	actionFunction(capturePoint, leadingPlayer, oldStep, newStep)
	leadingPlayer is the player that loses/gains control
	


=========================================================================================================
		Definitions:
=========================================================================================================
--]]
CapturePoint = {}
--Define how much influnce Influnce Generated by unit
--If you don't want such a behaviour simply remove anything except the last "return 1"
function CapturePoint.InfluencePower(unit)
	if IsUnitType(unit, UNIT_TYPE_HERO) then
		return 2
	else
		if IsUnitType(unit, UNIT_TYPE_SUMMONED) then
			return 0
		else 
			return 1
		end
	end
	return 1	
end

--Structures, Neutral Passive Units, Capture Points and Aloc Units are exclude from using capturing.
--this is a filter of EnterRange Hence the usage of GetTriggerUnit
CapturePoint.DefaultFiler = Condition(function ()
	local unit = GetTriggerUnit()
	if IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
		return false
	end
	if GetOwningPlayer(unit) == Player(PLAYER_NEUTRAL_PASSIVE) then
		return false
	end
	if IsUnitInGroup(unit, udg_CapturePoints) then
		return false
	end
	if GetUnitAbilityLevel(unit, FourCC('Aloc')) > 0 then
		return false
	end
	
	--local b = not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and GetOwningPlayer(unit) ~= Player(PLAYER_NEUTRAL_PASSIVE) and not IsUnitInGroup(unit, udg_CapturePoints) and GetUnitAbilityLevel(unit, FourCC('Aloc')) == 0
	return true
end)



--If Influence Rises/Falls over a negative/positive x time of this value a Event with this Value is thrown
--Default 25/50/75 %%;
--0%% Event is hardcoded excluded. 
-- Anything below 5 is not Recommented.
-- Insering 0 or 1 will break the system.
CapturePoint.PercentEventBase =	0.25

--Default value; Do Captur Points throw Events?
CapturePoint.DefaultThrowEvent = true

--Is used in RegisterCapturePointSimple
CapturePoint.DefaultStyle = 0
CapturePoint.DefaultRange = 400
CapturePoint.DefaultInfluence = 30


--Is used in RegisterCapturePointSimple & CapturePoint.addUnit
CapturePoint.DefaultBarOffsetX = 0
CapturePoint.DefaultBarOffsetY = 50
CapturePoint.DefaultBarOffsetZ = 300
CapturePoint.DefaultBarScale = 3


CapturePoint.TimerInterval = 0.5
--How long is one Interval of Capture, The time to capture a CapturePoint is CaptureTimerInterval*Influence (*2, if Controled by foe)
--Capture Points first have to be neutralised

--the styles supported
CapturePoint.Styles = {}
-- 0 = +1 Influence, if only Allies are inside the CaptureZone. -1 If only Foes.
-- 1 = Like 0; but Lose Influence, if no Ally is inside.
-- 2 = +1 Influence if more allies; -1 if more foes
-- 3 = Like 2; but Lose Influence, if no Ally is inside.
-- 4 = Influence gain/loss is done by difference of Foes and allies 
-- 5 = Like 4; but Lose Influence, if no Ally is inside.
CapturePoint.Styles[0] = function(influence, influenceMax, allies, foes)
	if allies ~= 0 and foes == 0 then	--Only Allies?
		if influence == influenceMax then	--Exceed Limit?
			return 0	--It execeeds.
		else
			return 1
		end
	elseif allies == 0 and foes ~= 0 then	--Only Foes?
		if influence == 0 then	--Exceed Limit?
			return 0	--It execeeds.
		else 
			return -1
		end
	else --nobody or both
		return 0
	end	
end

CapturePoint.Styles[1] = function(influence, influenceMax, allies, foes)
	if allies ~= 0 and foes == 0 then	--Only Allies?
		if influence == influenceMax then
			return 0
		else
			return 1
		end	
	else
		if allies == 0 then	--No allies?
			if influence == 0 then
				return 0
			else 
				return -1
			end
		else
			return 0	--There are Allies and Foes, do !
		end
	end
	return 0
end

CapturePoint.Styles[2] = function(influence, influenceMax, allies, foes)
	if allies > foes then	--More Allies?
		if influence == influenceMax then
			return 0
		else
			return 1
		end
	end 
	if  allies < foes then	--Less Allies?
		if influence == 0 then
			return 0
		else 
			return -1
		end
	end
	return 0
end

CapturePoint.Styles[3] = function(influence, influenceMax, allies, foes)
	if allies > foes then
		if influence == influenceMax then
			return 0
		else
			return 1
		end
	end 
	if  allies < foes or allies == 0 then	--Less Allies or none Ally?
		if influence == 0 then
			return 0
		else 
			return -1
		end
	end
	return 0
end

CapturePoint.Styles[4] = function(influence, influenceMax, allies, foes)
	if influence + (allies - foes) < influenceMax then	--New Influence below Upper Limit?
		if influence + (allies - foes) > 0 then		--New Influence above lower Limit?
			return (allies - foes)
		else 
			return	-influence	--Below Lower Limit Reduce by current Influence, to 0 it!
		end	
	else
		return influenceMax - influence	--Above Upper Limit Return Missing to Upper Limit!
	end
	return 0
end

CapturePoint.Styles[5] = function(influence, influenceMax, allies, foes)
	if allies == 0 and foes == 0 then --No Influncing Unit -> Lose 1 Influence?
		if influence == 0 then
			return 0
		else
			return -1
		end
	else --Style 4
		if influence + (allies - foes) < influenceMax then	
			if influence + (allies - foes) > 0 then
				return (allies - foes)
			else 
				return	-influence
			end		
		else
			return influenceMax - influence
		end
	end
	return 0
end

--======================================================================================================
--System Code Start
--======================================================================================================
--every Function starting with an upperCase is used by the system, lowerCase Functions are part of the API
function CapturePoint.AddBar(unit, x, y, z, scale)
	local bar = AddSpecialEffect(udg_CapturePointBarType, GetUnitX(unit) + x, GetUnitY(unit) + y)
	BlzSetSpecialEffectTimeScale(bar, 0)	--Disalbe AutoAnimation
	BlzSetSpecialEffectTime(bar, 0)
	BlzSetSpecialEffectScale(bar, scale)
	BlzSetSpecialEffectHeight(bar, GetUnitFlyHeight(unit) + z)

	local data = CapturePoint[unit]
	data.Bar = bar
	data.BarX = x
	data.BarY = y
	data.BarZ = z
	
	local owner = GetOwningPlayer(unit)
	if owner ~= Player(PLAYER_NEUTRAL_PASSIVE) then
		BlzSetSpecialEffectTime(bar, 1)
		BlzSetSpecialEffectColorByPlayer(bar, owner)
	end
end

function CapturePoint.SetupData(unit, range, influence, style)
	if CapturePoint[unit] then return false end

	CapturePoint[unit] = {}
	CapturePoint[CapturePoint[unit]] = unit

	if IsUnitInGroup( unit, udg_CapturePoints) then
		return false
	end
	
	local unitWithinRangeTable = UnitWithinRange.create(unit, range, CapturePoint.DefaultFiler)
	UnitWithinRange.setEvent(unitWithinRangeTable, nil)
	UnitWithinRange.addAction(unitWithinRangeTable, CapturePoint.EnterAction)
	UnitWithinRange.addselfClear(unit, CapturePoint.AutoClean)
	CapturePoint[unit].WithinRange = unitWithinRangeTable
	CapturePoint[unit].ThrowEvent = true

	GroupAddUnit(udg_CapturePoints, unit)
	local  owner = GetOwningPlayer(unit)
	CapturePoint[unit].Influencer = CreateGroup()
	CapturePoint[unit].LeadingPlayer = owner
	CapturePoint[unit].InfluenceNeed = influence
	CapturePoint[unit].Style = style
	--Start with Max Influence, if Controled already
	if owner ~= Player(PLAYER_NEUTRAL_PASSIVE) then
		CapturePoint[unit].InfluenceCurrent = influence
	else
		CapturePoint[unit].InfluenceCurrent = 0
	end
	return true
end

function CapturePoint.setEnterAction(unit, actionFunction)
	CapturePoint[unit].ActionEnter = actionFunction
end
function CapturePoint.setLeaveAction(unit, actionFunction)
	CapturePoint[unit].ActionLeave = actionFunction
end
function CapturePoint.setCaptureAction(unit, actionFunction)
	CapturePoint[unit].ActionCapture = actionFunction
end
function CapturePoint.setPercentAction(unit, actionFunction)
	CapturePoint[unit].ActionPercent = actionFunction
end
function CapturePoint.enableEvent(unit, flag)
	CapturePoint[unit].ThrowEvent = flag
end

--Inser a Unit as Captureable Capture Unit, Range is the distance from which the  can be captured,
--Influence * CapturePoint.TimerInterval time in seconds, style defines under which situation influences changes 
--Uses more arguments to define x/y/z/facing indiviudal
function CapturePoint.addUnit(unit, range, influence, style, x, y, z, scale)
	if not range then range = CapturePoint.DefaultRange end
	if not influence then influence = CapturePoint.DefaultInfluence end
	if not style then style = CapturePoint.DefaultStyle end
	if not x then x = CapturePoint.DefaultBarOffsetX end
	if not y then y = CapturePoint.DefaultBarOffsetY end
	if not z then z = CapturePoint.DefaultBarOffsetZ end
	if not scale then scale = CapturePoint.DefaultBarScale end
	
	if CapturePoint.SetupData(unit, range, influence, style) then
		CapturePoint.AddBar(unit, x, y, z, scale)
		return true
	else
		return false
	end	

end

--Makes a Capture Point uncapturable, second argument asks if it should be removed from the "Unit within"-System too.
--Removes the Bar Unit from the game.
function CapturePoint.removeUnit(unit, DeregisterUnitWithin)
	if DeregisterUnitWithin then
		UnitWithinRange.destory(unit)
	end
	GroupRemoveUnit(udg_CapturePoints, unit)
	
	GroupClear(CapturePoint[unit].Influencer)
	DestroyGroup(CapturePoint[unit].Influencer)
	BlzSetSpecialEffectTimeScale(CapturePoint[unit].Bar, 10)
	DestroyEffect(CapturePoint[unit].Bar)
	CapturePoint[unit] = nil
	return true
end

--This catches the WithingRangeEvent = -1
-- aka Removed/Killed/Replaced
--We do not clean in WithinRange cause it does it onitself if this  is thrown.
function CapturePoint.AutoClean(unit)
	CapturePoint.removeUnit(unit, false)
end

--Returns the Leader of the team of the  if there is such a thing or the  itself.
function CapturePoint.GetPlayerTeam(p)
    local teamNr = GetPlayerTeam(p)
    if GetPlayerId(p) <= GetBJMaxPlayers() and udg_CapturePointTeamLeader[teamNr] ~= nil then
        --swap owner to the Team Leader
        return udg_CapturePointTeamLeader[teamNr]
    else
        return p
    end
end

--Is Called with the Custom-Event UnitWithin = 1.
function CapturePoint.EnterAction(registeredUnit, registeredRange, enteringUnit, unitWithinRangeTable)
	local data = CapturePoint[registeredUnit]
	local owner = GetOwningPlayer(enteringUnit)

	if IsUnitInGroup(enteringUnit, data.Influencer) then
		return	--Do not allow twice
	end	
	GroupAddUnit(data.Influencer, enteringUnit)
	
	--Become the Leading Player if current Leadingplayer is Neutral_Passive.
	if data.LeadingPlayer == Player(PLAYER_NEUTRAL_PASSIVE) then
        --this team has a Leader?
		owner = CapturePoint.GetPlayerTeam(owner)
		data.LeadingPlayer = owner
        BlzSetSpecialEffectColorByPlayer(data.Bar, owner)
	end
	if data.ThrowEvent then
		--Event Entered
		udg_CapturePointEventMovedUnit = enteringUnit
		udg_CapturePointEventUnit = registeredUnit
		globals.udg_CapturePointEvent = 0
		globals.udg_CapturePointEvent = 1
		globals.udg_CapturePointEvent = 0
	end
	if CapturePoint[unit].ActionEnter then
		CapturePoint[unit].ActionEnter(registeredUnit, enteringUnit)
	end
end


--Checks all x times of CapturePoint.PercentEventBase() and throws the first found Event.
--Throws negative Events if Influence fall and a positive if Influence Rises.
-- udg_CapturePointEventUnit CapturePoint;
-- udg_CapturePointEventPlayer = leadingPlayer  -> Rising = the one will get the Point; falling the one who is losing this Point
function CapturePoint.ThrowEvent(oldPercent, newPercent, unit, player)
	
	local oldStep = math.modf(oldPercent / CapturePoint.PercentEventBase) 
	local newStep = math.modf(newPercent / CapturePoint.PercentEventBase)
	if oldStep ~= newStep then	--Step changed?
		if CapturePoint[unit].ActionPercent then
			CapturePoint[unit].ActionPercent(unit, player, oldStep, newStep)
		end

		if CapturePoint[unit].ThrowEvent then
			udg_CapturePointEventUnit = unit
			udg_CapturePointEventPlayer = player
			
			if oldStep < newStep then	--Rise?
				globals.udg_CapturePointEvent = newStep * CapturePoint.PercentEventBase * 100
			else	--Fallen below newstep + 1 (old => 8 new = 6 you enter 60%% realm -> lose the 70%% Influence)
				globals.udg_CapturePointEvent = -(newStep+1) * CapturePoint.PercentEventBase * 100
			end
			globals.udg_CapturePointEvent = 0
		end
		return true
	end
	return false
end

--Group Enumeration for all CapturePoints, Changes Influence, Ownership and Bar Color.
function CapturePoint.Loop( )
	local capturePoint = GetEnumUnit()
	local data = CapturePoint[capturePoint]
	local leadingPlayer = data.LeadingPlayer
	local allies = 0
	local foes = 0
	local playerInfluence = __jarray(0)
	local playerIdMax = bj_MAX_PLAYER_SLOTS
	
	playerInfluence[playerIdMax] = -1
	ForGroup(data.Influencer, function()
		local unit = GetEnumUnit()
		--Is Unit still Influencing?
		if not IsUnitType(unit, UNIT_TYPE_DEAD) and GetUnitTypeId(unit) ~= 0 and IsUnitInRange(unit, capturePoint, data.WithinRange.Range) then
			if not (IsUnitPaused(unit)) and not (IsUnitHidden(unit)) then	--can it influence now? 
				--Save Influence of this Player
				local playerId = GetPlayerId( GetOwningPlayer (unit))
				local influencePower = CapturePoint.InfluencePower(unit)
				playerInfluence[playerId] = playerInfluence[playerId] + influencePower
				if playerInfluence[playerId] > playerInfluence[playerIdMax] then
					playerIdMax = playerId
				end
				--Count allies/Foes.
				if IsUnitAlly (unit, leadingPlayer) then
					allies = allies + influencePower
				else
					foes = foes + influencePower
				end
			end
		else
			GroupRemoveUnit(data.Influencer, unit)
			--This  is no Influencer for this point anymore.
			--Event Unit stops Influenceing
			if data.ThrowEvent then
				udg_CapturePointEventUnit = capturePoint
				udg_CapturePointEventMovedUnit = unit
				globals.udg_CapturePointEvent = 0
				globals.udg_CapturePointEvent = -1
				globals.udg_CapturePointEvent = 0
			end
			
			if data.ActionLeave then
				data.ActionLeave(capturePoint, unit)
			end
			
		end
	end)

	local influence = data.InfluenceCurrent
	local influenceMax = data.InfluenceNeed

	
	local influenceGain = CapturePoint.Styles[data.Style](influence, influenceMax, allies, foes)
	--Is there InfluenceGain?	
	if influenceGain ~= 0  then
		local oldPercent = I2R(influence) / influenceMax
		influence = influence + influenceGain	
		data.InfluenceCurrent =	influence		
		local newPercent = I2R(influence) / influenceMax
		BlzSetSpecialEffectTime(data.Bar, newPercent)
		--Call Influence %%-Event?
		if data.ActionPercent or data.ThrowEvent then
			--CapturePoint.ThrowEvent(R2I(oldPercent*100),R2I(newPercent*100),capturePoint,leadingPlayer)
			CapturePoint.ThrowEvent(oldPercent,newPercent,capturePoint,leadingPlayer)
		end
	end

	if influenceGain ~= 0 or not IsUnitOwnedByPlayer (capturePoint, leadingPlayer) then	
		--Neutralise the Point?
		if influence == 0 then
			--ControlLose with units?
			if FirstOfGroup(data.Influencer) ~= nil then
				leadingPlayer = Player(playerIdMax)
				BlzSetSpecialEffectColorByPlayer(data.Bar, leadingPlayer)
			else
				leadingPlayer = Player(PLAYER_NEUTRAL_PASSIVE)
				BlzSetSpecialEffectColorByPlayer(data.Bar, leadingPlayer)
			end
			if data.ActionCapture then
				data.ActionCapture(capturePoint, leadingPlayer, GetOwningPlayer(capturePoint))
			end
			SetUnitOwner (capturePoint, Player(PLAYER_NEUTRAL_PASSIVE), true)
			data.LeadingPlayer = CapturePoint.GetPlayerTeam(leadingPlayer)
			BlzSetSpecialEffectTime(data.Bar, 0)
			
		else
			--Leading Player captures it?
			if influence == influenceMax and not IsUnitOwnedByPlayer (capturePoint, leadingPlayer) then
				if data.ActionCapture then
					data.ActionCapture(capturePoint, leadingPlayer, GetOwningPlayer(capturePoint))
				end
				SetUnitOwner(capturePoint, leadingPlayer, true)
                --Added 1.4a to support changing the ownership of the captured  inside the change owner 
                leadingPlayer = GetOwningPlayer(capturePoint)
				data.LeadingPlayer = leadingPlayer
				
			end
			BlzSetSpecialEffectColorByPlayer(data.Bar, leadingPlayer)
		end
	end
end

--Group Enumeration for all CapturePoints repos Bars
function CapturePoint.ReposBar()
	local unit = GetEnumUnit()
	local data = CapturePoint[unit]
	BlzSetSpecialEffectPosition(data.Bar, GetUnitX(unit) + data.BarX, GetUnitY(unit) + data.BarY, GetUnitFlyHeight(unit) + data.BarZ )
end

function CapturePoint.TimerReposBar()
	ForGroup(udg_CapturePoints, CapturePoint.ReposBar)
end

function CapturePoint.TimerInfluence()
	ForGroup(udg_CapturePoints,  CapturePoint.Loop)
end

function CapturePoint.startTimer()
	TimerStart(udg_CapturePointTimer[0], CapturePoint.TimerInterval, true, CapturePoint.TimerInfluence)
	TimerStart(udg_CapturePointTimer[1], 1.0/32.0, true, CapturePoint.TimerReposBar)
end

function CapturePoint.stopTimer( )
	PauseTimer(udg_CapturePointTimer[0])
	PauseTimer(udg_CapturePointTimer[1])
end

--Is Executed if you run CapturePoint the first time.
--Start Catching Events thrown by UnitWithinRange
--Start [0][1]
function CaptureInit( )
	CapturePoint.startTimer()
end