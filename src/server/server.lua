if GetCurrentResourceName() ~= "xinput_samtal" then
    print("Script must be named xinput_samtal to work correctly")
    while true do
        Wait(3000)
        print("Script must be named xinput_samtal to work correctly")
    end
    return
end

local callChannels = {}
local callStarters = {}

RegisterCommand("samtal", function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if callChannels[source] then
        TriggerClientEvent("esx:showNotification", source, "Du är redan i ett samtal.")
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent("esx:showNotification", source, "Ange ett giltigt ID.")
        return
    end

    if source == targetId then
        TriggerClientEvent("esx:showNotification", source, "Du kan inte starta samtal med dig själv.")
        return
    end

    if not GetPlayerName(targetId) then
        TriggerClientEvent("esx:showNotification", source, "Spelaren är inte online.")
        return
    end

    local channel
    repeat
        channel = math.random(10000, 99999)
    until not callStarters[channel]

    callChannels[source] = channel
    callChannels[targetId] = channel
    callStarters[channel] = {
        source = source,
        target = targetId,
        startTime = os.time()
    }

    TriggerClientEvent("abdiez_starta_samtal", source, channel, true, GetPlayerName(targetId))
    TriggerClientEvent("abdiez_starta_samtal", targetId, channel, false)

    if Config.WebhookURL ~= "" then
        PerformHttpRequest(Config.WebhookURL, function() end, "POST", json.encode({
            content = ("**Staff-samtal startat**\n**Från:** %s\n**Till:** %s\n**Kanal:** %d")
                :format(GetPlayerName(source), GetPlayerName(targetId), channel)
        }), {
            ["Content-Type"] = "application/json"
        })
    end
end, false)

RegisterCommand("avslutasamtal", function(source)
    local channel = callChannels[source]
    if not channel then
        TriggerClientEvent("esx:showNotification", source, "Du sitter inte i ett aktivt samtal.")
        return
    end

    local info = callStarters[channel]
    local dur = os.time() - info.startTime
    local m, s = math.floor(dur / 60), dur % 60

    if Config.WebhookURL ~= "" then
        PerformHttpRequest(Config.WebhookURL, function() end, "POST", json.encode({
            content = ("Samtalet mellan **%s** och **%s** varade i %d min %d sek.")
                :format(GetPlayerName(info.source), GetPlayerName(info.target), m, s)
        }), {
            ["Content-Type"] = "application/json"
        })
    end

    for pid, ch in pairs(callChannels) do
        if ch == channel then
            TriggerClientEvent("abdiez_avsluta_samtal", pid)
            callChannels[pid] = nil
        end
    end

    callStarters[channel] = nil
end, false)

AddEventHandler("playerDropped", function()
    local pid = source
    local channel = callChannels[pid]
    if channel then
        for p, ch in pairs(callChannels) do
            if ch == channel then
                TriggerClientEvent("abdiez_avsluta_samtal", p)
                callChannels[p] = nil
            end
        end
        callStarters[channel] = nil
    end
end)

