#pragma semicolon 1

#include <amxmodx>
#include <reapi>

enum (+= 1337){
	TASK_UNFREEZE
}

enum _:flenum {
	Float:flTEUnFreeze,
	Float:flCTUnFreeze
};
new Float:g_float[flenum];

public plugin_init(){
	register_plugin("Start Round With Freeze All Team", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Post", .post = true);

	bind_pcvar_float(create_cvar("UnFreezeTime_TE", "30.0", .description = "TE freeze çözülme süresi, değer virgüllü olmalıdır."), g_float[flTEUnFreeze]);
	bind_pcvar_float(create_cvar("UnFreezeTime_CT", "10.0", .description = "CT freeze çözülme süresi, değer virgüllü olmalıdır."), g_float[flCTUnFreeze]);
}
public RG_CSGameRules_RestartRound_Post(){
	for(new i = 1; i <= MaxClients; i++){
		if(!(is_user_alive(i))){
			continue;
		}
		static iFlags;
		iFlags = get_entvar(i, var_flags);

		new iTeam = get_member(i, m_iTeam);

		if(~iFlags & FL_FROZEN){
			set_entvar(i, var_flags, iFlags | FL_FROZEN);
			switch(iTeam){
				case TEAM_TERRORIST:{
					set_task(g_float[flTEUnFreeze], "UnFreeze", i + TASK_UNFREEZE);
					//client_print_color(0, 0, "^4TE Unfreezlenme basladi.");
				}
				case TEAM_CT:{
					set_task(g_float[flCTUnFreeze], "UnFreeze", i + TASK_UNFREEZE);
					//client_print_color(0, 0, "^4CT Unfreezlenme basladi.");
				}
			}
			break;
		}
	}
}
public UnFreeze(Taskid){
	static id, 	iFlags;
	id = Taskid - TASK_UNFREEZE;
	iFlags = get_entvar(id, var_flags);

	if(iFlags & FL_FROZEN){
		set_entvar(id, var_flags, iFlags & ~FL_FROZEN);
	}
	remove_task(TASK_UNFREEZE);
}