--asycn result, might bring wrong results when there are empty built menus or spellbooks
function isInTargetingMode()
    local index = 0
    repeat
        if BlzFrameIsVisible(BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, index)) then break end
        index = index + 1
    until index == 12 --when 12 is reached no button is visible

    return index == 11 --when the loop broke in index == 11 its targeting mode
end
