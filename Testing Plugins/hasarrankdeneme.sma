#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <nvault>

enum _:szRankSystem {
	g_szRankName,
	g_iRankDamage
}
new const g_szRankSystem[][][] = {
//  {"Rank Ismi", XP}, Son rankın sonuna virgül koyma.	
	{"UnRanked", 0},
	{"Silver I", 200},
	{"Silver II", 300},
	{"Silver III", 400},
	{"Silver IIII", 500},
	{"Silver IIIII", 600}
};

enum _:data {
	g_szRank,
	g_iDamage
}
new g_data[MAX_PLAYERS+1][data],
	hudsync;

public plugin_init(){
	register_plugin("Hasar - Rank Sistemi", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CBasePlayer_TakeDamage, "RG_CBasePlayer_TakeDamage_Pre", .post = false);
	hudsync = CreateHudSyncObj();
}
public RG_CBasePlayer_TakeDamage_Pre(const this, pInflictor, pAttacker, Float:flDamage, bitsDamageType){
	if(!(is_user_alive(pAttacker) || is_user_connected(this)) || this == pAttacker){
		return;
	}
	if(g_data[pAttacker][g_szRank] < sizeof(g_szRankSystem)-1){
		g_data[pAttacker][g_iDamage] += floatround(flDamage);
	}
	g_data[this][g_iDamage] -= floatround(flDamage);

	client_print_color(pAttacker, pAttacker, "^4Verilen hasar^3 %d", floatround(flDamage));

	UpdateRank(pAttacker);
	UpdateRank(this);
}
public UpdateRank(const id){
	if(g_data[id][g_iDamage] >= g_szRankSystem[g_data[id][g_szRank]+1][g_iRankDamage][0]){
		g_data[id][g_szRank]++;
		client_print_color(0, 0, "^4%n ^3adli oyuncu level atladi, yeni leveli^4 %s.", id, g_szRankSystem[g_data[id][g_szRank]][g_szRankName][0]);
	}
	else if(g_data[id][g_iDamage] < g_szRankSystem[g_data[id][g_szRank]][g_iRankDamage][0]){
		g_data[id][g_szRank]--;
		if(g_data[id][g_iDamage] <= 0){ 
			g_data[id][g_iDamage] = 0;
			return;
		}
	}
}
// Hud msgs
public client_putinserver(id){
	set_task(1.0, "ShowHud", id, .flags = "b");
}
public ShowHud(id){
	set_hudmessage(255, 255, 255, 0.01, 0.16, 0, _, 1.5);
	ShowSyncHudMsg(id, hudsync, "[ Rank: %s ]^n[ Damage: %i/%i ]", g_szRankSystem[g_data[id][g_szRank]][g_szRankName], g_data[id][g_iDamage], g_szRankSystem[g_data[id][g_szRank]+1][g_iRankDamage]);
}
public client_disconnected(id){
	g_data[id][g_szRank] = 0;
	g_data[id][g_iDamage] = 0;
}
// nvault
new g_Vault;

public plugin_cfg(){
	g_Vault = nvault_open("DamageRankSystem");

	if(g_Vault == INVALID_HANDLE){
		set_fail_state("Bulunamayan nvault dosyasi: DamageRankSystem");
	}
}
public plugin_end(){
	nvault_close(g_Vault);
}
public client_authorized(id, const authid[]){
	g_data[id][g_iDamage] = nvault_get(g_Vault, fmt("%s-damage", authid));
	g_data[id][g_szRank] = nvault_get(g_Vault, fmt("%s-rank", authid));
}
public savevault(id){
	new authid[MAX_AUTHID_LENGTH];
	get_user_authid(id, authid, charsmax(authid));

	nvault_pset(g_Vault, fmt("%s-damage", authid), fmt("%i", g_data[id][g_iDamage]));
	nvault_pset(g_Vault, fmt("%s-rank", authid), fmt("%i", g_data[id][g_szRank]));
}