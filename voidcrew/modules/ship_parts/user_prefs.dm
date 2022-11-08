/datum/preferences

	///Ships owned by the owner of the prefs
	var/list/ships_owned = list(
		/obj/item/ship_parts/neutral = 0,
		/obj/item/ship_parts/nanotrasen = 0,
		/obj/item/ship_parts/syndicate = 0,
	)

/datum/preferences/proc/save_ships()
	if(!path)
		return FALSE
	if(!fexists(path))
		return FALSE

	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	S.cd = "/"

	WRITE_FILE(S["ships_owned"], ships_owned)

/datum/controller/subsystem/ticker/display_report(popcount)
	. = ..()
	for(var/client/all_clients as anything in GLOB.clients)
		all_clients.give_random_ship_part()

