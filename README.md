# 🎮 Solo Leveling FiveM

<div align="center">
  <img src="https://www.editions-soleil.fr/sites/default/files/styles/bandeau_s/public/2022-03/solo-leveling-bandeau.jpg?h=59e9a709&itok=GF7cFxOV" alt="Solo Leveling FiveM" width="400"/>
  
  [![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)](https://github.com/Natsei/Solo-leveling-rp-fivem)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Discord](https://img.shields.io/discord/1189522321912897536?color=7289DA&label=Discord&logo=discord&logoColor=blue)](https://discord.gg/t58J287N)
</div>

## 📖 Description

Solo Leveling FiveM est un système de progression RPG inspiré du manhwa "Solo Leveling", intégré parfaitement dans l'univers de FiveM. Ce système permet aux joueurs de vivre une expérience unique de progression, de combat et d'évolution de personnage.

## ✨ Fonctionnalités

### 🎯 Système de Classes
- 6 classes de base : Tank, Mage, Épéiste, Assassin, Archer, Soigneur
- Classes avancées débloquables
- Système de progression unique
- Capacités spéciales par classe

### 🎒 Système d'Inventaire
- Interface moderne et intuitive
- Gestion des objets avec tooltips détaillés
- Système de rareté des objets
- Support des équipements

### 📜 Système de Quêtes
- Quêtes dynamiques et progressives
- Récompenses adaptées au niveau
- Suivi de progression en temps réel
- Quêtes spéciales pour les classes avancées

### 🏰 Donjons
- Donjons générés dynamiquement
- Difficulté adaptative
- Système de vagues
- Récompenses exclusives

## 🚀 Installation

1. Téléchargez la dernière version
2. Placez le dossier dans votre répertoire `resources`
3. Ajoutez `ensure solo-leveling` dans votre `server.cfg`
4. Importez le fichier `db.sql` dans votre base de données
5. Redémarrez votre serveur

## ⚙️ Configuration

```lua
Config = {
    Debug = false,
    StartingLevel = 1,
    MaxLevel = 100,
    ExpMultiplier = 1.0,
    GoldMultiplier = 1.0
}
```

## 🛠️ Dépendances

- oxmysql
- es_extended (optionnel)
- qb-core (optionnel)

## 📋 Prérequis

- FiveM Server
- MySQL Database
- PHP 7.4+ (pour le panel web)

## 🎨 Interface

L'interface utilisateur est moderne et responsive, avec :
- Barre de statut en temps réel
- Inventaire intuitif
- Système de notifications élégant
- Tooltips détaillés
- Animations fluides

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 License

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🙏 Remerciements

- [Solo Leveling](https://solo-leveling.fandom.com/) pour l'inspiration
- La communauté FiveM pour le support
- Tous les contributeurs

## 📞 Support

- Discord : [Rejoindre le serveur](https://discord.gg/t58J287N)
- Issues : [GitHub Issues](https://github.com/Natsei/Solo-leveling-rp-fivem/issues)

---

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/Natsei">natsei</a></sub>
</div>

## Structure du Projet

```
solo-leveling/
├── modules/
│   ├── class_system.lua
│   ├── level_system.lua
│   ├── quest_system.lua
│   ├── inventory_system.lua
│   ├── crafting_system.lua
│   ├── trading_system.lua
│   ├── dungeon_system.lua
│   ├── guild_system.lua
│   ├── rank_system.lua
│   ├── notification_system.lua
│   ├── log_system.lua
│   └── localization_system.lua
├── web/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── config.lua
├── server.lua
├── client.lua
├── core.lua
├── fxmanifest.lua
└── db.sql
```

## Développement

### Ajouter une Nouvelle Classe
1. Modifiez `modules/class_system.lua`
2. Ajoutez la nouvelle classe dans la table `Classes`
3. Définissez les statistiques de base et les capacités

### Ajouter une Nouvelle Quête
1. Modifiez `modules/quest_system.lua`
2. Ajoutez la nouvelle quête dans la table `Quests`
3. Définissez les objectifs et les récompenses

### Ajouter une Nouvelle Traduction
1. Modifiez `modules/localization_system.lua`
2. Ajoutez les nouvelles traductions dans la table `Translations`

## Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créez une branche pour votre fonctionnalité
3. Committez vos changements
4. Poussez vers la branche
5. Ouvrez une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## Support

Pour toute question ou problème :
- Ouvrez une issue sur GitHub
- Contactez-nous sur Discord
- Consultez la documentation

## Crédits

- Développé par natsei
- Inspiré par le manhwa Solo Leveling
- Utilise le framework FiveM
