# Interface NUI - Système de Classe

- Placez ce dossier dans web/class/
- Ajoutez l'ouverture de l'UI via un TriggerClientEvent côté client :

```
TriggerEvent('sl-core:client:OpenClassUI', {
    classData = {
        id = 'assassin',
        name = 'Assassin',
        description = 'Maître de la furtivité et des coups critiques',
        baseStats = { strength = 12, agility = 20, intelligence = 8, vitality = 8 },
        portrait = '../assets/portrait.png',
        skills = {
            { icon = '../assets/skill1.png', name = 'Furtivité', desc = 'Devenez invisible pendant 5s.', cooldown = 20, mana = 35 },
            { icon = '../assets/skill2.png', name = 'Coup dans le Dos', desc = 'Inflige de lourds dégâts critiques.', cooldown = 8, mana = 30 }
        }
    }
})
```

- Utilisez SendNUIMessage côté client pour envoyer les données à l'UI.
- Ajoutez le callback NUI pour `changeClass` côté client Lua. 