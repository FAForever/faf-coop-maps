version = 3
ScenarioInfo = {
    name = 'Seraphim Mission 4: Operation Ioz-Shavoh-Kael',
    description = 'Kael has resurfaced and is broadcasting propaganda to our Order forces. It is already causing infighting and several commanders have fled to support her. We must silence her, we are too close to reopening a rift, kill her.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael.scmap',
    save = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_save.lua',
    script = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_script.lua',
    norushradius = 0.000000,
    map_version = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Kael','Order','KOrder','UEF','Player2','Player3','Player4',} },
            },
            customprops = {
            },
			factions = { {'seraphim'}, {'aeon', 'seraphim', 'cybran'}, {'aeon', 'seraphim', 'cybran'}, {'aeon', 'seraphim', 'cybran'} },
        },
    }}
