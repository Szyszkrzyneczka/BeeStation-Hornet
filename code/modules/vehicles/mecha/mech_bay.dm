/turf/open/floor/mech_bay_recharge_floor
	name = "mech bay recharge station" //Recharging turfs
	desc = "Parking a mech on this station will recharge its internal power cell."
	icon = 'icons/turf/floors.dmi'
	icon_state = "recharge_floor"
	//set in stone to check the west turf for recharge port

/turf/open/floor/mech_bay_recharge_floor/break_tile()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/mech_bay_recharge_floor/airless
	icon_state = "recharge_floor_asteroid"
	initial_gas_mix = AIRLESS_ATMOS

/obj/machinery/mech_bay_recharge_port
	name = "mech bay power port"
	desc = "This port recharges a mech's internal power cell."
	density = TRUE
	dir = EAST
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_port"
	circuit = /obj/item/circuitboard/machine/mech_recharger
	var/obj/vehicle/sealed/mecha/recharging_mech
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	///Power unit per second to charge by, modified by /RefreshParts()
	var/recharge_power = 25
	///turf that will be checked when a mech wants to charge. directly one turf in the direction it is facing
	var/turf/recharging_turf
	var/on = FALSE


/obj/machinery/mech_bay_recharge_port/Initialize(mapload)
	. = ..()
	recharging_turf = get_step(loc, dir)

/obj/machinery/mech_bay_recharge_port/Destroy()
	if (recharge_console && recharge_console.recharge_port == src)
		recharge_console.recharge_port = null
	return ..()

/obj/machinery/mech_bay_recharge_port/setDir(new_dir)
	. = ..()
	recharging_turf = get_step(loc, dir)

/obj/machinery/mech_bay_recharge_port/RefreshParts()
	var/MC
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		MC += C.rating
	recharge_power = MC * 12.5

/obj/machinery/mech_bay_recharge_port/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Recharge power <b>[siunit(recharge_power, "W", 1)]</b>.</span>"

/obj/machinery/mech_bay_recharge_port/process(delta_time)
	if(machine_stat & NOPOWER || !recharge_console)
		return
	if(!recharging_mech)
		recharging_mech = locate(/obj/vehicle/sealed/mecha) in recharging_turf
		if(recharging_mech)
			recharge_console.update_appearance()
			recharge_console.ui_update()
	if(!recharging_mech?.cell)
		return
	if(recharging_mech.cell.charge < recharging_mech.cell.maxcharge)
		var/delta = min(recharge_power * delta_time, recharging_mech.cell.maxcharge - recharging_mech.cell.charge)
		recharging_mech.give_power(delta)
		use_power(delta*150)
	else
		recharge_console.update_appearance()
	if(recharging_mech.loc != recharging_turf)
		recharging_mech = null
		recharge_console.update_appearance()
		recharge_console.ui_update()


/obj/machinery/mech_bay_recharge_port/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "recharge_port-o", "recharge_port", I))
		return

	if(default_change_direction_wrench(user, I))
		recharging_turf = get_step(loc, dir)
		return

	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/computer/mech_bay_power_console
	name = "mech bay power control console"
	desc = "Displays the status of mechs connected to the recharge station."
	icon_screen = "recharge_comp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/circuitboard/computer/mech_bay_power_console


	var/obj/machinery/mech_bay_recharge_port/recharge_port
	light_color = LIGHT_COLOR_PINK

	var/had_mech = FALSE //Keep track of whether we had a mech last update

/obj/machinery/computer/mech_bay_power_console/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(recharge_port?.recharging_mech) //Update while there's a mech connected
		. = TRUE

/obj/machinery/computer/mech_bay_power_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/mech_bay_power_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechBayPowerConsole")
		ui.open()

/obj/machinery/computer/mech_bay_power_console/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("reconnect")
			reconnect()
			. = TRUE
			update_icon()

/obj/machinery/computer/mech_bay_power_console/ui_data(mob/user)
	var/list/data = list()
	if(recharge_port && !QDELETED(recharge_port))
		data["recharge_port"] = list("mech" = null)
		if(recharge_port.recharging_mech && !QDELETED(recharge_port.recharging_mech))
			data["recharge_port"]["mech"] = list("health" = recharge_port.recharging_mech.get_integrity(), "maxhealth" = recharge_port.recharging_mech.max_integrity, "cell" = null, "name" = recharge_port.recharging_mech.name,)
			if(recharge_port.recharging_mech.cell && !QDELETED(recharge_port.recharging_mech.cell))
				data["recharge_port"]["mech"]["cell"] = list(
				"charge" = recharge_port.recharging_mech.cell.charge,
				"maxcharge" = recharge_port.recharging_mech.cell.maxcharge
				)
	return data


/obj/machinery/computer/mech_bay_power_console/proc/reconnect()
	if(recharge_port)
		return
	recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in range(1)
	if(!recharge_port )
		for(var/D in GLOB.cardinals)
			var/turf/A = get_step(src, D)
			A = get_step(A, D)
			recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in A
			if(recharge_port)
				break
	if(recharge_port)
		if(!recharge_port.recharge_console)
			recharge_port.recharge_console = src
		else
			recharge_port = null

/obj/machinery/computer/mech_bay_power_console/update_overlays()
	. = ..()
	if(!recharge_port || !recharge_port.recharging_mech || !recharge_port.recharging_mech.cell || !(recharge_port.recharging_mech.cell.charge < recharge_port.recharging_mech.cell.maxcharge) || machine_stat & (NOPOWER|BROKEN))
		return
	. += "recharge_comp_on"

/obj/machinery/computer/mech_bay_power_console/Initialize(mapload)
	. = ..()
	reconnect()

/obj/machinery/computer/mech_bay_power_console/Destroy()
	if (recharge_port && recharge_port.recharge_console == src)
		recharge_port.recharge_console = null
	return ..()
