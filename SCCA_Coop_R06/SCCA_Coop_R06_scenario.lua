version = 3
ScenarioInfo = {
    name = 'Cybran Mission 6 - Freedom',
    description = 'Your Mission is to seize control of Black Sun and upload QAI\'s data-core directly into it\'s Control Center. Firing the weapon will then release both the Quantum Virus and the Liberation Matrix. The Gates will shut down. Everyone, everywhere will be free. There will be peace.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_map_version = 3,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_R06/SCCA_E06.scmap',
    save = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_save.lua',
    script = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Aeon','UEF','BlackSun','Player2','Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'cybran'}, {'cybran'}, {'cybran'}, {'cybran'} },
        },
    }}
