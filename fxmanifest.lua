--[[
    Solo Leveling FiveM Server
    Resource Manifest
    Author: Claude
    Version: 1.0.0
]]

fx_version 'cerulean'
game 'gta5'

author 'natsei'
description 'Solo Leveling RPG System for FiveM'
version '1.0.0'

-- Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'modules/*.lua',
    'server.lua'
}

client_scripts {
    'config.lua',
    'client.lua'
}

shared_scripts {
    'config.lua',
    'core.lua'
}

-- Fichiers
files {
    'web/index.html',
    'web/style.css',
    'web/script.js'
}

-- Dépendances
dependencies {
    'oxmysql'
}

-- Configuration
lua54 'yes' 
