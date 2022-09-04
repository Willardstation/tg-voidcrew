/obj/machinery/computer/scan_consolenew/Initialize(mapload)
	. = ..()
	stored_research = null

/obj/machinery/computer/scan_consolenew/Destroy()
	if(stored_research)
		stored_research.connected_machines -= src
	return ..()

/obj/machinery/computer/scan_consolenew/unsync_research_servers()
	if(stored_research)
		stored_research.connected_machines -= src
		stored_research = null

/obj/machinery/computer/scan_consolenew/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/multitool))
		var/obj/item/multitool/multi = attacking_item
		if(istype(multi.buffer, /obj/machinery/rnd/server/ship))
			var/obj/machinery/rnd/server/ship/server = multi.buffer
			stored_research = server.source_code_hdd.stored_research
			say("Linked to Server!")
			stored_research.connected_machines += src
			return

	return ..()
