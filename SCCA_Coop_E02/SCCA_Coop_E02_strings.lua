
--*****************************************************************************
--* File: C:\work\rts\main\data\maps\SCCA_Coop_E02\SCCA_Coop_E02_strings.lua
--* Author: (BOT)Sam Demulling 
--* Summary: Computer Generated operation data for E02
--*
--* This file was generated by SCUD.  Do not make manual changes to this file
--* or they will be overwritten!
--*
--* Campaign Faction: UEF
--* Campaign Description: UEF SP Campaign
--* Operation Name: Operation Snow Blind
--* Operation Description: Defend research facility and Luthien Colony, defeat Aeon threat
--*
--* Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
--*****************************************************************************


OPERATION_NAME = '<LOC OPNAME_E02>Operation Snow Blind'
OPERATION_DESCRIPTION = 'While you were busy on Capella, the Aeon pushed out of the Quarantine Zone and attacked our positions on Luthien. Our forces there are holding their own, but they will fall unless they\'re reinforced.'



--------------------------------
-- Opnode ID: B01
-- Operation Briefing
--------------------------------

BriefingData = {
  text = {
    {phase = 0, character = '<LOC Date>Date', text = '<LOC E02_B01_000_010>Date: 16-AUGUST-3844'},
    {phase = 1, character = '<LOC Clarke>Clarke', text = '<LOC E02_B01_001_010>While you were busy on Capella, the Aeon pushed out of the Quarantine Zone and attacked our positions on Luthien. Our forces there are holding their own, but they will fall unless they\'re reinforced.'},
    {phase = 2, character = '<LOC Clarke>Clarke', text = '<LOC E02_B01_002_010>The strategic importance of Luthien cannot be overstated. The planet is rich in natural resources and home to a small Research and Development Facility that is doing work vital to the UEF; it must not fall to the Aeon.'},
    {phase = 3, character = '<LOC Clarke>Clarke', text = '<LOC E02_B01_003_010>Colonel Arnold will oversee the OP. Lieutenant, you will support the Colonel. Questions?'},
    {phase = 3, character = '<LOC Arnold>Arnold', text = '<LOC E02_B01_003_020>How much longer am I going to be holding this guy\'s hand? '},
    {phase = 3, character = '<LOC Clarke>Clarke', text = '<LOC E02_B01_003_030>You have your orders, Colonel.'},
    {phase = 4, character = '<LOC Clarke>Clarke', text = '<LOC E02_B01_004_010>A word of warning, Lieutenant. The Aeon are brain-washing monsters who have only one purpose, to spread their so-called \'Way.\' Do not listen to anything they say. Attack and kill them with extreme prejudice. You gate in 30.'},
  },
  movies = {'E02_B01.sfd', 'E02_B02.sfd', 'E02_B03.sfd', 'E02_B04.sfd',},
  voice = {
    {Cue = 'E02_B01', Bank = 'E02_VO'},
    {Cue = 'E02_B02', Bank = 'E02_VO'},
    {Cue = 'E02_B03', Bank = 'E02_VO'},
    {Cue = 'E02_B04', Bank = 'E02_VO'},
  },
  bgsound = {
    {Cue = 'E02_B01', Bank = 'Op_Briefing_Vanilla'},
    {Cue = 'E02_B02', Bank = 'Op_Briefing_Vanilla'},
    {Cue = 'E02_B03', Bank = 'Op_Briefing_Vanilla'},
    {Cue = 'E02_B04', Bank = 'Op_Briefing_Vanilla'},
  },
  style = 'uef',
}

--------------------------------
-- Opnode ID: DB01
-- Operation Debriefing
--------------------------------

E02_DB01_010 = {
  {text = '<LOC CAMPDEB_0014>Despite the advantage of a two hour head start, Aeon forces were unable to make any progress towards occupying Luthien. Colonel Zachary Arnold led the defense of Station Lima Foxtrot and the evacuation of Luthien Colony. Both the Colony and the Station suffered only light damage and civilian losses were minimal. The Aeon Commander, despite a formidable base, was defeated and the Aeon have made no further attempts to occupy the planet.', faction = 'UEF'},
}

