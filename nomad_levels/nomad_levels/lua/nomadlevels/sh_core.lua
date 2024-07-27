--
function NomadLevels.XPForLevel(level) 
	if level == 0 then
		return 10
	end
	return math.ceil((level ^ 1.5 + level * 9 + 50))
end
