// Character properties for replacing witin the function, with already switched erroring main() function to actual properties

// Green Run
// Tranzit
switch( self.characterindex )
{
    case 2:
        self setmodel( "c_zom_player_farmgirl_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_farmgirl_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "rottweil72_zm";
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "870mcs_zm";
        self set_player_is_female( 1 );
        break;
    case 0:
        self setmodel( "c_zom_player_oldman_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_oldman_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "frag_grenade_zm";
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "claymore_zm";
        self set_player_is_female( 0 );
        break;
    case 3:
        self setmodel( "c_zom_player_engineer_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_engineer_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "m14_zm";
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "m16_zm";
        self set_player_is_female( 0 );
        break;
    case 1:
        self setmodel( "c_zom_player_reporter_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_reporter_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.talks_in_danger = 1;
        level.rich_sq_player = self;
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "beretta93r_zm";
        self set_player_is_female( 0 );
        break;
}

// Die Rise
switch( self.characterindex )
{
    case 2:
        self setmodel( "c_zom_player_farmgirl_dlc1_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_farmgirl_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "rottweil72_zm";
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "870mcs_zm";
        self set_player_is_female( 1 );
        self.whos_who_shader = "c_zom_player_farmgirl_dlc1_fb";
        break;
    case 0:
        self setmodel( "c_zom_player_oldman_dlc1_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_oldman_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "frag_grenade_zm";
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "claymore_zm";
        self set_player_is_female( 0 );
        self.whos_who_shader = "c_zom_player_oldman_dlc1_fb";
        break;
    case 3:
        self setmodel( "c_zom_player_engineer_dlc1_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_engineer_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "m14_zm";
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "m16_zm";
        self set_player_is_female( 0 );
        self.whos_who_shader = "c_zom_player_engineer_dlc1_fb";
        break;
    case 1:
        self setmodel( "c_zom_player_reporter_dlc1_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_reporter_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.talks_in_danger = 1;
        level.rich_sq_player = self;
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "beretta93r_zm";
        self set_player_is_female( 0 );
        self.whos_who_shader = "c_zom_player_reporter_dlc1_fb";
        break;
}

// Buried
switch( self.characterindex )
{
    case 2:
        self setmodel( "c_zom_player_farmgirl_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_farmgirl_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "rottweil72_zm";
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "870mcs_zm";
        self set_player_is_female( 1 );
        break;
    case 0:
        self setmodel( "c_zom_player_oldman_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_oldman_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "frag_grenade_zm";
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "claymore_zm";
        self set_player_is_female( 0 );
        break;
    case 3:
        self setmodel( "c_zom_player_engineer_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_engineer_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "m14_zm";
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "m16_zm";
        self set_player_is_female( 0 );
        break;
    case 1:
        self setmodel( "c_zom_player_reporter_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_reporter_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.talks_in_danger = 1;
        level.rich_sq_player = self;
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "beretta93r_zm";
        self set_player_is_female( 0 );
        break;
}

// Mob of the Dead
switch( self.characterindex )
{
    case 0:
        self setmodel( "c_zom_player_oleary_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_oleary_shortsleeve_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "judge_zm";
        self set_player_is_female( 0 );
        self.character_name = "Finn";
        break;
    case 1:
        self setmodel( "c_zom_player_deluca_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_deluca_longsleeve_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "thompson_zm";
        self set_player_is_female( 0 );
        self.character_name = "Sal";
        break;
    case 2:
        self setmodel( "c_zom_player_handsome_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_handsome_sleeveless_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "blundergat_zm";
        self set_player_is_female( 0 );
        self.character_name = "Billy";
        break;
    case 3:
        self setmodel( "c_zom_player_arlington_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_arlington_coat_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self.favorite_wall_weapons_list[ self.favorite_wall_weapons_list.size ] = "ray_gun_zm";
        self set_player_is_female( 0 );
        self.character_name = "Arlington";
        break;
}

// Origins
switch( self.characterindex )
{
    case 0:
        self setmodel( "c_zom_tomb_dempsey_fb" );
        self.voice = "american";
        self.skeleton = "base";
        self setviewmodel( "c_zom_dempsey_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self set_player_is_female( 0 );
        self.character_name = "Dempsey";
        break;
    case 1:
        self setmodel( "c_zom_tomb_nikolai_fb" );
        self.voice = "russian";
        self.skeleton = "base";
        self setviewmodel( "c_zom_nikolai_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self set_player_is_female( 0 );
        self.character_name = "Nikolai";
        break;
    case 2:
        self setmodel( "c_zom_tomb_richtofen_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_richtofen_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self set_player_is_female( 0 );
        self.character_name = "Richtofen";
        break;
    case 3:
        self setmodel( "c_zom_tomb_takeo_fb" );
	    self.voice = "american";
	    self.skeleton = "base";
        self setviewmodel( "c_zom_takeo_viewhands" );
        level.vox maps/mp/zombies/_zm_audio::zmbvoxinitspeaker( "player", "vox_plr_", self );
        self set_player_is_female( 0 );
        self.character_name = "Takeo";
        break;
}