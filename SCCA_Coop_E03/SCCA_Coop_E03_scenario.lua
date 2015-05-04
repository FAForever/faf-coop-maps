version = 3
ScenarioInfo = {
    name = 'Metal Shark',
    description = 'We have just received word that the Aeon are attacking Matar, an important rim-world. Undoubtedly, they\'re brainwashing the population or slaughtering them outright. You will drive the Aeon from Matar.\nColonel Arnold will maintain overall command responsibility. Colonel, you will be dropped here, while the Captain will be dropped here.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {512, 512},
    map = '/maps/SCCA_Coop_E03/SCCA_Coop_E03_v03.scmap',
    save = '/maps/SCCA_Coop_E03/SCCA_Coop_E03_v03_save.lua',
    script = '/maps/SCCA_Coop_E03/SCCA_Coop_E03_v03_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Aeon','Arnold','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
