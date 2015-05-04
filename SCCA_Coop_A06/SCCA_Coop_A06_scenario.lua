version = 3
ScenarioInfo = {
    name = 'Aeon Vanilla Campain - Mission 6',
    description = 'Black Sun is the key; everyone desires it.\nThe UEF and Cybrans wish to use it for their own goals, while Marxon rushes to destroy it.\nYou have no choice but to go to Earth and prevent the UEF and Cybran from using Black Sun.\nYou must also stop Marxon.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_A06/SCCA_Coop_A06_v03.scmap',
    save = '/maps/SCCA_Coop_A06/SCCA_Coop_A06_v03_save.lua',
    script = '/maps/SCCA_Coop_A06/SCCA_Coop_A06_v03_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','UEF','Cybran','Aeon','Neutral','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
