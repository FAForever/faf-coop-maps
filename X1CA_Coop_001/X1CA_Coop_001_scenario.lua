version = 3
ScenarioInfo = {
    name = 'FA Mission 1 - Black Day',
    description = '<LOC X1CA_Coop_001_description>Fort Clarke, located on the planet Griffin IV, is the UEF\'s last stronghold. Seraphim and Order forces are attacking the fort with overwhelming force. If Fort Clarke falls, the UEF is finished. You will defeat the enemy commanders on Griffin IV and end the siege of Fort Clarke.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    map = '/maps/X1CA_Coop_001/X1CA_Coop_001.scmap',
    save = '/maps/X1CA_Coop_001/X1CA_Coop_001_save.lua',
    script = '/maps/X1CA_Coop_001/X1CA_Coop_001_script.lua',
    norushradius = 0.000000,
    norushoffsetX_Player1 = 0.000000,
    norushoffsetY_Player1 = 0.000000,
    norushoffsetX_Player2 = 0.000000,
    norushoffsetY_Player2 = 0.000000,
    norushoffsetX_Player3 = 0.000000,
    norushoffsetY_Player3 = 0.000000,
    norushoffsetX_Player4 = 0.000000,
    norushoffsetY_Player4 = 0.000000,
    norushoffsetX_Seraphim = 0.000000,
    norushoffsetY_Seraphim = 0.000000,
    norushoffsetX_Order = 0.000000,
    norushoffsetY_Order = 0.000000,
    norushoffsetX_UEF = 0.000000,
    norushoffsetY_UEF = 0.000000,
    norushoffsetX_Civilians = 0.000000,
    norushoffsetY_Civilians = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Seraphim','Order','UEF','Civilians','Player2','Player3','Player4'} },
            },
            customprops = {
            },
        },
    }}
