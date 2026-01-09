fx_version 'cerulean'
game 'gta5'

author 'ESX Garage Script'
description 'Système de garage simple avec ox_lib pour véhicules, bateaux et avions'
version '2.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'oxmysql',
    'ox_lib'
}

lua54 'yes'
