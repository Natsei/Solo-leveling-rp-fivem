// Gestion de l'interface NUI Solo Leveling - Rang
let rankData = {
    name: 'E',
    color: '#00ff99',
    xp: 0,
    xpToNext: 1000,
    nextRank: 'D',
    nextBonus: '+5% d\'attaque',
    history: [
        'Débutant classé E',
        'A rejoint le serveur',
    ]
};

function updateUI() {
    document.getElementById('rank-name').textContent = rankData.name;
    document.getElementById('rank-color').style.background = rankData.color;
    document.getElementById('xp-text').textContent = `${rankData.xp} / ${rankData.xpToNext} XP de rang`;
    document.getElementById('xp-fill').style.width = `${Math.min(100, (rankData.xp / rankData.xpToNext) * 100)}%`;
    document.getElementById('next-rank').textContent = rankData.nextRank;
    document.getElementById('next-rank-info').textContent = `Bonus : ${rankData.nextBonus}`;
    // Historique
    const historyList = document.getElementById('rank-history');
    historyList.innerHTML = '';
    rankData.history.forEach(item => {
        const li = document.createElement('li');
        li.textContent = item;
        historyList.appendChild(li);
    });
}

// Réception des données depuis Lua
window.addEventListener('message', (event) => {
    if (event.data.type === 'openRankUI') {
        rankData = event.data.rankData;
        updateUI();
        document.body.style.display = 'block';
    }
    if (event.data.type === 'closeRankUI') {
        document.body.style.display = 'none';
    }
});

window.onload = () => {
    updateUI();
    document.body.style.display = 'none';
}; 