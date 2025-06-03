--[[
    Solo Leveling FiveM Server
    Localization System Module
    Author: Claude
    Version: 1.0.0
]]

local LocalizationSystem = {}

-- Langues supportées
local SupportedLanguages = {
    fr = 'Français',
    en = 'English',
    es = 'Español'
}

-- Textes localisés
local Translations = {
    fr = {
        -- Général
        ['welcome'] = 'Bienvenue dans Solo Leveling !',
        ['level_up'] = 'Niveau %d atteint !',
        ['quest_complete'] = 'Quête terminée : %s',
        
        -- Classes
        ['class_tank'] = 'Tank',
        ['class_mage'] = 'Mage',
        ['class_swordsman'] = 'Épéiste',
        ['class_assassin'] = 'Assassin',
        ['class_archer'] = 'Archer',
        ['class_healer'] = 'Soigneur',
        
        -- Items
        ['item_sword'] = 'Épée',
        ['item_potion'] = 'Potion',
        ['item_armor'] = 'Armure',
        
        -- Quêtes
        ['quest_start'] = 'Début de la quête : %s',
        ['quest_objective'] = 'Objectif : %s',
        ['quest_reward'] = 'Récompense : %s',
        
        -- Boutiques
        ['shop_buy'] = 'Acheter',
        ['shop_sell'] = 'Vendre',
        ['shop_price'] = 'Prix : %d',
        ['shop_stock'] = 'Stock : %d'
    },
    en = {
        -- General
        ['welcome'] = 'Welcome to Solo Leveling!',
        ['level_up'] = 'Reached level %d!',
        ['quest_complete'] = 'Quest completed: %s',
        
        -- Classes
        ['class_tank'] = 'Tank',
        ['class_mage'] = 'Mage',
        ['class_swordsman'] = 'Swordsman',
        ['class_assassin'] = 'Assassin',
        ['class_archer'] = 'Archer',
        ['class_healer'] = 'Healer',
        
        -- Items
        ['item_sword'] = 'Sword',
        ['item_potion'] = 'Potion',
        ['item_armor'] = 'Armor',
        
        -- Quests
        ['quest_start'] = 'Quest started: %s',
        ['quest_objective'] = 'Objective: %s',
        ['quest_reward'] = 'Reward: %s',
        
        -- Shops
        ['shop_buy'] = 'Buy',
        ['shop_sell'] = 'Sell',
        ['shop_price'] = 'Price: %d',
        ['shop_stock'] = 'Stock: %d'
    },
    es = {
        -- General
        ['welcome'] = '¡Bienvenido a Solo Leveling!',
        ['level_up'] = '¡Alcanzado nivel %d!',
        ['quest_complete'] = 'Misión completada: %s',
        
        -- Classes
        ['class_tank'] = 'Tanque',
        ['class_mage'] = 'Mago',
        ['class_swordsman'] = 'Espadachín',
        ['class_assassin'] = 'Asesino',
        ['class_archer'] = 'Arquero',
        ['class_healer'] = 'Sanador',
        
        -- Items
        ['item_sword'] = 'Espada',
        ['item_potion'] = 'Poción',
        ['item_armor'] = 'Armadura',
        
        -- Quests
        ['quest_start'] = 'Misión iniciada: %s',
        ['quest_objective'] = 'Objetivo: %s',
        ['quest_reward'] = 'Recompensa: %s',
        
        -- Shops
        ['shop_buy'] = 'Comprar',
        ['shop_sell'] = 'Vender',
        ['shop_price'] = 'Precio: %d',
        ['shop_stock'] = 'Stock: %d'
    }
}

-- Obtenir la langue d'un joueur
function LocalizationSystem.GetPlayerLanguage(citizenid)
    local result = MySQL.Sync.fetchScalar('SELECT language FROM sl_players WHERE citizenid = ?', {citizenid})
    if result and SupportedLanguages[result] then
        return result
    end
    return 'en' -- Langue par défaut
end

-- Définir la langue d'un joueur
function LocalizationSystem.SetPlayerLanguage(citizenid, language)
    if not SupportedLanguages[language] then
        return false
    end
    
    MySQL.Async.execute('UPDATE sl_players SET language = ? WHERE citizenid = ?',
        {language, citizenid})
    
    return true
end

-- Obtenir un texte traduit
function LocalizationSystem.GetText(citizenid, key, ...)
    local language = LocalizationSystem.GetPlayerLanguage(citizenid)
    local translation = Translations[language][key]
    
    if not translation then
        -- Fallback sur l'anglais si la traduction n'existe pas
        translation = Translations['en'][key]
        if not translation then
            return key
        end
    end
    
    if ... then
        return string.format(translation, ...)
    end
    
    return translation
end

-- Ajouter une nouvelle traduction
function LocalizationSystem.AddTranslation(language, key, text)
    if not SupportedLanguages[language] then
        return false
    end
    
    if not Translations[language] then
        Translations[language] = {}
    end
    
    Translations[language][key] = text
    return true
end

-- Obtenir toutes les traductions pour une langue
function LocalizationSystem.GetAllTranslations(language)
    if not SupportedLanguages[language] then
        return nil
    end
    
    return Translations[language]
end

-- Obtenir les langues supportées
function LocalizationSystem.GetSupportedLanguages()
    return SupportedLanguages
end

return LocalizationSystem 