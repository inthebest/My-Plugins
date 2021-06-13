#pragma semicolon 1

#include <amxmodx>

#define MICACMA_YETKI   ADMIN_BAN

public plugin_init(){
	register_plugin("No Admins Block Mic","1.0","` BesTCore;");
}
public client_putinserver(id){
	set_task(3.0,"onayla", id);
}
public onayla(id){
	if(get_user_flags(id) & MICACMA_YETKI){
		set_task(3.0,"micac", id);
		client_print_color(0, 0, "^1[^4Teşkilat-I Mahsusa^1] ^3 Oyuna admin girdi ve mikrofonlar aktiflestirildi.");
		client_print_color(0, 0, "^1[^4Teşkilat-I Mahsusa^1] ^3 Oyuna admin girdi ve mikrofonlar aktiflestirildi.");
	}
}
public micac(id){
	set_cvar_num("sv_voiceenable", 1);
}
