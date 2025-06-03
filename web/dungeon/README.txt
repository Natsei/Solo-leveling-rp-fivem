# Interface NUI - Système de Donjon

- Placez ce dossier dans web/dungeon/
- Ajoutez l'ouverture de l'UI via un TriggerClientEvent côté client :

```
TriggerEvent('sl-core:client:OpenDungeonUI', {
    dungeonData = {
        dungeons = {
            {
                icon = '../assets/dungeon1.png',
                name = 'Entrée de la Caverne',
                desc = 'Un donjon pour débutants rempli de gobelins.',
                info = 'Niveau min : 1 | Rang : E',
                rewards = 'XP, loot de base',
                prereq = ''
            },
            {
                icon = '../assets/dungeon2.png',
                name = 'Mine Abandonnée',
                desc = 'Des squelettes et zombies rôdent dans l\'obscurité.',
                info = 'Niveau min : 5 | Rang : D',
                rewards = 'XP, loot rare',
                prereq = ''
            }
        },
        party = {
            { name = 'Sung Jinwoo', class = 'Assassin' },
            { name = 'Yoo Jinho', class = 'Tank' }
        },
        selected = 0
    }
})
```

- Utilisez SendNUIMessage côté client pour envoyer les données à l'UI.
- Ajoutez le callback NUI pour `joinDungeon` côté client Lua. 