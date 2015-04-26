version = 3
ScenarioInfo = {
    name = 'FA Campaign Mission 1 - Coop',
    description = '<LOC X1CA_Coop_001_description>Fort Clarke, located on the planet Griffin IV, is the UEF\'s last stronghold. Seraphim and Order forces are attacking the fort with overwhelming force. If Fort Clarke falls, the UEF is finished. You will defeat the enemy commanders on Griffin IV and end the siege of Fort Clarke.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map_version=3,
    map = '/maps/X1CA_Coop_001/X1CA_Coop_001.scmap',
    save = '/maps/X1CA_Coop_001/X1CA_Coop_001_save.lua',
    script = '/maps/X1CA_Coop_001/X1CA_Coop_001_script.lua',
    norushradius = 0.000000,
    norushoffsetX_Player = 0.000000,
    norushoffsetY_Player = 0.000000,
    norushoffsetX_Coop1 = 0.000000,
    norushoffsetY_Coop1 = 0.000000,
    norushoffsetX_Coop2 = 0.000000,
    norushoffsetY_Coop2 = 0.000000,
	norushoffsetX_Coop3 = 0.000000,
    norushoffsetY_Coop3 = 0.000000,
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
                { name = 'FFA', armies = {'Player','Seraphim','Order','UEF','Civilians','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
