/datum/controller/subsystem/shuttle/proc/create_ship(datum/map_template/shuttle/voidcrew/ship_template_to_spawn)
	RETURN_TYPE(/obj/structure/overmap/ship)

	UNTIL(!shuttle_loading)
	var/obj/structure/overmap/ship/ship_to_spawn = new(SSovermap.get_unused_overmap_square(tries = INFINITY))
	ship_template_to_spawn = new ship_template_to_spawn
	shuttle_loading = TRUE
	var/load_resp = load_template(ship_template_to_spawn)
	if (!load_resp)
		stack_trace("Failed to load ship!")
		shuttle_loading = FALSE
		qdel(ship_to_spawn)
		return

	shuttle_loading = FALSE
	ship_to_spawn.shuttle = preview_shuttle
	ship_to_spawn.name = preview_shuttle.name
	preview_shuttle.register(TRUE)
	preview_shuttle.postregister(TRUE)

	var/transit_dock = SSshuttle.generate_transit_dock(preview_shuttle)
	if(!transit_dock)
		stack_trace("Failed to generate a transit dock for [ship_to_spawn]")
		qdel(ship_to_spawn)
		preview_shuttle = null
		return

	var/transit_resp = preview_shuttle.initiate_docking(transit_dock)
	if(transit_resp != DOCKING_SUCCESS)
		stack_trace("Failed to initiate docking for [ship_to_spawn]")
		qdel(ship_to_spawn)
		preview_shuttle = null
		return

	preview_shuttle = null
	return ship_to_spawn

/client/add_admin_verbs()
	. = ..()
	add_verb(src, list(
		.proc/respawn_ship,
		.proc/spawn_specific_ship,
	))

/client/remove_admin_verbs()
	. = ..()
	remove_verb(src, list(
		.proc/respawn_ship,
		.proc/spawn_specific_ship,
	))

/client/proc/respawn_ship()
	set name = "Respawn Initial Ship"
	set category = "Overmap"
	SSovermap.initial_ship?.shuttle?.intoTheSunset()
	SSovermap.spawn_initial_ship()

/client/proc/spawn_specific_ship()
	set name = "Spawn Specific Ship"
	set category = "Overmap"
	var/ship_to_spawn = input("Which ship do you want to spawn?", "Spawn Specific Ship") as null|anything in subtypesof(/datum/map_template/shuttle/voidcrew)
	if(!ship_to_spawn)
		return

	var/obj/structure/overmap/ship/spawned = SSshuttle.create_ship(ship_to_spawn)
	mob.admin_teleport(spawned.shuttle)