E02_DB01_020 = {
  {text = '<LOC CAMPDEB_0015>Despite heroic efforts by UEF personnel, Luthien was lost to Aeon invaders. Communication logs indicate that Station Lima Foxtrot was destroyed, with all personnel either declared dead or captured by the Aeon. Constable Keiichi Nakamura led the defense of Luthien Colony for nearly 24 hours before it was overwhelmed. Constable Nakamura has been posthumously awarded the UEF Cross 1st Class for his valor and leadership. All contact with Luthien has been lost.', faction = 'UEF'},
}

--------------------------------
-- Opnode ID: D01
-- Player Death
--------------------------------



-- Player Death Message
E02_D01_010 = {
  {text = '<LOC E02_D01_010_010>[{i EarthCom}]: Lieutenant! Come in, Lieutenant! We\'ve lost your signal...Lieutenant, report...', vid = 'E02_EarthCom_D01_0056.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_D01_0056', faction = 'UEF'},
}

--------------------------------
-- Opnode ID: M01
-- Rescue
--------------------------------



-- Player Lands
E02_M01_010 = {
  {text = '<LOC E02_M01_010_010>[{i Stenson}]: This is Director Stenson of Science Station Lima Foxtrot. Our Power Core has been breached and we are unable to repair it. If it isn\'t contained soon, the entire Facility will explode.', vid = 'E02_Stenson_M01_0100.sfd', bank = 'E02_VO', cue = 'E02_Stenson_M01_0100', faction = 'UEF'},
  {text = '<LOC E02_M01_010_020>[{i EarthCom}]: Colonel Arnold, General Clarke\'s orders are to get to Station Lima Foxtrot and fix that Power Core ASAP. EarthCom out.', vid = 'E02_EarthCom_M01_0044.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M01_0044', faction = 'UEF'},
}

-- Once a Air Factory is built
E02_M01_020 = {
  {text = '<LOC E02_M01_020_010>[{i EarthCom}]: Colonel Arnold has confirmed that you have constructed an Air Factory. We\'re uploading the schematic for the C-6 \'Courier\' Light Air Transport.', vid = 'E02_EarthCom_M01_0057.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M01_0057', faction = 'UEF'},
}

-- Once a Transport is built
E02_M01_030 = {
  {text = '<LOC E02_M01_030_010>[{i Arnold}]: Use your transport to move either your Armored Command Unit or an Engineer to Lima. Scans are showing a lot of Aeon activity between you and the facility, so it\'s going to be hot. Clear out the enemy before you try and reach Lima. ', vid = 'E02_Arnold_M01_0045.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M01_0045', faction = 'UEF'},
  {text = '<LOC E02_M01_030_020>[{i Arnold}]: You\'re on your own, rookie.', vid = 'E02_Arnold_M01_0046.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M01_0046', faction = 'UEF'},
}

-- 2 minutes into mission
E02_M01_040 = {
  {text = '<LOC E02_M01_040_010>[{i Arnold}]: Wait, what the...those eggheads dropped me on the wrong side of the continent! I\'m no help, EarthCom, it\'ll be hours before I can get there. Tell Clarke the rookie will have to do it on his own!', vid = 'E02_Arnold_M01_0047.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M01_0047', faction = 'UEF'},
  {text = '<LOC E02_M01_040_020>[{i EarthCom}]: Lieutenant, General Clarke has placed you in charge of the OP. Establish a base with some basic defenses and then build an Air Factory. Colonel Arnold will advise as necessary.', vid = 'E02_EarthCom_M01_0058.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M01_0058', faction = 'UEF'},
}

-- 5 minutes into mission
E02_M01_050 = {
  {text = '<LOC E02_M01_050_010>[{i Min}]: Attention Station Lima Foxtrot. This is Templar Min of the Aeon Illuminate. We have no intention of harming you. Surrender now and avoid unnecessary bloodshed.', vid = 'E02_Min_M01_0079.sfd', bank = 'E02_VO', cue = 'E02_Min_M01_0079', faction = 'Aeon'},
  {text = '<LOC E02_M01_050_020>[{i Arnold}]: Don\'t listen to her!', vid = 'E02_Arnold_M01_0048.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M01_0048', faction = 'UEF'},
}

-- 8 minutes into mission
E02_M01_060 = {
  {text = '<LOC E02_M01_060_010>[{i Stenson}]: The Core temperature has doubled. We can\'t last much longer!', vid = 'E02_Stenson_M01_0101.sfd', bank = 'E02_VO', cue = 'E02_Stenson_M01_0101', faction = 'UEF'},
}

