#pragma semicolon 1

#include <amxmodx>

#define ADMIN_PASS ADMIN_RCON

new bool:g_blChatOption,
	bool:g_blPassOption;

public plugin_init(){
	register_plugin("Server Password And Chat Off", "0.1", "Yek'-ta && ` BesTCore;");

	register_clcmd("say /serverayar", "clcmd_serveroption");

	register_clcmd("say", "clcmd_say");
	register_clcmd("say_team", "clcmd_say");

	server_cmd("sv_password ^"^"");
}
public clcmd_say(const id){
	if(g_blChatOption){
		client_print_color(id, id, "^3Chat konusmalari kapalidir.");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public clcmd_serveroption(const id){
	if(~get_user_flags(id) & ADMIN_PASS){
		client_print_color(id, id, "^3Bu menuye girmeye yetkin yok.");
		return PLUGIN_HANDLED;
	}
	new bestm = menu_create("\rServer Ayarlari", "clcmd_serveroption_");

	menu_additem(bestm, fmt("Sunucu Sifresi \d[\r%s\d]", g_blPassOption ? "1881":"Sifre Yok"));
	menu_additem(bestm, fmt("Chat Konusmalari \d[\r%s\d]", g_blChatOption ? "KAPALI":"ACIK"));

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
	return PLUGIN_HANDLED;
}
public clcmd_serveroption_(const id, menu, item){
	switch(item){
		case 0:{
			if(!g_blPassOption){
				server_cmd("sv_password 1881");
				client_print_color(0, 0, "^1%n ^3adli admin sunucunun sifresini^4 1881^3 olarak ayarladi.", id);
				client_print_color(0, 0, "^1%n ^3adli admin sunucunun sifresini^4 1881^3 olarak ayarladi.", id);
				client_print_color(0, 0, "^1%n ^3adli admin sunucunun sifresini^4 1881^3 olarak ayarladi.", id);
				g_blPassOption = true;
			}
			else {
				server_cmd("sv_password ^"^"");
				client_print_color(0, 0, "^1%n ^3adli admin sunucunun sifresini kaldirdi", id);
				client_print_color(0, 0, "^1%n ^3adli admin sunucunun sifresini kaldirdi", id);
				client_print_color(0, 0, "^1%n ^3adli admin sunucunun sifresini kaldirdi", id);
				g_blPassOption = false;
			}
			clcmd_serveroption(id);
		}
		case 1:{
			g_blChatOption = g_blChatOption ? false:true;
			clcmd_serveroption(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}