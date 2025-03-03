version = 3
ScenarioInfo = {
    name = "Haven's Invasion",
    description = "Invasion on Haven's Reef is starting. It's a planet controlled by UEF. You will gate in close to several small settlements and eradicate them. We expect very little resistance from these humans.",
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {512, 512},
    map = '/maps/X1MP_004/X1MP_004.scmap',
    save = '/maps/FAF_Coop_Havens_Invasion/FAF_Coop_Havens_Invasion_save.lua',
    script = '/maps/FAF_Coop_Havens_Invasion/FAF_Coop_Havens_Invasion_script.lua',
    map_version = 1,
    norushradius = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','UEF','Seraphim','Civilian',} },
            },
            customprops = {
            },
            factions = { {'seraphim'}, },
        },
    }}
