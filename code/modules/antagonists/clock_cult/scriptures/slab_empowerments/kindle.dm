//==================================//
// !            Kindle            ! //
//==================================//
/datum/clockcult/scripture/slab/kindle
	name = "Kindle"
	desc = "Stuns and mutes a target from a short range. Significantly less effective on Reebe."
	tip = "Stuns and mutes a target from a short range."
	button_icon_state = "Kindle"
	power_cost = 125
	invokation_time = 30
	invokation_text = list("Divinity, show them your light!")
	after_use_text = "Let the power flow through you!"
	slab_overlay = "volt"
	use_time = 150
	cogs_required = 1
	category = SPELLTYPE_SERVITUDE
	empowerment = "kindle"

//For the Kindle scripture; stuns and mutes a clicked_on non-servant.

/obj/item/clockwork/clockwork_slab/proc/kindle(mob/living/caller, mob/living/clicked_on)
	empowerment = null
	to_chat(caller, span_brass("You release the light of Ratvar!"))
	clockwork_say(caller, text2ratvar("Purge all untruths and honor Engine!"))
	if(isliving(clicked_on))
		var/mob/living/L = clicked_on
		if(is_servant_of_ratvar(L) || L.stat)
			return BULLET_ACT_HIT
		var/atom/O = L.anti_magic_check()
		playsound(L, 'sound/magic/fireball.ogg', 50, TRUE, frequency = 1.25)
		if(O)
			if(isitem(O))
				L.visible_message(span_warning("[L]'s eyes flare with dim light!"), \
				span_userdanger("Your [O] glows white-hot against you as it absorbs [src]'s power!"))
			else if(ismob(O))
				L.visible_message(span_warning("[L]'s eyes flare with dim light!"))
			playsound(L, 'sound/weapons/sear.ogg', 50, TRUE)
		else
			L.visible_message(span_warning("[L]'s eyes blaze with brilliant light!"), \
			span_userdanger("Your vision suddenly screams with white-hot light!"))
			L.Paralyze(5 SECONDS)
			L.flash_act(1, 1)
			if(iscultist(L))
				L.adjustFireLoss(15)
	return TRUE
