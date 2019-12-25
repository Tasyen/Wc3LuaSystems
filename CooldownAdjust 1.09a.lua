--[[
CooldownAdjust 1.09a
By Tasyen

CooldownAdjust extends / shortens cooldowns of any casted ability, based on casters current cooldownAdjustmentValue.
The casters current cooldownAdjustmentValue is calced on Spellcasting, this still allows you alter the cooldown of an ability outside of the spellcasting and it will be considered. And removes the need of registering castable abilities.
This value then affects the cooldown only for a small moment, the spell casting.
Cooldownadjustment supports 2 ways of interpretations of cooldownAdjustmentValue: SIMPLE_MODE (LoL Like) or armor Like (warcraft 3).
Sources of cooldownAdjustment are Buffs / Abilities or ItemCodes.
Its also possible to give specific units or unitCodes of a player a base cooldownAdjustmentValue for one adjustType.
One can bind Abilities/Buff/Item Sources to groups to use only the best current available of the group.
ItemCode groups can be seperated from Ability/Buff groups.
It's also possible for a cooldownAdjustment-Source to affect only item-, ultimate- or normalSpells.

=======================
API
=======================
When not passing adjustType in any function call mentioning it, COOLDOWN_ADJUST_TYPE_ANY is used.
When not passing stackingGroup, freestacking is used.

function CooldownAdjustCalcValue(unit unit [, integer adjustType]) returns real
	- returns the cooldownAdjustmentValue unit would have for spells of adjustType.

function CooldownAdjustCalcMulti(real value) returns real
	converts cooldownAdjustmentValue in an multiplier respecting "COOLDOWN_ADJUST_CAP_SHORTEN" and "COOLDOWN_ADJUST_CAP_EXTEND" with the wanted converting type.

function CooldownAdjustUnitSetValue(unit unit, real value [, integer adjustType])
	unit will have value as default CoolDownAdjustmentValue for adjustType. Does stack with any group.

function CooldownAdjustUnitGetValue(unit unit [, integer adjustType]) returns real
	returns the units base adjustment value for exactly that adjustType. Does not consider abilities/buffs.

function CooldownAdjustUnitAddValue(unit unit, real value [, integer adjustType])
	increases the currentValue by value.
	
function CooldownAdjustUnitClear(unit unit)
	- removes the custom unit data

function CooldownAdjustPlayerUnitsSetValue(player whichPlayer, integer unitCode, real value [, integer adjustType])
	units owned by whichPlayer of unitCode have for adjustType value CooldownAdjustValue.
    Example: CooldownAdjustPlayerUnitsSetValue(Player(0), FourCC('Hpal'), 100, COOLDOWN_ADJUST_TYPE_ANY) -> paladins of player red will have 100 cooldown adjustvalue for any spellType.

function CooldownAdjustPlayerUnitsAddValue(player whichPlayer, integer unitCode, real value [, integer adjustType])
	adds value to the current value

function CooldownAdjustPlayerUnitsGetValue(player whichPlayer, integer unitCode [, integer adjustType]) returns real
	returns the base adjustment value for units owned by whichPlayer of GetUnitTypeId(unitCode) for exactly that adjustType.  Does not consider abilities/buffs.

function CooldownAdjustPlayerUnitsClear(player whichPlayer [, integer unitCode])
	clears saved data for a player for unitCode.
	unitCode is optional, when unitCode is not set all saved data for whichPlayer is cleared

function CooldownAdjustRegister(integer abilityCode, real value [, integer adjustType, real valuePerLevel, integer stackingGroup])
	- If an unit has abilityCode on SpellEffect it will be affected by this CooldownAdjust.
	-One ablityCode can have any amount of cooldownAdjustments
	- arguments after value can be skiped in a function call CooldownAdjustRegister(FourCC('AHbz'),20) resulting into:
		COOLDOWN_ADJUST_TYPE_ANY, 0 per level, Free Stacking
	- value + valuePerLevel * abilityLevel (of the ability that gives cooldownadjustment) (buffs use level 1 currently).
		: + values reduces cooldown
		: - values extends cooldown
		: COOLDOWN_ADJUST_RATIO defines how strong each value is.
		: COOLDOWN_ADJUST_SIMPLE_MODE defines how the calced value is interpreted.
	- a group is a number, all sources with the same number will be considered as one group.
		: only the highest absolute cooldownValue of each group is used. (-30 overpowers 28 and changes the groups value from 28 CooldownReduction to 30 CooldownExtension)
		: sources with group = 0 will stack freely.
		: I personaly use an abilityCode like FourCC('A000') the one first beeing added to that group which is treated as represent of that group.

function CooldownAdjustRegisterItem(integer itemCode, real value [, integer adjustType, integer stackingGroup])
	-items of itemCode give value of adjustType when picked up and loses this value when droped.
	-One benefits from the "best" item and the "best" ability of the same stackingGroup at the same time.
	-Works for tomes.
	-One itemcode can have any amount of cooldownAdjustments
	-Manipulates CooldownAdjust.UnitData

function CooldownAdjustApplyInventory(unit)
	-Runs this for any unit having items without having them pickedup (preplaced).

function CooldownAdjustExclude (integer abilityCode)
	- exclude that casted ability beeing affected from CooldownAdjust

=======================
Avoiding Cooldown Adjustment
=======================
There are multiple Options to avoid cooldownAdjustment in unwanted situations.

CooldownAdjustExclude, to filter out specific casted abilities 
"COOLDOWN_ADJUST_THRESHOLD", Every spell with a default cooldown (the global one) below or equal to this definition will be ignored.
the definition function "CustomFilter", A function in which you have access to unit, usedItem (if there is one), and to the used Spell let it return false if you want the current spllcast untouched from CooldownAdjust.
Disable CooldownAdjust.TriggerSpellCast then this system stops doing its cd manipulation.

=======================
Definitions
=======================
--]]
do
	local function CustomFilter(unit, spell, usedItem, isUltimativeSpell)
		return true
		--customizeable filter
		--return true to allow cooldownadjustment for this situation
		--return false to disallow cooldownadjustment for this situation
	end
