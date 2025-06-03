// Gestion de l'interface NUI Solo Leveling - Guilde
let guildData = {
    name: 'Shadow Guild',
    description: 'La guilde la plus puissante du serveur.',
    members: [
        { name: 'Sung Jinwoo', role: 'Chef' },
        { name: 'Yoo Jinho', role: 'Officier' },
        { name: 'Han Songyi', role: 'Membre' }
    ]
};

function updateUI() {
    document.getElementById('guild-name').textContent = guildData.name;
    document.getElementById('guild-desc').textContent = guildData.description;
    const membersList = document.getElementById('members-list');
    membersList.innerHTML = '';
    guildData.members.forEach(member => {
        const div = document.createElement('div');
        div.className = 'member-item';
        div.innerHTML = `
            <span>${member.name}</span>
            <span class="member-role">${member.role}</span>
        `;
        membersList.appendChild(div);
    });
}

document.getElementById('invite-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/inviteGuild`, { method: 'POST' });
});

document.getElementById('leave-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/leaveGuild`, { method: 'POST' });
});

// Réception des données depuis Lua
window.addEventListener('message', (event) => {
    if (event.data.type === 'openGuildUI') {
        guildData = event.data.guildData;
        updateUI();
        document.body.style.display = 'block';
    }
    if (event.data.type === 'closeGuildUI') {
        document.body.style.display = 'none';
    }
});

window.onload = () => {
    updateUI();
    document.body.style.display = 'none';
}; 