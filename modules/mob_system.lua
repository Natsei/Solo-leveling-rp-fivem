--[[
    Solo Leveling FiveM Server
    Mob System Module
    Author: natsei
    Version: 1.0.0
]]

local MobSystem = {}

-- Configuration des types de mobs
local MobTypes = {
    {
        id = 'goblin',
        name = 'Gobelin',
        model = 'a_m_m_bevhills_01',
        health = 100,
        damage = 10,
        defense = 5,
        speed = 1.0,
        xp = 50,
        rankXp = 25,
        drops = {
            {item = 'goblin_ear', chance = 0.5, min = 1, max = 2},
            {item = 'goblin_coin', chance = 0.3, min = 1, max = 3}
        },
        abilities = {
            {id = 'quick_attack', cooldown = 3, damage = 15}
        }
    },
    {
        id = 'wolf',
        name = 'Loup',
        model = 'a_c_wolf',
        health = 80,
        damage = 15,
        defense = 3,
        speed = 1.2,
        xp = 40,
        rankXp = 20,
        drops = {
            {item = 'wolf_fang', chance = 0.4, min = 1, max = 2},
            {item = 'wolf_pelt', chance = 0.6, min = 1, max = 1}
        },
        abilities = {
            {id = 'pounce', cooldown = 5, damage = 20}
        }
    },
    {
        id = 'skeleton',
        name = 'Squelette',
        model = 'a_m_m_bevhills_02',
        health = 120,
        damage = 12,
        defense = 8,
        speed = 0.9,
        xp = 60,
        rankXp = 30,
        drops = {
            {item = 'skeleton_bone', chance = 0.7, min = 1, max = 3},
            {item = 'ancient_coin', chance = 0.2, min = 1, max = 2}
        },
        abilities = {
            {id = 'bone_throw', cooldown = 4, damage = 18}
        }
    },
    {
        id = 'zombie',
        name = 'Zombie',
        model = 'a_m_m_bevhills_01',
        health = 150,
        damage = 15,
        defense = 10,
        speed = 0.8,
        xp = 70,
        rankXp = 35,
        drops = {
            {item = 'zombie_heart', chance = 0.5, min = 1, max = 2},
            {item = 'rotten_flesh', chance = 0.8, min = 1, max = 3}
        },
        abilities = {
            {id = 'infect', cooldown = 8, damage = 25}
        }
    },
    {
        id = 'shadow_warrior',
        name = 'Guerrier de l\'Ombre',
        model = 'a_m_m_bevhills_01',
        health = 200,
        damage = 20,
        defense = 15,
        speed = 1.1,
        xp = 100,
        rankXp = 50,
        drops = {
            {item = 'shadow_crystal', chance = 0.6, min = 1, max = 2},
            {item = 'dark_essence', chance = 0.4, min = 1, max = 3}
        },
        abilities = {
            {id = 'shadow_slash', cooldown = 6, damage = 30},
            {id = 'dark_aura', cooldown = 15, damage = 20}
        }
    },
    {
        id = 'dark_mage',
        name = 'Mage Noir',
        model = 'a_m_m_bevhills_01',
        health = 150,
        damage = 25,
        defense = 8,
        speed = 0.9,
        xp = 120,
        rankXp = 60,
        drops = {
            {item = 'dark_essence', chance = 0.7, min = 1, max = 3},
            {item = 'magic_crystal', chance = 0.5, min = 1, max = 2}
        },
        abilities = {
            {id = 'dark_bolt', cooldown = 4, damage = 35},
            {id = 'shadow_burst', cooldown = 12, damage = 45}
        }
    }
}

-- Mobs actifs dans le monde
local ActiveMobs = {}

-- Spawn un mob
function MobSystem.SpawnMob(mobType, position, level)
    local mobConfig = nil
    for _, m in ipairs(MobTypes) do
        if m.id == mobType then
            mobConfig = m
            break
        end
    end
    
    if not mobConfig then return nil end
    
    local mobId = #ActiveMobs + 1
    local scaledHealth = mobConfig.health * (1 + (level - 1) * 0.1)
    local scaledDamage = mobConfig.damage * (1 + (level - 1) * 0.1)
    local scaledDefense = mobConfig.defense * (1 + (level - 1) * 0.1)
    
    ActiveMobs[mobId] = {
        type = mobType,
        level = level,
        health = scaledHealth,
        maxHealth = scaledHealth,
        damage = scaledDamage,
        defense = scaledDefense,
        position = position,
        target = nil,
        lastAbilityUse = {},
        state = 'idle'
    }
    
    -- Notifier les joueurs à proximité
    local players = QBCore.Functions.GetPlayers()
    for _, player in ipairs(players) do
        local playerPed = GetPlayerPed(player)
        local playerPos = GetEntityCoords(playerPed)
        if #(playerPos - position) < 50.0 then
            TriggerClientEvent('sl-core:client:MobSpawned', player, mobId, ActiveMobs[mobId])
        end
    end
    
    return mobId
