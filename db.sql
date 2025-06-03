--[[
    Solo Leveling FiveM Server
    Database Structure
    Author: Claude
    Version: 1.0.0
]]

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS `solo_leveling` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `solo_leveling`;

-- Table des joueurs
CREATE TABLE IF NOT EXISTS `sl_players` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(50) NOT NULL,
    `level` INT DEFAULT 1,
    `exp` INT DEFAULT 0,
    `gold` INT DEFAULT 1000,
    `class` VARCHAR(50),
    `data` JSON,
    `inventory` JSON,
    `language` VARCHAR(2) DEFAULT 'fr',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des guildes
CREATE TABLE IF NOT EXISTS `sl_guilds` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `leader` VARCHAR(50) NOT NULL,
    `members` JSON,
    `bank` INT DEFAULT 0,
    `level` INT DEFAULT 1,
    `exp` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`leader`) REFERENCES `sl_players`(`citizenid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des quêtes
CREATE TABLE IF NOT EXISTS `sl_quests` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `quest_id` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `level_required` INT DEFAULT 1,
    `type` VARCHAR(20) NOT NULL,
    `rewards` JSON,
    `objectives` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des quêtes complétées
CREATE TABLE IF NOT EXISTS `sl_completed_quests` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `quest_id` VARCHAR(50) NOT NULL,
    `completed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`citizenid`) REFERENCES `sl_players`(`citizenid`) ON DELETE CASCADE,
    FOREIGN KEY (`quest_id`) REFERENCES `sl_quests`(`quest_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des items
CREATE TABLE IF NOT EXISTS `sl_items` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `item_id` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `type` VARCHAR(20) NOT NULL,
    `description` TEXT,
    `stats` JSON,
    `stackable` BOOLEAN DEFAULT FALSE,
    `max_stack` INT DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des boutiques
CREATE TABLE IF NOT EXISTS `sl_shops` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `shop_id` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `npc` VARCHAR(50) NOT NULL,
    `items` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des logs
CREATE TABLE IF NOT EXISTS `sl_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `type` VARCHAR(10) NOT NULL,
    `category` VARCHAR(50) NOT NULL,
    `message` TEXT NOT NULL,
    `data` JSON,
    `timestamp` INT NOT NULL,
    `server` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des donjons
CREATE TABLE IF NOT EXISTS `sl_dungeons` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `dungeon_id` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `min_level` INT DEFAULT 1,
    `max_level` INT DEFAULT 100,
    `waves` INT DEFAULT 1,
    `rewards` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des monstres
CREATE TABLE IF NOT EXISTS `sl_mobs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `mob_id` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `level` INT DEFAULT 1,
    `health` INT DEFAULT 100,
    `damage` INT DEFAULT 10,
    `exp` INT DEFAULT 50,
    `gold` INT DEFAULT 25,
    `drops` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des recettes de crafting
CREATE TABLE IF NOT EXISTS `sl_recipes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `recipe_id` VARCHAR(50) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `required_level` INT DEFAULT 1,
    `materials` JSON,
    `result` JSON,
    `crafting_time` INT DEFAULT 30,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des traductions
CREATE TABLE IF NOT EXISTS `sl_translations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `language` VARCHAR(2) NOT NULL,
    `key` VARCHAR(100) NOT NULL,
    `text` TEXT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `lang_key` (`language`, `key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion des données de base

-- Insertion des quêtes de base
INSERT INTO `sl_quests` (`quest_id`, `name`, `description`, `level_required`, `type`, `rewards`, `objectives`) VALUES
('quest_001', 'Début du Voyage', 'Commencez votre aventure en parlant au guide du village', 1, 'main', 
'{"exp": 100, "gold": 50, "items": [{"id": "item_001", "amount": 1}]}',
'[{"type": "talk", "target": "npc_guide", "description": "Parler au guide du village"}]');

-- Insertion des items de base
INSERT INTO `sl_items` (`item_id`, `name`, `type`, `description`, `stats`, `stackable`, `max_stack`) VALUES
('item_001', 'Cristal d\'Ombre', 'material', 'Un cristal mystérieux qui émane des ombres', NULL, TRUE, 99),
('item_002', 'Épée en Fer', 'weapon', 'Une épée basique en fer', '{"damage": 10, "durability": 100}', FALSE, 1);

-- Insertion des boutiques de base
INSERT INTO `sl_shops` (`shop_id`, `name`, `npc`, `items`) VALUES
('shop_001', 'Boutique du Forgeron', 'npc_blacksmith',
'[{"id": "item_001", "price": 100, "stock": 5}, {"id": "item_002", "price": 150, "stock": 3}]');

-- Insertion des donjons de base
INSERT INTO `sl_dungeons` (`dungeon_id`, `name`, `min_level`, `max_level`, `waves`, `rewards`) VALUES
('dungeon_001', 'Donjon des Ombres', 10, 20, 5,
'{"exp": 1000, "gold": 500, "items": [{"id": "item_001", "chance": 0.1}, {"id": "item_002", "chance": 0.05}]}');

-- Insertion des monstres de base
INSERT INTO `sl_mobs` (`mob_id`, `name`, `level`, `health`, `damage`, `exp`, `gold`, `drops`) VALUES
('mob_001', 'Loup des Ombres', 10, 100, 15, 50, 25,
'[{"id": "item_001", "chance": 0.1}, {"id": "item_002", "chance": 0.05}]');

-- Insertion des recettes de base
INSERT INTO `sl_recipes` (`recipe_id`, `name`, `description`, `required_level`, `materials`, `result`, `crafting_time`) VALUES
('recipe_001', 'Épée en Acier', 'Une épée plus résistante que l\'épée en fer', 5,
'[{"id": "iron_ingot", "amount": 3}, {"id": "steel_ingot", "amount": 2}, {"id": "wood", "amount": 1}]',
'{"id": "sword_002", "amount": 1}', 30);

-- Insertion des traductions de base
INSERT INTO `sl_translations` (`language`, `key`, `text`) VALUES
('fr', 'welcome', 'Bienvenue dans Solo Leveling !'),
('fr', 'level_up', 'Niveau %d atteint !'),
('fr', 'quest_complete', 'Quête terminée : %s'),
('en', 'welcome', 'Welcome to Solo Leveling!'),
('en', 'level_up', 'Reached level %d!'),
('en', 'quest_complete', 'Quest completed: %s'); 