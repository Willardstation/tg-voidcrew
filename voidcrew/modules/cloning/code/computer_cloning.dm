#define AUTOCLONING_MINIMAL_LEVEL 3

/datum/data/record
	name = "record"
	var/list/fields = list()

/obj/machinery/computer/cloning
	name = "cloning console"
	desc = "Used to clone people and manage DNA."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/cloning
	req_access = list(ACCESS_GENETICS) //for modifying records
	light_color = LIGHT_COLOR_BLUE

	///List of all user records we have stored on the computer.
	var/list/datum/data/record/records = list()

	///The disk inserted into the console, holding cloning data for patients that we can read/write from/to.
	var/obj/item/disk/data/diskette
	///The linked machine that holds the bodies we can scan.
	var/obj/machinery/dna_scannernew/scanner
	///List of all cloning pods connected to us.
	var/list/obj/machinery/clonepod/pods
	///The cloning pod type this computer can sync to.
	var/clonepod_type = /obj/machinery/clonepod

	///The ckey of the person in the scanner.
	var/scantemp_ckey
	///The name of the person in the scanner.
	var/scantemp_name
	///Temporary message sent to the UI stating what the cloning process is at.
	var/temp = "Inactive"
	///Temporary scanning data to end errors to the UI.
	var/scantemp = "Inactive"

	//select which parts of the diskette to load
	var/include_se = FALSE //mutations
	var/include_ui = FALSE //appearance
	var/include_ue = FALSE //blood type, UE, and name

	///Boolean on whether we're actively scanning someone from the scanner currently.
	var/loading = FALSE
	///Boolean on whether the machine is set to autoprocess, which will allow process() to run.
	var/autoprocess = FALSE
	///Booleaon on whether this is an experimental cloning computer, which allows for different behavior.
	var/experimental = FALSE

/obj/machinery/computer/cloning/Initialize(mapload)
	. = ..()
	updatemodules(TRUE)

/obj/machinery/computer/cloning/Destroy()
	if(pods)
		for(var/P in pods)
			DetachCloner(P)
		pods = null
	return ..()

/obj/machinery/computer/cloning/AltClick(mob/user)
	. = ..()
	eject_disk(user)

/obj/machinery/computer/cloning/process()
	if(!(scanner && LAZYLEN(pods) && autoprocess))
		return

	if(scanner.occupant && scanner.scan_level > 2)
		scan_occupant(scanner.occupant)

	for(var/datum/data/record/R as anything in records)
		var/obj/machinery/clonepod/pod = GetAvailablePod(R.fields["mindref"], efficient_required = TRUE)

		if(!pod)
			return

		if(pod.occupant)
			break

		var/result = grow_clone_from_record(pod, R, experimental)
		if(result & CLONING_SUCCESS)
			temp = "[R.fields["name"]] => Cloning cycle in progress..."
			log_combat("Cloning of [key_name(R.fields["mindref"])] automatically started via autoprocess - [src] at [AREACOORD(src)]. Pod: [pod] at [AREACOORD(pod)].")
			SStgui.update_uis(src)
		if(result & CLONING_DELETE_RECORD)
			records -= R

/obj/machinery/computer/cloning/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/disk/data)) //INSERT SOME DISKETTES
		if(diskette)
			eject_disk(user)
		if(!user.transferItemToLoc(weapon, src))
			return
		diskette = weapon
		to_chat(user, span_notice("You insert [weapon].</span>"))
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		return
	return ..()

/obj/machinery/computer/cloning/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!istype(tool.buffer, /obj/machinery/clonepod))
		tool.buffer = src
		to_chat(user, "<font color = #666633>-% Successfully stored [REF(tool.buffer)] [tool.buffer.name] in buffer %-</font color>")
		return TRUE
	if(get_area(tool.buffer) != get_area(src))
		to_chat(user, "<font color = #666633>-% Cannot link machines across power zones.</font color>")
		return TRUE
	to_chat(user, "<font color = #666633>-% Successfully linked [tool.buffer] with [src] %-</font color>")
	AttachCloner(tool.buffer)
	return TRUE

