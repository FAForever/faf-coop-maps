-- Part 1 Dialogues

-- Explain whats going on. Why are we dropping on a beach filled with guns?
IntroP1 = {
    {text = '[Coalition HQ]: Commander, the Seraphim are dug in deep here. They have a research lab on this beach. We need to know what the Seraphim are up to.', vid = '', bank = '', cue = 'IntroP1_1', faction = 'UEF'},
    {text = '[Coalition HQ]: General Valerie is going to gate once this Order base is destroyed. She will provide backup for you Commander.', vid = '', bank = '', cue = 'IntroP1_2', faction = 'UEF'},
    {text = '[Coalition HQ]: This is going to be a hell of a fight commander, droping you into the thick of it. HQ out.', vid = '', bank = '', cue = 'IntroP1_3', faction = 'UEF'},
}

-- Hey at least we get some units.
Thalia1P1 = {
    {text = '[Crusader Thalia]: Commander I will be assisting you with taking this beach. I will provide you with reinforcements as I set my own base up a south of your LZ.', vid = 'Thalia.sfd', vidx = '', bank = '', cue = 'Thalia1P1', faction = 'Aeon'},
    {text = '[Crusader Thalia]: For now use these forces I will send more shortly. Thalia out.', vid = 'Thalia.sfd', vidx = '', bank = '', cue = 'Thalia1P2', faction = 'Aeon'},
}
-- oh never mind.
Thalia2P1 = {
    {text = '[Crusader Thalia]: HQ I am having some werid ACU errors, I am unable to upgrade or construct T3 units.', vid = 'Thalia.sfd', vidx = '', bank = '', cue = 'Thalia2P1', faction = 'Aeon'},
    {text = '[Coalition HQ]: We are reading some strange jamming waves. The Seraphim are somehow blocking T3 access. We got techs working on a work around, but it looks like you are on your own. HQ, out.', vid = '', vidx = '', bank = '', cue = 'Thalia2P2', faction = 'UEF'},
    {text = '[Crusader Thalia]: Commander I will soon be heavily pressed to defend my own position, I will send what reinforcements I can, but that will be all I can send you.', vid = 'Thalia.sfd', vidx = '', bank = '', cue = 'Thalia2P3', faction = 'Aeon'}, 
}
-- oh I see, they will bring "Order" I get it!
Reveal1P1 = {
    {text = '[Oum-Eoshi]: Soon we will wipe all of you out. Our might will destroy you.', vid = 'X04_Oum-Eoshi_M03_03767.sfd', vidx = '', bank = '', cue = 'Reveal1P1', faction = 'Seraphim'},
    {text = '[Executioner Keleana]: The Seraphim will bring order! You will fail to stop us!', vid = 'Celene.sfd', vidx = '', bank = '', cue = 'Reveal1P2', faction = 'Aeon'},
}

-- Oh great now I got help the drunk general survive.
EndP1 = {
    {text = '[Coalition HQ]: Area looks clear, General Valerie is gating in now.', vid = '', vidx = '', bank = '', cue = 'EndP1_1', faction = 'UEF'},
    {text = '[General Valerie]: Commander, I am setting up my position now, keep me covered. Valerie out.', vid = 'E06_Aiko_M01_0264.sfd', bank = '', cue = 'EndP1_2', faction = 'UEF'},
    {text = '[General Valerie]: It seems that the Jammer is not fully working on my ACU, I have limited acess to T3.', vid = 'E06_Aiko_M01_0264.sfd', bank = '', cue = 'EndP1_3', faction = 'UEF'},
}

-- Why did they not think to start that at the begining?
SelfP1 = {
    {text = '[Coalition HQ]: Commander the Seraphim are attempting to self-destruct the lab, capture it immediately!', vid = '', vidx = '', bank = '', cue = 'SelfP1', faction = 'UEF'},
}

End2P1 = {
    {text = '[Coalition HQ]: The lab is ours, make sure you defend it while the techs download all the data. HQ Oout.', vid = '', vidx = '', bank = '', cue = 'End2P1', faction = 'UEF'},
}

--Part 2 Dialogues

