version = 3
ScenarioInfo = {
    name = 'Aeon Mission 3 - High Tide',
    description = 'Ten days ago we launched an offensive against UEF forces positioned on Matar.\nDespite my planning, seizing the planet has proven much more difficult than expected. This is unacceptable.\nYou will go to Matar and relieve Crusader Eris. She has been in constant battle and is in need of rest.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {512, 512},
    map = '/maps/SCCA_Coop_A03/SCCA_Coop_A03.scmap',
    save = '/maps/SCCA_Coop_A03/SCCA_Coop_A03_save.lua',
    script = '/maps/SCCA_Coop_A03/SCCA_Coop_A03_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','UEF','Eris','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