-- 13 minutes into mission
E02_M01_070 = {
  {text = '<LOC E02_M01_070_010>[{i Stenson}]: The Core is increasingly unstable. You\'ve got to do something! There isn\'t much time left!', vid = 'E02_Stenson_M01_0102.sfd', bank = 'E02_VO', cue = 'E02_Stenson_M01_0102', faction = 'UEF'},
}

-- 18 minutes into mission
E02_M01_080 = {
  {text = '<LOC E02_M01_080_010>[{i Stenson}]: ...the thermal shield is failing! The Core will explode any minute!', vid = 'E02_Stenson_M01_0103.sfd', bank = 'E02_VO', cue = 'E02_Stenson_M01_0103', faction = 'UEF'},
  {text = '<LOC E02_M01_080_020>[{i Arnold}]: What are you doing? Get over there and help them! We\'re going to lose that whole Facility!', vid = 'E02_Arnold_M01_0049.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M01_0049', faction = 'UEF'},
}

-- once the player reaches the station
E02_M01_090 = {
  {text = '<LOC E02_M01_090_010>[{i Stenson}]: Thank goodness you\'ve made it! Repair the Core, quickly!', vid = 'E02_Stenson_M01_0104.sfd', bank = 'E02_VO', cue = 'E02_Stenson_M01_0104', faction = 'UEF'},
}

-- If SO#1 is completed
E02_M01_140 = {
  {text = '<LOC E02_M01_140_010>[{i Arnold}]: Looks like you got all the patrols. You actually impressed me with that one, rookie.', vid = 'E02_Arnold_M01_0050.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M01_0050', faction = 'UEF'},
}

-- If Science Facility is destoryed
E02_M01_150 = {
  {text = '<LOC E02_M01_150_010>[{i EarthCom}]: Station Lima Foxtrot come in. I repeat, Station Lima Foxtrot come in. It\'s no good. I think we lost them. Abort mission and recall. EarthCom out.', vid = 'E02_EarthCom_M01_0059.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M01_0059', faction = 'UEF'},
}

-- If the players completes all Primary Objectives
E02_M01_160 = {
  {text = '<LOC E02_M01_160_010>[{i EarthCom}]: The Core has been repaired and the Station is secure. Good job, Lieutenant. EarthCom out.', vid = 'E02_EarthCom_M01_0060.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M01_0060', faction = 'UEF'},
}

-- Objective Reminders for PO2, #1
E02_M01_200 = {
  {text = '<LOC E02_M01_200_010>[{i EarthCom}]: Sir, you haven\'t built a transport yet. Is there a problem? EarthCom out. ', vid = 'E02_EarthCom_M01_00691.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M01_00691', faction = 'UEF'},
}

-- Objective Reminders for PO4, #4
E02_M01_210 = {
  {text = '<LOC E02_M01_210_010>[{i EarthCom}]: Sir, General Clarke is wondering why the Power Core hasn\'t been repaired yet. EarthCom out.', vid = 'E02_EarthCom_M01_00692.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M01_00692', faction = 'UEF'},
}

--------------------------------
-- Opnode ID: M01_OBJ
-- Rescue Objectives
--------------------------------

-- Primary Objectives
M1P1Text = '<LOC E02_M01_OBJ_010_111>Build an Air Factory'

-- Primary Objectives
M1P1Detail = '<LOC E02_M01_OBJ_010_112>The C-6 \'Courier\' Transport is now available at the Air Factory. A transport will be necessary to move your ACU or an Engineer to Station Lima Foxtrot.'

-- Primary Objectives
M1P15Text = '<LOC E02_M01_OBJ_010_121>Build a Transport'

-- Primary Objectives
M1P15Detail = '<LOC E02_M01_OBJ_010_122>The Tech 1 transport has limited carrying capacity, but it will be sufficient to carry either your ACU or an Engineer to Station Lima Foxtrot.'

-- Primary Objectives
M1P2Text = '<LOC E02_M01_OBJ_010_131>Transport Your ACU or an Engineer to the Station'

-- Primary Objectives
M1P2Detail = '<LOC E02_M01_OBJ_010_132>Clear a path through the Aeon patrols before you send out your transport, otherwise it might get shot down.'

-- Primary Objectives
M1P3Text = '<LOC E02_M01_OBJ_010_141>Repair the Research Facility at Station Lima Foxtrot'

