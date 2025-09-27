version = 3
ScenarioInfo = {
    name = "Seabring Defense",
    description = "Defend the Seabring Town from Gari's assault.",
    type = "campaign_coop",
    starts = true,
    preview = "",
    size = {1024, 1024},
    -- Do not manually edit. Ever. Controlled by deployment script:
    map_version = 1,
    map = "/maps/X1CA_001/X1CA_001.scmap",
    save = "/maps/FAF_Coop_Seabring_Defense/FAF_Coop_Seabring_Defense_save.lua",
    script = "/maps/FAF_Coop_Seabring_Defense/FAF_Coop_Seabring_Defense_script.lua",
    norushradius = 0.000000,
    Configurations = {
        ["standard"] = {
            teams = {
                { name = "FFA", armies = {"Player1","Order","UEF","Civilians",} },
            },
            customprops = {
            },
            factions = { {"uef"} },
        },
    }}
