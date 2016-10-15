version = 3
ScenarioInfo = {
    name = 'UEF Mission 5 - Forge',
    description = 'The Aeon are bypassing our defensive lines and the Cybran virus is wreaking havoc with our Quantum Gates. The data you retrieved on Minerva wasn\'t enough; our techs won\'t be able to isolate and neutralize the virus in time.\nOur only option is to deploy Project: Black Sun before the Cybrans manage to infect the entire Gate Network. Black Sun uses the Quantum Gates to magnify and deliver a shockwave to any location in the galaxy. Black Sun can destroy any planet.\nhe final Black Sun components are being readied on Pisces IV. You are to ensure that those components reach Earth. The Pisces Gate has been isolated from the Network and the techs assure me that it\'ll work.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_E05/SCCA_Coop_E05.scmap',
    save = '/maps/SCCA_Coop_E05/SCCA_Coop_E05_save.lua',
    script = '/maps/SCCA_Coop_E05/SCCA_Coop_E05_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Aeon','City','Cybran','Player2','Player3','Player4'} },
            },
            customprops = {
            },
        },
    }}
