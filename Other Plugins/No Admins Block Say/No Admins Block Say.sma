#include <amxmodx>

new chatoption;

public plugin_init(){
	register_plugin("No Admins Block Say", "0.1", "` BesTCore;");

	register_clcmd("say", "@sayengel");
	register_clcmd("say_team", "@sayengel");
}
public sayengel(id){
	if(chatoption == 0){
		client_print_color(id, id, "^4Chat kapatilmistir.");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public client_putinserver(id){
	if(get_user_flags(id) & ADMIN_RESERVATION){
		if(chatoption == 0){
			client_print_color(0, 0,"^4Bir yetkili oyuna girdi ve chat aktiflestirildi.");
		}
		chatoption++;
	}
}
public client_disconnected(id){
	if(get_user_flags(id) & ADMIN_RESERVATION){
		chatoption--;
		if(chatoption == 0){
			client_print_color(0, 0, "^4Oyunda aktif admin olmadigi icin chat kapatiliyor.");
		}
	}
}