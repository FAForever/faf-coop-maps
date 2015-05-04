version = 3
ScenarioInfo = {
    name = 'Aeon Vanilla Campain - Mission 4',
    description = 'This is Procyon, a planet deep in Cybran territory. We know little of it save its name.\nIn my meditations, I have sensed something there, some...other. I cannot describe it, but it troubles me greatly.\nYou must go to Procyon and discover what it is.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_A04/SCCA_Coop_A04_v04.scmap',
    save = '/maps/SCCA_Coop_A04/SCCA_Coop_A04_v04_save.lua',
    script = '/maps/SCCA_Coop_A04/SCCA_Coop_A04_v04_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Cybran','Civilian','Nodes','Nexus_Defense','Coop1','Coop2','Coop3'} },
            },
            customprops = {
            },
        },
    }}
