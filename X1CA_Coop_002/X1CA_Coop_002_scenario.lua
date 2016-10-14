version = 3
ScenarioInfo = {
    name = 'FA Mission 2 - Dawn',
    description = '<LOC X1CA_002_description>Aeon Loyalists, led by Crusader Rhiza, were captured while conducting sabotage and intelligence missions against Order and QAI positions. You must rescue the Loyalists being held by QAI and defeat all enemy commanders operating on the planet.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/X1CA_Coop_002/X1CA_Coop_002.scmap',
    save = '/maps/X1CA_Coop_002/X1CA_Coop_002_save.lua',
    script = '/maps/X1CA_Coop_002/X1CA_Coop_002_script.lua',
    norushradius = 0.000000,
    norushoffsetX_Player1 = 0.000000,
    norushoffsetY_Player1 = 0.000000,
    norushoffsetX_Player2 = 0.000000,
    norushoffsetY_Player2 = 0.000000,
    norushoffsetX_Player3 = 0.000000,
    norushoffsetY_Player3 = 0.000000,
    norushoffsetX_Player4 = 0.000000,
    norushoffsetY_Player4 = 0.000000,
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
                { name = 'FFA', armies = {'Player1','Order','QAI','Loyalist','OrderNeutral','Player2','Player3','Player4'} },
            },
            customprops = {
            },
        },
    }}
