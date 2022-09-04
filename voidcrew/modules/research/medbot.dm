/mob/living/simple_animal/bot/medbot/Initialize(mapload, new_skin)
	. = ..()
	linked_techweb = null

/mob/living/simple_animal/bot/medbot/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/multitool))
		var/obj/item/multitool/multi = attacking_item
		if(istype(multi.buffer, /obj/machinery/ship_research_server))
			var/obj/machinery/ship_research_server/server = multi.buffer
			linked_techweb = server.source_code_hdd.stored_research
			say("Linked to Server!")
			return

	return ..()
