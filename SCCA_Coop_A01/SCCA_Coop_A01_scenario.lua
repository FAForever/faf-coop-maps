version = 3
ScenarioInfo = {
    name = 'Aeon Mission 1 - Joust',
    description = "This is Rigel, a lightly populated UEF world.\nYour task is to assist Crusader Rhiza, who is engaging the UEF along several fronts. She will evaluate your performance.\nRemember, Knight, our primary mission is to spread The Way to humanity. That is our calling. The Way will bring peace.",
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {512, 512},
    map = '/maps/SCCA_Coop_A01/SCCA_Coop_A01.scmap',
    save = '/maps/SCCA_Coop_A01/SCCA_Coop_A01_save.lua',
    script = '/maps/SCCA_Coop_A01/SCCA_Coop_A01_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Rhiza','UEF','FauxUEF','FauxRhiza','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
