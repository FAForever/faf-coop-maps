version = 3
ScenarioInfo = {
    name = 'Aeon Vanilla Campain - Mission 2',
    description = 'Campaign Map: Not Intended for Multiplayer Play',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {512, 512},
    map = '/maps/SCCA_Coop_A02/SCCA_Coop_A02_v03.scmap',
    save = '/maps/SCCA_Coop_A02/SCCA_Coop_A02_v03_save.lua',
    script = '/maps/SCCA_Coop_A02/SCCA_Coop_A02_v03_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Cybran','NeutralCybran','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
