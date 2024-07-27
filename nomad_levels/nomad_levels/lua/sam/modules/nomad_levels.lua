if SAM_LOADED then return end

sam.command.set_category("Nomad")

sam.command.new('givexp')
:SetPermission('givexp', 'superadmin')
:Help('Give XP to a player.')
:AddArg('player', {
    single_target = true,
    allow_higher_target = true
})
:AddArg('number', {
    hint = 'XP',
    round = true
})
:OnExecute(function(caller, targets, number)
    local target = targets[1]

    NomadLevels.AddPlayerXP(target, number)

    sam.player.send_message(nil, '{A} gave {T} {V} XP.', {
        A = caller,
        T = targets,
        V = number
    })
end):End()