-- Primary Objectives
M1P3Detail = '<LOC E02_M01_OBJ_010_142>The Power Core must be repaired by an ACU or an Engineer! If it explodes, it will destroy the Station and end the Operation.'

-- Secondary Objectives
M1S1Text = '<LOC E02_M01_OBJ_020_111>Defeat All Aeon Patrols'

-- Secondary Objectives
M1S1Detail = '<LOC E02_M01_OBJ_020_112>In order to ensure safe passage for your transport, destroy any Aeon units patrolling the area.'

-- Bonus/Hidden Objectives
M1H1Text = '<LOC E02_M01_OBJ_030_111>Death From Above'

-- Bonus/Hidden Objectives
M1H1Detail = '<LOC E02_M01_OBJ_030_112>One of your Gunships has increased in rank to Veteran.'

-- Bonus/Hidden Objectives
M1H2Text = '<LOC E02_M01_OBJ_030_121>Generator'

-- Bonus/Hidden Objectives
M1H2Detail = '<LOC E02_M01_OBJ_030_122>You\'ve generated over %s units of Energy.'



--------------------------------
-- Opnode ID: M02
-- Shield Wall
--------------------------------



-- Start of Mission 2
E02_M02_010 = {
  {text = '<LOC E02_M02_010_010>[{i EarthCom}]: Sir, scans detect a large group of Aeon ground forces. They appear to be readying another attack. General Clarke has authorized you to receive the \'Air Cleaner\' Tech 2 Anti-Air Turret and the \'Triad\' Tech 2 Point Defense Turret. Upgrade any of your factories and construct a Tech 2 Engineer to build these new units. EarthCom out.', vid = 'E02_EarthCom_M02_0061.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M02_0061', faction = 'UEF'},
}

-- 5 minutes before the Aeon actually attack 
E02_M02_020 = {
  {text = '<LOC E02_M02_020_010>[{i EarthCom}]: Sir, the Aeon will soon launch an attack. EarthCom out.', vid = 'E02_EarthCom_M02_0062.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M02_0062', faction = 'UEF'},
}

-- As the Aeon units are moving to attack (1st Wave)
E02_M02_030 = {
  {text = '<LOC E02_M02_030_010>[{i Stenson}]: They\'re coming! They\'re going to slaughter us all!', vid = 'E02_Stenson_M02_0105.sfd', bank = 'E02_VO', cue = 'E02_Stenson_M02_0105', faction = 'UEF'},
  {text = '<LOC E02_M02_030_020>[{i Min}]: You were given the opportunity to save yourselves. You will now suffer the wrath of the Illuminate.', vid = 'E02_Min_M02_0080.sfd', bank = 'E02_VO', cue = 'E02_Min_M02_0080', faction = 'Aeon'},
}

-- 2nd Wave
E02_M02_035 = {
  {text = '<LOC E02_M02_035_010>[{i EarthCom}]: Sir, more units are approaching. EarthCom out.', vid = 'E02_EarthCom_M02_01139.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M02_01139', faction = 'UEF'},
}

-- 3rd Wave
E02_M02_037 = {
  {text = '<LOC E02_M02_037_010>[{i EarthCom}]: Another force is moving in, sir. This is the biggest one yet. EarthCom out.', vid = 'E02_EarthCom_M02_01140.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M02_01140', faction = 'UEF'},
}

-- Once the Aeon attack is thwarted
E02_M02_040 = {
  {text = '<LOC E02_M02_040_010>[{i Min}]: Why do you resist? Lay down your arms and accept your fate.', vid = 'E02_Min_M02_0081.sfd', bank = 'E02_VO', cue = 'E02_Min_M02_0081', faction = 'Aeon'},
  {text = '<LOC E02_M02_040_020>[{i Arnold}]: Nice job defending the Station, rookie.', vid = 'E02_Arnold_M02_0051.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M02_0051', faction = 'UEF'},
}

--------------------------------
-- Opnode ID: M02_OBJ
-- Shield Wall Objectives
--------------------------------

-- Primary Objectives
M15P1Text = '<LOC E02_M02_OBJ_010_211>Defeat Aeon Assault'

-- Primary Objectives
M15P1Detail = '<LOC E02_M02_OBJ_010_212>Multiple waves of Aeon units are heading towards Station Lima Foxtrot. Protect the Station at all costs.'



--------------------------------
-- Opnode ID: M03
-- Bodyguard
--------------------------------



