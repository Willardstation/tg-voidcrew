/datum/controller/subsystem/processing/station
	can_fire = FALSE

/datum/controller/subsystem/processing/station/Initialize()
	//Initialize the station's announcer datum and nothing else
	announcer = new announcer()
	return SS_INIT_SUCCESS
