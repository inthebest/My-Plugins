#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <fakemeta>

public plugin_init(){
	register_plugin("Keep Standing During The Riot", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_CBasePlayer_TakeDamage_Post", .post = true);
}
public RG_CBasePlayer_TakeDamage_Post(const this, pevInflictor, pevAttacker, Float:flDamage, bitsDamageType){
	if(!(is_user_connected(pevAttacker)) || get_entvar(this, var_takedamage) == false || get_member(pevAttacker, m_iTeam) != TEAM_TERRORIST || get_member(this, m_iTeam) != TEAM_CT){
		return;
	}
	for(new i = 1; i <= MaxClients; i++){
		if(Stuck(i) && get_member(i, m_iTeam) == TEAM_TERRORIST){
			new Float:Origin[3];
			get_entvar(i, var_origin, Origin);
			Origin[2] += 35;
			set_entvar(i, var_origin, Origin);
			client_print_color(0, 0, "^3Isyan basladigi icin butun mahkumlar kaldirildi.");
			break;
		}
	}
}
bool:Stuck(id){
	static Float:Origin[3]; 
	get_entvar(id, var_origin, Origin);

	engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, get_entvar(id, var_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0);

	return bool:get_tr2(0, TR_StartSolid);
}