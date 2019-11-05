--https://stackoverflow.com/questions/1426954/split-string-in-lua
function string.mysplit (inputstr, sep)
    if sep == nil then
       return {}
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end


function framePoint2Index(point)
    for index = 1, 8 do
        if ConvertFramePointType(index) == point then
            return index
        end
    end
    return -1
end

-- shortens the amount of text to be saved
-- 0.123 -> 123, -0.1 = -100
function TrimNumberFraction2String(value)
    if value == 0 then
        return "0"
    elseif value > 0 then
        return string.sub( value, 3, 5)
    else
        return "-"..string.sub( value, 4, 6)
    end
    return 0
end

-- reverts TrimNumberFraction2String
-- 123 -> 0.123, -100 -> -0.1
function StringFraction2Number(value)
    if value == "0" then
        return 0
    else
        local valueNumber = tonumber(value)
        --this is actually a valid number like 0.2 or -0.03?
        if valueNumber < 1 and valueNumber > -1 then
            return valueNumber
    
        elseif valueNumber > 0 then
            return tonumber("0."..value)
        else
            return tonumber("-0."..string.sub(value,2))
        end
    end
    return 0
end
