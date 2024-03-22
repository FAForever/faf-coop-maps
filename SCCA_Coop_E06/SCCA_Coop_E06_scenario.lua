version = 3 -- Lua Version. Dont touch this
ScenarioInfo = {
    name = "UEF Mission 6 - Stone Wall - Remastered",
    description = "Black Sun facility is located here, on the island of Ni'ihua in the Hawaiian chain.\nYour job is simple: You will protect Black Sun during the final stages of its completion. Once it is operational, you will fire it. Captain Aiko is currently in charge of security at the Facility;\n she will offer her unconditional assistance. You now have full access to the UEF arsenal.",
    preview = '',
    map_version = 5,
    type = 'campaign_coop',
    starts = true,
    size = {1024, 1024},
    reclaim = {3334354, 82315.22},
    map = '/maps/SCCA_Coop_E06/SCCA_Coop_E06.scmap',
    save = '/maps/SCCA_Coop_E06/SCCA_Coop_E06_save.lua',
    script = '/maps/SCCA_Coop_E06/SCCA_Coop_E06_script.lua',
    norushradius = 0,
    Configurations = {
        ['standard'] = {
            teams = {
                {
                    name = 'FFA',
                    armies = {'Player1', 'Black_Sun', 'Aeon', 'Cybran', 'Component', 'Player2', 'Player3', 'Player4'}
                },
            },
            customprops = {
            },
            factions = {
                {'uef'},
                {'uef'},
                {'uef'},
                {'uef'}
            },
        },
    },
}
