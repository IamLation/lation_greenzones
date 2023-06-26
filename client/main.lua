local greenZone = nil
local vehiclesInZone = nil
local adminZoneMenu = nil
local zone = lib.points.new(vec3(0, 0, 0), 0)
local pedCoords = nil
local radiusBlip = nil
local sprite = nil
local vehicle = nil
local speed = 0

-- Default greenzones configured beforehand in the config
for k, v in pairs(Config.GreenZones) do
    greenZone = lib.points.new(v.coords, v.radius)
    function greenZone:onEnter()
        if v.disablePlayerVehicleCollision then
            for _, player in pairs(GetActivePlayers()) do
                if player ~= cache.ped then
                    local ped = cache.ped
                    local ped2 = GetPlayerPed(player)
                    local veh = GetVehiclePedIsIn(ped, false)
                    local veh2 = GetVehiclePedIsIn(ped2, false)
                    SetEntityAlpha(ped2, 153, false)
                    if veh ~= 0 then
                        SetEntityAlpha(veh, 153, false)
                    end
                    if veh2 ~= 0 then
                        SetEntityAlpha(veh2, 153, false)
                    end
                end
            end
        end
        if v.removeWeapons then
            local currentWeapon = GetSelectedPedWeapon(cache.ped)
            RemoveWeaponFromPed(cache.ped, currentWeapon)
        end
        if v.disableFiring then
            SetPlayerCanDoDriveBy(cache.ped, false)
        end
        if v.setInvincible then
            SetEntityInvincible(cache.ped, true)
        end
        if v.enableSpeedLimits then
            vehicle = GetVehiclePedIsIn(cache.ped, false)
            speed = v.setSpeedLimit * 0.44
        end
        if v.displayTextUI then
            lib.showTextUI(v.textToDisplay, {
                position = v.displayTextPosition,
                icon = v.displayTextIcon,
                style = {
                    borderRadius = 4,
                    backgroundColor = v.backgroundColorTextUI,
                    color = v.textColor
                }
            })
        end
        if Config.EnableNotifications then
            lib.notify({
                title = Notifications.greenzoneTitle, 
                description = Notifications.greenzoneEnter,
                type = 'success',
                position = Notifications.position,
                duration = 6000,
                style = {
                backgroundColor = '#ff5a47',
                color = '#2C2C2C',
                    ['.description'] = {
                        color = '#2C2C2C',
                    }
                },
                icon = Notifications.greenzoneIcon,
                iconColor = '#2C2C2C'
            })
        end
    end
    function greenZone:onExit()
        if v.disablePlayerVehicleCollision then
            for _, player in pairs(GetActivePlayers()) do
                if player ~= cache.ped then
                    local ped = cache.ped
                    local ped2 = GetPlayerPed(player)
                    local veh = GetVehiclePedIsIn(ped, false)
                    local veh2 = GetVehiclePedIsIn(ped2, false)
                    SetEntityAlpha(ped2, 255, false)
                    if veh ~= 0 then
                        SetEntityAlpha(veh, 255, false)
                    end
                    if veh2 ~= 0 then
                        SetEntityAlpha(veh2, 255, false)
                    end
                end
            end
        end
        if v.disableFiring then
            SetPlayerCanDoDriveBy(cache.ped, true)
        end
        if v.setInvincible then
            SetEntityInvincible(cache.ped, false)
        end
        if v.enableSpeedLimits then
            vehicle = GetVehiclePedIsIn(cache.ped, false)
            SetVehicleMaxSpeed(vehicle, 0.0)
        end
        if v.displayTextUI then
            lib.hideTextUI()
        end
        if Config.EnableNotifications then
            lib.notify({
                title = Notifications.greenzoneTitle, 
                description = Notifications.greenzoneExit,
                type = 'error',
                position = Notifications.position,
                style = {
                backgroundColor = '#72E68F',
                color = '#2C2C2C',
                    ['.description'] = {
                        color = '#2C2C2C',
                    }
                },
                icon = Notifications.greenzoneIcon,
                iconColor = '#2C2C2C'
            })
        end
    end
    function greenZone:nearby()
        if v.disablePlayerVehicleCollision then
            for _, player in pairs(GetActivePlayers()) do
                if player ~= PlayerId() then
                    local ped = PlayerPedId()
                    local ped2 = GetPlayerPed(player)
                    local veh = GetVehiclePedIsIn(ped, false)
                    local veh2 = GetVehiclePedIsIn(ped2, false)
                    SetEntityAlpha(ped2, 153, false)
                    if veh2 ~= 0 then
                        if veh ~= 0 then
                            SetEntityAlpha(veh, 153, false)
                            SetEntityNoCollisionEntity(veh, veh2, true)
                            SetEntityNoCollisionEntity(veh2, veh, true)
                        end
                        SetEntityAlpha(veh2, 153, false)
                        SetEntityNoCollisionEntity(ped, veh2, true)
                        SetEntityNoCollisionEntity(veh2, ped, true)
                    else
                        SetEntityNoCollisionEntity(ped, ped2, true)
                        SetEntityNoCollisionEntity(ped2, ped, true)
                    end
                end
            end
        end
        if v.disableFiring then
            DisablePlayerFiring(cache.ped, true)
        end
        if v.enableSpeedLimits then
            vehicle = GetVehiclePedIsIn(cache.ped, false) -- This isn't 100% needed, could be commented out if performance is impacted too much. Only difference would be if player spawns into this zone, they can drive at any speed until exit/re-enter
            SetVehicleMaxSpeed(vehicle, speed)
        end
    end
