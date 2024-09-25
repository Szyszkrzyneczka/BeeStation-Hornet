// mouse signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of client/Click(): (atom/target, atom/location, control, params, mob/user)
#define COMSIG_CLIENT_CLICK "atom_client_click"
//Allows the user to examinate regardless of client.eye.
	#define COMPONENT_ALLOW_EXAMINATE (1<<0)
	#define COMPONENT_CANCEL_CLICK_ALT (1<<0)
///from base of atom/alt_click_secondary(): (/mob)
#define COMSIG_CLICK_ALT_SECONDARY "alt_click_secondary"
	#define COMPONENT_CANCEL_CLICK_ALT_SECONDARY (1<<0)
///from base of mob/MouseWheelOn(): (/atom, delta_x, delta_y, params)
#define COMSIG_MOUSE_SCROLL_ON "mousescroll_on"
