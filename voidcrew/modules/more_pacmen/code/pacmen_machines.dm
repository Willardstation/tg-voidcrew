// Add your pacmen here name, circuit path, icon, power_gen, max_sheets, sheet path and time_per_sheet

/obj/machinery/power/port_gen/pacman/voidman
	name = "\improper V.O.I.D.M.A.N.-type portable generator"
	circuit = /obj/item/circuitboard/machine/pacman/voidman
	icon_state = "portgen1_0"
	base_icon = "portgen1"
	power_gen = 50000
	max_sheets = 50
	sheet_path = /obj/item/stack/sheet/mineral/abductor
	time_per_sheet = 60

/obj/machinery/power/port_gen/pacman/brainman
	name = "\improper B.R.A.I.N.S...-type portable generator"
	circuit = /obj/item/circuitboard/machine/pacman/voidman
	icon_state = "portgen1_0"
	base_icon = "portgen1"
	power_gen = 9500
	max_sheets = 50
	sheet_path = /obj/item/organ/internal/brain
	time_per_sheet = 25