end

 -- Blip creation for the default persistent greenzones configured beforehand
for k, v in pairs(Config.GreenZones) do
    if v.blip then
        if v.blipType == 'radius' then
            local blip = AddBlipForRadius(v.coords.x, v.coords.y, v.coords.z, v.radius)
            SetBlipColour(blip, v.blipColor)
            SetBlipAlpha(blip, v.blipAlpha)
            if v.enableSprite then
                local blip2 = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
                SetBlipSprite(blip2, v.blipSprite)
                SetBlipColour(blip2, v.blipColor)
                SetBlipScale(blip2, v.blipScale)
                SetBlipAsShortRange(blip2, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.blipName)
                EndTextCommandSetBlipName(blip2)
            end
        else
            local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite(blip, v.blipSprite)
            SetBlipColour(blip, v.blipColor)
            SetBlipScale(blip, v.blipScale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.blipName)
            EndTextCommandSetBlipName(blip)
        end
    end
end

-- Start of events for creating Greenzones in-game, this is the menu that takes data, passes it to server
lib.callback.register('lation_greenzones:adminZone', function()
    pedCoords = GetEntityCoords(cache.ped)
    adminZoneMenu = lib.inputDialog('Create Greenzone', {
        {type = 'input', label = 'Blip Name', description = 'The name of the Greenzone on the map', placeholder = 'Greenzone', icon = 'quote-left', required = true, min = 4, max = 16},
        {type = 'input', label = 'Display Text', description = 'Text to display on everyone\'s screen in this zone', placeholder = 'Active Greenzone', icon = 'comment', required = true},
        {type = 'color', label = 'Display Text Color', description = 'The HTML color code of the text displayed', default = '#ff5a47', icon = 'palette', required = true},
        {type = 'select', label = 'Display Text Position', description = 'The position on the screen for the text', options = {
            { value = 'right-center', label = 'Right center'},
            { value = 'left-center', label = 'Left center' },
            { value = 'top-center', label = 'Top center' }
        }, default = 'top-center', clearable = false, required = true},
        {type = 'slider', label = 'Size (radius)', icon = 'sliders', required = true, default = 10, min = 1, max = 100, step = 1},
        {type = 'checkbox', label = 'Disable Firing', checked = false},
        {type = 'checkbox', label = 'Everyone Invincible', checked = false},
        {type = 'slider', label = 'Speed Limit (MPH)', icon = 'sliders', required = false, default = 0, min = 0, max = 100, step = 10},
        {type = 'number', label = 'Blip ID', description = 'The sprite ID to display on the map', icon = 'map-pin', default = 487, required = true},
        {type = 'number', label = 'Blip Color', description = 'The blip color for the above sprite', icon = 'palette', default = 1, required = true}
      })
    if adminZoneMenu == nil then
        return
    else
        zoneName = adminZoneMenu[1]
        textUI = adminZoneMenu[2]
        textUIColor = adminZoneMenu[3]
        textUIPosition = adminZoneMenu[4]
        zoneSize = adminZoneMenu[5]
        disarm = adminZoneMenu[6]
        invincible = adminZoneMenu[7]
        speedLimit = adminZoneMenu[8]
        blipID = adminZoneMenu[9]
        blipColor = adminZoneMenu[10]
        lib.callback('lation_greenzones:data', false, cb, pedCoords, zoneName, textUI, textUIColor, textUIPosition, zoneSize, disarm, invincible, speedLimit, blipID, blipColor)
    end
end)

