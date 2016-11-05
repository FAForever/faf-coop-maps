version = 3
ScenarioInfo = {
    name = 'Cybran Mission 2 - Artifact',
    description = 'I have a special mission for you. Oh yes. QAI needs to accelerate its development of the Quantum Virus. Must finish before Black Sun is deployed. QAI requires a specific piece of Seraphim technology, a Quantum Interface Device. Its...core is Seraphim tech. Amazing technology. Oh yes. The Seraphim were the precursors to the Aeon.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {512, 512},
    map = '/maps/SCCA_Coop_R02/SCCA_Coop_R02.scmap',
    save = '/maps/SCCA_Coop_R02/SCCA_Coop_R02_save.lua',
    script = '/maps/SCCA_Coop_R02/SCCA_Coop_R02_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Aeon','CybranJanus','Civilian','FakeAeon','FakeJanus','Player2','Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'cybran'}, {'cybran'}, {'cybran'}, {'cybran'} },
        },
    }}
