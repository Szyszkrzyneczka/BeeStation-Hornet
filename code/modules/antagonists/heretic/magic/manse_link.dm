/datum/action/cooldown/spell/pointed/manse_link
	name = "Manse Link"
	desc = "This spell allows you to pierce through reality and connect minds to one another \
		via your Mansus Link. All minds connected to your Mansus Link will be able to communicate discreetly across great distances."
	background_icon_state = "bg_heretic"
	button_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "PI'RC' TH' M'ND."
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	cast_range = 7

	/// The time it takes to link to a mob.
	var/link_time = 6 SECONDS

/datum/action/cooldown/spell/pointed/manse_link/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)

/datum/action/cooldown/spell/pointed/manse_link/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return isliving(cast_on)

/datum/action/cooldown/spell/pointed/manse_link/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	// If we fail to link, cancel the spell.
	if(!do_linking(cast_on))
		return . | SPELL_CANCEL_CAST

/**
* The actual process of linking [linkee] to our network.
*/
/datum/action/cooldown/spell/pointed/manse_link/proc/do_linking(mob/living/linkee)
	var/datum/component/mind_linker/linker = target
	if(linkee.stat == DEAD)
		to_chat(owner, span_warning("They're dead!"))
		return FALSE
	to_chat(owner, span_notice("You begin linking [linkee]'s mind to yours..."))
	to_chat(linkee, span_warning("You feel your mind being pulled somewhere... connected... intertwined with the very fabric of reality..."))
	if(!do_after(owner, link_time, linkee))
		to_chat(owner, span_warning("You fail to link to [linkee]'s mind."))
		to_chat(linkee, span_warning("The foreign presence leaves your mind."))
		return FALSE
	if(QDELETED(src) || QDELETED(owner) || QDELETED(linkee))
		return FALSE
	if(!linker.link_mob(linkee))
		to_chat(owner, span_warning("You can't seem to link to [linkee]'s mind."))
		to_chat(linkee, span_warning("The foreign presence leaves your mind."))
		return FALSE
	return TRUE

/datum/action/innate/mansus_speech
	name = "Mansus Link"
	desc = "Send a psychic message to everyone connected to your Mansus Net."
	button_icon_state = "link_speech"
	icon_icon = 'icons/hud/actions/actions_slime.dmi'
	background_icon_state = "bg_ecult"
	/// The raw prophet that hosts our link.
	var/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/originator

/datum/action/innate/mansus_speech/New(originator)
	. = ..()
	src.originator = originator

/datum/action/innate/mansus_speech/Activate()
	var/mob/living/living_owner = owner
	if(!originator?.linked_mobs[living_owner])
		CRASH("Uh oh, a Mansus Link ([type]) got somehow called Activate() [isnull(originator) ? "without an originator Raw Prophet" : "without being in the originator's linked_mobs list"].")

	var/message = sanitize(input(living_owner, "Enter your message", "Telepathy from the Mansus"))
	if(!message)
		return

	if(QDELETED(living_owner))
		return

	if(!originator?.linked_mobs[living_owner])
		to_chat(living_owner, "<span class='warning'>The link seems to have been severed...</span>")
		Remove(living_owner)
		return

	var/msg = "<i><font color=#568b00>\[Mansus Link\] <b>[living_owner]:</b> [message]</font></i>"
	log_directed_talk(living_owner, originator, msg, LOG_SAY, "Mansus Link")
	to_chat(originator.linked_mobs, msg)

	for(var/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, living_owner)
		to_chat(dead_mob, "[link] [msg]")
