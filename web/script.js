// Variables globales
let playerData = null;
let tooltipTimeout = null;

// Initialisation
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch (data.type) {
        case 'initialize':
            initializeUI(data.data);
            break;
        case 'notification':
            showNotification(data.data);
            break;
        case 'showClassInfo':
            showClassUI(data.data);
            break;
        case 'showInventory':
            showInventoryUI(data.data);
            break;
        case 'updateQuestProgress':
            updateQuestProgress(data.data);
            break;
        case 'updatePlayerData':
            updatePlayerData(data.data);
            break;
    }
});

// Initialisation de l'interface
function initializeUI(data) {
    playerData = data;
    document.getElementById('main-ui').classList.remove('hidden');
    updateStatusBar();
}

// Mise à jour de la barre de statut
function updateStatusBar() {
    if (!playerData) return;
    
    const levelElement = document.getElementById('player-level');
    const expElement = document.getElementById('player-exp');
    const goldElement = document.getElementById('player-gold');
    
    levelElement.textContent = `Niveau ${playerData.level}`;
    expElement.textContent = `${playerData.exp}/${playerData.nextLevelExp} XP`;
    goldElement.textContent = `${playerData.gold} 🪙`;
    
    // Mise à jour de la barre de progression XP
    const expProgress = (playerData.exp / playerData.nextLevelExp) * 100;
    const progressBar = expElement.parentElement.querySelector('.progress-bar');
    if (progressBar) {
        const progressFill = progressBar.querySelector('.progress-fill');
        if (progressFill) {
            progressFill.style.width = `${expProgress}%`;
        }
    }
}

// Mise à jour des données du joueur
function updatePlayerData(data) {
    playerData = { ...playerData, ...data };
    updateStatusBar();
}

// Affichage des notifications
function showNotification(data) {
    const container = document.getElementById('notification-container');
    const notification = document.createElement('div');
    notification.className = `notification ${data.type}`;
    notification.innerHTML = `
        <h3>${data.title}</h3>
        <p>${data.message}</p>
    `;
    
    container.appendChild(notification);
    
    // Animation de sortie
    setTimeout(() => {
        notification.style.opacity = '0';
        setTimeout(() => notification.remove(), 300);
    }, data.duration || 3000);
}

// Interface de classe
function showClassUI(classData) {
    const classUI = document.getElementById('class-ui');
    const className = document.getElementById('class-name');
    const statsList = document.getElementById('class-stats-list');
    const abilitiesList = document.getElementById('class-abilities-list');
    
    className.textContent = classData.name;
    
    // Statistiques
    statsList.innerHTML = '';
    for (const [stat, value] of Object.entries(classData.baseStats)) {
        const statElement = document.createElement('div');
        statElement.className = 'stat-item';
        statElement.innerHTML = `
            <span class="stat-name">${formatStatName(stat)}</span>
            <span class="stat-value">${value}</span>
        `;
        statsList.appendChild(statElement);
    }
    
    // Capacités
    abilitiesList.innerHTML = '';
    classData.abilities.forEach(ability => {
        const abilityElement = document.createElement('div');
        abilityElement.className = 'ability-item';
        abilityElement.innerHTML = `
            <h4>${ability.name}</h4>
            <p>Temps de recharge: ${ability.cooldown}s</p>
            <p>Coût en mana: ${ability.manaCost}</p>
        `;
        abilitiesList.appendChild(abilityElement);
    });
    
    classUI.classList.remove('hidden');
}

function formatStatName(stat) {
    const statNames = {
        strength: 'Force',
        agility: 'Agilité',
        intelligence: 'Intelligence',
        vitality: 'Vitalité'
    };
    return statNames[stat] || stat;
}

function closeClassUI() {
    document.getElementById('class-ui').classList.add('hidden');
}

// Interface d'inventaire
function showInventoryUI(inventory) {
    const inventoryUI = document.getElementById('inventory-ui');
    const inventoryGrid = document.getElementById('inventory-grid');
    
    inventoryGrid.innerHTML = '';
    inventory.forEach((item, index) => {
        const slot = document.createElement('div');
        slot.className = 'inventory-slot';
        if (item) {
            slot.innerHTML = `
                <div class="item" data-item-id="${item.id}">
                    <img src="items/${item.id}.png" alt="${item.name}">
                    <span class="item-name">${item.name}</span>
                    ${item.amount > 1 ? `<span class="item-amount">${item.amount}</span>` : ''}
                </div>
            `;
            
            // Gestion des tooltips
            slot.addEventListener('mouseenter', () => showItemTooltip(slot, item));
            slot.addEventListener('mouseleave', hideItemTooltip);
            
            slot.onclick = () => useItem(item.id);
        }
        inventoryGrid.appendChild(slot);
    });
    
    inventoryUI.classList.remove('hidden');
}

function closeInventoryUI() {
    document.getElementById('inventory-ui').classList.add('hidden');
}

function useItem(itemId) {
    fetch(`https://${GetParentResourceName()}/useItem`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            itemId: itemId
        })
    });
}

// Gestion des tooltips
function showItemTooltip(element, item) {
    if (tooltipTimeout) {
        clearTimeout(tooltipTimeout);
    }
    
    tooltipTimeout = setTimeout(() => {
        const tooltip = document.createElement('div');
        tooltip.className = 'item-tooltip';
        tooltip.innerHTML = `
            <h4>${item.name}</h4>
            ${item.rarity ? `<div class="item-rarity">${item.rarity}</div>` : ''}
            ${item.stats ? `
                <div class="item-stats">
                    ${Object.entries(item.stats).map(([stat, value]) => `
                        <div>${formatStatName(stat)}: ${value}</div>
                    `).join('')}
                </div>
            ` : ''}
            ${item.description ? `
                <div class="item-description">${item.description}</div>
            ` : ''}
        `;
        
        document.body.appendChild(tooltip);
        
        const rect = element.getBoundingClientRect();
        const tooltipRect = tooltip.getBoundingClientRect();
        
        // Positionnement intelligent du tooltip
        let left = rect.right + 10;
        let top = rect.top;
        
        // Vérifier si le tooltip dépasse à droite
        if (left + tooltipRect.width > window.innerWidth) {
            left = rect.left - tooltipRect.width - 10;
        }
        
        // Vérifier si le tooltip dépasse en bas
        if (top + tooltipRect.height > window.innerHeight) {
            top = window.innerHeight - tooltipRect.height - 10;
        }
        
        tooltip.style.left = `${left}px`;
        tooltip.style.top = `${top}px`;
        
        setTimeout(() => tooltip.classList.add('show'), 10);
    }, 200);
}

function hideItemTooltip() {
    if (tooltipTimeout) {
        clearTimeout(tooltipTimeout);
    }
    
    const tooltip = document.querySelector('.item-tooltip');
    if (tooltip) {
        tooltip.classList.remove('show');
        setTimeout(() => tooltip.remove(), 300);
    }
}

// Interface de quête
function updateQuestProgress(data) {
    const questList = document.getElementById('quest-list');
    const questElement = document.querySelector(`[data-quest-id="${data.questId}"]`);
    
    if (questElement) {
        const progressBar = questElement.querySelector('.quest-progress');
        progressBar.style.width = `${data.progress}%`;
        
        // Animation de progression
        progressBar.style.animation = 'none';
        progressBar.offsetHeight; // Force reflow
        progressBar.style.animation = 'progressShine 2s infinite';
    }
}

// Gestion des touches
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeClassUI();
        closeInventoryUI();
    }
}); 