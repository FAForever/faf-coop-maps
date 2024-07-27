version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "Cybran Mission 6 - Freedom, Remastered",
    description = "Having the Black Sun access codes secured, Cybran forces attempt a daring operation on Earth itself to take control of Black Sun, before the UEF could fire it, and before the Aeon could destroy it.\nThere's no turning back now, the fate of the Galaxy rests in your hands.",
    preview = '',
    map_version = 5,
    type = 'campaign_coop',
    starts = true,
    size = {1024, 1024},
    reclaim = {2776666, 82315.22},
    map = '/maps/SCCA_Coop_R06/SCCA_Coop_R06.scmap',
    save = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_save.lua',
    script = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_script.lua',
    norushradius = 40,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'Player1', 'Aeon', 'UEF', 'BlackSun', 'Cybran', 'Player2', 'Player3', 'Player4'}
                },
            },
            customprops = {
            },
            factions = {
                {'cybran'},
                {'cybran'},
                {'cybran'},
                {'cybran'}
            },
        },
    },
}
