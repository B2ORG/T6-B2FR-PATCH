#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_weapons;

init()
{
	level thread OnPlayerConnect();
	
	setdvar( "player_strafeSpeedScale", 0.8 );
	setdvar( "player_backSpeedScale", 0.7 );
}

OnPlayerConnect()
{
	level waittill( "connecting", player);	
	player thread OnPlayerSpawned();

	level waittill( "initial_players_connected" );
	player iPrintLn( "^5FIRST ROOM FIX V2" );
}

OnPlayerSpawned()
{
    level endon( "game_ended" );
	self endon( "disconnect" );

	self waittill( "spawned_player" );
	self thread timer_hud();
}

timer_hud()
{
    self endon( "disconnect" );

	timer_hud = newClientHudElem(self);
	timer_hud.alignx = "right";
	timer_hud.aligny = "top";
	timer_hud.horzalign = "user_right";
	timer_hud.vertalign = "user_top";
	timer_hud.x -= 5;
	timer_hud.y += 2;
	timer_hud.fontscale = 1.4;
	timer_hud.alpha = 0;
	timer_hud.color = ( 1, 1, 1 );
	timer_hud.hidewheninmenu = 1;
	timer_hud.hidden = 0;
	timer_hud.label = &"";

	flag_wait( "initial_blackscreen_passed" );
	timer_hud.alpha = 1;

	players = get_players();
	if (players.size == 1) 
	{
		timer_hud setTimerUp(0);
	}
}