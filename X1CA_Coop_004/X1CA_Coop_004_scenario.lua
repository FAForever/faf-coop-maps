version = 3
ScenarioInfo = {
    name = 'FA Campaign Mission 4 - Coop',
    description = '<LOC X1CA_Coop_004_description>Coalition Command has received unverified intel that the Seraphim are massing on the planet Hades -- control of Hades will let the Seraphim attack any location within Coalition-controlled space. Elite Commander Dostya will join you for this mission, and the two of you will eliminate any Seraphim forces found on Hades.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/X1CA_Coop_004/X1CA_Coop_004_v04.scmap',
    save = '/maps/X1CA_Coop_004/X1CA_Coop_004_v04_save.lua',
    script = '/maps/X1CA_Coop_004/X1CA_Coop_004_v04_script.lua',
    norushradius = 0.000000,
    norushoffsetX_Player = 0.000000,
    norushoffsetY_Player = 0.000000,
    norushoffsetX_Dostya = 0.000000,
    norushoffsetY_Dostya = 0.000000,
    norushoffsetX_Seraphim = 0.000000,
    norushoffsetY_Seraphim = 0.000000,
    norushoffsetX_SeraphimSecondary = 0.000000,
    norushoffsetY_SeraphimSecondary = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Dostya','Seraphim','SeraphimSecondary', 'Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
