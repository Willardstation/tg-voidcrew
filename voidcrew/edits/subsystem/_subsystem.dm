/datum/controller/subsystem
	///If this is TRUE, this subsystem will delete itself entirely.
	///This is for subsystems that TG has but we absolutely do not need or want.
	///Disabling these help with Init times slightly, but the goal is to remove things we don't want running.
	var/voidcrew_hard_disabled = FALSE

	///If this is TRUE, this subsystem will not be able to fire anymore.
	///This is for subsystems that we need to Initialize, but don't want to process.
	var/voidcrew_soft_disabled = FALSE

/datum/controller/subsystem/Initialize()
	if(voidcrew_hard_disabled)
		qdel(src)
		return
	..()
	if(voidcrew_soft_disabled)
		can_fire = FALSE

/**
 * Hard disabled
 */
//No random events, we don't have any custom ones anyway.
/datum/controller/subsystem/events
	voidcrew_hard_disabled = TRUE

//No night shifts, planets have timezones and such, whatever.
/datum/controller/subsystem/nightshift
	voidcrew_hard_disabled = TRUE

//We do not want security levels, everyone is on individual ships.
/datum/controller/subsystem/security_level
	voidcrew_hard_disabled = TRUE

//We do not want station traits.
/datum/controller/subsystem/processing/station
	voidcrew_hard_disabled = TRUE

/**
 * Soft disabled
 */
// We do not want paychecks, we want people to make money themselves legitimately
/datum/controller/subsystem/economy
	voidcrew_soft_disabled = TRUE

//We do not have Antagonists, there is no point in processing this.
/datum/controller/subsystem/traitor
	voidcrew_soft_disabled = TRUE
