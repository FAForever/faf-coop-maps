version = 3
ScenarioInfo = {
    name = 'Theta Civilian Rescue',
    description = 'Some Cybran scum has kidnapped civilians from one of our settlements. Our intelligence officers were able to roughly pinpoint their current location. It is your job to go in and rescue them. We don\'t want to give them reason to retaliate later on, so the weaponry available to you, will be restricted. Good luck out there, Commander. Bring them home safe.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {256, 256},
    norushradius = 0.000000,
    norushoffsetX_Player1 = 0.000000,
    norushoffsetY_Player1 = 0.000000,
    norushoffsetX_Cybran = 0.000000,
    norushoffsetY_Cybran = 0.000000,
    norushoffsetX_Player2 = 0.000000,
    norushoffsetY_Player2 = 0.000000,
    norushoffsetX_Player3 = 0.000000,
    norushoffsetY_Player3 = 0.000000,
    norushoffsetX_Player4 = 0.000000,
    norushoffsetY_Player4 = 0.000000,
    map = '/maps/ThetaCivilianRescue/ThetaCivilianRescue.scmap',
    save = '/maps/ThetaCivilianRescue/ThetaCivilianRescue_save.lua',
    script = '/maps/ThetaCivilianRescue/ThetaCivilianRescue_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Cybran', 'Player2', 'Player3', 'Player4'} },
            },
            customprops = {
            },
        },
    }
}