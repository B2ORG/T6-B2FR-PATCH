// by JezuzLizard
init()
{
    level thread on_player_connect();
}

on_player_connect()
{
    while (true)
    {
        level waittill("connected", player);
        player thread print_nearby_entities();
    }
}

print_nearby_entities()
{
    level waittill("initial_blackscreen_passed");
    ents = getentarray("destructible", "targetname");
    while(1)
    {
        foreach(ent in ents)
        {
            if(distancesquared(self.origin, ent.origin) < 128 * 128)
            {
                if(ent.classname != "player" && ent.targetname == "destructible")
                {
                    if (isdefined(ent.model))
                    {
                        self iprintln(ent.model);
                    }
                    if (isdefined(ent.origin))
                    {
                        self iprintln(ent.origin);
                    }
                    if (isdefined(ent.angles))
                    {
                        self iprintln(ent.angles);
                    }
                }
            }
        }
        wait(1);
    }
}