local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

-- Récupérer les véhicules du joueur
ESX.RegisterServerCallback('esx_garage:getVehicles', function(source, cb, type)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb({})
        return
    end

    local vehicles = {}
    local query = ''
    local params = {
        ['@owner'] = xPlayer.identifier
    }

    if type == 'boat' then
        query = 'SELECT * FROM owned_vehicles WHERE owner = @owner AND type = @type AND stored = 1'
        params['@type'] = 'boat'
    elseif type == 'plane' then
        query = 'SELECT * FROM owned_vehicles WHERE owner = @owner AND type = @type AND stored = 1'
        params['@type'] = 'aircraft'
    else
        -- Pour les voitures, accepter 'car', NULL, vide ou 'vehicle'
        query = 'SELECT * FROM owned_vehicles WHERE owner = @owner AND (type = "car" OR type = "vehicle" OR type IS NULL OR type = "") AND stored = 1'
    end

    MySQL.Async.fetchAll(query, params, function(result)
        if result then
            for i = 1, #result, 1 do
                table.insert(vehicles, {
                    vehicle = json.decode(result[i].vehicle),
                    plate = result[i].plate,
                    stored = result[i].stored
                })
            end
        end

        cb(vehicles)
    end)
end)

-- Ranger un véhicule
ESX.RegisterServerCallback('esx_garage:storeVehicle', function(source, cb, plate, type)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb(false)
        return
    end

    -- Trim la plaque pour éviter les problèmes d'espaces
    plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

    print('^3[ESX GARAGE DEBUG] Tentative de rangement - Plaque: "' .. plate .. '" | Type garage: ' .. type .. '^7')

    -- Vérifier si le véhicule appartient au joueur (sans filtrer par type pour plus de flexibilité)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND TRIM(plate) = @plate', {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = plate
    }, function(result)
        if result and result[1] then
            -- Vérifier que le type du garage correspond au type du véhicule (si défini)
            local vehicleType = result[1].type
            local vehicleTypeDisplay = vehicleType or 'NULL'
            local canStore = false

            print('^3[ESX GARAGE DEBUG] Véhicule trouvé - Type BDD: "' .. vehicleTypeDisplay .. '"^7')

            if type == 'boat' and vehicleType == 'boat' then
                canStore = true
            elseif type == 'plane' and vehicleType == 'aircraft' then
                canStore = true
            elseif type == 'car' and (vehicleType == 'car' or vehicleType == 'vehicle' or vehicleType == nil or vehicleType == '') then
                canStore = true
            end

            if canStore then
                print('^2[ESX GARAGE DEBUG] Rangement autorisé !^7')
                MySQL.Async.execute('UPDATE owned_vehicles SET stored = 1 WHERE owner = @owner AND TRIM(plate) = @plate', {
                    ['@owner'] = xPlayer.identifier,
                    ['@plate'] = plate
                }, function(rowsChanged)
                    cb(true)
                end)
            else
                -- Mauvais type de garage
                print('^1[ESX GARAGE DEBUG] Mauvais type de garage !^7')
                cb(false)
            end
        else
            -- Véhicule pas trouvé ou pas au joueur
            print('^1[ESX GARAGE DEBUG] Véhicule non trouvé dans la BDD !^7')
            cb(false)
        end
    end)
end)

-- Définir l'état du véhicule (sorti ou rangé)
RegisterNetEvent('esx_garage:setVehicleState')
AddEventHandler('esx_garage:setVehicleState', function(plate, state)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    -- Trim la plaque pour éviter les problèmes d'espaces
    plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

    MySQL.Async.execute('UPDATE owned_vehicles SET stored = @stored WHERE owner = @owner AND TRIM(plate) = @plate', {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = plate,
        ['@stored'] = state
    }, function(rowsChanged)
        -- Optionnel : log ou autre
    end)
end)

-- Commande pour voir les véhicules dans la BDD (debug)
RegisterCommand('checkvehicles', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    MySQL.Async.fetchAll('SELECT plate, type, stored FROM owned_vehicles WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier
    }, function(result)
        if result then
            print('^3[ESX GARAGE DEBUG] Véhicules de ' .. xPlayer.getName() .. ':^7')
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 0},
                multiline = true,
                args = {'[DEBUG]', 'Vos véhicules dans la BDD:'}
            })

            for i = 1, #result, 1 do
                local typeStr = result[i].type or 'NULL'
                local storedStr = result[i].stored == 1 and 'Rangé' or 'Sorti'
                print('^3  - Plaque: ' .. result[i].plate .. ' | Type: ' .. typeStr .. ' | État: ' .. storedStr .. '^7')

                TriggerClientEvent('chat:addMessage', source, {
                    color = {255, 255, 0},
                    multiline = false,
                    args = {'[DEBUG]', 'Plaque: ' .. result[i].plate .. ' | Type: ' .. typeStr .. ' | ' .. storedStr}
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                multiline = false,
                args = {'[DEBUG]', 'Aucun véhicule trouvé dans la BDD'}
            })
        end
    end)
end, false)

-- Commande pour ajouter un véhicule de test (pour développement)
if Config.Debug then
    RegisterCommand('addtestcar', function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)

        if not xPlayer then
            return
        end

        local model = args[1] or 'adder'
        local plate = 'TEST' .. math.random(100, 999)

        local vehicleProps = {
            model = GetHashKey(model),
            plate = plate
        }

        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (@owner, @plate, @vehicle, @type, @stored)', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@type'] = 'car',
            ['@stored'] = 1
        }, function(rowsChanged)
            TriggerClientEvent('esx:showNotification', source, 'Véhicule de test ajouté: ' .. model)
        end)
    end, false)

    RegisterCommand('addtestboat', function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)

        if not xPlayer then
            return
        end

        local model = args[1] or 'seashark'
        local plate = 'BOAT' .. math.random(100, 999)

        local vehicleProps = {
            model = GetHashKey(model),
            plate = plate
        }

        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (@owner, @plate, @vehicle, @type, @stored)', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@type'] = 'boat',
            ['@stored'] = 1
        }, function(rowsChanged)
            TriggerClientEvent('esx:showNotification', source, 'Bateau de test ajouté: ' .. model)
        end)
    end, false)

    RegisterCommand('addtestplane', function(source, args, rawCommand)
        local xPlayer = ESX.GetPlayerFromId(source)

        if not xPlayer then
            return
        end

        local model = args[1] or 'luxor'
        local plate = 'AIR' .. math.random(100, 999)

        local vehicleProps = {
            model = GetHashKey(model),
            plate = plate
        }

        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (@owner, @plate, @vehicle, @type, @stored)', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@type'] = 'aircraft',
            ['@stored'] = 1
        }, function(rowsChanged)
            TriggerClientEvent('esx:showNotification', source, 'Avion de test ajouté: ' .. model)
        end)
    end, false)
end

-- Log de démarrage
print('^2[ESX GARAGE]^7 Script de garage chargé avec succès!')
print('^2[ESX GARAGE]^7 Garages disponibles: ' .. #Config.Garages)
