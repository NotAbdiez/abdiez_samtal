if GetCurrentResourceName() ~= "abdiez_samtal" then
    print("Script must be named abdiez_samtal to work correctly.")
    while true do
        Wait(3000)
        TriggerEvent("chat:addMessage", {
            color = { 255, 0, 0 },
            multiline = true,
            args = {
                "Xinput",
                "Script must be named xinput_samtal to work correctly"
            }
        })
    end
    return
end

local isInCall = false

local function screenText(x, y, scale, text, custom)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    if custom then
        DrawText(x, y)
    else
        DrawText(0.18, y)
    end
end

RegisterNetEvent("abdiez_starta_samtal")
AddEventHandler("abdiez_starta_samtal", function(channel, isStaff, targetName)
    isInCall = true
    exports["pma-voice"]:setCallChannel(channel)

    if isStaff then
        TriggerEvent("abdiez_visa_personal_meddelande", targetName)
    else
        TriggerEvent("abdiez_visa_spelare_meddelande")
    end
end)

RegisterNetEvent("abdiez_avsluta_samtal")
AddEventHandler("abdiez_avsluta_samtal", function()
    isInCall = false
    exports["pma-voice"]:setCallChannel(0)
    ESX.ShowNotification("~g~Samtalet avslutades")
end)

RegisterNetEvent("abdiez_visa_personal_meddelande")
AddEventHandler("abdiez_visa_personal_meddelande", function(name)
    CreateThread(function()
        while isInCall do
            screenText(0.19, 0.922, 0.4, ("Du sitter i ett samtal med ~y~%s"):format(name), true)
            screenText(0.19, 0.945, 0.4, "För att avsluta: ~r~/avslutasamtal", true)
            Wait(0)
        end
    end)
end)

RegisterNetEvent("abdiez_visa_spelare_meddelande")
AddEventHandler("abdiez_visa_spelare_meddelande", function()
    CreateThread(function()
        while isInCall do
            screenText(0.19, 0.922, 0.4, "Du sitter i ett ~y~staff samtal", true)
            screenText(0.19, 0.945, 0.4, "Endast staff kan avsluta samtalet", true)
            Wait(0)
        end
    end)
end)


