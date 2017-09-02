version = 3
ScenarioInfo = {
    name = 'Theban Colony',
    description = 'Playable preview. Defend the colony as long as you can.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/FAF_Coop_Theban_Colony/FAF_Coop_Theban_Colony.scmap',
    save = '/maps/FAF_Coop_Theban_Colony/FAF_Coop_Theban_Colony_save.lua',
    script = '/maps/FAF_Coop_Theban_Colony/FAF_Coop_Theban_Colony_script.lua',
    map_version = 1,
    norushradius = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','UEF','Civilian','Cybran','XPlayer2','XPlayer3','XPlayer4',} },
            },
            customprops = {
            },
            factions = { {'cybran'}, {'cybran'}, {'cybran'}, {'cybran'} },
        },
    }}
