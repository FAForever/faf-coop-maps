version = 3
ScenarioInfo = {
    name = '<LOC OPNAME_R04>Cybran Mission 4 - Mainframe Tango',
    description = '<LOC SCCA_R04_description>This is Procyon, an out-of-the-way planet with a small population. Our sensors indicate that the Aeon have landed and are establishing millitary operations. We cannot allow them to seize the planet. Commander, you will travel to Procyon and defeat the Aeon forces. Do not allow them to damage the QAI\'s Mainframe or secondary Processing Nodes. You gate ASAP.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_R04/SCCA_Coop_R04.scmap',
    save = '/maps/SCCA_Coop_R04/SCCA_Coop_R04_save.lua',
    script = '/maps/SCCA_Coop_R04/SCCA_Coop_R04_script.lua',
    norushradius = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Aeon','Civilian','Neutral','Player2','Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'cybran'}, {'cybran'}, {'cybran'}, {'cybran'} },
        },
    }}
