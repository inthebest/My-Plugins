#pragma semicolon 1

#include <amxmodx>
#include <reapi>

enum (+= 1337){
	TASK_UNFREEZE
}
new Float:cvars;

public plugin_init(){
	register_plugin("Start Round With Freeze", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Post", .post = true);

	bind_pcvar_float(create_cvar("FreezeSure", "30.0", .description = "Freeze bozulma süresi, değer virgüllü olmalıdır."), cvars);
}
public RG_CSGameRules_RestartRound_Post(){
	for(new i = 1; i <= MaxClients; i++){
		if(get_member(i, m_iTeam) != TEAM_TERRORIST){
			continue;
		}
		static iFlags;
		iFlags = get_entvar(i, var_flags);

		if(~iFlags & FL_FROZEN){
			set_entvar(i, var_flags, iFlags | FL_FROZEN);
			remove_task(i + TASK_UNFREEZE);
			set_task(cvars, "PlayersUnFreeze", i + TASK_UNFREEZE);
			//client_print_color(0, 0, "Donduruldu.");
		}
	}
}
public PlayersUnFreeze(Taskid){
	static id;
	id = Taskid - TASK_UNFREEZE;

	static iFlags;
	iFlags = get_entvar(id, var_flags);

	if(iFlags & FL_FROZEN){
		set_entvar(id, var_flags, iFlags & ~FL_FROZEN);
		//client_print_color(0, 0, "Cozuldu.");
	}
}