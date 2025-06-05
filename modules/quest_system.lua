--[[
    Solo Leveling FiveM Server
    Quest System Module
    Author: natsei
    Version: 1.0.0
]]

local QuestSystem = {}

-- Configuration des quêtes
local Quests = {
    {
        id = 'quest_001',
        name = 'Début du Voyage',
        description = 'Commencez votre aventure en parlant au guide du village',
        level = 1,
        type = 'main',
        rewards = {
            exp = 100,
            gold = 50,
            items = {
                {id = 'item_001', amount = 1}
            }
        },
        objectives = {
            {
                type = 'talk',
                target = 'npc_guide',
                description = 'Parler au guide du village'
            }
        }
    },
    {
        id = 'quest_002',
        name = 'Chasse aux Monstres',
        description = 'Éliminez 5 monstres dans la forêt',
        level = 5,
        type = 'daily',
        rewards = {
            exp = 200,
            gold = 100,
            items = {
                {id = 'item_002', amount = 2}
            }
        },
        objectives = {
            {
                type = 'kill',
                target = 'monster_001',
                amount = 5,
                description = 'Éliminer 5 monstres'
            }
        }
    }
}

-- Obtenir les quêtes disponibles pour un joueur
function QuestSystem.GetAvailableQuests(citizenid)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    local availableQuests = {}
    
    for _, quest in ipairs(Quests) do
        if playerData.level >= quest.level and not QuestSystem.IsQuestCompleted(citizenid, quest.id) then
            table.insert(availableQuests, quest)
        end
    end
    
    return availableQuests
end

-- Vérifier si une quête est complétée
function QuestSystem.IsQuestCompleted(citizenid, questId)
    local result = MySQL.Sync.fetchScalar('SELECT completed_quests FROM sl_players WHERE citizenid = ?', {citizenid})
    if result then
        local completedQuests = json.decode(result)
        return completedQuests[questId] == true
    end
    return false
end

-- Démarrer une quête
function QuestSystem.StartQuest(citizenid, questId)
    local quest = nil
    for _, q in ipairs(Quests) do
        if q.id == questId then
            quest = q
            break
        end
    end
    
    if not quest then return false end
    
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData.active_quests then
        playerData.active_quests = {}
    end
    
    playerData.active_quests[questId] = {
        progress = {},
        started_at = os.time()
    }
    
    MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
        {json.encode(playerData), citizenid})
    
    return true
end

-- Mettre à jour la progression d'une quête
function QuestSystem.UpdateQuestProgress(citizenid, questId, objectiveType, target, amount)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData.active_quests or not playerData.active_quests[questId] then
        return false
    end
    
    local quest = nil
    for _, q in ipairs(Quests) do
        if q.id == questId then
            quest = q
            break
        end
    end
    
    if not quest then return false end
    
    local objective = nil
    for _, obj in ipairs(quest.objectives) do
        if obj.type == objectiveType and obj.target == target then
            objective = obj
            break
        end
    end
    
    if not objective then return false end
    
    if not playerData.active_quests[questId].progress[objectiveType] then
        playerData.active_quests[questId].progress[objectiveType] = {}
    end
    
    if not playerData.active_quests[questId].progress[objectiveType][target] then
        playerData.active_quests[questId].progress[objectiveType][target] = 0
    end
    
    playerData.active_quests[questId].progress[objectiveType][target] = 
        playerData.active_quests[questId].progress[objectiveType][target] + amount
    
    -- Vérifier si la quête est complétée
    if QuestSystem.IsQuestFullyCompleted(playerData.active_quests[questId], quest) then
        QuestSystem.CompleteQuest(citizenid, questId)
    end
    
    MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
        {json.encode(playerData), citizenid})
    
    return true
end

-- Vérifier si une quête est entièrement complétée
function QuestSystem.IsQuestFullyCompleted(questProgress, quest)
    for _, objective in ipairs(quest.objectives) do
        if not questProgress.progress[objective.type] or
           not questProgress.progress[objective.type][objective.target] or
           questProgress.progress[objective.type][objective.target] < objective.amount then
            return false
        end
    end
    return true
end

-- Compléter une quête
function QuestSystem.CompleteQuest(citizenid, questId)
    local quest = nil
    for _, q in ipairs(Quests) do
        if q.id == questId then
            quest = q
            break
        end
    end
    
    if not quest then return false end
    
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    
    -- Ajouter les récompenses
    playerData.exp = playerData.exp + quest.rewards.exp
    playerData.gold = playerData.gold + quest.rewards.gold
    
    if quest.rewards.items then
        for _, item in ipairs(quest.rewards.items) do
            -- Ajouter l'item à l'inventaire du joueur
            -- TODO: Implémenter l'ajout d'items
        end
    end
    
    -- Marquer la quête comme complétée
    if not playerData.completed_quests then
        playerData.completed_quests = {}
    end
    playerData.completed_quests[questId] = true
    
    -- Supprimer la quête des quêtes actives
    if playerData.active_quests then
        playerData.active_quests[questId] = nil
    end
    
    MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
        {json.encode(playerData), citizenid})
    
    return true
end

return QuestSystem 