/obj/item/organ/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	zone = BODY_ZONE_CHEST
	slot = "parasite_egg"

/obj/item/organ/body_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, "<span class='warning'>You found an unknown alien organism in [owner]'s [zone]!</span>")

/obj/item/organ/body_egg/New(loc)
	if(iscarbon(loc))
		src.Insert(loc)
	return ..()

/obj/item/organ/body_egg/Insert(mob/living/carbon/M, special = 0, pref_load = FALSE)
	..()
	ADD_TRAIT(owner, TRAIT_XENO_HOST, TRAIT_GENERIC)
	ADD_TRAIT(owner, TRAIT_XENO_IMMUNE, "xeno immune")
	START_PROCESSING(SSobj, src)
	owner.med_hud_set_status()
	INVOKE_ASYNC(src, PROC_REF(AddInfectionImages), owner)

/obj/item/organ/body_egg/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_XENO_HOST, TRAIT_GENERIC)
		REMOVE_TRAIT(owner, TRAIT_XENO_IMMUNE, "xeno immune")
		owner.med_hud_set_status()
		INVOKE_ASYNC(src, PROC_REF(RemoveInfectionImages), owner)
	..()

/obj/item/organ/body_egg/on_death()
	. = ..()
	if(!owner)
		return
	egg_process()

/obj/item/organ/body_egg/on_life()
	. = ..()
	egg_process()

/obj/item/organ/body_egg/proc/egg_process()
	return

/obj/item/organ/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/body_egg/proc/RemoveInfectionImages()
	return
