#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new szSkin[][][] = {
	{"", 0, ""},
	{"Model 1", 10, "bb_fast"},
	{"Model 2", 20, "bb_jumper"}
};

new bool:g_blBuySkin[MAX_PLAYERS+1][sizeof(szSkin)],
	g_iPickSkin[MAX_PLAYERS+1];

new g_szModelName[MAX_PLAYERS+1][30],
	g_szModel[MAX_PLAYERS+1][50],
	g_iModelCost[MAX_PLAYERS+1],
	iPickSkin[MAX_PLAYERS+1];

public plugin_init(){
	register_plugin("Skin Buy and Pick", "0.1", "` BesTCore;");

	register_clcmd("say /modelmenu", "clcmd_modelmenu");
	register_clcmd("nightvision", "clcmd_modelmenu");

	RegisterHookChain(RG_CBasePlayer_SetClientUserInfoModel, "CBasePlayer_SetClientUserInfoModel_Pre", .post = false);
}
public clcmd_modelmenu(const id){
	new bestm = menu_create("\rModel Menu", "clcmd_modelmenu_");

	for(new i = 1; i < sizeof(szSkin); i++){
		menu_additem(bestm, fmt("%s \d[\r%d\y TL\d]", szSkin[i][0], szSkin[i][1]), fmt("%i", i));
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public clcmd_modelmenu_(const id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	Iteminfo(id, szSkin[key][0], szSkin[key][1][0], szSkin[key][2][0], key);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public Iteminfo(const id, modelname[], modelcost, model[], pickskin){
	copy(g_szModelName[id], charsmax(g_szModelName), modelname);
	copy(g_szModel[id], charsmax(g_szModel), model);
	g_iModelCost[id] = modelcost;
	iPickSkin[id] = pickskin;

	new bestm = menu_create("\rModel Bilgisi", "Iteminfo_");

	if(g_blBuySkin[id][pickskin]){
		if(g_iPickSkin[id] == pickskin){
			menu_additem(bestm, "\yUrunu kullanmayi birak", "1");
		}
		else {
			menu_additem(bestm, "\yUrunu kullan", "2");
		}
	}
	else {
		menu_additem(bestm, "Satin Al", "3");
		menu_additem(bestm, "Iptal Et", "4");
	}
	menu_addtext(bestm, fmt("\dIncelenen Urun:\y %s", modelname));
	menu_addtext(bestm, fmt("\dUrun Fiyati:\y %d TL", modelcost));

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public Iteminfo_(const id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			if(g_blBuySkin[id][iPickSkin[id]]){
				if(g_iPickSkin[id] == iPickSkin[id]){
					g_iPickSkin[id] = 0;
					client_print_color(id, id, "^3Basarili bir sekilde^4 %s^3 adli urunu kullanmayi biraktiniz.", g_szModelName[id][0]);
				}
			}
		}
		case 2:{
			if(g_blBuySkin[id][iPickSkin[id]]){
				if(!(g_iPickSkin[id] == iPickSkin[id])){
					g_iPickSkin[id] = iPickSkin[id];
					client_print_color(id, id, "^3Basarili bir sekilde^4 %s^3 adli urunu kullanmaya basladiniz.", g_szModelName[id][0]);
				}
			}
		}
		case 3:{
			if(!g_blBuySkin[id][iPickSkin[id]]){
				g_blBuySkin[id][iPickSkin[id]] = true;
				g_iPickSkin[id] = iPickSkin[id];
				client_print_color(id, id, "^3Basarili bir sekilde^4 %s^3 adli urunu satin aldiniz.", g_szModelName[id][0]);
			}
		}
		case 4:{
			client_print_color(id, id, "^3Isleminizi iptal ettiniz.");
			menu_destroy(menu);
			return PLUGIN_HANDLED;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public CBasePlayer_SetClientUserInfoModel_Pre(id, infobuffer[], szNewModel[]){
	for(new i = 1; i < sizeof(szSkin); i++){
		SetHookChainArg(3, ATYPE_STRING, szSkin[g_iPickSkin[id]][2]);
	}
}
public plugin_precache(){
	for(new i = 1; i < sizeof(szSkin); i++){
		precache_model(fmt("models/player/%s/%s.mdl", szSkin[i][2][0], szSkin[i][2][0]));
	}
}