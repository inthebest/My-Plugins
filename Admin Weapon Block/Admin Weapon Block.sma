#pragma semicolon 1

#include <amxmodx>

new const szWeaponBlock[][] = {
	"43",
	"42",
	"AWP",
	"M4A1"
};

public plugin_init(){
	register_plugin("Admin Weapon Block", "0.1", "` BesTCore;");

	register_clcmd("amx_weapon", "clcmd_weapon");
}
public clcmd_weapon(const id){
	new szArg[32];
	read_argv(2, szArg, charsmax(szArg));

	for(new i = 0; i < sizeof(szWeaponBlock); i++){
		if(equal(szArg, szWeaponBlock[i])){
			client_print_color(id, id, "^3Yasaklanmis silahi veremezsin.");
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}