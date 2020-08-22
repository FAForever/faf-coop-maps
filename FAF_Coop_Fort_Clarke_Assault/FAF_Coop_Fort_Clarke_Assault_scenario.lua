version = 3
ScenarioInfo = {
    name = 'Fort Clarke Assault',
    description = "Rework of the first FA mission from Seraphim point of view. Work in progress.",
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/X1CA_001/X1CA_001.scmap',
    save = '/maps/FAF_Coop_Fort_Clarke_Assault/FAF_Coop_Fort_Clarke_Assault_save.lua',
    script = '/maps/FAF_Coop_Fort_Clarke_Assault/FAF_Coop_Fort_Clarke_Assault_script.lua',
    map_version = 3,
    norushradius = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Seraphim','Order','UEF','Aeon','Cybran','Civilians','Player2','Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'seraphim'}, {'seraphim'}, {'seraphim'}, {'seraphim'} },
        },
    }}
