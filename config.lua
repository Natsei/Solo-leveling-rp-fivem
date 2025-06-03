--[[
    Solo Leveling FiveM Server
    Configuration File
    Author: Claude
    Version: 1.0.0
]]

Config = {}

-- Configuration générale
Config.Debug = false
Config.DefaultRank = 'E'
Config.MaxLevel = 100
Config.UIEnabled = true -- true = NUI Solo Leveling, false = RageUI ESX

-- Configuration des statistiques
Config.BaseStats = {
    strength = 10,
    agility = 10,
    intelligence = 10,
    vitality = 10
}

Config.StatsPerLevel = {
    strength = 2,
    agility = 2,
    intelligence = 2,
    vitality = 2
}

-- Configuration de l'XP
Config.BaseXP = 100
Config.XPMultiplier = 1.5
Config.RankXP = {
    E = 0,
    D = 1000,
    C = 5000,
    B = 15000,
    A = 50000,
    S = 150000,
    National = 500000
}

-- Configuration des classes
Config.Classes = {
    {
        id = 'tank',
        name = 'Tank',
        description = 'Spécialiste de la défense et de l\'endurance',
        baseStats = {
            strength = 15,
            agility = 8,
            intelligence = 5,
            vitality = 20
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
        }
    }
}

-- Configuration des donjons
Config.Dungeons = {
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
    }
}

-- Configuration des mobs
Config.Mobs = {
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
        }
    }
}

-- Configuration des sorts
Config.Spells = {
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
    }
}

-- Configuration des guildes
Config.Guilds = {
    maxMembers = 50,
    minLevelToCreate = 10,
    costToCreate = 10000,
    roles = {
        {
            id = 'leader',
            name = 'Chef',
            permissions = {
                'invite_members',
                'kick_members',
                'promote_members',
                'demote_members',
                'manage_roles',
                'manage_bank',
                'manage_missions',
                'manage_buildings'
            }
        },
        {
            id = 'officer',
            name = 'Officier',
            permissions = {
                'invite_members',
                'kick_members',
                'promote_members',
                'manage_missions',
                'manage_buildings'
            }
        }
    }
}

-- Configuration des points de spawn
Config.SpawnPoints = {
    {
        name = 'Centre-ville',
        coords = vector3(0, 0, 0),
        radius = 100.0
    },
    {
        name = 'Forêt',
        coords = vector3(100, 100, 0),
        radius = 150.0
    }
}

-- Configuration des notifications
Config.Notifications = {
    levelUp = {
        title = 'Niveau Supérieur !',
        message = 'Vous avez atteint le niveau %s !',
        type = 'success'
    },
    rankUp = {
        title = 'Rang Supérieur !',
        message = 'Vous avez atteint le rang %s !',
        type = 'success'
    },
    dungeonComplete = {
        title = 'Donjon Terminé !',
        message = 'Vous avez terminé le donjon %s !',
        type = 'success'
    }
}

return Config 