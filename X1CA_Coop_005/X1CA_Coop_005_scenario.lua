version = 3
ScenarioInfo = {
    name = 'FA Mission 5 - Mind Games',
    description = '<LOC X1CA_Coop_005_description>Because of the events on Hades, QAI must be destroyed once and for all. Using intelligence acquired from the Seven Hand Node, the Coalition has learned that QAI\'s mainframe is on the planet Pearl II. Your mission is to establish a foothold on Pearl II, thus clearing the way for Dr. Brackman, who will arrive and personally shut down QAI.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/X1CA_Coop_005/X1CA_Coop_005.scmap',
    save = '/maps/X1CA_Coop_005/X1CA_Coop_005_save.lua',
    script = '/maps/X1CA_Coop_005/X1CA_Coop_005_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Fletcher','Hex5','QAI','Aeon','UEF','Order','Brackman','Player2','Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'} },
        },
    }}
