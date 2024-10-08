/datum/clockcult/scripture/slab/sentinelscompromise
	name = "Sentinel's Compromise"
	use_time = 80
	slab_overlay = "compromise"
	desc = "Heal any servant within view, but half of their damage healed will be given to you in the form of toxin damage."
	tip = "Use on any servant in trouble to heal their wounds."
	invokation_time = 10
	button_icon_state = "Sentinel's Compromise"
	category = SPELLTYPE_PRESERVATION
	cogs_required = 1
	power_cost = 80
	empowerment = "compromise"

//For the Sentinel's Compromise scripture; heals a clicked_on servant.

/obj/item/clockwork/clockwork_slab/proc/sentinels_compromise(mob/living/caller, atom/clicked_on)
	empowerment = null
	var/turf/T = caller.loc
	if(!isturf(T))
		return FALSE

	if(isliving(clicked_on) && (clicked_on in view(7, get_turf(caller))))
		var/mob/living/L = clicked_on
		if(!is_servant_of_ratvar(L))
			to_chat(caller, span_inathneq("\"[L] does not yet serve Ratvar.\""))
			return TRUE
		if(L.stat == DEAD)
			to_chat(caller, span_inathneq("\"[L.p_theyre(TRUE)] dead. [text2ratvar("Oh, child. To have your life cut short...")]\""))
			return TRUE

		var/brutedamage = L.getBruteLoss()
		var/burndamage = L.getFireLoss()
		var/oxydamage = L.getOxyLoss()
		var/totaldamage = brutedamage + burndamage + oxydamage
		if(!totaldamage && (!L.reagents || !L.reagents.has_reagent(/datum/reagent/water/holywater)))
			to_chat(caller, span_inathneq("\"[L] is unhurt and untainted.\""))
			return TRUE
		to_chat(caller, span_brass("You bathe [L == caller ? "yourself":"[L]"] in Inath-neq's power!"))
		var/clicked_onturf = get_turf(L)
		var/has_holy_water = (L.reagents && L.reagents.has_reagent(/datum/reagent/water/holywater))
		var/healseverity = max(round(totaldamage*0.05, 1), 1) //shows the general severity of the damage you just healed, 1 glow per 20
		for(var/i in 1 to healseverity)
			new /obj/effect/temp_visual/heal(clicked_onturf, "#1E8CE1")
		if(totaldamage)
			L.adjustBruteLoss(-brutedamage, TRUE, FALSE)
			L.adjustFireLoss(-burndamage, TRUE, FALSE)
			L.adjustOxyLoss(-oxydamage)
			L.adjustToxLoss(totaldamage * 0.5, TRUE, TRUE)
			clockwork_say(caller, text2ratvar("[has_holy_water ? "Heal tainted" : "Mend wounded"] flesh!"))
			log_combat(caller, L, "healed with Sentinel's Compromise")
			L.visible_message(span_warning("A blue light washes over [L], [has_holy_water ? "causing [L.p_them()] to briefly glow as it mends" : " mending"] [L.p_their()] bruises and burns!"), \
			"[span_heavy_brass("You feel Inath-neq's power healing your wounds[has_holy_water ? " and purging the darkness within you" : ""], but a deep nausea overcomes you!")]")
		else
			clockwork_say(caller, text2ratvar("Purge foul darkness!"))
			log_combat(caller, L, "purged of holy water with Sentinel's Compromise")
			L.visible_message(span_warning("A blue light washes over [L], causing [L.p_them()] to briefly glow!"), \
			"[span_heavy_brass("You feel Inath-neq's power purging the darkness within you!")]")
		playsound(clicked_onturf, 'sound/magic/staff_healing.ogg', 50, 1)

		if(has_holy_water)
			L.reagents.remove_reagent(/datum/reagent/water/holywater, 1000)

	return TRUE
