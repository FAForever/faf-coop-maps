version = 3
ScenarioInfo = {
    name = 'Operation Artifact',
    description = 'Campaign Map: Not Intended for Multiplayer Play',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {512, 512},
    map = '/maps/SCCA_Coop_R02/SCCA_Coop_R02_v01.scmap',
    save = '/maps/SCCA_Coop_R02/SCCA_Coop_R02_v01_save.lua',
    script = '/maps/SCCA_Coop_R02/SCCA_Coop_R02_v01_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Aeon','CybranJanus','Civilian','FakeAeon','FakeJanus','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
