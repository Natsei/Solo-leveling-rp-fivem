# Interface NUI - Système de Rang

- Placez ce dossier dans web/rank/
- Ajoutez l'ouverture de l'UI via un TriggerClientEvent côté client :

```
TriggerEvent('sl-core:client:OpenRankUI', {
    rankData = {
        name = 'C',
        color = '#a259ff',
        xp = 3200,
        xpToNext = 5000,
        nextRank = 'B',
        nextBonus = '+10% de défense',
        history = {
            'A atteint le rang D',
            'A terminé un donjon',
            'A rejoint une guilde'
        }
    }
})
```

- Utilisez SendNUIMessage côté client pour envoyer les données à l'UI. 