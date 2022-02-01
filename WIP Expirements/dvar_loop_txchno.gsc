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
	for(;;) 
	{
		// you can add any possibly exploited dvars to this loop
		setdvar( "player_strafeSpeedScale", 0.8 );
		setdvar( "player_backSpeedScale", 0.7 );
		
		setdvar("con_gameMsgWindow0Filter", "gamenotify obituary");
		setdvar("con_gameMsgWindow0LineCount", 4);
		setdvar("con_gameMsgWindow0MsgTime", 5);
		setdvar("con_gameMsgWindow0FadeInTime", 0.25);
		setdvar("con_gameMsgWindow0FadeOutTime", 0.5);
				
		setdvar( "sv_endGameIfISuck", 0 );
		setdvar( "sv_allowAimAssist", 0 );
		setdvar("sv_cheats", 0);

		wait(2);
	}
}
