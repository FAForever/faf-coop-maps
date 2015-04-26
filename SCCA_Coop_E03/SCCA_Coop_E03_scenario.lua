version = 3
ScenarioInfo = {
    name = 'Metal Shark',
    description = 'Campaign Map: Not Intended for Multiplayer Play',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {512, 512},
    map = '/maps/SCCA_Coop_E03/SCCA_Coop_E03_v03.scmap',
    save = '/maps/SCCA_Coop_E03/SCCA_Coop_E03_v03_save.lua',
    script = '/maps/SCCA_Coop_E03/SCCA_Coop_E03_v03_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Aeon','Arnold','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
