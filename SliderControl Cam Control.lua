CamControl = {}

function CamControl.Action(sliderObject)
    SetCameraFieldForPlayer(GetTriggerPlayer(), CamControl[sliderObject], BlzFrameGetValue(BlzGetTriggerFrame()), 0)
    print(BlzFrameGetValue(BlzGetTriggerFrame()), BlzFrameGetText(sliderObject.Label))
end

TimerStart(CreateTimer(),0,false, function()
    xpcall(function()
    print("CamControl")
    local data = {
        -- min max default step, LabelText
        {100, 5000, GetCameraField(CAMERA_FIELD_TARGET_DISTANCE), 50, "TARGET_DISTANCE"},
        {100, 5000,  GetCameraField(CAMERA_FIELD_FARZ), 1, "FARZ"},
        {0, 360,  bj_RADTODEG * GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK), 1, "ANGLE_OF_ATTACK"},
        {20, 120, bj_RADTODEG * GetCameraField(CAMERA_FIELD_FIELD_OF_VIEW), 1, "FIELD_OF_VIEW"},
        {0, 360, bj_RADTODEG * GetCameraField(CAMERA_FIELD_ROLL), 1, "ROLL"},
        {0, 360, bj_RADTODEG * GetCameraField(CAMERA_FIELD_ROTATION), 1, "ROTATION"},
        {0, 5000, GetCameraField(CAMERA_FIELD_ZOFFSET), 1, "ZOFFSET"},
        {0, 5000, GetCameraField(CAMERA_FIELD_NEARZ), 1, "NEARZ"},
        {0, 360,  bj_RADTODEG * GetCameraField(CAMERA_FIELD_LOCAL_PITCH), 1, "LOCAL_PITCH"},
        {0, 360,  bj_RADTODEG * GetCameraField(CAMERA_FIELD_LOCAL_YAW), 1, "LOCAL_YAW"},
        {0, 360, bj_RADTODEG * GetCameraField(CAMERA_FIELD_LOCAL_ROLL), 1, "LOCAL_ROLL"}
    }
    local frameListObject = FrameList.create()
    local parentFrame = frameListObject.Frame
    BlzFrameSetAbsPoint(frameListObject.Frame, FRAMEPOINT_CENTER, 0.4, 0.3)
    FrameList.setSize(frameListObject, 0.012,0.12)
    
    for index = 1, 11 do
        local sliderObject = SliderControl.new(CamControl.Action, data[index][1], data[index][2], data[index][3], data[index][4], data[index][5], 0.15, 0.09, "", parentFrame)
        CamControl[sliderObject] = ConvertCameraField(index - 1)
        FrameList.add(frameListObject, sliderObject.Frame)
        table.insert(CamControl, sliderObject)
    end

    print("Done")
end,err)
end)