local ESX = nil
local PlayerData = {}
local currentGarage = nil
local inGarageMenu = false
local currentVehicles = {}
local spawnedVehicle = nil
local garageVehicle = nil
local inGarageInterior = false
local selectedVehicleIndex = 1

-- DUI Variables
local duiObjects = {}
local duiTextures = {}

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Fonction pour créer un DUI autour de la tête
function CreateHeadDUI(text, lines)
    local txd = CreateRuntimeTxd('duiGarage')
    local duiWidth = 512
    local duiHeight = 256

    local duiUrl = "https://i.imgur.com/placeholder.png"

    -- Créer le DUI object
    local dui = CreateDui("about:blank", duiWidth, duiHeight)

    -- Créer du HTML pour le texte
    local html = [[
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    background: rgba(0, 0, 0, 0.7);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    font-family: 'Arial Black', sans-serif;
                }
                .container {
                    text-align: center;
                    color: #00ff00;
                    text-shadow: 0 0 10px #00ff00, 0 0 20px #00ff00;
                    font-size: 48px;
                    font-weight: bold;
                    line-height: 1.2;
                    animation: pulse 2s infinite;
                }
                @keyframes pulse {
                    0%, 100% { opacity: 1; }
                    50% { opacity: 0.7; }
                }
            </style>
        </head>
        <body>
            <div class="container">]] .. text .. [[</div>
        </body>
        </html>
    ]]

    SetDuiHtml(dui, html)

    local duiHandle = GetDuiHandle(dui)
    local tx = CreateRuntimeTextureFromDuiHandle(txd, 'duiTexture', duiHandle)

    return {dui = dui, txd = txd, texture = 'duiTexture', handle = duiHandle}
end

-- Fonction pour afficher le DUI autour de la tête du joueur
function DisplayHeadDUI(garage)
    local ped = PlayerPedId()
    local boneIndex = GetPedBoneIndex(ped, 0x796e) -- Head bone

    if not duiObjects[garage.name] then
        duiObjects[garage.name] = CreateHeadDUI(garage.duiText:gsub('\n', '<br>'))
    end

    local duiData = duiObjects[garage.name]

    -- Dessiner le DUI comme un sprite autour de la tête
    local headPos = GetPedBoneCoords(ped, boneIndex, 0.0, 0.0, 0.0)
    local camCoords = GetGameplayCamCoord()

    DrawSprite(duiData.txd, duiData.texture, headPos.x, headPos.y + 0.5, headPos.z, 0.15, 0.15, 0.0, 255, 255, 255, 255)
end

-- Fonction pour dessiner du texte 3D
function Draw3DText(coords, text)
    local camCoords = GetGameplayCamCoord()
    local distance = #(coords - camCoords)

    if distance < Config.DrawDistance then
        local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)

        if onScreen then
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 215)
            SetTextEntry("STRING")
            SetTextCentre(1)
            AddTextComponentString(text)
            DrawText(_x, _y)

            local factor = (string.len(text)) / 370
            DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 150)
        end
    end
end

-- Fonction pour créer un effet de téléportation stylé
function TeleportEffect(callback)
    local ped = PlayerPedId()

    -- Effet de fade out
    DoScreenFadeOut(800)

    while not IsScreenFadedOut() do
        Citizen.Wait(0)
    end

    Citizen.Wait(500)

    -- Exécuter le callback (téléportation)
    if callback then
        callback()
    end

    Citizen.Wait(500)

    -- Effet de fade in
    DoScreenFadeIn(800)
end

