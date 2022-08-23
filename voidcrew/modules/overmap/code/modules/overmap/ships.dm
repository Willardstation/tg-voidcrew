#define SHIP_VIEW_RANGE 4

/obj/structure/overmap/ship
	name = "Shuttle"
	desc = "its a friggin shuttle" //true

	icon_state = "ship"


	var/state = "Idle"
	var/est_thrust = 0

	var/close_overmap_objects = list()
	var/shuttle = null

	var/source_template = null
	var/mass = 0
	var/sensor_range = 0

	///All engines synced to this map.
	var/list/obj/machinery/power/shuttle/engine/engine_list = list()

	// Stuff needed to render the map
	var/map_name
	var/atom/movable/screen/map_view/cam_screen
	var/list/cam_plane_masters
	var/atom/movable/screen/background/cam_background

/obj/structure/overmap/ship/Initialize(mapload)
	. = ..()
	map_name = "overmap_[REF(src)]_map"
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_masters = list()
	for (var/plane in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/instance = new plane()
		if(instance.blend_mode_override)
			instance.blend_mode = instance.blend_mode_override
		instance.assigned_map = map_name
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "[map_name]:CENTER"
		cam_plane_masters += instance
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE
	update_screen()

/obj/structure/overmap/ship/Destroy()
	. = ..()

	QDEL_NULL(cam_screen)
	QDEL_LIST(cam_plane_masters)
	QDEL_NULL(cam_background)

/**
  * Updates the screen object, which is displayed on all connected helms
  */
/obj/structure/overmap/ship/proc/update_screen()
	var/list/visible_turfs = list()
	for(var/turf/visible_turf in view(SHIP_VIEW_RANGE, get_turf(src)))
		visible_turfs += visible_turf

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen?.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)
	return TRUE


/obj/structure/overmap/ship/newtonian_move(direction, instant, start_delay)
	return // fuck you no gravity



/obj/structure/overmap/ship/proc/try_move(x = 0, y = 0)
	Move(locate(src.x + x, src.y + y, z))

/obj/structure/overmap/ship/proc/get_heading()
	return

/obj/structure/overmap/ship/proc/get_speed()
	return

/obj/structure/overmap/ship/proc/get_eta()
	return

#undef SHIP_VIEW_RANGE
