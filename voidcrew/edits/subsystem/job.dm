///The spawning of the inital ship in `/datum/job/map_check()` will set this for us without editing job positions.
/datum/controller/subsystem/job/set_overflow_role(new_overflow_role)
	return

/datum/controller/subsystem/job/setup_officer_positions()
	var/datum/job/job_exists = SSjob.GetJob(JOB_SECURITY_OFFICER)
	if(!job_exists)
		return
	return ..()
