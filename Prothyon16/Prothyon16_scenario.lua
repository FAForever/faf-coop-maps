version = 3
ScenarioInfo = {
    name = 'Prothyon - 16 Beta',
    description = "Prothyon - 16 is a secret UEF facillity for training new ACU pilots. Your task today is to provide a demonstration to our newest recruits by fighting against a training AI.",
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {2048, 2048},
    map = '/maps/Prothyon16/Prothyon16.scmap',
    save = '/maps/Prothyon16/Prothyon16_save.lua',
    script = '/maps/Prothyon16/Prothyon16_script.lua',
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
