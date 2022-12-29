/datum/computer_file/program/nt_pay
	tgui_id = "NtosPayVoidcrew"

/datum/computer_file/program/nt_pay/ui_data(mob/user)
	var/list/data = ..()

	data["all_accounts"] = list()
	for(var/obj/item/card/id/cards as anything in current_user.bank_cards)
		data["all_accounts"] += cards.name

	return data
