// This can probably be changed to use mind linker at some point
/datum/action/cooldown/spell/personality_commune
	name = "Personality Commune"
	desc = "Sends thoughts to your alternate consciousness."
	button_icon_state = "telepathy"
	cooldown_time = 0 SECONDS
	spell_requirements = NONE

	/// Fluff text shown when a message is sent to the pair
	var/fluff_text = ("<span class='boldnotice'>You hear an echoing voice in the back of your head...</span>")
	/// The message to send to the corresponding person on cast
	var/to_send

/datum/action/cooldown/spell/personality_commune/New(Target)
	. = ..()
	if(!istype(target, /datum/brain_trauma/severe/split_personality))
		stack_trace("[type] was created on a target that isn't a /datum/brain_trauma/severe/split_personality, this doesn't work.")
		qdel(src)

/datum/action/cooldown/spell/personality_commune/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/personality_commune/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/datum/brain_trauma/severe/split_personality/trauma = target
	if(!istype(trauma)) // hypothetically impossible but you never know
		return . | SPELL_CANCEL_CAST

	to_send = tgui_input_text(cast_on, "What would you like to tell your other self?", "Commune")
	if(QDELETED(src) || QDELETED(trauma)|| QDELETED(cast_on) || QDELETED(trauma.owner) || !can_cast_spell())
		return . | SPELL_CANCEL_CAST
	if(!to_send)
		reset_cooldown()
		return . | SPELL_CANCEL_CAST

	return TRUE

// Pillaged and adapted from telepathy code
/datum/action/cooldown/spell/personality_commune/cast(mob/living/cast_on)
	. = ..()
	var/datum/brain_trauma/severe/split_personality/trauma = target

	var/user_message = ("<span class='boldnotice'>You concentrate and send thoughts to your other self:</span>")
	var/user_message_body = ("<span class='notice'>[to_send]</span>")
	to_chat(cast_on, "[user_message] [user_message_body]")
	to_chat(trauma.owner, "[fluff_text] [user_message_body]")
	log_directed_talk(cast_on, trauma.owner, to_send, LOG_SAY, "[name]")
	for(var/dead_mob in GLOB.dead_mob_list)
		if(!isobserver(dead_mob))
			continue
		to_chat(dead_mob, "[FOLLOW_LINK(dead_mob, cast_on)] [("<span class='boldnotice'>[cast_on] [name]:</span>")] [("<span class='notice'>\"[to_send]\" to</span>")] [("<span class='name'>[trauma]</span>")]")
