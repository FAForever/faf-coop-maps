local OpStrings = import('/maps/X1CA_Coop_006/X1CA_Coop_006_strings.lua')

operationData = 
{
    key = 'X1CA_Coop_006',
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13915',
    opBriefingText = OpStrings.BriefingData,
    opMovies = {
        postOpMovies = {
            factionDependant = true,
            success = {
                uef = {
                    {vid = '/movies/FMV_SCX_Outro.sfd', sfx = 'X_FMV_Outro', sfxBank = 'FMV_BG', voice = 'SCX_Outro_VO', voiceBank = 'X_FMV'},
                    {vid = '/movies/Credits_UEF.sfd', sfx = 'X_FMV_UEF_Credits', sfxBank = 'FMV_BG', voice = 'SCX_UEF_Credits_VO', voiceBank = 'X_FMV', subtitles = 'default'},
                    {vid = '/movies/FMV_SCX_Post_Outro.sfd', sfx = 'X_FMV_Post_Outro', sfxBank = 'FMV_BG', voice = 'SCX_Post_Outro_VO', voiceBank = 'X_FMV', subtitles = 'default'},
                },
                cybran = {
                    {vid = '/movies/FMV_SCX_Outro.sfd', sfx = 'X_FMV_Outro', sfxBank = 'FMV_BG', voice = 'SCX_Outro_VO', voiceBank = 'X_FMV'},
                    {vid = '/movies/Credits_Cybran.sfd', sfx = 'X_FMV_Cybran_Credits', sfxBank = 'FMV_BG', voice = 'SCX_Cybran_Credits_VO', voiceBank = 'X_FMV', subtitles = 'default'},
                    {vid = '/movies/FMV_SCX_Post_Outro.sfd', sfx = 'X_FMV_Post_Outro', sfxBank = 'FMV_BG', voice = 'SCX_Post_Outro_VO', voiceBank = 'X_FMV', subtitles = 'default'},
                },
                aeon = {
                    {vid = '/movies/FMV_SCX_Outro.sfd', sfx = 'X_FMV_Outro', sfxBank = 'FMV_BG', voice = 'SCX_Outro_VO', voiceBank = 'X_FMV'},
                    {vid = '/movies/Credits_Aeon.sfd', sfx = 'X_FMV_Aeon_Credits', sfxBank = 'FMV_BG', voice = 'SCX_Aeon_Credits_VO', voiceBank = 'X_FMV', subtitles = 'default'},
                    {vid = '/movies/FMV_SCX_Post_Outro.sfd', sfx = 'X_FMV_Post_Outro', sfxBank = 'FMV_BG', voice = 'SCX_Post_Outro_VO', voiceBank = 'X_FMV', subtitles = 'default'},
                },
            },
        },
    },
    opDebriefingSuccess = OpStrings.X06_DB01_010,
    opDebriefingFailure = OpStrings.X06_DB01_020,
}
