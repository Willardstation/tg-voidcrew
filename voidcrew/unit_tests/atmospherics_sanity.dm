/**
 * We overwrite this because we do not expect all stations to be connected to eachother.
 */
/datum/unit_test/atmospherics_sanity/crawl_area(area/the_area)
	if(!(the_area.type in station_areas_remaining))
		return
	station_areas_remaining.Cut()
