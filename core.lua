--[[
    Solo Leveling FiveM Server
    Core System
    Author: Claude
    Version: 1.0.0
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- Configuration
Config = {
    Debug = false,
    DefaultRank = 'E',
    MaxLevel = 100,
    StartingStats = {
        strength = 10,
        agility = 10,
        intelligence = 10,
        vitality = 10
    }
}

-- Module System
local Modules = {}

-- Load all modules
local function LoadModules()
    local moduleFiles = {
        'rank_system',
        'class_system',
        'dungeon_system',
        'power_system',
        'mob_system',
        'guild_system',
        'level_system'
    }

    for _, moduleName in ipairs(moduleFiles) do
        local success, module = pcall(function()
            return LoadResourceFile(GetCurrentResourceName(), 'modules/' .. moduleName .. '.lua')
        end)

        if success and module then
            Modules[moduleName] = load(module)()
            if Config.Debug then
                print('^2[SL-Core] ^7Module chargé: ' .. moduleName)
            end
        else
            print('^1[SL-Core] ^7Erreur lors du chargement du module: ' .. moduleName)
        end
    end
end

-- Initialize the core system
local function Initialize()
    LoadModules()
    
    -- Register server events
    RegisterNetEvent('sl-core:server:InitializePlayer')
    AddEventHandler('sl-core:server:InitializePlayer', function()
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        
        if Player then
            -- Initialize player data
            local playerData = {
                rank = Config.DefaultRank,
                level = 1,
                stats = Config.StartingStats,
                class = nil,
                guild = nil
            }
            
            -- Save to database
            MySQL.Async.execute('INSERT INTO sl_players (citizenid, data) VALUES (?, ?)',
                {Player.PlayerData.citizenid, json.encode(playerData)})
        end
    end)
end

-- Start the system
CreateThread(function()
    Initialize()
    print('^2[SL-Core] ^7Système Solo Leveling initialisé avec succès!')
end)

-- Export functions
exports('GetPlayerRank', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Modules.rank_system.GetPlayerRank(Player.PlayerData.citizenid)
    end
    return nil
end)

exports('GetPlayerClass', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Modules.class_system.GetPlayerClass(Player.PlayerData.citizenid)
    end
    return nil
end) 