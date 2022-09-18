//mix used by cloners
/datum/gas_mixture/immutable/cloner
	initial_temperature = T20C

/datum/gas_mixture/immutable/cloner/garbage_collect()
	..()
	ADD_GAS(/datum/gas/nitrogen, gases)
	gases[/datum/gas/nitrogen][MOLES] = MOLES_O2STANDARD + MOLES_N2STANDARD

/datum/gas_mixture/immutable/cloner/heat_capacity()
	return (MOLES_O2STANDARD + MOLES_N2STANDARD)*20 //specific heat of nitrogen is 20

//cloning techweb
/datum/techweb_node/cloning
	id = "cloning"
	display_name = "Organic Replication(cloning)"
	description = "We have the technology to MAKE him."
	prereq_ids = list("biotech", "adv_biotech", "genetics")
	design_ids = list("clonecontrol", "clonepod")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/obj/machinery/proc/is_operational()
	return !(machine_stat & (NOPOWER|BROKEN|MAINT))

/obj/machinery/CheckParts(list/parts_list)
	..()
	RefreshCloner()

/obj/machinery/proc/RefreshCloner() //Placeholder proc for machines that are built using frames.
	return

/datum/brain_trauma/proc/on_clone()
	if(clonable)
		return new type
