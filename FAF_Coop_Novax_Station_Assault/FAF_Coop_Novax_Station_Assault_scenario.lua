version = 3
ScenarioInfo = {
    name = 'Novax Station Assault',
    description = 'QAI has found a planet where the UEF develops new experimental weapons. They need to be stopped before they can finish their research. An Order commander has already launched their offensive. You will gate in, locate all UEF research stations and destroy them.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {4096, 4096},
    map = '/maps/X1MP_012/X1MP_012.scmap',
    save = '/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_save.lua',
    script = '/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_script.lua',
    map_version = 11,
    norushradius = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','UEF','Order','Cybran','Objective','QAI','Player2','Player3','Player4',} },
            },
            customprops = {
            },
            factions = { {'seraphim'}, {'aeon'}, {'seraphim'}, {'aeon'} },
        },
    }}
