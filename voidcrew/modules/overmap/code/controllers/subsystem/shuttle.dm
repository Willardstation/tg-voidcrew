/datum/controller/subsystem/shuttle/proc/create_ship()
	// load a ship map

	UNTIL(!shuttle_loading)
	var/datum/map_template/shuttle/voidcrew/pill/new_pill = new
	shuttle_loading = TRUE
	if (!load_template(new_pill)) // NOVA TODO: this fails to load the ship
		stack_trace("Failed to load ship!")
		shuttle_loading = FALSE
		return
	shuttle_loading = FALSE

	// get the loading dock
	// spawn a new overmap ship on the overmap
	var/obj/structure/overmap/ship/ship_to_spawn = new(SSovermap.get_unused_overmap_square(tries = INFINITY))
	// link it to the loading dock
	ship_to_spawn.
