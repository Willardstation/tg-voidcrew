//Computer

/obj/item/circuitboard/computer/prototype_cloning
	name = "Prototype Cloning"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/prototype_cloning

/obj/item/circuitboard/computer/cloning
	name = "Cloning"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/computer/cloning
	var/list/records = list()

//Machinery

/obj/item/circuitboard/machine/clonepod
	name = "Clone Pod"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/clonepod
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/clonepod/experimental
	name = "Experimental Clone Pod"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/clonepod/experimental

//Machine Designs

/datum/design/board/clonecontrol
	name = "Computer Design (Cloning Machine Console)"
	desc = "Allows for the construction of circuit boards used to build a new Cloning Machine console."
	id = "clonecontrol"
	build_path = /obj/item/circuitboard/computer/cloning
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL
	category = RND_CATEGORY_MACHINE

/datum/design/board/clonepod
	name = "Machine Design (Clone Pod)"
	desc = "Allows for the construction of circuit boards used to build a Cloning Pod."
	id = "clonepod"
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL
	build_path = /obj/item/circuitboard/machine/clonepod
	category = RND_CATEGORY_MACHINE
