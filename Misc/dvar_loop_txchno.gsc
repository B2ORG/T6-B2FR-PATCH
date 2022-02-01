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
	player thread onplayerspawned();
	level thread setDvars();

	level waittill( "initial_players_connected" );
	player iprintln( "^5FIRST ROOM FIX V3" );
}

onplayerspawned()
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	self waittill( "spawned_player" );
	self thread timerhud();
	// level thread nofog();
	// level thread nukemannequins();
	// self thread sethands();
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
		
		setdvar("con_gameMsgWindow1FadeInTime", 0.25);
		setdvar("con_gameMsgWindow1FadeOutTime", 0.01);
		setdvar("con_gameMsgWindow1Filter", "boldgame");
		setdvar("con_gameMsgWindow1LineCount", 1);
		setdvar("con_gameMsgWindow1MsgTime", 3);
		
		setdvar("con_gameMsgWindow2FadeInTime", 0.75);
		setdvar("con_gameMsgWindow2FadeOutTime", 0.5);
		setdvar("con_gameMsgWindow2Filter", "subtitle");
		setdvar("con_gameMsgWindow2LineCount", 7);
		setdvar("con_gameMsgWindow2MsgTime", 5);
		
		setdvar("con_gameMsgWindow3FadeInTime", 0.25);
		setdvar("con_gameMsgWindow3FadeOutTime", 0.5);
		setdvar("con_gameMsgWindow3Filter", "objnotify");
		setdvar("con_gameMsgWindow3LineCount", 1);
		setdvar("con_gameMsgWindow3MsgTime", 0); // means player 4
		
		setdvar( "sv_endGameIfISuck", 0 );
		setdvar( "sv_allowAimAssist", 0 );
		setdvar("sv_cheats", 0);

		wait(2);
	}
}

nofog()
{
	players = get_players();
	if( players.size == 1 )
	{
		setdvar( "r_fog", 0 );
	}

}

timerhud()
{
	timer_hud = newclienthudelem( self );
	timer_hud.alignx = "left";
	timer_hud.aligny = "top";
	timer_hud.horzalign = "user_left";
	timer_hud.vertalign = "user_top";
	timer_hud.x = timer_hud.x + 5;
	timer_hud.y = timer_hud.y + 2;
	timer_hud.fontscale = 1.4;
	timer_hud.alpha = 0;
	timer_hud.color = ( 1, 1, 1 );
	timer_hud.hidewheninmenu = 1;
	timer_hud.hidden = 0;
	timer_hud.label = &"";
	flag_wait( "initial_blackscreen_passed" );
	timer_hud.alpha = 1;
	players = get_players();
	if( players.size == 1 )
	{
		timer_hud settimerup( 0 );
	}

}

nukemannequins()
{
	flag_wait( "initial_blackscreen_passed" );
	wait 1;
	destructibles = getentarray( "destructible", "targetname" );
	foreach( mannequin in destructibles )
	{
		if( mannequin.origin == ( 1058.2, 387.3, -57 ) )
		{
			mannequin delete();
		}
		if( mannequin.origin == ( 609.28, 315.9, -53.89 ) )
		{
			mannequin delete();
		}
		if( mannequin.origin == ( 872.48, 461.88, -56.8 ) )
		{
			mannequin delete();
		}
		if( mannequin.origin == ( 851.1, 156.6, -51 ) )
		{
			mannequin delete();
		}
		if( mannequin.origin == ( 808, 140.5, -51 ) )
		{
			mannequin delete();
		}
		if( mannequin.origin == ( 602.53, 281.09, -55 ) )
		{
			mannequin delete();
		}
	}

}

sethands()
{
	self setviewmodel( "c_zom_suit_viewhands" );
	self setviewmodel( "c_zom_farmgirl_viewhands" );
	self setviewmodel( "c_zom_arlington_coat_viewhands" );

}

