/mob/living/simple_animal/bot/medbot/Initialize(mapload, new_skin)
	. = ..()
	linked_techweb = null

/mob/living/simple_animal/bot/medbot/Destroy()
	if(linked_techweb)
		linked_techweb.connected_machines -= src
	return ..()

/mob/living/simple_animal/bot/medbot/unsync_research_servers()
	if(linked_techweb)
		linked_techweb.connected_machines -= src
		linked_techweb = null

/mob/living/simple_animal/bot/medbot/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/multitool))
		var/obj/item/multitool/multi = attacking_item
		if(istype(multi.buffer, /obj/machinery/rnd/server/ship))
			var/obj/machinery/rnd/server/ship/server = multi.buffer
			linked_techweb = server.source_code_hdd.stored_research
			linked_techweb.connected_machines += src
			say("Linked to Server!")
			return

	return ..()
