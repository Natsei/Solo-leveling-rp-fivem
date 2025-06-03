// Gestion de l'interface NUI Solo Leveling - Pouvoirs
let powerData = {
    magicType: 'Feu',
    spells: [
        {
            icon: '../assets/spell_fireball.png',
            name: 'Boule de Feu',
            desc: 'Lance une boule de feu explosive.',
            level: 2,
            mana: 30,
            cooldown: 5
        },
        {
            icon: '../assets/spell_ice.png',
            name: 'Pic de Glace',
            desc: 'Transperce l'ennemi avec un pic de glace.',
            level: 1,
            mana: 35,
            cooldown: 8
        }
    ]
};

function updateUI() {
    document.getElementById('magic-type').textContent = `Type : ${powerData.magicType}`;
    const spellsList = document.getElementById('spells-list');
    spellsList.innerHTML = '';
    powerData.spells.forEach((spell, idx) => {
        const div = document.createElement('div');
        div.className = 'spell-item';
        div.innerHTML = `
            <img src="${spell.icon}" class="spell-icon" alt="Spell">
            <div class="spell-name">${spell.name}</div>
            <div class="spell-desc">${spell.desc}</div>
            <div class="spell-info">Mana : ${spell.mana} | CD : ${spell.cooldown}s</div>
            <div class="spell-level">Niv. ${spell.level}</div>
            <button class="upgrade-btn" data-idx="${idx}">Améliorer</button>
        `;
        spellsList.appendChild(div);
    });
    // Ajout listeners pour les boutons d'amélioration
    document.querySelectorAll('.upgrade-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const idx = btn.getAttribute('data-idx');
            fetch(`https://${GetParentResourceName()}/upgradeSpell`, {
                method: 'POST',
                body: JSON.stringify({ spellIndex: idx })
            });
        });
    });
}

// Réception des données depuis Lua
window.addEventListener('message', (event) => {
    if (event.data.type === 'openPowerUI') {
        powerData = event.data.powerData;
        updateUI();
        document.body.style.display = 'block';
    }
    if (event.data.type === 'closePowerUI') {
        document.body.style.display = 'none';
    }
});

window.onload = () => {
    updateUI();
    document.body.style.display = 'none';
}; 