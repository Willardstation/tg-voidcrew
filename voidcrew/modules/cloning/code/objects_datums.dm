//objects

/obj/effect/countdown/clonepod
	name = "cloning pod countdown"
	color = "#18d100"
	text_size = 1

/obj/effect/countdown/clonepod/get_value()
	var/obj/machinery/clonepod/C = attached_to
	if(!istype(C))
		return
	else if(C.occupant)
		var/completion = round(C.get_completion())
		return completion

/obj/machinery/CheckParts(list/parts_list)
	..()
	RefreshCloner()

/obj/machinery/proc/RefreshCloner() //Got Confused added this
	return

/obj/machinery/proc/is_operational()
	return !(machine_stat & (NOPOWER|BROKEN|MAINT))

//datums

/datum/brain_trauma
	var/clonable = TRUE // will this transfer if the brain is cloned?

/datum/brain_trauma/proc/on_clone()
	if(clonable)
		return new type

/datum/brain_trauma/mild/phobia/on_clone()
	if(clonable)
		return new type(phobia_type)

/datum/brain_trauma/special/psychotic_brawling/bath_salts
	clonable = FALSE

/datum/brain_trauma/special/beepsky
	clonable = FALSE

/datum/mood_event/cloned_corpse
	description = "<span class='boldwarning'>I recently saw my own corpse...</span>\n"
	mood_change = -6

/datum/quirk/proc/clone_data() //return additional data that should be remembered by cloning
/datum/quirk/proc/on_clone(data) //create the quirk from clone data

//techweb
/datum/techweb_node/cloning
	id = "cloning"
	display_name = "Organic Replication(cloning)"
	description = "We have the technology to MAKE him."
	prereq_ids = list("biotech", "adv_biotech", "genetics")
	design_ids = list("clonecontrol", "clonepod")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

//mix used by cloners
/datum/gas_mixture/immutable/cloner
	initial_temperature = T20C

/datum/gas_mixture/immutable/cloner/garbage_collect()
	..()
	ADD_GAS(/datum/gas/nitrogen, gases)
	gases[/datum/gas/nitrogen][MOLES] = MOLES_O2STANDARD + MOLES_N2STANDARD

/datum/gas_mixture/immutable/cloner/heat_capacity()
	return (MOLES_O2STANDARD + MOLES_N2STANDARD)*20 //specific heat of nitrogen is 20
