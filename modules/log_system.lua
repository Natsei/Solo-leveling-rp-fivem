--[[
    Solo Leveling FiveM Server
    Log System Module
    Author: Claude
    Version: 1.0.0
]]

local LogSystem = {}

-- Types de logs
local LogTypes = {
    INFO = 'info',
    WARNING = 'warning',
    ERROR = 'error',
    DEBUG = 'debug'
}

-- Configuration des logs
local LogConfig = {
    enabled = true,
    logToFile = true,
    logToDatabase = true,
    logLevel = LogTypes.INFO,
    maxLogAge = 30 -- jours
}

-- Créer un nouveau log
function LogSystem.CreateLog(type, category, message, data)
    if not LogConfig.enabled then return end
    
    if not LogTypes[type] then
        type = LogTypes.INFO
    end
    
    local logEntry = {
        type = type,
        category = category,
        message = message,
        data = data or {},
        timestamp = os.time(),
        server = GetConvar('sv_hostname', 'Unknown')
    }
    
    -- Log dans la console
    local logMessage = string.format('[%s] [%s] %s', type, category, message)
    if type == LogTypes.ERROR then
        print('^1' .. logMessage .. '^7')
    elseif type == LogTypes.WARNING then
        print('^3' .. logMessage .. '^7')
    else
        print('^2' .. logMessage .. '^7')
    end
    
    -- Log dans un fichier
    if LogConfig.logToFile then
        local logFile = io.open('logs/' .. os.date('%Y-%m-%d') .. '.log', 'a')
        if logFile then
            logFile:write(string.format('[%s] %s\n', os.date('%H:%M:%S'), logMessage))
            logFile:close()
        end
    end
    
    -- Log dans la base de données
    if LogConfig.logToDatabase then
        MySQL.Async.execute('INSERT INTO sl_logs (type, category, message, data, timestamp, server) VALUES (?, ?, ?, ?, ?, ?)',
            {type, category, message, json.encode(data or {}), os.time(), GetConvar('sv_hostname', 'Unknown')})
    end
end

-- Nettoyer les vieux logs
function LogSystem.CleanOldLogs()
    if not LogConfig.logToDatabase then return end
    
    local cutoffDate = os.time() - (LogConfig.maxLogAge * 24 * 60 * 60)
    MySQL.Async.execute('DELETE FROM sl_logs WHERE timestamp < ?', {cutoffDate})
end

-- Obtenir les logs
function LogSystem.GetLogs(type, category, startDate, endDate, limit)
    limit = limit or 100
    
    local query = 'SELECT * FROM sl_logs WHERE 1=1'
    local params = {}
    
    if type then
        query = query .. ' AND type = ?'
        table.insert(params, type)
    end
    
    if category then
        query = query .. ' AND category = ?'
        table.insert(params, category)
    end
    
    if startDate then
        query = query .. ' AND timestamp >= ?'
        table.insert(params, startDate)
    end
    
    if endDate then
        query = query .. ' AND timestamp <= ?'
        table.insert(params, endDate)
    end
    
    query = query .. ' ORDER BY timestamp DESC LIMIT ?'
    table.insert(params, limit)
    
    return MySQL.Sync.fetchAll(query, params)
end

-- Logs spécifiques
function LogSystem.LogPlayerAction(citizenid, action, data)
    LogSystem.CreateLog(LogTypes.INFO, 'player_action', string.format('Player %s performed action: %s', citizenid, action), data)
end

function LogSystem.LogItemTransaction(citizenid, itemId, amount, type)
    LogSystem.CreateLog(LogTypes.INFO, 'item_transaction', 
        string.format('Player %s %s %d of item %s', citizenid, type, amount, itemId))
end

function LogSystem.LogQuestProgress(citizenid, questId, progress)
    LogSystem.CreateLog(LogTypes.INFO, 'quest_progress',
        string.format('Player %s progressed in quest %s', citizenid, questId), progress)
end

function LogSystem.LogError(error, context)
    LogSystem.CreateLog(LogTypes.ERROR, 'system_error', error, context)
end

-- Initialisation
CreateThread(function()
    if LogConfig.logToFile then
        os.execute('mkdir logs 2>nul')
    end
    
    if LogConfig.logToDatabase then
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS sl_logs (
                id INT AUTO_INCREMENT PRIMARY KEY,
                type VARCHAR(10) NOT NULL,
                category VARCHAR(50) NOT NULL,
                message TEXT NOT NULL,
                data JSON,
                timestamp INT NOT NULL,
                server VARCHAR(255) NOT NULL
            )
        ]])
        
        -- Nettoyer les vieux logs tous les jours
        while true do
            LogSystem.CleanOldLogs()
            Wait(24 * 60 * 60 * 1000) -- 24 heures
        end
    end
end)

return LogSystem 