NomadUI.SQL.Query( [[
    CREATE TABLE IF NOT EXISTS player_profiles (
    steamid64 VARCHAR(17) PRIMARY KEY,
    first_join INTEGER,
    last_join INTEGER,
    total_playtime BIGINT,
    kills INTEGER,
    deaths INTEGER,
    xp INTEGER,
    level INTEGER
    );
]])

util.AddNetworkString("NomadLevels.SendProfileData")

hook.Add("PlayerInitialSpawn", "NomadLevels.PlayerInitiated", function(ply)
    if not IsValid( ply ) or ply:IsBot() then return end

    NomadUI.SQL.Query(string.format("SELECT * FROM `player_profiles` WHERE `steamid64` = '%s' LIMIT 1", ply:SteamID64()), function( queryResult )
        if not IsValid( ply ) then return end

        local currentTime = os.time()
        local steamId = ply:SteamID64()

        if queryResult and not table.IsEmpty( queryResult ) then
            local profile = queryResult[1]
            NomadUI.SQL.Query(string.format("UPDATE `player_profiles` SET last_join = %i WHERE `steamid64` = '%s';", currentTime, steamId))
            ply:SetFirstJoin(profile["first_join"])
            ply:SetLastJoin(currentTime)
            ply:SetPlayTime(profile["total_playtime"])
            ply:SetXP(profile["xp"])
            ply:SetLevel(profile["level"])
        else
            ply:SetFirstJoin(currentTime)
            ply:SetLastJoin(currentTime)
            ply:SetPlayTime(0)
            ply:SetXP(0)
            ply:SetLevel(10)

            NomadUI.SQL.Query(string.format("INSERT INTO `player_profiles` (`steamid64`, `first_join`, `last_join`, `total_playtime`, `kills`, `deaths`, `xp`, `level`) VALUES('%s', %i, %i, 0, 0, 0, 0, 1);", steamId, currentTime, currentTime))
        end
    end)
end)

-- META
local PLAYER = FindMetaTable("Player")

function PLAYER:SetFirstJoin(firstSeen)
    self:Nomad().first_joiun = firstSeen
    self:SetNWString( "NomadLevels.FirstJoin", firstSeen )
end

function PLAYER:GetFirstjoin()
    return self:Nomad().first_seen
end

function PLAYER:SetLastJoin(lastSeen)
    self:Nomad().last_Join = lastSeen
    self:SetNWString( "NomadLevels.LastJoin", lastSeen )
end

function PLAYER:GetLastJoin()
    return self:Nomad().last_join
end

function PLAYER:SetPlayTime(playTime)
    self:Nomad().total_playtime = playTime
    self:SetNWString( "NomadLevels.PlayTime", playTime )
end

function PLAYER:GetPlayTime()
    return self:Nomad().total_playtime
end

function PLAYER:SetJoinTime(joinTime)
    self:Nomad().join_time = joinTime
    self:SetNWString( "NomadLevels..JoinTime", joinTime )
end

function PLAYER:GetJoinTime()
    return self:Nomad().join_time
end

function PLAYER:SetLevel(lvl)
    self:Nomad().level = lvl
    self:SetNWString( "NomadLevels.Level", lvl )

    hook.Run("NomadLevels.LevelledUp", ply, lvl)
    NomadUI.SQL.Query(string.format("UPDATE `player_profiles` SET level = %u WHERE `steamid64` = '%s'", lvl, self:SteamID64()))
end

function PLAYER:GetLevel()
    return self:Nomad().level
end

function PLAYER:SetXP(xp)
    self:Nomad().xp = xp
    self:SetNWString( "NomadLevels.XP", xp )

    hook.Run("NomadLevels.XPReceived", ply, xp)
    NomadUI.SQL.Query(string.format("UPDATE `player_profiles` SET xp = %u WHERE `steamid64` = '%s'", xp, self:SteamID64()))
end

function PLAYER:GetXP()
    return self:Nomad().xp
end

function PLAYER:SaveProfile()
    local profile = self:Nomad()
    local profileData = {
        level = profile.level,
        xp = profile.xp,
        total_playtime = profile.total_playtime,
    }
    NomadUI.SQL.Query(string.format("UPDATE `player_profiles` SET total_playtime = %i, level = %i, xp = %i WHERE `steamid64` = '%s';", self:SteamID64(), profileData.total_playtime, profileData.level, profileData.xp))
    hook.Run("NomadLevels.PlayerSaved", self, profile)
end

function NomadLevels.AddPlayerXP(ply, xpToAdd)
    if not IsValid(ply) then return end
    if ply:IsBot() then return end

    local curLvl = ply:GetLevel()
    local newLvl = curLvl + 1

    local curXP = ply:GetXP()
    local neededXP = NomadLevels.XPForLevel(newLvl)
    local newXP = curXP + xpToAdd

    while newXP >= neededXP do
        newXP = newXP - neededXP
        curLvl = newLvl
        newLvl = curLvl
        neededXP = NomadLevels.XPForLevel(newLvl)
    end

    if curLvl ~= ply:GetLevel() then
        ply:SetLevel(curLvl)

        NomadLevels.AddNotification(ply, string.format("You have now reached Level: %s! Congratulations!", newLvl), 5)
    end

    ply:SetXP(newXP)
    ply:SaveProfile()
end

util.AddNetworkString("NomadLevels.ReceivedNotifcation")

function NomadLevels.AddNotification( pPlayer, sText, iTime )
    local tPackage = {
        text = sText,
        time = iTime
    }

    net.Start( "NomadLevels.ReceivedNotifcation" )
        net.WriteString( util.TableToJSON( tPackage ) )
    net.Send( pPlayer )
end