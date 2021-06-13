#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new const g_szSkin[][] = {
	"",            // 1.sine dokunma gerisini düzenle.
	"Model 1",
	"Model 2"
};
new const g_szDefSkin[][] = {
	"Model 1",    // Default "TE" skini.
	"Model 2"     // Default "CT" skini.
};

new g_iPick[MAX_PLAYERS+1];

public plugin_init(){
	register_plugin("HNS Model Menu", "0.1", "` BesTCore;");

	register_clcmd("say /ctkarakter", "clcmd_character");

	RegisterHookChain(RG_CBasePlayer_SetClientUserInfoModel, "RG_CBasePlayer_SetClientUserInfoModel_Pre", .post = false);
}
public clcmd_character(const id){
	if(!(is_user_alive(id)) || get_member(id, m_iTeam) != TEAM_CT){
		client_print_color(id, id, "^3Bu menuye yasayan ctler girebilir.");
		return PLUGIN_HANDLED;
	}
	new bestm = menu_create("\rKarakter Menu", "clcmd_character_");

	for(new i = 1; i < sizeof(g_szSkin); i++){
		menu_additem(bestm, fmt("%s", g_szSkin[i][0]), fmt("%i", i));
	}
	menu_display(id, bestm);
	return PLUGIN_HANDLED;
}
public clcmd_character_(const id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	rg_set_user_model(id, g_szSkin[key][0]);
	g_iPick[id] = key;

	menu_destroy(menu);
	return PLUGIN_HANDLED;

}
public RG_CBasePlayer_SetClientUserInfoModel_Pre(id, infobuffer[], szNewModel[]){
	new TeamName:iTeam = get_member(id, m_iTeam);

	switch(iTeam){
		case TEAM_CT:{
			for(new i = 1; i < sizeof(g_szSkin); i++){
				if(g_iPick[id] > 0){
					SetHookChainArg(3, ATYPE_STRING, g_szSkin[g_iPick[id]][0]);
					break;
				}
				else {
					SetHookChainArg(3, ATYPE_STRING, g_szDefSkin[1]);
				}
			}
		}
		case TEAM_TERRORIST:{
			SetHookChainArg(3, ATYPE_STRING, g_szDefSkin[0]);
		}
	}
}
public client_disconnected(id){
	g_iPick[id] = 0;
}
public plugin_precache(){
	for(new i = 1; i < sizeof(g_szSkin); i++){
		precache_model(fmt("models/player/%s/%s.mdl", g_szSkin[i][0], g_szSkin[i][0]));
	}
	for(new i = 0; i < sizeof(g_szDefSkin); i++){
		precache_model(fmt("models/player/%s/%s.mdl", g_szDefSkin[i][0], g_szDefSkin[i][0]));
	}
}