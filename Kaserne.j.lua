--[[
	Kasernen 1.1.6
	By Tasyen

System to let units spawn constantly troops.

==============
API
==============
function Kaserne.createSpawnPoint(unit, spawnPoint, chargePoint, facing)
	creats an KaserneObject that spawns units at location spawnPoint and lets units "attack" to chargePoint
	The points are required to be kept for this to work.
	returns a table managing this

function Kaserne.addSpawn(kaserneObject, intervale, unitsTable, firstdelay, delayBetweenSpawns)
	adds an wave spawning for a table gained with Kaserne.createSpawnPoint.
	firstdelay
	Every intervale unitsTable will spawn between 2 units spawning delayBetweenSpawns seconds are waited
	such spawning is not enabled on default

function Kaserne.enableSpawn(who, flag)
	starts or stops the intervales for who. Who can be the Kaserne the KaserneTable or an single WaveSpawn.
	has to be called for each created kaserne before the spawn
	can also be called with Kaserne.enableSpawn(nil, true) to (re)start all Timers or false to stop all

function Kaserne.startSpawning(kaserneSpawnObject)
	kaserneSpawnObject creates a wave
function Kaserne.startSpawningUnit(unit)
	all kaserneSpawnObject of that unit spawn waves
function Kaserne.spawn(kaserneSpawnObject, index)
	spawn 1 solider

function Kaserne.UnitCreated(unit, kaserneSpawnObject)
	this is executed for each unit spawned might helpful customizing it.
--]]
Kaserne = {}
Kaserne.All = CreateGroup()
-- Model used by kaserneSpawnObject on default, one can change the Model for each waveSpawn (Kaserne.addSpawn) indiviudal
Kaserne.SpawnGrafik = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTo.mdl"

--This happens to any  spawned by a fabrik it was outsourced into a  to make it more easy to custimze
function Kaserne.UnitCreated(unit, kaserneSpawnObject)
	local kaserneObject = kaserneSpawnObject.Parent

	RemoveGuardPosition(unit)
	IssuePointOrderLoc(unit, "attack", kaserneObject.PointCharge )

	--Custom coli:
	--UnitAddAbility(unit, 'Aeth' )

	SetUnitAcquireRange(unit, 600.00)

end

function Kaserne.createSpawnPoint(unit, spawnPoint, chargePoint, facing)
	if not Kaserne[unit] then Kaserne[unit] = {} end
	local newObject = {}
	table.insert( Kaserne[unit], newObject)
	GroupAddUnit(Kaserne.All, unit)
	newObject.Unit = unit
	newObject.PointSpawn = spawnPoint
	newObject.PointCharge = chargePoint
	newObject.Facing = facing
	newObject.Spawns = {}
	return newObject
end

function Kaserne.spawn(kaserneSpawnObject, index)
	-- a kaserneSpawnObject is gained with Kaserne.addSpawn
	local parent = kaserneSpawnObject.Parent
	local newUnit = CreateUnitAtLoc(GetOwningPlayer(parent.Unit), kaserneSpawnObject.Units[index], parent.PointSpawn, parent.Facing)
	Kaserne.UnitCreated(newUnit, kaserneSpawnObject)
end

function Kaserne.TimerActionSpawn()
	local timerObject = Kaserne[GetExpiredTimer()]
	local kaserneSpawnObject = timerObject.Parent
	timerObject.Count = timerObject.Count + 1
	--First execution?
	if timerObject.Count == 1 and timerObject.Count < #kaserneSpawnObject.Units then
		--spawn over Time?
		if kaserneSpawnObject.DelayBetweenSpawns > 0 then
			--start over Time Spawn
			TimerStart(GetExpiredTimer(), kaserneSpawnObject.DelayBetweenSpawns, true, Kaserne.TimerActionSpawn)
		else
			for index = 1, #kaserneSpawnObject.Units, 1 do
				Kaserne.spawn(kaserneSpawnObject, index)
			end
			timerObject.Count = #kaserneSpawnObject.Units + 1
		end
	end
	
	-- spawned all Units?
	if timerObject.Count > #kaserneSpawnObject.Units then
		DestroyEffect(timerObject.Effect)
		timerObject.Effect = nil
		timerObject.Timer = nil
		Kaserne[GetExpiredTimer()] = nil
		PauseTimer(GetExpiredTimer())
		DestroyTimer(GetExpiredTimer())
	else
		-- no, spawn more
		Kaserne.spawn(kaserneSpawnObject, timerObject.Count)
	end
end

function Kaserne.startSpawning(kaserneSpawnObject)
	local newObject = {}
	newObject.Timer = CreateTimer()
	newObject.Count = 0
	newObject.Parent = kaserneSpawnObject
	newObject.Effect = AddSpecialEffectLoc(kaserneSpawnObject.SpawnGrafik, kaserneSpawnObject.Parent.PointSpawn)
	Kaserne[newObject.Timer] = newObject
	TimerStart(newObject.Timer, kaserneSpawnObject.DelayFirst, false, Kaserne.TimerActionSpawn)
end
function Kaserne.startSpawningUnit(unit)
	for index, value in ipairs(Kaserne[who].Spawns) do
		Kaserne.startSpawning(value)
	end
end

function Kaserne.TimerActionStartSpawning()
	Kaserne.startSpawning(Kaserne[GetExpiredTimer()])
end

function Kaserne.addSpawn(kaserneObject, intervale, unitsTable, firstdelay, delayBetweenSpawns)
	-- a kaserneObject is gained with Kaserne.createSpawnPoint
	if not firstdelay or firstdelay < 0 then firstdelay = 0 end
	if not delayBetweenSpawns or delayBetweenSpawns < 0 then delayBetweenSpawns = 0 end
	local newObject = {}
	table.insert(kaserneObject.Spawns, newObject)
	newObject.Parent = kaserneObject
	newObject.IntervaleValue = intervale
	newObject.IntervaleTimer = CreateTimer()
	Kaserne[newObject.IntervaleTimer] = newObject
	newObject.Units = unitsTable
	newObject.SpawnGrafik = Kaserne.SpawnGrafik
	newObject.DelayBetweenSpawns = delayBetweenSpawns
	newObject.DelayFirst = firstdelay
	return newObject
end
function Kaserne.EnableSpawnKaserne(object, flag)
	if flag then
		TimerStart(object.IntervaleTimer, object.IntervaleValue, true, Kaserne.TimerActionStartSpawning)
	else
		PauseTimer(object.IntervaleTimer)
	end

end

function Kaserne.enableSpawn(who, flag)
	-- selected none -> affect all
	if not who then

		ForGroup(Kaserne.All, function()
			for _, spawnWay in ipairs(Kaserne[GetEnumUnit()]) do
				for _, value in ipairs(spawnWay.Spawns) do
					Kaserne.EnableSpawnKaserne(value, flag)
				end
			end
		
		end)
	-- selected the unit?
	elseif tostring(who):sub(1, 5) == "unit:" then
		for _, spawnWay in ipairs(Kaserne[who]) do
			for _, value in ipairs(spawnWay.Spawns) do
				Kaserne.EnableSpawnKaserne(value, flag)
			end
		end
	-- selected the kaserneObject?
	elseif who.Unit then
		for index, value in ipairs(who.Spawns) do
			Kaserne.EnableSpawnKaserne(value, flag)
		end
	-- selected the kaserneSpawnObject?
	elseif who.Units then
		Kaserne.EnableSpawnKaserne(who, flag)
	end	
end