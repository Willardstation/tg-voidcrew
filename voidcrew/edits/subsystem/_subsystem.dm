/**
 * Hard disabled
 */
//No random events, we don't have any custom ones anyway.
/datum/controller/subsystem/events
	flags = SS_NO_INIT

//No night shifts, planets have timezones and such, whatever.
/datum/controller/subsystem/nightshift
	flags = SS_NO_INIT

//We do not want security levels, everyone is on individual ships.
/datum/controller/subsystem/security_level
	flags = SS_NO_INIT

//We do not want station traits.
/datum/controller/subsystem/processing/station
	flags = SS_NO_INIT

/**
 * Soft disabled
 */
// We do not want paychecks, we want people to make money themselves legitimately
/datum/controller/subsystem/economy
	can_fire = FALSE

//We do not have Antagonists, there is no point in processing this.
/datum/controller/subsystem/traitor
	can_fire = FALSE
