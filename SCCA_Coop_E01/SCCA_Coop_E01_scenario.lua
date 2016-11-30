version = 3
ScenarioInfo = {
    name = 'UEF Mission 1 - Black Earth',
    description = 'Intel reports that two Cybran Commanders gated to Capella over an hour ago.\nWe presume they\'re attempting to inflame the Symbiont population.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {512, 512},
    map = '/maps/SCCA_Coop_E01/SCCA_Coop_E01.scmap',
    save = '/maps/SCCA_Coop_E01/SCCA_Coop_E01_save.lua',
    script = '/maps/SCCA_Coop_E01/SCCA_Coop_E01_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Arnold','Cybran','EastResearch','Player2','Player3','Player4'} },
            },
            customprops = {
            },
        },
    }}