/obj/machinery/computer/cloning/proc/GetAvailablePod(mind, efficient_required = FALSE)
	if(!length(pods))
		return null
	for(var/obj/machinery/clonepod/pod as anything in pods)
		if(pod.occupant && pod.clonemind == mind)
			continue
		if(!pod.is_operational)
			continue
		if(!pod.occupant)
			continue
		if(pod.mess)
			continue
		if(efficient_required && pod.efficiency <= 5)
			continue
		return pod
	return null

/obj/machinery/computer/cloning/proc/HasEfficientPod()
	if(!length(pods))
		return FALSE
	for(var/obj/machinery/clonepod/pod as anything in pods)
		if(pod.is_operational && pod.efficiency > 5)
			return TRUE

/obj/machinery/computer/cloning/proc/updatemodules(findfirstcloner)
	if(findfirstcloner && !LAZYLEN(pods))
		sync_cloner()
	if(!autoprocess)
		STOP_PROCESSING(SSmachines, src)
	else
		START_PROCESSING(SSmachines, src)

/obj/machinery/computer/cloning/proc/findscanner()
	for(var/direction in GLOB.cardinals)
		var/obj/machinery/dna_scannernew/scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, direction))
		// If found and operational, return the scanner
		if (scannerf && scannerf.is_operational)
			return scannerf
	// If no scanner was found, it will return null
	return null

/obj/machinery/computer/cloning/proc/sync_cloner()
	for(var/direction in GLOB.cardinals)
		var/obj/machinery/clonepod/podf = locate(clonepod_type, get_step(src, direction))
		if(podf && podf.is_operational)
			return AttachCloner(podf)

/obj/machinery/computer/cloning/proc/AttachCloner(obj/machinery/clonepod/pod)
	if(pod.connected)
		pod.connected.DetachCloner(pod)
	pod.connected = src
	LAZYADD(pods, pod)

/obj/machinery/computer/cloning/proc/DetachCloner(obj/machinery/clonepod/pod)
	pod.connected = null
	LAZYREMOVE(pods, pod)

/obj/machinery/computer/cloning/proc/eject_disk(mob/user)
	if(diskette)
		scantemp = "Disk Ejected"
		diskette.forceMove(drop_location())
		user.put_in_active_hand(diskette)
		diskette = null
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		return TRUE

/obj/machinery/computer/cloning/proc/save_record(mob/user, target)
	var/datum/data/record/GRAB = null
	for(var/datum/data/record/record as anything in records)
		if(record.fields["id"] == target)
			GRAB = record
			break
	if(!GRAB || !GRAB.fields)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		scantemp = "Failed saving to disk: Data Corruption"
		return FALSE
	if(!diskette || diskette.read_only)
		scantemp = !diskette ? "Failed saving to disk: No disk." : "Failed saving to disk: Disk refuses override attempt."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	diskette.fields = GRAB.fields.Copy()
	diskette.name = "data disk - '[src.diskette.fields["name"]]'"
	scantemp = "Saved to disk successfully."
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	return TRUE

/obj/machinery/computer/cloning/proc/delete_record(mob/user, target)
	var/datum/data/record/GRAB = null
	for(var/datum/data/record/record as anything in records)
		if(record.fields["id"] == target)
			GRAB = record
			break
	if(!GRAB)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		scantemp = "Cannot delete: Data Corrupted."
		return FALSE
	var/mob/living/L = user
	var/obj/item/card/id/C = L.get_idcard(hand_first = TRUE)
	if(istype(C) || istype(C, /obj/item/modular_computer/pda))
		if(check_access(C))
			scantemp = "[GRAB.fields["name"]] => Record deleted."
			records.Remove(GRAB)
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
			var/obj/item/circuitboard/computer/cloning/board = circuit
			board.records = records
			return TRUE
	scantemp = "Cannot delete: Access Denied."
	playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

