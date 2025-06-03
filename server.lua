--[[
    Solo Leveling FiveM Server
    Author: Claude
    Resource: arise
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- Chargement dynamique des pouvoirs/passifs
function LoadPowersForPlayer(class, level)
    local powers = {}
    local basePath = 'web/power/powers/' .. class .. '/'
    local lvls = {5, 10, 20, 35, 50}
    for i, lvl in ipairs(lvls) do
        if level >= lvl then
            local file = LoadResourceFile(GetCurrentResourceName(), basePath .. 'active' .. i .. '.lua')
            if file then table.insert(powers, assert(load(file))()) end
        end
    end
    for i = 1, 2 do
        local file = LoadResourceFile(GetCurrentResourceName(), basePath .. 'passive' .. i .. '.lua')
        if file then table.insert(powers, assert(load(file))()) end
    end
    return powers
end

RegisterNetEvent('arise:server:GetPlayerPowers', function(class, level, useRageUI)
    local src = source
    local powers = LoadPowersForPlayer(class, level)
    TriggerClientEvent('arise:client:ShowPowerUI', src, {spells = powers, magicType = class}, useRageUI)
end)

RegisterNetEvent('arise:server:UpgradeSpell', function(spellIndex)
    -- Ici, ajoute la logique d'amélioration de sort (mise à jour DB, vérif, etc.)
    -- Tu peux notifier le client du succès/échec si besoin
end) 