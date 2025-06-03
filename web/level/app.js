// Gestion de l'interface NUI Solo Leveling - Level/Stats
let stats = {
    strength: 10,
    agility: 10,
    intelligence: 10,
    vitality: 10
};
let baseStats = {...stats};
let pointsRemaining = 0;
let playerLevel = 1;
let playerXP = 0;
let xpToNext = 100;

function updateUI() {
    document.getElementById('player-level').textContent = playerLevel;
    document.getElementById('xp-text').textContent = `${playerXP} / ${xpToNext} XP`;
    document.getElementById('xp-fill').style.width = `${Math.min(100, (playerXP / xpToNext) * 100)}%`;
    document.getElementById('stat-strength').textContent = stats.strength;
    document.getElementById('stat-agility').textContent = stats.agility;
    document.getElementById('stat-intelligence').textContent = stats.intelligence;
    document.getElementById('stat-vitality').textContent = stats.vitality;
    document.getElementById('points-remaining').textContent = pointsRemaining;
    // Calculs détaillés (exemple)
    document.getElementById('stat-attack').textContent = Math.floor(stats.strength * 2.5);
    document.getElementById('stat-defense').textContent = Math.floor(stats.vitality * 2.2);
    document.getElementById('stat-speed').textContent = (100 + stats.agility * 1.5).toFixed(1);
    document.getElementById('stat-mana').textContent = Math.floor(stats.intelligence * 3.1);
}

// Gestion des boutons +/–
document.querySelectorAll('.plus').forEach(btn => {
    btn.addEventListener('click', () => {
        const stat = btn.getAttribute('data-stat');
        if (pointsRemaining > 0) {
            stats[stat]++;
            pointsRemaining--;
            updateUI();
        }
    });
});
document.querySelectorAll('.minus').forEach(btn => {
    btn.addEventListener('click', () => {
        const stat = btn.getAttribute('data-stat');
        if (stats[stat] > baseStats[stat]) {
            stats[stat]--;
            pointsRemaining++;
            updateUI();
        }
    });
});

document.getElementById('reset-btn').addEventListener('click', () => {
    stats = {...baseStats};
    pointsRemaining = 0;
    updateUI();
    fetch(`https://${GetParentResourceName()}/resetStats`, {method: 'POST'});
});

document.getElementById('confirm-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/saveStats`, {
        method: 'POST',
        body: JSON.stringify(stats)
    });
});

// Réception des données depuis Lua
window.addEventListener('message', (event) => {
    if (event.data.type === 'openLevelUI') {
        stats = {...event.data.stats};
        baseStats = {...event.data.baseStats};
        pointsRemaining = event.data.pointsRemaining;
        playerLevel = event.data.level;
        playerXP = event.data.xp;
        xpToNext = event.data.xpToNext;
        updateUI();
        document.body.style.display = 'block';
    }
    if (event.data.type === 'closeLevelUI') {
        document.body.style.display = 'none';
    }
});

// Masquer l'UI par défaut
window.onload = () => {
    document.body.style.display = 'none';
}; 