-- The function that creates a temporary greenzone via in-game command for all clients from the data passed
RegisterNetEvent('lation_greenzones:createAdminZone')
AddEventHandler('lation_greenzones:createAdminZone', function(zoneCoords, zoneName, textUI, textUIColor, textUIPosition, zoneSize, disarm, invincible, speedLimit, blipID, blipColor)
    vehicle = GetVehiclePedIsIn(cache.ped, false)
    zone:remove() -- Removes any existing zones
    RemoveBlip(radiusBlip) -- Removes any exisitng radius blips
    RemoveBlip(sprite) -- Removes any existing blip sprites
    lib.hideTextUI() -- Hides any existing textUI's
    SetVehicleMaxSpeed(vehicle, 0.0) -- Ensures no vehicle speed limits are enforced
    SetEntityInvincible(cache.ped, false) -- Ensures no one is still invincible anywhere
    createBlip(zoneName, zoneCoords, zoneSize, blipID, blipColor) -- Creates the new blip
    zone = lib.points.new(zoneCoords, zoneSize) -- Creates a new point
    speed = speedLimit * 0.44 -- Converts to MPH (probably not 100% accurate but works enough lul)
    function zone:onEnter()
        vehicle = GetVehiclePedIsIn(cache.ped, false)
        lib.showTextUI(textUI, {
            position = textUIPosition,
            icon = 'shield-halved',
            style = {
                borderRadius = 4,
                backgroundColor = textUIColor,
                color = 'black'
            }
        })
        if invincible then
            SetEntityInvincible(cache.ped, true)
        end
    end
    function zone:onExit()
        lib.hideTextUI()
        if invincible then
            SetEntityInvincible(cache.ped, false)
        end
        SetVehicleMaxSpeed(vehicle, 0.0)
    end
    function zone:nearby()
        if disarm then
            DisablePlayerFiring(cache.ped, true)
        end
        if speedLimit ~= 0 then
            vehicle = GetVehiclePedIsIn(cache.ped, false)
            SetVehicleMaxSpeed(vehicle, speed)
        end
    end
end)

-- The function that creates blips for Greenzones created in-game
function createBlip(blipName, blipCoords, blipRadius, blipID, blipColor)
    local radius = ESX.Math.Round(blipRadius, 1)
    radiusBlip = AddBlipForRadius(blipCoords, radius)
    SetBlipColour(radiusBlip, blipColor)
    SetBlipAlpha(radiusBlip, 100)
    sprite = AddBlipForCoord(blipCoords)
    SetBlipSprite(sprite, blipID)
    SetBlipDisplay(sprite, 4)
    SetBlipColour(sprite, blipColor)
    SetBlipScale(sprite, 1.0)
    SetBlipAsShortRange(sprite, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipName)
    EndTextCommandSetBlipName(sprite)
end

-- The actual removal of all tempoary greenzone related things
function deleteZone()
    vehicle = GetVehiclePedIsIn(cache.ped, false)
    zone:remove()
    RemoveBlip(radiusBlip)
    RemoveBlip(sprite)
    lib.hideTextUI()
    SetVehicleMaxSpeed(vehicle, 0.0)
    SetEntityInvincible(cache.ped, false)
end

-- The confirmation for deleting an active temporary greenzone
lib.callback.register('lation_greenzones:adminZoneClear', function()
    local confirm = lib.alertDialog({
        header = 'Confirm Action',
        content = 'Are you sure you want to delete your Green Zone?',
        centered = true,
        cancel = true
    })
    if confirm == 'confirm' then
        lib.callback('lation_greenzones:deleteZone')
    else
        return
    end
end)

-- The event that gets triggered for all clients when deleting a temporary greenzone
RegisterNetEvent('lation_greenzones:deleteAdminZone')
AddEventHandler('lation_greenzones:deleteAdminZone', function()
    deleteZone()
end)