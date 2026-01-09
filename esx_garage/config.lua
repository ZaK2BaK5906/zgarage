Config = {}

Config.Locale = 'fr'
Config.Debug = false -- Activer pour les commandes de test (/addtestcar, /addtestboat, /addtestplane)

-- Distance d'interaction avec le garage
Config.DrawDistance = 10.0
Config.MarkerDistance = 2.5

-- Configuration des garages
Config.Garages = {
    --──────────────────────────────────────────────────────────────────────────
    -- GARAGES IMPOUND (Fourri\u00e8re)
    --──────────────────────────────────────────────────────────────────────────
    ['Hayes Autos'] = {
        type = 'vehicle',
        isImpound = true,
        coords = vec3(483.75, -1312.29, 29.21),
        spawnPoint = vec4(493.279114, -1329.283569, 29.027100, 328.818909),
        duiText = 'FOURRIERE\nHAYES AUTOS'
    },
    ['Airport Impound Hangar'] = {
        type = 'plane',
        isImpound = true,
        coords = vec3(-1299.520874, -3407.564941, 13.929688),
        spawnPoint = vec4(-1271.512085, -3380.808838, 13.929688, 331.653534),
        duiText = 'FOURRIERE\nHANGAR'
    },
    ['Boat Impound Pier'] = {
        type = 'boat',
        isImpound = true,
        coords = vec3(-858.039551, -1470.685669, 1.629272),
        spawnPoint = vec4(-859.621948, -1476.909912, 0.432983, 291.968506),
        duiText = 'FOURRIERE\nBATEAUX'
    },

    --──────────────────────────────────────────────────────────────────────────
    -- GARAGES VOITURES
    --──────────────────────────────────────────────────────────────────────────
    ['Legion Square'] = {
        type = 'vehicle',
        coords = vec3(215.446167, -809.802185, 30.728882),
        spawnPoint = vec4(232.931870, -790.087891, 29.454932, 158.740158),
        duiText = 'GARAGE\nLEGION SQUARE'
    },
    ['Pillbox Hill Garage'] = {
        type = 'vehicle',
        coords = vec3(100.99, -1071.73, 29.23),
        spawnPoint = vec4(113.87, -1071.64, 28.19, 85.48),
        duiText = 'GARAGE\nPILLBOX HILL'
    },
    ['Vinewood Center'] = {
        type = 'vehicle',
        coords = vec3(70.074722, 12.342858, 68.944336),
        spawnPoint = vec4(75.890114, 19.292309, 67.927490, 158.740158),
        duiText = 'GARAGE\nVINEWOOD'
    },
    ['Penitentiary'] = {
        type = 'vehicle',
        coords = vec3(1899.138428, 2602.852783, 45.742188),
        spawnPoint = vec4(1892.400024, 2601.349365, 44.287231, 269.291351),
        duiText = 'GARAGE\nPRISON'
    },
    ['Motel Parking'] = {
        type = 'vehicle',
        coords = vec3(273.705505, -344.241760, 44.916504),
        spawnPoint = vec4(285.428558, -347.894501, 43.950195, 161.574799),
        duiText = 'GARAGE\nMOTEL'
    },
    ['Spanish Ave Parking'] = {
        type = 'vehicle',
        coords = vec3(-1160.347290, -740.967041, 19.675415),
        spawnPoint = vec4(-1151.973633, -749.512085, 17.929663, 223.937012),
        duiText = 'GARAGE\nSPANISH AVE'
    },
    ['Little Seoul Parking'] = {
        type = 'vehicle',
        coords = vec3(-350.861542, -874.839539, 31.065918),
        spawnPoint = vec4(-357.771423, -883.226379, 29.893042, 0.000000),
        duiText = 'GARAGE\nLITTLE SEOUL'
    },
    ['Laguna Parking'] = {
        type = 'vehicle',
        coords = vec3(364.074738, 297.903290, 103.486450),
        spawnPoint = vec4(367.503296, 296.004395, 102.195654, 348.661407),
        duiText = 'GARAGE\nLAGUNA'
    },
    ['Airport Los Santos'] = {
        type = 'vehicle',
        coords = vec3(-796.865906, -2024.663696, 8.874756),
        spawnPoint = vec4(-790.153870, -2022.949463, 7.719800, 56.692913),
        duiText = 'GARAGE\nAEROPORT'
    },
    ['San Andreas Beach'] = {
        type = 'vehicle',
        coords = vec3(-1183.226318, -1510.958252, 4.359009),
        spawnPoint = vec4(-1183.516479, -1501.912109, 3.254590, 218.267715),
        duiText = 'GARAGE\nBEACH'
    },
    ['The Motor Hotel'] = {
        type = 'vehicle',
        coords = vec3(1142.123047, 2663.934082, 38.159668),
        spawnPoint = vec4(1137.441772, 2654.175781, 36.919409, 0.000000),
        duiText = 'GARAGE\nMOTOR HOTEL'
    },
    ['Alamo Sea Parking'] = {
        type = 'vehicle',
        coords = vec3(959.683533, 3618.975830, 32.666626),
        spawnPoint = vec4(950.703308, 3615.586914, 31.610596, 90.708656),
        duiText = 'GARAGE\nALAMO SEA'
    },
    ['Sandy Shore Parking'] = {
        type = 'vehicle',
        coords = vec3(1737.942871, 3709.199951, 34.132568),
        spawnPoint = vec4(1737.797852, 3718.839600, 32.876538, 19.842520),
        duiText = 'GARAGE\nSANDY SHORES'
    },
    ['Paleto Bay Parking'] = {
        type = 'vehicle',
        coords = vec3(84.725281, 6421.437500, 31.520874),
        spawnPoint = vec4(85.200005, 6427.846191, 30.214307, 45.354328),
        duiText = 'GARAGE\nPALETO BAY'
    },
    ['Elysian Parking'] = {
        type = 'vehicle',
        coords = vec3(204.646149, -3132.843994, 5.774414),
        spawnPoint = vec4(203.498901, -3129.336182, 4.753149, 87.874016),
        duiText = 'GARAGE\nELYSIAN'
    },
    ['Airport Parking'] = {
        type = 'vehicle',
        coords = vec3(-992.281311, -2699.393311, 13.828613),
        spawnPoint = vec4(-982.325256, -2700.131836, 12.660034, 56.692913),
        duiText = 'GARAGE\nAIRPORT'
    },
    ['Centro Parking'] = {
        type = 'vehicle',
        coords = vec3(-352.879120, -676.470337, 32.043213),
        spawnPoint = vec4(-349.028564, -688.101074, 31.628516, 0.000000),
        duiText = 'GARAGE\nCENTRO'
    },
    ['Cypress Flats Parking'] = {
        type = 'vehicle',
        coords = vec3(722.228577, -2016.342896, 29.279907),
        spawnPoint = vec4(740.479126, -2016.553833, 28.291260, 263.622070),
        duiText = 'GARAGE\nCYPRESS FLATS'
    },
    ['El Burro Parking'] = {
        type = 'vehicle',
        coords = vec3(1384.325317, -2079.876953, 52.397827),
        spawnPoint = vec4(1382.320923, -2052.065918, 50.893408, 36.850395),
        duiText = 'GARAGE\nEL BURRO'
    },
    ['La Mesa Parking'] = {
        type = 'vehicle',
        coords = vec3(903.665955, -1575.890137, 30.813232),
        spawnPoint = vec4(871.437378, -1567.081299, 29.488623, 104.881889),
        duiText = 'GARAGE\nLA MESA'
    },
    ['Big Ranch Station'] = {
        type = 'vehicle',
        coords = vec3(345.151642, -1687.424194, 32.515015),
        spawnPoint = vec4(357.125275, -1691.419800, 31.393750, 138.897629),
        duiText = 'GARAGE\nBIG RANCH'
    },
    ['Rancho Garage'] = {
        type = 'vehicle',
        coords = vec3(450.448364, -1981.714233, 24.393433),
        spawnPoint = vec4(461.037354, -1993.648315, 21.888306, 130.393707),
        duiText = 'GARAGE\nRANCHO'
    },
    ['La Mesa Mechanics'] = {
        type = 'vehicle',
        coords = vec3(807.006592, -810.000000, 26.196289),
        spawnPoint = vec4(814.892334, -822.725281, 24.840259, 93.543304),
        duiText = 'GARAGE\nLA MESA MECA'
    },
    ['Mirror Park Parking'] = {
        type = 'vehicle',
        coords = vec3(1038.092285, -764.320862, 57.924561),
        spawnPoint = vec4(1040.676880, -775.608765, 56.822290, 8.503937),
        duiText = 'GARAGE\nMIRROR PARK'
    },
    ['Del Perro Private'] = {
        type = 'vehicle',
        coords = vec3(-1562.742798, -540.210999, 33.593384),
        spawnPoint = vec4(-1542.975830, -564.421997, 24.669653, 36.850395),
        duiText = 'GARAGE\nDEL PERRO'
    },
    ['Vinewood Small Park'] = {
        type = 'vehicle',
        coords = vec3(-570.382446, 311.301086, 84.479858),
        spawnPoint = vec4(-559.345032, 327.336273, 83.374365, 269.291351),
        duiText = 'GARAGE\nVINEWOOD PARK'
    },
    ['Gran Señora Desert'] = {
        type = 'vehicle',
        coords = vec3(180.632965, 2793.375732, 45.640991),
        spawnPoint = vec4(192.290115, 2787.613281, 44.802881, 280.629913),
        duiText = 'GARAGE\nDESERT'
    },
    ['Small Paleto Park'] = {
        type = 'vehicle',
        coords = vec3(-379.556030, 6062.175781, 31.487183),
        spawnPoint = vec4(-398.597809, 6051.204590, 30.515381, 133.228333),
        duiText = 'GARAGE\nPALETO PARK'
    },
    ['Grapeseed Parking'] = {
        type = 'vehicle',
        coords = vec3(2564.320801, 4680.435059, 34.065186),
        spawnPoint = vec4(2550.817627, 4682.188965, 32.740698, 17.007874),
        duiText = 'GARAGE\nGRAPESEED'
    },
    ['Grapeseed Village Park'] = {
        type = 'vehicle',
        coords = vec3(1707.230713, 4791.890137, 41.967773),
        spawnPoint = vec4(1697.195557, 4804.549316, 40.744360, 141.732285),
        duiText = 'GARAGE\nGRAPESEED'
    },

    --──────────────────────────────────────────────────────────────────────────
    -- MARINAS BATEAUX
    --──────────────────────────────────────────────────────────────────────────
    ['La Puerta Pier'] = {
        type = 'boat',
        coords = vec3(-789.1887, -1490.7750, 1.5952),
        spawnPoint = vec4(-796.127441, -1502.109863, 0.112793, 110.551186),
        duiText = 'MARINA\nLA PUERTA'
    },
    ['Paleto Cove Pier'] = {
        type = 'boat',
        coords = vec3(-1605.323120, 5258.281250, 2.067383),
        spawnPoint = vec4(-1600.457153, 5263.279297, 0.348755, 22.677164),
        duiText = 'MARINA\nPALETO COVE'
    },
    ['Paleto Bay Pier'] = {
        type = 'boat',
        coords = vec3(-243.059341, 6598.101074, 7.391968),
        spawnPoint = vec4(-288.553833, 6617.802246, -0.399292, 48.188972),
        duiText = 'MARINA\nPALETO BAY'
    },
    ['Pacific Small Pier'] = {
        type = 'boat',
        coords = vec3(3852.725342, 4459.898926, 1.865234),
        spawnPoint = vec4(3855.388916, 4454.347168, 0.115063, 269.291351),
        duiText = 'MARINA\nPACIFIC'
    },

    --──────────────────────────────────────────────────────────────────────────
    -- HANGARS AVIONS
    --──────────────────────────────────────────────────────────────────────────
    ['Airport Hangar'] = {
        type = 'plane',
        coords = vec3(-940.958252, -2954.043945, 13.929688),
        spawnPoint = vec4(-980.228577, -2997.375732, 12.929688, 59.527554),
        duiText = 'HANGAR\nAIRPORT'
    },
    ['Trevor Hangar'] = {
        type = 'plane',
        coords = vec3(1759.199951, 3298.562744, 41.714966),
        spawnPoint = vec4(1740.224121, 3277.740723, 40.191553, 144.566910),
        duiText = 'HANGAR\nTREVOR'
    },
}

-- Messages
Config.Messages = {
    garage_opened = 'Appuyez sur ~g~E~s~ pour ouvrir le garage',
    no_vehicles = 'Vous n\'avez aucun véhicule dans ce garage',
    vehicle_spawned = 'Véhicule sorti du garage',
    vehicle_stored = 'Véhicule rangé dans le garage',
    not_owned = 'Ce véhicule ne vous appartient pas',
    store_vehicle = 'Appuyez sur ~g~E~s~ pour ranger le véhicule',
}
