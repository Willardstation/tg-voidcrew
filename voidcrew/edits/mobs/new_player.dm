/**
 * Latejoin menu
 */
/mob/dead/new_player/LateChoices()
	var/list/shuttle_choices = list(
		"Purchase ship" = "Purchase",
	)

	for(var/obj/structure/overmap/ship/active_ships as anything in SSovermap.simulated_ships)
		if(isnull(active_ships.shuttle))
			CRASH("[active_ships] has no shuttle???")
		if(length(active_ships.shuttle.spawn_points) <= 0)
			continue
		shuttle_choices["[active_ships.name]" - "([active_ships.source_template.short_name])"] = active_ships

	var/used_name = client.prefs.read_preference(/datum/preference/name/real_name)
	var/obj/structure/overmap/ship/selected_ship = shuttle_choices[tgui_input_list(src, "Select ship to spawn on.", "Welcome, [used_name].", shuttle_choices)]
	if(!selected_ship)
		return

	if(selected_ship == "Purchase")
		var/datum/map_template/shuttle/template = SSmapping.ship_purchase_list[tgui_input_list(src, "Please select ship to purchase!", "Welcome, [used_name].", SSmapping.ship_purchase_list)]
		if(!template)
			return LateChoices()

		to_chat(usr, span_danger("Your [initial(template.name)] is being prepared. Please be patient!"))
		var/obj/docking_port/mobile/voidcrew/target = SSshuttle.create_ship(template)
		if(!istype(target))
			to_chat(usr, span_danger("There was an error loading the ship. Please contact admins!"))
			return
		SSblackbox.record_feedback("tally", "ship_purchased", 1, initial(template.name)) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(!AttemptLateSpawn(target.current_ship.job_slots[1], target.current_ship)) //Try to spawn as the first listed job in the job slots (usually captain)
			to_chat(usr, span_danger("Ship spawned, but you were unable to be spawned. You can likely try to spawn in the ship through joining normally, but if not, please contact an admin."))
		return

	if(selected_ship.memo)
		var/memo_accept = tgui_alert(src, "Current ship memo: [selected_ship.memo]", "[selected_ship.name] Memo", list("OK", "Cancel"))
		if(memo_accept != "OK")
			return LateChoices() //Send them back to shuttle selection

	var/list/job_choices = list()
	for(var/datum/job/job as anything in selected_ship.job_slots)
		if(selected_ship.job_slots[job] < 1)
			continue
		job_choices["[job.title] ([selected_ship.job_slots[job]] positions)"] = job
	if(!job_choices.len)
		to_chat(usr, "<span class='danger'>There are no jobs available on this ship!</span>")
		return LateChoices() //Send them back to shuttle selection

	var/datum/job/selected_job = job_choices[tgui_input_list(src, "Select job.", "Welcome, [used_name].", job_choices)]
	if(!selected_job)
		return LateChoices() //Send them back to shuttle selection

	if(!SSticker?.IsRoundInProgress())
		to_chat(usr, "<span class='danger'>The round is either not ready, or has already finished...</span>")
		return

	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='notice'>There is an administrative lock on entering the game!</span>")
		return

	var/relevant_cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		relevant_cap = min(hpc, epc)
	else
		relevant_cap = max(hpc, epc)

	if(SSticker.queued_players.len && !(ckey(key) in GLOB.admin_datums))
		if((living_player_count() >= relevant_cap) || (src != SSticker.queued_players[1]))
			to_chat(usr, "<span class='warning'>Server is full.</span>")

	AttemptLateSpawn(selected_job, selected_ship)

/**
 * Latejoining
 */
/mob/dead/new_player/AttemptLateSpawn(rank, obj/structure/overmap/ship/joined_ship)
	if(isnull(joined_ship) || isnull(joined_ship.shuttle))
		stack_trace("Tried to spawn ([ckey]) into a null ship! Please report this on Github.")
		return FALSE
	var/datum/job/job = SSjob.GetJob(rank)
	var/error = IsJobUnavailable(rank, joined_ship)
	if(error != JOB_AVAILABLE)
		alert(src, get_job_unavailable_error_message(error, job))
		return FALSE
	if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
		alert(src, "An administrator has disabled late join spawning.")
		return FALSE

	//Removes a job slot
	joined_ship.job_slots[job]--

	//Remove the player from the join queue if he was in one and reset the timer
	SSticker.queued_players -= src
	SSticker.queue_delay = 4

	if(!SSjob.AssignRole(src, job, TRUE))
		tgui_alert(usr, "There was an unexpected error putting you into your requested job. If you cannot join with any job, you should contact an admin.")
		return FALSE

	var/atom/destination = pick(joined_ship.shuttle.spawn_points)
	if(!destination)
		CRASH("Failed to find a latejoin spawn point.")
	var/mob/living/character = create_character(destination)
	if(!character)
		CRASH("Failed to create a character for latejoin.")
	transfer_character()

	SSjob.EquipRank(character, job, character.client)
	job.after_latejoin_spawn(character)

	SSticker.minds += character.mind
	character.client.init_verbs() // init verbs for the late join
	var/mob/living/carbon/human/humanc
	if(ishuman(character))
		humanc = character //Let's retypecast the var to be human,

	if(humanc) //These procs all expect humans
		joined_ship.manifest_inject(humanc, job)
		GLOB.data_core.manifest_inject(humanc)
		if(SSshuttle.arrivals)
			SSshuttle.arrivals.QueueAnnounce(humanc, rank)
		else
			announce_arrival(humanc, rank)
		AddEmploymentContract(humanc)

		humanc.increment_scar_slot()
		humanc.load_persistent_scars()

		if(GLOB.curse_of_madness_triggered)
			give_madness(humanc, GLOB.curse_of_madness_triggered)

	GLOB.joined_player_list += character.ckey

	if((job.job_flags & JOB_ASSIGN_QUIRKS) && humanc && CONFIG_GET(flag/roundstart_traits))
		SSquirks.AssignQuirks(humanc, humanc.client)

	log_manifest(character.mind.key,character.mind,character,latejoin = TRUE)
	log_shuttle("[character.mind.key] / [character.mind.name] has joined [joined_ship.name] as [job.title]")

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CREWMEMBER_JOINED, character, rank)

/**
 * Job availability
 */
/mob/dead/new_player/IsJobUnavailable(rank, obj/structure/overmap/ship/joined_ship, latejoin = FALSE)
	var/datum/job/job = SSjob.GetJob(rank)
	if(!job)
		return JOB_UNAVAILABLE_GENERIC
	if(joined_ship.job_slots[job] <= 0)
		return JOB_UNAVAILABLE_SLOTFULL
	var/eligibility_check = SSjob.check_job_eligibility(src, job, "Mob IsJobUnavailable")
	if(eligibility_check != JOB_AVAILABLE)
		return eligibility_check
	if(latejoin && !job.special_check_latejoin(client))
		return JOB_UNAVAILABLE_GENERIC
	return JOB_AVAILABLE
