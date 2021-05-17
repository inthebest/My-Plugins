#pragma semicolon 1

#include <amxmodx>

public plugin_init(){
	register_plugin("Block Slash", "0.1", "` BesTCore;");

	register_clcmd("say", "clcmd_say");
	register_clcmd("say_team", "clcmd_say");
}
public clcmd_say(id){
	new szArg[32];
	read_args(szArg, charsmax(szArg));
	remove_quotes(szArg);

	if(szArg[0] == '/'){
		return PLUGIN_HANDLED_MAIN;
	}
	return PLUGIN_CONTINUE;
}