--constants for AdjustTypes
	COOLDOWN_ADJUST_TYPE_ANY = 0 --Any spell casted
	COOLDOWN_ADJUST_TYPE_SPELL = 1 --not item, nor ultimate
	COOLDOWN_ADJUST_TYPE_ITEM = 2 --Spell used over an item
	COOLDOWN_ADJUST_TYPE_ULTIMATE = 3 --Spells having requiered hero Level not 0 nor 1.

	COOLDOWN_ADJUST_THRESHOLD = 0.5 --Abilities with a default cooldown of this or less seconds, won't have their cooldown touched.
	COOLDOWN_ADJUST_RATIO = 0.01 --How Strong is each point
	COOLDOWN_ADJUST_CAP_EXTEND = 5.0 --Maximum cooldown Multi; used by - udg_CooldownAdjustValue, 5.0 => Cooldown can be extended to 5.0 times as long
	COOLDOWN_ADJUST_CAP_SHORTEN = 0.20 --Minimum cooldown Multi; used by + udg_CooldownAdjustValue, 0.6 => Cooldown can be shortend to 60%
	COOLDOWN_ADJUST_SIMPLE_MODE = false --(true) Lol like, (false) increases the casts by Ratio in one default cooldown run.
	COOLDOWN_ADJUST_SEPERATE_ITEM_GROUPS = false --(true) an unit will benefit from the best item and ability of one group (false) only the abs best of one group is used be it item or ability.
