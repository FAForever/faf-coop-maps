version = 3
ScenarioInfo = {
    name = '<LOC OPNAME_A02>Aeon Mission 2 - Machine Purge',
    description = '<LOC SCCA_A02_description>This is Zeta Canis. It was once a UEF colony, but it is now in the hands of those cursed Cybrans.\nZeta Canis offers little in resources, but its location makes it a prime staging area for strikes into UEF territory.\nYou will go to Zeta Canis, destroy any Cybran Commanders on the planet, and cleanse the civilian population.\nLeave none alive.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    norushradius = 0.000000,
    size = {512, 512},
    map = '/maps/SCCA_Coop_A02/SCCA_Coop_A02.scmap',
    save = '/maps/SCCA_Coop_A02/SCCA_Coop_A02_save.lua',
    script = '/maps/SCCA_Coop_A02/SCCA_Coop_A02_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Cybran','NeutralCybran','Player2','Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'aeon'}, {'aeon'}, {'aeon'}, {'aeon'} },
        },
    }}
