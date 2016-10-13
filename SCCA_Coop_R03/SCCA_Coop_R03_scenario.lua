version = 3
ScenarioInfo = {
    name = 'Cybran Mission 3 - Defrag',
    description = 'The Aeon will defeat the UEF within 22 days. Secondary calculations show there is a 54.229 percent chance the UEF will fire Black Sun before they fall to the Aeon. Either outcome signals the end of the Cybran Nation.\nTime is against us. Perhaps Dr. Sweeney will be able to offer us some guidance. No doubt that the UEF misses one of its top scientists, but he\'s our guest now.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {512, 512},
    map = '/maps/SCCA_Coop_R03/SCCA_Coop_R03.scmap',
    save = '/maps/SCCA_Coop_R03/SCCA_Coop_R03_save.lua',
    script = '/maps/SCCA_Coop_R03/SCCA_Coop_R03_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','UEF','BrackmanBase','Civilian','CybranCloaked','Player2','Player3','Player4'} },
            },
            customprops = {
            },
        },
    }}
