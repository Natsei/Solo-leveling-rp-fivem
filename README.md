# Solo Leveling FiveM Server

Un système modulaire pour serveur FiveM inspiré de l'univers Solo Leveling, offrant une expérience RPG-MMO unique avec progression individuelle, donjons, classes évolutives et système de classement.

## 🚀 Fonctionnalités

- Système de rang (E à National)
- Classes de base et avancées
- Système de pouvoirs avec différents types de magie
- Donjons instanciés
- Système de guilde
- Progression de niveau avec statistiques
- Mobs et boss avec IA
- Système de loot et récompenses

## 📋 Prérequis

- FiveM Server
- QBCore Framework
- MySQL
- ox_lib
- ox_target
- ox_inventory

## 🛠️ Installation

1. Clonez ce dépôt dans votre dossier `resources`
2. Importez le fichier SQL dans votre base de données
3. Ajoutez `ensure sl-core` dans votre `server.cfg`
4. Configurez les paramètres dans `config.lua`

## 📦 Structure des Modules

```
/core/
  ├── core.lua           # Point d'entrée principal
  └── modules/
      ├── rank_system.lua    # Système de rang
      ├── class_system.lua   # Système de classe
      ├── dungeon_system.lua # Système de donjon
      ├── power_system.lua   # Système de pouvoirs
      ├── mob_system.lua     # Système de mobs
      ├── guild_system.lua   # Système de guilde
      └── level_system.lua   # Système de niveau
```

## 🎮 Utilisation

### Système de Rang

```lua
-- Obtenir le rang d'un joueur
local rank = exports['sl-core']:GetPlayerRank(source)

-- Ajouter de l'XP de rang
exports['sl-core']:AddRankXP(citizenid, amount)
```

### Système de Classe

```lua
-- Définir la classe d'un joueur
exports['sl-core']:SetPlayerClass(citizenid, classId)

-- Évoluer vers une classe avancée
exports['sl-core']:EvolveClass(citizenid, advancedClassId)
```

### Système de Donjon

```lua
-- Créer une instance de donjon
local instanceId = exports['sl-core']:CreateDungeonInstance(dungeonId, players)

-- Gérer la vague de monstres
exports['sl-core']:HandleWave(instanceId)
```

### Système de Pouvoirs

```lua
-- Apprendre un sort
exports['sl-core']:LearnSpell(citizenid, spellId)

-- Utiliser un sort
exports['sl-core']:CastSpell(citizenid, spellId, target)
```

### Système de Guilde

```lua
-- Créer une guilde
exports['sl-core']:CreateGuild(citizenid, name, description)

-- Rejoindre une guilde
exports['sl-core']:JoinGuild(citizenid, guildName)
```

### Système de Niveau

```lua
-- Ajouter de l'XP
exports['sl-core']:AddXP(citizenid, amount)

-- Obtenir les statistiques
local stats = exports['sl-core']:GetPlayerStats(citizenid)
```

## 🔧 Configuration

Modifiez les paramètres dans `config.lua` pour personnaliser :

- XP requis par niveau
- Statistiques de base
- Types de mobs
- Donjons disponibles
- Sorts et capacités
- Rangs et récompenses

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🙏 Remerciements

- L'équipe QBCore pour leur framework
- La communauté FiveM
- Les créateurs de Solo Leveling pour l'inspiration

## Choix de l'interface : NUI ou RageUI

Dans `config.lua`, modifiez la ligne suivante pour choisir l'interface :

```lua
Config.UIEnabled = true -- true = NUI Solo Leveling, false = RageUI ESX
```

- Si `true` : interfaces immersives NUI (HTML/CSS/JS)
- Si `false` : menus classiques RageUI (ESX)

Assurez-vous d'avoir la ressource RageUI installée si vous utilisez ce mode.

## Ajout d'assets visuels

Placez vos icônes (PNG, SVG) dans le dossier `web/assets/`.

- Flaticon : https://www.flaticon.com/
- Game-icons.net : https://game-icons.net/
- OpenGameArt : https://opengameart.org/

Nommez les fichiers selon la convention : `nom_pouvoir.png` ou `nom_pouvoir.svg`. 