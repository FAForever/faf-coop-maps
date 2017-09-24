version = 3
ScenarioInfo = {
    name = 'Prothyon - 16',
    description = "Prothyon - 16 is a secret UEF facillity for training new ACU pilots. Your task today is to provide a demonstration to our newest recruits by fighting against a training AI.",
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {2048, 2048},
    map = '/maps/X1MP_010/X1MP_010.scmap',
    save = '/maps/FAF_Coop_Prothyon_16/FAF_Coop_Prothyon_16_save.lua',
    script = '/maps/FAF_Coop_Prothyon_16/FAF_Coop_Prothyon_16_script.lua',
    map_version = 3,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','UEF','UEFAlly','Objective','Seraphim','Player2','Player3','Player4',} },
            },
            customprops = {
            },
            factions = { {'uef'}, {'uef'}, {'uef'}, {'uef'} },
        },
    }}