/obj/machinery/computer/cloning/proc/load_record(mob/user)
	if(!diskette || !istype(diskette.fields) || !diskette.fields["name"] || !diskette.fields)
		scantemp = "Failed loading: Load error."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	for(var/datum/data/record/R as anything in records)
		if(R.fields["id"] == diskette.fields["id"])
			scantemp = "Failed loading: Data already exists!"
			return FALSE
	var/datum/data/record/R = new(src)
	for(var/each in diskette.fields)
		R.fields[each] = diskette.fields[each]

	records += R
	scantemp = "Loaded into internal storage successfully."
	var/obj/item/circuitboard/computer/cloning/board = circuit
	board.records = records
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	return TRUE

/obj/machinery/computer/cloning/proc/clone_mob(mob/user, target)
	var/datum/data/record/C = find_record("id", target, records)
	//Look for that player! They better be dead!
	if(!C)
		temp = "Failed to clone: Data corrupted."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	var/obj/machinery/clonepod/pod = GetAvailablePod()
	//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
	if(!LAZYLEN(pods))
		temp = "Error: No Clonepods detected."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if(!pod)
		temp = "Error: No Clonepods available."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if(!CONFIG_GET(flag/revival_cloning))
		temp = "Error: Unable to initiate cloning cycle."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if(pod.occupant)
		temp = "Warning: Cloning cycle already in progress."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	switch(pod.growclone(
		C.fields["name"],
		C.fields["UI"],
		C.fields["SE"],
		C.fields["mindref"],
		C.fields["last_death"],
		C.fields["mrace"],
		C.fields["features"],
		C.fields["factions"],
		C.fields["quirks"],
		C.fields["bank_account"],
		C.fields["traumas"],
		C.fields["body_only"],
		experimental,
	))
		if(CLONING_SUCCESS)
			temp = "Notice: [C.fields["name"]] => Cloning cycle in progress..."
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
			if(!C.fields["body_only"])
				records.Remove(C)
			return TRUE
		if(CLONING_SUCCESS_EXPERIMENTAL)
			temp = "Notice: [C.fields["name"]] => Experimental cloning cycle in progress..."
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
			return TRUE
		if(ERROR_NO_SYNTHFLESH)
			temp = "Error [ERROR_NO_SYNTHFLESH]: Out of synthflesh."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_PANEL_OPENED)
			temp = "Error [ERROR_PANEL_OPENED]: Panel opened."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_MESS_OR_ATTEMPTING)
			temp = "Error [ERROR_MESS_OR_ATTEMPTING]: Pod is already occupied."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_MISSING_EXPERIMENTAL_POD)
			temp = "Error [ERROR_MISSING_EXPERIMENTAL_POD]: Experimental pod is not detected."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_NOT_MIND)
			temp = "Error [ERROR_NOT_MIND]: [C.fields["name"]]'s lack of their mind."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_PRESAVED_CLONE)
			temp = "Error [ERROR_PRESAVED_CLONE]: [C.fields["name"]]'s clone record is presaved."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_OUTDATED_CLONE)
			temp = "Error [ERROR_OUTDATED_CLONE]: [C.fields["name"]]'s clone record is outdated."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_ALREADY_ALIVE)
			temp = "Error [ERROR_ALREADY_ALIVE]: [C.fields["name"]] already alive."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_COMMITED_SUICIDE)
			temp = "Error [ERROR_COMMITED_SUICIDE]: [C.fields["name"]] commited a suicide."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_SOUL_DEPARTED)
			temp = "Error [ERROR_SOUL_DEPARTED]: [C.fields["name"]]'s soul had departed."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_SUICIDED_BODY)
			temp = "Error [ERROR_SUICIDED_BODY]: Failed to capture [C.fields["name"]]'s mind from a suicided body."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		if(ERROR_UNCLONABLE)
			temp = "Error [ERROR_UNCLONABLE]: [C.fields["name"]] is not clonable."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		else
			temp = "Error unknown => Initialisation failure."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