-- Fonction pour spawner un véhicule avec effet
function SpawnVehicleWithEffect(model, coords, heading, plate, props)
    local modelHash = GetHashKey(model)

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(0)
    end

    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, heading, true, false)
    SetVehicleNumberPlateText(vehicle, plate)
    SetEntityAsSomewhatMission(vehicle, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehRadioStation(vehicle, 'OFF')

    -- Appliquer les props du véhicule
    if props then
        ESX.Game.SetVehicleProperties(vehicle, props)
    end

    -- Effet de spawn (particules)
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Citizen.Wait(0)
    end

    UseParticleFxAssetNextCall("core")
    StartParticleFxNonLoopedAtCoord("ent_dst_elec_fire_sp", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)

    SetModelAsNoLongerNeeded(modelHash)

    return vehicle
end

-- Fonction pour ouvrir le garage (téléportation vers IPL)
function OpenGarage(garage)
    ESX.TriggerServerCallback('esx_garage:getVehicles', function(vehicles)
        if #vehicles == 0 then
            ESX.ShowNotification(Config.Messages.no_vehicles)
            return
        end

        currentVehicles = vehicles
        currentGarage = garage
        selectedVehicleIndex = 1
        inGarageMenu = true

        -- Téléportation vers l'IPL de garage
        local iplConfig
        if garage.type == 'car' then
            iplConfig = Config.GarageIPL
        elseif garage.type == 'boat' then
            iplConfig = Config.BoatGarageIPL
        else
            iplConfig = Config.PlaneGarageIPL
        end

        TeleportEffect(function()
            local ped = PlayerPedId()
            SetEntityCoords(ped, iplConfig.Interior.x, iplConfig.Interior.y, iplConfig.Interior.z)
            SetEntityHeading(ped, iplConfig.Interior.w)
            inGarageInterior = true

            -- Spawner le premier véhicule
            if currentVehicles[selectedVehicleIndex] then
                SpawnGarageVehicle(selectedVehicleIndex, iplConfig)
            end
        end)
    end, garage.type)
end

-- Fonction pour spawner le véhicule dans le garage
function SpawnGarageVehicle(index, iplConfig)
    -- Supprimer l'ancien véhicule si existant
    if DoesEntityExist(garageVehicle) then
        DeleteEntity(garageVehicle)
    end

    local vehicle = currentVehicles[index]
    if vehicle then
        local spawnCoords = iplConfig.SpawnPoint
        garageVehicle = SpawnVehicleWithEffect(
            vehicle.vehicle.model,
            vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z),
            spawnCoords.w,
            vehicle.plate,
            vehicle.vehicle
        )

        -- Verrouiller le véhicule pour éviter que le joueur monte dedans
        SetVehicleDoorsLocked(garageVehicle, 2)
        FreezeEntityPosition(garageVehicle, true)
    end
end

-- Fonction pour sortir le véhicule du garage
function TakeOutVehicle()
    if not currentVehicles[selectedVehicleIndex] then return end

    local vehicle = currentVehicles[selectedVehicleIndex]

    TeleportEffect(function()
        -- Téléporter le joueur à la sortie du garage
        local ped = PlayerPedId()
        local spawnCoords = currentGarage.spawnPoint

        SetEntityCoords(ped, spawnCoords.x, spawnCoords.y, spawnCoords.z)
        SetEntityHeading(ped, spawnCoords.w)

        -- Supprimer le véhicule de l'intérieur
        if DoesEntityExist(garageVehicle) then
            DeleteEntity(garageVehicle)
        end

        -- Spawner le véhicule à l'extérieur
        spawnedVehicle = SpawnVehicleWithEffect(
            vehicle.vehicle.model,
            vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z),
            spawnCoords.w,
            vehicle.plate,
            vehicle.vehicle
        )

        -- Déverrouiller et mettre le joueur dedans
        SetVehicleDoorsLocked(spawnedVehicle, 1)
        FreezeEntityPosition(spawnedVehicle, false)
        TaskWarpPedIntoVehicle(ped, spawnedVehicle, -1)

        -- Mettre à jour l'état du véhicule
        TriggerServerEvent('esx_garage:setVehicleState', vehicle.plate, 0)

        ESX.ShowNotification(Config.Messages.vehicle_spawned)

        inGarageMenu = false
        inGarageInterior = false
        currentGarage = nil
    end)
end

-- Fonction pour changer de véhicule dans le menu
function ChangeGarageVehicle(direction)
    selectedVehicleIndex = selectedVehicleIndex + direction

    if selectedVehicleIndex < 1 then
        selectedVehicleIndex = #currentVehicles
    elseif selectedVehicleIndex > #currentVehicles then
        selectedVehicleIndex = 1
    end

    local iplConfig
    if currentGarage.type == 'car' then
        iplConfig = Config.GarageIPL
    elseif currentGarage.type == 'boat' then
        iplConfig = Config.BoatGarageIPL
    else
        iplConfig = Config.PlaneGarageIPL
    end

    SpawnGarageVehicle(selectedVehicleIndex, iplConfig)
end

