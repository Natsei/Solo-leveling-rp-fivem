--[[
    Solo Leveling FiveM Server
    Guild System Module
    Author: Claude
    Version: 1.0.0
]]

local GuildSystem = {}

-- Configuration des rôles et permissions (voir config.lua)
local GuildConfig = Config.Guilds

-- Création d'une guilde
function GuildSystem.CreateGuild(citizenid, name, description)
    -- Vérifier si le joueur a déjà une guilde
    local result = MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid})
    if result then
        local playerData = json.decode(result)
        if playerData.guild then
            return false, 'Déjà dans une guilde.'
        end
        if playerData.level < GuildConfig.minLevelToCreate then
            return false, 'Niveau insuffisant pour créer une guilde.'
        end
    end
    -- Créer la guilde
    local guild = {
        name = name,
        description = description,
        leader = citizenid,
        members = {
            [citizenid] = {role = 'leader', joined = os.time()}
        },
        created = os.time(),
        level = 1,
        bank = 0
    }
    -- Sauvegarder la guilde (table séparée)
    MySQL.Async.execute('INSERT INTO sl_guilds (name, data) VALUES (?, ?)', {name, json.encode(guild)})
    -- Mettre à jour le joueur
    MySQL.Async.execute('UPDATE sl_players SET data = JSON_SET(data, "$.guild", ?) WHERE citizenid = ?', {name, citizenid})
    return true
end

-- Inviter un joueur dans une guilde
function GuildSystem.InviteToGuild(guildName, targetCitizenId, inviterCitizenId)
    -- Vérifier que l'invitant est bien dans la guilde et a la permission
    local guildData = MySQL.Sync.fetchScalar('SELECT data FROM sl_guilds WHERE name = ?', {guildName})
    if not guildData then return false, 'Guilde introuvable.' end
    local guild = json.decode(guildData)
    if not guild.members[inviterCitizenId] then return false, 'Non membre.' end
    local inviterRole = guild.members[inviterCitizenId].role
    local inviterPerms = {}
    for _, role in ipairs(GuildConfig.roles) do
        if role.id == inviterRole then inviterPerms = role.permissions end
    end
    local canInvite = false
    for _, perm in ipairs(inviterPerms) do if perm == 'invite_members' then canInvite = true end end
    if not canInvite then return false, 'Pas la permission.' end
    -- Vérifier que le joueur n'est pas déjà dans une guilde
    local targetData = MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {targetCitizenId})
    if targetData then
        local pdata = json.decode(targetData)
        if pdata.guild then return false, 'Déjà dans une guilde.' end
    end
    -- Ajouter l'invitation (à gérer côté client/serveur)
    TriggerClientEvent('sl-core:client:GuildInvite', QBCore.Functions.GetPlayerByCitizenId(targetCitizenId), guildName, inviterCitizenId)
    return true
end

-- Accepter une invitation
function GuildSystem.JoinGuild(citizenid, guildName)
    local guildData = MySQL.Sync.fetchScalar('SELECT data FROM sl_guilds WHERE name = ?', {guildName})
    if not guildData then return false, 'Guilde introuvable.' end
    local guild = json.decode(guildData)
    if guild.members[citizenid] then return false, 'Déjà membre.' end
    if table.count(guild.members) >= GuildConfig.maxMembers then return false, 'Guilde pleine.' end
    -- Ajouter le membre
    guild.members[citizenid] = {role = 'member', joined = os.time()}
    -- Sauvegarder
    MySQL.Async.execute('UPDATE sl_guilds SET data = ? WHERE name = ?', {json.encode(guild), guildName})
    MySQL.Async.execute('UPDATE sl_players SET data = JSON_SET(data, "$.guild", ?) WHERE citizenid = ?', {guildName, citizenid})
    return true
end

-- Quitter une guilde
function GuildSystem.LeaveGuild(citizenid)
    local playerData = MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid})
    if not playerData then return false, 'Aucune donnée.' end
    local pdata = json.decode(playerData)
    if not pdata.guild then return false, 'Pas de guilde.' end
    local guildName = pdata.guild
    local guildData = MySQL.Sync.fetchScalar('SELECT data FROM sl_guilds WHERE name = ?', {guildName})
    if not guildData then return false, 'Guilde introuvable.' end
    local guild = json.decode(guildData)
    guild.members[citizenid] = nil
    -- Si chef, transférer ou dissoudre
    if guild.leader == citizenid then
        local found = false
        for cid, member in pairs(guild.members) do
            if member.role == 'officer' then
                guild.leader = cid
                guild.members[cid].role = 'leader'
                found = true
                break
            end
        end
        if not found then
            -- Dissoudre la guilde
            MySQL.Async.execute('DELETE FROM sl_guilds WHERE name = ?', {guildName})
            -- Mettre à jour tous les membres
            for cid, _ in pairs(guild.members) do
                MySQL.Async.execute('UPDATE sl_players SET data = JSON_SET(data, "$.guild", NULL) WHERE citizenid = ?', {cid})
            end
            return true, 'Guilde dissoute.'
        end
    end
    -- Sauvegarder
    MySQL.Async.execute('UPDATE sl_guilds SET data = ? WHERE name = ?', {json.encode(guild), guildName})
    MySQL.Async.execute('UPDATE sl_players SET data = JSON_SET(data, "$.guild", NULL) WHERE citizenid = ?', {citizenid})
    return true
end

-- Obtenir les infos d'une guilde
function GuildSystem.GetGuildInfo(guildName)
    local guildData = MySQL.Sync.fetchScalar('SELECT data FROM sl_guilds WHERE name = ?', {guildName})
    if not guildData then return nil end
    return json.decode(guildData)
end

-- Obtenir la guilde d'un joueur
function GuildSystem.GetPlayerGuild(citizenid)
    local playerData = MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid})
    if not playerData then return nil end
    local pdata = json.decode(playerData)
    return pdata.guild
end

return GuildSystem 