--[[
    Solo Leveling FiveM Server
    Level System Module
    Author: Claude
    Version: 1.0.0
]]

local LevelSystem = {}

-- Configuration des niveaux
local LevelConfig = {
    maxLevel = 100,
    baseXP = 100,
    xpMultiplier = 1.5,
    statsPerLevel = {
        strength = 2,
        agility = 2,
        intelligence = 2,
        vitality = 2
    }
}

-- Statistiques de base
local BaseStats = {
    strength = 10,
    agility = 10,
    intelligence = 10,
    vitality = 10
}

-- Calculer l'XP nécessaire pour un niveau
function LevelSystem.GetRequiredXP(level)
    return math.floor(LevelConfig.baseXP * (level - 1) * LevelConfig.xpMultiplier)
end

-- Ajouter de l'XP à un joueur
function LevelSystem.AddXP(citizenid, amount)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData then return false end
    
    playerData.xp = playerData.xp + amount
    
    -- Vérifier la montée de niveau
    while playerData.level < LevelConfig.maxLevel do
        local requiredXP = LevelSystem.GetRequiredXP(playerData.level + 1)
        if playerData.xp >= requiredXP then
            playerData.level = playerData.level + 1
            playerData.xp = playerData.xp - requiredXP
            
            -- Augmenter les statistiques
            for stat, value in pairs(LevelConfig.statsPerLevel) do
                playerData.stats[stat] = (playerData.stats[stat] or BaseStats[stat]) + value
            end
            
            -- Notifier le joueur
            local src = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            if src then
                TriggerClientEvent('sl-core:client:LevelUp', src, playerData.level)
            end
        else
            break
        end
    end
    
    -- Sauvegarder les données
    MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
        {json.encode(playerData), citizenid})
    
    return true
end

-- Obtenir le niveau d'un joueur
function LevelSystem.GetPlayerLevel(citizenid)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData then return 1 end
    
    return playerData.level or 1
end

-- Obtenir l'XP d'un joueur
function LevelSystem.GetPlayerXP(citizenid)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData then return 0 end
    
    return playerData.xp or 0
end

-- Obtenir les statistiques d'un joueur
function LevelSystem.GetPlayerStats(citizenid)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData then return BaseStats end
    
    return playerData.stats or BaseStats
end

-- Augmenter une statistique
function LevelSystem.IncreaseStat(citizenid, stat, amount)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData then return false end
    
    if not playerData.stats then
        playerData.stats = BaseStats
    end
    
    playerData.stats[stat] = (playerData.stats[stat] or BaseStats[stat]) + amount
    
    -- Sauvegarder les données
    MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
        {json.encode(playerData), citizenid})
    
    return true
end

-- Calculer les dégâts basés sur les statistiques
function LevelSystem.CalculateDamage(citizenid, baseDamage)
    local stats = LevelSystem.GetPlayerStats(citizenid)
    local level = LevelSystem.GetPlayerLevel(citizenid)
    
    -- Formule de dégâts : baseDamage * (1 + (force/100)) * (1 + (niveau/50))
    return math.floor(baseDamage * (1 + (stats.strength / 100)) * (1 + (level / 50)))
end

-- Calculer la défense basée sur les statistiques
function LevelSystem.CalculateDefense(citizenid, baseDefense)
    local stats = LevelSystem.GetPlayerStats(citizenid)
    local level = LevelSystem.GetPlayerLevel(citizenid)
    
    -- Formule de défense : baseDefense * (1 + (vitalité/100)) * (1 + (niveau/50))
    return math.floor(baseDefense * (1 + (stats.vitality / 100)) * (1 + (level / 50)))
end

-- Calculer la vitesse basée sur les statistiques
function LevelSystem.CalculateSpeed(citizenid, baseSpeed)
    local stats = LevelSystem.GetPlayerStats(citizenid)
    
    -- Formule de vitesse : baseSpeed * (1 + (agilité/200))
    return baseSpeed * (1 + (stats.agility / 200))
end

-- Calculer le mana basé sur les statistiques
function LevelSystem.CalculateMana(citizenid, baseMana)
    local stats = LevelSystem.GetPlayerStats(citizenid)
    local level = LevelSystem.GetPlayerLevel(citizenid)
    
    -- Formule de mana : baseMana * (1 + (intelligence/100)) * (1 + (niveau/50))
    return math.floor(baseMana * (1 + (stats.intelligence / 100)) * (1 + (level / 50)))
end

-- Réinitialiser les statistiques d'un joueur
function LevelSystem.ResetStats(citizenid)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData then return false end
    
    playerData.stats = BaseStats
    
    -- Sauvegarder les données
    MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
        {json.encode(playerData), citizenid})
    
    return true
end

return LevelSystem 