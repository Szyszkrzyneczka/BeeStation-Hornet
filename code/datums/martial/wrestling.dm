/mob/living/carbon/human/proc/wrestling_help()
	set name = "Recall Teachings"
	set desc = "Remember how to wrestle."
	set category = "Wrestling"

	to_chat(usr, "<b><i>You flex your muscles and have a revelation...</i></b>")
	to_chat(usr, "<span class='notice'>Clinch</span>: Grab. Passively gives you a chance to immediately aggressively grab someone. Not always successful.")
	to_chat(usr, "<span class='notice'>Suplex</span>: Disarm someone you are grabbing. Suplexes your target to the floor. Greatly injures them and leaves both you and your target on the floor.")
	to_chat(usr, "<span class='notice'>Advanced grab</span>: Grab. Passively causes stamina damage when grabbing someone.")

/datum/martial_art/wrestling
	name = "Wrestling"
	id = MARTIALART_WRESTLING
	var/datum/action/slam/slam = new/datum/action/slam()
	var/datum/action/throw_wrassle/throw_wrassle = new/datum/action/throw_wrassle()
	var/datum/action/kick/kick = new/datum/action/kick()
	var/datum/action/strike/strike = new/datum/action/strike()
	var/datum/action/drop/drop = new/datum/action/drop()

/datum/martial_art/wrestling/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	switch(streak)
		if("drop")
			streak = ""
			drop(A,D)
			return 1
		if("strike")
			streak = ""
			strike(A,D)
			return 1
		if("kick")
			streak = ""
			kick(A,D)
			return 1
		if("throw")
			streak = ""
			throw_wrassle(A,D)
			return 1
		if("slam")
			streak = ""
			slam(A,D)
			return 1
	return 0

/datum/action/slam
	name = "Slam (Cinch) - Slam a grappled opponent into the floor."
	button_icon_state = "wrassle_slam"

