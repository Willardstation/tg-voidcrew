/datum/map_template/shuttle/voidcrew
	name = "ships"
	prefix = "_maps/voidcrew/"
	port_id = "ship"

	///The prefix signifying the ship's faction
	var/faction_prefix = NEUTRAL_SHIP
	///Short name of the ship
	var/short_name
	///Cost of the ship
	var/cost = 1

	///List of job slots
	var/list/job_slots = list()

	/// Ensures we dont try to spawn an abstract subtype
	var/abstract = /datum/map_template/shuttle/voidcrew

/datum/map_template/shuttle/voidcrew/New()
	. = ..()
	name = "[faction_prefix] [name]"

/datum/map_template/shuttle/voidcrew/proc/assemble_job_slots()
	. = list()
	for(var/list/job_definition as anything in job_slots)
		var/job_name = job_definition["name"]
		var/is_officer = !!job_definition["officer"]
		var/initial_slots = job_definition["slots"]
		var/job_outfit = job_definition["outfit"]
		var/datum/job/job_slot = new /datum/job
		job_slot.title = job_name
		job_slot.officer = is_officer
		job_slot.outfit = text2path(job_outfit)
		if(faction_prefix != NEUTRAL_SHIP)
			job_slot.faction = faction_prefix
		job_slot.job_flags = JOB_EQUIP_RANK|JOB_CREW_MEMBER|JOB_ASSIGN_QUIRKS
		.[job_slot] = initial_slots
