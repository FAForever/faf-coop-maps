version = 3
ScenarioInfo = {
    name = 'Operation Unlock',
    description = 'Campaign Map: Not Intended for Multiplayer Play',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_R05_v01/SCCA_Coop_R05_v01.scmap',
    save = '/maps/SCCA_Coop_R05_v01/SCCA_Coop_R05_v01_save.lua',
    script = '/maps/SCCA_Coop_R05_v01/SCCA_Coop_R05_v01_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','UEF','Hex5','FauxUEF','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
