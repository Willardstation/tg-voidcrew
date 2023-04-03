/**
 * Removes the ability to take money out of ID cards directly.
 * Instead they'll have to go through a Bank accounting machine.
 */
/obj/item/card/id/AltClick(mob/living/user)
	return FALSE

///Security OFficer's job trim refresh requires a set security officer job, so lets return out if it doesn't exist.
/datum/id_trim/job/security_officer/refresh_trim_access()
	var/datum/job/job_exists = SSjob.GetJob(JOB_SECURITY_OFFICER)
	if(!job_exists)
		return
	return ..()
