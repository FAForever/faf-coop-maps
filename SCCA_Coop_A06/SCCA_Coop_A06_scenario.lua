version = 3
ScenarioInfo = {
    name = 'Aeon Mission 6 - Beginnings',
    description = "Black Sun is the key; everyone desires it.\nThe UEF and Cybrans wish to use it for their own goals, while Marxon rushes to destroy it.\nYou have no choice but to go to Earth and prevent the UEF and Cybran from using Black Sun.\nYou must also stop Marxon.",
    preview = '',
    map_version = 3,
    type = 'campaign_coop',
    starts = true,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_A06/SCCA_Coop_A06.scmap',
    save = '/maps/SCCA_Coop_A06/SCCA_Coop_A06_save.lua',
    script = '/maps/SCCA_Coop_A06/SCCA_Coop_A06_script.lua',
    norushradius = 0,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'Player1', 'UEF', 'Cybran', 'Aeon', 'Neutral', 'Player2', 'Player3', 'Player4'}
                },
            },
            customprops = {
            },
            factions = {
                {'aeon'},
                {'aeon'},
                {'aeon'},
                {'aeon'}
            },
        },
    },
}
