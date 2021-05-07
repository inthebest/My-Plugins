#pragma semicolon 1

#include <amxmodx>

new g_cvars;

public plugin_init(){
	register_plugin("Limited Ban", "0.1", "` BesTCore;");

	register_clcmd("amx_ban", "clcmd_ban");

	bind_pcvar_num(create_cvar("Ban_Sinir", "120", _, "amx_ban komutunun zaman sinirini duzenler."), g_cvars);
}
public clcmd_ban(const id){
	new szArg[32];
	read_argv(2, szArg, charsmax(szArg));

	new iArg = str_to_num(szArg);

	if(iArg > g_cvars){
		client_print_color(id, id, "^3Ban komutunun zaman sinirini gecemezsin^1,^4 Sinir:^3 %d", g_cvars);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}