/**
 * TODO
 *
 * TECHWEB STUFF
 *
 * Experiment handlers
 *
 * Add dissections
 * Add survey machines
 * Experiments:
 * - Give research points
 *
 * RESEARCH STUFF
 *
 * Add designs for Prolathes
 * Add designs for Circuit imprinters
 * Add designs for R&D servers
 * Add designs for R&D consoles
 *
 * context menus
 *
 */

/datum/techweb
	///List of everything connected to this techweb via Multitool, used for R&D server deconstruction.
	var/list/connected_machines = list()

/datum/techweb/New()
	. = ..()
	for (var/datum/experiment/experiment_path as anything in subtypesof(/datum/experiment))
		if (initial(experiment_path.voidcrew_available))
			available_experiments += new experiment_path()

/**
 * Allow RND machines to be connected via multitool
 * But only if we're connected to science's node by default
 * Check is for stuff like Autolathes.
 */
/obj/machinery/rnd/Initialize(mapload)
	. = ..()
	if(stored_research == SSresearch.science_tech)
		stored_research = null

/obj/machinery/rnd/Destroy()
	if(stored_research)
		stored_research.connected_machines -= src
	return ..()

/obj/machinery/rnd/unsync_research_servers()
	if(stored_research)
		stored_research.connected_machines -= src
		stored_research = null

/obj/machinery/rnd/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/multitool) && !istype(src, /obj/machinery/rnd/server/ship))
		var/obj/item/multitool/multi = attacking_item
		if(istype(multi.buffer, /obj/machinery/rnd/server/ship))
			var/obj/machinery/rnd/server/ship/server = multi.buffer
			stored_research = server.source_code_hdd.stored_research
			stored_research.connected_machines += src
			say("Linked to Server!")
			return

	return ..()


/**
 * Cancel all experiments being added, we'll do it ourselves.
 */
/datum/techweb/add_experiments(list/experiment_list)
	return
