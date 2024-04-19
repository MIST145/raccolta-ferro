ESX = exports["es_extended"]:getSharedObject()

CreateModelHide(vector3(1720.8802, 3695.7625, 33.476), 10.5, -1241212535, true)

RegisterNetEvent("gngn:notify")
AddEventHandler("gngn:notify", function(title, desc)
    exports['okokNotify']:Alert(title or 'Miner Job', desc, 5000, 'info', false)
end)

function makeProp(data, freeze, synced)
    loadModel(data.prop)
    local prop = CreateObject(data.prop, data.coords.x, data.coords.y, data.coords.z - 1.03, synced or false, synced or false, 0)
    SetEntityHeading(prop, data.coords + 180.0) -- Correction here
    FreezeEntityPosition(prop, freeze or false)
    if Config.Debug then 
        print("^2Debug^7: ^0Prop Created ^7: '^2"..prop.."^7'") 
    end
    return prop
end


local time = 1000
function loadModel(model) 
    if not HasModelLoaded(model) then
        if Config.Debug then 
            print("^2Debug^7: ^2Loading Model^7: '^2"..model.."^7'") 
        end
        while not HasModelLoaded(model) do
            if time > 0 then 
                time = time - 1 
                RequestModel(model)
            else 
                time = 1000 
                print("^2Debug^7: ^2LoadModel^7: Timed out loading model ^7'^2"..model.."^7'") 
                break
            end
            Wait(10)
        end
    end 
end

Citizen.CreateThread(function()
    if Config.ferroShop then
        for k, v in ipairs(Config.ferroShopPos) do
            RequestModel(GetHashKey(v.ped))
            while not HasModelLoaded(GetHashKey(v.ped)) do
                Wait(1)
            end

            local createshopped = CreatePed(4, GetHashKey(v.ped), v.coords.x, v.coords.y, v.coords.z-1, v.coords.h, false, true)
            FreezeEntityPosition(createshopped, true)
            SetEntityInvincible(createshopped, true) 
            SetBlockingOfNonTemporaryEvents(createshopped, true)

            exports.ox_target:addBoxZone({
                coords = vec3(v.coords.x, v.coords.y, v.coords.z),
                size = v.size,
                rotation = v.coords.h,
                distance = 2,
                debug = false,
              
                options = {
                    {
                        name = 'Ferroshop',
                        event = 'gngn:showferrocontext',
                        icon = v.icon,
                        label = v.label,          
                    }
                }
            })

            Citizen.Wait(30000)
        end
    end
end)

local propSpawnCooldown = 30 * 1000
local createdProps = {}
local createdTargets = {}

function createPropAndTarget(propCoords)
    local propAlreadyExists = false
    local targetAlreadyExists = false
    local proximityThreshold = 2.0

    for _, propInfo in pairs(createdTargets) do
        local existingPropCoords = GetEntityCoords(propInfo.prop)
        local distance = #(propCoords - existingPropCoords)
        if distance < proximityThreshold then
            propAlreadyExists = true
            break
        end
    end

    for _, propInfo in pairs(createdTargets) do
        local existingPropCoords = GetEntityCoords(propInfo.prop)
        if existingPropCoords == propCoords then
            targetAlreadyExists = true
            break
        end
    end

    if not propAlreadyExists and not targetAlreadyExists then
        local prop = makeProp({ coords = propCoords, prop = GetHashKey("prop_ld_rubble_03") }, 1, false)
        table.insert(createdProps, prop)

        local zoneParameters = {
            coords = propCoords,
            radius = 1.2,
            debug = false,
            distance = 1,
            drawSprite = true,
            options = {
                {
                    name = 'ferraio' .. prop,
                    event = 'raccoltaferro',
                    icon = "fas fa-screwdriver",
                    items = {[Config.RequiredItem] = 1},
                    label = 'Ferro'
                }
            }
        }
        local zoneId = exports.ox_target:addSphereZone(zoneParameters)
        createdTargets[prop] = { id = zoneId, prop = prop }
    end
end

function hidePropAndTarget(propInfo)
    local prop = propInfo.prop
    local zoneId = propInfo.id

    SetEntityAlpha(prop, 0)
    exports.ox_target:removeZone(zoneId)
    createdTargets[prop] = nil
end

