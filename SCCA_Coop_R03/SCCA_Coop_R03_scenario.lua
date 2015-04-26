version = 3
ScenarioInfo = {
    name = 'Operation Defrag',
    description = 'Campaign Map: Not Intended for Multiplayer Play',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {512, 512},
    map = '/maps/SCCA_Coop_R03/SCCA_Coop_R03_v01.scmap',
    save = '/maps/SCCA_Coop_R03/SCCA_Coop_R03_v01_save.lua',
    script = '/maps/SCCA_Coop_R03/SCCA_Coop_R03_v01_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','UEF','BrackmanBase','Civilian','CybranCloaked','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
