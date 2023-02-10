//objects

/obj/effect/countdown/clonepod
	name = "cloning pod countdown"
	color = "#18d100"
	text_size = 1

/obj/effect/countdown/clonepod/get_value()
	var/obj/machinery/clonepod/attacked_clone_pod = attached_to
	if(!istype(attacked_clone_pod))
		return
	if(attacked_clone_pod.occupant)
		var/completion = round(attacked_clone_pod.get_completion())
		return completion

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
/obj/item/disk/data
	var/list/fields = list()

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
	description = span_boldwarning("I recently saw my own corpse...")
	mood_change = -6

/datum/config_entry/flag/revival_cloning

//mix used by cloners
/datum/gas_mixture/immutable/cloner
	initial_temperature = T20C

/datum/gas_mixture/immutable/cloner/garbage_collect()
	..()
	ADD_GAS(/datum/gas/nitrogen, gases)
	gases[/datum/gas/nitrogen][MOLES] = MOLES_O2STANDARD + MOLES_N2STANDARD

/datum/gas_mixture/immutable/cloner/heat_capacity()
	return (MOLES_O2STANDARD + MOLES_N2STANDARD)*20 //specific heat of nitrogen is 20

//Called when something resists while this atom is its loc
/atom/movable/proc/container_resist(mob/living/user)
	return
