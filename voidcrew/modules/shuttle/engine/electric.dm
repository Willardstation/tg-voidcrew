/**
  * ### Ion Engines
  * Engines that convert electricity to thrust. Yes, I know that's not how it works, it needs a propellant, but this is a video game.
  */
/obj/machinery/power/shuttle_engine/ship/electric
	name = "ion thruster"
	desc = "A thruster that expels charged particles to generate thrust."
	icon_state = "burst"
	circuit = /obj/item/circuitboard/machine/engine/electric
	engine_power = 10

	icon_state_off = "burst_off"
	icon_state_closed = "burst"
	icon_state_open = "burst_open"

	///Amount, in kilojoules, needed for a full burn.
	var/power_per_burn = 50000

/obj/machinery/power/shuttle_engine/ship/electric/update_engine()
	. = ..()
	if(!.)
		return FALSE
	thruster_active = !!powernet
	return thruster_active

/obj/machinery/power/shuttle_engine/ship/electric/on_construction()
	. = ..()
	connect_to_network()

/obj/machinery/power/shuttle_engine/ship/electric/burn_engine(percentage = 100)
	. = ..()
	var/true_percentage = min(newavail() / power_per_burn, percentage / 100)
	add_delayedload(power_per_burn * true_percentage)
	return engine_power * true_percentage

/obj/machinery/power/shuttle_engine/ship/electric/return_fuel()
	if(length(powernet?.nodes) == 2)
		for(var/obj/machinery/power/smes/S in powernet.nodes)
			return S.charge
	return newavail()

/obj/machinery/power/shuttle_engine/ship/electric/return_fuel_cap()
	if(length(powernet?.nodes) == 2)
		for(var/obj/machinery/power/smes/S in powernet.nodes)
			return S.capacity
	return power_per_burn
