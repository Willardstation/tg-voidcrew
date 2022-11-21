#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)
/proc/create_and_destroy_voidcrew_ignores()
	. = list()
	// needs a fuel type or it fails to init
	. += /obj/machinery/power/shuttle_engine/ship/fueled
#endif
