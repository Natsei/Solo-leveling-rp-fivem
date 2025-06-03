--[[
    Solo Leveling FiveM Server
    Rank System Module
    Author: Claude
    Version: 1.0.0
]]

local RankSystem = {}

-- Configuration des rangs
local Ranks = {
    {name = 'E', xpRequired = 0, color = '~g~'},
    {name = 'D', xpRequired = 1000, color = '~b~'},
    {name = 'C', xpRequired = 5000, color = '~p~'},
    {name = 'B', xpRequired = 15000, color = '~r~'},
    {name = 'A', xpRequired = 50000, color = '~o~'},
    {name = 'S', xpRequired = 150000, color = '~y~'},
    {name = 'National', xpRequired = 500000, color = '~r~'}
}

-- Obtenir le rang d'un joueur
function RankSystem.GetPlayerRank(citizenid)
    local result = MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid})
    if result then
        local playerData = json.decode(result)
        return playerData.rank
    end
    return 'E'
end

-- Obtenir l'XP de rang d'un joueur
function RankSystem.GetPlayerRankXP(citizenid)
    local result = MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid})
    if result then
        local playerData = json.decode(result)
        return playerData.rankXP or 0
    end
    return 0
end

-- Ajouter de l'XP de rang
function RankSystem.AddRankXP(citizenid, amount)
    local currentXP = RankSystem.GetPlayerRankXP(citizenid)
    local currentRank = RankSystem.GetPlayerRank(citizenid)
    local newXP = currentXP + amount
    
    -- Vérifier la progression de rang
    for i, rank in ipairs(Ranks) do
        if newXP >= rank.xpRequired and currentRank ~= rank.name then
            -- Mise à jour du rang
            MySQL.Async.execute('UPDATE sl_players SET data = JSON_SET(data, "$.rank", ?) WHERE citizenid = ?',
                {rank.name, citizenid})
            
            -- Notification au joueur
            local src = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            if src then
                TriggerClientEvent('sl-core:client:RankUp', src, rank.name)
            end
        end
    end
    
    -- Mise à jour de l'XP
    MySQL.Async.execute('UPDATE sl_players SET data = JSON_SET(data, "$.rankXP", ?) WHERE citizenid = ?',
        {newXP, citizenid})
end

-- Obtenir les informations du rang suivant
function RankSystem.GetNextRankInfo(currentRank)
    for i, rank in ipairs(Ranks) do
        if rank.name == currentRank and i < #Ranks then
            return Ranks[i + 1]
        end
    end
    return nil
end

-- Vérifier si un joueur peut accéder à un contenu spécifique
function RankSystem.CanAccessContent(citizenid, requiredRank)
    local playerRank = RankSystem.GetPlayerRank(citizenid)
    local playerRankIndex = 0
    local requiredRankIndex = 0
    
    for i, rank in ipairs(Ranks) do
        if rank.name == playerRank then
            playerRankIndex = i
        end
        if rank.name == requiredRank then
            requiredRankIndex = i
        end
    end
    
    return playerRankIndex >= requiredRankIndex
end

return RankSystem 