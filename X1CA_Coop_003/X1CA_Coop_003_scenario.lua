version = 3
ScenarioInfo = {
    name = 'FA Mission 3 - Red Flag',
    description = '<LOC X1CA_Coop_003_description>Princess Burke has returned, but she is in grave danger. Seraphim forces have her trapped on the planet Blue Sky, and she has no chance of escaping. You will go to Blue Sky, destroy the Seraphim commanders, and save Princess Burke.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {2048, 1024},
    map = '/maps/X1CA_Coop_003/X1CA_Coop_003.scmap',
    save = '/maps/X1CA_Coop_003/X1CA_Coop_003_save.lua',
    script = '/maps/X1CA_Coop_003/X1CA_Coop_003_script.lua',
    norushradius = 0.000000,
    norushoffsetX_Player1 = 0.000000,
    norushoffsetY_Player1 = 0.000000,
    norushoffsetX_Seraphim = 0.000000,
    norushoffsetY_Seraphim = 0.000000,
    norushoffsetX_Rhiza = 0.000000,
    norushoffsetY_Rhiza = 0.000000,
    norushoffsetX_Princess = 0.000000,
    norushoffsetY_Princess = 0.000000,
    norushoffsetX_Crystals = 0.000000,
    norushoffsetY_Crystals = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Seraphim','Rhiza','Princess','Crystals','Player2','Player3','Player4'} },
            },
            customprops = {
            },
        },
    }}
