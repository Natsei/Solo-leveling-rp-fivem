--[[
    Solo Leveling FiveM Server
    Inventory System Module
    Author: natsei
    Version: 1.0.0
]]

local InventorySystem = {}

-- Configuration des types d'items
local ItemTypes = {
    WEAPON = 'weapon',
    ARMOR = 'armor',
    CONSUMABLE = 'consumable',
    MATERIAL = 'material',
    QUEST = 'quest'
}

-- Configuration des items
local Items = {
    {
        id = 'sword_001',
        name = 'Épée en Fer',
        type = ItemTypes.WEAPON,
        description = 'Une épée basique en fer',
        stats = {
            damage = 10,
            durability = 100
        },
        stackable = false,
        maxStack = 1
    },
    {
        id = 'potion_001',
        name = 'Potion de Vie',
        type = ItemTypes.CONSUMABLE,
        description = 'Restaure 50 points de vie',
        effect = {
            type = 'heal',
            value = 50
        },
        stackable = true,
        maxStack = 99
    }
}

-- Obtenir l'inventaire d'un joueur
function InventorySystem.GetPlayerInventory(citizenid)
    local result = MySQL.Sync.fetchScalar('SELECT inventory FROM sl_players WHERE citizenid = ?', {citizenid})
    if result then
        return json.decode(result)
    end
    return {}
end

-- Ajouter un item à l'inventaire
function InventorySystem.AddItem(citizenid, itemId, amount)
    amount = amount or 1
    local inventory = InventorySystem.GetPlayerInventory(citizenid)
    local item = nil
    
    for _, i in ipairs(Items) do
        if i.id == itemId then
            item = i
            break
        end
    end
    
    if not item then return false end
    
    if item.stackable then
        if not inventory[itemId] then
            inventory[itemId] = 0
        end
        
        if inventory[itemId] + amount > item.maxStack then
            return false
        end
        
        inventory[itemId] = inventory[itemId] + amount
    else
        if not inventory[itemId] then
            inventory[itemId] = {}
        end
        
        for i = 1, amount do
            table.insert(inventory[itemId], {
                durability = item.stats.durability,
                id = #inventory[itemId] + 1
            })
        end
    end
    
    MySQL.Async.execute('UPDATE sl_players SET inventory = ? WHERE citizenid = ?',
        {json.encode(inventory), citizenid})
    
    return true
end

-- Retirer un item de l'inventaire
function InventorySystem.RemoveItem(citizenid, itemId, amount)
    amount = amount or 1
    local inventory = InventorySystem.GetPlayerInventory(citizenid)
    local item = nil
    
    for _, i in ipairs(Items) do
        if i.id == itemId then
            item = i
            break
        end
    end
    
    if not item then return false end
    
    if item.stackable then
        if not inventory[itemId] or inventory[itemId] < amount then
            return false
        end
        
        inventory[itemId] = inventory[itemId] - amount
        if inventory[itemId] == 0 then
            inventory[itemId] = nil
        end
    else
        if not inventory[itemId] or #inventory[itemId] < amount then
            return false
        end
        
        for i = 1, amount do
            table.remove(inventory[itemId])
        end
        
        if #inventory[itemId] == 0 then
            inventory[itemId] = nil
        end
    end
    
    MySQL.Async.execute('UPDATE sl_players SET inventory = ? WHERE citizenid = ?',
        {json.encode(inventory), citizenid})
    
    return true
end

-- Utiliser un item
function InventorySystem.UseItem(citizenid, itemId, itemInstanceId)
    local inventory = InventorySystem.GetPlayerInventory(citizenid)
    local item = nil
    
    for _, i in ipairs(Items) do
        if i.id == itemId then
            item = i
            break
        end
    end
    
    if not item then return false end
    
    if item.type == ItemTypes.CONSUMABLE then
        if item.stackable then
            if not inventory[itemId] or inventory[itemId] < 1 then
                return false
            end
        else
            if not inventory[itemId] or not inventory[itemId][itemInstanceId] then
                return false
            end
        end
        
        -- Appliquer l'effet de l'item
        if item.effect.type == 'heal' then
            -- TODO: Implémenter la guérison
        end
        
        -- Retirer l'item après utilisation
        return InventorySystem.RemoveItem(citizenid, itemId, 1)
    end
    
    return false
end

-- Vérifier si un joueur a un item
function InventorySystem.HasItem(citizenid, itemId, amount)
    amount = amount or 1
    local inventory = InventorySystem.GetPlayerInventory(citizenid)
    local item = nil
    
    for _, i in ipairs(Items) do
        if i.id == itemId then
            item = i
            break
        end
    end
    
    if not item then return false end
    
    if item.stackable then
        return inventory[itemId] and inventory[itemId] >= amount
    else
        return inventory[itemId] and #inventory[itemId] >= amount
    end
end

return InventorySystem 