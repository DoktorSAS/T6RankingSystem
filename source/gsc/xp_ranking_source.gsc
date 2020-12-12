#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud_message;


init()
{
    level.callbackactordamage = ::custom_actor_damage_override_wrapper;
    level thread on_player_connect();
    level thread add_xp_based_on_time_played();
    level thread add_xp_based_on_rounds_beaten();
    level thread add_xp_for_opened_doors();
    level thread add_xp_for_opened_debris();
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
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
	else
	{
        if ( isDefined(attacker)  && isDefined(attacker.pers[ "xp_ranking" ]))
        {
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

add_xp_for_opened_debris()
{
    debris_trigs = getentarray( "zombie_debris", "targetname" );
    foreach ( debris_trig in debris_trigs )
    {
    	 debris_trig thread watch_for_open_door();
    }
}

add_xp_for_opened_doors()
{
    zombie_doors = getentarray( "zombie_door", "targetname" );
    foreach ( zombie_door in zombie_doors )
    {
    	zombie_door thread watch_for_open_door();
    }
}

watch_for_open_door()
{
    level endon( "end_game" );
    while ( true )
    {
        self waittill( "trigger", who, force );
        if ( isDefined( level.custom_door_buy_check ) )
        {
            if ( !who [[ level.custom_door_buy_check ]]( self ) )
            {
                continue;
            }
        }
        if ( getDvarInt( "zombie_unlock_all" ) > 0 || isDefined( force ) && force )
        {
            continue;
        }
        if ( !who usebuttonpressed() )
        {
            continue;
        }
        if ( who maps/mp/zombies/_zm_utility::in_revive_trigger() )
        {
            continue;
        }
        if ( maps/mp/zombies/_zm_utility::is_player_valid( who ) )
        {
            cost = self.zombie_cost;
            if ( who.score >= cost )
            {
                xp = getDvarInt( "xp_for_open_door" );
                who.pers[ "xp_ranking" ] += xp;
                break;
            }
            else
            {
                continue;
            }
        }
    }
}
