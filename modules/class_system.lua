--[[
    Solo Leveling FiveM Server
    Class System Module
    Author: Claude
    Version: 1.0.0
]]

local ClassSystem = {}

-- Configuration des classes
local Classes = {
    -- Classes de base
    {
        id = 'tank',
        name = 'Tank',
        description = 'Spécialiste de la défense et de l\'endurance',
        baseStats = {
            strength = 15,
            agility = 8,
            intelligence = 5,
            vitality = 20
        },
        abilities = {
            {id = 'shield_wall', name = 'Mur de Bouclier', cooldown = 30, manaCost = 50},
            {id = 'taunt', name = 'Provocation', cooldown = 15, manaCost = 25}
        }
    },
    {
        id = 'mage',
        name = 'Mage',
        description = 'Maître des arcanes et de la magie élémentaire',
        baseStats = {
            strength = 5,
            agility = 8,
            intelligence = 20,
            vitality = 10
        },
        abilities = {
            {id = 'fireball', name = 'Boule de Feu', cooldown = 5, manaCost = 30},
            {id = 'ice_spike', name = 'Pic de Glace', cooldown = 8, manaCost = 35}
        }
    },
    {
        id = 'swordsman',
        name = 'Épéiste',
        description = 'Expert en combat rapproché',
        baseStats = {
            strength = 15,
            agility = 15,
            intelligence = 5,
            vitality = 12
        },
        abilities = {
            {id = 'slash', name = 'Entaille', cooldown = 3, manaCost = 20},
            {id = 'whirlwind', name = 'Tourbillon', cooldown = 12, manaCost = 40}
        }
    },
    {
        id = 'assassin',
        name = 'Assassin',
        description = 'Maître de la furtivité et des coups critiques',
        baseStats = {
            strength = 12,
            agility = 20,
            intelligence = 8,
            vitality = 8
        },
        abilities = {
            {id = 'stealth', name = 'Furtivité', cooldown = 20, manaCost = 35},
            {id = 'backstab', name = 'Coup dans le Dos', cooldown = 8, manaCost = 30}
        }
    },
    {
        id = 'archer',
        name = 'Archer',
        description = 'Expert en combat à distance',
        baseStats = {
            strength = 10,
            agility = 18,
            intelligence = 10,
            vitality = 10
        },
        abilities = {
            {id = 'precise_shot', name = 'Tir Précis', cooldown = 4, manaCost = 25},
            {id = 'rain_of_arrows', name = 'Pluie de Flèches', cooldown = 15, manaCost = 45}
        }
    },
    {
        id = 'healer',
        name = 'Soigneur',
        description = 'Maître de la guérison et du support',
        baseStats = {
            strength = 5,
            agility = 10,
            intelligence = 15,
            vitality = 15
        },
        abilities = {
            {id = 'heal', name = 'Soin', cooldown = 8, manaCost = 40},
            {id = 'blessing', name = 'Bénédiction', cooldown = 20, manaCost = 50}
        }
    }
}

-- Classes avancées (débloquées via quêtes ou niveaux)
local AdvancedClasses = {
    {
        id = 'paladin',
        name = 'Paladin',
        baseClass = 'tank',
        requiredLevel = 30,
        description = 'Combinaison de force divine et de défense',
        evolutionStats = {
            strength = 5,
            agility = 3,
            intelligence = 8,
            vitality = 5
        },
        newAbilities = {
            {id = 'divine_shield', name = 'Bouclier Divin', cooldown = 45, manaCost = 60},
            {id = 'holy_strike', name = 'Frappe Sainte', cooldown = 12, manaCost = 40}
        }
    },
    {
        id = 'shadow_monarch',
        name = 'Monarque de l\'Ombre',
        baseClass = 'assassin',
        requiredLevel = 40,
        description = 'Maître des ombres et de la mort',
        evolutionStats = {
            strength = 8,
            agility = 5,
            intelligence = 10,
            vitality = 3
        },
        newAbilities = {
            {id = 'shadow_step', name = 'Pas de l\'Ombre', cooldown = 15, manaCost = 45},
            {id = 'death_mark', name = 'Marque de la Mort', cooldown = 30, manaCost = 70}
        }
    }
}

-- Obtenir la classe d'un joueur
function ClassSystem.GetPlayerClass(citizenid)
    local result = MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid})
    if result then
        local playerData = json.decode(result)
        return playerData.class
    end
    return nil
end

-- Définir la classe d'un joueur
function ClassSystem.SetPlayerClass(citizenid, classId)
    local class = nil
    for _, c in ipairs(Classes) do
        if c.id == classId then
            class = c
            break
        end
    end
    
    if class then
        MySQL.Async.execute('UPDATE sl_players SET data = JSON_SET(data, "$.class", ?) WHERE citizenid = ?',
            {json.encode(class), citizenid})
        return true
    end
    return false
end

-- Vérifier si un joueur peut évoluer vers une classe avancée
function ClassSystem.CanEvolveClass(citizenid, advancedClassId)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    local advancedClass = nil
    
    for _, ac in ipairs(AdvancedClasses) do
        if ac.id == advancedClassId then
            advancedClass = ac
            break
        end
    end
    
    if not advancedClass then return false end
    
    return playerData.class.id == advancedClass.baseClass and playerData.level >= advancedClass.requiredLevel
end

-- Évoluer vers une classe avancée
function ClassSystem.EvolveClass(citizenid, advancedClassId)
    if not ClassSystem.CanEvolveClass(citizenid, advancedClassId) then
        return false
    end
    
    local advancedClass = nil
    for _, ac in ipairs(AdvancedClasses) do
        if ac.id == advancedClassId then
            advancedClass = ac
            break
        end
    end
    
    if advancedClass then
        local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
        playerData.class = advancedClass
        
        MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
            {json.encode(playerData), citizenid})
        return true
    end
    return false
end

-- Obtenir les statistiques de base d'une classe
function ClassSystem.GetClassBaseStats(classId)
    for _, class in ipairs(Classes) do
        if class.id == classId then
            return class.baseStats
        end
    end
    return nil
end

-- Obtenir les capacités d'une classe
function ClassSystem.GetClassAbilities(classId)
    for _, class in ipairs(Classes) do
        if class.id == classId then
            return class.abilities
        end
    end
    return nil
end

return ClassSystem 