--[[
=======================
SIMPLE_MODE (true)
	Each point affects the value by COOLDOWN_ADJUST_RATIO percent.

Example:
the buff of Brillianz-Aura shall reduces Cooldowns by 10%.

ratio = 0.01 inside COOLDOWN_ADJUST_RATIO
then we use register the Brillianz-Aura-Buff as source of CooldownAdjust with "CooldownAdjustRegister" ( integer abilityCode, real value [, integer adjustType])
->
CooldownAdjustRegister(FourCC('BHab'), 10)

with this line: any unit having the buff FourCC('BHab') will gain 10 CooldownAdjustValue. Each point interpretated as 1% cooldown reduction. the 0 means affect any spell.
so the unit would now have 10% CooldownReduction.

if one would want to have 20%, one just doubles it.
CooldownAdjustRegister(FourCC('BHab'), 20)

=======================
SIMPLE_MODE (fasle)
In this mode each point increases the casts per default cooldown by ratio (when one could cast instantly). For the user it looks like first points give alot of %, while later points give less.
While it is absurd to have 300% in SIMPLE_MODE(true), it is sane in this mode. In this mode such value would mean that you can cast the spell 3 additonal times in the time you could cast it normaly once.

When having 100s cd with 50 value in (Ratio 0.01) you can cast your spell 0.5 additonal times in that 100s. Result into 1,5 casts in 100s. 100s/1.5 = 66.6s
negative side increases for each point the cooldown by ratio. -20 = 120% cooldown -100 = 200% cooldown

If one would want to calc the % one could do it with that equation.
	value = ( 1 / COOLDOWN_ADJUST_RATIO ) / ( 1 /wanted Reduction - 1)

Example: ratio = 0.01, wanted % = 20

	value = 100 / (1/0.2 - 1)
	-> 100 / (5 - 1) = 100/4 = 25
25 cooldownAdjustmentValue would reduce cooldown by 20%.

Let's test the tripple, how much one needs for 60%?
	100 / (1/3/5 -1)
	100 / (5/3 - 1)
	100 / (2/3) = 300 / 2 = 150
60% Reduction would need 150 Value, beeing 6 times as much as the value needed for 20% reduction.

=======================
negative cooldownadjustment is always linear

with ratio 0.01
each -1 cooldownAdjustmentValue extends cooldown by 1%, so -100 would double the cooldown, -200 would tripple it.
this is only the case if the total cooldownAdjustmentValue goes below 0.
if an unit has + and - and they are from different groups they first add each other.
	-20 and 45 -> 25 (shorten by ~20%)

=======================


============
Globals
============
--]]
	CooldownAdjust = {}
	CooldownAdjust.Timer = CreateTimer() --used to reach the after spell effect event
	CooldownAdjust.TriggerSpellCast = CreateTrigger() --handle the executon on spelleffect-event
	CooldownAdjust.TriggerSpellCastEvents = {} --save the event so it won't be seen as garbage
	CooldownAdjust.TriggerItem = CreateTrigger()
	CooldownAdjust.TriggerItemEvents = {}
	
	CooldownAdjust.Reset = {} --data that is reseted when CooldownAdjust.Timer expires
	CooldownAdjust.AbilitySources = {} --What abilities give cooldownAdjustmentValues
	CooldownAdjust.ItemData = {} --What items give cooldownAdjustmentValues
	CooldownAdjust.DataExclude = {} --Which Spells do not trigger CooldownAdjust
	CooldownAdjust.UnitData = {} --custom base cooldownAdjustmentValues for units
	--setmetatable(CooldownAdjust.UnitData, {__mode = "k"}) --`CooldownAdjust.UnitData' has weak keys; auto clean on unit removage only works when the unit has no strong references anymore.
	CooldownAdjust.PlayerUnitData = {} --custom base cooldownAdjustmentValues for unitTypes owned by a player

--============
--Code
--============
	function NonSimpleRising(amount, ratio)
		if amount >= 0 then
			amount =  (amount * ratio) / (amount * ratio + 1 )
			return 1 - 1 * amount
		else
			amount = - amount
			return 1 + 1 * amount * ratio	--negative power is linear
		end
	end

	function CooldownAdjustCalcMulti(value)
		if value ~= 0 then --Is there a value?
			--Change this part if you want another Value interpretation
			if COOLDOWN_ADJUST_SIMPLE_MODE then
				value = 1.0 - value * COOLDOWN_ADJUST_RATIO --Simple Rising
			else	
				value = NonSimpleRising(value, COOLDOWN_ADJUST_RATIO) --Armor Like
			end
			return math.max(COOLDOWN_ADJUST_CAP_SHORTEN, math.min(value, COOLDOWN_ADJUST_CAP_EXTEND))
		else  --No Adjustment
			return 1.0
		end	
	end

	function CooldownAdjustCalcValue(unit, adjustType)
		local result = 0
		adjustType = adjustType or COOLDOWN_ADJUST_TYPE_ANY
		--unit specific bonus
		result = CooldownAdjustUnitGetValue(unit, COOLDOWN_ADJUST_TYPE_ANY) 
		if adjustType ~= COOLDOWN_ADJUST_TYPE_ANY then
			result = result +  CooldownAdjustUnitGetValue(unit, adjustType)
		end

		--player unitTypeId bonus
		local unitOwner = GetOwningPlayer(unit)
		local unitTypeId = GetUnitTypeId(unit)
		result = result + CooldownAdjustPlayerUnitsGetValue(unitOwner, unitTypeId, COOLDOWN_ADJUST_TYPE_ANY)  
		if adjustType ~= COOLDOWN_ADJUST_TYPE_ANY then
			result = result + CooldownAdjustPlayerUnitsGetValue(unitOwner, unitTypeId, adjustType)
		end
		
		
		--buff and ability bonus
		local buffGroups = {}
		for k,v in ipairs(CooldownAdjust.AbilitySources)
		do	
			local dataObject = v
			local ability = BlzGetUnitAbility(unit, dataObject.Ability)
			--have ability, this CooldownSource can affect the current spellcast?
			if ability and (dataObject.AdjustType == COOLDOWN_ADJUST_TYPE_ANY or dataObject.AdjustType == adjustType ) then
				local level = GetUnitAbilityLevel(unit, dataObject.Ability)
				local currentValue = dataObject.Value + dataObject.ValuePerLevel * level
				
				if dataObject.Group ~= 0 then --uses Stacking Groups?
					--best item and best ability/buff ? or this unit does not have any data -> don't care about items
					if COOLDOWN_ADJUST_SEPERATE_ITEM_GROUPS or not CooldownAdjust.UnitData[unit] then
						--not existing yet or better then the best
						if not buffGroups[dataObject.Group] or math.abs(buffGroups[dataObject.Group]) < math.abs(currentValue) then
							buffGroups[dataObject.Group] = currentValue
						end
					else
						--care about items
						--get the units itemtable for this situation
						
						local currentItemData = CooldownAdjust.UnitData[unit].Item[dataObject.AdjustType][dataObject.Group]

--						print(GetObjectName(dataObject.Ability), dataObject.AdjustType, dataObject.Group, currentItemData, buffGroups[dataObject.Group])

						--have none item of that type and group or this ablity/buff is better then the best 
						if not currentItemData or math.abs(currentItemData.Best) <  math.abs(currentValue) then
							if not buffGroups[dataObject.Group] or math.abs(buffGroups[dataObject.Group]) <  math.abs(currentValue) then
								-- this will totaly overwritte the best
								if currentItemData then
									buffGroups[dataObject.Group] =  -currentItemData.Best + currentValue
								else
									buffGroups[dataObject.Group] =  currentValue
								end
							end
						end
					end
				else -- free stacking
					result = result + currentValue
				end
			end
		end

		for k, v in pairs(buffGroups) do
			result = result + v
		end
		return result
	end
	
	function CooldownAdjustRegister(abilityCode, value, adjustType, valuePerLevel, stackingGroup)
		local newObject = {}
		newObject.Ability = abilityCode
		newObject.Value = value
		newObject.ValuePerLevel = valuePerLevel or 0
		newObject.AdjustType = adjustType or COOLDOWN_ADJUST_TYPE_ANY
		newObject.Group = stackingGroup or 0
		table.insert(CooldownAdjust.AbilitySources, newObject)
	end

	function CooldownAdjustUnitSetValue(unit, value, adjustType)
		if not CooldownAdjust.UnitData[unit] then
			CooldownAdjust.UnitData[unit] = {
			[COOLDOWN_ADJUST_TYPE_ANY] = 0,
			[COOLDOWN_ADJUST_TYPE_SPELL] = 0,
			[COOLDOWN_ADJUST_TYPE_ITEM] = 0,
			[COOLDOWN_ADJUST_TYPE_ULTIMATE] = 0,
			Item = {
				--this is used for stackingroups of items.
					[COOLDOWN_ADJUST_TYPE_ANY] = {},
					[COOLDOWN_ADJUST_TYPE_SPELL] = {},
					[COOLDOWN_ADJUST_TYPE_ITEM] = {},
					[COOLDOWN_ADJUST_TYPE_ULTIMATE] = {},
				}
			}
		end
		CooldownAdjust.UnitData[unit][adjustType or COOLDOWN_ADJUST_TYPE_ANY] = value
	end

	function CooldownAdjustUnitGetValue(unit, adjustType)
		if not CooldownAdjust.UnitData[unit] then return 0 end
		return CooldownAdjust.UnitData[unit][adjustType or COOLDOWN_ADJUST_TYPE_ANY]
	end

	function CooldownAdjustUnitClear(unit)
		CooldownAdjust.UnitData[unit] = nil
	end

	function CooldownAdjustUnitAddValue(unit, value, adjustType)
		adjustType = adjustType or COOLDOWN_ADJUST_TYPE_ANY
		CooldownAdjustUnitSetValue(unit, CooldownAdjustUnitGetValue(unit, adjustType) + value, adjustType)
	end

	function CooldownAdjustPlayerUnitsSetValue(whichPlayer, unitCode, value, adjustType)
		--if not CooldownAdjust.PlayerUnitData[whichPlayer][unitCode] then CooldownAdjust.PlayerUnitData[whichPlayer][unitCode] = {[COOLDOWN_ADJUST_TYPE_ANY] = 0, [COOLDOWN_ADJUST_TYPE_SPELL] = 0, [COOLDOWN_ADJUST_TYPE_ITEM] = 0, [COOLDOWN_ADJUST_TYPE_ULTIMATE] = 0} end
		if not CooldownAdjust.PlayerUnitData[whichPlayer][unitCode] then CooldownAdjust.PlayerUnitData[whichPlayer][unitCode] = __jarray(0) end
		CooldownAdjust.PlayerUnitData[whichPlayer][unitCode][adjustType or COOLDOWN_ADJUST_TYPE_ANY] = value
	end

	function CooldownAdjustPlayerUnitsGetValue(whichPlayer, unitCode, adjustType)
		if not CooldownAdjust.PlayerUnitData[whichPlayer][unitCode] then return 0 end
		return CooldownAdjust.PlayerUnitData[whichPlayer][unitCode][adjustType or COOLDOWN_ADJUST_TYPE_ANY]
	end
	function CooldownAdjustPlayerUnitsAddValue(whichPlayer, unitCode, value, adjustType)
		adjustType = adjustType or COOLDOWN_ADJUST_TYPE_ANY
		CooldownAdjustPlayerUnitsSetValue(whichPlayer, unitCode, CooldownAdjustPlayerUnitsGetValue(whichPlayer, unitCode, adjustType) + value, adjustType)
	end

	function CooldownAdjustPlayerUnitsClear(whichPlayer, unitCode)
		--when unitCode is set remove a specific field
		if unitCode then
			CooldownAdjust.PlayerUnitData[whichPlayer][unitCode] = nil
		else
			--remove all saved fields for that player
			for k, v in pairs(CooldownAdjust.PlayerUnitData[whichPlayer])
			do
				CooldownAdjust.PlayerUnitData[whichPlayer][k] = nil
			end
		end
	end

	function CooldownAdjustRegisterItem(itemCode, value, adjustType, stackingGroup)
		if not CooldownAdjust.ItemData[itemCode] then CooldownAdjust.ItemData[itemCode] = {} end
		local newObject = {}
		newObject.Value = value
		newObject.AdjustType = adjustType or COOLDOWN_ADJUST_TYPE_ANY
		newObject.StackingGroup = stackingGroup or 0
		table.insert(CooldownAdjust.ItemData[itemCode], newObject)
	end

	function CooldownAdjustExclude(abilityCode)
		CooldownAdjust.DataExclude[abilityCode] = true
	end
	

	TriggerAddAction(CooldownAdjust.TriggerSpellCast, function()
		xpcall(function()
		local spell = GetSpellAbilityId()
		if CooldownAdjust.DataExclude[spell] then return end --exclude this spells?
		
		local unit = GetTriggerUnit()	
		local spellOrder = GetUnitCurrentOrder(unit)
		local level = GetUnitAbilityLevel(unit, spell) - 1
		local spellReqLevel = BlzGetAbilityIntegerField(GetSpellAbility(), ABILITY_IF_REQUIRED_LEVEL)
		local itemSpell = ( spellOrder >= 852008 and spellOrder <= 852013)
		--local isUltimativeSpell = (spellReqLevel ~= 0 and spellReqLevel ~= 1) or (BlzBitAnd(BlzGetAbilityIntegerLevelField(GetSpellAbility(), ABILITY_ILF_OPTIONS, level), 8) == 8)
		local isUltimativeSpell = (spellReqLevel ~= 0 and spellReqLevel ~= 1)
		--local itemSpell = BlzGetAbilityBooleanField(GetSpellAbility(), ABILITY_BF_ITEM_ABILITY)
		--local isHeroSpell = BlzGetAbilityBooleanField(GetSpellAbility(), ABILITY_BF_HERO_ABILITY)

		--print (GetUnitName(unit), GetObjectName(spell), itemSpell, isUltimativeSpell)

		local usedItem
		if itemSpell then
			usedItem = UnitItemInSlot(unit, spellOrder - 852008)
		else
			usedItem = nil
		end
		if BlzGetAbilityCooldown(spell,level) > COOLDOWN_ADJUST_THRESHOLD and CustomFilter(unit, spell, usedItem, isUltimativeSpell) then	--Does this ability pass the cooldown Threshold, and the customizeable Filter?
			local cooldownAdjustmentValue
			if usedItem ~= nil then
				cooldownAdjustmentValue = CooldownAdjustCalcValue(unit, COOLDOWN_ADJUST_TYPE_ITEM)
			elseif isUltimativeSpell then
				cooldownAdjustmentValue = CooldownAdjustCalcValue(unit, COOLDOWN_ADJUST_TYPE_ULTIMATE)
			else
				cooldownAdjustmentValue = CooldownAdjustCalcValue(unit, COOLDOWN_ADJUST_TYPE_SPELL)
			end

			if cooldownAdjustmentValue ~= 0 then
				local cd = BlzGetUnitAbilityCooldown(unit, spell, level)
				local reseter = {}
				reseter.Unit = unit
				reseter.Spell = spell
				reseter.Level = level
				reseter.Time = cd * CooldownAdjustCalcMulti(cooldownAdjustmentValue) - cd
				table.insert(CooldownAdjust.Reset, reseter)			
				
				BlzSetUnitAbilityCooldown(unit, spell, level , cd + reseter.Time)
				TimerStart(CooldownAdjust.Timer, 0.00, false, function()
					local cd
					local reseter

					for k,v in ipairs(CooldownAdjust.Reset)
					do
						--Revert the cooldown change done for all casters in the list
						reseter = v
						cd = BlzGetUnitAbilityCooldown(reseter.Unit, reseter.Spell, reseter.Level)
						BlzSetUnitAbilityCooldown(reseter.Unit, reseter.Spell, reseter.Level, cd - reseter.Time)
						CooldownAdjust.Reset[k] = nil
					end
				end)
			end
			print (BlzGetAbilityCooldown(spell,level).." -> ".. string.format( "%%.3f",BlzGetUnitAbilityCooldown(unit, spell, level)))
		end
	end, print)
	end)

	TriggerAddAction(CooldownAdjust.TriggerItem, function()
		xpcall(function()
		local itemCode = GetItemTypeId(GetManipulatedItem())
		if CooldownAdjust.ItemData[itemCode] then
			local unit = GetTriggerUnit()
			local add = 1
			if GetHandleId(GetTriggerEventId()) == GetHandleId(EVENT_PLAYER_UNIT_DROP_ITEM) then
				--tomes bonuses are not lost when droping, Life == 0 is item dead/removed
				if IsItemIdPowerup(itemCode) and GetWidgetLife(GetManipulatedItem()) == 0 then return end
				add = -1
			end

			for key, value in ipairs(CooldownAdjust.ItemData[itemCode])
			do
				--Free Stacking?
				if value.StackingGroup == 0 then
					--yes, modify custom Unit Value
					CooldownAdjustUnitAddValue(unit, add * value.Value, value.AdjustType)
				else
					--create UnitData when needed
					if not CooldownAdjust.UnitData[unit] then
						CooldownAdjust.UnitData[unit] = {
						[COOLDOWN_ADJUST_TYPE_ANY] = 0,
						[COOLDOWN_ADJUST_TYPE_SPELL] = 0,
						[COOLDOWN_ADJUST_TYPE_ITEM] = 0,
						[COOLDOWN_ADJUST_TYPE_ULTIMATE] = 0,
						Item = {
							--this is used for stackingroups of items.
								[COOLDOWN_ADJUST_TYPE_ANY] = {},
								[COOLDOWN_ADJUST_TYPE_SPELL] = {},
								[COOLDOWN_ADJUST_TYPE_ITEM] = {},
								[COOLDOWN_ADJUST_TYPE_ULTIMATE] = {},
							}
						}
					end

					local currentContainer = CooldownAdjust.UnitData[unit].Item[value.AdjustType][value.StackingGroup]
					if not currentContainer then
						--create not exiting table
						currentContainer = {}
						CooldownAdjust.UnitData[unit].Item[value.AdjustType][value.StackingGroup] = currentContainer
					end
					--Add?
					if add > 0 then
						--add
						table.insert(currentContainer, value.Value)
						--have only one after adding?
						if #currentContainer == 1 then
							--yes, this is the best!
							CooldownAdjustUnitAddValue(unit, value.Value, value.AdjustType)
							currentContainer.Best = value.Value
						--new one Better then Best?
						elseif math.abs(value.Value) > math.abs(currentContainer.Best) then
							--reduce unitData by Best add new one and replace Best Value
							CooldownAdjustUnitAddValue(unit, - currentContainer.Best, value.AdjustType)
							CooldownAdjustUnitAddValue(unit, value.Value, value.AdjustType)
							currentContainer.Best = value.Value
						end
					else
						--remove
						--only one of that type?
						if #currentContainer == 1 then
							CooldownAdjustUnitAddValue(unit, - currentContainer.Best, value.AdjustType)
							table.remove(currentContainer)
							currentContainer.Best = 0
						else
							--could the best be removed?
							if value.Value == currentContainer.Best then
								--yes, makes it complex

								--unit loses the Bonus of Best
								CooldownAdjustUnitAddValue(unit, - currentContainer.Best, value.AdjustType)
								--remove best
								local newBest = 0
								local index2Remove = nil
								for itemModifierKey, itemModifier in ipairs(currentContainer)
								do
									--none toRemove found yet and this is the value one wants to remove
									if not index2Remove and itemModifier == value.Value  then
										--remember this index to be removed, removing inside the loop malfunction it.
										index2Remove = itemModifierKey										
									else
										if math.abs(itemModifier) > math.abs(newBest) then
											newBest = itemModifier
										end
									end
								end
								table.remove(currentContainer, index2Remove)
								CooldownAdjustUnitAddValue(unit, newBest, value.AdjustType)
								currentContainer.Best = newBest
							else
								--no, some bonus having no effect currently.
								--Find the first with that value and remove it, then its done.
								for itemModifierKey, itemModifier in ipairs(currentContainer)
								do
									if itemModifier == value.Value then
										table.remove(currentContainer, itemModifierKey)
										break
									end
								end
							end
						end
					end
				end
			end
		end
	end, print)
	end)

	for playerIndex = 0, bj_MAX_PLAYER_SLOTS - 1, 1 do
		--prepare player tables
		CooldownAdjust.PlayerUnitData[Player(playerIndex)] = {}
		--store the events, events created in the root having no reference are seen as garbage and will be removed as soon the garbage collector runs.
		table.insert(CooldownAdjust.TriggerSpellCastEvents, TriggerRegisterPlayerUnitEvent(CooldownAdjust.TriggerSpellCast, Player(playerIndex), EVENT_PLAYER_UNIT_SPELL_EFFECT, nil))
		table.insert(CooldownAdjust.TriggerItemEvents, TriggerRegisterPlayerUnitEvent(CooldownAdjust.TriggerItem, Player(playerIndex), EVENT_PLAYER_UNIT_PICKUP_ITEM, nil))
		table.insert(CooldownAdjust.TriggerItemEvents, TriggerRegisterPlayerUnitEvent(CooldownAdjust.TriggerItem, Player(playerIndex), EVENT_PLAYER_UNIT_DROP_ITEM, nil))
	end	
	
end