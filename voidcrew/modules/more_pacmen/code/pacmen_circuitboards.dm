// Add your pacmen circuitboards here and list the req_componets and build path

/obj/item/circuitboard/machine/pacman/voidman
	name = "VOIDMAN-type Generator"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/port_gen/pacman/voidman
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 5
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/pacman/brainman
	name = "BRAINMAN-type Generator"
	greyscale_colors = CIRCUIT_COLOR_ENGINEERING
	build_path = /obj/machinery/power/port_gen/pacman/brainman
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/iron = 5
	)
	needs_anchored = FALSE
