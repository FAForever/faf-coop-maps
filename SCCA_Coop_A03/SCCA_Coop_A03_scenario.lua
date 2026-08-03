version = 3
ScenarioInfo = {
    name = '<LOC OPNAME_A03>Aeon Mission 3 - High Tide',
    description = '<LOC SCCA_A03_description>Ten days ago we launched an offensive against UEF forces positioned on Matar.\nDespite my planning, seizing the planet has proven much more difficult than expected. This is unacceptable.\nYou will go to Matar and relieve Crusader Eris. She has been in constant battle and is in need of rest.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    norushradius = 0.000000,
    size = {512, 512},
    map = '/maps/SCCA_Coop_A03/SCCA_Coop_A03.scmap',
    save = '/maps/SCCA_Coop_A03/SCCA_Coop_A03_save.lua',
    script = '/maps/SCCA_Coop_A03/SCCA_Coop_A03_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','UEF','Eris','Player2','Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'aeon'}, {'aeon'}, {'aeon'}, {'aeon'} },
        },
    }}
