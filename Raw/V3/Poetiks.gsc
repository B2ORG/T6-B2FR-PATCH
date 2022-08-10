#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_weapons;

main()
{
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

	setdvar( "player_strafeSpeedScale", 0.8 );
	setdvar( "player_backSpeedScale", 0.7 );
	setdvar( "sv_endGameIfISuck", 0 ); 				// Prevent host migration
	setdvar( "sv_allowAimAssist", 0 ); 				// Removes target assist
	setdvar( "sv_patch_zm_weapons", 0 ); 			// Depatch patched recoil

	level waittill( "initial_players_connected" );			
	player iPrintLn( "^5FIRST ROOM FIX V3" );

	if ( level.script == "zm_nuked" )
    {
		// level thread EyeChange();

		if ( !level.enable_magic )
		{
			// player iPrintLn( "^3NOT ENOUGH MANNEQUINS ..." );
        	// level thread NukeMannequins();
		}
    }

	if ( level.script == "zm_transit" && level.scr_zm_map_start_location != "transit" )
	{
		level thread NoFog();
	} 

}

OnPlayerSpawned()
{
    level endon( "game_ended" );
	self endon( "disconnect" );

	self waittill( "spawned_player" );
	self thread TimerHud();
	self thread SetHands();
}

NoFog()
{
	players = get_players();
	setdvar ( "r_fog", 0 ); 					// All lobby size
	if ( players.size == 1 )
		{
			// setdvar ( "r_fog", 0 ); 			// Selected lobby size
		}

}

TimerHud()
{
	timer_hud = newClientHudElem(self);
	timer_hud.alignx = "left";
	timer_hud.aligny = "top";
	timer_hud.horzalign = "user_left";
	timer_hud.vertalign = "user_top";
	timer_hud.x += 5; 							// += if alligned left, -= if right
	timer_hud.y += 2;
	timer_hud.fontscale = 1.4;
	timer_hud.alpha = 0;
	timer_hud.color = ( 1, 1, 1 );
	timer_hud.hidewheninmenu = 1;
	timer_hud.hidden = 0;
	timer_hud.label = &"";

	flag_wait( "initial_blackscreen_passed" );
	timer_hud.alpha = 1;

	timer_hud setTimerUp(1); 				// If timer is also for coop

	players = get_players();
	if ( players.size == 1 ) 
	{
		// timer_hud setTimerUp(0);
	}
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

SetHands() 
{
    self setviewmodel( "c_zom_suit_viewhands" );
	// self setviewmodel( "c_zom_hazmat_viewhands" );

    // self setviewmodel( "c_zom_farmgirl_viewhands" );
	//self setviewmodel( "c_zom_engineer_viewhands" );
	//self setviewmodel( "c_zom_reporter_viewhands" );
	//self setviewmodel( "c_zom_oldman_viewhands" );

    self setviewmodel( "c_zom_arlington_coat_viewhands" );
	//self setviewmodel( "c_zom_deluca_longsleeve_viewhands" );
	//self setviewmodel( "c_zom_handsome_sleeveless_viewhands" );
	//self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );

    //self setviewmodel( "c_zom_takeo_viewhands" ); 
	//self setviewmodel( "c_zom_dempsey_viewhands" ); 
	//self setviewmodel( "c_zom_nikolai_viewhands" ); 
	//self setviewmodel( "c_zom_richtofen_viewhands" ); 
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

