version = 3
ScenarioInfo = {
    name = 'Novax Station Assault',
    description = 'QAI has found a planet where the UEF develops new experimental weapons. They need to be stopped before they can finish their research. An Order commander has already launched their offensive. You will gate in, locate all UEF research stations and destroy them.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {4096, 4096},
    map = '/maps/X1MP_012/X1MP_012.scmap',
    save = '/maps/NovaxStationAssault/NovaxStationAssault_save.lua',
    script = '/maps/NovaxStationAssault/NovaxStationAssault_script.lua',
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