function unhidePropAndTarget(propInfo)
    local prop = propInfo.prop
    local propCoords = GetEntityCoords(prop)

    SetEntityAlpha(prop, 255)
    local zoneParameters = {
        coords = propCoords,
        radius = 1.2,
        debug = false,
        distance = 1,
        drawSprite = true,
        options = {
            {
                name = 'ferraio' .. prop,
                event = 'raccoltaferro',
                icon = "fas fa-screwdriver",
                items = {[Config.RequiredItem] = 1},
                label = 'Ferro'
            }
        }
    }
    local zoneId = exports.ox_target:addSphereZone(zoneParameters)
    createdTargets[prop] = { id = zoneId, prop = prop }
end

function resetTargetOptions(prop)
    local propInfo = createdTargets[prop]
    local zoneId = propInfo.id
    exports.ox_target:removeZone(zoneId)
    local propCoords = GetEntityCoords(prop)
    local zoneParameters = {
        coords = propCoords,
        radius = 1.2,
        debug = false,
        distance = 1,
        drawSprite = true,
        options = {
            {
                name = 'ferraio' .. prop,
                event = 'raccoltaferro',
                icon = "fas fa-screwdriver",
                items = {[Config.RequiredItem] = 1},
                label = 'Ferro'
            }
        }
    }
    Citizen.Wait(1000)
    local newZoneId = exports.ox_target:addSphereZone(zoneParameters)
    createdTargets[prop].id = newZoneId
end

function checkFerroPositions()
    for _, v in pairs(Config.ferroPositions) do
        local propCoords = vector3(v.x, v.y, v.z)
        createPropAndTarget(propCoords)
    end
end

checkFerroPositions()

RegisterNetEvent("raccoltaferro")
AddEventHandler("raccoltaferro", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPropInfo = nil
    local closestDistance = 3.0

    for _, propInfo in pairs(createdTargets) do
        local propCoords = GetEntityCoords(propInfo.prop)
        local distance = #(playerCoords - propCoords)
        if distance < closestDistance then
            closestPropInfo = propInfo
            closestDistance = distance
        end
    end

    if lib.progressBar({
        duration = Config.Timings["Extractor"],
        label = 'Collecting...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = 'amb@world_human_gardener_plant@male@base',
            clip = 'base'
        },
        prop = {
            model = `prop_tool_consaw`,
            bone = 57005,
            pos = vec3(0.18, 0.07, 0.00),
            rot = vec3(252.0, 180.0, 0.0)
        },
    }) then

    TriggerServerEvent("gngn:ferroreward")

    if closestPropInfo ~= nil then
        hidePropAndTarget(closestPropInfo)
        Citizen.Wait(Config.Timings["FerroRespawn"])
        unhidePropAndTarget(closestPropInfo)
        resetTargetOptions(closestPropInfo.prop)
        end
    end
end)

Citizen.CreateThread(function()

    for _, info in pairs(Config.Blips) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, info.size)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
 end)

AddEventHandler("onClientResourceStop", function(reason)
    for _, prop in ipairs(createdProps) do
        DeleteEntity(prop)
    end
end)

RegisterNetEvent("gngn:showferrocontext")
AddEventHandler("gngn:showferrocontext", function()
        lib.registerContext({
            id = 'ferro',
            title = 'Blacksmith ' .. GetPlayerName(PlayerId()) .. '(' .. GetPlayerServerId(PlayerId()) .. ')',
            options = {
                {
                    title = 'Iron Accessories',
                    description = 'Buy your pickaxes here',
                    icon = 'fas fa-toolbox',
                    menu = 'ferro2',
                    iconColor = '#0a77ae',
                    arrow = true,
                    iconAnimation = 'fade'
                },
            }
        })

        lib.showContext('ferro')
end)

lib.registerContext({
    id = 'ferro2',
    title = 'Blacksmith ' .. GetPlayerName(PlayerId()) .. '(' .. GetPlayerServerId(PlayerId()) .. ')',
    options = {
        {
            title = 'Electric Saw',
            description = 'With this, you can cut all pieces of iron. Cost: $500',
            icon = 'fas fa-dollar-sign',
            serverEvent = 'buyestrattore',
            iconColor = '#017a60',
            arrow = true,
            iconAnimation = 'fade'
        },
    }
})
