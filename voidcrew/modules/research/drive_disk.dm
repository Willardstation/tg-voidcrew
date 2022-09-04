/obj/item/computer_hardware/hard_drive/cluster/hdd_theft/ship_disk
	name = "R&D server source code"
	desc = "The source code on this drive stores all the research from a ship, insert it into an R&D console to make use of it."

	var/datum/techweb/stored_research

/obj/item/computer_hardware/hard_drive/cluster/hdd_theft/ship_disk/Initialize(mapload)
	. = ..()
	name += " [num2hex(rand(1,65535), -1)]"
	stored_research = new()
	SSresearch.servers |= src

/obj/item/computer_hardware/hard_drive/cluster/hdd_theft/ship_disk/Destroy()
	. = ..()
	stored_research = null

