--[[
    Solo Leveling FiveM Server
    Core Module
    Author: natsei
    Version: 1.0.0
]]

Core = {}

-- Fonctions utilitaires
function Core.FormatNumber(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

function Core.GetRandomInt(min, max)
    return math.random(min, max)
end

function Core.GetRandomFloat(min, max)
    return min + math.random() * (max - min)
end

function Core.CalculateDistance(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

function Core.IsInRange(x1, y1, z1, x2, y2, z2, range)
    return Core.CalculateDistance(x1, y1, z1, x2, y2, z2) <= range
end

-- Fonctions de progression
function Core.CalculateExpForLevel(level)
    return math.floor(100 * (level ^ 1.5))
end

function Core.CalculateLevelFromExp(exp)
    local level = 1
    while Core.CalculateExpForLevel(level) <= exp do
        level = level + 1
    end
    return level - 1
end

function Core.CalculateExpToNextLevel(currentExp, currentLevel)
    local nextLevelExp = Core.CalculateExpForLevel(currentLevel + 1)
    return nextLevelExp - currentExp
end

-- Fonctions de combat
function Core.CalculateDamage(attackerLevel, attackerStats, defenderLevel, defenderStats)
    local baseDamage = attackerStats.strength * 2
    local levelDiff = attackerLevel - defenderLevel
    local levelMultiplier = 1 + (levelDiff * 0.1)
    local defense = defenderStats.vitality * 0.5
    
    local finalDamage = (baseDamage * levelMultiplier) - defense
    return math.max(1, math.floor(finalDamage))
end

function Core.CalculateCriticalChance(attackerStats)
    return math.min(0.5, attackerStats.agility * 0.01)
end

function Core.CalculateCriticalDamage(attackerStats)
    return 1.5 + (attackerStats.strength * 0.01)
end

-- Fonctions d'items
function Core.CalculateItemValue(item, quality)
    quality = quality or 1
    local baseValue = item.baseValue or 100
    return math.floor(baseValue * quality)
end

function Core.CalculateDropChance(baseChance, luck)
    luck = luck or 0
    return math.min(1, baseChance * (1 + luck * 0.1))
end

-- Fonctions de guilde
function Core.CalculateGuildExp(level)
    return math.floor(1000 * (level ^ 1.8))
end

function Core.CalculateGuildLevel(exp)
    local level = 1
    while Core.CalculateGuildExp(level) <= exp do
        level = level + 1
    end
    return level - 1
end

-- Fonctions de donjon
function Core.CalculateDungeonDifficulty(level)
    return {
        mobHealth = 100 * (1 + level * 0.1),
        mobDamage = 10 * (1 + level * 0.05),
        mobCount = math.floor(3 + level * 0.5),
        bossHealth = 500 * (1 + level * 0.15),
        bossDamage = 50 * (1 + level * 0.1)
    }
end

-- Fonctions de craft
function Core.CalculateCraftingSuccess(level, recipeLevel, quality)
    quality = quality or 1
    local baseChance = 0.5
    local levelDiff = level - recipeLevel
    local levelBonus = math.max(0, levelDiff * 0.05)
    return math.min(1, baseChance + levelBonus + (quality * 0.1))
end

-- Fonctions de localisation
function Core.GetLocalizedText(key, ...)
    local text = Config.Localization.translations[key]
    if not text then return key end
    
    if ... then
        return string.format(text, ...)
    end
    return text
end

-- Fonctions de validation
function Core.IsValidName(name)
    return name and #name >= 3 and #name <= 50
end

function Core.IsValidLevel(level)
    return level and level >= 1 and level <= Config.Server.maxLevel
end

function Core.IsValidGold(amount)
    return amount and amount >= 0
end

-- Fonctions de debug
function Core.Debug(message, ...)
    if Config.Debug then
        print(string.format("[DEBUG] " .. message, ...))
    end
end

return Core 