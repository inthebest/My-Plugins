#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new const Modelini[] = "addons/amxmodx/configs/modeller.ini";

new ModelIsmi[MAX_PLAYERS+1][50],
	ModelYeri[MAX_PLAYERS+1][50],
	ModelFiyat[MAX_PLAYERS+1],
	ModelAktif[MAX_PLAYERS+1][50],
	ModelSayisi = 0;

new iModelDeger[MAX_PLAYERS+1],
	iModelName[MAX_PLAYERS+1][50];

public plugin_init(){
	register_plugin("Ini Skin Deneme", "0.1", "` BesTCore;");

	register_clcmd("say /model", "clcmd_model");

	RegisterHookChain(RG_CBasePlayer_SetClientUserInfoModel, "CBasePlayer_SetClientUserInfoModel_Pre", .post = false);
}
public plugin_precache(){
	new iFile = fopen(Modelini, "r");
	if(iFile){
		new szBuffer[MAX_FMT_LENGTH], fiyat[10], i = 1;

		while(fgets(iFile, szBuffer, charsmax(szBuffer))){
			if(szBuffer[0] == EOS){
				continue;
			}
			parse(szBuffer, ModelIsmi[i], charsmax(ModelIsmi), ModelYeri[i], charsmax(ModelYeri), fiyat, charsmax(fiyat));
			ModelFiyat[i] = str_to_num(fiyat);
			precache_model(fmt("models/player/%s/%s.mdl", ModelYeri[i], ModelYeri[i]));
			i++;
		}
		ModelSayisi = i;
		fclose(iFile);
	}
}
public clcmd_model(id){
	new bestm = menu_create("\rModel Satin Al", "clcmd_model_");

	for(new i = 1, nts[6]; i < ModelSayisi; i++){
		num_to_str(i, nts, charsmax(nts));
		menu_additem(bestm, fmt("%s \d[\r%d \yTL\d]", ModelIsmi[i], ModelFiyat[i]), nts);
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public clcmd_model_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6],key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	buyitem(id, ModelIsmi[key], ModelFiyat[key], ModelYeri[key]);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public CBasePlayer_SetClientUserInfoModel_Pre(id, infobuffer[], szNewModel[]) {
	SetHookChainArg(3, ATYPE_STRING, ModelAktif[id]);
}
public buyitem(const id, item[], fiyat, deger[]){
	copy(iModelDeger[id], charsmax(iModelDeger), deger);
	copy(iModelName[id], charsmax(iModelName), item);

	new bestm = menu_create("\rOnay Sistemi", "buyitem_");

	menu_additem(bestm, "Satin Al");
	menu_additem(bestm, fmt("Iptal Et^n^n\dIncelenen Ürün:\r %s^n\dÜrün Fiyati:\r %d", item, fiyat));

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public buyitem_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0 :{
			copy(ModelAktif[id], charsmax(ModelAktif), iModelDeger[id]);
			client_print_color(id, id, "^4Basarili bir sekilde^4 %s ^3adli modeli satin aldiniz.", iModelName[id]);
		}
		case 1:{
			client_print_color(id, id, "^4Isleminizi iptal ettiniz.");
			return PLUGIN_HANDLED;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}