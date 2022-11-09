/* //TG's engines
/obj/item/circuitboard/machine/engine
/obj/item/circuitboard/machine/engine/heater
/obj/item/circuitboard/machine/engine/propulsion
*/

/obj/item/circuitboard/machine/engine/electric
	name = "Ion Thruster (Machine Board)"
	build_path = /obj/machinery/power/shuttle_engine/electric
	req_components = list(
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/micro_laser = 3,
	)

/obj/item/circuitboard/machine/engine/oil
	name = "Oil Thruster (Machine Board)"
	build_path = /obj/machinery/power/shuttle_engine/liquid/oil
	req_components = list(
		/obj/item/reagent_containers/cup/beaker = 4,
		/obj/item/stock_parts/micro_laser = 2,
	)

/obj/item/circuitboard/machine/engine/void
	name = "Void Thruster (Machine Board)"
	build_path = /obj/machinery/power/shuttle_engine/void
	req_components = list(
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/micro_laser/quadultra = 1,
		/obj/item/stack/cable_coil = 5,
	)
	specific_parts = TRUE

/obj/item/circuitboard/machine/engine/plasma
	name = "Plasma Thruster (Machine Board)"
	build_path = /obj/machinery/power/shuttle_engine/fueled/plasma
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 5,
	)

/obj/item/circuitboard/machine/engine/expulsion
	name = "Expulsion Thruster (Machine Board)"
	build_path = /obj/machinery/power/shuttle_engine/fueled/expulsion
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2,
	)

/obj/item/circuitboard/computer/shuttle/helm
	name = "Shuttle Helm"
	build_path = /obj/machinery/computer/helm
