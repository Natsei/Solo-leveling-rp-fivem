-- Solo Leveling FiveM Server - Structure SQL

CREATE TABLE IF NOT EXISTS sl_players (
    citizenid VARCHAR(50) PRIMARY KEY,
    data LONGTEXT
);

CREATE TABLE IF NOT EXISTS sl_guilds (
    name VARCHAR(50) PRIMARY KEY,
    data LONGTEXT
);

-- Index pour les performances
CREATE INDEX IF NOT EXISTS idx_guild_citizenid ON sl_players (citizenid); 