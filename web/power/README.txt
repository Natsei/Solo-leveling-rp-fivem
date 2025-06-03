# Interface NUI - Système de Pouvoirs

- Placez ce dossier dans web/power/
- Ajoutez l'ouverture de l'UI via un TriggerClientEvent côté client :

```
TriggerEvent('sl-core:client:OpenPowerUI', {
    powerData = {
        magicType = 'Ombre',
        spells = {
            {
                icon = '../assets/spell_shadow.png',
                name = 'Éclair d\'Ombre',
                desc = 'Inflige des dégâts continus.',
                level = 3,
                mana = 40,
                cooldown = 6
            },
            {
                icon = '../assets/spell_fireball.png',
                name = 'Boule de Feu',
                desc = 'Lance une boule de feu explosive.',
                level = 2,
                mana = 30,
                cooldown = 5
            }
        }
    }
})
```

- Utilisez SendNUIMessage côté client pour envoyer les données à l'UI.
- Ajoutez le callback NUI pour `upgradeSpell` côté client Lua.

---

# Ajout d'icônes pour les pouvoirs

Pour personnaliser les visuels des pouvoirs, placez vos icônes (PNG, SVG) dans le dossier `web/assets/` à la racine du dossier `web`.

- Flaticon : https://www.flaticon.com/
- Game-icons.net : https://game-icons.net/
- OpenGameArt : https://opengameart.org/

Nommez les fichiers selon la convention : `nom_pouvoir.png` ou `nom_pouvoir.svg`.

Ensuite, référencez-les dans le code NUI (HTML/JS) ou dans vos menus RageUI si besoin. 