-- SO#1 is revealed when  the player first gains LoS on an Aeon Radar. 
E02_M03_010 = {
  {text = '<LOC E02_M03_010_010>[{i EarthCom}]: Sir, we have detected three Aeon Short-Range Radar Installations in the area. Destroy them if you are able. EarthCom out.', vid = 'E02_EarthCom_M03_0063.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_0063', faction = 'UEF'},
}

-- if the SO#1 is completed
E02_M03_020 = {
  {text = '<LOC E02_M03_020_010>[{i EarthCom}]: All three Aeon Short-Range Radar Installations have been destroyed. EarthCom out.', vid = 'E02_EarthCom_M03_0064.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_0064', faction = 'UEF'},
}

-- PO#1 & PO#2 are revealed. ( 1.Get Units to Luthien Colony & 2.Evacuate Luthien Colony )
E02_M03_025 = {
  {text = '<LOC E02_M03_025_010>[{i EarthCom}]: Sir, General Clarke has decided to evacuate Luthien Colony. You are to escort a convoy of civilian trucks to Station Lima--', vid = 'E02_EarthCom_M03_0065.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_0065', faction = 'UEF'},
  {text = '<LOC E02_M03_025_020>[{i Arnold}]: After all this, we\'re abandoning the planet to those monsters?', vid = 'E02_Arnold_M03_0052.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M03_0052', faction = 'UEF'},
}

-- 3 minutes after PO#2 is revealed 
E02_M03_030 = {
  {text = '<LOC E02_M03_030_010>[{i Nakamura}]: Lieutenant, this is Constable Nakamura of Luthien. We\'ll be ready to evacuate once you get some escorts down here. They\'re going to hit us hard, so you\'ll need some tanks and Mobile Anti-Air units. Make sure they\'re escorted by Gunships. Luthien out.', vid = 'E02_Nakamura_M03_0092.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_0092', faction = 'UEF'},
}

-- if the player has not gotten units to the Colony within 10 minutes
E02_M03_040 = {
  {text = '<LOC E02_M03_040_010>[{i Nakamura}]: We\'re still waiting on those escorts, Lieutenant. Luthien out.', vid = 'E02_Nakamura_M03_0093.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_0093', faction = 'UEF'},
}

-- Once the player has sufficient units at the Colony 
E02_M03_050 = {
  {text = '<LOC E02_M03_050_010>[{i Nakamura}]: Lieutenant, the trucks have exited the Colony. They are now under your control. Luthien out.', vid = 'E02_Nakamura_M03_0094.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_0094', faction = 'UEF'},
}

-- If a Truck is blocked
E02_M03_060 = {
  {text = '<LOC E02_M03_060_010>[{i Nakamura}]: One of the trucks is blocked, Commander. We need you to clear the way. Luthien out.', vid = 'E02_Nakamura_M03_0095.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_0095', faction = 'UEF'},
}

-- If a Truck takes damage 
E02_M03_070 = {
  {text = '<LOC E02_M03_070_010>[{i Nakamura}]: The Aeon found the trucks! They\'re attacking!', vid = 'E02_Nakamura_M03_0096.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_0096', faction = 'UEF'},
}

-- If a Truck is lost 
E02_M03_080 = {
  {text = '<LOC E02_M03_080_010>[{i Nakamura}]: The Aeon have destroyed a truck...all those poor people...', vid = 'E02_Nakamura_M03_0097.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_0097', faction = 'UEF'},
}

-- If a 2nd Truck is lost 
E02_M03_090 = {
  {text = '<LOC E02_M03_090_010>[{i Nakamura}]: We\'ve lost more trucks, Lieutenant! We need more protection! Luthien out.', vid = 'E02_Nakamura_M03_0098.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_0098', faction = 'UEF'},
}

-- If a 3rd Truck is lost 
E02_M03_100 = {
  {text = '<LOC E02_M03_100_010>[{i Nakamura}]: We\'ve lost too many trucks! We can\'t afford to lose anymore!', vid = 'E02_Nakamura_M03_0099.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_0099', faction = 'UEF'},
}

-- When First truck reaches Facility
E02_M03_110 = {
  {text = '<LOC E02_M03_110_010>[{i EarthCom}]: A truck has reached Station Lima Foxtrot, sir. EarthCom out.', vid = 'E02_EarthCom_M03_0067.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_0067', faction = 'UEF'},
}

