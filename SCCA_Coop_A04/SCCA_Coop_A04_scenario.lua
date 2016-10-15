version = 3
ScenarioInfo = {
    name = 'Aeon Mission 4 - Entity',
    description = 'This is Procyon, a planet deep in Cybran territory. We know little of it save its name.\nIn my meditations, I have sensed something there, some...other. I cannot describe it, but it troubles me greatly.\nYou must go to Procyon and discover what it is.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_A04/SCCA_Coop_A04.scmap',
    save = '/maps/SCCA_Coop_A04/SCCA_Coop_A04_save.lua',
    script = '/maps/SCCA_Coop_A04/SCCA_Coop_A04_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Cybran','Civilian','Nodes','Nexus_Defense','Player2','Player3','Player4'} },
            },
            customprops = {
            },
        },
    }}
