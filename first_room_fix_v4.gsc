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
#include maps/mp/zombies/_zm_net;

main()
{
	replaceFunc( maps/mp/animscripts/zm_utility::wait_network_frame, ::FixNetworkFrame );
	replaceFunc( maps/mp/zombies/_zm_utility::wait_network_frame, ::FixNetworkFrame );

	// replaceFunc( maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options, ::GetPapWeaponReticle );
}

init()
{
	level thread OnPlayerConnect();
}

OnPlayerConnect()
{
	level waittill( "connecting", player );	

	player thread OnPlayerSpawned();

	level thread SetDvars();			// Anticheat and initial dvars
	level thread OriginsFix();			// Blood & Doors set to custom games
	level waittill( "initial_players_connected" );
	
	if ( level.script == "zm_transit" && level.scr_zm_map_start_location != "transit" )							// Exclude depot from Green Run
	{
		if ( level.players.size < 2 )  	// Change between <2 and <5
		{
			// setdvar ( "r_fog", 0 ); 	// Remove fog
		}
	} 

	level thread PrintNetworkFrame();	// Prints current length of networkframe
	level thread PrintFix();			// Print First Room Fix msg

	if ( level.players.size < 2 )  		// Change between <2 and <5 | All characters have to be preset if using for coop
	{
		// level thread SetCharacters();
	}

	if ( level.players.size < 5 ) 		// Change between <2 and <5
	{
		if ( level.script == "zm_nuked" )
		{
			// level thread EyeChange();	// Eye color on Nuketown

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

	flag_wait( "initial_blackscreen_passed" );
	// 'hostonly' will define whether timer is for everyone or just host in the game. 'soloonly' will define if timer should be used in coop or not
	hostonly = false; 
	soloonly = false;
	foreach ( player in level.players )
	{
		if ( soloonly && level.players.size != 1 )
		{
			break;
		}

		// player TimerHud();

		if ( hostonly )
		{
			break;
		}
	}
}

PrintFix()
{
	foreach( player in level.players )	// Code from 5
	{
		player iprintln( "^5FIRST ROOM FIX V4" );
	}
}

FixNetworkFrame()
{

	wait 0.1; 							// IF statement caused fix to not work
}

PrintNetworkFrame()
{
	network_hud = newHudElem();
	network_hud.alignx = "center";
	network_hud.aligny = "top";
	network_hud.horzalign = "user_center";
	network_hud.vertalign = "user_top";
	network_hud.x += 0;
	network_hud.y += 2;
	network_hud.fontscale = 1.4;
	network_hud.alpha = 0;
	network_hud.color = ( 1, 1, 1 );
	network_hud.hidewheninmenu = 1;
	network_hud.label = &"Network frame check: ";

	flag_wait( "initial_blackscreen_passed" );

	start_time = int( getTime() );
	wait_network_frame();
	end_time = int( getTime() );
	network_frame_len = float((end_time - start_time) / 1000);
	
	network_hud.alpha = 1;
	network_hud setValue( network_frame_len );

	wait 3;
	network_hud.alpha = 0;
}

SetDvars() 
{
	// avoid mid game changes to ruleset and msg related dvars
	i = 1;
	cheats = 0;
	cool_message = "Alright there fuckaroo, quit this cheated sheit and touch grass loser. Zi0 & Txch";
	random_float = randomFloatRange( 2.0, 4.0 );

	for( ; ; ) 
	{
		// check if any of the 
		if ( i != 1 ) 
		{
			if ( getDvar( "player_strafeSpeedScale" ) != "0.8" || getDvar( "player_backSpeedScale" ) != "0.7" ) 
			{
				// our cheat warning signature xD 
				if (cheats == 0) 
				{
					level thread CreateWarningHud( cool_message, 0 );
				}
				level thread CreateWarningHud( "Movement Speed Modification Attempted.", 30 );
				
				cheats = 1;
			}
			if ( getDvar( "con_gameMsgWindow0LineCount" ) != "4" || getDvar( "con_gameMsgWindow0MsgTime" ) != "5"
			|| getDvar( "con_gameMsgWindow0FadeInTime" ) != "0.25" || getDvar( "con_gameMsgWindow0FadeOutTime" ) != "0.5"
			|| getDvar( "con_gameMsgWindow0Filter" ) != "gamenotify obituary" ) 
			{
				// our cheat warning signature xD 
				if (cheats == 0) 
				{
					level thread CreateWarningHud( cool_message, 0 );
				}
				level thread CreateWarningHud( "No Print Attempted.", 50 );

				cheats = 1;
			} 
			if ( getDvar( "sv_patch_zm_weapons" ) != "0" || getDvar( "sv_cheats" ) != "0" ) 
			{
				// our cheat warning signature xD 
				if (cheats == 0) 
				{
					level thread CreateWarningHud( cool_message, 0 );
				}
				level thread CreateWarningHud( "sv_cheats Attempted.", 70 );

				cheats = 1;
			}
		}

		// you can add any possibly exploited dvars to this loop
		setdvar( "player_strafeSpeedScale", 0.8 );
		setdvar( "player_backSpeedScale", 0.7 );
		
		setdvar( "con_gameMsgWindow0Filter", "gamenotify obituary" );
		setdvar( "con_gameMsgWindow0LineCount", 4 );
		setdvar( "con_gameMsgWindow0MsgTime", 5 );
		setdvar( "con_gameMsgWindow0FadeInTime", 0.25 );
		setdvar( "con_gameMsgWindow0FadeOutTime", 0.5 );
				 
		setdvar( "sv_endGameIfISuck", 0 ); 		// Prevent host migration
		setdvar( "sv_allowAimAssist", 0 ); 	 	// Removes target assist
		setdvar( "sv_patch_zm_weapons", 0 );	// Depatch patched recoil
		setdvar( "sv_cheats", 0 );

		i = 0;

		wait random_float;
	}
}

CreateWarningHud( text, offset ) 
{
	warnHud = newHudElem();
	warnHud.fontscale = 1.5;
	warnHud.alignx = "left";
	warnHud.x -= 20;
	warnHud.y += offset;
	warnHud.color = ( 0, 0, 0 );
	warnHud.hidewheninmenu = 0;

	if (offset != 0 ) 
	{
		warnHud.label = &"^1Cheat Warning: ";
	}
	else 
	{
		warnHud.label = &"^5";
	}

	warnHud setText( text );
	
	warnHud showElem();
}

TimerHud()
{
	timer_hud = newClientHudElem(self);
	timer_hud.alignx = "left";					// Change only this for right
	timer_hud.aligny = "top";
	timer_hud.horzalign = "user_left";			// Changes automatically
	timer_hud.vertalign = "user_top";
	timer_hud.x += 7; 							// Changes automatically
	timer_hud.y += 2;							// Changes automatically
	timer_hud.fontscale = 1.4;
	timer_hud.alpha = 1;
	timer_hud.color = ( 1, 1, 1 );
	timer_hud.hidewheninmenu = 1;
	if ( timer_hud.alignx == "right" )
	{
		timer_hud.horzalign = "user_right";
		timer_hud.x -= 7; 
		timer_hud.y += 12;
	} 

	self thread RoundTimerHud(timer_hud);

	timer_hud setTimerUp(0); 
}

RoundTimerHud(hud)
{
	round_timer_hud = newClientHudElem(self);
	round_timer_hud.alignx = hud.alignx;
	round_timer_hud.aligny = hud.aligny;
	round_timer_hud.horzalign = hud.horzalign;
	round_timer_hud.vertalign = hud.vertalign;
	round_timer_hud.x -= ( 10 + hud.x ); 				
	round_timer_hud.y += ( 20 + hud.y );
	round_timer_hud.fontscale = 1.4;
	round_timer_hud.alpha = 0;	// Don't actually want it to display
	round_timer_hud.color = ( 1, 1, 1 );
	round_timer_hud.hidewheninmenu = 1;
	round_timer_hud.label = &"";

	// flag_wait( "initial_blackscreen_passed" );
	level.FADE_TIME = 0.2;

	while ( 1 )
	{
		round_timer_hud setTimerUp(0);
		start_time = int( getTime() / 1000 );

		level waittill( "end_of_round" );

		end_time = int( getTime() / 1000 );
		time = end_time - start_time;

		if ( level.round_number > 10 )
		{
			self DisplayRoundTime(time, round_timer_hud);
		}

		level waittill( "start_of_round" );
	}
}

DisplayRoundTime(time, hud)
{
	timer_for_hud = time - 0.05;

	// Since actual round timer is hidden it's prob not needed but imma leave it here regardless
	hud FadeOverTime(level.FADE_TIME);
	hud.alpha = 0;
	wait level.FADE_TIME * 2;

	hud.label = &"Round Time: ";
	hud FadeOverTime(level.FADE_TIME);
	hud.alpha = 1;

	for ( i = 0; i < 20; i++ ) // wait 5s
	{
		hud setTimer(timer_for_hud);
		wait 0.25;
	}

	hud FadeOverTime(level.FADE_TIME);
	hud.alpha = 0;

	wait level.FADE_TIME * 2;
	hud.label = &"";
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
	enablesurvival = true;		// Enable to preset characters for survival
	enablegreenrun = true;		// Enable to preset characters for greenrun
	enablemob = true;			// Enable to preset characters for mob
	enableorigins = true;		// Enable to preset characters for oregano

	if ( is_classic() == 0 )	// Can't be in the same if statement cause it fucks with the else
	{
		if ( enablesurvival )
		{
			ciaviewmodel = "c_zom_suit_viewhands"; // Preset as well so it's easier to find later
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
			players[0].characterindex = 1;

			if ( level.players.size > 1 )
			{
				// Set blue player properties
				players[1] setmodel( "c_zom_player_cia_fb" );
				players[1].voice = "american";
				players[1].skeleton = "base";
				players[1] setviewmodel( ciaviewmodel );
				players[1].characterindex = 0;

				if ( level.players.size > 2) 
				{
					// Set yellow player properties
					players[2] setmodel( "c_zom_player_cia_fb" );
					players[2].voice = "american";
					players[2].skeleton = "base";
					players[2] setviewmodel( ciaviewmodel );
					players[2].characterindex = 0;

					if ( level.players.size > 3 )
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
	}

	else	// Else simplifies if statement for Tranzit
	{
		if ( level.script == "zm_prison" && enablemob ) 
		{
			// Set white player properties
			players[0] setmodel( "c_zom_player_arlington_fb" );
			players[0].voice = "american";
			players[0].skeleton = "base";
			players[0] setviewmodel( "c_zom_arlington_coat_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			players[0].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "ray_gun_zm";
			players[0] set_player_is_female( 0 );
			players[0].character_name = "Arlington";
			players[0].characterindex = 3;

			if ( level.players.size > 1 )
			{
				// Set blue player properties
				players[1] setmodel( "c_zom_player_deluca_fb" );
				players[1].voice = "american";
				players[1].skeleton = "base";
				players[1] setviewmodel( "c_zom_deluca_longsleeve_viewhands" );
				level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
				players[1].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "thompson_zm";
				players[1] set_player_is_female( 0 );
				players[1].character_name = "Sal";
				players[1].characterindex = 1;

				if ( level.layers.size > 2) 
				{			
					// Set yellow player properties
					players[2] setmodel( "c_zom_player_handsome_fb" );
					players[2].voice = "american";
					players[2].skeleton = "base";
					players[2] setviewmodel( "c_zom_handsome_sleeveless_viewhands" );
					level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
					players[2].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "blundergat_zm";
					players[2] set_player_is_female( 0 );
					players[2].character_name = "Billy";
					players[2].characterindex = 2;

					if ( level.players.size > 3 )
					{
						// Set green player properties
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
			if ( level.players.size == 1 && players[0].character_name == "Arlington" && level.script == "zm_prison" )
			{
				level.has_weasel = 1;
			}
		}

		if ( enablegreenrun )
		{
			if ( level.script == "zm_transit" || level.script == "zm_highrise" || level.script == "zm_buried" )
			{
				// Set white player properties
				players[0] setmodel( "c_zom_player_farmgirl_fb" );
				players[0].voice = "american";
				players[0].skeleton = "base";
				players[0] setviewmodel( "c_zom_farmgirl_viewhands" );
				level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
				players[0].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "rottweil72_zm";
				players[0].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "870mcs_zm";
				players[0] set_player_is_female( 1 );
				players[0].characterindex = 2;
				if ( level.script == "zm_highrise")
				{
					players[0] setmodel( "c_zom_player_farmgirl_dlc1_fb" );
					players[0].whos_who_shader = "c_zom_player_farmgirl_dlc1_fb";
				}

				if ( level.players.size > 1 )
				{
					// Set blue player properties
					players[1] setmodel( "c_zom_player_oldman_fb" );
					players[1].voice = "american";
					players[1].skeleton = "base";
					players[1] setviewmodel( "c_zom_oldman_viewhands" );
					level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
					players[1].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "frag_grenade_zm";
					players[1].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "claymore_zm";
					players[1] set_player_is_female( 0 );
					players[1].characterindex = 0;
					if ( level.script == "zm_highrise")
					{
						players[1] setmodel( "c_zom_player_oldman_dlc1_fb" );
						players[1].whos_who_shader = "c_zom_player_oldman_dlc1_fb";
					}

					if ( level.players.size > 2) 
					{			
						// Set yellow player properties
						players[2] setmodel( "c_zom_player_engineer_fb" );
						players[2].voice = "american";
						players[2].skeleton = "base";
						players[2] setviewmodel( "c_zom_engineer_viewhands" );
						level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
						players[2].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "m14_zm";
						players[2].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "m16_zm";
						players[2] set_player_is_female( 0 );
						players[2].characterindex = 3;
						if ( level.script == "zm_highrise")
						{
							players[2] setmodel( "c_zom_player_engineer_dlc1_fb" );
							players[2].whos_who_shader = "c_zom_player_engineer_dlc1_fb";
						}

						if ( level.players.size > 3 )
						{
							// Set green player properties
							players[3] setmodel( "c_zom_player_reporter_fb" );
							players[3].voice = "american";
							players[3].skeleton = "base";
							players[3] setviewmodel( "c_zom_reporter_viewhands" );
							level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
							players[3].favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "beretta93r_zm";
							players[3].talks_in_danger = 1;
							level.rich_sq_player = self;
							players[3] set_player_is_female( 0 );
							players[3].characterindex = 1;
							if ( level.script == "zm_highrise")
							{
								players[2] setmodel( "c_zom_player_reporter_dlc1_fb" );
								players[2].whos_who_shader = "c_zom_player_reporter_dlc1_fb";
							}
						}
					}
				}
			}
		}
		

		if ( level.script == "zm_tomb" && enableorigins )
		{
			// Set white player properties
			players[0] setmodel( "c_zom_tomb_takeo_fb" );
			players[0].voice = "american";
			players[0].skeleton = "base";
			players[0] setviewmodel( "c_zom_takeo_viewhands" );
			level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
			players[0] set_player_is_female( 0 );
			players[0].character_name = "Takeo";
			players[0].characterindex = 3;

			if ( level.players.size > 1 )
			{
				// Set blue player properties
				players[1] setmodel( "c_zom_tomb_dempsey_fb" );
				players[1].voice = "american";
				players[1].skeleton = "base";
				players[1] setviewmodel( "c_zom_dempsey_viewhands" );
				level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
				players[1] set_player_is_female( 0 );
				players[1].character_name = "Dempsey";
				players[1].characterindex = 0;

				if ( level.players.size > 2) 
				{			
					// Set yellow player properties
					players[2] setmodel( "c_zom_tomb_richtofen_fb" );
					players[2].voice = "american";
					players[2].skeleton = "base";
					players[2] setviewmodel( "c_zom_richtofen_viewhands" );
					level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
					players[2] set_player_is_female( 0 );
					players[2].character_name = "Richtofen";
					players[2].characterindex = 2;

					if ( level.players.size > 3 )
					{
						// Set green player properties
						players[3] setmodel( "c_zom_tomb_nikolai_fb" );
						players[3].voice = "russian";
						players[3].skeleton = "base";
						players[3] setviewmodel( "c_zom_nikolai_viewhands" );
						level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
						players[3] set_player_is_female( 0 );
						players[3].character_name = "Nikolai";
						players[3].characterindex = 1;
					}
				}
			}
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

OriginsFix()
{
	flag_wait( "start_zombie_round_logic" );
	wait 0.5;
	if ( level.script == "zm_tomb")
	{
		level.is_forever_solo_game = 0;
	}
}