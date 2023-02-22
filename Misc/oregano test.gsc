#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;

main()
{
    level thread init_origins_safe();
}

init_origins_safe()
{
    flag_wait("initial_blackscreen_passed");

    level thread hud_enemy_zombie();
}

hud_enemy_zombie()
{
    level endon("end_game");

    enemy_hud = createserverfontstring("hudsmall" , 1.5);
	enemy_hud setpoint("TOPRIGHT", "TOPRIGHT", -8, 0);
	enemy_hud.color = (1, 1, 1);
	enemy_hud.hidewheninmenu = 1;
    enemy_hud setValue(0);
	enemy_hud.alpha = 1;

    while (true)
    {
        enemy_hud setValue(get_current_zombie_count());
        wait 0.05;
    }
}
