local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

-- Récupérer les véhicules du joueur
ESX.RegisterServerCallback('esx_garage:getVehicles', function(source, cb, type, isSociety, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb({})
        return
    end

    local vehicles = {}
    local query = ''
    local params = {}

    if isSociety and jobName then
        -- Véhicules d'entreprise (société)
        params = {
            ['@job'] = jobName
        }

        if type == 'boat' then
            query = 'SELECT * FROM owned_vehicles WHERE owner = @job AND type = @type AND stored = 1'
            params['@type'] = 'boat'
        elseif type == 'plane' then
            query = 'SELECT * FROM owned_vehicles WHERE owner = @job AND type = @type AND stored = 1'
            params['@type'] = 'aircraft'
        else
            -- Pour les voitures, accepter 'car', NULL, vide ou 'vehicle'
            query = 'SELECT * FROM owned_vehicles WHERE owner = @job AND (type = "car" OR type = "vehicle" OR type IS NULL OR type = "") AND stored = 1'
        end
    else
        -- Véhicules personnels
        params = {
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
ESX.RegisterServerCallback('esx_garage:storeVehicle', function(source, cb, plate, type, isSociety, jobName)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        cb(false)
        return
    end

    -- Trim la plaque pour éviter les problèmes d'espaces
    plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

    print('^3[ESX GARAGE DEBUG] Tentative de rangement - Plaque: "' .. plate .. '" | Type garage: ' .. type .. '^7')

    -- Déterminer le propriétaire à chercher
    local ownerSearch = xPlayer.identifier
    if isSociety and jobName then
        ownerSearch = jobName -- Chercher les véhicules de l'entreprise
    end

    -- Vérifier si le véhicule appartient au joueur ou à l'entreprise
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE TRIM(plate) = @plate', {
        ['@plate'] = plate
    }, function(result)
        if result and result[1] then
            local vehicleOwner = result[1].owner
            local vehicleType = result[1].type
            local vehicleTypeDisplay = vehicleType or 'NULL'
            local canStore = false

            print('^3[ESX GARAGE DEBUG] Véhicule trouvé - Propriétaire: "' .. vehicleOwner .. '" | Type BDD: "' .. vehicleTypeDisplay .. '"^7')

            -- Vérifier le propriétaire
            local ownerMatch = false
            if isSociety and jobName then
                -- Pour les garages société, accepter les véhicules du job OU du joueur
                ownerMatch = (vehicleOwner == jobName or vehicleOwner == xPlayer.identifier)
            else
                -- Pour les garages perso, seulement les véhicules du joueur
                ownerMatch = (vehicleOwner == xPlayer.identifier)
            end

            if not ownerMatch then
                print('^1[ESX GARAGE DEBUG] Le véhicule n\'appartient pas au joueur/société !^7')
                cb(false)
                return
            end

            -- Vérifier le type de véhicule
            if type == 'boat' and vehicleType == 'boat' then
                canStore = true
            elseif type == 'plane' and vehicleType == 'aircraft' then
                canStore = true
            elseif type == 'vehicle' and (vehicleType == 'car' or vehicleType == 'vehicle' or vehicleType == nil or vehicleType == '') then
                canStore = true
            end

            if canStore then
                print('^2[ESX GARAGE DEBUG] Rangement autorisé !^7')

                -- Si c'est un garage société et que le véhicule appartient au joueur, le transférer à la société
                local newOwner = vehicleOwner
                if isSociety and jobName and vehicleOwner == xPlayer.identifier then
                    newOwner = jobName
                    print('^3[ESX GARAGE DEBUG] Transfert du véhicule vers la société ' .. jobName .. '^7')
                end

                MySQL.Async.execute('UPDATE owned_vehicles SET stored = 1, owner = @newowner WHERE TRIM(plate) = @plate', {
                    ['@newowner'] = newOwner,
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
            -- Véhicule pas trouvé
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

-- Commande pour ajouter un véhicule d'entreprise
RegisterCommand('addsocietycar', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    if not xPlayer.getGroup or xPlayer.getGroup() ~= 'admin' then
        TriggerClientEvent('esx:showNotification', source, '~r~Vous devez être admin')
        return
    end

    local model = args[1]
    local job = args[2]

    if not model or not job then
        TriggerClientEvent('esx:showNotification', source, '~r~Usage: /addsocietycar [modèle] [job]')
        TriggerClientEvent('esx:showNotification', source, '~y~Exemple: /addsocietycar police police')
        return
    end

    local plate = string.upper(job) .. math.random(100, 999)

    local vehicleProps = {
        model = GetHashKey(model),
        plate = plate
    }

    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (@owner, @plate, @vehicle, @type, @stored)', {
        ['@owner'] = job, -- Le job est le propriétaire
        ['@plate'] = plate,
        ['@vehicle'] = json.encode(vehicleProps),
        ['@type'] = 'vehicle',
        ['@stored'] = 1
    }, function(rowsChanged)
        TriggerClientEvent('esx:showNotification', source, '~g~Véhicule d\'entreprise ajouté: ' .. model .. ' [' .. plate .. ']')
        print('^2[ESX GARAGE]^7 Véhicule entreprise ajouté: ' .. model .. ' pour le job ' .. job)
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
