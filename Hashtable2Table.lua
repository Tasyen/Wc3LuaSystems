do --"Converts" Hashtables into Lua Tables
  HashtableAsTable = {}
  
  function InitHashtable()
    return {}
  end
  
  HashtableAsTable.CreateNeededTables = function(table, parentKey, childKey)
    if not table[parentKey] then table[parentKey] = {} end
    if not table[parentKey][childKey] then table[parentKey][childKey] = {} end
  end

  HashtableAsTable.DoNeededTablesExist = function(table, parentKey, childKey)
    if not table then return false end
    if not table[parentKey] then return false end
    if childKey and not table[parentKey][childKey] then return false end
    return true
  end
  
  function SaveInteger(table, parentKey, childKey, value)
    HashtableAsTable.CreateNeededTables(table, parentKey, childKey)
    table[parentKey][childKey].Integer = value
    return true
  end

  function SaveReal(table, parentKey, childKey, value)
    HashtableAsTable.CreateNeededTables(table, parentKey, childKey)
    table[parentKey][childKey].Real = value
    return true
  end

  function SaveBoolean(table, parentKey, childKey, value)
    HashtableAsTable.CreateNeededTables(table, parentKey, childKey)
    table[parentKey][childKey].Boolean = value
    return true
  end

  function SaveStr(table, parentKey, childKey, value)
    HashtableAsTable.CreateNeededTables(table, parentKey, childKey)
    table[parentKey][childKey].String = value
    return true
  end

  function HashtableAsTable.SaveHandle(table, parentKey, childKey, handle)
    HashtableAsTable.CreateNeededTables(table, parentKey, childKey)
    table[parentKey][childKey].Handle = handle
    return true
  end
  --change the executive code of Save Handle functions
  SavePlayerHandle = HashtableAsTable.SaveHandle
  SaveWidgetHandle = HashtableAsTable.SaveHandle
  SaveDestructableHandle = HashtableAsTable.SaveHandle
  SaveItemHandle = HashtableAsTable.SaveHandle
  SaveUnitHandle = HashtableAsTable.SaveHandle
  SaveAbilityHandle = HashtableAsTable.SaveHandle
  SaveTimerHandle = HashtableAsTable.SaveHandle
  SaveTriggerHandle = HashtableAsTable.SaveHandle
  SaveTriggerConditionHandle = HashtableAsTable.SaveHandle
  SaveTriggerActionHandle = HashtableAsTable.SaveHandle
  SaveTriggerEventHandle = HashtableAsTable.SaveHandle
  SaveForceHandle = HashtableAsTable.SaveHandle
  SaveGroupHandle = HashtableAsTable.SaveHandle
  SaveLocationHandle = HashtableAsTable.SaveHandle
  SaveRectHandle = HashtableAsTable.SaveHandle
  SaveBooleanExprHandle = HashtableAsTable.SaveHandle
  SaveSoundHandle = HashtableAsTable.SaveHandle
  SaveEffectHandle = HashtableAsTable.SaveHandle
  SaveUnitPoolHandle = HashtableAsTable.SaveHandle
  SaveItemPoolHandle = HashtableAsTable.SaveHandle
  SaveQuestHandle = HashtableAsTable.SaveHandle
  SaveQuestItemHandle = HashtableAsTable.SaveHandle
  SaveDefeatConditionHandle = HashtableAsTable.SaveHandle
  SaveTimerDialogHandle = HashtableAsTable.SaveHandle
  SaveLeaderboardHandle = HashtableAsTable.SaveHandle
  SaveMultiboardHandle = HashtableAsTable.SaveHandle
  SaveMultiboardItemHandle = HashtableAsTable.SaveHandle
  SaveTrackableHandle = HashtableAsTable.SaveHandle
  SaveDialogHandle = HashtableAsTable.SaveHandle
  SaveButtonHandle = HashtableAsTable.SaveHandle
  SaveTextTagHandle = HashtableAsTable.SaveHandle
  SaveLightningHandle = HashtableAsTable.SaveHandle
  SaveImageHandle = HashtableAsTable.SaveHandle
  SaveUbersplatHandle = HashtableAsTable.SaveHandle
  SaveRegionHandle = HashtableAsTable.SaveHandle
  SaveFogStateHandle = HashtableAsTable.SaveHandle
  SaveFogModifierHandle = HashtableAsTable.SaveHandle
  SaveAgentHandle = HashtableAsTable.SaveHandle
  SaveHashtableHandle = HashtableAsTable.SaveHandle
  SaveFrameHandle = HashtableAsTable.SaveHandle

  function HashtableHaveSavedData(table, parentKey, childKey, name)
    return HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) and table[parentKey][childKey][name]
  end
  function HaveSavedInteger(table, parentKey, childKey)
    return HashtableHaveSavedData(table, parentKey, childKey, "Integer")
  end
  function HaveSavedReal(table, parentKey, childKey)
    return HashtableHaveSavedData(table, parentKey, childKey, "Real")
  end
  function HaveSavedBoolean(table, parentKey, childKey)
    return HashtableHaveSavedData(table, parentKey, childKey, "Boolean")
  end
  function HaveSavedString(table, parentKey, childKey)
    return HashtableHaveSavedData(table, parentKey, childKey, "String")
  end
  function HaveSavedHandle(table, parentKey, childKey)
    return HashtableHaveSavedData(table, parentKey, childKey, "Handle")
  end


  function LoadInteger(table, parentKey, childKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) and table[parentKey][childKey].Integer ~= nil then
      return table[parentKey][childKey].Integer
    else
      return 0
    end
  end

  function LoadReal(table, parentKey, childKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) and table[parentKey][childKey].Real ~= nil then
      return table[parentKey][childKey].Real
    else
      return 0.0
    end
  end

  function LoadBoolean(table, parentKey, childKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) and table[parentKey][childKey].Boolean ~= nil then
      return table[parentKey][childKey].Boolean
    else
      return false
    end
  end

  function LoadStr(table, parentKey, childKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) and table[parentKey][childKey].String ~= nil then
      return table[parentKey][childKey].String
    else
      return ""
    end
  end

  function HashtableLoadHandle(table, parentKey, childKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) and table[parentKey][childKey].Handle ~= nil then
      return table[parentKey][childKey].Handle
    else
      return nil
    end
  end
  --change the executive code of Load Handle functions
  LoadPlayerHandle = HashtableLoadHandle
  LoadWidgetHandle = HashtableLoadHandle
  LoadDestructableHandle = HashtableLoadHandle
  LoadItemHandle = HashtableLoadHandle
  LoadUnitHandle = HashtableLoadHandle
  LoadAbilityHandle = HashtableLoadHandle
  LoadTimerHandle = HashtableLoadHandle
  LoadTriggerHandle = HashtableLoadHandle
  LoadTriggerConditionHandle = HashtableLoadHandle
  LoadTriggerActionHandle = HashtableLoadHandle
  LoadTriggerEventHandle = HashtableLoadHandle
  LoadForceHandle = HashtableLoadHandle
  LoadGroupHandle = HashtableLoadHandle
  LoadLocationHandle = HashtableLoadHandle
  LoadRectHandle = HashtableLoadHandle
  LoadBooleanExprHandle = HashtableLoadHandle
  LoadSoundHandle = HashtableLoadHandle
  LoadEffectHandle = HashtableLoadHandle
  LoadUnitPoolHandle = HashtableLoadHandle
  LoadItemPoolHandle = HashtableLoadHandle
  LoadQuestHandle = HashtableLoadHandle
  LoadQuestItemHandle = HashtableLoadHandle
  LoadDefeatConditionHandle = HashtableLoadHandle
  LoadTimerDialogHandle = HashtableLoadHandle
  LoadLeaderboardHandle = HashtableLoadHandle
  LoadMultiboardHandle = HashtableLoadHandle
  LoadMultiboardItemHandle = HashtableLoadHandle
  LoadTrackableHandle = HashtableLoadHandle
  LoadDialogHandle = HashtableLoadHandle
  LoadButtonHandle = HashtableLoadHandle
  LoadTextTagHandle = HashtableLoadHandle
  LoadLightningHandle = HashtableLoadHandle
  LoadImageHandle = HashtableLoadHandle
  LoadUbersplatHandle = HashtableLoadHandle
  LoadRegionHandle = HashtableLoadHandle
  LoadFogStateHandle = HashtableLoadHandle
  LoadFogModifierHandle = HashtableLoadHandle
  LoadAgentHandle = HashtableLoadHandle
  LoadHashtableHandle = HashtableLoadHandle
  LoadFrameHandle = HashtableLoadHandle


  function RemoveSavedInteger(table, parentKey, childKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) then
      table[parentKey][childKey].Integer = nil
    end   
  end

  function RemoveSavedReal(table, parentKey, childKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) then
      table[parentKey][childKey].Real = nil
    end
  end

  function RemoveSavedBoolean(table, parentKey, childKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) then
      table[parentKey][childKey].Boolean = nil
    end
  end

  function RemoveSavedString(table, parentKey, childKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) then
      table[parentKey][childKey].String = nil
    end
  end

  function RemoveSavedHandle(table, parentKey, childKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey, childKey) then
      table[parentKey][childKey].Handle = nil
    end
  end
    
  function FlushParentHashtable(table)
    for key in pairs(table)
    do
      table[key] = nil
    end
  end

  function FlushChildHashtable(table, parentKey)
    if HashtableAsTable.DoNeededTablesExist(table, parentKey) then
      table[parentKey] = nil
    end
  end
end
