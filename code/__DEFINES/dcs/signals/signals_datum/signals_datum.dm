// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /datum signals
#define COMSIG_COMPONENT_ADDED "component_added"				//! when a component is added to a datum: (/datum/component)
#define COMSIG_COMPONENT_REMOVING "component_removing"			//! before a component is removed from a datum because of RemoveComponent: (/datum/component)
#define COMSIG_PARENT_PREQDELETED "parent_preqdeleted"			//! before a datum's Destroy() is called: (force), returning a nonzero value will cancel the qdel operation
#define COMSIG_PARENT_QDELETING "parent_qdeleting"				//! just before a datum's Destroy() is called: (force), at this point none of the other components chose to interrupt qdel and Destroy will be called
#define COMSIG_TOPIC "handle_topic"                             //! generic topic handler (usr, href_list)

/// fires on the target datum when an element is attached to it (/datum/element)
#define COMSIG_ELEMENT_ATTACH "element_attach"
/// fires on the target datum when an element is attached to it  (/datum/element)
#define COMSIG_ELEMENT_DETACH "element_detach"

/// Sent when the amount of materials in material_container changes
#define COMSIG_MATERIAL_CONTAINER_CHANGED "material_container_changed"

///from base of [/datum/reagents/proc/add_reagent] - Sent before the reagent is added: (reagenttype, amount, reagtemp, data, no_react)
#define COMSIG_REAGENTS_PRE_ADD_REAGENT "reagents_pre_add_reagent"
	/// Prevents the reagent from being added.
	#define COMPONENT_CANCEL_REAGENT_ADD (1<<0)

// /datum/species signals
#define COMSIG_SPECIES_GAIN "species_gain"						//! from datum/species/on_species_gain(): (datum/species/new_species, datum/species/old_species)
#define COMSIG_SPECIES_LOSS "species_loss"						//! from datum/species/on_species_loss(): (datum/species/lost_species)

// /datum/song signals
/// Sent to the instrument when a song starts playing
#define COMSIG_SONG_START 	"song_start"
#define COMSIG_SONG_END		"song_end"

/*******Component Specific Signals*******/
//Janitor
#define COMSIG_TURF_IS_WET "check_turf_wet"
///(max_strength, immediate, duration_decrease = INFINITY): Returns bool.
#define COMSIG_TURF_MAKE_DRY "make_turf_try"

///Called on an object to "clean it", such as removing blood decals/overlays, etc. The clean types bitfield is sent with it. Return TRUE if any cleaning was necessary and thus performed.
#define COMSIG_COMPONENT_CLEAN_ACT "clean_act"

//Creamed

///called when you wash your face at a sink: (num/strength)
#define COMSIG_COMPONENT_CLEAN_FACE_ACT "clean_face_act"

//Gibs

///from base of /obj/effect/decal/cleanable/blood/gibs/streak(): (list/directions, list/diseases)
#define COMSIG_GIBS_STREAK "gibs_streak"

/// Called on mobs when they step in blood. (blood_amount, blood_state, list/blood_DNA)
#define COMSIG_STEP_ON_BLOOD "step_on_blood"

//Diseases

#define COMSIG_DISEASE_END "disease_end" 						//from the base of /datum/disease/advance/Destroy(): (GetDiseaseID)

//Mood

#define COMSIG_ADD_MOOD_EVENT "add_mood" //! Called when you send a mood event from anywhere in the code.
#define COMSIG_CLEAR_MOOD_EVENT "clear_mood" //! Called when you clear a mood event from anywhere in the code.

/// Called in /obj/structure/moneybot/add_money(). (to_add)
#define COMSIG_MONEYBOT_ADD_MONEY "moneybot_add_money"


#define COMSIG_GREYSCALE_CONFIG_REFRESHED "greyscale_config_refreshed"


// /datum/component/two_handed signals
#define COMSIG_TWOHANDED_WIELD "twohanded_wield"              //from base of datum/component/two_handed/proc/wield(mob/living/carbon/user): (/mob/user)
      #define COMPONENT_TWOHANDED_BLOCK_WIELD 1
#define COMSIG_TWOHANDED_UNWIELD "twohanded_unwield"          //from base of datum/component/two_handed/proc/unwield(mob/living/carbon/user): (/mob/user)


// /datum/mind signals
#define COMSIG_MIND_TRANSFER_TO		"mind_transfer_to"		// (mob/old, mob/new)
#define COMSIG_MIND_JOIN_ANTAG_HUD	"mind_join_antag_hud"	// (datum/atom_hud/antag/hud)
#define COMSIG_MIND_LEAVE_ANTAG_HUD	"mind_leave_antag_hud"	// (datum/atom_hud/antag/hud)
#define COMSIG_MIND_CRYOED 			"mind_cryoed"			// Sent when a mob with a mind enters cryo storage: ()

// /datum/component/clockwork_trap signals
#define COMSIG_CLOCKWORK_SIGNAL_RECEIVED "clock_received"			//! When anything the trap is attatched to is triggered

///Subsystem signals
///From base of datum/controller/subsystem/Initialize
#define COMSIG_SUBSYSTEM_POST_INITIALIZE "subsystem_post_initialize"

///from SSsecurity_level when the security level changes : (new_level)
#define COMSIG_SECURITY_LEVEL_CHANGED "security_level_changed"

/// a weather event of some kind occured
#define COMSIG_WEATHER_TELEGRAPH(event_type) "!weather_telegraph [event_type]"
#define COMSIG_WEATHER_START(event_type) "!weather_start [event_type]"
#define COMSIG_WEATHER_WINDDOWN(event_type) "!weather_winddown [event_type]"
#define COMSIG_WEATHER_END(event_type) "!weather_end [event_type]"
/// An alarm of some form was sent (datum/alarm_handler/source, alarm_type, area/source_area)
#define COMSIG_ALARM_FIRE(alarm_type) "!alarm_fire [alarm_type]"
/// An alarm of some form was cleared (datum/alarm_handler/source, alarm_type, area/source_area)
#define COMSIG_ALARM_CLEAR(alarm_type) "!alarm_clear [alarm_type]"

/// signals from globally accessible objects

// Alarm listener datum signals
///Sent when an alarm is fired (alarm, area/source_area)
#define COMSIG_ALARM_TRIGGERED "comsig_alarm_triggered"
///Send when an alarm source is cleared (alarm_type, area/source_area)
#define COMSIG_ALARM_CLEARED "comsig_alarm_clear"

// Radio jammer signals
/// Calls something to toggle its jamming ability. (mob/user, silent = FALSE)
#define COMSIG_TOGGLE_JAMMER "toggle_jammer"

///Called to all children when a parent moves, as long as it has the moved relay component.
#define COMSIG_PARENT_MOVED_RELAY "parent_moved_relay"

/// Called when a buffer tries to send some stored data to something (datum/source, mob/user, datum/buffer, obj/item/buffer_parent) (buffer item may be null)
#define COMSIG_PARENT_RECIEVE_BUFFER "recieve_buffer"
	#define COMPONENT_BUFFER_RECIEVED (1 << 0)
