/**
 * We are modularly making stuff we don't want, early return.
 * We can manually re-add whatever we need here as well.
 */
/datum/controller/subsystem/mapping
	///List of all ships that can be purchased.
	var/list/ship_purchase_list = list()
	///List of all Nanotrasen ships, one is randomly selected to spawn at start.
	var/list/nt_ship_list = list()
	///List of all Syndicate ships, one is randomly selected to spawn at start.
	var/list/syn_ship_list = list()

/datum/controller/subsystem/mapping/Initialize(timeofday)
	load_ship_templates()
	return ..()

/datum/controller/subsystem/mapping/loadWorld()
	InitializeDefaultZLevels()

/datum/controller/subsystem/mapping/generate_linkages_for_z_level(z_level)
	if(!isnum(z_level) || z_level <= 0)
		return FALSE

	if(multiz_levels.len < z_level)
		multiz_levels.len = z_level

	// TODO - MULTI-Z
	multiz_levels[z_level] = list()

/datum/controller/subsystem/mapping/setup_map_transitions()
	return

///generates the list of GLOB.the_station_areas - We don't have a station, maybe we can make use of this one day for ships.
/datum/controller/subsystem/mapping/generate_station_area_list()
	return

/datum/controller/subsystem/mapping/proc/load_ship_templates()
	SHOULD_CALL_PARENT(TRUE)
	if(ship_purchase_list.len) //don't build repeatedly
		return

	for(var/datum/map_template/shuttle/voidcrew/shuttles as anything in subtypesof(/datum/map_template/shuttle/voidcrew))
		ship_purchase_list["[initial(shuttles.faction_prefix)] [initial(shuttles.name)] ([initial(shuttles.cost)] credits)"] = shuttles

		switch(initial(shuttles.faction_prefix))
			if(NANOTRASEN_SHIP)
				nt_ship_list[initial(shuttles.name)] = shuttles
			if(SYNDICATE_SHIP)
				syn_ship_list[initial(shuttles.name)] = shuttles

/datum/controller/subsystem/mapping/get_station_center()
	return SSovermap.overmap_centre || locate(OVERMAP_LEFT_SIDE_COORD, OVERMAP_NORTH_SIDE_COORD, OVERMAP_Z_LEVEL)

/datum/controller/subsystem/mapping/get_turf_above(turf/T)
	return SSovermap.calculate_turf_above(T)

/datum/controller/subsystem/mapping/get_turf_below(turf/T)
	return SSovermap.calculate_turf_below(T)

/get_safe_random_station_turf(list/areas_to_pick_from)
	if(!areas_to_pick_from)
		areas_to_pick_from = list()
		for(var/obj/structure/overmap/ship/ship as anything in SSovermap.simulated_ships)
			areas_to_pick_from += ship.shuttle.shuttle_areas
	return ..(areas_to_pick_from)

/get_random_station_turf()
	// the chance that this just fucking yeets you into hyper-space is too high
	return get_safe_random_station_turf()

/find_safe_turf(zlevel, list/zlevels, extended_safety_checks = FALSE, dense_atoms = FALSE)
	if(zlevel == 1)
		stack_trace("Attempting to get a safe turf on the overmap, this really shouldn't happen.")
	if(!zlevels)
		if(zlevel)
			zlevels = list(zlevel)
		else
			zlevels = list()
			for(var/obj/structure/overmap/ship/ship as anything in SSovermap.simulated_ships)
				zlevels |= ship.shuttle.z
	return ..(zlevel, zlevels, extended_safety_checks, dense_atoms)
