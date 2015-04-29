version = 3
ScenarioInfo = {
    name = 'Operation Stone Wall',
    description = 'Black Sun facility is located here, on the island of Ni\'ihua in the Hawaiian chain.\nYour job is simple: You will protect Black Sun during the final stages of its completion. Once it is operational, you will fire it. Captain Aiko is currently in charge of security at the Facility;\n she will offer her unconditional assistance. You now have full access to the UEF arsenal.',
    type = 'campaign_coop',
    starts = true,
    preview = '',
    size = {1024, 1024},
    map = '/maps/SCCA_Coop_E06/SCCA_Coop_E06_v01.scmap',
    save = '/maps/SCCA_Coop_E06/SCCA_Coop_E06_v01_save.lua',
    script = '/maps/SCCA_Coop_E06/SCCA_Coop_E06_v01_script.lua',
    Configurations = {
        ['standard'] = {
            teams = {
                { name = 'FFA', armies = {'Player','Black_Sun','Aeon','Cybran','Component','Coop1','Coop2','Coop3',} },
            },
            customprops = {
            },
        },
    }}
