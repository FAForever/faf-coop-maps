version = 3
ScenarioInfo = {
    name = 'Seraphim Mission 5: Operation Overlord Surth-Velsok',
    description = 'Overlord Surth-Velsok has gone rogue. He believes that there has to be another way to survive. He is attempting to broker a truce with the Humans, he must be stopped at all costs.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok.scmap',
    save = '/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_save.lua',
    script = '/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_script.lua',
    norushradius = 80.000000,
    map_version = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Seraphim','Cybran','Player2','Player3','Player4',} },
            },
            customprops = {
            },
            factions = { {'seraphim'}, {'seraphim','aeon','cybran'}, {'seraphim','aeon','cybran'}, {'seraphim','aeon','cybran'} },
        },
    }}
