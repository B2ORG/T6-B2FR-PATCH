#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\_utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_stats;

main()
{
    level thread safe_init();
}

safe_init()
{
	level waittill("frfix_init");
    level.FRFIX_PLUGIN_PERMAPERKS = ::award_permaperks;
}

debug_print(text)
{
	if (level.FRFIX_CONFIG["debug"])
		print("DEBUG: " + text);
}

info_print(text)
{
	print("INFO: " + text);
}

print(arg)
{
}

is_round(rnd)
{
	if (rnd <= level.round_number)
		is_rnd = true;
	else
		is_rnd = false;

	return is_rnd;
}

permaperk_struct(current_array, code, award, take, to_round, maps_exclude, map_unique)
{
	if (!isDefined(maps_exclude))
		maps_exclude = array();
	if (!isDefined(to_round))
		to_round = 255;
	if (!isDefined(map_unique))
		map_unique = undefined;

	permaperk = spawnStruct();
	permaperk.code = code;
	permaperk.to_round = to_round;
	permaperk.award = award;
	permaperk.take = take;
	permaperk.maps_to_exclude = maps_exclude;
	permaperk.map_unique = map_unique;

	debug_print("generating permaperk struct | data: code=" + code + " to_round=" + to_round + " award=" + award + " take=" + take + " map_unique=" + map_unique + " | size of current: " + current_array.size);

	current_array[current_array.size] = permaperk;
	return current_array;
}

// This implementation is currently broken, do not use
award_permaperks()
{
	level endon("end_game");
	self endon("disconnect");

	if (!level.FRFIX_CONFIG["give_permaperks"] || level.round_number > level.start_round + 2)
		return;

	while (!isalive(self))
		wait 0.05;

	wait 0.5;

	perks_to_process = array();
	perks_to_process = permaperk_struct(perks_to_process, "revive", true, false);
	perks_to_process = permaperk_struct(perks_to_process, "multikill_headshots", true, false);
	perks_to_process = permaperk_struct(perks_to_process, "perk_lose", true, false);
	perks_to_process = permaperk_struct(perks_to_process, "jugg", true, false, 15);
	perks_to_process = permaperk_struct(perks_to_process, "flopper", true, false, 255, array(), "zm_buried");
	perks_to_process = permaperk_struct(perks_to_process, "box_weapon", false, true, 255, array("zm_buried"));
	perks_to_process = permaperk_struct(perks_to_process, "nube", true, true, 10, array("zm_highrise"));

	self.frfix_awarding_permaperks = true;

	foreach (perk in perks_to_process)
	{
		wait 0.05;

		if (isDefined(perk.map_unique) && perk.map_unique != level.script)
			continue;

		perk_code = perk.code;
		debug_print("processing: " + perk_code);

		// If award and take are both set, it means maps specified in 'maps_to_exclude' are the maps on which perk needs to be taken away
		if (perk.award && perk.take && isinarray(perk.maps_to_exclude, level.script))
		{
			self remove_permaperk(perk_code);
			wait_network_frame();
		}
		// Else if take is specified, take
		else if (!perk.award && perk.take && !isinarray(perk.maps_to_exclude, level.script))
		{
			self remove_permaperk(perk_code);
			wait_network_frame();
		}

		for (j = 0; j < level.pers_upgrades[perk_code].stat_names.size; j++)
		{
			stat_name = level.pers_upgrades[perk_code].stat_names[j];
			stat_value = level.pers_upgrades[perk_code].stat_desired_values[j];

			self reset_permaperk(stat_name, perk_code);
			wait_network_frame();

			// Award perk if all conditions match
			if (perk.award && !is_round(perk.to_round) && !isinarray(perk.maps_to_exclude, level.script))
			{
				self award_permaperk(stat_name, perk_code, stat_value);
				wait_network_frame();
			}
		}
	}

	wait 0.5;
	self.frfix_awarding_permaperks = undefined;
	self uploadstatssoon();
}

reset_permaperk(stat_name, perk_code)
{
	perk_name = permaperk_name(perk_code);

	self.stats_this_frame[stat_name] = 1;
	self set_global_stat(stat_name, 0);
	info_print(self.name + ": Permaperk '" + perk_name + "' resetting -> " + stat_name + " set to: 0");
}

award_permaperk(stat_name, perk_code, stat_value)
{
	perk_name = permaperk_name(perk_code);

	if (self get_global_stat(stat_name) != stat_value)
	{
		self.stats_this_frame[stat_name] = 1;
		self set_global_stat(stat_name, stat_value);
		info_print(self.name + ": Permaperk '" + perk_name + "' activation -> " + stat_name + " set to: " + stat_value);
	}
	else
	{
		info_print(self.name + ": Permaperk '" + perk_name + "' activation -> Requirements already met");
	}
}

remove_permaperk(perk_code, perk_name)
{
	if (!isDefined(perk_name))
		perk_name = permaperk_name(perk_code);

	info_print("Perk Removal for " + self.name + ": " + perk_name);
	self.pers_upgrades_awarded[perk_code] = 0;
}

permaperk_name(perk)
{
	switch (perk)
	{
		case "revive":
			return "Quick Revive";
		case "multikill_headshots":
			return "Extra Headshot Damage";
		case "perk_lose":
			return "Tombstone";
		case "jugg":
			return "Juggernog";
		case "flopper":
			return "Flopper";
		case "box_weapon":
			return "Better Mystery Box";
		case "nube":
			return "Nube";
		case "board":
			return "Metal Boards";
		case "carpenter":
			return "Metal Carpenter Boards";
		case "insta_kill":
			return "Insta-Kill Pro";
		case "cash_back":
			return "Perk Refund";
		case "pistol_points":
			return "Double Pistol Points";
		case "double_points":
			return "Half-Off";
		case "sniper":
			return "Sniper Points";
		default:
			return perk;
	}
}
