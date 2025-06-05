--[[
    Solo Leveling FiveM Server
    Crafting System Module
    Author: natsei
    Version: 1.0.0
]]

local CraftingSystem = {}

-- Configuration des recettes
local Recipes = {
    {
        id = 'recipe_001',
        name = 'Épée en Acier',
        description = 'Une épée plus résistante que l\'épée en fer',
        requiredLevel = 5,
        materials = {
            {id = 'iron_ingot', amount = 3},
            {id = 'steel_ingot', amount = 2},
            {id = 'wood', amount = 1}
        },
        result = {
            id = 'sword_002',
            amount = 1
        },
        craftingTime = 30 -- en secondes
    },
    {
        id = 'recipe_002',
        name = 'Potion de Force',
        description = 'Augmente temporairement la force',
        requiredLevel = 10,
        materials = {
            {id = 'herb_001', amount = 2},
            {id = 'crystal_001', amount = 1},
            {id = 'water', amount = 1}
        },
        result = {
            id = 'potion_002',
            amount = 1
        },
        craftingTime = 15
    }
}

-- Vérifier si un joueur peut crafter une recette
function CraftingSystem.CanCraftRecipe(citizenid, recipeId)
    local recipe = nil
    for _, r in ipairs(Recipes) do
        if r.id == recipeId then
            recipe = r
            break
        end
    end
    
    if not recipe then return false end
    
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if playerData.level < recipe.requiredLevel then
        return false
    end
    
    -- Vérifier les matériaux
    local inventory = json.decode(MySQL.Sync.fetchScalar('SELECT inventory FROM sl_players WHERE citizenid = ?', {citizenid}))
    for _, material in ipairs(recipe.materials) do
        if not inventory[material.id] or inventory[material.id] < material.amount then
            return false
        end
    end
    
    return true
end

-- Commencer le crafting d'un item
function CraftingSystem.StartCrafting(citizenid, recipeId)
    if not CraftingSystem.CanCraftRecipe(citizenid, recipeId) then
        return false
    end
    
    local recipe = nil
    for _, r in ipairs(Recipes) do
        if r.id == recipeId then
            recipe = r
            break
        end
    end
    
    if not recipe then return false end
    
    -- Retirer les matériaux
    local inventory = json.decode(MySQL.Sync.fetchScalar('SELECT inventory FROM sl_players WHERE citizenid = ?', {citizenid}))
    for _, material in ipairs(recipe.materials) do
        inventory[material.id] = inventory[material.id] - material.amount
        if inventory[material.id] == 0 then
            inventory[material.id] = nil
        end
    end
    
    -- Mettre à jour l'inventaire
    MySQL.Async.execute('UPDATE sl_players SET inventory = ? WHERE citizenid = ?',
        {json.encode(inventory), citizenid})
    
    -- Démarrer le timer de crafting
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData.crafting then
        playerData.crafting = {}
    end
    
    playerData.crafting[recipeId] = {
        startTime = os.time(),
        endTime = os.time() + recipe.craftingTime
    }
    
    MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
        {json.encode(playerData), citizenid})
    
    return true
end

-- Vérifier si le crafting est terminé
function CraftingSystem.IsCraftingComplete(citizenid, recipeId)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not playerData.crafting or not playerData.crafting[recipeId] then
        return false
    end
    
    return os.time() >= playerData.crafting[recipeId].endTime
end

-- Récupérer l'item crafté
function CraftingSystem.CollectCraftedItem(citizenid, recipeId)
    if not CraftingSystem.IsCraftingComplete(citizenid, recipeId) then
        return false
    end
    
    local recipe = nil
    for _, r in ipairs(Recipes) do
        if r.id == recipeId then
            recipe = r
            break
        end
    end
    
    if not recipe then return false end
    
    -- Ajouter l'item à l'inventaire
    local inventory = json.decode(MySQL.Sync.fetchScalar('SELECT inventory FROM sl_players WHERE citizenid = ?', {citizenid}))
    if not inventory[recipe.result.id] then
        inventory[recipe.result.id] = 0
    end
    inventory[recipe.result.id] = inventory[recipe.result.id] + recipe.result.amount
    
    MySQL.Async.execute('UPDATE sl_players SET inventory = ? WHERE citizenid = ?',
        {json.encode(inventory), citizenid})
    
    -- Nettoyer le crafting
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    playerData.crafting[recipeId] = nil
    
    MySQL.Async.execute('UPDATE sl_players SET data = ? WHERE citizenid = ?',
        {json.encode(playerData), citizenid})
    
    return true
end

-- Obtenir les recettes disponibles pour un joueur
function CraftingSystem.GetAvailableRecipes(citizenid)
    local playerData = json.decode(MySQL.Sync.fetchScalar('SELECT data FROM sl_players WHERE citizenid = ?', {citizenid}))
    local availableRecipes = {}
    
    for _, recipe in ipairs(Recipes) do
        if playerData.level >= recipe.requiredLevel then
            table.insert(availableRecipes, recipe)
        end
    end
    
    return availableRecipes
end

return CraftingSystem 