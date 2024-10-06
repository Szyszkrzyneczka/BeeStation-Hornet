
/obj/effect/timestop
	anchored = TRUE
	name = "chronofield"
	desc = "ZA WARUDO"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	pixel_x = -64
	pixel_y = -64
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/list/immune = list() // the one who creates the timestop is immune, which includes wizards and the dead slime you murdered to make this chronofield
	var/turf/target
	var/freezerange = 2
	var/duration = 140
	var/datum/proximity_monitor/advanced/timestop/chronofield
	alpha = 125
	var/check_anti_magic = FALSE
	var/check_holy = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/timestop)

/obj/effect/timestop/Initialize(mapload, radius, time, list/immune_atoms, start = TRUE)	//Immune atoms assoc list atom = TRUE
	. = ..()
	if(!isnull(time))
		duration = time
	if(!isnull(radius))
		freezerange = radius
	for(var/A in immune_atoms)
		immune[A] = TRUE
	for(var/mob/living/L in GLOB.player_list)
		if(locate(/datum/action/cooldown/spell/timestop) in L.actions) //People who can stop time are immune to its effects
			immune[L] = TRUE
	for(var/mob/living/simple_animal/hostile/holoparasite/G in GLOB.holoparasites)
		if(G?.summoner?.current)
			if(((locate(/datum/action/cooldown/spell/timestop) in G.actions) || (locate(/datum/action/cooldown/spell/timestop) in G.actions))) //It would only make sense that a person's stand would also be immune.
				immune[G] = TRUE
			if(((locate(/datum/action/cooldown/spell/timestop) in G.actions) || (locate(/datum/action/cooldown/spell/timestop) in G.actions))) //It would only make sense that a person's stand would also be immune.
				immune[G.summoner.current] = TRUE
				for(var/mob/living/simple_animal/hostile/holoparasite/GG in GLOB.holoparasites)
					if(G.summoner == GG.summoner)
						immune[GG] = TRUE
	if(start)
		timestop()

/obj/effect/timestop/Destroy()
	QDEL_NULL(chronofield)
	playsound(src, 'sound/magic/timeparadox2.ogg', 75, TRUE, frequency = -1) //reverse!
	return ..()

/obj/effect/timestop/proc/timestop()
	target = get_turf(src)
	playsound(src, 'sound/magic/timeparadox2.ogg', 75, 1, -1)
	chronofield = make_field(/datum/proximity_monitor/advanced/timestop, list("current_range" = freezerange, "host" = src, "immune" = immune, "check_anti_magic" = check_anti_magic, "check_holy" = check_holy))
	QDEL_IN(src, duration)

/obj/effect/timestop/wizard
	check_anti_magic = TRUE
	duration = 100

/datum/proximity_monitor/advanced/timestop
	name = "chronofield"
	setup_field_turfs = TRUE
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	requires_processing = TRUE
	var/list/immune = list()
	var/list/frozen_things = list()
	var/list/frozen_mobs = list() //cached separately for processing
	var/check_anti_magic = FALSE
	var/check_holy = FALSE

	var/static/list/global_frozen_atoms = list()

/datum/proximity_monitor/advanced/timestop/Destroy()
	unfreeze_all()
	return ..()

/datum/proximity_monitor/advanced/timestop/field_turf_crossed(atom/movable/AM)
	freeze_atom(AM)

/datum/proximity_monitor/advanced/timestop/proc/freeze_atom(atom/movable/A)
	if(immune[A] || global_frozen_atoms[A] || !istype(A))
		return FALSE
	var/frozen = TRUE
	if(isliving(A))
		freeze_mob(A)
	else if(istype(A, /obj/projectile))
		freeze_projectile(A)
	else if(istype(A, /obj/vehicle/sealed/mecha))
		freeze_mecha(A)
	else
		frozen = FALSE
	if(A.throwing)
		freeze_throwing(A)
		frozen = TRUE
	if(!frozen)
		return

	frozen_things[A] = A.move_resist
	A.move_resist = INFINITY
	global_frozen_atoms[A] = src
	into_the_negative_zone(A)
	RegisterSignal(A, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(unfreeze_atom))
	RegisterSignal(A, COMSIG_ITEM_PICKUP, PROC_REF(unfreeze_atom))

	return TRUE

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_all()
	for(var/i in frozen_things)
		unfreeze_atom(i)

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_atom(atom/movable/A)
	SIGNAL_HANDLER

	if(A.throwing)
		unfreeze_throwing(A)
	if(isliving(A))
		unfreeze_mob(A)
	else if(istype(A, /obj/projectile))
		unfreeze_projectile(A)
	else if(istype(A, /obj/vehicle/sealed/mecha))
		unfreeze_mecha(A)

	UnregisterSignal(A, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(A, COMSIG_ITEM_PICKUP)
	escape_the_negative_zone(A)
	A.move_resist = frozen_things[A]
	frozen_things -= A
	global_frozen_atoms -= A


/datum/proximity_monitor/advanced/timestop/proc/freeze_mecha(obj/vehicle/sealed/mecha/M)
	M.completely_disabled = TRUE

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_mecha(obj/vehicle/sealed/mecha/M)
	M.completely_disabled = FALSE


/datum/proximity_monitor/advanced/timestop/proc/freeze_throwing(atom/movable/AM)
	var/datum/thrownthing/T = AM.throwing
	T.paused = TRUE

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_throwing(atom/movable/AM)
	var/datum/thrownthing/T = AM.throwing
	if(T)
		T.paused = FALSE

/datum/proximity_monitor/advanced/timestop/process()
	for(var/i in frozen_mobs)
		var/mob/living/m = i
		m.Stun(20, ignore_canstun = TRUE)

/datum/proximity_monitor/advanced/timestop/setup_field_turf(turf/T)
	for(var/i in T.contents)
		freeze_atom(i)
	return ..()


/datum/proximity_monitor/advanced/timestop/proc/freeze_projectile(obj/projectile/P)
	P.paused = TRUE

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_projectile(obj/projectile/P)
	P.paused = FALSE

/datum/proximity_monitor/advanced/timestop/proc/freeze_mob(mob/living/L)
	frozen_mobs += L
	if(L.anti_magic_check(check_anti_magic, check_holy))
		immune += L
		return
	L.Stun(20, ignore_canstun = TRUE)
	SSmove_manager.stop_looping(src) //stops them mid pathing even if they're stunimmune //This is really dumb
	if(isanimal(L))
		var/mob/living/simple_animal/S = L
		S.toggle_ai(AI_OFF)
	if(ishostile(L))
		var/mob/living/simple_animal/hostile/H = L
		H.LoseTarget()

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_mob(mob/living/L)
	L.AdjustStun(-20, ignore_canstun = TRUE)
	frozen_mobs -= L
	if(isanimal(L))
		var/mob/living/simple_animal/S = L
		S.toggle_ai(initial(S.AIStatus))

//you don't look quite right, is something the matter?
/datum/proximity_monitor/advanced/timestop/proc/into_the_negative_zone(atom/A)
	A.add_atom_colour(list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0), TEMPORARY_COLOUR_PRIORITY)

//let's put some colour back into your cheeks
/datum/proximity_monitor/advanced/timestop/proc/escape_the_negative_zone(atom/A)
	A.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
