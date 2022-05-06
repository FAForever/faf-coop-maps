version = 3
ScenarioInfo = {
    name = "Operation Trident",
    description = "Operation Trident",
    preview = '',
    map_version = 2,
    type = 'campaign_coop',
    starts = true,
    size = {1024, 1024},
    map = '/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident.scmap',
    save = '/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_save.lua',
    script = '/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_script.lua',
    norushradius = 0,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'Player1', 'Aeon', 'UEF', 'Cybran', 'Civilians', 'Player2'}
                },
            },
            customprops = {
            },
            factions = {
                {'cybran'},
                {'cybran'}
            },
        },
    },
}
