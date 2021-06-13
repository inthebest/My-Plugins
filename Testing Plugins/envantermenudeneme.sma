#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new const defaultknife[] = "models/moon_basebuilder/v_moonayyildiz.mdl";

new const esyalar[][][] = {
	{"", 0, ""},
	{"Elma", 10, "newflip"},
	{"Armut", 20, "newkarambit"},
	{"Muz", 30, "newkelebek"}
};

new g_iEsya[MAX_PLAYERS+1][64],
	g_iUseItem[MAX_PLAYERS+1],
	PickItem[MAX_PLAYERS+1];

public plugin_init(){
	register_plugin("Envanter Menu Deneme", "0.1", "` BesTCore;");

	register_clcmd("nightvision", "clcmd_market");
	register_clcmd("say /market", "clcmd_market");

	RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "CBasePlayerWeapon_DefaultDeploy_Pre", .post = false);
}
public clcmd_market(const id){
	new bestm = menu_create("Market Menu", "clcmd_market_");

	menu_additem(bestm, "Esya Al", "1");
	menu_additem(bestm, "Esyalarim", "2");

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public clcmd_market_(const id, const menu, const item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			esyaal(id);
		}
		case 1:{
			esyalarim(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public esyaal(const id){
	new bestm = menu_create("Esya Al", "esyaal_");

	for(new i = 1, nts[6]; i < sizeof(esyalar); i++){
		num_to_str(i, nts, charsmax(nts));
		menu_additem(bestm, fmt("%s \d[\r%d \yTL\d]", esyalar[i][0], esyalar[i][1][0]), nts);
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public esyaal_(const id, const menu, const item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	
	if(g_iEsya[id][key] == 1){
		client_print_color(id, id, "^4Bu üründen sende bir tane var.");
		return PLUGIN_HANDLED;
	}
	g_iEsya[id][key] += 1;
	client_print_color(id, id, "^4Basarili bir sekilde^3 %s^3 adli ürünü aldiniz.", esyalar[key][0]);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public esyalarim(const id){
	new bestm = menu_create("Envanter", "esyalarim_");

	for(new i = 1, nts[6]; i < sizeof(esyalar); i++){
		if(g_iEsya[id][i] > 0){
			num_to_str(i, nts, charsmax(nts));
			menu_additem(bestm, fmt("%s \d[\r%d \yTL\d] \d(\r%d \yAdet\d)", esyalar[i][0], esyalar[i][1][0], g_iEsya[id][i]), nts);
		}
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
	return PLUGIN_HANDLED;
}
public esyalarim_(const id, const menu, const item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	g_iUseItem[id] = esyalar[key][2][0];
	ExaminedItem(id, esyalar[key][0], esyalar[key][1][0], g_iEsya[id][key]);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public ExaminedItem(const id, item[], price, howmanyitem){
	PickItem[id] = str_to_num(item);
	new bestm = menu_create("\rEsya Inceleme", "ExaminedItem_");

	menu_additem(bestm, fmt("\rÜrünü Aktif Et^n^n\dIncelenen Ürün: \r%s^n\dÜrün Fiyati: \r%d \yTL^n\dÜrün Adedi: \r%d\y Adet", item, price, howmanyitem), "1");

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public ExaminedItem_(const id, const menu, const item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			g_iUseItem[id] = PickItem[id];
			client_print_color(id, id, "Ürün Aktifleştirildi ^4%s.", PickItem[id]);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public CBasePlayerWeapon_DefaultDeploy_Pre(const Entity, v_Model[], w_Model[], Anim, AnimExt[], skiplocal){
	if(get_member(Entity, m_iId) != WEAPON_KNIFE){
		return;
	}

	new id = get_member(Entity, m_pPlayer);

	if(g_iUseItem[id] > 0){
		for(new i = 1; i < sizeof(esyalar); i++){
			SetHookChainArg(2, ATYPE_STRING, esyalar[g_iUseItem[id]][2]);
		}
	}
	else {
		SetHookChainArg(2, ATYPE_STRING, defaultknife);
	}
}
public client_disconnected(id){
	arrayset(g_iEsya[id], 0, sizeof(g_iEsya));
	arrayset(g_iUseItem[id], 0, sizeof(g_iUseItem));
}
public plugin_precache(){
	for(new i = 1; i < sizeof(esyalar); i++){
		precache_model(fmt("models/moon_basebuilder/%s.mdl", esyalar[i][2]));
	}
	precache_model(defaultknife);
}