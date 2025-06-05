--[[
    Solo Leveling FiveM Server
    Power System Module
    Author: natsei
    Version: 1.0.0
]]

local PowerSystem = {}

-- Configuration des types de magie
local MagicTypes = {
    {
        id = 'fire',
        name = 'Feu',
        color = {r = 255, g = 69, b = 0},
        effects = {
            particle = 'core',
            particleName = 'ent_amb_fire_work',
            sound = 'fire_magic',
            damageType = 'fire'
        }
    },
    {
        id = 'ice',
        name = 'Glace',
        color = {r = 0, g = 191, b = 255},
        effects = {
            particle = 'core',
            particleName = 'ent_amb_snow_light',
            sound = 'ice_magic',
            damageType = 'ice'
        }
    },
    {
        id = 'shadow',
        name = 'Ombre',
        color = {r = 75, g = 0, b = 130},
        effects = {
            particle = 'core',
            particleName = 'ent_amb_smoke_factory_white',
            sound = 'shadow_magic',
            damageType = 'dark'
        }
    },
    {
        id = 'lightning',
        name = 'Foudre',
        color = {r = 255, g = 255, b = 0},
        effects = {
            particle = 'core',
            particleName = 'ent_amb_lightning',
            sound = 'lightning_magic',
            damageType = 'lightning'
        }
    },
    {
        id = 'earth',
        name = 'Terre',
        color = {r = 139, g = 69, b = 19},
        effects = {
            particle = 'core',
            particleName = 'ent_amb_dust_cloud',
            sound = 'earth_magic',
            damageType = 'physical'
        }
    },
    {
        id = 'light',
        name = 'Lumière',
        color = {r = 255, g = 255, b = 255},
        effects = {
            particle = 'core',
            particleName = 'ent_amb_light_beam',
            sound = 'light_magic',
            damageType = 'holy'
        }
    },
    {
        id = 'poison',
        name = 'Poison',
        color = {r = 0, g = 255, b = 0},
        effects = {
            particle = 'core',
            particleName = 'ent_amb_smoke_gaswork',
            sound = 'poison_magic',
            damageType = 'poison'
        }
    }
}

-- Configuration des sorts
local Spells = {
    {
        id = 'fireball',
        name = 'Boule de Feu',
        magicType = 'fire',
        manaCost = 30,
        cooldown = 5,
        damage = 50,
        range = 20.0,
        aoe = 3.0,
        level = 1,
        description = 'Lance une boule de feu qui explose à l\'impact'
    },
    {
        id = 'ice_spike',
        name = 'Pic de Glace',
        magicType = 'ice',
        manaCost = 35,
        cooldown = 8,
        damage = 40,
        range = 15.0,
        aoe = 2.0,
        level = 1,
        description = 'Crée un pic de glace qui transperce les ennemis'
    },
    {
        id = 'shadow_bolt',
        name = 'Éclair d\'Ombre',
        magicType = 'shadow',
        manaCost = 40,
        cooldown = 6,
        damage = 45,
        range = 25.0,
        aoe = 0.0,
        level = 1,
        description = 'Lance un éclair d\'ombre qui inflige des dégâts continus'
    },
    {
        id = 'chain_lightning',
        name = 'Éclair en Chaîne',
        magicType = 'lightning',
        manaCost = 50,
        cooldown = 12,
        damage = 35,
        range = 15.0,
        aoe = 5.0,
        level = 1,
        description = 'Un éclair qui rebondit entre les ennemis'
    },
    {
        id = 'earth_spike',
        name = 'Pic de Terre',
        magicType = 'earth',
        manaCost = 45,
        cooldown = 10,
        damage = 55,
        range = 12.0,
        aoe = 4.0,
        level = 1,
        description = 'Fait surgir un pic de terre sous l\'ennemi'
    },
    {
        id = 'holy_beam',
        name = 'Rayon Sacré',
        magicType = 'light',
        manaCost = 60,
        cooldown = 15,
        damage = 70,
        range = 30.0,
        aoe = 0.0,
        level = 1,
        description = 'Un rayon de lumière pure qui brûle les ennemis'
    },
    {
        id = 'poison_cloud',
        name = 'Nuage de Poison',
        magicType = 'poison',
        manaCost = 55,
        cooldown = 20,
        damage = 25,
        range = 10.0,
        aoe = 8.0,
        level = 1,
        description = 'Crée un nuage de poison qui inflige des dégâts continus'
    }
}

-- Sorts appris par les joueurs
local PlayerSpells = {}

-- Apprendre un sort
function PowerSystem.LearnSpell(citizenid, spellId)
    local spell = nil
    for _, s in ipairs(Spells) do
        if s.id == spellId then
            spell = s
            break
        end
    end
    
    if not spell then return false end
    
    if not PlayerSpells[citizenid] then
        PlayerSpells[citizenid] = {}
    end
    
    PlayerSpells[citizenid][spellId] = {
        level = 1,
        lastUsed = 0
    }
    
    return true
end

-- Utiliser un sort
function PowerSystem.CastSpell(citizenid, spellId, target)
    if not PlayerSpells[citizenid] or not PlayerSpells[citizenid][spellId] then
        return false
    end
    
    local spell = nil
    for _, s in ipairs(Spells) do
        if s.id == spellId then
            spell = s
            break
        end
    end
    
    if not spell then return false end
    
    local playerSpell = PlayerSpells[citizenid][spellId]
    local currentTime = os.time()
    
    -- Vérifier le cooldown
    if currentTime - playerSpell.lastUsed < spell.cooldown then
        return false
    end
    
    -- Vérifier le mana
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData or playerData.mana < spell.manaCost then
        return false
    end
    
    -- Appliquer les effets du sort
    local magicType = nil
    for _, mt in ipairs(MagicTypes) do
        if mt.id == spell.magicType then
            magicType = mt
            break
        end
    end
    
    if magicType then
        -- Créer les effets visuels et sonores
        local src = QBCore.Functions.GetPlayerByCitizenId(citizenid)
        if src then
            TriggerClientEvent('sl-core:client:CastSpell', src, {
                spell = spell,
                magicType = magicType,
                target = target
            })
        end
        
        -- Appliquer les dégâts
        if target and target.type == 'mob' then
            -- TODO: Implémenter les dégâts aux mobs
        end
        
        -- Mettre à jour le mana et le cooldown
        playerData.mana = playerData.mana - spell.manaCost
        playerSpell.lastUsed = currentTime
        
        MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
            {json.encode(playerData), citizenid})
        
        return true
    end
    
    return false
end

-- Obtenir les sorts d'un joueur
function PowerSystem.GetPlayerSpells(citizenid)
    return PlayerSpells[citizenid] or {}
end

-- Améliorer un sort
function PowerSystem.UpgradeSpell(citizenid, spellId)
    if not PlayerSpells[citizenid] or not PlayerSpells[citizenid][spellId] then
        return false
    end
    
    local playerSpell = PlayerSpells[citizenid][spellId]
    local spell = nil
    
    for _, s in ipairs(Spells) do
        if s.id == spellId then
            spell = s
            break
        end
    end
    
    if not spell then return false end
    
    -- Vérifier les prérequis pour l'amélioration
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData or playerData.level < (playerSpell.level * 5) then
        return false
    end
    
    -- Améliorer le sort
    playerSpell.level = playerSpell.level + 1
    
    return true
end

return PowerSystem 