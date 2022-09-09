/obj/machinery/computer/rdconsole
	///The mobile ship we are connected to.
	var/datum/weakref/connected_ship_ref

/obj/machinery/computer/rdconsole/Initialize(mapload)
	. = ..()
	stored_research.consoles_accessing[src] = FALSE
	stored_research = null

/obj/machinery/computer/rdconsole/Destroy()
	. = ..()
	if(connected_ship_ref)
		connected_ship_ref = null
	if(stored_research)
		stored_research.connected_machines -= src
		stored_research = null

/obj/machinery/computer/rdconsole/unsync_research_servers()
	if(stored_research)
		stored_research.consoles_accessing[src] = FALSE
		stored_research.connected_machines -= src
		stored_research = null

/obj/machinery/computer/rdconsole/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	. = ..()
	if(!port)
		return FALSE
	connected_ship_ref = WEAKREF(port)

/obj/machinery/computer/rdconsole/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/multitool))
		var/obj/item/multitool/multi = attacking_item
		if(istype(multi.buffer, /obj/machinery/rnd/server/ship))
			var/obj/machinery/rnd/server/ship/server = multi.buffer
			stored_research = server.source_code_hdd.stored_research
			say("Linked to Server!")
			stored_research.connected_machines += src
			return
		if(stored_research)
			say("Disconnected from Server.")
			stored_research.connected_machines -= src
			stored_research.consoles_accessing -= src
			stored_research = null
			return

	if(istype(attacking_item, /obj/item/research_notes))
		var/obj/item/research_notes/research_notes = attacking_item
		stored_research.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = research_notes.value))
		playsound(src,'sound/machines/copier.ogg', 50, TRUE)
		qdel(research_notes)
		return

	return ..()


/obj/machinery/computer/rdconsole/ui_act(action, list/params)
	if (action == "loadTech")
		var/mob/living/user = usr
		var/obj/docking_port/mobile/voidcrew/port = connected_ship_ref?.resolve()
		if(port)
			if(!(user.mind in port.current_ship.ship_team.members))
				say("ERROR- DOWNLOADING NOT ALLOWED FOR NON-CREW!")
				return
	return ..()
