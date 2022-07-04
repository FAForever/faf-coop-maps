version = 3
ScenarioInfo = {
    name = 'Seraphim Mission 2: Operation Tha-Atha-Aez',
    description = 'You have been called back to Velia, because the Coalition has launched a new offensive. Almost half of our commanders are trapped behind enemy lines, and can only Gate to Velia. The Coalition knows this and they are attemping to cut them off. You must hold the gates until all our commanders are through. ',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez.scmap',
    save = '/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_save.lua',
    script = '/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_script.lua',
     norushradius = 0.000000,
    map_version = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','SeraphimAlly','UEF','Aeon','WarpComs','SeraphimAlly2','Player2','Player3','Player4',} },
            },
            customprops = {
            },
			factions = { {'seraphim'}, {'aeon', 'seraphim'}, {'aeon', 'seraphim'}, {'aeon', 'seraphim'} },
        },
    }}
