/datum/controller/subsystem/shuttle/proc/create_ship(datum/map_template/shuttle/voidcrew/ship_template_to_spawn)
	RETURN_TYPE(/obj/structure/overmap/ship)

	UNTIL(!shuttle_loading)
	var/obj/structure/overmap/ship/ship_to_spawn = new(SSovermap.get_unused_overmap_square(tries = INFINITY))
	ship_template_to_spawn = new ship_template_to_spawn
	shuttle_loading = TRUE
	var/load_resp = action_load(ship_template_to_spawn)
	if (!load_resp)
		stack_trace("Failed to load ship!")
		shuttle_loading = FALSE
		qdel(ship_to_spawn)
		return
	shuttle_loading = FALSE
	ship_to_spawn.shuttle = load_resp

	return load_resp
