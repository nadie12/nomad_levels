--
local notifs = {}
local curY = 0

NomadUI.RegisterFont("NotificationText", "Roboto", 24)

function NomadUI.AddNotification(sText, iTime)
    curY = curY + 40
    local x, y = 800, 128
    local rX, rY = ScrW() / 2 - x / 2, ScrH() - (150 + curY)

    local notif = vgui.Create("DPanel")
    notif:SetSize( x, y )
    notif:SetPos( rX, ScrH() )
    notif:MoveTo( rX, rY, 0.2, 0, 1 )
    notif.Paint = function()
    end

    NomadUI.SlideTextDLabel(notif, "NomadUI.NotificationText", sText, x*0.9, y*0.9, x*0.05, y*0.05, NomadUI.Color("FrameTitle"), 1)

    timer.Simple(iTime, function()
        if IsValid(notif) then
            notif:MoveTo(ScrW() / 2 - x / 2, ScrH(), 0.2, 0, 1, function()
                if IsValid(notif) then
                    curY = curY - 40
                    notif:Remove() 
                end
            end)
        end
    end)
end

function NomadUI.SlideTextDLabel(base, font, text, x, y, xpos, ypos, color, time)
    local curTime = CurTime()
    local stopTime = curTime + time
    local strLength = string.len(text)

    local label = vgui.Create("DLabel", base)
    local sizeX, sizeY = surface.GetTextSize(text)
	label:SetSize( sizeX + 200, sizeY + 50 )
    label:Center()
    label:SetText("")
    label:SetWrap(true)
    label:SetTextColor( color )
	label:SetFont( font )

    function label.Think()
        if label:GetText() == text then
            return
        end

        local curTime = CurTime()
        local timeLeft = stopTime - curTime
        local strSize = (timeLeft / (time / 100) ) / 100
        local strLong = 1 - strSize

        label:SetText( string.sub( text, 0, strLength * strLong ) )
        label:Center()
    end

    return label
end

net.Receive("NomadLevels.ReceivedNotifcation", function()
    local tbl = util.JSONToTable(net.ReadString())
    NomadUI.AddNotification(tbl["text"], tbl["time"])
end)