main()
{
	replaceFunc( maps\mp\animscripts\zm_utility::wait_network_frame, ::wait_network_frame_override );
	replaceFunc( maps\mp\zombies\_zm_utility::wait_network_frame, ::wait_network_frame_override );
}

wait_network_frame_override()
{
	wait 0.1;
}