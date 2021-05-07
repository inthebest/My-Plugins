#pragma semicolon 1

#include <amxmodx>
#include <reapi>

enum (+= 1337){
	TASK_FREEZE = 1337
}
new Float:cvars;

public plugin_init(){
	register_plugin("After Start Round With Freeze", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Post", .post = true);

	bind_pcvar_float(create_cvar("FreezeSure", "30.0", .description = "Freezeleme süresi, değer virgüllü olmalıdır."), cvars);
}
public RG_CSGameRules_RestartRound_Post(){
	for(new i = 1; i <= MaxClients; i++){
		if(get_member(i, m_iTeam) != TEAM_TERRORIST){
			continue;
		}
		remove_task(TASK_FREEZE);
		set_task(cvars, "PlayersFreeze", i + TASK_FREEZE);
	}
}
public PlayersFreeze(Taskid){
	static id;
	id = Taskid - TASK_FREEZE;

	static iFlags;
	iFlags = get_entvar(id, var_flags);

	if(~iFlags & FL_FROZEN){
		set_entvar(id, var_flags, iFlags | FL_FROZEN);
		//client_print_color(0, 0, "Donduruldu.");
	}
}