-- When Second truck reaches Facility 
E02_M03_120 = {
  {text = '<LOC E02_M03_120_010>[{i EarthCom}]: Sir, another truck has reached the Station safely. EarthCom out.', vid = 'E02_EarthCom_M03_0068.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_0068', faction = 'UEF'},
}

-- When last truck reaches facility 
E02_M03_130 = {
  {text = '<LOC E02_M03_130_010>[{i EarthCom}]: Lieutenant, another truck has made it to the Station. EarthCom out.', vid = 'E02_EarthCom_M03_0069.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_0069', faction = 'UEF'},
}

-- Mission ends when all Primary Objectives have been completed
E02_M03_140 = {
  {text = '<LOC E02_M03_140_010>[{i EarthCom}]: Luthien Colony has been successfully evacuated and medical teams are tending to the survivors. Mission completed. EarthCom out.', vid = 'E02_EarthCom_M03_0070.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_0070', faction = 'UEF'},
}

-- If all the trucks make it, play the next VO instead of 140 
E02_M03_150 = {
  {text = '<LOC E02_M03_150_010>[{i EarthCom}]: Sir, the Luthien Council wishes to thank you for your excellent work during the evacuation effort. EarthCom out.', vid = 'E02_EarthCom_M03_0071.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_0071', faction = 'UEF'},
}

-- If 4+ Trucks are destroyed 
E02_M03_170 = {
  {text = '<LOC E02_M03_170_010>[{i EarthCom}]: Sir, there were too many civilian casualties. Abort the mission and return to Earth. Colonel Arnold will oversee the rest of the operation.', vid = 'E02_EarthCom_M03_0073.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_0073', faction = 'UEF'},
}

-- Easy Mode - New convoy of trucks spawned
E02_M03_175 = {
  {text = '<LOC E02_M03_175_010>[{i Nakamura}]: Another group of trucks is ready to be escorted, Lieutenant. Luthien out.', vid = 'E02_Nakamura_M03_01335.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_01335', faction = 'UEF'},
}

-- If the player completes all Primary Objectives
E02_M03_180 = {
  {text = '<LOC E02_M03_180_010>[{i EarthCom}]: Luthien Colony has successfully evacuated and medical teams are seeing to the survivors. Mission completed. EarthCom out.', vid = 'E02_EarthCom_M03_0074.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_0074', faction = 'UEF'},
}

-- Objective Reminders for PO1,#1
E02_M03_200 = {
  {text = '<LOC E02_M03_200_010>[{i EarthCom}]: Sir, Luthien Colony is still waiting for your units to arrive. EarthCom out. ', vid = 'E02_EarthCom_M03_00693.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_00693', faction = 'UEF'},
}

-- Objective Reminders for P01, #2
E02_M03_205 = {
  {text = '<LOC E02_M03_205_010>[{i Nakamura}]: Lieutenant, the convoy is ready to go. We\'re just waiting for your units to arrive. Luthien out.', vid = 'E02_Nakamura_M03_01458.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_01458', faction = 'UEF'},
}

-- Objective Reminders for PO2, #1
E02_M03_210 = {
  {text = '<LOC E02_M03_210_010>[{i EarthCom}]: Sir, Station Lima Foxtrot is still waiting for the convoy from Luthien Colony to arrive. EarthCom out. ', vid = 'E02_EarthCom_M03_00695.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M03_00695', faction = 'UEF'},
}

-- Objective Reminders for PO2, #2
E02_M03_215 = {
  {text = '<LOC E02_M03_215_010>[{i Nakamura}]: You need to get those trucks to the Station soon, Lieutenant. The longer they\'re out there, the more likely the Aeon are to find them.', vid = 'E02_Nakamura_M03_01459.sfd', bank = 'E02_VO', cue = 'E02_Nakamura_M03_01459', faction = 'UEF'},
}

--------------------------------
-- Opnode ID: M03_OBJ
-- Bodyguard Objectives
--------------------------------

-- Primary Objectives 
M2P1Text = '<LOC E02_M03_OBJ_010_311>Get Units to Luthien Colony'

-- Primary Objectives 
M2P1Detail = '<LOC E02_M03_OBJ_010_312>The civilians will need escorts if they are to safely reach Station Lima Foxtrot. Move at least %s tanks, %s AA units, and %s Gunships to the Luthien Colony to begin the evacuation.'

