version = 3
ScenarioInfo = {
    name = 'Coalition Mission 5: Operation Red Revenge',
    description = 'We have located the Seraphim positions. They have several fortresses before we reach their central planet. This seems to be a Research world for the Seraphim. We need to find out what their plan is.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/FAF_Coop_Operation_Red_Revenge/FAF_Coop_Operation_Red_Revenge.scmap',
    save = '/maps/FAF_Coop_Operation_Red_Revenge/FAF_Coop_Operation_Red_Revenge_save.lua',
    script = '/maps/FAF_Coop_Operation_Red_Revenge/FAF_Coop_Operation_Red_Revenge_script.lua',
    norushradius = 80.000000,
    map_version = 1,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Order','Seraphim','QAI','UEF','Player2','Player3','Player4',} },
            },
            customprops = {
            },
            factions = { {'uef','aeon','cybran'}, {'uef','aeon','cybran'}, {'uef','aeon','cybran'}, {'uef','aeon','cybran'} },
        },
    }}
