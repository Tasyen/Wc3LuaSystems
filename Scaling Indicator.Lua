--[[
Scaling Indicator 1.0
by Tasyen

function ScalingIndicator.create(filePath, x, y, initialSize, endSize, time)
    creates an alpha low image with endSize at x/y over time a second image scales to the endSize over time seconds starting with initialSize.
    returns the table handling containg the data
    
function ScalingIndicator.setColor(object, red, green, blue, alpha)
    use this onto a table returned with ScalingIndicator.create to change the color.
--]]

ScalingIndicator = {}
ScalingIndicator.KeepExpired = 1.0 -- seconds full scaled indicators are kept
-- Suggested Images
ScalingIndicator.HUMAN = "ReplaceableTextures\\Selection\\SpellAreaOfEffect.blp"
ScalingIndicator.ORC = "ReplaceableTextures\\Selection\\SpellAreaOfEffect_Orc.blp"
ScalingIndicator.ELF = "ReplaceableTextures\\Selection\\SpellAreaOfEffect_NE.blp"
ScalingIndicator.UNDEAD = "ReplaceableTextures\\Selection\\SpellAreaOfEffect_Undead.blp"
ScalingIndicator.AURA9 = "ReplaceableTextures\\Splats\\AuraRune9b.blp"
ScalingIndicator.TELEPORT = "ReplaceableTextures\\Splats\\TeleportTarget.blp"
ScalingIndicator.CIRCLE = "ReplaceableTextures\\Selection\\SelectionCircleLarge.blp"
ScalingIndicator.CIRCLE2 = "ReplaceableTextures\\Selection\\SelectionCircleLargeDotted.blp"

function ScalingIndicator.KeepComplete()
    local timer = GetExpiredTimer()
    SetImageRenderAlways(ScalingIndicator[timer].ImageCurrent, false)
    DestroyImage(ScalingIndicator[timer].ImageCurrent)
    ScalingIndicator[timer] = nil
    DestroyTimer(timer)
end

function ScalingIndicator.UpdateAction()
    -- iterate from max to min this is more efficent when having alot of indicators expiring at the same time, without using an advanced indexing technique
    for index = #ScalingIndicator, 1, -1 do
        local object = ScalingIndicator[index]
        
        object.Steps = object.Steps - 1
        -- still running?
        if object.Steps > 0 then
            object.SizeCurrent = object.SizeCurrent + object.SizeAdd
            SetImageRenderAlways(object.ImageCurrent, false)
            DestroyImage(object.ImageCurrent)
            -- recreate the scaling image with the new size
            object.ImageCurrent = CreateImage(object.FilePath, object.SizeCurrent, object.SizeCurrent, 0, object.X, object.Y, 0, object.SizeCurrent/2, object.SizeCurrent/2, 0, 2)
            SetImageRenderAlways(object.ImageCurrent, true)
            SetImageColor(object.ImageCurrent, object.Red, object.Green, object.Blue, object.Alpha)
        else
            -- expired!
            SetImageRenderAlways(object.ImageMax, false)
            DestroyImage(object.ImageMax)
            table.remove(ScalingIndicator, index)
            -- stop timer when done
            if #ScalingIndicator == 0 then PauseTimer(ScalingIndicator.Timer) end

            -- keep the Image for ScalingIndicator.KeepExpired seconds alive
            local timer = CreateTimer()
            ScalingIndicator[timer] = object
            TimerStart(timer, ScalingIndicator.KeepExpired, false, ScalingIndicator.KeepComplete)

            
        end
    end
end

function ScalingIndicator.create(filePath, x, y, initialSize, endSize, time)
    local newObject = {
        FilePath = filePath,
        X = x,
        Y = y,
        Steps = time * 20, -- / 0.05
        SizeMax = endSize,
        SizeCurrent = initialSize,
        Red = 255,
        Green = 255,
        Blue = 255,
        Alpha = 255
    }
    newObject.SizeAdd = (endSize - initialSize) / newObject.Steps
    newObject.ImageMax = CreateImage(filePath, endSize, endSize, 0, x, y, 0, endSize/2, endSize/2, 0, 2)
    SetImageRenderAlways(newObject.ImageMax, true)
    SetImageColor(newObject.ImageMax, newObject.Red, newObject.Green, newObject.Blue, 100)
    newObject.ImageCurrent = CreateImage(filePath, newObject.SizeCurrent, newObject.SizeCurrent, 0, x, y, 0, newObject.SizeCurrent/2, newObject.SizeCurrent/2, 0, 2)
    if not ScalingIndicator.Timer then ScalingIndicator.Timer = CreateTimer() end
    if #ScalingIndicator == 0 then TimerStart(ScalingIndicator.Timer, 0.05, true, ScalingIndicator.UpdateAction) end
    table.insert(ScalingIndicator, newObject)
    return newObject
end

function ScalingIndicator.setColor(object, red, green, blue, alpha)
    object.Red = red
    object.Green = green
    object.Blue = blue
    object.Alpha = alpha
    SetImageColor(object.ImageCurrent, object.Red, object.Green, object.Blue, object.Alpha)
    SetImageColor(object.ImageMax, object.Red, object.Green, object.Blue, 100 * object.Alpha/255)
end