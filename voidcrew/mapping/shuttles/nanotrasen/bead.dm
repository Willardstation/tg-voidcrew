/datum/map_template/shuttle/voidcrew/bead
	name = "Bead-class Corporate Frigate"
	suffix = "nano_bead"
	short_name = "Bead-Class"
	faction_prefix = NANOTRASEN_SHIP
	part_cost = 1

	job_slots = list(
		list(
			name = "Captain",
			officer = TRUE,
			outfit = /datum/outfit/job/captain,
			slots = 1,
		),
		list(
			name = "Station Engineer",
			outfit = /datum/outfit/job/engineer,
			slots = 1,
		),
		list(
			name = "Atmospheric Technician",
			outfit = /datum/outfit/job/atmos,
			slots = 1,
		),
		list(
			name = "Security Officer",
			outfit = /datum/outfit/job/security,
			slots = 3,
		),
	)
