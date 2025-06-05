--[[
    Solo Leveling FiveM Server
    Dungeon System Module
    Author: natsei
    Version: 1.0.0
]]

local DungeonSystem = {}

-- Configuration des donjons
local Dungeons = {
    {
        id = 'cave_entrance',
        name = 'Entrée de la Caverne',
        requiredRank = 'E',
        minLevel = 1,
        maxPlayers = 1,
        waves = {
            {
                mobs = {
                    {type = 'goblin', count = 3, level = 1},
                    {type = 'wolf', count = 2, level = 1}
                },
                boss = nil
            }
        },
        rewards = {
            xp = 100,
            rankXp = 50,
            items = {
                {name = 'goblin_ear', chance = 0.5, min = 1, max = 3},
                {name = 'wolf_fang', chance = 0.3, min = 1, max = 2}
            }
        }
    },
    {
        id = 'abandoned_mine',
        name = 'Mine Abandonnée',
        requiredRank = 'D',
        minLevel = 5,
        maxPlayers = 2,
        waves = {
            {
                mobs = {
                    {type = 'skeleton', count = 4, level = 5},
                    {type = 'zombie', count = 3, level = 5}
                },
                boss = {
                    type = 'skeleton_warrior',
                    level = 7
                }
            }
        },
        rewards = {
            xp = 300,
            rankXp = 150,
            items = {
                {name = 'skeleton_bone', chance = 0.6, min = 2, max = 4},
                {name = 'zombie_heart', chance = 0.4, min = 1, max = 3}
            }
        }
    },
    {
        id = 'shadow_temple',
        name = 'Temple de l\'Ombre',
        requiredRank = 'C',
        minLevel = 15,
        maxPlayers = 3,
        waves = {
            {
                mobs = {
                    {type = 'shadow_warrior', count = 5, level = 15},
                    {type = 'dark_mage', count = 3, level = 15}
                },
                boss = {
                    type = 'shadow_lord',
                    level = 20
                }
            }
        },
        rewards = {
            xp = 800,
            rankXp = 400,
            items = {
                {name = 'shadow_crystal', chance = 0.7, min = 1, max = 2},
                {name = 'dark_essence', chance = 0.5, min = 1, max = 3}
            }
        }
    }
}

-- Donjons actifs
local ActiveDungeons = {}

-- Créer une instance de donjon
function DungeonSystem.CreateDungeonInstance(dungeonId, players)
    local dungeon = nil
    for _, d in ipairs(Dungeons) do
        if d.id == dungeonId then
            dungeon = d
            break
        end
    end
    
    if not dungeon then return false end
    
    -- Vérifier les prérequis
    for _, player in ipairs(players) do
        local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {player}))
        if not playerData or 
           playerData.level < dungeon.minLevel or
           not RankSystem.CanAccessContent(player, dungeon.requiredRank) then
            return false
        end
    end
    
    -- Créer l'instance
    local instanceId = #ActiveDungeons + 1
    ActiveDungeons[instanceId] = {
        dungeon = dungeon,
        players = players,
        currentWave = 1,
        mobs = {},
        boss = nil,
        startTime = os.time(),
        status = 'active'
    }
    
    -- Notifier les joueurs
    for _, player in ipairs(players) do
        local src = QBCore.Functions.GetPlayerByCitizenId(player)
        if src then
            TriggerClientEvent('sl-core:client:EnterDungeon', src, instanceId, dungeon)
        end
    end
    
    return instanceId
end

-- Gérer la vague de monstres
function DungeonSystem.HandleWave(instanceId)
    local instance = ActiveDungeons[instanceId]
    if not instance then return false end
    
    local wave = instance.dungeon.waves[instance.currentWave]
    if not wave then return false end
    
    -- Spawn les mobs
    for _, mobConfig in ipairs(wave.mobs) do
        for i = 1, mobConfig.count do
            local mobId = #instance.mobs + 1
            instance.mobs[mobId] = {
                type = mobConfig.type,
                level = mobConfig.level,
                health = 100,
                position = GetRandomSpawnPoint(instanceId)
            }
            
            -- Notifier les joueurs
            for _, player in ipairs(instance.players) do
                local src = QBCore.Functions.GetPlayerByCitizenId(player)
                if src then
                    TriggerClientEvent('sl-core:client:SpawnMob', src, mobId, instance.mobs[mobId])
                end
            end
        end
    end
    
    -- Spawn le boss si présent
    if wave.boss then
        instance.boss = {
            type = wave.boss.type,
            level = wave.boss.level,
            health = 1000,
            position = GetBossSpawnPoint(instanceId)
        }
        
        for _, player in ipairs(instance.players) do
            local src = QBCore.Functions.GetPlayerByCitizenId(player)
            if src then
                TriggerClientEvent('sl-core:client:SpawnBoss', src, instance.boss)
            end
        end
    end
    
    return true
end

-- Gérer la mort d'un mob
function DungeonSystem.HandleMobDeath(instanceId, mobId)
    local instance = ActiveDungeons[instanceId]
    if not instance or not instance.mobs[mobId] then return false end
    
    -- Supprimer le mob
    instance.mobs[mobId] = nil
    
    -- Vérifier si la vague est terminée
    if #instance.mobs == 0 and not instance.boss then
        instance.currentWave = instance.currentWave + 1
        
        if instance.currentWave > #instance.dungeon.waves then
            -- Donjon terminé
            DungeonSystem.CompleteDungeon(instanceId)
        else
            -- Nouvelle vague
            DungeonSystem.HandleWave(instanceId)
        end
    end
    
    return true
end

-- Gérer la mort du boss
function DungeonSystem.HandleBossDeath(instanceId)
    local instance = ActiveDungeons[instanceId]
    if not instance or not instance.boss then return false end
    
    instance.boss = nil
    instance.currentWave = instance.currentWave + 1
    
    if instance.currentWave > #instance.dungeon.waves then
        -- Donjon terminé
        DungeonSystem.CompleteDungeon(instanceId)
    else
        -- Nouvelle vague
        DungeonSystem.HandleWave(instanceId)
    end
    
    return true
end

-- Compléter le donjon
function DungeonSystem.CompleteDungeon(instanceId)
    local instance = ActiveDungeons[instanceId]
    if not instance then return false end
    
    -- Donner les récompenses
    for _, player in ipairs(instance.players) do
        local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {player}))
        
        -- XP
        playerData.xp = playerData.xp + instance.dungeon.rewards.xp
        RankSystem.AddRankXP(player, instance.dungeon.rewards.rankXp)
        
        -- Items
        for _, item in ipairs(instance.dungeon.rewards.items) do
            if math.random() < item.chance then
                local amount = math.random(item.min, item.max)
                -- Ajouter l'item à l'inventaire du joueur
                -- TODO: Implémenter l'ajout d'items
            end
        end
        
        -- Sauvegarder les données
        MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
            {json.encode(playerData), player})
        
        -- Notifier le joueur
        local src = QBCore.Functions.GetPlayerByCitizenId(player)
        if src then
            TriggerClientEvent('sl-core:client:DungeonComplete', src, instance.dungeon)
        end
    end
    
    -- Nettoyer l'instance
    ActiveDungeons[instanceId] = nil
    
    return true
end

-- Fonctions utilitaires
function GetRandomSpawnPoint(instanceId)
    -- TODO: Implémenter la logique de spawn
    return vector3(0, 0, 0)
end

function GetBossSpawnPoint(instanceId)
    -- TODO: Implémenter la logique de spawn du boss
    return vector3(0, 0, 0)
end

return DungeonSystem 