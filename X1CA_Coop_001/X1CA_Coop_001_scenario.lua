version = 3
ScenarioInfo = {
    name = 'FA Mission 1 - Black Day',
    description = '<LOC X1CA_001_description>Fort Clarke, located on the planet Griffin IV, is the UEF\'s last stronghold. Seraphim and Order forces are attacking the fort with overwhelming force. If Fort Clarke falls, the UEF is finished. You will defeat the enemy commanders on Griffin IV and end the siege of Fort Clarke.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    map = '/maps/X1CA_001/X1CA_001.scmap',
    save = '/maps/X1CA_Coop_001/X1CA_Coop_001_save.lua',
    script = '/maps/X1CA_Coop_001/X1CA_Coop_001_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Seraphim','Order','UEF','Civilians','Player2','Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'} },
        },
    }}
