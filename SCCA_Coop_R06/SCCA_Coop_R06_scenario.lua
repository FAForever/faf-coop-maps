version = 3
ScenarioInfo = {
    name = 'Operation Freedom',
    description = 'Campaign Map: Not Intended for Multiplayer Play',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_map_version = 3,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_R06/SCCA_E06.scmap',
    save = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_save.lua',
    script = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Aeon','UEF','BlackSun','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
