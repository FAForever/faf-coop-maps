version = 3
ScenarioInfo = {
    name = 'Cybran Mission 1 - Liberation',
    description = 'All of the Symbionts on Theban 2 have been enslaved by the UEF\'s loyalty programming. We have initiated a wideband broadcast of the Symbiont Liberation Matrix; by the time we arrive, our brothers and sisters will be free and ready to evacuate.\nUnfortunately, the Aeon have also set their sights on Theban 2 and have launched an offensive against local UEF forces. Defeat the Aeon and UEF armies in your sector in order to free the Symbionts. I will engage the primary UEF commander.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {512, 512},
    map = '/maps/SCCA_Coop_R01/SCCA_Coop_R01.scmap',
    save = '/maps/SCCA_Coop_R01/SCCA_Coop_R01_save.lua',
    script = '/maps/SCCA_Coop_R01/SCCA_Coop_R01_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Aeon','UEF','Symbiont','Dostya','FauxUEF','Wreckage_Holding','Player2', 'Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'cybran'}, {'cybran'}, {'cybran'}, {'cybran'} },
        },
    }}
