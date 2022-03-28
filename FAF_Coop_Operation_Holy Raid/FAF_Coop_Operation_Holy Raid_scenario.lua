version = 3
ScenarioInfo = {
    name = 'Coalition Mission 2: Operation Holy Raid',
    description = 'This planet houses a secret coalition research facility, Somehow Order forces have found it and are laying seige to the defenses. Stop them and protect the research at all costs.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/FAF_Coop_Operation_Holy Raid/FAF_Coop_Operation_Holy Raid.scmap',
    save = '/maps/FAF_Coop_Operation_Holy Raid/FAF_Coop_Operation_Holy Raid_save.lua',
    script = '/maps/FAF_Coop_Operation_Holy Raid/FAF_Coop_Operation_Holy Raid_script.lua',
    norushradius = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Order1','Order2','Civilians','Player2','Player3','Player4',} },
            },
            customprops = {
            },
            factions = { {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'} },
        },
    }}
