version = 3
ScenarioInfo = {
    name = "Coalition Mission 4: Operation Rebel's Rest",
    description = 'We  have another situation developing on a Prison world deep in UEF space. Two UEF commanders have gone rogue in support of the late Commander Fletcher. They need to be stopped before they unleash the criminal population of Rebel\'s rest.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = "/maps/FAF_Coop_Operation_Rebel's_Rest/FAF_Coop_Operation_Rebel's_Rest.scmap",
    save = "/maps/FAF_Coop_Operation_Rebel's_Rest/FAF_Coop_Operation_Rebel's_Rest_save.lua",
    script = "/maps/FAF_Coop_Operation_Rebel's_Rest/FAF_Coop_Operation_Rebel's_Rest_script.lua",
    norushradius = 0.000000,
    map_version = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','UEF1','UEF2','Player2','Player3','Player4',} },
            },
            customprops = {
            },
            factions = { {'uef','aeon','cybran'}, {'uef','aeon','cybran'}, {'uef','aeon','cybran'}, {'uef','aeon','cybran'} },
        },
    }}
