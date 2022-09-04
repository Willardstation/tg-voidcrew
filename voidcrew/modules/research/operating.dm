/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures. Automatically syncs to operating tables within its line of sight for surgical tech advancement."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/operating

/obj/machinery/computer/operating/Initialize(mapload)
	. = ..()
	linked_techweb = null
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/operating/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/multitool))
		var/obj/item/multitool/multi = attacking_item
		if(istype(multi.buffer, /obj/machinery/ship_research_server))
			var/obj/machinery/ship_research_server/server = multi.buffer
			linked_techweb = server.source_code_hdd.stored_research
			say("Linked to Server!")
			return

	return ..()
