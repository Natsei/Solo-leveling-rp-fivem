--[[
    Solo Leveling FiveM Server
    Configuration File
    Author: Claude
    Version: 1.0.0
]]

Config = {}

-- Configuration de la base de données
Config.Database = {
    host = "localhost",
    user = "root",
    password = "",
    database = "solo_leveling"
}

-- Configuration du serveur
Config.Server = {
    maxLevel = 100,
    startingGold = 1000,
    startingExp = 0,
    expMultiplier = 1.0,
    goldMultiplier = 1.0,
    dropRate = 1.0
}

-- Configuration des classes
Config.Classes = {
    maxActiveQuests = 5,
    maxInventorySlots = 50,
    maxGuildMembers = 50,
    maxDungeonPlayers = 4
}

-- Configuration des donjons
Config.Dungeons = {
    {
        id = "dungeon_001",
        name = "Donjon des Ombres",
        minLevel = 10,
        maxLevel = 20,
        waves = 5,
        rewards = {
            exp = 1000,
            gold = 500,
            items = {
                {id = "item_001", chance = 0.1},
                {id = "item_002", chance = 0.05}
            }
        }
    },
    {
        id = "dungeon_002",
        name = "Donjon du Dragon",
        minLevel = 30,
        maxLevel = 40,
        waves = 8,
        rewards = {
            exp = 3000,
            gold = 1500,
            items = {
                {id = "item_003", chance = 0.15},
                {id = "item_004", chance = 0.08}
            }
        }
    }
}

-- Configuration des mobs
Config.Mobs = {
    {
        id = "mob_001",
        name = "Loup des Ombres",
        level = 10,
        health = 100,
        damage = 15,
        exp = 50,
        gold = 25,
        drops = {
            {id = "item_001", chance = 0.1},
            {id = "item_002", chance = 0.05}
        }
    },
    {
        id = "mob_002",
        name = "Gobelin",
        level = 15,
        health = 150,
        damage = 20,
        exp = 75,
        gold = 35,
        drops = {
            {id = "item_003", chance = 0.15},
            {id = "item_004", chance = 0.08}
        }
    }
}

-- Configuration des items
Config.Items = {
    {
        id = "item_001",
        name = "Cristal d'Ombre",
        type = "material",
        description = "Un cristal mystérieux qui émane des ombres",
        stackable = true,
        maxStack = 99
    },
    {
        id = "item_002",
        name = "Épée en Fer",
        type = "weapon",
        description = "Une épée basique en fer",
        stats = {
            damage = 10,
            durability = 100
        },
        stackable = false
    }
}

-- Configuration des boutiques
Config.Shops = {
    {
        id = "shop_001",
        name = "Boutique du Forgeron",
        npc = "npc_blacksmith",
        items = {
            {
                id = "item_001",
                price = 100,
                stock = 5
            },
            {
                id = "item_002",
                price = 150,
                stock = 3
            }
        }
    }
}

-- Configuration des quêtes
Config.Quests = {
    {
        id = "quest_001",
        name = "Début du Voyage",
        description = "Commencez votre aventure en parlant au guide du village",
        level = 1,
        type = "main",
        rewards = {
            exp = 100,
            gold = 50,
            items = {
                {id = "item_001", amount = 1}
            }
        },
        objectives = {
            {
                type = "talk",
                target = "npc_guide",
                description = "Parler au guide du village"
            }
        }
    }
}

-- Configuration des guildes
Config.Guilds = {
    maxNameLength = 20,
    minMembersToCreate = 3,
    maxMembers = 50,
    creationCost = 10000,
    dailyTax = 1000
}

-- Configuration des notifications
Config.Notifications = {
    defaultDuration = 3000,
    position = "top-right",
    sound = true
}

-- Configuration des logs
Config.Logs = {
    enabled = true,
    logToFile = true,
    logToDatabase = true,
    maxLogAge = 30 -- jours
}

-- Configuration de la localisation
Config.Localization = {
    defaultLanguage = "fr",
    supportedLanguages = {
        fr = "Français",
        en = "English",
        es = "Español"
    }
}

-- Configuration des commandes
Config.Commands = {
    admin = {
        "setlevel",
        "additem",
        "addgold",
        "teleport"
    },
    player = {
        "class",
        "inventory",
        "quests",
        "craft",
        "shop",
        "guild"
    }
}

-- Configuration des permissions
Config.Permissions = {
    admin = {
        "setlevel",
        "additem",
        "addgold",
        "teleport",
        "kick",
        "ban"
    },
    moderator = {
        "kick",
        "warn"
    }
}

return Config 