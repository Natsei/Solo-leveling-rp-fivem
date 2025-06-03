--[[
    Solo Leveling FiveM Client
    Author: Claude
    Resource: arise
]]

local QBCore = exports['qb-core']:GetCoreObject()
local ESX = nil
if not Config.UIEnabled then
    ESX = exports['es_extended']:getSharedObject()
    -- RageUI doit être dans tes ressources
    if not RageUI then
        RageUI = exports['rageui']:GetRageUI()
    end
end

-- Helper pour NUI/RageUI
local function UseNUI()
    return Config.UIEnabled == nil or Config.UIEnabled == true
end

-- Ouvrir l'interface des pouvoirs
RegisterNetEvent('arise:client:OpenPowerUI', function(class, level)
    if UseNUI() then
        TriggerServerEvent('arise:server:GetPlayerPowers', class, level)
    else
        TriggerServerEvent('arise:server:GetPlayerPowers', class, level, true) -- true = RageUI
    end
end)

RegisterNetEvent('arise:client:ShowPowerUI', function(powerData, useRageUI)
    if UseNUI() and not useRageUI then
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'openPowerUI', powerData = powerData })
    else
        -- Squelette RageUI pour les pouvoirs
        local mainMenu = RageUI.CreateMenu("Pouvoirs", "Vos sorts et passifs")
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while RageUI.Visible(mainMenu) do
                RageUI.IsVisible(mainMenu, true, true, true, function()
                    for _, spell in ipairs(powerData.spells) do
                        RageUI.Button(spell.name, spell.description, {RightLabel = spell.type == 'passive' and "Passif" or "Actif"}, true, {
                            onSelected = function()
                                if spell.type ~= 'passive' then
                                    -- Ici, tu peux déclencher l'utilisation du sort
                                end
                            end
                        })
                    end
                end)
                Citizen.Wait(0)
            end
        end)
    end
end)

RegisterNUICallback('upgradeSpell', function(data, cb)
    TriggerServerEvent('arise:server:UpgradeSpell', data.spellIndex)
    cb('ok')
end)

-- Fermer l'UI (exemple pour toutes les NUI)
RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Ouvrir les autres interfaces (exemples)
RegisterNetEvent('arise:client:OpenLevelUI', function(data)
    if UseNUI() then
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'openLevelUI', stats = data.stats, baseStats = data.baseStats, pointsRemaining = data.pointsRemaining, level = data.level, xp = data.xp, xpToNext = data.xpToNext })
    else
        -- Squelette RageUI pour le menu de stats/niveau
        local mainMenu = RageUI.CreateMenu("Statistiques", "Distribution des points")
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while RageUI.Visible(mainMenu) do
                RageUI.IsVisible(mainMenu, true, true, true, function()
                    RageUI.Separator("Niveau : " .. data.level .. " | XP : " .. data.xp .. "/" .. data.xpToNext)
                    for stat, value in pairs(data.stats) do
                        RageUI.Button(stat, "", {RightLabel = tostring(value)}, true, {})
                    end
                end)
                Citizen.Wait(0)
            end
        end)
    end
end)

RegisterNetEvent('arise:client:OpenClassUI', function(data)
    if UseNUI() then
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'openClassUI', classData = data })
    else
        local mainMenu = RageUI.CreateMenu("Classe", "Votre classe actuelle")
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while RageUI.Visible(mainMenu) do
                RageUI.IsVisible(mainMenu, true, true, true, function()
                    RageUI.Separator(data.name)
                    RageUI.Separator(data.description)
                end)
                Citizen.Wait(0)
            end
        end)
    end
end)

RegisterNetEvent('arise:client:OpenRankUI', function(data)
    if UseNUI() then
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'openRankUI', rankData = data })
    else
        local mainMenu = RageUI.CreateMenu("Rang", "Votre progression de rang")
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while RageUI.Visible(mainMenu) do
                RageUI.IsVisible(mainMenu, true, true, true, function()
                    RageUI.Separator("Rang : " .. data.name)
                    RageUI.Separator("XP Rang : " .. data.xp .. "/" .. data.xpToNext)
                end)
                Citizen.Wait(0)
            end
        end)
    end
end)

RegisterNetEvent('arise:client:OpenDungeonUI', function(data)
    if UseNUI() then
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'openDungeonUI', dungeonData = data })
    else
        local mainMenu = RageUI.CreateMenu("Donjons", "Liste des donjons")
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while RageUI.Visible(mainMenu) do
                RageUI.IsVisible(mainMenu, true, true, true, function()
                    for _, dungeon in ipairs(data.dungeons) do
                        RageUI.Button(dungeon.name, dungeon.desc, {RightLabel = dungeon.info}, true, {})
                    end
                end)
                Citizen.Wait(0)
            end
        end)
    end
end)

RegisterNetEvent('arise:client:OpenGuildUI', function(data)
    if UseNUI() then
        SetNuiFocus(true, true)
        SendNUIMessage({ type = 'openGuildUI', guildData = data })
    else
        local mainMenu = RageUI.CreateMenu("Guilde", "Membres de la guilde")
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            while RageUI.Visible(mainMenu) do
                RageUI.IsVisible(mainMenu, true, true, true, function()
                    for _, member in ipairs(data.members) do
                        RageUI.Button(member.name, member.role, {}, true, {})
                    end
                end)
                Citizen.Wait(0)
            end
        end)
    end
end) 