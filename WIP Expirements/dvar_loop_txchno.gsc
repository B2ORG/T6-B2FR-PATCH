//Decompiled with SeriousHD-'s GSC Decompiler
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_weapons;
init()
{
	level thread onplayerconnect();
}

onplayerconnect()
{
	level waittill( "connecting", player );
	level thread setDvars();

	level waittill( "initial_players_connected" );
	player iprintln( "^5FIRST ROOM FIX V3" );
}


setDvars() {
	// avoid mid game changes to ruleset and msg related dvars
	i = 1;

	for(;;) 
	{
		// check if any of the 
		if (i != 1) {
			if (getDvar("player_strafeSpeedScale") != "0.8" || getDvar("player_backSpeedScale") != "0.7") {
				level thread createWarningHud("Movement Speed Modification Attempted.", 0);
			}
			if(getDvar("con_gameMsgWindow0LineCount") != "4" || getDvar("con_gameMsgWindow0MsgTime") != "5"
			|| getDvar("con_gameMsgWindow0FadeInTime") != "0.25" || getDvar("con_gameMsgWindow0FadeOutTime") != "0.5"
			|| getDvar("con_gameMsgWindow0Filter") != "gamenotify obituary") {
				level thread createWarningHud("No Print Attempted.", 20);
			} 
			if(getDvar("sv_endGameIfISuck") != "0" || getDvar("sv_allowAimAssist") != "0" || getDvar("sv_cheats") != "0") {
				level thread createWarningHud("sv_cheats Attempted.", 40);
			}
		}

		// you can add any possibly exploited dvars to this loop
		setdvar( "player_strafeSpeedScale", 0.8 );
		setdvar( "player_backSpeedScale", 0.7);
		
		setdvar("con_gameMsgWindow0Filter", "gamenotify obituary");
		setdvar("con_gameMsgWindow0LineCount", 4);
		setdvar("con_gameMsgWindow0MsgTime", 5);
		setdvar("con_gameMsgWindow0FadeInTime", 0.25);
		setdvar("con_gameMsgWindow0FadeOutTime", 0.5);
				
		setdvar("sv_endGameIfISuck", 0);
		setdvar("sv_allowAimAssist", 0);
		setdvar("sv_cheats", 0);

		i = 0;

		wait(2);
	}
}

createWarningHud(text, offset) {
	warnHud = newHudElem();
	warnHud.fontscale = 1.5;
	warnHud.alignx = "left";
	warnHud.x -= 20;
	warnHud.y += offset;
	warnHud.color = ( 0, 0, 0);
	warnHud.hidewheninmenu = 0;
	warnHud.label = &"^1Cheat Warning: ";
	warnHud setText(text);
	
	warnHud showElem();
}
