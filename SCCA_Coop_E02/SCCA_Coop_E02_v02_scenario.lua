version = 3
ScenarioInfo = {
    name = 'Operation Snow Blind',
    description = 'Campaign Map: Not Intended for Multiplayer Play',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {512, 512},
    map = '/maps/SCCA_Coop_E02_v02/SCCA_Coop_E02_v02.scmap',
    save = '/maps/SCCA_Coop_E02_v02/SCCA_Coop_E02_v02_save.lua',
    script = '/maps/SCCA_Coop_E02_v02/SCCA_Coop_E02_v02_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Aeon','AllyResearch','AllyCivilian','AeonNeutral','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
