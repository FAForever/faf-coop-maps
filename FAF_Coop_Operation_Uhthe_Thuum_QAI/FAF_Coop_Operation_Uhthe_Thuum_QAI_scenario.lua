version = 3
ScenarioInfo = {
    name = 'Seraphim Mission 3: Operation Uhthe-Thuum-QAI',
    description = 'QAI survived and needs our help to reupload himself into the Quantum network, you will gate in and support him in any way you can. He alone has such vast processing power he is vital to our plan against the Humans.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI.scmap',
    save = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_save.lua',
    script = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_script.lua',
    norushradius = 0.000000,
    map_version = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Cybran1','QAI','Nodes','Cybran2','Player2','Player4','Player3',} },
            },
            customprops = {
            },
			factions = { {'seraphim'}, {'aeon', 'seraphim'}, {'aeon', 'seraphim'}, {'aeon', 'seraphim'} },
        },
    }}
