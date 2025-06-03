# Interface NUI - Système de Niveau/Statistiques

- Placez ce dossier dans web/level/
- Ajoutez l'ouverture de l'UI via un TriggerClientEvent côté client :

```
TriggerEvent('sl-core:client:OpenLevelUI', {
    stats = {strength = 10, agility = 10, intelligence = 10, vitality = 10},
    baseStats = {strength = 10, agility = 10, intelligence = 10, vitality = 10},
    pointsRemaining = 5,
    level = 5,
    xp = 123,
    xpToNext = 200
})
```

- Utilisez SendNUIMessage côté client pour envoyer les données à l'UI.
- Ajoutez les callbacks NUI pour `resetStats` et `saveStats` côté client Lua. 