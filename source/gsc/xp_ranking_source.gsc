#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm;

init()
{
    level.callbackactordamage = ::custom_actor_damage_override_wrapper;
    level thread on_player_connect();
}

on_player_connect()
{
    level endon( "end_game" );
    while ( true )
    {
        level waittill( "connected", player );
        player.pers[ "xp_ranking" ] = 0; //change to whatever method to save xp when ready
        player thread add_xp_based_on_time_played();
        player thread add_xp_based_on_rounds_beaten();
        player thread add_xp_based_on_successful_revives();
    }
}

add_xp_based_on_time_played()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    while ( true )
    {
        wait 60;
        self.pers[ "xp_ranking" ] += getDvar( "xp_for_minutes" );
    }
}

add_xp_based_on_rounds_beaten()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    level waittill( "start_of_round" ); //skip first round
    while ( true )
    {
        level waittill( "start_of_round" );
        self.pers[ "xp_ranking" ] += getDvar( "xp_for_round" );
        if ( getDvar( "xp_for_round_bouns" ) )
        {
            self.pers[ "xp_ranking" ] += level.round_number;
        }
    }
}

add_xp_based_on_successful_revives()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    while ( 1 )
    {
        self waittill( "player_revived", reviver );
        reviver.pers[ "xp_ranking" ] += getDvar( "xp_for_revive" );
    }
}

custom_actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked does not match cerberus output did not change
{
	damage_override = self actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	if ( ( self.health - damage_override ) > 0 || !is_true( self.dont_die_on_me ) )
	{
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
	else 
	{
        if ( is_player( attacker ) )
        {
            attacker.pers[ "xp_ranking" ] += getDvar( "xp_for_kill" );
            if ( meansofdeath == "MOD_MELEE" )
            {
                attacker.pers[ "xp_ranking" ] += getDvar( "bouns_if_knife_kill" );
            }
        }
		self [[ level.callbackactorkilled ]]( inflictor, attacker, damage, meansofdeath, weapon, vdir, shitloc, psoffsettime );
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
}