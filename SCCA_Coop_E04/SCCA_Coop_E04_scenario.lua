version = 3
ScenarioInfo = {
    name = 'Operation Vaccine',
    description = 'We have an emergency. Our techs have determined the Cybrans are behind the recent problems with our Gates.\nSomehow, they managed to hack into the Quantum Gate Network and install a virus.\nIt\'s spreading throughout the entire system, and the Cybrans could use it to shut down specific Gates. If that happens, they will have us cornered and isolated.\nIntel has managed to decrypt a number of virus-related transmissions, and they are originating from Minerva.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {512, 512},
    map = '/maps/SCCA_Coop_E04/SCCA_Coop_E04.scmap',
    save = '/maps/SCCA_Coop_E04/SCCA_Coop_E04_save.lua',
    script = '/maps/SCCA_Coop_E04/SCCA_Coop_E04_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Cybran','Cybran_Research','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
