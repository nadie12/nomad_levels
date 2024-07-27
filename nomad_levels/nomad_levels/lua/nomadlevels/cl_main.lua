local PLAYER = FindMetaTable("Player")

function PLAYER:GetLevel()
    return self:GetNWInt("NomadLevels.Level")
end

function PLAYER:GetXP()
    return self:GetNWInt("NomadLevels.XP")
end

function PLAYER:GetFirstJoin()
    return self:GetNWInt("NomadLevels.FirstJoin")
end

function PLAYER:GetLastJoin()
    return self:GetNWInt("NomadLevels.LastJoin")
end

function PLAYER:GetPlayTime()
    return self:GetNWInt("NomadLevels.PlayTime")
end

hook.Add("HUDPaint", "DrawPlayerProfileHUD", function()
    local ply = LocalPlayer()
    local y = 10
    local x = ScrW() * .5
    local textColor = Color(255, 255, 255, 255)
    local labelColor = Color(255, 200, 0, 255)

    local curLvl = ply:GetLevel()
    local nextLvl = curLvl + 1

    -- Drawing each profile variable
    draw.SimpleText("Player Profile", "DermaDefaultBold", x, y, labelColor, TEXT_ALIGN_LEFT)
    y = y + 20
    draw.SimpleText("First Join: " .. os.date("%c", ply:GetFirstJoin()), "DermaDefault", x, y, textColor, TEXT_ALIGN_LEFT)
    y = y + 20
    draw.SimpleText("Last Join: " .. os.date("%c", ply:GetLastJoin()), "DermaDefault", x, y, textColor, TEXT_ALIGN_LEFT)
    y = y + 20
    draw.SimpleText("Total Play Time: " ..  ply:GetPlayTime() .. " seconds", "DermaDefault", x, y, textColor, TEXT_ALIGN_LEFT)
    y = y + 20
    draw.SimpleText("XP: " .. ply:GetXP(), "DermaDefault", x, y, textColor, TEXT_ALIGN_LEFT)
    y = y + 20
    draw.SimpleText("Level: " .. curLvl, "DermaDefault", x, y, textColor, TEXT_ALIGN_LEFT)
    y = y + 20
    draw.SimpleText("XP Until Lvl: " .. NomadLevels.XPForLevel(nextLvl),  "DermaDefault", x, y, textColor, TEXT_ALIGN_LEFT)
end)