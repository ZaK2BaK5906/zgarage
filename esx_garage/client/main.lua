local ESX = nil
local PlayerData = {}
local currentGarage = nil

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

-- Fonction pour spawner un véhicule
function SpawnVehicle(model, coords, heading, plate, props)
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

    SetModelAsNoLongerNeeded(modelHash)

    return vehicle
end

-- Fonction pour ouvrir le menu du garage
function OpenGarageMenu(garageName, garage)
    -- Vérifier le job si c'est un garage job
    if garage.job then
        if PlayerData.job.name ~= garage.job then
            ESX.ShowNotification('~r~Vous n\'avez pas accès à ce garage')
            return
        end
    end

    -- Déterminer si c'est un garage société ou personnel
    local isSociety = garage.society == true

    ESX.TriggerServerCallback('esx_garage:getVehicles', function(vehicles)
        if #vehicles == 0 then
            ESX.ShowNotification(Config.Messages.no_vehicles)
            return
        end

        currentGarage = garage

        -- Créer les options pour le menu ox_lib
        local options = {}

        for i = 1, #vehicles, 1 do
            local vehicle = vehicles[i]
            local vehicleName = GetDisplayNameFromVehicleModel(vehicle.vehicle.model)
            local vehicleLabel = GetLabelText(vehicleName)

            if vehicleLabel == 'NULL' then
                vehicleLabel = vehicleName
            end

            local description = 'Plaque: ' .. vehicle.plate
            if isSociety then
                description = description .. ' [ENTREPRISE]'
            end

            table.insert(options, {
                title = vehicleLabel,
                description = description,
                icon = 'car',
                onSelect = function()
                    TakeOutVehicle(vehicle, garage)
                end
            })
        end

        -- Ouvrir le menu ox_lib
        lib.registerContext({
            id = 'garage_menu',
            title = garageName,
            options = options
        })

        lib.showContext('garage_menu')
    end, garage.type, isSociety, garage.job)
end

-- Fonction pour sortir le véhicule du garage
function TakeOutVehicle(vehicleData, garage)
    local ped = PlayerPedId()
    local spawnCoords = garage.spawnPoint

    -- Vérifier si un véhicule est déjà présent
    ESX.Game.DeleteVehicle(GetClosestVehicle(spawnCoords.x, spawnCoords.y, spawnCoords.z, 3.0, 0, 71))

    -- Attendre un peu
    Citizen.Wait(100)

    -- Spawner le véhicule
    local vehicle = SpawnVehicle(
        vehicleData.vehicle.model,
        vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z),
        spawnCoords.w,
        vehicleData.plate,
        vehicleData.vehicle
    )

    if not DoesEntityExist(vehicle) then
        ESX.ShowNotification('~r~Erreur lors du spawn du véhicule')
        return
    end

    -- Attendre que le véhicule soit bien spawn
    Citizen.Wait(100)

    -- Mettre le joueur dedans
    TaskWarpPedIntoVehicle(ped, vehicle, -1)

    -- Mettre à jour l'état du véhicule
    TriggerServerEvent('esx_garage:setVehicleState', vehicleData.plate, 0)

    ESX.ShowNotification(Config.Messages.vehicle_spawned)
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

    -- Déterminer si c'est un garage société
    local isSociety = garage.society == true
    local jobName = garage.job or nil

    ESX.TriggerServerCallback('esx_garage:storeVehicle', function(success)
        if success then
            DeleteEntity(vehicle)
            ESX.ShowNotification(Config.Messages.vehicle_stored)
        else
            ESX.ShowNotification(Config.Messages.not_owned)
        end
    end, plate, garage.type, isSociety, jobName)
end

-- Thread principal pour l'interaction avec les garages
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for garageName, garage in pairs(Config.Garages) do
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
                            OpenGarageMenu(garageName, garage)
                        end
                    end
                end
            end
        end

        Citizen.Wait(sleep)
    end
end)
