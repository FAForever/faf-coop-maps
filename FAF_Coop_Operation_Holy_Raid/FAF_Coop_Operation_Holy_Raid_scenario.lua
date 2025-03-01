version = 3
ScenarioInfo = {
    name = '<LOC FAF_Coop_Operation_Holy_Raid_Name>Coalition Mission 2: Operation Holy Raid',
    description = '<LOC FAF_Coop_Operation_Holy_Raid_Description>This planet houses a secret Coalition research facility, Somehow Order forces have found it and are laying seige to the defenses. Stop them and protect the research at all costs.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/FAF_Coop_Operation_Holy_Raid/FAF_Coop_Operation_Holy_Raid.scmap',
    save = '/maps/FAF_Coop_Operation_Holy_Raid/FAF_Coop_Operation_Holy_Raid_save.lua',
    script = '/maps/FAF_Coop_Operation_Holy_Raid/FAF_Coop_Operation_Holy_Raid_script.lua',
    norushradius = 0.000000,
    map_version = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Order1','Order2','Civilians','Player2','Player3','Player4',} },
            },
            customprops = {
            },
            factions = { {'uef','aeon','cybran'}, {'uef','aeon','cybran'}, {'uef','aeon','cybran'}, {'uef','aeon','cybran'} },
        },
    }}
