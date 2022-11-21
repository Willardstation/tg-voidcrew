/**
 * We are modularly making stuff we don't want, early return.
 * We can manually re-add whatever we need here as well.
 */
/datum/controller/subsystem/mapping
	///List of all ships that can be purchased.
	var/list/datum/map_template/shuttle/voidcrew/ship_purchase_list = list()
	///List of all Nanotrasen ships, one is randomly selected to spawn at start.
	var/list/datum/map_template/shuttle/voidcrew/nt_ship_list = list()
	///List of all Syndicate ships, one is randomly selected to spawn at start.
	var/list/datum/map_template/shuttle/voidcrew/syn_ship_list = list()

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

/datum/controller/subsystem/mapping/setup_ruins()
	return

/datum/controller/subsystem/mapping/proc/load_ship_templates()
	SHOULD_CALL_PARENT(TRUE)
	if(ship_purchase_list.len) //don't build repeatedly
		return

	for(var/datum/map_template/shuttle/voidcrew/shuttles as anything in subtypesof(/datum/map_template/shuttle/voidcrew))
		ship_purchase_list["[initial(shuttles.name)] ([initial(shuttles.faction_prefix)] [initial(shuttles.part_cost)] part\s)"] = shuttles

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

/proc/get_safe_random_station_turf(list/areas_to_pick_from)
	if(!areas_to_pick_from)
		areas_to_pick_from = list()
		for(var/obj/structure/overmap/ship/ship as anything in SSovermap.simulated_ships)
			areas_to_pick_from += ship.shuttle.shuttle_areas

	for(var/idx in 1 to 5)
		var/list/turfs = get_area_turfs(pick(areas_to_pick_from))
		var/turf/target_turf
		while(length(turfs) && !target_turf)
			var/checking_idx = rand(1, length(turfs))
			var/turf/checking_turf = turfs[checking_idx]
			var/area/turf_area = get_area(checking_turf)
			turfs.Cut(checking_idx, checking_idx + 1)
			if(checking_turf.density)
				continue
			if(!(turf_area.area_flags & VALID_TERRITORY))
				continue
			if(isgroundlessturf(checking_turf))
				continue
			target_turf = checking_turf
			break

		if(target_turf)
			return target_turf

/// This actually gives you a random ship turf, not a random station turf; modular code goes wee
/proc/get_random_station_turf()
	var/list/areas = list()
	for(var/obj/structure/overmap/ship/ship as anything in SSovermap.simulated_ships)
		areas += ship.shuttle.shuttle_areas

	for(var/idx in 1 to 5)
		var/list/turfs = get_area_turfs(pick(areas))
		var/turf/target_turf
		while(length(turfs) && !target_turf)
			var/checking_idx = rand(1, length(turfs))
			var/turf/checking_turf = turfs[checking_idx]
			turfs.Cut(checking_idx, checking_idx + 1)
			if(checking_turf.density)
				continue
			target_turf = checking_turf
			break

		if(target_turf)
			return target_turf

/proc/find_safe_turf(zlevel, list/zlevels, extended_safety_checks = FALSE, dense_atoms = FALSE)
	if(zlevel == 1)
		stack_trace("Attempting to locate a safe turf on the overmap zlevel, this really shouldn't happen!")

	if(zlevel)
		zlevels = list(zlevel)

	var/list/area/areas = list()
	for(var/obj/structure/overmap/ship/ship as anything in SSovermap.simulated_ships)
		areas += ship.shuttle.shuttle_areas
	// TODO - IMPL EVENT DATUM AND DONT USE SHIPS
	// for(var/datum/overmap/event/event as anything in SSovermap.events)
	// 	areas += event.event_areas

	while(length(areas))
		var/area_idx = rand(1, length(areas))
		var/area/target_area = areas[area_idx]
		areas.Cut(area_idx, area_idx + 1)

		var/list/turfs = get_area_turfs(target_area)
		while(length(turfs))
			var/turf_idx = rand(1, length(turfs))
			var/turf/target_turf = turfs[turf_idx]
			turfs.Cut(turf_idx, turf_idx + 1)
			if(is_safe_turf(target_turf, extended_safety_checks, dense_atoms))
				return target_turf
