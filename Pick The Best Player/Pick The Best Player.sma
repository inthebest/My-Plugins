#include <amxmodx>

new const iUstTag[] = "\dCSDuragi.COM -\r";

enum _: PickPlayer {
	FirstPlayer[MAX_NAME_LENGTH],
	SecondPlayer[MAX_NAME_LENGTH],
	Sync
};

new Players[PickPlayer];

new bool:iChoose[MAX_PLAYERS+1] = false;

public plugin_init(){
	register_plugin("Pick The Best Player","0.1","` BesTCore;");

	register_clcmd("say /etkinlikmenu", "activitymenu");
	Players[Sync] = CreateHudSyncObj();

	Players[FirstPlayer] = "Secilmedi";
	Players[SecondPlayer] = "Secilmedi";
}
public activitymenu(id){
	if(get_user_flags(id) & ADMIN_RCON){
		new bestm = menu_create(fmt("%s Etkinlik Menu", iUstTag), "activitymenu_");

		menu_additem(bestm, "En Iyi Oyuncu Sec", "1");
		menu_additem(bestm, "En Iyi Komutcu Sec", "2");

		menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
		menu_display(id, bestm);
	}
	else {
		client_print_color(id, id, "^1Bu menu icin yeterli yetkiniz bulunmamaktadir.");
	}
}
public activitymenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			iChoose[id] = false;
			ChoosePlayer(id);
		}
		case 2:{
			iChoose[id] = true;
			ChoosePlayer(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public ChoosePlayer(id){
	new bestm = menu_create(fmt("%s Oyuncular", iUstTag), "ChoosePlayer_");

	for(new i = 1, nts[6]; i <= MaxClients; i++){
		if(!is_user_connected(i) || i != id || is_user_bot(i)){
			continue;
		}
		num_to_str(i, nts, charsmax(nts));
		menu_additem(bestm, fmt("%n", i), nts);
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public ChoosePlayer_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key, name[MAX_NAME_LENGTH];
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	get_user_name(key, name, charsmax(name));

	if(!is_user_connected(key)){
		client_print_color(id, id, "^1Oyuncu Bulunamadi");
		return PLUGIN_HANDLED;
	}
	if(iChoose[id]){
		Players[SecondPlayer] = name;
		client_print_color(0, 0, "^3%n ^1adli admin^3 %n^1 adli oyuncuyu en iyi komutcu olarak secti.", id, key);
	}
	else {
		Players[FirstPlayer] = name;
		client_print_color(0, 0, "^3%n^1 adli admin^3 %n^1 adli oyuncuyu en iyi oyuncu olarak secti", id, key);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public client_putinserver(id){
	set_task(1.0, "ShowTopPlayers", id, .flags = "b");
}
public ShowTopPlayers(id){

	set_hudmessage(255, 0, 42, 0.01, 0.5, _, 1.5);
	ShowSyncHudMsg(id, Players[Sync], "En iyi Oyuncu: %s^nEn iyi Komutcu: %s", Players[FirstPlayer], Players[SecondPlayer]);
}