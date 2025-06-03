// Gestion de l'interface NUI Solo Leveling - Donjons
let dungeonData = {
    dungeons: [
        {
            icon: '../assets/dungeon1.png',
            name: 'Entrée de la Caverne',
            desc: 'Un donjon pour débutants rempli de gobelins.',
            info: 'Niveau min : 1 | Rang : E',
            rewards: 'XP, loot de base',
            prereq: '',
        },
        {
            icon: '../assets/dungeon2.png',
            name: 'Mine Abandonnée',
            desc: 'Des squelettes et zombies rôdent dans l'obscurité.',
            info: 'Niveau min : 5 | Rang : D',
            rewards: 'XP, loot rare',
            prereq: '',
        }
    ],
    party: [
        { name: 'Sung Jinwoo', class: 'Assassin' },
        { name: 'Yoo Jinho', class: 'Tank' }
    ],
    selected: 0
};

function updateUI() {
    // Liste des donjons
    const dungeonsList = document.getElementById('dungeons-list');
    dungeonsList.innerHTML = '';
    dungeonData.dungeons.forEach((dungeon, idx) => {
        const div = document.createElement('div');
        div.className = 'dungeon-item' + (dungeonData.selected === idx ? ' selected' : '');
        div.innerHTML = `
            <img src="${dungeon.icon}" class="dungeon-icon" alt="Donjon">
            <div class="dungeon-name">${dungeon.name}</div>
            <div class="dungeon-desc">${dungeon.desc}</div>
            <div class="dungeon-info">${dungeon.info}</div>
            <div class="dungeon-rewards">Récompenses : ${dungeon.rewards}</div>
            ${dungeon.prereq ? `<div class="dungeon-prereq">${dungeon.prereq}</div>` : ''}
        `;
        div.addEventListener('click', () => {
            dungeonData.selected = idx;
            updateUI();
        });
        dungeonsList.appendChild(div);
    });
    // Groupe
    const partyList = document.getElementById('party-list');
    partyList.innerHTML = '';
    dungeonData.party.forEach(member => {
        const div = document.createElement('div');
        div.className = 'party-member';
        div.textContent = `${member.name} (${member.class})`;
        partyList.appendChild(div);
    });
}

document.getElementById('join-dungeon-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/joinDungeon`, {
        method: 'POST',
        body: JSON.stringify({ dungeonIndex: dungeonData.selected })
    });
});

// Réception des données depuis Lua
window.addEventListener('message', (event) => {
    if (event.data.type === 'openDungeonUI') {
        dungeonData = event.data.dungeonData;
        updateUI();
        document.body.style.display = 'block';
    }
    if (event.data.type === 'closeDungeonUI') {
        document.body.style.display = 'none';
    }
});

window.onload = () => {
    updateUI();
    document.body.style.display = 'none';
}; 