/datum/action/slam/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't WRESTLE while you're OUT FOR THE COUNT.</span>")
		return
	owner.visible_message("<span class='danger'>[owner] prepares to BODY SLAM!</span>", "<b><i>Your next attack will be a BODY SLAM.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.streak = "slam"

/datum/action/throw_wrassle
	name = "Throw (Cinch) - Spin a cinched opponent around and throw them."
	button_icon_state = "wrassle_throw"

/datum/action/throw_wrassle/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't WRESTLE while you're OUT FOR THE COUNT.</span>")
		return
	owner.visible_message("<span class='danger'>[owner] prepares to THROW!</span>", "<b><i>Your next attack will be a THROW.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.streak = "throw"

/datum/action/kick
	name = "Kick - A powerful kick, sends people flying away from you. Also useful for escaping from bad situations."
	button_icon_state = "wrassle_kick"

/datum/action/kick/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't WRESTLE while you're OUT FOR THE COUNT.</span>")
		return
	owner.visible_message("<span class='danger'>[owner] prepares to KICK!</span>", "<b><i>Your next attack will be a KICK.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.streak = "kick"

/datum/action/strike
	name = "Strike - Hit a neaby opponent with a quick attack."
	button_icon_state = "wrassle_strike"

/datum/action/strike/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't WRESTLE while you're OUT FOR THE COUNT.</span>")
		return
	owner.visible_message("<span class='danger'>[owner] prepares to STRIKE!</span>", "<b><i>Your next attack will be a STRIKE.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.streak = "strike"

/datum/action/drop
	name = "Drop - Smash down onto an opponent."
	button_icon_state = "wrassle_drop"

/datum/action/drop/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't WRESTLE while you're OUT FOR THE COUNT.</span>")
		return
	owner.visible_message("<span class='danger'>[owner] prepares to LEG DROP!</span>", "<b><i>Your next attack will be a LEG DROP.</i></b>")
	var/mob/living/carbon/human/H = owner
	H.mind.martial_art.streak = "drop"

/datum/martial_art/wrestling/teach(mob/living/carbon/human/H,make_temporary=0)
	if(..())
		to_chat(H, "<span class = 'userdanger'>SNAP INTO A THIN TIM!</span>")
		to_chat(H, "<span class = 'danger'>Place your cursor over a move at the top of the screen to see what it does.</span>")
		drop.Grant(H)
		kick.Grant(H)
		slam.Grant(H)
		throw_wrassle.Grant(H)
		strike.Grant(H)

/datum/martial_art/wrestling/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class = 'userdanger'>You no longer feel that the tower of power is too sweet to be sour...</span>")
	drop.Remove(H)
	kick.Remove(H)
	slam.Remove(H)
	throw_wrassle.Remove(H)
	strike.Remove(H)

/datum/martial_art/wrestling/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "punched with wrestling", name)
	..()

/datum/martial_art/wrestling/proc/throw_wrassle(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	if(!A.pulling || A.pulling != D)
		to_chat(A, "You need to have [D] in a cinch!")
		return
	D.forceMove(A.loc)
	D.setDir(get_dir(D, A))

	D.Stun(80)
	D.visible_message("<span class='danger'><B>[A] starts spinning around with [D]!</B></span>", \
					"<span class='userdanger'>[A] starts spinning around with you!</span>")
	A.emote("scream")

	for (var/i in 1 to 20)
		var/delay = 5
		switch (i)
			if (18 to INFINITY)
				delay = 0.25
			if (15 to 17)
				delay = 0.5
			if (10 to 14)
				delay = 1
			if (6 to 9)
				delay = 2
			if (1 to 5)
				delay = 3

		if (A && D)

			if (get_dist(A, D) > 1)
				to_chat(A, "[D] is too far away!")
				return 0

			if (!isturf(A.loc) || !isturf(D.loc))
				to_chat(A, "You can't throw [D] from here!")
				return 0

			A.setDir(turn(A.dir, 90))
			var/turf/T = get_step(A, A.dir)
			var/turf/S = D.loc
			var/direction = get_dir(D, A)
			if ((S && isturf(S) && S.Exit(D, direction)) && (T && isturf(T) && T.Enter(A)))
				D.forceMove(T)
				D.setDir(direction)
		else
			return 0

		sleep(delay)

	if (A && D)
		// These are necessary because of the sleep call.

		if (get_dist(A, D) > 1)
			to_chat(A, "[D] is too far away!")
			return 0

		if (!isturf(A.loc) || !isturf(D.loc))
			to_chat(A, "You can't throw [D] from here!")
			return 0

		D.forceMove(A.loc) // Maybe this will help with the wallthrowing bug.

		D.visible_message("<span class='danger'><B>[A] throws [D]!</B></span>", \
						"<span class='userdanger'>[A] throws you!</span>")
		playsound(A.loc, "swing_hit", 50, 1)
		var/turf/T = get_edge_target_turf(A, A.dir)
		if (T && isturf(T))
			if (!D.stat)
				D.emote("scream")
			D.throw_at(T, 10, 4, A, TRUE, TRUE, callback = CALLBACK(D, TYPE_PROC_REF(/mob/living/carbon/human, Paralyze), 20))
	log_combat(A, D, "has thrown with wrestling", name)
	return 0

/datum/martial_art/wrestling/proc/FlipAnimation(mob/living/carbon/human/D)
	set waitfor = FALSE
	if (D)
		animate(D, transform = matrix(180, MATRIX_ROTATE), time = 1, loop = 0)
	sleep(15)
	if (D)
		animate(D, transform = null, time = 1, loop = 0)

/datum/martial_art/wrestling/proc/slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	if(!A.pulling || A.pulling != D)
		to_chat(A, "You need to have [D] in a cinch!")
		return
	D.forceMove(A.loc)
	A.setDir(get_dir(A, D))
	D.setDir(get_dir(D, A))

	D.visible_message("<span class='danger'><B>[A] lifts [D] up!</B></span>", \
					"<span class='userdanger'>[A] lifts you up!</span>")

	FlipAnimation()

	for (var/i in 1 to 3)
		if (A && D)
			A.pixel_y += 3
			D.pixel_y += 3
			A.setDir(turn(A.dir, 90))
			D.setDir(turn(D.dir, 90))

			switch (A.dir)
				if (NORTH)
					D.pixel_x = A.pixel_x
				if (SOUTH)
					D.pixel_x = A.pixel_x
				if (EAST)
					D.pixel_x = A.pixel_x - 8
				if (WEST)
					D.pixel_x = A.pixel_x + 8

			if (get_dist(A, D) > 1)
				to_chat(A, "[D] is too far away!")
				A.pixel_x = A.base_pixel_x
				A.pixel_y = A.base_pixel_y
				D.pixel_x = D.base_pixel_x
				D.pixel_y = D.base_pixel_y
				return 0

			if (!isturf(A.loc) || !isturf(D.loc))
				to_chat(A, "You can't slam [D] here!")
				A.pixel_x = A.base_pixel_x
				A.pixel_y = A.base_pixel_y
				D.pixel_x = D.base_pixel_x
				D.pixel_y = D.base_pixel_y
				return 0
		else
			if (A)
				A.pixel_x = A.base_pixel_x
				A.pixel_y = A.base_pixel_y
			if (D)
				D.pixel_x = D.base_pixel_x
				D.pixel_y = D.base_pixel_y
			return 0

		sleep(1)

	if (A && D)
		A.pixel_x = A.base_pixel_x
		A.pixel_y = A.base_pixel_y
		D.pixel_x = D.base_pixel_x
		D.pixel_y = D.base_pixel_y

		if (get_dist(A, D) > 1)
			to_chat(A, "[D] is too far away!")
			return 0

		if (!isturf(A.loc) || !isturf(D.loc))
			to_chat(A, "You can't slam [D] here!")
			return 0

		D.forceMove(A.loc)

		var/fluff = "body-slam"
		switch(pick(2,3))
			if (2)
				fluff = "turbo [fluff]"
			if (3)
				fluff = "atomic [fluff]"

		D.visible_message("<span class='danger'><B>[A] [fluff] [D]!</B></span>", \
						"<span class='userdanger'>[A] [fluff] you!</span>", null, COMBAT_MESSAGE_RANGE)
		playsound(A.loc, "swing_hit", 50, 1)
		if (!D.stat)
			D.emote("scream")
			D.Paralyze(40)

			switch(rand(1,3))
				if (2)
					D.adjustBruteLoss(rand(20,30))
				if (3)
					EX_ACT(D, EXPLODE_LIGHT)
				else
					D.adjustBruteLoss(rand(10,20))
		else
			EX_ACT(D, EXPLODE_LIGHT)

	else
		if (A)
			A.pixel_x = 0
			A.pixel_y = 0
		if (D)
			D.pixel_x = 0
			D.pixel_y = 0


	log_combat(A, D, "body-slammed", name)
	return 0

/datum/martial_art/wrestling/proc/CheckStrikeTurf(mob/living/carbon/human/A, turf/T)
	if (A && (T && isturf(T) && get_dist(A, T) <= 1))
		A.forceMove(T)

/datum/martial_art/wrestling/proc/strike(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	var/turf/T = get_turf(A)
	if (T && isturf(T) && D && isturf(D.loc))
		for (var/i in 1 to 4)
			A.setDir(turn(A.dir, 90))

		A.forceMove(D.loc)
		addtimer(CALLBACK(src, PROC_REF(CheckStrikeTurf), A, T), 4)

		D.visible_message("<span class='danger'><B>[A] headbutts [D]!</B></span>", \
						"<span class='userdanger'>[A] headbutts you!</span>", null, COMBAT_MESSAGE_RANGE)
		D.adjustBruteLoss(rand(10,20))
		playsound(A.loc, "swing_hit", 50, 1)
		D.Unconscious(20)
	log_combat(A, D, "headbutted", name)

/datum/martial_art/wrestling/proc/kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	A.emote("scream")
	A.emote("flip")
	A.setDir(turn(A.dir, 90))

	D.visible_message("<span class='danger'><B>[A] roundhouse-kicks [D]!</B></span>", \
					"<span class='userdanger'>[A] roundhouse-kicks you!</span>", null, COMBAT_MESSAGE_RANGE)
	playsound(A.loc, "swing_hit", 50, 1)
	D.adjustBruteLoss(rand(10,20))

	var/turf/T = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
	if (T && isturf(T))
		D.Paralyze(20)
		D.throw_at(T, 3, 2)
	log_combat(A, D, "roundhouse-kicked", name)

/datum/martial_art/wrestling/proc/drop(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D)
		return
	var/obj/surface = null
	var/turf/ST = null
	var/falling = 0

	for (var/obj/O in oview(1, A))
		if(O.density)
			if (O == D)
				continue
			if (O.opacity)
				continue
			else
				surface = O
				ST = get_turf(O)
				break

	if (surface && (ST && isturf(ST)))
		A.forceMove(ST)
		A.visible_message("<span class='danger'><B>[A] climbs onto [surface]!</B></span>", \
						"<span class='danger'><B>You climb onto [surface]!</B></span>")
		A.pixel_y = A.base_pixel_y + 10
		falling = 1
		sleep(10)

	if (A && D)
		// These are necessary because of the sleep call.

		if ((falling == 0 && get_dist(A, D) > 1) || (falling == 1 && get_dist(A, D) > 2)) // We climbed onto stuff.
			A.pixel_y = A.base_pixel_y
			if (falling == 1)
				A.visible_message("<span class='danger'><B>...and dives head-first into the ground, ouch!</B></span>", \
								"<span class='userdanger'>...and dive head-first into the ground, ouch!</span>")
				A.adjustBruteLoss(rand(10,20))
				A.Paralyze(60)
			to_chat(A, "[D] is too far away!")
			return 0

		if (!isturf(A.loc) || !isturf(D.loc))
			A.pixel_y = A.base_pixel_y
			to_chat(A, "You can't drop onto [D] from here!")
			return 0

		if(A)
			animate(A, transform = matrix(90, MATRIX_ROTATE), time = 1, loop = 0)
		sleep(10)
		if(A)
			animate(A, transform = null, time = 1, loop = 0)

		A.forceMove(D.loc)

		D.visible_message("<span class='danger'><B>[A] leg-drops [D]!</B></span>", \
									"<span class='userdanger'>[A] leg-drops you!</span>")
		playsound(A.loc, "swing_hit", 50, 1)
		A.emote("scream")

		if (falling == 1)
			if (prob(33) || D.stat)
				EX_ACT(D, EXPLODE_LIGHT)
			else
				D.adjustBruteLoss(rand(20,30))
		else
			D.adjustBruteLoss(rand(20,30))

		D.Paralyze(40)

		A.pixel_y = A.base_pixel_y

	else
		if (A)
			A.pixel_y = A.base_pixel_y
	log_combat(A, D, "leg-dropped", name)
	return

/datum/martial_art/wrestling/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	log_combat(A, D, "wrestling-disarmed", name)
	..()

/datum/martial_art/wrestling/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	if(A.pulling == D)
		return 1
	A.start_pulling(D)
	D.visible_message("<span class='danger'>[A] gets [D] in a cinch!</span>", \
								"<span class='userdanger'>[A] gets you in a cinch!</span>", null, COMBAT_MESSAGE_RANGE)
	D.Stun(rand(60,100))
	log_combat(A, D, "cinched", name)
	return 1

/obj/item/storage/belt/champion/wrestling
	name = "Wrestling Belt"
	var/datum/martial_art/wrestling/style = new

/obj/item/storage/belt/champion/wrestling/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_BELT)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/storage/belt/champion/wrestling/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_BELT) == src)
		style.remove(H)
