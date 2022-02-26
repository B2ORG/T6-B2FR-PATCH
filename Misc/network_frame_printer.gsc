#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zm_prison;
#include maps/mp/zm_tomb;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_audio;

init()
{
	level thread OnPlayerConnect();
}

OnPlayerConnect()
{
	level waittill( "connecting", player );	
	player thread OnPlayerSpawned();

	level waittill( "initial_players_connected" );
	
	level thread PrintFix();			
}

OnPlayerSpawned()
{
    level endon( "game_ended" );
	self endon( "disconnect" );

	self waittill( "spawned_player" );

	flag_wait( "initial_blackscreen_passed" );
	level thread PrintNetworkFrame();
	level thread PrintSpawn();
}

PrintFix()
{
	foreach( player in level.players )
	{
		player iprintln( "PRINT NETWORK FRAME" );
	}
}

PrintSpawn()
{
	spawn_hud = newhudelem( self );
	spawn_hud.alignx = "left";
	spawn_hud.aligny = "top";
	spawn_hud.horzalign = "user_left";
	spawn_hud.vertalign = "user_top";
	spawn_hud.x += 4;
	spawn_hud.y += 30;
	spawn_hud.fontscale = 1.4;
	spawn_hud.color = ( 1, 1, 1 );
	spawn_hud.hidewheninmenu = 1;
	spawn_hud.label = &"Spawn rate: ";

    spawn_hud setValue( -1 );
    spawn_hud.alpha = 0.9;
		
	level waittill ( "start_of_round" );
	while ( 1 )
	{
		while ( get_current_zombie_count() < 3)
		{
			if ( get_current_zombie_count() == 1 )
			{
				start_time = int( getTime() );
			}

			if ( get_current_zombie_count() == 2 )
			{
				end_time = int( getTime() );
			}
			wait 0.05;
		}

		get_difference = ( end_time - start_time );
		convert_secs = ( get_difference / 1000 );
		spawn_hud setValue( convert_secs );
		level waittill ( "start_of_round" );
		wait 0.1;
	}
}

PrintNetworkFrame()
{
	network_hud = newhudelem( self );
	network_hud.alignx = "left";
	network_hud.aligny = "top";
	network_hud.horzalign = "user_left";
	network_hud.vertalign = "user_top";
	network_hud.x += 5;
	network_hud.y += 10;
	network_hud.fontscale = 1.4;
	network_hud.alpha = 0;
	network_hud.color = ( 1, 1, 1 );
	network_hud.hidewheninmenu = 1;
	network_hud.label = &"Network frame: ";

	start_time = int(getTime());
	wait_network_frame();
	end_time = int(getTime());

	network_frame_len = float((end_time - start_time) / 1000);
	network_hud.alpha = 0.9;
	network_hud setValue( network_frame_len );
}