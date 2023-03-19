#include common_scripts\utility;

main()
{
    level thread safe_init();
}

safe_init()
{
    level waittill("frfix_init");
    level.FRFIX_PLUGIN_FRIDGE = ::set_fridge;
}

set_fridge(func)
{
    switch (level.players[0].name)
    {
        default:
            foreach (player in level.players)
            {
                if (level.script == "zm_transit")
                    player [[func]]("mp5k_upgraded_zm");
                else if (level.script == "zm_highrise" || level.script == "zm_buried")
                    player [[func]]("an94_upgraded_zm");
            }
    }
}
