/datum/techweb
	///List of everything connected to this techweb via Multitool, used for R&D server deconstruction.
	var/list/connected_machines = list()

/datum/techweb/New()
	. = ..()
	for(var/datum/experiment/experiment_path as anything in subtypesof(/datum/experiment))
		available_experiments += new experiment_path()

/**
 * Cancel all experiments being added, we'll do it ourselves.
 */
/datum/techweb/add_experiments(list/experiment_list)
	return