-- Primary Objectives 
TruckProgress = '<LOC E02_M03_OBJ_010_313>(%s/%s)'

-- Primary Objectives 
M2P2Text = '<LOC E02_M03_OBJ_010_321>Evacuate Luthien Colony'

-- Primary Objectives 
M2P2Detail = '<LOC E02_M03_OBJ_010_322>Luthien Colony will not be able to hold off the Aeon for long. Move the civilians to the Station Lima Foxtrot for protection.'

-- Secondary Objectives
M2S1Text = '<LOC E02_M03_OBJ_020_311>Destroy all Aeon Light Radar Installations'

-- Secondary Objectives
M2S1Detail = '<LOC E02_M03_OBJ_020_312>By destroying the Aeon\'s radar installations, you will prevent them from accessing their Intelligence Network.'

-- Secondary Objectives
RadarProgress = '<LOC E02_M03_OBJ_020_313>(%s/%s)'

-- Secondary Objectives
M2S2Fail = '<LOC E02_M03_OBJ_020_314>Radar installation destroyed.'

-- Bonus Hidden Objectives 
M2H1Text = '<LOC E02_M03_OBJ_030_311>All Civilian Trucks Survived'

-- Bonus Hidden Objectives 
M2H1Detail = '<LOC E02_M03_OBJ_030_312>General Clarke sends her personal congratulations and thanks you for saving the civilians.'



--------------------------------
-- Opnode ID: M04
-- Avalanche
--------------------------------



-- Map Expands
E02_M04_010 = {
  {text = '<LOC E02_M04_010_010>[{i EarthCom}]: Sir, in addition to defending Station Lima Foxtrot, you are to exterminate the Aeon Commander. Colonel Arnold will continue to advise. EarthCom out.', vid = 'E02_EarthCom_M04_0075.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M04_0075', faction = 'UEF'},
}

-- Once 2 minutes have passed 
E02_M04_040 = {
  {text = '<LOC E02_M04_040_010>[{i Min}]: It appears that I\'ve underestimated you, Commander. Now you will experience the fury of the Aeon.', vid = 'E02_Min_M04_0082.sfd', bank = 'E02_VO', cue = 'E02_Min_M04_0082', faction = 'Aeon'},
}

-- Once 5 minutes have passed   
E02_M04_050 = {
  {text = '<LOC E02_M04_050_010>[{i Arnold}]: Satellite feeds of the Aeon base reveal a flaw: The eastern part of Min\'s base is defended with shields. Use ground units to take out her Power Generators and then hit her head-on once the shields are down.', vid = 'E02_Arnold_M04_0053.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M04_0053', faction = 'UEF'},
}

-- If SO#1 completed 
E02_M04_070 = {
  {text = '<LOC E02_M04_070_010>[{i Arnold}]: Thorough, ain\'t ya?', vid = 'E02_Arnold_M04_0054.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M04_0054', faction = 'UEF'},
}

-- If still incomplete from M2, SO#2 reappears 
E02_M04_080 = {
  {text = '<LOC E02_M04_080_010>[{i EarthCom}]: Sir, we have detected three Aeon Short-Range Radar Installations in the area. Destroy them if you are able. EarthCom out.', vid = 'E02_EarthCom_M04_0076.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M04_0076', faction = 'UEF'},
}

-- If SO#2 is completed
E02_M04_090 = {
  {text = '<LOC E02_M04_090_010>[{i EarthCom}]: All three Aeon Short-Range Radar Installations have been destroyed. EarthCom out.', vid = 'E02_EarthCom_M04_0077.sfd', bank = 'E02_VO', cue = 'E02_EarthCom_M04_0077', faction = 'UEF'},
}

-- When Aeon CDR is defeated
E02_M04_130 = {
  {text = '<LOC E02_M04_130_010>[{i Min}]: You may have defeated me, but my spirit lives on in The Way! ', vid = 'E02_Min_M04_0083.sfd', bank = 'E02_VO', cue = 'E02_Min_M04_0083', faction = 'Aeon'},
}

-- If the player completes all PO\'s NIS 
E02_M04_150 = {
  {text = '<LOC E02_M04_150_010>[{i Arnold}]: Great job, Lieutenant. The first round is on me!', vid = 'E02_Arnold_M04_0055.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M04_0055', faction = 'UEF'},
}

