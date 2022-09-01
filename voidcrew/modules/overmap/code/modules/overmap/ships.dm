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
