/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures. Automatically syncs to operating tables within its line of sight for surgical tech advancement."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/operating

/obj/machinery/computer/operating/Initialize(mapload)
	. = ..()
	QDEL_NULL(experiment_handler)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/operating/Destroy()
	unsync_research_servers()
	return ..()

/obj/machinery/computer/operating/unsync_research_servers()
	if(linked_techweb)
		linked_techweb.connected_machines -= src
		linked_techweb = null

/obj/machinery/computer/operating/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb)) //disconnect old one
		linked_techweb.connected_machines -= src
	. = ..()
	if(.)
		linked_techweb.connected_machines += src //connect new one
		say("Linked to Server!")