IntroP2 = {
    {text = '[Coalition HQ]: Commander, The techs are searching through the lab data. We need to hold that lab untill they are finished. HQ out.', vid = '', bank = '', cue = 'IntroP2_1', faction = 'UEF'},
    {text = '[General Valerie]: Commander I will continue to set up my position, I will try to defend the lab and attack enemy positions around us.', vid = 'E06_Aiko_M01_0264.sfd', bank = '', cue = 'IntroP2_2', faction = 'UEF'},
    {text = '[General Valerie]: I am picking up 4 enemy bases in the area, take a few out to reduce the enemy pressure. Valerie out.', vid = 'E06_Aiko_M01_0264.sfd', bank = '', cue = 'IntroP2_3', faction = 'UEF'},
}

MidP2 = {
    {text = '[Coalition HQ]: Commander... The techs found something terrible.. hold on.', vid = '', bank = '', cue = 'MidP2_1', faction = 'UEF'},
    {text = '[Coalition HQ]: The Seraphim have been working on a project code named \'Thisl-Eniz\' they are developing a way to open a new rift on this end.', vid = '', bank = '', cue = 'MidP2_2', faction = 'UEF'},
    {text = '[Coalition HQ]: The list... They needed ACU crystals, the Techs even found some of Brackman and their own research involved. This is what the Seraphim have been working towards.', vid = '', bank = '', cue = 'MidP2_3', faction = 'UEF'},
    {text = '[Coalition HQ]: The Techs are still working, keep that lab defended. HQ out.', vid = '', bank = '', cue = 'MidP2_4', faction = 'UEF'},
}

--Part 3 Dialogues

IntroP3 = {
    {text = '[Coalition HQ]: Commander, The enemy has a new type of "tech" jammer. The techs think they can bypass the jamming effect in a few months... we dont have that time.', vid = '', bank = '', cue = 'IntroP3_1', faction = 'UEF'},
    {text = '[Coalition HQ]: Take out the jammer and the enemy forces in the area. Then we can clean up the enemy positions with T3 units. HQ out.', vid = '', bank = '', cue = 'IntroP3_2', faction = 'UEF'},
    {text = '[General Valerie]: Commander I am detecting a Cybran base to the west. QAI is in play, take him out.', vid = 'E06_Aiko_M01_0264.sfd', bank = '', cue = 'IntroP3_3', faction = 'UEF'},
    {text = '[General Valerie]: I will defend the beach region and lab. I will assist as I can. Just keep me covered.', vid = 'E06_Aiko_M01_0264.sfd', bank = '', cue = 'IntroP3_4', faction = 'UEF'},
    {text = '[General Valerie]: If you can take out the Jammer I can start sending some harder T3 attacks and get some Fatboys out. Valerie out.', vid = 'E06_Aiko_M01_0264.sfd', bank = '', cue = 'IntroP3_5', faction = 'UEF'},
}

MidP3 = {
    {text = '[Coalition HQ]: Commander General Hall wishes to speak with you.', vid = '', bank = '', cue = 'MidP3_1', faction = 'UEF'},
    {text = '[General Hall]: Commander, We must hurry, The Seraphim are attempting to create a new Rift a few planets away from your position.', vid = '', bank = '', cue = 'MidP3_2', faction = 'UEF'},
    {text = '[General Hall]: I have tasked all available commanders to assault the Seraphim strongholds. We need your strike team as soon as possible.', vid = '', bank = '', cue = 'MidP3_3', faction = 'UEF'},
    {text = '[General Hall]: One last thing... Make that Seraphim bastard pay for killing Doysta. Hall out.', vid = '', bank = '', cue = 'MidP3_4', faction = 'UEF'},
}

Thalia1P3 = {
    {text = '[Crusader Thalia]: Commander I need your assistance. There is a Quantum Jammer somewhere in your operational area. It is preventing me from gating in my sister.', vid = 'Thalia.sfd', vidx = '', bank = '', cue = 'Jammer1P3', faction = 'Aeon'},
    {text = '[Crusader Thalia]: If you can find and destroy it, I will be able to send another wave of Reinforcements. The Tech jammer has not fully blocked my T3 so you would receive some stronger units.', vid = 'Thalia.sfd', vidx = '', bank = '', cue = 'Jammer2P3', faction = 'Aeon'},
    {text = '[Crusader Thalia]: This is just a request, if you are unable to spare the resources I understand. Thalia out.', vid = 'Thalia.sfd', vidx = '', bank = '', cue = 'Jammer3P3', faction = 'Aeon'},
}

