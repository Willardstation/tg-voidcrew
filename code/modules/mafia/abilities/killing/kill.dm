/**
 * Attack
 *
 * During the night, attacks a player in attempts to kill them.
 */
/datum/mafia_ability/attack_player
	name = "Attack"
	ability_action = "attempt to attack"
	action_priority = COMSIG_MAFIA_NIGHT_KILL_PHASE
	///The message told to the player when they are killed.
	var/attack_action = "killed by"
	///Whether the player will suicide if they hit a Town member.
	var/honorable = FALSE

/datum/mafia_ability/attack_player/perform_action(datum/mafia_controller/game, datum/mafia_role/day_target)
	if(!using_ability)
		return
	if(!validate_action_target(game))
		return ..()

	if(!target_role.kill(game, src, FALSE))
		to_chat(host_role.body, span_danger("Your attempt at killing [target_role.body.real_name] was prevented!"))
	else
		to_chat(target_role.body, span_userdanger("You have been [attack_action] \a [host_role.name]!"))
		if(honorable && (target_role.team != MAFIA_TEAM_TOWN))
			to_chat(host_role.body, span_userdanger("You have killed an innocent crewmember. You will die tomorrow night."))
			RegisterSignal(game, COMSIG_MAFIA_SUNDOWN, PROC_REF(internal_affairs))
	return ..()

/datum/mafia_ability/attack_player/proc/internal_affairs(datum/mafia_controller/game)
	SIGNAL_HANDLER
	to_chat(host_role.body, span_userdanger("You have been killed by Nanotrasen Internal Affairs!"))
	host_role.reveal_role(game, verbose = TRUE)
	host_role.kill(game, src, FALSE) //you technically kill yourself but that shouldn't matter

/datum/mafia_ability/attack_player/honorable
	attack_action = "executed by"
	honorable = TRUE
