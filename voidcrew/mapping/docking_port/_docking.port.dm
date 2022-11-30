/**
 * The main docking port that all voidcrew ships should be using.
 */
/obj/docking_port/mobile/voidcrew
	launch_status = UNLAUNCHED

	/// Makes sure we dont run linking logic more than once
	VAR_PRIVATE/cached_z_level

	///The linked overmap object, if there is one
	var/obj/structure/overmap/ship/current_ship

	///List of spawn points on the ship.
	var/list/obj/machinery/cryopod/spawn_points = list()

/obj/docking_port/mobile/voidcrew/Destroy(force)
	current_ship.shuttle = null
	current_ship = null
	spawn_points.Cut()
	unlink_from_z_level()
	return ..()

/obj/docking_port/mobile/voidcrew/zMove(dir, turf/target, z_move_flags)
	..()
	// we don't need to do this in initialize because all ship loading starts in the template area and is then moved to transit
	link_to_z_level()

/// Links to the Z level to ensure that if there are more than one ships on a z level when one leaves it doesnt clear the z trait
/obj/docking_port/mobile/voidcrew/proc/link_to_z_level()
	if(cached_z_level == z)
		return
	unlink_from_z_level()
	RegisterSignal(SSdcs, COMSIG_GLOB_Z_SHIP_PROBE, PROC_REF(respond_to_z_port_probe))
	cached_z_level = z
	GLOB.station_levels_cache[z] = TRUE

/// Unlinks from the z level
/obj/docking_port/mobile/voidcrew/proc/unlink_from_z_level()
	if(cached_z_level == z)
		return
	UnregisterSignal(SSdcs, COMSIG_GLOB_Z_SHIP_PROBE)
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_Z_SHIP_PROBE))
		return
	GLOB.station_levels_cache[z] = FALSE

/// Signal Handler for checking if anyone else is linked to a z level
/obj/docking_port/mobile/voidcrew/proc/respond_to_z_port_probe(datum/source, z_level)
	SIGNAL_HANDLER
	return (z_level == cached_z_level)

/**
 * ##get_all_humans
 *
 * Returns a list of all the living humans on the ship, as long as they have a mind and a client.
 */
/obj/docking_port/mobile/voidcrew/proc/get_all_humans()
	var/list/humans_to_add = list()
	var/list/all_turfs = return_ordered_turfs(x, y, z, dir)
	for(var/turf/turf as anything in all_turfs)
		var/mob/living/carbon/human/human_to_add = locate() in turf.contents
		if(isnull(human_to_add))
			continue
		if(human_to_add.stat == DEAD)
			continue
		if(!human_to_add.client || !human_to_add.mind)
			continue
		humans_to_add.Add(human_to_add)
	return humans_to_add

/**
 * Scuttle the ship
 *
 * Delete all of the areas, and delete any cryopods
 */
/obj/docking_port/mobile/voidcrew/proc/mothball()
	if(length(get_all_humans()) > 0)
		return
	var/obj/docking_port/stationary/current_dock = get_docked()

	var/underlying_area_type = SHUTTLE_DEFAULT_UNDERLYING_AREA
	if(current_dock && current_dock.area_type)
		underlying_area_type = current_dock.area_type

	var/list/old_turfs = return_ordered_turfs(x, y, z, dir)

	var/area/underlying_area = GLOB.areas_by_type[underlying_area_type]
	if(!underlying_area)
		underlying_area = new underlying_area_type(null)

	for(var/turf/oldT in old_turfs)
		if(!oldT || !istype(oldT.loc, area_type))
			continue
		var/obj/machinery/cryopod/pod = locate() in oldT.contents
		if(pod)
			qdel(pod) // we don't want anyone respawning now do we
		var/obj/machinery/computer/helm/helm = locate() in oldT.contents
		if(helm)
			qdel(helm) // we don't want anyone respawning now do we

		var/area/old_area = oldT.loc
		underlying_area.contents += oldT
		oldT.transfer_area_lighting(old_area, underlying_area)

	message_admins("\[SHUTTLE]: [current_ship?.name] has been turned into a ruin!")
	log_admin("\[SHUTTLE]: [current_ship?.name] has been turned into a ruin!")

	qdel(src, force = TRUE)
