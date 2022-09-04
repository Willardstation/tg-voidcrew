/obj/machinery/computer/scan_consolenew/Initialize(mapload)
	. = ..()
	stored_research = null

/obj/machinery/computer/scan_consolenew/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/multitool))
		var/obj/item/multitool/multi = attacking_item
		if(istype(multi.buffer, /obj/machinery/ship_research_server))
			var/obj/machinery/ship_research_server/server = multi.buffer
			stored_research = server.source_code_hdd.stored_research
			say("Linked to Server!")
			return

	return ..()
