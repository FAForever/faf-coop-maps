version = 3
ScenarioInfo = {
    name = 'Seraphim Mission 1: Operation Yath-aez',
    description = 'Commander the entire Seraphim force is in full retreat, after the loss of the rift our forces have been on the back foot. We Have sent out several forward commanders to clear worlds to evacate our forces. We lost contact with Yuth-azth, we are sending you to replace him on Tarv-3.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {2048, 2048},
    map = '/maps/FAF_Coop_Operation_Yath_Aez/FAF_Coop_Operation_Yath_Aez.scmap',
    save = '/maps/FAF_Coop_Operation_Yath_Aez/FAF_Coop_Operation_Yath_Aez_save.lua',
    script = '/maps/FAF_Coop_Operation_Yath_Aez/FAF_Coop_Operation_Yath_Aez_script.lua',
    norushradius = 0.000000,
    map_version = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'UEF','Player1','Cybran','Aeon','Player2','Player3','Player4',} },
            },
            customprops = {
            },
			factions = { {'seraphim'}, {'seraphim'}, {'seraphim'}, {'seraphim'} },
        },
    }}