-- Fonction pour quitter le garage sans sortir de véhicule
function ExitGarage()
    TeleportEffect(function()
        local ped = PlayerPedId()
        SetEntityCoords(ped, currentGarage.coords.x, currentGarage.coords.y, currentGarage.coords.z)
        SetEntityHeading(ped, currentGarage.heading)

        if DoesEntityExist(garageVehicle) then
            DeleteEntity(garageVehicle)
        end

        inGarageMenu = false
        inGarageInterior = false
        currentGarage = nil
    end)
end

-- Fonction pour ranger un véhicule
function StoreVehicle(garage)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        ESX.ShowNotification('Vous devez être dans un véhicule')
        return
    end

    local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

    ESX.TriggerServerCallback('esx_garage:storeVehicle', function(success)
        if success then
            TeleportEffect(function()
                DeleteEntity(vehicle)
                ESX.ShowNotification(Config.Messages.vehicle_stored)
            end)
        else
            ESX.ShowNotification(Config.Messages.not_owned)
        end
    end, plate, garage.type)
end

-- Affichage du menu DUI dans le garage
function DrawGarageMenu()
    if not inGarageMenu or not currentVehicles[selectedVehicleIndex] then return end

    local vehicle = currentVehicles[selectedVehicleIndex]
    local vehicleName = GetDisplayNameFromVehicleModel(vehicle.vehicle.model)
    local vehicleLabel = GetLabelText(vehicleName)

    if vehicleLabel == 'NULL' then
        vehicleLabel = vehicleName
    end

    -- Créer le HTML pour le menu
    local menuText = string.format(
        '<div style="font-size: 36px;">%s</div><div style="font-size: 24px; margin-top: 20px;">%d / %d</div><div style="font-size: 20px; margin-top: 30px;">← → Pour changer<br>E pour sortir<br>Retour arrière pour quitter</div>',
        vehicleLabel,
        selectedVehicleIndex,
        #currentVehicles
    )

    -- Afficher le texte à l'écran
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.5, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(vehicleLabel)
    DrawText(0.5, 0.3)

    -- Info véhicule
    SetTextFont(0)
    SetTextScale(0.35, 0.35)
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(string.format("~g~%d~s~ / ~g~%d", selectedVehicleIndex, #currentVehicles))
    DrawText(0.5, 0.35)

    -- Instructions
    SetTextFont(0)
    SetTextScale(0.3, 0.3)
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString("~b~←~s~ ~b~→~s~ Pour changer  |  ~g~E~s~ pour sortir  |  ~r~RETOUR~s~ pour quitter")
    DrawText(0.5, 0.9)
end

-- Thread principal pour l'interaction avec les garages
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if not inGarageMenu then
            for k, garage in pairs(Config.Garages) do
                local distance = #(coords - garage.coords)

                if distance < Config.DrawDistance then
                    sleep = 0
                    Draw3DText(garage.coords, garage.duiText)

                    if distance < Config.MarkerDistance then
                        -- Vérifier si le joueur est dans un véhicule
                        local vehicle = GetVehiclePedIsIn(ped, false)

                        if vehicle ~= 0 then
                            -- Ranger le véhicule
                            Draw3DText(vector3(coords.x, coords.y, coords.z + 1.0), Config.Messages.store_vehicle)

                            if IsControlJustReleased(0, 38) then -- E
                                StoreVehicle(garage)
                            end
                        else
                            -- Ouvrir le garage
                            Draw3DText(vector3(coords.x, coords.y, coords.z + 1.0), Config.Messages.garage_opened)

                            if IsControlJustReleased(0, 38) then -- E
                                OpenGarage(garage)
                            end
                        end
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- Thread pour le menu du garage
Citizen.CreateThread(function()
    while true do
        local sleep = 500

        if inGarageMenu and inGarageInterior then
            sleep = 0
            DrawGarageMenu()

            -- Navigation
            if IsControlJustReleased(0, 174) then -- Flèche gauche
                ChangeGarageVehicle(-1)
            elseif IsControlJustReleased(0, 175) then -- Flèche droite
                ChangeGarageVehicle(1)
            elseif IsControlJustReleased(0, 38) then -- E - Sortir le véhicule
                TakeOutVehicle()
            elseif IsControlJustReleased(0, 194) then -- Backspace - Quitter
                ExitGarage()
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Supprimer tous les DUI
        for k, dui in pairs(duiObjects) do
            if dui.dui then
                DestroyDui(dui.dui)
            end
        end

        -- Supprimer le véhicule du garage
        if DoesEntityExist(garageVehicle) then
            DeleteEntity(garageVehicle)
        end
    end
end)
