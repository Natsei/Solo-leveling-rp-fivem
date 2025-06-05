--[[
    Solo Leveling FiveM Server
    Trading System Module
    Author: natsei
    Version: 1.0.0
]]

local TradingSystem = {}

-- Configuration des boutiques NPC
local Shops = {
    {
        id = 'shop_001',
        name = 'Boutique du Forgeron',
        npc = 'npc_blacksmith',
        items = {
            {
                id = 'sword_001',
                price = 100,
                stock = 5
            },
            {
                id = 'armor_001',
                price = 150,
                stock = 3
            }
        }
    },
    {
        id = 'shop_002',
        name = 'Boutique d\'Alchimie',
        npc = 'npc_alchemist',
        items = {
            {
                id = 'potion_001',
                price = 50,
                stock = 10
            },
            {
                id = 'potion_002',
                price = 75,
                stock = 8
            }
        }
    }
}

-- Acheter un item dans une boutique
function TradingSystem.BuyItem(citizenid, shopId, itemId, amount)
    amount = amount or 1
    local shop = nil
    local shopItem = nil
    
    for _, s in ipairs(Shops) do
        if s.id == shopId then
            shop = s
            for _, item in ipairs(s.items) do
                if item.id == itemId then
                    shopItem = item
                    break
                end
            end
            break
        end
    end
    
    if not shop or not shopItem then return false end
    
    if shopItem.stock < amount then
        return false
    end
    
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    local totalPrice = shopItem.price * amount
    
    if playerData.gold < totalPrice then
        return false
    end
    
    -- Retirer l'or du joueur
    playerData.gold = playerData.gold - totalPrice
    MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
        {json.encode(playerData), citizenid})
    
    -- Ajouter l'item à l'inventaire du joueur
    local inventory = json.decode(MySQL.Sync.fetchScalar('SELECT inventory FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not inventory[itemId] then
        inventory[itemId] = 0
    end
    inventory[itemId] = inventory[itemId] + amount
    
    MySQL.Async.execute('UPDATE sl_players SET inventory = ? WHERE citizenid = ?',
        {json.encode(inventory), citizenid})
    
    -- Mettre à jour le stock
    shopItem.stock = shopItem.stock - amount
    
    return true
end

-- Vendre un item à une boutique
function TradingSystem.SellItem(citizenid, shopId, itemId, amount)
    amount = amount or 1
    local shop = nil
    local shopItem = nil
    
    for _, s in ipairs(Shops) do
        if s.id == shopId then
            shop = s
            for _, item in ipairs(s.items) do
                if item.id == itemId then
                    shopItem = item
                    break
                end
            end
            break
        end
    end
    
    if not shop or not shopItem then return false end
    
    -- Vérifier si le joueur a l'item
    local inventory = json.decode(MySQL.Sync.fetchScalar('SELECT inventory FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not inventory[itemId] or inventory[itemId] < amount then
        return false
    end
    
    -- Calculer le prix de vente (50% du prix d'achat)
    local sellPrice = math.floor(shopItem.price * 0.5 * amount)
    
    -- Retirer l'item de l'inventaire
    inventory[itemId] = inventory[itemId] - amount
    if inventory[itemId] == 0 then
        inventory[itemId] = nil
    end
    
    MySQL.Async.execute('UPDATE sl_players SET inventory = ? WHERE citizenid = ?',
        {json.encode(inventory), citizenid})
    
    -- Ajouter l'or au joueur
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    playerData.gold = playerData.gold + sellPrice
    
    MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
        {json.encode(playerData), citizenid})
    
    return true
end

-- Échanger des items entre joueurs
function TradingSystem.TradeItems(player1Id, player2Id, player1Items, player2Items)
    -- Vérifier les items des deux joueurs
    local player1Inventory = json.decode(MySQL.Sync.fetchScalar('SELECT inventory FROM sl_players WHERE citizenid = ?', {player1Id}))
    local player2Inventory = json.decode(MySQL.Sync.fetchScalar('SELECT inventory FROM sl_players WHERE citizenid = ?', {player2Id}))
    
    -- Vérifier les items du joueur 1
    for itemId, amount in pairs(player1Items) do
        if not player1Inventory[itemId] or player1Inventory[itemId] < amount then
            return false
        end
    end
    
    -- Vérifier les items du joueur 2
    for itemId, amount in pairs(player2Items) do
        if not player2Inventory[itemId] or player2Inventory[itemId] < amount then
            return false
        end
    end
    
    -- Effectuer l'échange
    for itemId, amount in pairs(player1Items) do
        player1Inventory[itemId] = player1Inventory[itemId] - amount
        if player1Inventory[itemId] == 0 then
            player1Inventory[itemId] = nil
        end
        
        if not player2Inventory[itemId] then
            player2Inventory[itemId] = 0
        end
        player2Inventory[itemId] = player2Inventory[itemId] + amount
    end
    
    for itemId, amount in pairs(player2Items) do
        player2Inventory[itemId] = player2Inventory[itemId] - amount
        if player2Inventory[itemId] == 0 then
            player2Inventory[itemId] = nil
        end
        
        if not player1Inventory[itemId] then
            player1Inventory[itemId] = 0
        end
        player1Inventory[itemId] = player1Inventory[itemId] + amount
    end
    
    -- Mettre à jour les inventaires
    MySQL.Async.execute('UPDATE sl_players SET inventory = ? WHERE citizenid = ?',
        {json.encode(player1Inventory), player1Id})
    MySQL.Async.execute('UPDATE sl_players SET inventory = ? WHERE citizenid = ?',
        {json.encode(player2Inventory), player2Id})
    
    return true
end

-- Obtenir les items d'une boutique
function TradingSystem.GetShopItems(shopId)
    for _, shop in ipairs(Shops) do
        if shop.id == shopId then
            return shop.items
        end
    end
    return nil
end

return TradingSystem 