/datum/experiment
	///Whether the experiment will be available to players.
	var/voidcrew_available = TRUE

/datum/experiment/finish_experiment(datum/component/experiment_handler/experiment_handler)
	. = ..()
	experiment_handler.linked_web.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = RESEARCH_STOLEN_PER_THEFT))

/datum/experiment/dissection
	voidcrew_available = FALSE

/datum/experiment/ordnance
	voidcrew_available = FALSE

/datum/experiment/scanning/random/material
	voidcrew_available = FALSE
