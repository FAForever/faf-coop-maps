version = 3
ScenarioInfo = {
    name = 'FA Mission 6 - Overlord',
    description = '<LOC X1CA_Coop_006_description>Using Gate codes recovered from the remains of QAI, Coalition forces can now gate directly to Earth, where the Seraphim are constructing a Quantum Arch. Once complete, the Arch will let the Seraphim summon untold reinforcements. The Arch must be destroyed, no matter the cost.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 3,
    size = {1024, 1024},
    map = '/maps/X1CA_Coop_006/X1CA_Coop_006.scmap',
    save = '/maps/X1CA_Coop_006/X1CA_Coop_006_save.lua',
    script = '/maps/X1CA_Coop_006/X1CA_Coop_006_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player1','Rhiza','Fletcher','Order','Seraphim','ControlCenter','OptionZero','Player2','Player3','Player4'} },
            },
            customprops = {
            },
            factions = { {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'}, {'uef', 'aeon', 'cybran'} },
        },
    }}
