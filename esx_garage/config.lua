Config = {}

Config.Locale = 'fr'
Config.Debug = false -- Activer pour les commandes de test (/addtestcar, /addtestboat, /addtestplane)

-- Distance d'interaction avec le garage
Config.DrawDistance = 10.0
Config.MarkerDistance = 2.5

-- Couleur du texte DUI
Config.DUIColor = {r = 255, g = 255, b = 255, a = 255}

-- IPL de garage pour la téléportation
Config.GarageIPL = {
    Interior = vector4(223.22, -967.44, -99.87, 0.0), -- Intérieur du garage (sous-sol)
    SpawnPoint = vector4(228.5, -981.5, -99.0, 180.0), -- Point de spawn du véhicule
    ExitPoint = vector4(224.5, -967.5, -99.0, 90.0) -- Point de sortie
}

-- IPL de garage pour bateaux
Config.BoatGarageIPL = {
    Interior = vector4(-795.0, -1510.0, 1.6, 110.0), -- Marina
    SpawnPoint = vector4(-798.0, -1513.0, 0.0, 110.0),
    ExitPoint = vector4(-795.0, -1510.0, 1.6, 110.0)
}

-- IPL de garage pour avions
Config.PlaneGarageIPL = {
    Interior = vector4(-1267.0, -3013.0, 13.94, 330.0), -- Hangar
    SpawnPoint = vector4(-1272.0, -3016.0, 13.94, 330.0),
    ExitPoint = vector4(-1267.0, -3013.0, 13.94, 330.0)
}

-- Configuration des garages
Config.Garages = {
    -- GARAGES VOITURES
    {
        name = 'Garage Centre-Ville',
        type = 'car', -- car, boat, plane
        coords = vector3(215.8, -810.1, 30.7),
        heading = 160.0,
        spawnPoint = vector4(229.7, -800.1, 30.5, 160.0),
        duiText = 'GARAGE\nVOITURES'
    },
    {
        name = 'Garage Legion Square',
        type = 'car',
        coords = vector3(213.6, -791.5, 30.8),
        heading = 340.0,
        spawnPoint = vector4(218.5, -781.5, 30.6, 340.0),
        duiText = 'GARAGE\nVOITURES'
    },
    {
        name = 'Garage Vespucci',
        type = 'car',
        coords = vector3(-340.0, -874.8, 31.3),
        heading = 170.0,
        spawnPoint = vector4(-348.5, -874.3, 31.3, 170.0),
        duiText = 'GARAGE\nVOITURES'
    },
    {
        name = 'Garage Sandy Shores',
        type = 'car',
        coords = vector3(1737.6, 3710.2, 34.1),
        heading = 20.0,
        spawnPoint = vector4(1737.9, 3718.5, 34.0, 20.0),
        duiText = 'GARAGE\nVOITURES'
    },
    {
        name = 'Garage Paleto Bay',
        type = 'car',
        coords = vector3(105.4, 6613.7, 31.9),
        heading = 222.0,
        spawnPoint = vector4(110.5, 6607.8, 31.9, 222.0),
        duiText = 'GARAGE\nVOITURES'
    },

    -- GARAGES BATEAUX
    {
        name = 'Marina Vespucci',
        type = 'boat',
        coords = vector3(-795.0, -1510.6, 1.6),
        heading = 110.0,
        spawnPoint = vector4(-798.7, -1513.5, 0.0, 110.0),
        duiText = 'MARINA\nBATEAUX'
    },
    {
        name = 'Marina Paleto Bay',
        type = 'boat',
        coords = vector3(-283.4, 6637.0, 7.5),
        heading = 45.0,
        spawnPoint = vector4(-289.5, 6637.5, 0.0, 45.0),
        duiText = 'MARINA\nBATEAUX'
    },
    {
        name = 'Marina Sandy Shores',
        type = 'boat',
        coords = vector3(1334.0, 4265.0, 31.5),
        heading = 260.0,
        spawnPoint = vector4(1334.5, 4264.5, 29.0, 260.0),
        duiText = 'MARINA\nBATEAUX'
    },

    -- GARAGES AVIONS
    {
        name = 'Hangar LSIA',
        type = 'plane',
        coords = vector3(-1267.0, -3013.1, 13.9),
        heading = 330.0,
        spawnPoint = vector4(-1272.5, -3016.5, 13.94, 330.0),
        duiText = 'HANGAR\nAVIONS'
    },
    {
        name = 'Aérodrome Sandy Shores',
        type = 'plane',
        coords = vector3(1737.0, 3296.0, 41.2),
        heading = 195.0,
        spawnPoint = vector4(1741.5, 3299.5, 41.1, 195.0),
        duiText = 'AERODROME\nAVIONS'
    },
    {
        name = 'Héliport Hôpital',
        type = 'plane',
        coords = vector3(313.4, -1465.0, 46.5),
        heading = 140.0,
        spawnPoint = vector4(313.5, -1465.5, 46.5, 140.0),
        duiText = 'HELIPORT\nHELICOS'
    },
}

-- Messages
Config.Messages = {
    garage_opened = 'Appuyez sur ~g~E~s~ pour ouvrir le garage',
    no_vehicles = 'Vous n\'avez aucun véhicule dans ce garage',
    vehicle_spawned = 'Véhicule sorti du garage',
    vehicle_stored = 'Véhicule rangé dans le garage',
    already_out = 'Ce véhicule est déjà sorti',
    not_owned = 'Ce véhicule ne vous appartient pas',
    store_vehicle = 'Appuyez sur ~g~E~s~ pour ranger le véhicule',
}
