--[[
    Solo Leveling FiveM Server
    Client Module
    Author: natsei
    Version: 1.0.0
]]

-- Variables locales
local PlayerData = nil
local IsInitialized = false

-- Initialisation du joueur
RegisterNetEvent('sl:client:InitializePlayer')
AddEventHandler('sl:client:InitializePlayer', function(data)
    PlayerData = data
    IsInitialized = true
    
    -- Initialiser l'interface utilisateur
    SendNUIMessage({
        type = 'initialize',
        data = {
            level = PlayerData.level,
            exp = PlayerData.exp,
            gold = PlayerData.gold,
            class = PlayerData.class
        }
    })
    
    -- Afficher la notification de bienvenue
    ShowNotification('success', 'Bienvenue', 'Bienvenue dans Solo Leveling !')
end)

-- Gestion des notifications
RegisterNetEvent('sl:client:ShowNotification')
AddEventHandler('sl:client:ShowNotification', function(data)
    ShowNotification(data.type, data.title, data.message)
end)

function ShowNotification(type, title, message)
    SendNUIMessage({
        type = 'notification',
        data = {
            type = type,
            title = title,
            message = message
        }
    })
end

-- Gestion de l'interface utilisateur
RegisterNetEvent('sl:client:ShowClassInfo')
AddEventHandler('sl:client:ShowClassInfo', function(classData)
    SendNUIMessage({
        type = 'showClassInfo',
        data = classData
    })
end)

RegisterNetEvent('sl:client:ShowInventory')
AddEventHandler('sl:client:ShowInventory', function(inventory)
    SendNUIMessage({
        type = 'showInventory',
        data = inventory
    })
end)

-- Gestion des quêtes
RegisterNetEvent('sl:client:UpdateQuestProgress')
AddEventHandler('sl:client:UpdateQuestProgress', function(questId, progress)
    SendNUIMessage({
        type = 'updateQuestProgress',
        data = {
            questId = questId,
            progress = progress
        }
    })
end)

-- Gestion du combat
local function HandleCombat()
    if not IsInitialized then return end
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    -- Vérifier les entités à proximité
    local entities = GetGamePool('CPed')
    for _, entity in ipairs(entities) do
        if not IsPedAPlayer(entity) and not IsEntityDead(entity) then
            local entityCoords = GetEntityCoords(entity)
            local distance = #(coords - entityCoords)
            
            if distance < 2.0 then
                -- Démarrer le combat
                if IsControlJustPressed(0, 24) then -- Clic gauche
                    TriggerServerEvent('sl:server:StartCombat', NetworkGetNetworkIdFromEntity(entity))
                end
            end
        end
    end
end

-- Gestion des donjons
local function HandleDungeons()
    if not IsInitialized then return end
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    -- Vérifier les portails de donjon à proximité
    for _, dungeon in pairs(Config.Dungeons) do
        local dungeonCoords = vector3(dungeon.coords.x, dungeon.coords.y, dungeon.coords.z)
        local distance = #(coords - dungeonCoords)
        
        if distance < 5.0 then
            -- Afficher le marqueur
            DrawMarker(1, dungeonCoords.x, dungeonCoords.y, dungeonCoords.z - 1.0,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                1.0, 1.0, 1.0, 255, 0, 0, 100,
                false, true, 2, false, nil, nil, false)
            
            -- Afficher le texte
            DrawText3D(dungeonCoords.x, dungeonCoords.y, dungeonCoords.z, dungeon.name)
            
            -- Entrer dans le donjon
            if IsControlJustPressed(0, 38) then -- E
                if PlayerData.level >= dungeon.minLevel then
                    TriggerServerEvent('sl:server:EnterDungeon', dungeon.id)
                else
                    ShowNotification('error', 'Niveau insuffisant', 'Vous devez être niveau ' .. dungeon.minLevel .. ' pour entrer dans ce donjon.')
                end
            end
        end
    end
end

-- Fonctions utilitaires
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

-- Boucle principale
CreateThread(function()
    while true do
        Wait(0)
        
        if IsInitialized then
            HandleCombat()
            HandleDungeons()
        end
    end
end)

-- Initialisation
CreateThread(function()
    -- Attendre que le joueur soit chargé
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(100)
    end
    
    -- Demander l'initialisation au serveur
    TriggerServerEvent('sl:server:InitializePlayer')
end) 