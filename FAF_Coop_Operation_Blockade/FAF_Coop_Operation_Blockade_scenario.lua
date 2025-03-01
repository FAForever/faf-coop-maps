version = 3
ScenarioInfo = {
    name = '<LOC FAF_Coop_Operation_Blockade_Name>Coalition Mission 1: Operation Blockade',
    description = '<LOC FAF_Coop_Operation_Blockade_Desciption>The Seraphim and their Order allies are attempting to flee into open space. This is one of the planet they are using as a fallback location. We must not let the Seraphim leave this planet, destroy them all.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {2048, 2048},
    map = '/maps/FAF_Coop_Operation_Blockade/FAF_Coop_Operation_Blockade.scmap',
    save = '/maps/FAF_Coop_Operation_Blockade/FAF_Coop_Operation_Blockade_save.lua',
    script = '/maps/FAF_Coop_Operation_Blockade/FAF_Coop_Operation_Blockade_script.lua',
    norushradius = 0.000000,
    map_version = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Seraphim','Seraphim2','Player2','Player3','Player4',} },
            },
            customprops = {
            },
            factions = { {'uef','aeon','cybran'}, {'uef','aeon','cybran'}, {'uef','aeon','cybran'}, {'uef','aeon','cybran'} },
        },
    }}
