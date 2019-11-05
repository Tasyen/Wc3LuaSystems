do
    --Based on FIleIO from TriggerHappy, converted by Tasyen
    -- The string limit per Preload call.
    local preloadLimit = 200

    -- The list of abilities used to read and write data. 
    -- You can add more abilities to increase the max content length for files.
    local abilityList = {FourCC("Amls"), FourCC("Aroc"), FourCC("Amic"), FourCC("Amil"), FourCC("Aclf")}

    -- The maximum number of characters that can be written to a file.
    local maxLength = preloadLimit * #abilityList

    --[[
      Write text to a file that can be read later.
      @param filename Filename of the file.
      @param contents Contents to write to the file.
     --]]

    function writeFile(filename, contents)
            
        PreloadGenClear()
        PreloadGenStart()
        local indexA = 1
        local lengthContent = string.len(contents)
        for index, abilityId in ipairs(abilityList) do
            local indexB = indexA + preloadLimit
            local buffer = string.sub(contents, indexA, indexB)
            Preload("\" )\ncall BlzSetAbilityTooltip("..abilityId..", \""..buffer.."\", 0)\n//")
            indexA = indexA + preloadLimit
            if indexA > lengthContent then break end
        end
        Preload("\" )\nendfunction\nfunction a takes nothing returns nothing\n //")
        PreloadGenEnd(filename)
    end



    --[[
    Read text from a generated file.
    @param filename Filename of the file.
    --]]

    function readFile(filename)
        local output = ""
        local originalTooltip = {}

        for index, abilityId in ipairs(abilityList) do
            originalTooltip[index] = BlzGetAbilityTooltip(abilityId, 0)
        end

        Preloader(filename)
        for index, abilityId in ipairs(abilityList) do
            local buffer = BlzGetAbilityTooltip(abilityId, 0)
            if buffer == originalTooltip[index] then
                break
            else 
                output = output .. buffer
            end
            BlzSetAbilityTooltip(abilityId, originalTooltip[index], 0)
        end
        return output
    end
end
