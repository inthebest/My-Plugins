#pragma semicolon 1

#include <amxmodx>

public plugin_init(){
	register_plugin("Menu Ayar Deneme", "0.1", "` BesTCore;");

	register_clcmd("say /menugir", "openmenu");
}
public openmenu(id){
	new bestm = menu_create(fmt("\yMenu Ayar Deneme"), "openmenu_");

	menu_additem(bestm, "Secenek", "1");
	menu_additem(bestm, "Secenek", "1");
	menu_additem(bestm, "Secenek", "1");
	menu_additem(bestm, "Secenek", "1");
	menu_additem(bestm, "Secenek", "1");

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_setprop(bestm, MPROP_EXIT, 0);
	menu_display(id, bestm);
}
public openmenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			openmenu(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}