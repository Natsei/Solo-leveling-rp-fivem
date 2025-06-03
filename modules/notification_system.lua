--[[
    Solo Leveling FiveM Server
    Notification System Module
    Author: Claude
    Version: 1.0.0
]]

local NotificationSystem = {}

-- Types de notifications
local NotificationTypes = {
    INFO = 'info',
    SUCCESS = 'success',
    WARNING = 'warning',
    ERROR = 'error'
}

-- Configuration des notifications
local Notifications = {
    {
        id = 'level_up',
        type = NotificationTypes.SUCCESS,
        title = 'Niveau Supérieur !',
        message = 'Vous avez atteint le niveau %d !',
        duration = 5000
    },
    {
        id = 'quest_complete',
        type = NotificationTypes.SUCCESS,
        title = 'Quête Terminée',
        message = 'Vous avez complété la quête : %s',
        duration = 5000
    },
    {
        id = 'item_obtained',
        type = NotificationTypes.INFO,
        title = 'Item Obtenu',
        message = 'Vous avez obtenu : %s x%d',
        duration = 3000
    },
    {
        id = 'gold_obtained',
        type = NotificationTypes.INFO,
        title = 'Or Obtenu',
        message = 'Vous avez obtenu %d pièces d\'or',
        duration = 3000
    }
}

-- Envoyer une notification à un joueur
function NotificationSystem.SendNotification(citizenid, notificationId, ...)
    local notification = nil
    for _, n in ipairs(Notifications) do
        if n.id == notificationId then
            notification = n
            break
        end
    end
    
    if not notification then return false end
    
    local message = string.format(notification.message, ...)
    
    -- Envoyer la notification au client
    TriggerClientEvent('sl:showNotification', citizenid, {
        type = notification.type,
        title = notification.title,
        message = message,
        duration = notification.duration
    })
    
    return true
end

-- Envoyer une notification personnalisée
function NotificationSystem.SendCustomNotification(citizenid, type, title, message, duration)
    duration = duration or 3000
    
    if not NotificationTypes[type] then
        type = NotificationTypes.INFO
    end
    
    TriggerClientEvent('sl:showNotification', citizenid, {
        type = type,
        title = title,
        message = message,
        duration = duration
    })
    
    return true
end

-- Envoyer une notification à tous les joueurs
function NotificationSystem.BroadcastNotification(notificationId, ...)
    local notification = nil
    for _, n in ipairs(Notifications) do
        if n.id == notificationId then
            notification = n
            break
        end
    end
    
    if not notification then return false end
    
    local message = string.format(notification.message, ...)
    
    TriggerClientEvent('sl:showNotification', -1, {
        type = notification.type,
        title = notification.title,
        message = message,
        duration = notification.duration
    })
    
    return true
end

-- Envoyer une notification personnalisée à tous les joueurs
function NotificationSystem.BroadcastCustomNotification(type, title, message, duration)
    duration = duration or 3000
    
    if not NotificationTypes[type] then
        type = NotificationTypes.INFO
    end
    
    TriggerClientEvent('sl:showNotification', -1, {
        type = type,
        title = title,
        message = message,
        duration = duration
    })
    
    return true
end

return NotificationSystem 