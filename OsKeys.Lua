--function HotKey.convert(key)
    --converts oskey <-> string
    
--Requires Global Initialization by Bribe. 
--Maps OSKEY to a string representing it
onTriggerInit(function()
    HotKey = {}
    local releaseTrigger = CreateTrigger()
    TriggerAddAction(releaseTrigger, function()
        --print(HotKey[BlzGetTriggerPlayerKey()])
        CustomUI.HotKeyAction(true)
    end)

    local clickTrigger = CreateTrigger()
    TriggerAddAction(clickTrigger, function()
        --print(HotKey[BlzGetTriggerPlayerKey()])
        CustomUI.HotKeyAction(false)
    end)
    function HotKey.convert(key)
        return HotKey[key]
    end
    
    HotKey[OSKEY_0] = "0"
    HotKey[OSKEY_1] = "1"
    HotKey[OSKEY_2] = "2"
    HotKey[OSKEY_3] = "3"
    HotKey[OSKEY_4] = "4"
    HotKey[OSKEY_5] = "5"
    HotKey[OSKEY_6] = "6"
    HotKey[OSKEY_7] = "7"
    HotKey[OSKEY_8] = "8"
    HotKey[OSKEY_9] = "9"
    HotKey[OSKEY_A] = "A"
    HotKey[OSKEY_B] = "B"
    HotKey[OSKEY_C] = "C"
    HotKey[OSKEY_D] = "D" 
    HotKey[OSKEY_E] = "E"
    HotKey[OSKEY_F] = "F"
    HotKey[OSKEY_G] = "G"
    HotKey[OSKEY_H] = "H"
    HotKey[OSKEY_I] = "I"
    HotKey[OSKEY_J] = "J"
    HotKey[OSKEY_K] = "K"
    HotKey[OSKEY_L] = "L"
    HotKey[OSKEY_M] = "M"
    HotKey[OSKEY_N] = "N"
    HotKey[OSKEY_O] = "O"
    HotKey[OSKEY_P] = "P"
    HotKey[OSKEY_Q] = "Q"
    HotKey[OSKEY_R] = "R"
    HotKey[OSKEY_S] = "S"
    HotKey[OSKEY_T] = "T"
    HotKey[OSKEY_U] = "U"
    HotKey[OSKEY_V] = "V"
    HotKey[OSKEY_W] = "W"
    HotKey[OSKEY_X] = "X"
    HotKey[OSKEY_Y] = "Y"
    HotKey[OSKEY_Z] = "Z"
    HotKey[OSKEY_OEM_COMMA] = ","
    HotKey[OSKEY_OEM_MINUS] = "-"
    HotKey[OSKEY_OEM_PLUS] = "+"
    HotKey[OSKEY_OEM_PERIOD] = "."
    HotKey[OSKEY_OEM_2] = "#"
    HotKey[OSKEY_OEM_7] = "Ä"
    HotKey[OSKEY_OEM_3] = "Ö"
    HotKey[OSKEY_OEM_1] = "Ü"
    HotKey[OSKEY_OEM_4] = "ß"
    HotKey[OSKEY_OEM_5] = "^"
    HotKey[OSKEY_OEM_6] = "´"
    HotKey[OSKEY_OEM_102] = "<"
    HotKey[OSKEY_LALT] = "LALT"
    HotKey[OSKEY_RALT] = "RALT"
    HotKey[OSKEY_LCONTROL] = "LCRTL"
    HotKey[OSKEY_RCONTROL] = "RCRTL"
    HotKey[OSKEY_LSHIFT] = "LSHIFT"
    HotKey[OSKEY_RSHIFT] = "RSHIFT"
    HotKey[OSKEY_ESCAPE] = "ESC"    
    HotKey[OSKEY_CAPSLOCK] = "CAPSLOCK"    
    HotKey[OSKEY_TAB] = "TAB"
    HotKey[OSKEY_BACKSPACE] = "BACKSPACE"
    HotKey[OSKEY_SPACE] = "SPACE"    
    HotKey[OSKEY_NUMPAD0] = "N0"
    HotKey[OSKEY_NUMPAD1] = "N1"
    HotKey[OSKEY_NUMPAD2] = "N2"
    HotKey[OSKEY_NUMPAD3] = "N3"
    HotKey[OSKEY_NUMPAD4] = "N4"
    HotKey[OSKEY_NUMPAD5] = "N5"
    HotKey[OSKEY_NUMPAD6] = "N6"
    HotKey[OSKEY_NUMPAD7] = "N7"
    HotKey[OSKEY_NUMPAD8] = "N8"
    HotKey[OSKEY_NUMPAD9] = "N9"
    HotKey[OSKEY_F1] = "F1"
    HotKey[OSKEY_F2] = "F2"
    HotKey[OSKEY_F3] = "F3"
    HotKey[OSKEY_F4] = "F4"
    HotKey[OSKEY_F5] = "F5"
    HotKey[OSKEY_F6] = "F6"
    HotKey[OSKEY_F7] = "F7"
    HotKey[OSKEY_F8] = "F8"
    HotKey[OSKEY_F9] = "F9"
    HotKey[OSKEY_F10] = "F10"
    HotKey[OSKEY_F11] = "F11"
    HotKey[OSKEY_F12] = "F12"
    HotKey["0"] = OSKEY_0
    HotKey["1"] = OSKEY_1
    HotKey["2"] = OSKEY_2
    HotKey["3"] = OSKEY_3
    HotKey["4"] = OSKEY_4
    HotKey["5"] = OSKEY_5
    HotKey["6"] = OSKEY_6
    HotKey["7"] = OSKEY_7
    HotKey["8"] = OSKEY_8
    HotKey["9"] = OSKEY_9
    HotKey["A"] = OSKEY_A
    HotKey["B"] = OSKEY_B
    HotKey["C"] = OSKEY_C
    HotKey["D"] = OSKEY_D
    HotKey["E"] = OSKEY_E
    HotKey["F"] = OSKEY_F
    HotKey["G"] = OSKEY_G
    HotKey["H"] = OSKEY_H
    HotKey["I"] = OSKEY_I
    HotKey["J"] = OSKEY_J
    HotKey["K"] = OSKEY_K
    HotKey["L"] = OSKEY_L
    HotKey["M"] = OSKEY_M
    HotKey["N"] = OSKEY_N
    HotKey["O"] = OSKEY_O
    HotKey["P"] = OSKEY_P
    HotKey["Q"] = OSKEY_Q
    HotKey["R"] = OSKEY_R
    HotKey["S"] = OSKEY_S
    HotKey["T"] = OSKEY_T
    HotKey["U"] = OSKEY_U
    HotKey["V"] = OSKEY_V
    HotKey["W"] = OSKEY_W
    HotKey["X"] = OSKEY_X
    HotKey["Y"] = OSKEY_Y
    HotKey["Z"] = OSKEY_Z
    HotKey[","] = OSKEY_OEM_COMMA
    HotKey["-"] = OSKEY_OEM_MINUS
    HotKey["+"] = OSKEY_OEM_PLUS
    HotKey["."] = OSKEY_OEM_PERIOD
    HotKey["#"] = OSKEY_OEM_2
    HotKey["Ä"] = OSKEY_OEM_7
    HotKey["Ö"] = OSKEY_OEM_3
    HotKey["Ü"] = OSKEY_OEM_1
    HotKey["ß"] = OSKEY_OEM_4
    HotKey["^"] = OSKEY_OEM_5
    HotKey["´"] = OSKEY_OEM_6
    HotKey["<"] = OSKEY_OEM_102
    HotKey["LALT"] = OSKEY_LALT
    HotKey["LCRTL"] = OSKEY_LCONTROL
    HotKey["LSHIFT"] = OSKEY_LSHIFT
    HotKey["RALT"] = OSKEY_RALT
    HotKey["RCRTL"] = OSKEY_RCONTROL
    HotKey["RSHIFT"] = OSKEY_RSHIFT
    HotKey["TAB"] = OSKEY_TAB
    HotKey["SPACE"] = OSKEY_SPACE
    HotKey["CAPSLOCK"] = OSKEY_CAPSLOCK
    HotKey["BACKSPACE"] = OSKEY_BACKSPACE
    HotKey["N0"] = OSKEY_NUMPAD0
    HotKey["N1"] = OSKEY_NUMPAD1
    HotKey["N2"] = OSKEY_NUMPAD2
    HotKey["N3"] = OSKEY_NUMPAD3
    HotKey["N4"] = OSKEY_NUMPAD4
    HotKey["N5"] = OSKEY_NUMPAD5
    HotKey["N6"] = OSKEY_NUMPAD6
    HotKey["N7"] = OSKEY_NUMPAD7
    HotKey["N8"] = OSKEY_NUMPAD8
    HotKey["N9"] = OSKEY_NUMPAD9
    HotKey["F1"] = OSKEY_F1
    HotKey["F2"] = OSKEY_F2
    HotKey["F3"] = OSKEY_F3
    HotKey["F4"] = OSKEY_F4
    HotKey["F5"] = OSKEY_F5
    HotKey["F6"] = OSKEY_F6
    HotKey["F7"] = OSKEY_F7
    HotKey["F8"] = OSKEY_F8
    HotKey["F9"] = OSKEY_F9
    HotKey["F10"] = OSKEY_F10
    HotKey["F11"] = OSKEY_F11
    HotKey["F12"] = OSKEY_F12
    

    for playerIndex = 0, GetBJMaxPlayers()-1,1 do
        local player = Player(playerIndex)
        BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, OSKEY_LALT,  4, true)
        BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, OSKEY_LALT,  0, false)
        BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, OSKEY_LSHIFT,  1, true)
        BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, OSKEY_LSHIFT,  0, false)
        BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, OSKEY_LCONTROL,  2, true)
        BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, OSKEY_LCONTROL,  0, false)
        BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, OSKEY_RALT,  4, true)
        BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, OSKEY_RALT,  0, false)
        BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, OSKEY_RSHIFT,  1, true)
        BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, OSKEY_RSHIFT,  0, false)
        BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, OSKEY_RCONTROL,  2, true)
        BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, OSKEY_RCONTROL,  0, false)
        BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, OSKEY_SPACE,  0, true)
        BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, OSKEY_SPACE,  0, false)
        BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, OSKEY_CAPSLOCK,  0, true)
        BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, OSKEY_CAPSLOCK,  0, false)
        BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, OSKEY_BACKSPACE,  0, true)
        BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, OSKEY_BACKSPACE,  0, false)

        for index = 48, 90,1 do --A to 0
            local key = ConvertOsKeyType(index)
            BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, key,  0, true) 
            BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, key,  0, false) 
        end
        for index = 96, 105,1 do --Numpad
            local key = ConvertOsKeyType(index)
            BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, key,  0, true) 
            BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, key,  0, false) 
        end
        for index = 112, 123,1 do --F1 to F12
            local key = ConvertOsKeyType(index)
            BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, key,  0, true) 
            BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, key,  0, false) 
        end
        for index = 186, 192,1 do --some OEM key BA to C0
            local key = ConvertOsKeyType(index)
            BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, key,  0, true) 
            BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, key,  0, false) 
        end
        for index = 219, 223,1 do --further OEM KEys DB to DF
            local key = ConvertOsKeyType(index)
            BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, key,  0, true) 
            BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, key,  0, false) 
        end

        for index = 225, 226,1 do --further OEM KEys E1,E2
            local key = ConvertOsKeyType(index)
            BlzTriggerRegisterPlayerKeyEvent(clickTrigger, player, key,  0, true) 
            BlzTriggerRegisterPlayerKeyEvent(releaseTrigger, player, key,  0, false) 
        end
    end
end) 
