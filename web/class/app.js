// Gestion de l'interface NUI Solo Leveling - Classe
let classData = {
    id: 'assassin',
    name: 'Assassin',
    description: 'Maître de la furtivité et des coups critiques',
    baseStats: { strength: 12, agility: 20, intelligence: 8, vitality: 8 },
    portrait: '../assets/portrait.png',
    skills: [
        { icon: '../assets/skill1.png', name: 'Furtivité', desc: 'Devenez invisible pendant 5s.', cooldown: 20, mana: 35 },
        { icon: '../assets/skill2.png', name: 'Coup dans le Dos', desc: 'Inflige de lourds dégâts critiques.', cooldown: 8, mana: 30 }
    ]
};

function updateUI() {
    document.getElementById('class-name').textContent = classData.name;
    document.getElementById('class-desc').textContent = classData.description;
    document.querySelector('.portrait').src = classData.portrait;
    document.getElementById('stat-strength').textContent = classData.baseStats.strength;
    document.getElementById('stat-agility').textContent = classData.baseStats.agility;
    document.getElementById('stat-intelligence').textContent = classData.baseStats.intelligence;
    document.getElementById('stat-vitality').textContent = classData.baseStats.vitality;
    // Compétences dynamiques
    const skillsList = document.getElementById('skills-list');
    skillsList.innerHTML = '';
    classData.skills.forEach(skill => {
        const div = document.createElement('div');
        div.className = 'skill-item';
        div.innerHTML = `
            <img src="${skill.icon}" class="skill-icon" alt="Skill">
            <div class="skill-name">${skill.name}</div>
            <div class="skill-desc">${skill.desc}</div>
            <div class="skill-info">Cooldown : ${skill.cooldown}s | Mana : ${skill.mana}</div>
        `;
        skillsList.appendChild(div);
    });
}

document.getElementById('change-class-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/changeClass`, {method: 'POST'});
});

// Réception des données depuis Lua
window.addEventListener('message', (event) => {
    if (event.data.type === 'openClassUI') {
        classData = event.data.classData;
        updateUI();
        document.body.style.display = 'block';
    }
    if (event.data.type === 'closeClassUI') {
        document.body.style.display = 'none';
    }
});

window.onload = () => {
    updateUI();
    document.body.style.display = 'none';
}; 