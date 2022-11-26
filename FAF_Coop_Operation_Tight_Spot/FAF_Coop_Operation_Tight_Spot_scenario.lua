version = 3
ScenarioInfo = {
    name = 'Operation Tight Spot',
    description = "Coallition scouting mission in the QAI's controlled teritory that went wrong. Fight the QAI's forces to survive and escape from the planet.",
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 512},
    map = '/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot.scmap',
    save = '/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot_save.lua',
    script = '/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot_script.lua',
    map_version = 1,
    norushradius = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Loyalist', 'QAI', 'Civilian', 'Player2'} },
            },
            customprops = {
            },
            factions = { {'aeon'}, {'aeon', 'cybran', 'uef'} },
        },
    }}
