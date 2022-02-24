#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zm_prison;
#include maps/mp/zm_tomb;
#include maps/mp/zombies/_zm_audio;

main()
{
	// replaceFunc( maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options, ::GetPapWeaponReticle );

	replaceFunc( maps/mp/animscripts/zm_utility::wait_network_frame, ::FixNetworkFrame );

	replaceFunc( maps/mp/zombies/_zm_utility::wait_network_frame, ::FixNetworkFrame );
}

init()
{
	level thread OnPlayerConnect();
}

OnPlayerConnect()
{
	level waittill( "connecting", player );	
	player thread OnPlayerSpawned();

	setdvar( "player_strafeSpeedScale", 0.8 );
	setdvar( "player_backSpeedScale", 0.7 );
	setdvar( "sv_endGameIfISuck", 0 ); 			// Prevent host migration
	setdvar( "sv_allowAimAssist", 0 ); 			// Removes target assist
	setdvar( "sv_patch_zm_weapons", 0 ); 		// Depatch patched recoil
	
	level waittill( "initial_players_connected" );
	players = get_players();	

	if ( level.script == "zm_transit" && level.scr_zm_map_start_location != "transit" )	// Exclude depot from Green Run
	{
		if ( players.size == 1 ) // Change between ==1 and <5
		{
			// setdvar ( "r_fog", 0 ); 			// Remove fog
		}
	} 

	level thread PrintFix();

	if ( players.size < 5 )  // Change between ==1 and <5 | All characters have to be preset if using for coop
	{
		// level thread SetCharacters();
	}

	if ( players.size < 5 ) // Change between ==1 and <5
	{
		if ( level.script == "zm_nuked" )
		{
			// level thread EyeChange();

			if ( !level.enable_magic )
			{
				// level thread NukeMannequins();
			}
		}
	}
}

OnPlayerSpawned()
{
    level endon( "game_ended" );
	self endon( "disconnect" );

	self waittill( "spawned_player" );
	players = get_players();

	// Set 2nd argument to 1 if solo only, players.size for coop
	for ( i = 0; i < players.size; i++ ) 
	{
		// players[i] TimerHud();
	}
}

PrintFix()
{
	// foreach(player in level.players)
	// {
	// player iprintln( "^5FIRST ROOM FIX V4" )
	// }
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		player = level.players[ i ];
		player iprintln( "^5FIRST ROOM FIX V4" );
	}
}

FixNetworkFrame()
{
	if ( numremoteclients() )
	{
		snapshot_ids = getsnapshotindexarray();
		acked = undefined;
		while ( !isDefined( acked ) )
		{
			level waittill( "snapacknowledged" );
			acked = snapshotacknowledged( snapshot_ids );
		}
	}
	else
	{
		wait 0.1; // this was changed to wait 0.05 ...
	}
}

TimerHud()
{
	timer_hud = newClientHudElem(self);
	timer_hud.alignx = "right";
	timer_hud.aligny = "top";
	timer_hud.horzalign = "user_right";
	timer_hud.vertalign = "user_top";
	timer_hud.x -= 5; 				// += if alligned left, -= if right
	timer_hud.y += 2;
	timer_hud.fontscale = 1.4;
	timer_hud.alpha = 0;
	timer_hud.color = ( 1, 1, 1 );
	timer_hud.hidewheninmenu = 1;
	timer_hud.hidden = 0;
	timer_hud.label = &"";

	flag_wait( "initial_blackscreen_passed" );
	timer_hud.alpha = 1;

	timer_hud setTimerUp(0); 
}

NukeMannequins()
{
	flag_wait( "initial_blackscreen_passed" );
	wait 1;
    destructibles = getentarray( "destructible", "targetname" );
    foreach ( mannequin in destructibles )
    {
        if ( mannequin.origin == ( 1058.2, 387.3, -57 ) )
        {
            mannequin delete();
        }
        if ( mannequin.origin == ( 609.28, 315.9, -53.89 ) )
        {
            mannequin delete();
        }
        if ( mannequin.origin == ( 872.48, 461.88, -56.8 ) )
        {
            mannequin delete();
        }
        if ( mannequin.origin == ( 851.1, 156.6, -51 ) )
        {
            mannequin delete();
        }
        if ( mannequin.origin == ( 808, 140.5, -51 ) )
        {
            mannequin delete();
        }
        if ( mannequin.origin == ( 602.53, 281.09, -55 ) )
        {
            mannequin delete();
        }
    }
}

