VolumeGroupControl = {}

function VolumeGroupControl.Action(sliderObject)
    VolumeGroupSetVolumeForPlayerBJ(GetTriggerPlayer(), VolumeGroupControl[sliderObject], BlzFrameGetValue(BlzGetTriggerFrame())*0.01 )
    print(BlzFrameGetValue(BlzGetTriggerFrame()), BlzFrameGetText(sliderObject.Label))
end

TimerStart(CreateTimer(),0,false, function()
    xpcall(function()
    print("VolumGroupControl")
    local data = {
        "UnitMovement",
        "UnitSound",
        "Combat",
        "Spells",
        "User Interface",
        "Music",
        "Ambient",
        "Fire",
    }
    local frameListObject = FrameList.create()
    local parentFrame = frameListObject.Frame
    BlzFrameSetAbsPoint(frameListObject.Frame, FRAMEPOINT_CENTER, 0.4, 0.3)
    FrameList.setSize(frameListObject, 0.012, 0.12)
    
    for index = 0, 7 do
        local sliderObject = SliderControl.new(VolumeGroupControl.Action, 0, 100, 100, 1, data[index+1], 0.09, 0.05, "", parentFrame)
        VolumeGroupControl[sliderObject] = ConvertVolumeGroup(index)
        FrameList.add(frameListObject, sliderObject.Frame)
        table.insert( VolumeGroupControl, sliderObject )
    end
    print("Done")
end,err)
end)