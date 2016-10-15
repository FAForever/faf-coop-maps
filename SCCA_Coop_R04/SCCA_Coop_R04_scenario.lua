version = 3
ScenarioInfo = {
    name = 'Cybran Mission 4 - Mainframe Tango',
    description = 'This is Procyon, an out-of-the-way planet with a small population. Our sensors indicate that the Aeon have landed and are establishing millitary operations. We cannot allow them to seize the planet. Commander, you will travel to Procyon and defeat the Aeon forces. Do not allow them to damage the QAI\'s Mainframe or secondary Processing Nodes. You gate ASAP.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_R04/SCCA_Coop_R04.scmap',
    save = '/maps/SCCA_Coop_R04/SCCA_Coop_R04_save.lua',
    script = '/maps/SCCA_Coop_R04/SCCA_Coop_R04_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Aeon','Civilian','Neutral','Player2','Player3','Player4'} },
            },
            customprops = {
            },
        },
    }}
