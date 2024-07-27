local plyMeta = FindMetaTable( "Player" )

local CLASS = {}
CLASS.__index = CLASS

AccessorFunc( CLASS, "m_player", "Player" )

function plyMeta:Nomad()
    if not self.NomadLevels then
        self.NomadLevels = table.Copy( CLASS )
        self.NomadLevels:SetPlayer( self )
    end

    return self.NomadLevels
end
