/datum/controller/subsystem/shuttle/proc/create_ship(datum/map_template/shuttle/voidcrew/ship_template_to_spawn)
	RETURN_TYPE(/obj/structure/overmap/ship)

	UNTIL(!shuttle_loading)
	var/obj/structure/overmap/ship/ship_to_spawn = new(SSovermap.get_unused_overmap_square(tries = INFINITY))
	ship_template_to_spawn = new ship_template_to_spawn

	shuttle_loading = TRUE
	var/obj/docking_port/mobile/loaded = action_load(ship_template_to_spawn)
	shuttle_loading = FALSE

	if(!loaded)
		qdel(ship_to_spawn)
		return

	ship_to_spawn.name = loaded.name
	ship_to_spawn.source_template = ship_template_to_spawn
	ship_to_spawn.shuttle = loaded
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
