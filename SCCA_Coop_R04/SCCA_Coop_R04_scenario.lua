version = 3
ScenarioInfo = {
    name = 'Operation Mainframe Tango',
    description = 'Campaign Map: Not Intended for Multiplayer Play',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_R04/SCCA_Coop_R04.scmap',
    save = '/maps/SCCA_Coop_R04/SCCA_Coop_R04_save.lua',
    script = '/maps/SCCA_Coop_R04/SCCA_Coop_R04_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Aeon','Civilian','Neutral','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
