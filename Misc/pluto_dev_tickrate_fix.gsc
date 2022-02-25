main()
{ 
	replaceFunc( maps/mp/animscripts/zm_utility::wait_network_frame, ::wait_network_frame_override );
	replaceFunc( maps/mp/zombies/_zm_utility::wait_network_frame, ::wait_network_frame_override );
    level thread onConnect();
}

onConnect()
{
    for (;;)
    {
        level waittill("connected", player);
        player thread connected();
    }
}

connected()
{
    self endon("disconnect");

    self.initial_spawn = true;

    for(;;)
    {
        self waittill("spawned_player");

        if( self.initial_spawn )
		{
			self.initial_spawn = false;
            self iprintln( "^5Spawn Rate Fix" );
        }
    }
}

wait_network_frame_override() // fix for increased spawn rate
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