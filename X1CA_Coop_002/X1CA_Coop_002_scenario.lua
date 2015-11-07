version = 3
ScenarioInfo = {
    name = 'FA Campaign Mission 2 - Coop',
    description = '<LOC X1CA_002_description>Aeon Loyalists, led by Crusader Rhiza, were captured while conducting sabotage and intelligence missions against Order and QAI positions. You must rescue the Loyalists being held by QAI and defeat all enemy commanders operating on the planet.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/X1CA_002/X1CA_002.scmap',
    save = '/maps/X1CA_Coop_002/X1CA_Coop_002_save.lua',
    script = '/maps/X1CA_Coop_002/X1CA_Coop_002_script.lua',
    norushradius = 0.000000,
    norushoffsetX_Player = 0.000000,
    norushoffsetY_Player = 0.000000,
    norushoffsetX_Coop1 = 0.000000,
    norushoffsetY_Coop1 = 0.000000,
    norushoffsetX_Coop2 = 0.000000,
    norushoffsetY_Coop2 = 0.000000,
    norushoffsetX_Coop3 = 0.000000,
    norushoffsetY_Coop3 = 0.000000,
    norushoffsetX_Order = 0.000000,
    norushoffsetY_Order = 0.000000,
    norushoffsetX_QAI = 0.000000,
    norushoffsetY_QAI = 0.000000,
    norushoffsetX_Loyalist = 0.000000,
    norushoffsetY_Loyalist = 0.000000,
    norushoffsetX_OrderNeutral = 0.000000,
    norushoffsetY_OrderNeutral = 0.000000,
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Order','QAI','Loyalist','OrderNeutral','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
