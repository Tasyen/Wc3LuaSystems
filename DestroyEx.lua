
function typeOfObject(value)
    --returns the type of userData or type(value) "unit" or "timer"...
    local typeString = tostring(value)
    local index = string.find( typeString, ":")
    return string.sub(typeString, 1, index - 1)
end

do
    local data = {}
    data.timer = DestroyTimer
    data.timerdialog = DestroyTimerDialog
    data.location = RemoveLocation
    data.region = RemoveRegion
    data.rect = RemoveRect
    data.sound = KillSoundWhenDone
    data.unitpool = DestroyUnitPool
    data.itempool = DestroyItemPool
    data.dialog = DialogDestroy
    data.quest = DestroyQuest
    -- data.questitem = DestroyUnitPool
    data.defeatcondition = DestroyDefeatCondition
    data.leaderboard = DestroyLeaderboard
    data.multiboard = DestroyMultiboard
    data.gamecache = FlushGameCache
    data.texttag = DestroyTextTag
    data.lightning = DestroyLightning
    data.image = DestroyImage
    data.ubersplat = DestroyUbersplat
    data.hashtable = FlushParentHashtable
    data.framehandle = BlzDestroyFrame
    data.effect = DestroyEffect
    data.trigger = DestroyTrigger
    data.force = DestroyForce
    data.group = DestroyGroup
    data.item = RemoveItem
    data.destructable = RemoveDestructable
    data.unit = RemoveUnit
    data.fogmodifier = DestroyFogModifier
    
    function DestroyEx(object)
        if type(object) == "userdata" then
            local typeAsString = typeOfObject(object)
            if data[typeAsString] then data[typeAsString](object) end
        end
    end
end