version = 3
ScenarioInfo = {
    name = 'Theta Civilian Rescue',
    description = 'Some Cybran scum has kidnapped civilians from one of our settlements. Our intelligence officers were able to roughly pinpoint their current location. It is your job to go in and rescue them. We don\'t want to give them reason to retaliate later on, so the weaponry available to you, will be restricted. Good luck out there, Commander. Bring them home safe.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {256, 256},
    map = '/maps/SCMP_012/SCMP_012.scmap',
    save = '/maps/FAF_Coop_Theta_Civilian_Rescue/FAF_Coop_Theta_Civilian_Rescue_save.lua',
    script = '/maps/FAF_Coop_Theta_Civilian_Rescue/FAF_Coop_Theta_Civilian_Rescue_script.lua',
    map_version = 3,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Cybran', 'Player2', 'Player3', 'Player4'} },
            },
            customprops = {
            },
            factions = { {'uef'}, {'uef'}, {'uef'}, {'uef'} },
        },
    }
}