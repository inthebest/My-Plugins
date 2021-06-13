#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new bool:g_blDamage[MAX_PLAYERS+1];

public plugin_init(){
	register_plugin("Slow Take Damage", "0.1", "` BesTCore;");

	register_clcmd("say /damageayarla", "clcmd_damageayarla");

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_CBasePlayer_TakeDamage_Pre", .post = false);
}
public clcmd_damageayarla(id){
	if(!g_blDamage[id]){
		g_blDamage[id] = true;
		// Hasar azaltmayı actik.
	}
	else {
		g_blDamage[id] = false;
		// Hasar azaltmayı kapattık.
	}
}
public RG_CBasePlayer_TakeDamage_Pre(const this, pInflictor, pAttacker, Float:flDamage, bitsDamageType){
	if(!(is_user_alive(pAttacker) || is_user_connected(this) || this != pAttacker || g_blDamage[this] || get_member(pAttacker, m_iTeam) == TEAM_CT)){
		return;
	}
	SetHookChainArg(4, ATYPE_FLOAT, flDamage/2);
}