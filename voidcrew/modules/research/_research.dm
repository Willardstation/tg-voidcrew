/**
 * TODO
 *
 * TECHWEB STUFF
 *
 * Experiment handlers
 *
 * RESEARCH POINT GENERATION
 *
 * Add dissections
 * Add survey machines
 * Experiments:
 * - Give research points
 * - Are all unlocked from the start
 *
 * RESEARCH STUFF
 *
 * Add designs for Prolathes
 * Add designs for Circuit imprinters
 * Add designs for R&D servers
 * Add designs for R&D consoles
 *
 */

/obj/machinery/rnd/Initialize(mapload)
	. = ..()
	if(stored_research == SSresearch.science_tech)
		stored_research = null

/obj/machinery/rnd/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/multitool))
		var/obj/item/multitool/multi = attacking_item
		if(istype(multi.buffer, /obj/machinery/ship_research_server))
			var/obj/machinery/ship_research_server/server = multi.buffer
			linked_techweb = server.source_code_hdd.stored_research
			say("Linked to Server!")
			return

	return ..()
