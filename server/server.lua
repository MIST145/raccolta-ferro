ESX = exports["es_extended"]:getSharedObject()

function discordname(source)
    local discord = ""
    local id = ""
    
    if source then
        local identifiers = GetNumPlayerIdentifiers(source)
        for i = 0, identifiers - 1 do
            local identifier = GetPlayerIdentifier(source, i)
            if identifier and string.match(identifier, "discord") then
                discord = identifier
                id = string.sub(discord, 9, -1)
                break
            end
        end
    end

    return "<@" .. id .. ">"
end

RegisterServerEvent("gngn:ferroreward")
AddEventHandler("gngn:ferroreward", function()
    local xPlayer = ESX.GetPlayerFromId(source)

    logs('Raccolta ferro', "**NAME **\n " .. GetPlayerName(source) .. "\n" .. "**IDENTIFIER **\n " .. GetPlayerIdentifier(source) .. "\n" .. "**DISCORD **\n" .. discordname(source) .. "\n" .. "**FINISH **\n Ha raccolto del ferro!", 5763719)

    dajitem(xPlayer.source)
    
end)

RegisterServerEvent("buyestrattore")
AddEventHandler("buyestrattore", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local pickcost = 500
    local PlayerMoney = xPlayer.getMoney()

    if PlayerMoney >= pickcost then
    xPlayer.addInventoryItem('estrattore', 1)
    xPlayer.removeMoney(pickcost)
    else
    TriggerClientEvent("gngn:notify", source, "Raccolta ferro", "Non hai soldi a sufficienza")
    end
end)

function dajitem(da)
    local d = math.random(0, 100)
    local xPlayer = ESX.GetPlayerFromId(da)

    local items = {
    'ironore',
    }

    local randomItem = items[math.random(1, #items)]

    if Config.Debug then print(d) end

    if d <= 55 then
        xPlayer.addInventoryItem('ironore', 1)
    elseif d <= 70 then 
        xPlayer.addInventoryItem(randomItem, 1)
    elseif d <= 85 then 
        local uncutgems = {'ironore', 'ironore', 'ironore'}
        local randomgem = uncutgems[math.random(1, #uncutgems)]
        xPlayer.addInventoryItem(randomgem, 1)
    elseif d <= 100 then 
        xPlayer.addInventoryItem('ironore', 1)
    end
end

function logs(name, message, color, imageUrl)
    local webhookjob = 'https://discordapp.com/api/webhooks/1229100990624567347/0a54Rc5fUqtvIclSxxSrrfZBUaJyhm_94grvVKbX3xW8PNn_PEVwNVzPsAxcgW42zUvA'

    if message == nil or message == '' then 
        return false 
    end

    local embed = {
        title = message,
        type = "rich",
        color = color,
        footer = {
            text = "Raccolta Ferro Logs",
            icon_url = "https://i.imgur.com/FnZFBjU.png",
        },
        thumbnail = {
            url = "https://i.imgur.com/FnZFBjU.png",
        },
        author = {
            name = 'Raccolta Ferro Logs',
            icon_url = 'https://i.imgur.com/FnZFBjU.png',
        },
    }

    local payload = {
        username = name,
        embeds = {embed},
    }

    PerformHttpRequest(webhookjob, function(err, text, headers) end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end


