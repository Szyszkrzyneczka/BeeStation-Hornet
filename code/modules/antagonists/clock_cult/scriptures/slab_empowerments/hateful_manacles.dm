//==================================//
// !       Hateful Manacles       ! //
//==================================//
/datum/clockcult/scripture/slab/hateful_manacles
	name = "Hateful Manacles"
	desc = "Forms replicant manacles around a target's wrists that function like handcuffs, restraining the target."
	tip = "Handcuff a target at close range to subdue them for conversion or vitality extraction."
	button_icon_state = "Hateful Manacles"
	power_cost = 25
	invokation_time = 15
	invokation_text = list("Shackle the heretic...", "Break them in body and spirit!")
	slab_overlay = "hateful_manacles"
	use_time = 200
	cogs_required = 0
	category = SPELLTYPE_SERVITUDE
	empowerment = MANACLES

//For the Hateful Manacles scripture; applies replicant handcuffs to the clicked_on.

/datum/clockcult/scripture/slab/proc/hateful_manacles(mob/living/caller, atom/clicked_on)
	empowerment = null
	var/turf/T = caller.loc
	if(!isturf(T))
		return FALSE

	if(iscarbon(clicked_on) && clicked_on.Adjacent(caller))
		var/mob/living/carbon/L = clicked_on
		if(is_servant_of_ratvar(L))
			to_chat(caller, ("<span class='neovgre'>\"[L.p_theyre(TRUE)] a servant.\"</span>"))
			return FALSE
		else if(L.stat)
			to_chat(caller, ("<span class='neovgre'>\"There is use in shackling the dead, but for examples.\"</span>"))
			return FALSE
		else if (istype(L.handcuffed, /obj/item/restraints/handcuffs/clockwork))
			to_chat(caller, ("<span class='neovgre'>\"[L.p_theyre(TRUE)] already helpless, no?\"</span>"))
			return FALSE

		playsound(caller.loc, 'sound/weapons/handcuffs.ogg', 30, TRUE)
		caller.visible_message(("<span class='danger'>[caller] begins forming manacles around [L]'s wrists!</span>"), \
		("<span class='neovgre_small'>You begin shaping replicant alloy into manacles around [L]'s wrists...</span>"))
		to_chat(L, ("<span class='userdanger'>[caller] begins forming manacles around your wrists!</span>"))
		if(do_after(caller, 3 SECONDS, L))
			if(!(istype(L.handcuffed,/obj/item/restraints/handcuffs/clockwork)))
				L.set_handcuffed(new /obj/item/restraints/handcuffs/clockwork(L))
				L.update_handcuffed()
				to_chat(caller, ("<span class='neovgre_small'>You shackle [L].</span>"))
				log_combat(caller, L, "handcuffed")
		else
			to_chat(caller, ("<span class='warning'>You fail to shackle [L].</span>"))
	return TRUE

/obj/item/restraints/handcuffs/clockwork
	name = "replicant manacles"
	desc = "Heavy manacles made out of freezing-cold metal. It looks like brass, but feels much more solid."
	icon_state = "brass_manacles"
	item_state = "brass_manacles"
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/clockwork/dropped(mob/user)
	user.visible_message(("<span class='danger'>[user]'s [name] come apart at the seams!</span>"), \
	("<span class='userdanger'>Your [name] break apart as they're removed!</span>"))
	. = ..()