SetCharacters()
{
	players = get_players();
	if ( level.script == "zm_transit" || level.script == "zm_nuked" )
	{
		ciaviewmodel = "c_zom_suit_viewhands"; // Just Python talkin
		cdcviewmodel = "c_zom_hazmat_viewhands"; // Use this if you want CDC
		if ( level.script == "zm_nuked" )
		{
			cdcviewmodel = "c_zom_hazmat_viewhands_light";
		}
		
		// Set white player properties
		players[0] setmodel( "c_zom_player_cdc_fb" );
		players[0].voice = "american";
		players[0].skeleton = "base";
		players[0] setviewmodel( cdcviewmodel );
		players[0].characterindex = 0;

		if ( players.size > 1 )
		{
			// Set blue player properties
			players[1] setmodel( "c_zom_player_cia_fb" );
			players[1].voice = "american";
			players[1].skeleton = "base";
			players[1] setviewmodel( ciaviewmodel );
			players[1].characterindex = 1;

			if ( players.size > 2) 
			{
				// Set yellow player properties
				players[2] setmodel( "c_zom_player_cia_fb" );
				players[2].voice = "american";
				players[2].skeleton = "base";
				players[2] setviewmodel( ciaviewmodel );
				players[2].characterindex = 0;

				if ( players.size > 3 )
				{
					// Set green player properties
					players[3] setmodel( "c_zom_player_cdc_fb" );
					players[3].voice = "american";
					players[3].skeleton = "base";
					players[3] setviewmodel( cdcviewmodel );
					players[3].characterindex = 1;
				}
			}
		}	
	}

	if ( level.script == "zm_prison" ) 
	{
		// Set white player properties | override character/c_zom_arlington
		players[0] setmodel( "c_zom_player_arlington_fb" );
		players[0].voice = "american";
		players[0].skeleton = "base";
		players[0] setviewmodel( "c_zom_arlington_coat_viewhands" );
		level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
		players[0].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "ray_gun_zm";
		players[0] set_player_is_female( 0 );
		players[0].character_name = "Arlington";
		players[0].characterindex = 3;

		if ( players.size > 1 )
		{
			// Set blue player properties | override character/c_zom_deluca
			players[1] setmodel( "c_zom_player_deluca_fb" );
			players[1].voice = "american";
			players[1].skeleton = "base";
			players[1] setviewmodel( "c_zom_deluca_longsleeve_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			players[1].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "thompson_zm";
			players[1] set_player_is_female( 0 );
			players[1].character_name = "Sal";
			players[1].characterindex = 1;

			if ( players.size > 2) 
			{			
				// Set yellow player properties | override character/c_zom_handsome
				players[2] setmodel( "c_zom_player_handsome_fb" );
				players[2].voice = "american";
				players[2].skeleton = "base";
				players[2] setviewmodel( "c_zom_handsome_sleeveless_viewhands" );
				level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
				players[2].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "blundergat_zm";
				players[2] set_player_is_female( 0 );
				players[2].character_name = "Billy";
				players[2].characterindex = 2;

				if ( players.size > 3 )
				{
					// Set green player properties | override character/c_zom_oleary
					players[3] setmodel( "c_zom_player_oleary_fb" );
					players[3].voice = "american";
					players[3].skeleton = "base";
					players[3] setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
					level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
					players[3].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "judge_zm";
					players[3] set_player_is_female( 0 );
					players[3].character_name = "Finn";
					players[3].characterindex = 0;
				}
			}
		}
		
		// No reason to assign it for coop as it's already been assigned by original function, only need to handle that for solo
		if ( players.size == 1 && players[0].character_name == "Arlington" && level.script == "zm_prison" )
		{
			level.has_weasel = 1;
		}
	}
}

EyeChange()
{
	level setclientfield( "zombie_eye_change", 1 );
	sndswitchannouncervox( "richtofen" );
}

GetPapWeaponReticle ( weapon ) // Override to get rid of rng reticle
{
	if ( !isDefined( self.pack_a_punch_weapon_options ) )
	{
		self.pack_a_punch_weapon_options = [];
	}
	if ( !is_weapon_upgraded( weapon ) )
	{
		return self calcweaponoptions( 0, 0, 0, 0, 0 );
	}
	if ( isDefined( self.pack_a_punch_weapon_options[ weapon ] ) )
	{
		return self.pack_a_punch_weapon_options[ weapon ];
	}
	smiley_face_reticle_index = 1;
	base = get_base_name( weapon );
	camo_index = 39;
	if ( level.script == "zm_prison" )
	{
		camo_index = 40;
	}
	else if ( level.script == "zm_tomb" )
	{
		camo_index = 45;
	}
	lens_index = randomintrange( 0, 6 );
	reticle_index = randomintrange( 0, 16 );
	reticle_color_index = randomintrange( 0, 6 );
	plain_reticle_index = 16;
	// r = randomint( 10 );
	use_plain = true;  //r < 3;
	if ( base == "saritch_upgraded_zm" )
	{
		reticle_index = smiley_face_reticle_index;
	}
	else if ( use_plain )
	{
		reticle_index = plain_reticle_index;
	}
	scary_eyes_reticle_index = 8;
	purple_reticle_color_index = 3;
	if ( reticle_index == scary_eyes_reticle_index )
	{
		reticle_color_index = purple_reticle_color_index;
	}
	letter_a_reticle_index = 2;
	pink_reticle_color_index = 6;
	if ( reticle_index == letter_a_reticle_index )
	{
		reticle_color_index = pink_reticle_color_index;
	}
	letter_e_reticle_index = 7;
	green_reticle_color_index = 1;
	if ( reticle_index == letter_e_reticle_index )
	{
		reticle_color_index = green_reticle_color_index;
	}
	self.pack_a_punch_weapon_options[ weapon ] = self calcweaponoptions( camo_index, lens_index, reticle_index, reticle_color_index );
	return self.pack_a_punch_weapon_options[ weapon ];
}
