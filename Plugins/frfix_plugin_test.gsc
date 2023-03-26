#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_stats;

main()
{
    level thread safe_init();
}

safe_init()
{
    level waittill("frfix_init");
    level.FRFIX_PLUGIN_TEST = ::permaperks_testing;
}

permaperks_testing()
{
    level endon("end_game");

	if (!maps\mp\zombies\_zm_pers_upgrades::is_pers_system_active())
		return;

    if ((level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zclassic") || (level.script == "zm_highrise") || (level.script == "zm_buried"))
    {
        while (!isDefined(level.players[0].pers_upgrades_awarded))
            wait 0.05;
    }
    else
    {
        return;
    }

    perk_states = array();
    while (true)
    {
        foreach(player in level.players)
            perk_states = player get_perk_states(perk_states);

        wait 0.1;
    }
}

get_perk_states(old_perkstates)
{
    perkstate = array();

    foreach (perk in level.pers_upgrades_keys)
    {
        stat_name = level.pers_upgrades[perk].stat_names[0];
        perkstate[perk]["bool"] = self.pers_upgrades_awarded[perk];
        perkstate[perk]["value"] = self get_global_stat(stat_name);
    }

    if (!isDefined(old_perkstates))
        return perkstate;

    foreach (perk in level.pers_upgrades_keys)
    {
        if (perkstate[perk]["bool"] != old_perkstates[perk]["bool"])
            print("DEBUG: player=" + self.name + " " + perk + " changed state from " + old_perkstates[perk]["bool"] + " to " + perkstate[perk]["bool"]);
        if (perkstate[perk]["value"] != old_perkstates[perk]["value"])
            print("DEBUG: player=" + self.name + " " + perk + " changed value from " + old_perkstates[perk]["value"] + " to " + perkstate[perk]["value"]);
    }

    return perkstate;
}