/obj/machinery/computer/cloning/proc/toggle_lock(mob/user)
	if(!scanner.is_operational)
		return
	if(!scanner.locked && !scanner.occupant) //I figured out that if you're fast enough, you can lock an open pod
		return
	scanner.locked = !scanner.locked
	playsound(src, scanner.locked ? 'sound/machines/terminal_prompt_deny.ogg' : 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	return TRUE

/obj/machinery/computer/cloning/proc/scan_mob(mob/user, body_only = FALSE)
	if(!scanner.is_operational || !scanner.occupant)
		return
	scantemp = "[scantemp_name] => Scanning..."
	loading = TRUE
	playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
	say("Initiating scan...")
	var/prev_locked = scanner.locked
	scanner.locked = TRUE
	addtimer(CALLBACK(src, PROC_REF(finish_scan), scanner.occupant, user, prev_locked, body_only), 2 SECONDS)
	return TRUE

/obj/machinery/computer/cloning/proc/toggle_autoprocess(mob/user)
	if(!scanner || !HasEfficientPod() || scanner.scan_level < AUTOCLONING_MINIMAL_LEVEL)
		return FALSE
	autoprocess = !autoprocess
	if(autoprocess)
		START_PROCESSING(SSmachines, src)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	else
		STOP_PROCESSING(SSmachines, src)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	return TRUE

/obj/machinery/computer/cloning/proc/finish_scan(mob/living/L, mob/user, prev_locked, body_only)
	if(!scanner || !L)
		return
	src.add_fingerprint(usr)
	scan_occupant(L, user, body_only)

	loading = FALSE
	scanner.locked = prev_locked
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	SStgui.update_uis(src) // Immediate since it's not spammable

//Used by consoles without records
/obj/machinery/computer/cloning/proc/clone_occupant(occupant, mob/user)
	var/mob/living/mob_occupant = get_mob_or_brainmob(occupant)
	var/datum/dna/dna
	if(ishuman(mob_occupant))
		var/mob/living/carbon/C = mob_occupant
		dna = C.has_dna()
	if(isbrain(mob_occupant))
		var/mob/living/brain/B = mob_occupant
		dna = B.stored_dna
	if(!can_scan(dna, mob_occupant))
		return
	var/clone_species
	if(dna.species)
		clone_species = dna.species
	else
		scantemp = "Unauthorized clone process detected => Interrupted."
		return //no dna info for species? you're not allowed to clone them. Don't harass xeno, don't try xeno farm.
	var/obj/machinery/clonepod/pod = GetAvailablePod()
	//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
	if(!LAZYLEN(pods))
		temp = "No Clonepods detected."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else if(!pod)
		temp = "No Clonepods available."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else if(pod.occupant)
		temp = "Cloning cycle already in progress."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else
		pod.growclone(mob_occupant.real_name, dna.unique_identity, dna.mutation_index, null, null, clone_species, dna.blood_type, mob_occupant.faction)
		temp = "[mob_occupant.real_name] => Cloning data sent to pod."
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		log_combat("[user ? key_name(user) : "Unknown"] cloned [key_name(mob_occupant)] with [src] at [AREACOORD(src)].")

/obj/machinery/computer/cloning/proc/can_scan(datum/dna/dna, mob/living/mob_occupant, datum/bank_account/account, body_only)
	if(!istype(dna))
		scantemp = "Unable to locate valid genetic data."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return FALSE
	if(NO_DNA_COPY in dna.species.species_traits)
		scantemp = "The DNA of this lifeform could not be read due to an unknown error!"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return FALSE
	if((HAS_TRAIT(mob_occupant, TRAIT_HUSK)) && (src.scanner.scan_level < 2))
		scantemp = "Subject's body is too damaged to scan properly."
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return FALSE
	if(HAS_TRAIT(mob_occupant, TRAIT_BADDNA))
		scantemp = "Subject's DNA is damaged beyond any hope of recovery."
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return FALSE
	if(!experimental)
		if(!body_only && (mob_occupant.suiciding))
			scantemp = "Subject's brain is not responding to scanning stimuli."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			return FALSE
		if(!body_only && isnull(mob_occupant.mind))
			scantemp = "Mental interface failure."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			return FALSE
		if(!body_only && SSeconomy.full_ancap)
			if(!account)
				scantemp = "Subject is either missing an ID card with a bank account on it, or does not have an account to begin with. Please ensure the ID card is on the body before attempting to scan."
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				return FALSE
	return TRUE

/obj/machinery/computer/cloning/proc/scan_occupant(occupant, mob/user, body_only)
	var/mob/living/mob_occupant = get_mob_or_brainmob(occupant)
	var/datum/dna/dna
	var/datum/bank_account/has_bank_account

	// Do not use unless you know what they are.
	var/mob/living/carbon/C = mob_occupant
	var/mob/living/brain/B = mob_occupant

	if(ishuman(mob_occupant))
		dna = C.has_dna()
		var/obj/item/card/id/I = C.get_idcard(TRUE)
		if(I)
			has_bank_account = I.registered_account
	if(isbrain(mob_occupant))
		dna = B.stored_dna

	if(!can_scan(dna, mob_occupant, has_bank_account, body_only))
		return

	var/datum/data/record/R = new()
	if(dna.species)
		// We store the instance rather than the path, because some
		// species (abductors, slimepeople) store state in their
		// species datums
		R.fields["mrace"] = dna.species
	else
		return //no dna info for species? you're not allowed to clone them. Don't harass xeno, don't try xeno farm.
		//Note: if you want to clone unusual species, you need to check 'carbon/human' rather than 'dna.species'

	R.fields["name"] = mob_occupant.real_name
	if(experimental) //even if you have the same identity, this will give you different id based on your mind. body_only gets β at their id.
		R.fields["id"] =  copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.real_name), 3, 10)+"β+" //beta plus
	else if(body_only)
		R.fields["id"] = copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.real_name), 3, 10)+"β" //beta
	else
		R.fields["id"] = copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.real_name), 3, 7)+copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.mind), -4)
	R.fields["UE"] = dna.unique_enzymes
	R.fields["UI"] = dna.unique_identity
	R.fields["SE"] = dna.mutation_index
	R.fields["blood_type"] = dna.blood_type
	R.fields["features"] = dna.features
	R.fields["factions"] = mob_occupant.faction
	R.fields["quirks"] = list()
	R.fields["traumas"] = list()

	if(isbrain(mob_occupant)) //We'll detect the brain first because trauma is from the brain, not from the body.
		R.fields["traumas"] = B.get_traumas()
	else if(ishuman(mob_occupant))
		R.fields["traumas"] = C.get_traumas()
	//Traumas will be overriden if the brain transplant is made because '/obj/item/organ/brain/Insert' does that thing. This should be done since we want a monkey yelling to people with 'God voice syndrome'

	R.fields["bank_account"] = has_bank_account
	if(!experimental)
		R.fields["mindref"] = "[REF(mob_occupant.mind)]"
		R.fields["last_death"] = (mob_occupant.stat == DEAD && mob_occupant.mind) ? mob_occupant.mind.last_death : -1
		R.fields["body_only"] = body_only
	else
		R.fields["last_death"] = 0
		R.fields["body_only"] = 0

	var/datum/data/record/old_record = find_record("id", R.fields["id"], records)
	if(old_record)
		records -= old_record
		scantemp = "Record updated."
	else
		scantemp = "Subject successfully scanned."
	records += R

	if(!experimental)
		log_combat("[user ? key_name(user) : "Autoprocess"] added the [body_only ? "body-only " : ""]record of [key_name(mob_occupant)] to [src] at [AREACOORD(src)].")
	else
		log_combat("[user ? key_name(user) : "Autoprocess"] added the experimental record of [key_name(mob_occupant)] to [src] at [AREACOORD(src)].")
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50)

//Prototype cloning console, much more rudimental and lacks modern functions such as saving records, autocloning, or safety checks.
/obj/machinery/computer/cloning/prototype
	name = "prototype cloning console"
	desc = "Used to operate an experimental cloner."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/prototype_cloning
	clonepod_type = /obj/machinery/clonepod/experimental
	experimental = TRUE
