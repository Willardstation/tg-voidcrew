/proc/grow_clone_from_record(obj/machinery/clonepod/pod, datum/data/record/clone_record, experimental)
	return pod.growclone(
		clone_record.fields["name"],
		clone_record.fields["UI"],
		clone_record.fields["SE"],
		clone_record.fields["mindref"],
		clone_record.fields["last_death"],
		clone_record.fields["mrace"],
		clone_record.fields["features"],
		clone_record.fields["factions"],
		clone_record.fields["quirks"],
		clone_record.fields["bank_account"],
		clone_record.fields["traumas"],
		clone_record.fields["body_only"],
		experimental,
	)
