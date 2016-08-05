version = 3
ScenarioInfo = {
    name = 'Theta Civilian Rescue',
    description = 'Some Cybran scum has kidnapped civilians from one of our settlements. Our intelligence officers were able to roughly pinpoint their current location. It is your job to go in and rescue them. We don\'t want to give them reason to retaliate later on, so the weaponry available to you, will be restricted. Good luck out there, Commander. Bring them home safe.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {256, 256},
    norushradius = 0.000000,
    norushoffsetX_Player = 0.000000,
    norushoffsetY_Player = 0.000000,
    norushoffsetX_Cybran = 0.000000,
    norushoffsetY_Cybran = 0.000000,
    norushoffsetX_Coop1 = 0.000000,
    norushoffsetY_Coop1 = 0.000000,
    norushoffsetX_Coop2 = 0.000000,
    norushoffsetY_Coop2 = 0.000000,
    norushoffsetX_Coop3 = 0.000000,
    norushoffsetY_Coop3 = 0.000000,
    map = '/maps/ThetaCivilianRescue/ThetaCivilianRescue.scmap',
    save = '/maps/ThetaCivilianRescue/ThetaCivilianRescue_save.lua',
    script = '/maps/ThetaCivilianRescue/ThetaCivilianRescue_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Cybran', 'Coop1', 'Coop2', 'Coop3'} },
            },
            customprops = {
            },
        },
    }
}