version = 3
ScenarioInfo = {
    name = 'Operation Rescue',
    description = 'A group of UEF scientists are trapped on a planet and a Cybran Commander gated near them quite a while back. They managed to send a distress signal before the Cybran built a long-range Jammer. We\'ve managed to locate the scientists. Commander, you will gate in and help those scientists.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/SCMP_027/SCMP_027.scmap',
    save = '/maps/faf_coop_operation_rescue.v0001/FAF_Coop_operation_rescue_save.lua',
    script = '/maps/faf_coop_operation_rescue.v0001/FAF_Coop_operation_rescue_script.lua',
    map_version = 1,
    norushradius = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Cybran','UEF','Player2','Player3','Player4',} },
            },
            customprops = {
            },
            factions = { {'uef'}, {'uef'}, {'uef'}, {'uef'} },
        },
    }}