-- Objective Reminders for PO2, #1
E02_M04_210 = {
  {text = '<LOC E02_M04_210_010>[{i Arnold}]: Keep at it, you\'ll bring that Aeon down soon enough. Arnold out. ', vid = 'E02_Arnold_M04_00697.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M04_00697', faction = 'UEF'},
}

-- Objective Reminders for PO2, #2
E02_M04_215 = {
  {text = '<LOC E02_M04_215_010>[{i Arnold}]: If you\'re having trouble with that Aeon, try a different unit combination. That might expose a flaw in her defenses. Arnold out.', vid = 'E02_Arnold_M04_01097.sfd', bank = 'E02_VO', cue = 'E02_Arnold_M04_01097', faction = 'UEF'},
}

--------------------------------
-- Opnode ID: M04_OBJ
-- Avalanche Objectives
--------------------------------

-- Primary Objectives
M3P1Text = '<LOC E02_M04_OBJ_010_411>Defend Station Lima Foxtrot'

-- Primary Objectives
M3P1Detail = '<LOC E02_M04_OBJ_010_412>The Science Facility and its research are extremely valuable. Defend the Facility.'

-- Primary Objectives
M3P2Text = '<LOC E02_M04_OBJ_010_421>Defeat the Aeon Commander'

-- Primary Objectives
M3P2Detail = '<LOC E02_M04_OBJ_010_422>Defeat the Aeon Commander to ensure the safety of Station Lima Foxtrot.'

-- Secondary Objectives
M3S1Text = '<LOC E02_M04_OBJ_020_411>Destroy the Aeon Factories'

-- Secondary Objectives
M3S1Detail = '<LOC E02_M04_OBJ_020_412>Bring Aeon production to a halt by destroying their factories.'



--------------------------------
-- Opnode ID: T01
-- Enemy taunts
--------------------------------



-- Taunt1
TAUNT1 = {
  {text = '<LOC E02_T01_010_010>[{i Min}]: Embrace The Way or be cleansed.', vid = 'E02_Min_T01_0084.sfd', bank = 'E02_VO', cue = 'E02_Min_T01_0084', faction = 'Aeon'},
}

-- Taunt2
TAUNT2 = {
  {text = '<LOC E02_T01_020_010>[{i Min}]: You are destroying the galaxy with your hatred.', vid = 'E02_Min_T01_0085.sfd', bank = 'E02_VO', cue = 'E02_Min_T01_0085', faction = 'Aeon'},
}

-- Taunt3
TAUNT3 = {
  {text = '<LOC E02_T01_030_010>[{i Min}]: You will answer for the crimes committed by the UEF.', vid = 'E02_Min_T01_0086.sfd', bank = 'E02_VO', cue = 'E02_Min_T01_0086', faction = 'Aeon'},
}

-- Taunt4
TAUNT4 = {
  {text = '<LOC E02_T01_040_010>[{i Min}]: We are the galaxy\'s salvation. Accept our teachings.', vid = 'E02_Min_T01_0087.sfd', bank = 'E02_VO', cue = 'E02_Min_T01_0087', faction = 'Aeon'},
}

-- Taunt5
TAUNT5 = {
  {text = '<LOC E02_T01_050_010>[{i Min}]: The Way must be spread to all of humanity!', vid = 'E02_Min_T01_0088.sfd', bank = 'E02_VO', cue = 'E02_Min_T01_0088', faction = 'Aeon'},
}

-- Taunt6
TAUNT6 = {
  {text = '<LOC E02_T01_060_010>[{i Min}]: I have no wish to kill you.', vid = 'E02_Min_T01_0089.sfd', bank = 'E02_VO', cue = 'E02_Min_T01_0089', faction = 'Aeon'},
}

-- Taunt7
TAUNT7 = {
  {text = '<LOC E02_T01_070_010>[{i Min}]: Embrace the Way and become a Knight of the Illuminate!', vid = 'E02_Min_T01_0090.sfd', bank = 'E02_VO', cue = 'E02_Min_T01_0090', faction = 'Aeon'},
}

-- Taunt8
TAUNT8 = {
  {text = '<LOC E02_T01_080_010>[{i Min}]: The Princess has foreseen my victory.', vid = 'E02_Min_T01_0091.sfd', bank = 'E02_VO', cue = 'E02_Min_T01_0091', faction = 'Aeon'},
}
