--[[
	UnitWithinRange 1.5
	By Tasyen

Allows to register specific Units to throw events when an  enters a wanted range.
Inside this Events you have access to the entered , the enteringUnit and the Range this was registered on.


How UnitWithinRange works?
UnitWithinRange generateds for any Unit Registered an own Trigger handling Unit comes in Range of x.
By Connecting Unit/Trigger with Hashtabels under their HandleID

===================
Event/Trigger
===================
udg_WithinRangeEvent tells you what happens
	udg_WithinRangeEvent = 1 	Enters
	
udg_WithinRangeUnit is the Unit who was Registered
udg_WithinRangeEnteringUnit is the Unit who came in Range
udg_WithinRangeRange is the Range under which this was registered (it is not the distance between 2 units, the distance  will bve from the center of each  while the range detecions includes colisionsizes).

===================
API
===================
function UnitWithinRange.create(unit, range[, filter])
	creates if there isn't already such one for unit with range and filter.
	Returns the new created table or the already existing table for this range.

function UnitWithinRange.destory(unitWithinRangeTable)
	destroys unitWithinRangeTable can also be called with an unit to destroy all of registered unitWithinRangeTable

function UnitWithinRange.setEvent(unitWithinRangeTable[, event])
	udg_WithinRangeEvent will take that event when an unit enters
	use nil/0 to disable event throwing

function UnitWithinRange.addselfClear(unit[, action])
	this unit will destroy all UnitWithinRange data when life dropping below 0.405 and calls the action (function(unit))

function UnitWithinRange.addAction(unitWithinRangeTable, action)
	action will be called when an unit enters.
	action can be an trigger or a function
	a function supports arguments(registered Unit, registered Range, Entering Unit, unitWithinRangeTable)
===================
--]]
UnitWithinRange = {}
UnitWithinRange.SelfClear = {}
function UnitWithinRange.Action()
	local unitWithinRangeTable = UnitWithinRange[GetTriggeringTrigger()]

	if unitWithinRangeTable.Event and unitWithinRangeTable.Event ~= 0 then
		udg_WithinRangeUnit = unitWithinRangeTable.Unit
		udg_WithinRangeEnteringUnit = GetTriggerUnit()
		udg_WithinRangeRange = unitWithinRangeTable.Range
		globals.udg_WithinRangeEvent = 0.0
		globals.udg_WithinRangeEvent = unitWithinRangeTable.Event
		globals.udg_WithinRangeEvent = 0.0
	end

	for index, value in ipairs(unitWithinRangeTable.Action)
	do
		if type(value) == "function" then
			value(unitWithinRangeTable.Unit, unitWithinRangeTable.Range, GetTriggerUnit(), unitWithinRangeTable)
		else
			udg_WithinRangeUnit = unitWithinRangeTable.Unit
			udg_WithinRangeEnteringUnit = GetTriggerUnit()
			udg_WithinRangeRange = unitWithinRangeTable.Range
			ConditionalTriggerExecute(value)
		end

	end
end

function UnitWithinRange.create(unit, range, filter)
	if not UnitWithinRange[unit] then UnitWithinRange[unit] = {} end
	if not UnitWithinRange[unit][range] then
		local newObject = {}
		UnitWithinRange[unit][range] = newObject
		local trigger = CreateTrigger()
		UnitWithinRange[trigger] = newObject
		newObject.Unit = unit
		newObject.Range = range
		newObject.Event = 1.0
		newObject.Trigger = trigger
		newObject.Action = {}
		newObject.Filter = filter
		newObject.TriggerAction = TriggerAddAction(trigger,  UnitWithinRange.Action)
		TriggerRegisterUnitInRange(trigger, unit, range, filter)

		return newObject
	else
		return UnitWithinRange[unit][range]
	end
end

function UnitWithinRange.SelfClearAction()
	local unit = GetTriggerUnit()
	for index, value in ipairs(UnitWithinRange.SelfClear[unit].Actions)
	do
		value(unit)
	end
	UnitWithinRange.SelfClear[unit].Actions = nil
	UnitWithinRange.destory(unit)
end

function UnitWithinRange.addselfClear(unit, action)
	local selfClear = UnitWithinRange.SelfClear[unit]
	if not selfClear then
		selfClear = {}
		local trigger = CreateTrigger()
		selfClear.Actions = {}
		selfClear.TriggerAction = TriggerAddAction(trigger, UnitWithinRange.SelfClearAction)
		selfClear.Trigger = trigger

		TriggerRegisterUnitStateEvent(trigger, unit, UNIT_STATE_LIFE, LESS_THAN_OR_EQUAL, 0.405)
		UnitWithinRange.SelfClear[unit] = selfClear
	end
	if action then
		table.insert(selfClear.Actions, action)
	end
end

function UnitWithinRange.setEvent(unitWithinRangeTable, event)
	unitWithinRangeTable.Event = event
end

function UnitWithinRange.addAction(unitWithinRangeTable, action)
	table.insert(unitWithinRangeTable.Action, action)
end

function UnitWithinRange.destory(unitWithinRangeTable)
	if type(unitWithinRangeTable) == "table" then
		TriggerRemoveAction(unitWithinRangeTable.Trigger, unitWithinRangeTable.TriggerAction)
		DestroyTrigger(unitWithinRangeTable.Trigger)
		unitWithinRangeTable.Trigger = nil
		unitWithinRangeTable.TriggerAction = nil
		unitWithinRangeTable.Action = nil
		unitWithinRangeTable.Event = nil
		UnitWithinRange[unitWithinRangeTable.Unit][unitWithinRangeTable.Range] = nil
	elseif UnitWithinRange[unitWithinRangeTable] then
		local unit = unitWithinRangeTable
		for range, value in pairs(UnitWithinRange[unit])
		do
			UnitWithinRange.destory(value)
		end

		if UnitWithinRange.SelfClear[unit] then
			local selfClear = UnitWithinRange.SelfClear[unit]
			TriggerRemoveAction(selfClear.Trigger, selfClear.TriggerAction)
			DestroyTrigger(selfClear.Trigger)
			UnitWithinRange.SelfClear[unit] = nil
		end
		
		UnitWithinRange[unit] = nil
	end
end