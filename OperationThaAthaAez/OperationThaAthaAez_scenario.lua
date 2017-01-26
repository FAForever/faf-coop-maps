version = 3
ScenarioInfo = {
    name = 'Operation (Tha-Atha-Aez)',
    description = 'You have been called back to Gev-7 because the Coalition has launched a new offensive. Almost half of our commanders are trapped behind enemy lines, and can only Gate to Gev-7. The Coalition knows this and they are attemping to cut them off. You must hold the gates until all our commanders are through. ',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 2048},
    map = '/maps/OperationThaAthaAez/OperationThaAthaAez.scmap',
    save = '/maps/OperationThaAthaAez/OperationThaAthaAez_save.lua',
    script = '/maps/OperationThaAthaAez/OperationThaAthaAez_script.lua',
    norushradius = 0.000000,
    map_version = 3,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','SeraphimAlly','UEF','Aeon','WarpComs','SeraphimAlly2','Player2','Player3','Player4',} },
            },
            customprops = {
            },
            factions = { {'seraphim'}, {'seraphim'}, {'seraphim'}, {'seraphim'} },
        },
    }}
