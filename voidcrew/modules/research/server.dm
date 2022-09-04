#define RESEARCH_STOLEN_PER_THEFT 2500

/obj/machinery/ship_research_server
	desc = "A computer system that hosts a source R&D server drive, allowing research to be loaded and saved onto a disk, and shared within a vessel."
	///Installed source code files that hosts our research.
	var/obj/item/computer_hardware/hard_drive/cluster/hdd_theft/ship_disk/source_code_hdd

/obj/machinery/ship_research_server/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ATTACK_HAND_SECONDARY, .proc/on_attack_hand_secondary)

/obj/machinery/ship_research_server/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_ATTACK_HAND_SECONDARY)
	if(source_code_hdd)
		source_code_hdd.forceMove(loc)
		source_code_hdd = null
	return ..()

/obj/machinery/ship_research_server/attacked_by(obj/item/attacking_item, mob/living/user)
	if(istype(attacking_item, source_code_hdd))
		if(source_code_hdd)
			balloon_alert(user, "disk already installed!")
			return
		if(!attacking_item.forceMove(src))
			balloon_alert(user, "won't fit!")
			return
		source_code_hdd = attacking_item
		balloon_alert(user, "disk uploaded!")
		return

	if(istype(attacking_item, /obj/item/multitool))
		var/obj/item/multitool/multi = attacking_item
		multi.buffer = src
		to_chat(user, span_notice("[src] stored in [attacking_item]."))
		return TRUE
	return ..()


/**
 * ##attackhand_secondary
 *
 * Attempting to steal research nodes from the server by right clicking it.
 */
/obj/machinery/ship_research_server/proc/on_attack_hand_secondary(datum/source, mob/user)
	SIGNAL_HANDLER

	var/mob/living/living_user = user

	if(DOING_INTERACTION_WITH_TARGET(user, source))
		return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN
	if(istype(living_user) && !living_user.combat_mode)
		return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, .proc/steal_research, user)
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/obj/machinery/ship_research_server/proc/steal_research(mob/thief)
	if(!source_code_hdd.stored_research.can_afford(list(TECHWEB_POINT_TYPE_GENERIC = RESEARCH_STOLEN_PER_THEFT)))
		balloon_alert(thief, "not enough points to steal!")
		return
	if(!do_after(thief, (10 SECONDS), src))
		balloon_alert(thief, "interrupted!")
		return

	source_code_hdd.stored_research.remove_point_list(list(TECHWEB_POINT_TYPE_GENERIC = RESEARCH_STOLEN_PER_THEFT))
	var/obj/item/research_notes/the_dossier = new /obj/item/research_notes(loc, RESEARCH_STOLEN_PER_THEFT, "biology")

#undef RESEARCH_STOLEN_PER_THEFT
