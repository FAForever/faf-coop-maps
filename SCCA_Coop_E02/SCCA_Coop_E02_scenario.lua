version = 3
ScenarioInfo = {
    name = 'UEF Mission 2 - Snow Blind',
    description = 'While you were busy on Capella, the Aeon pushed out of the Quarantine Zone and attacked our positions on Luthien. Our forces there are holding their own, but they will fall unless they\'re reinforced.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {512, 512},
    map = '/maps/SCCA_Coop_E02/SCCA_Coop_E02.scmap',
    save = '/maps/SCCA_Coop_E02/SCCA_Coop_E02_save.lua',
    script = '/maps/SCCA_Coop_E02/SCCA_Coop_E02_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Aeon','AllyResearch','AllyCivilian','AeonNeutral','Player2','Player3','Player4'} },
            },
            customprops = {
            },
        },
    }}
