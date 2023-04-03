//For unit tests, as we don't have 'planets', we set all maps to not be planetary, and remove all job changes.
/datum/map_config/LoadConfig(filename, error_if_missing)
	. = ..()
	planetary = FALSE
	job_changes = list()
