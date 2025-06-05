--[[
    Solo Leveling FiveM Server
    Server Module
    Author: natsei
    Version: 1.0.0
]]

-- Initialisation des modules
local ClassSystem = LoadResourceFile(GetCurrentResourceName(), 'modules/class_system.lua')
local QuestSystem = LoadResourceFile(GetCurrentResourceName(), 'modules/quest_system.lua')
local InventorySystem = LoadResourceFile(GetCurrentResourceName(), 'modules/inventory_system.lua')
local CraftingSystem = LoadResourceFile(GetCurrentResourceName(), 'modules/crafting_system.lua')
local TradingSystem = LoadResourceFile(GetCurrentResourceName(), 'modules/trading_system.lua')
local NotificationSystem = LoadResourceFile(GetCurrentResourceName(), 'modules/notification_system.lua')
local LogSystem = LoadResourceFile(GetCurrentResourceName(), 'modules/log_system.lua')
local LocalizationSystem = LoadResourceFile(GetCurrentResourceName(), 'modules/localization_system.lua')

-- Chargement des modules
ClassSystem = load(ClassSystem)()
QuestSystem = load(QuestSystem)()
InventorySystem = load(InventorySystem)()
CraftingSystem = load(CraftingSystem)()
TradingSystem = load(TradingSystem)()
NotificationSystem = load(NotificationSystem)()
LogSystem = load(LogSystem)()
LocalizationSystem = load(LocalizationSystem)()

-- Initialisation du joueur
RegisterNetEvent('sl:server:InitializePlayer')
AddEventHandler('sl:server:InitializePlayer', function()
    local src = source
    local citizenid = GetPlayerIdentifier(src, 0)
    
    -- Vérifier si le joueur existe déjà
    local result = MySQL.Sync.fetchScalar('SELECT id FROM sl_players WHERE citizenid = ?', {citizenid})
    
    if not result then
        -- Créer un nouveau joueur
        MySQL.Async.execute('INSERT INTO sl_players (citizenid, name, level, exp, gold, class, data, inventory, language) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            {
                citizenid,
                GetPlayerName(src),
                1,
                0,
                Config.Server.startingGold,
                nil,
                json.encode({}),
                json.encode({}),
                Config.Localization.defaultLanguage
            })
        
        LogSystem.CreateLog('info', 'player', 'Nouveau joueur créé: ' .. citizenid)
    end
    
    -- Envoyer les données au client
    local playerData = MySQL.Sync.fetchAll('SELECT * FROM sl_players WHERE citizenid = ?', {citizenid})[1]
    TriggerClientEvent('sl:client:InitializePlayer', src, playerData)
end)

-- Gestion des quêtes
RegisterNetEvent('sl:server:StartQuest')
AddEventHandler('sl:server:StartQuest', function(questId)
    local src = source
    local citizenid = GetPlayerIdentifier(src, 0)
    
    if QuestSystem.StartQuest(citizenid, questId) then
        NotificationSystem.SendNotification(citizenid, 'quest_start', questId)
        LogSystem.CreateLog('info', 'quest', 'Joueur ' .. citizenid .. ' a commencé la quête: ' .. questId)
    end
end)

RegisterNetEvent('sl:server:UpdateQuestProgress')
AddEventHandler('sl:server:UpdateQuestProgress', function(questId, objectiveType, target, amount)
    local src = source
    local citizenid = GetPlayerIdentifier(src, 0)
    
    if QuestSystem.UpdateQuestProgress(citizenid, questId, objectiveType, target, amount) then
        LogSystem.CreateLog('info', 'quest', 'Joueur ' .. citizenid .. ' a progressé dans la quête: ' .. questId)
    end
end)

-- Gestion de l'inventaire
RegisterNetEvent('sl:server:UseItem')
AddEventHandler('sl:server:UseItem', function(itemId, itemInstanceId)
    local src = source
    local citizenid = GetPlayerIdentifier(src, 0)
    
    if InventorySystem.UseItem(citizenid, itemId, itemInstanceId) then
        LogSystem.CreateLog('info', 'inventory', 'Joueur ' .. citizenid .. ' a utilisé l\'item: ' .. itemId)
    end
end)

-- Gestion du crafting
RegisterNetEvent('sl:server:StartCrafting')
AddEventHandler('sl:server:StartCrafting', function(recipeId)
    local src = source
    local citizenid = GetPlayerIdentifier(src, 0)
    
    if CraftingSystem.StartCrafting(citizenid, recipeId) then
        NotificationSystem.SendNotification(citizenid, 'crafting_start', recipeId)
        LogSystem.CreateLog('info', 'crafting', 'Joueur ' .. citizenid .. ' a commencé le crafting: ' .. recipeId)
    end
end)

-- Gestion du commerce
RegisterNetEvent('sl:server:BuyItem')
AddEventHandler('sl:server:BuyItem', function(shopId, itemId, amount)
    local src = source
    local citizenid = GetPlayerIdentifier(src, 0)
    
    if TradingSystem.BuyItem(citizenid, shopId, itemId, amount) then
        NotificationSystem.SendNotification(citizenid, 'item_bought', itemId, amount)
        LogSystem.CreateLog('info', 'trading', 'Joueur ' .. citizenid .. ' a acheté: ' .. amount .. 'x ' .. itemId)
    end
end)

-- Commandes administrateur
RegisterCommand('setlevel', function(source, args)
    if IsPlayerAceAllowed(source, 'command.setlevel') then
        local targetId = tonumber(args[1])
        local level = tonumber(args[2])
        
        if targetId and level and Core.IsValidLevel(level) then
            local citizenid = GetPlayerIdentifier(targetId, 0)
            MySQL.Async.execute('UPDATE sl_players SET level = ? WHERE citizenid = ?', {level, citizenid})
            NotificationSystem.SendNotification(citizenid, 'level_set', level)
            LogSystem.CreateLog('admin', 'level', 'Admin a défini le niveau de ' .. citizenid .. ' à ' .. level)
        end
    end
end)

-- Commandes joueur
RegisterCommand('class', function(source)
    local citizenid = GetPlayerIdentifier(source, 0)
    local class = ClassSystem.GetPlayerClass(citizenid)
    if class then
        TriggerClientEvent('sl:client:ShowClassInfo', source, class)
    end
end)

RegisterCommand('inventory', function(source)
    local citizenid = GetPlayerIdentifier(source, 0)
    local inventory = InventorySystem.GetPlayerInventory(citizenid)
    TriggerClientEvent('sl:client:ShowInventory', source, inventory)
end)

-- Initialisation
CreateThread(function()
    -- Créer les dossiers nécessaires
    os.execute('mkdir logs 2>nul')
    
    -- Nettoyer les vieux logs
    LogSystem.CleanOldLogs()
    
    print('^2[SL-Server] ^7Système Solo Leveling initialisé avec succès!')
end) 