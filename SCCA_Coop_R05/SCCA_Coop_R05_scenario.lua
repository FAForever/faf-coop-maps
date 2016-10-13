version = 3
ScenarioInfo = {
    name = 'Cybran Mission 5 - Unlock',
    description = 'Commander, you will free Hex5\'s comrades and get the Black Sun\'s access codes. We are running out of time, my boy. Out of time. The UEF will fall to the Aeon within 14 days. If that happens, there is a high probabillity the UEF will unleash Option Zero and destroy all life on Earth. We face our darkest hour. You must succeed. Your brothers and sisters are counting on you. Be safe.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_R05/SCCA_Coop_R05.scmap',
    save = '/maps/SCCA_Coop_R05/SCCA_Coop_R05_save.lua',
    script = '/maps/SCCA_Coop_R05/SCCA_Coop_R05_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','UEF','Hex5','FauxUEF','Player2','Player3','Player4'} },
            },
            customprops = {
            },
        },
    }}
