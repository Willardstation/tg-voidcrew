/obj/machinery/computer/cloning/ui_data(mob/user)
	var/list/data = list()

	var/list/lack_machine = list()
	if(isnull(scanner))
		lack_machine += "ERROR: No Scanner Detected!"
	if(!LAZYLEN(pods))
		lack_machine += "ERROR: No Pod Detected!"
	data["lacksMachine"] = lack_machine

	if(length(records))
		for(var/datum/data/record/R in records)
			var/list/record_entry = list()
			record_entry["name"] = "[R.fields["name"]]"
			record_entry["id"] = "[R.fields["id"]]"
			record_entry["damages"] = FALSE
			record_entry["UI"] = "[R.fields["UI"]]"
			record_entry["UE"] = "[R.fields["UE"]]"
			record_entry["blood_type"] = "[R.fields["blood_type"]]"
			record_entry["last_death"] = R.fields["last_death"]
			record_entry["body_only"] = R.fields["body_only"]
			data["records"] += list(record_entry)
	else
		data["records"] = list()
	if(diskette && diskette.fields)
		var/list/disk_data = list()
		disk_data["name"] = "[diskette.fields["name"]]"
		disk_data["id"] = "[diskette.fields["id"]]"
		disk_data["UI"] = "[diskette.fields["UI"]]"
		disk_data["UE"] = "[diskette.fields["UE"]]"
		disk_data["blood_type"] = "[diskette.fields["blood_type"]]"
		disk_data["last_death"] = diskette.fields["last_death"]
		disk_data["body_only"] = diskette.fields["body_only"]
		data["diskData"] = disk_data
	else
		data["diskData"] = list()
	data["hasAutoprocess"] = !!(scanner && HasEfficientPod() && scanner.scan_level >= AUTOCLONING_MINIMAL_LEVEL)
	data["autoprocess"] = autoprocess
	data["temp"] = temp
	var/build_temp
	var/mob/living/scanner_occupant = get_mob_or_brainmob(scanner?.occupant)
	if(scanner_occupant?.ckey != scantemp_ckey || scanner_occupant?.name != scantemp_name)
		build_temp = "Ready to Scan"
		scantemp_ckey = scanner_occupant?.ckey
		scantemp_name = scanner_occupant?.name
		scantemp = "[scanner_occupant] => [build_temp]"
	data["scanTemp"] = scantemp
	data["scannerLocked"] = scanner?.locked
	data["hasOccupant"] = scanner?.occupant
	data["recordsLength"] = "View Records ([length(records)])"
	return data

/obj/machinery/computer/cloning/ui_static_data(mob/user)
	var/list/data = list()
	data["experimental"] = experimental
	return data

/obj/machinery/computer/cloning/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_autoprocess")
			return toggle_autoprocess(usr)
		if("scan")
			scan_mob(usr, FALSE)
			return TRUE
		if("scan_body_only")
			scan_mob(usr, TRUE)
			return TRUE
		if("toggle_lock")
			return toggle_lock(usr)
		if("clone")
			clone_mob(usr, params["target"])
			return TRUE
		if("delrecord")
			delete_record(usr, params["target"])
			return TRUE
		if("save")
			save_record(usr, params["target"])
			return TRUE
		if("load")
			load_record(usr)
			return TRUE
		if("eject")
			return eject_disk(usr)

/obj/machinery/computer/cloning/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	updatemodules(TRUE)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CloningConsole", "Cloning System Control")
		ui.open()
