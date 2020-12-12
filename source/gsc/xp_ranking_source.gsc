#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm;

init()
{
    level.callbackactordamage = ::custom_actor_damage_override_wrapper;
    level thread on_player_connect();
    level thread add_xp_based_on_time_played();
    level thread add_xp_based_on_rounds_beaten();
}

on_player_connect()
{
    level endon( "end_game" );
    while ( true )
    {
        level waittill( "connected", player );
        player.pers[ "xp_ranking" ] = 0; //change to whatever method to save xp when ready
        player thread add_xp_based_on_successful_revives();
	player thread display_player_xp();
    }
}

display_player_xp(){
	self endon( "disconnect" );
	level endon( "end_game" );
	xp_value = CreateFontString("small", 1.2);
	xp_value setPoint("CENTER", "RIGHT", "CENTER", -200);
	xp_value.label = &"";
	xp_value.alpha = 1;
	while(true){
		if(self.pers[ "xp_ranking" ] >= 1000000){
			score_value SetValue(999999);
			score_value FadeOverTime( 1 );
		}else{
			xp_value SetValue(self.pers[ "xp_ranking" ]);
			xp_value FadeOverTime( 1 );
		} 
		wait 0.05;
	}
}

add_xp_based_on_successful_revives()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    while ( 1 )
    {
        self waittill( "player_revived", reviver );
        reviver.pers[ "xp_ranking" ] += getDvarInt( "xp_for_revive" );
    }
}

custom_actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked does not match cerberus output did not change
{
	damage_override = self actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	if ( ( self.health - damage_override ) > 0 )
	{
		print_to_all("No kill");
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
	else
	{
		print_to_all("kill");
        if ( isDefined(attacker)  && isDefined(attacker.pers[ "xp_ranking" ]))
        {
        	print_to_all("points");
            attacker.pers[ "xp_ranking" ] += getDvarInt( "xp_for_kill" );
            if ( meansofdeath == "MOD_MELEE" )
            {
                attacker.pers[ "xp_ranking" ] += getDvarInt( "bouns_if_knife_kill" );
            }
        }
		self [[ level.callbackactorkilled ]]( inflictor, attacker, damage, meansofdeath, weapon, vdir, shitloc, psoffsettime );
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
}

/* 
	Thread called in the init to reduce the amount of total
	thread. Is a system to optimize the script on server-side
*/

add_xp_based_on_rounds_beaten()
{ 
    level endon( "end_game" );
    level waittill( "start_of_round" ); //skip first round
    xp = getDvarInt( "xp_for_round" );
    xp_for_round_bouns = getDvarInt( "xp_for_round_bouns" );
    while ( 1 )
    {
        level waittill( "start_of_round" );
        foreach(player in level.players){
        	player.pers[ "xp_ranking" ] += xp;
        	if ( xp_for_round_bouns )
        	{
            	player.pers[ "xp_ranking" ] += level.round_number;
        	}
        }
    }
}

add_xp_based_on_time_played()
{
    level endon( "end_game" );
    xp = getDvarInt( "xp_for_minutes" );
    while ( 1 )
    {
        wait 60;
        foreach(player in level.players)
        	player.pers[ "xp_ranking" ] += xp;
    }
}

add_xp_on_power_on()
{
    level endon( "end_game" );
    level waittill("power_on");
    xp = getDvarInt("turn_on_power");
    foreach(player in level.players)
        player.pers[ "xp_ranking" ] += xp;
}