Thalia2P3 = {
    {text = '[Crusader Thalia]: Commander my sister was able to gate in, Sending you reinforcements now.', vid = 'Thalia.sfd', vidx = '', bank = '', cue = 'Jammer1P3', faction = 'Aeon'},
}

TechJamDown = {
    {text = '[Coalition HQ]: The Jammer is down! Other commanders are reporting complete access to T3. HQ out.', vid = '', vidx = '', bank = '', cue = 'TechJamDown1', faction = 'UEF'},
    {text = '[General Valerie]: Commander, I am switching it stronger T3 attacks. I will start work on a Fatboy so we can clear the area faster. Valerie out.', vid = 'E06_Aiko_M01_0264.sfd', bank = '', cue = 'TechJamDown2', faction = 'UEF'},
}

--Part 4 Dialogues

IntroP4 = {
    {text = '[Coalition HQ]: Commander you need to take out both the Seraphim and the Order commanders. The Order commander has constructed two Paragons one for each of them.', vid = '', bank = '', cue = 'IntroP4_1', faction = 'UEF'},
    {text = '[Coalition HQ]: Expect several experimentals and heavy enemy attacks. You need to be quick commander, the Techs found what the seraphim are working on and it is not good.', vid = '', bank = '', cue = 'IntroP4_2', faction = 'UEF'},
    {text = '[General Valerie]: Commander I try to clear out any positions left you have not cleared already.', vid = 'E06_Aiko_M01_0264.sfd', bank = '', cue = 'IntroP4_3', faction = 'UEF'},
}

-- Win or lose and enemy deaths Dialogues

PlayerWin = {
    {text = '[Coalition HQ]: Good work Commander, Prepare to immediately gate to the Seraphim\'s last stronghold.', vid = '', bank = '', cue = 'IntroP3_1', faction = 'UEF'},
}

Death1 = {
    {text = '[QAI]: The Seraphim will prevail. Removing me has not changed the estimated outcome, you will fail.', vid = 'QAI.sfd', bank = '', cue = 'Death1_1', faction = 'Cybran'},
}

Death2 = {
    {text = '[Oum-Eoshi]: No! I can... not fail... here!', vid = 'X04_Oum-Eoshi_M03_03767.sfd', bank = '', cue = 'Death2_1', faction = 'Seraphim'},  
}

Death3 = {
    {text = '[Executioner Keleana]: My Lord!! help... me!', vid = 'Celene.sfd', bank = '', cue = 'Death3_1', faction = 'Aeon'},
}

Objectivefailed1 = {
    {text = '[Coalition HQ]: Commander the Lab has been destroyed! This mission is a failure.', vid = '', bank = '', cue = 'IntroP3_1', faction = 'UEF'},
}

Objectivefailed2 = {
    {text = '[General Valerie]: Getting... hit from... all sides!! Help... me!!!!.', vid = 'E06_Aiko_M01_0264.sfd', bank = '', cue = 'IntroP3_1', faction = 'UEF'},
}

--taunts

P1Taunt1 = {
    {text = '[Oum-Eoshi]: You will never break our defenses. Your cause is hopeless.', vid = 'X04_Oum-Eoshi_M03_03767.sfd', bank = '', cue = 'Death2_1', faction = 'Seraphim'},  
}

P1Taunt2 = {
    {text = '[Oum-Eoshi]: I have killed some of your most elite commanders. You are nothing.', vid = 'X04_Oum-Eoshi_M03_03767.sfd', bank = '', cue = 'Death2_1', faction = 'Seraphim'},  
}

P1Taunt3 = {
    {text = '[Oum-Eoshi]: How does it feel to not have your T3 units? I will make your death quick.', vid = 'X04_Oum-Eoshi_M03_03767.sfd', bank = '', cue = 'Death2_1', faction = 'Seraphim'},  
}

