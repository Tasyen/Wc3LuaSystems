--===========================================================================
-- Counts key structures owned by a player and his or her allies, including
-- structures currently upgrading or under construction.
--
-- Key structures: Town Hall, Great Hall, Tree of Life, Necropolis
--
do
    local isTownHallFilter = Filter(function()
        return IsUnitType(GetFilterUnit(), UNIT_TYPE_TOWNHALL) and not IsUnitType(GetFilterUnit(), UNIT_TYPE_DEAD)
    end)
    local group = CreateGroup()
    function MeleeGetAllyKeyStructureCount(whichPlayer)
        xpcall(function()
        local playerIndex  = 0
        local indexPlayer
        local keyStructs  = 0   
        -- Count the number of buildings controlled by all not-yet-defeated co-allies.

        repeat
            indexPlayer = Player(playerIndex)
            
            if (PlayersAreCoAllied(whichPlayer, indexPlayer)) then
                GroupEnumUnitsOfPlayer(group, indexPlayer, isTownHallFilter)
                keyStructs = keyStructs + CountUnitsInGroup(group)
                GroupClear(group)
            end
                
            playerIndex = playerIndex + 1
        until playerIndex == bj_MAX_PLAYERS

        return keyStructs
    
    end, function(x) print(x) return x end)
end
end