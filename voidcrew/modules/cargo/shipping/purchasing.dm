/obj/machinery/computer/voidcrew_cargo/proc/buy()
	SEND_SIGNAL(linked_port, COMSIG_SUPPLY_SHUTTLE_BUY)

	if(!checkout_list.len)
		return FALSE

	var/turf/open/pod_location = beacon.loc
	if(!pod_location)
		return FALSE

	var/obj/structure/closet/supplypod/podspawn/pod = podspawn(list(
		"target" = get_turf(user),
		"style" = STYLE_STANDARD,
		"spawn" = /obj/structure/shipping_container,
	))
	var/obj/structure/shipping_container/container_holder = locate() in pod.contents
	linked_port.shipping_containers += container_holder

	var/value = 0
	var/purchases = 0

	for(var/datum/supply_order/spawning_order as anything in checkout_list)
		var/price = spawning_order.pack.get_cost()
		if(spawning_order.applied_coupon)
			price *= (1 - spawning_order.applied_coupon.discount_pct_off)

		var/datum/bank_account/paying_for_this = linked_port.current_ship.ship_account

		if(spawning_order.paying_account)
			SSeconomy.track_purchase(paying_for_this, price, spawning_order.pack.name)
		value += spawning_order.pack.get_cost()
		checkout_list -= spawning_order
		QDEL_NULL(spawning_order.applied_coupon)

		spawning_order.generate(container_holder)

		SSblackbox.record_feedback("nested tally", "cargo_imports", 1, list("[spawning_order.pack.get_cost()]", "[spawning_order.pack.name]"))

		investigate_log("Order #[spawning_order.id] ([spawning_order.pack.name], placed by [key_name(spawning_order.orderer_ckey)]), paid by [paying_for_this.account_holder] has shipped.", INVESTIGATE_CARGO)
		if(spawning_order.pack.dangerous)
			message_admins("\A [spawning_order.pack.name] ordered by [ADMIN_LOOKUPFLW(spawning_order.orderer_ckey)], paid by [paying_for_this.account_holder] has shipped.")
		purchases++

	SSeconomy.import_total += value
	investigate_log("[purchases] orders in this shipment, worth [value] credits. [paying_for_this.account_balance] credits left.", INVESTIGATE_CARGO)

/obj/machinery/computer/voidcrew_cargo/proc/sell()
	var/datum/bank_account/account = linked_port.current_ship.ship_account
	var/presale_points = account.account_balance

	if(!GLOB.exports_list.len) // No exports list? Generate it!
		setupExports()

	var/datum/export_report/ex = new

	for(var/obj/structure/shipping_container/containers as anything in linked_port.shipping_containers)
		for(var/atom/movable/AM as anything in containers.contents)
			if(iscameramob(AM))
				continue
			if(AM.anchored)
				continue
			export_item_and_contents(AM, export_categories, dry_run = FALSE, external_report = ex)
		linked_port.shipping_containers += containers
		qdel(containers)

	if(ex.exported_atoms)
		ex.exported_atoms += "." //ugh

	for(var/datum/export/exports  as anything in ex.total_amount)
		if(!exports.total_printout(ex))
			continue
		account.adjust_money(ex.total_value[exports])

	SSeconomy.export_total += (account.account_balance - presale_points)
	investigate_log("contents sold for [account.account_balance - presale_points] credits. Contents: [ex.exported_atoms ? ex.exported_atoms.Join(",") + "." : "none."]", INVESTIGATE_CARGO)
