version = 3
ScenarioInfo = {
    name = 'Aeon Mission 5 - Shining Star',
    description = 'This is Eridani. It is deep in UEF territory, and Crusaders Rhiza and Ariel have launched attacks on the planet, sowing destruction on Marxon\'s orders.\nYou will go to Eridani and press the Princesses case.\nAll who refuse you must be silenced.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/scca_coop_a05/SCCA_Coop_A05.scmap',
    save = '/maps/scca_coop_a05/SCCA_Coop_A05_save.lua',
    script = '/maps/scca_coop_a05/SCCA_Coop_A05_script.lua',
    norushradius = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Ariel','UEF','Colonies','Player2','Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'aeon'}, {'aeon'}, {'aeon'}, {'aeon'} },
        },
    }}