end

-- Gérer les dégâts sur un mob
function MobSystem.DamageMob(mobId, damage, attacker)
    local mob = ActiveMobs[mobId]
    if not mob then return false end
    
    -- Calculer les dégâts réels en tenant compte de la défense
    local actualDamage = math.max(1, damage - mob.defense)
    mob.health = mob.health - actualDamage
    
    -- Notifier les joueurs à proximité
    local players = QBCore.Functions.GetPlayers()
    for _, player in ipairs(players) do
        local playerPed = GetPlayerPed(player)
        local playerPos = GetEntityCoords(playerPed)
        if #(playerPos - mob.position) < 50.0 then
            TriggerClientEvent('sl-core:client:MobDamaged', player, mobId, actualDamage)
        end
    end
    
    -- Vérifier si le mob est mort
    if mob.health <= 0 then
        MobSystem.KillMob(mobId, attacker)
    else
        -- Le mob devient agressif
        mob.state = 'aggressive'
        mob.target = attacker
    end
    
    return true
end

-- Tuer un mob
function MobSystem.KillMob(mobId, killer)
    local mob = ActiveMobs[mobId]
    if not mob then return false end
    
    -- Donner les récompenses au tueur
    if killer then
        local killerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {killer}))
        if killerData then
            -- XP
            killerData.xp = killerData.xp + mob.xp
            RankSystem.AddRankXP(killer, mob.rankXp)
            
            -- Loot
            local mobConfig = nil
            for _, m in ipairs(MobTypes) do
                if m.id == mob.type then
                    mobConfig = m
                    break
                end
            end
            
            if mobConfig then
                for _, drop in ipairs(mobConfig.drops) do
                    if math.random() < drop.chance then
                        local amount = math.random(drop.min, drop.max)
                        -- TODO: Ajouter l'item à l'inventaire du joueur
                    end
                end
            end
            
            -- Sauvegarder les données
            MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
                {json.encode(killerData), killer})
        end
    end
    
    -- Notifier les joueurs à proximité
    local players = QBCore.Functions.GetPlayers()
    for _, player in ipairs(players) do
        local playerPed = GetPlayerPed(player)
        local playerPos = GetEntityCoords(playerPed)
        if #(playerPos - mob.position) < 50.0 then
            TriggerClientEvent('sl-core:client:MobKilled', player, mobId)
        end
    end
    
    -- Supprimer le mob
    ActiveMobs[mobId] = nil
    
    return true
end

-- Mettre à jour l'état des mobs
function MobSystem.UpdateMobs()
    for mobId, mob in pairs(ActiveMobs) do
        if mob.state == 'aggressive' and mob.target then
            local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(mob.target)
            if targetPlayer then
                local targetPed = GetPlayerPed(targetPlayer)
                local targetPos = GetEntityCoords(targetPed)
                local distance = #(targetPos - mob.position)
                
                -- Vérifier si le joueur est toujours à portée
                if distance > 50.0 then
                    mob.state = 'idle'
                    mob.target = nil
                else
                    -- Déplacer le mob vers le joueur
                    -- TODO: Implémenter le déplacement
                    
                    -- Vérifier les capacités
                    local mobConfig = nil
                    for _, m in ipairs(MobTypes) do
                        if m.id == mob.type then
                            mobConfig = m
                            break
                        end
                    end
                    
                    if mobConfig then
                        for _, ability in ipairs(mobConfig.abilities) do
                            if not mob.lastAbilityUse[ability.id] or 
                               os.time() - mob.lastAbilityUse[ability.id] >= ability.cooldown then
                                -- Utiliser la capacité
                                -- TODO: Implémenter l'utilisation des capacités
                                mob.lastAbilityUse[ability.id] = os.time()
                            end
                        end
                    end
                end
            else
                mob.state = 'idle'
                mob.target = nil
            end
        end
    end
end

-- Thread de mise à jour
CreateThread(function()
    while true do
        MobSystem.UpdateMobs()
        Wait(1000)
    end
end)

return MobSystem 