P1Taunt4 = {
    {text = '[Executioner Keleana]: The UEF and Cybran are heretics, they will be cleansed!', vid = 'Celene.sfd', bank = '', cue = 'Death3_1', faction = 'Aeon'},
}

P1Taunt5 = {
    {text = '[Executioner Keleana]: The Seraphim are the true gods of this galaxy!', vid = 'Celene.sfd', bank = '', cue = 'Death3_1', faction = 'Aeon'},
}

-- Taunts P2

P2Taunt1 = {
    {text = '[Oum-Eoshi]: You will never break my fortresses!', vid = 'X04_Oum-Eoshi_M03_03767.sfd', bank = '', cue = 'Death2_1', faction = 'Seraphim'},  
}

P2Taunt2 = {
    {text = '[Executioner Keleana]: Your kind killed my sister! I will wipe all of you out!', vid = 'Celene.sfd', bank = '', cue = 'Death3_1', faction = 'Aeon'},
}

P2Taunt3 = {
    {text = '[Executioner Keleana]: A am a Executioner of the Seraphim\'s will! You will fall before me!', vid = 'Celene.sfd', bank = '', cue = 'Death3_1', faction = 'Aeon'},
}

-- Taunts P3

P3Taunt1 = {
    {text = '[Oum-Eoshi]: I will crush you! I defeated the mighty Doysta! No human can best me!', vid = 'X04_Oum-Eoshi_M03_03767.sfd', bank = '', cue = 'Death2_1', faction = 'Seraphim'},  
}

P3Taunt2 = {
    {text = '[Executioner Keleana]: Soon the Seraphim promise to deliver the Order unto the Way! You will not stop them!', vid = 'Celene.sfd', bank = '', cue = 'Death3_1', faction = 'Aeon'},
}

P3Taunt3 = {
    {text = '[Executioner Keleana]: My devotion makes me stronger! Your unity makes you slopy!', vid = 'Celene.sfd', bank = '', cue = 'Death3_1', faction = 'Aeon'},
}

P3Taunt4 = {
    {text = '[QAI]: I have optimized my tactics to insure your defeat.', vid = 'QAI.sfd', bank = '', cue = 'Death1_1', faction = 'Cybran'},
}

P3Taunt5 = {
    {text = '[QAI]: Regardless of the outcome of this battle, the Coalition\'s chances of defeating the Seraphim are less than 1%.', vid = 'QAI.sfd', bank = '', cue = 'Death1_1', faction = 'Cybran'},
}

P3Taunt6 = {
    {text = '[QAI]: This is unexpected, I will have to recalculate your chances.', vid = 'QAI.sfd', bank = '', cue = 'Death1_1', faction = 'Cybran'},
}

-- Taunts P4

P4Taunt1 = {
    {text = '[Oum-Eoshi]: I have infinite resources, I will make bomb this planet like Earth!', vid = 'X04_Oum-Eoshi_M03_03767.sfd', bank = '', cue = 'Death2_1', faction = 'Seraphim'},  
}

P4Taunt2 = {
    {text = '[Oum-Eoshi]: Even without the Tech jammer I am still superior!', vid = 'X04_Oum-Eoshi_M03_03767.sfd', bank = '', cue = 'Death2_1', faction = 'Seraphim'},  
}

P4Taunt3 = {
    {text = '[Executioner Keleana]: The Seraphim will guide us to Salvation!', vid = 'Celene.sfd', bank = '', cue = 'Death3_1', faction = 'Aeon'},
}

P4Taunt4 = {
    {text = '[Executioner Keleana]: Once we finish you the Seraphim\'s plans will become reality!', vid = 'Celene.sfd', bank = '', cue = 'Death3_1', faction = 'Aeon'},
}

P4Taunt5 = {
    {text = '[Oum-Eoshi]: What! How dare you!', vid = 'X04_Oum-Eoshi_M03_03767.sfd', bank = '', cue = 'Death2_1', faction = 'Seraphim'},  
}

P4Taunt6 = {
    {text = '[Executioner Keleana]: Wait! My lord what should I do!', vid = 'Celene.sfd', bank = '', cue = 'Death3_1', faction = 'Aeon'},
}