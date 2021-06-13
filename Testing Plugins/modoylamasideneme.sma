#pragma semicolon 1

#include <amxmodx>

new const iUstTag[]  = "\rMoonGaming\d -";
new const iAltTag[]  = "\yMoonGaming\d -\w";

new g_iVotes[3],
	g_iVoteing,
	g_iCount,
	ActiveMode;

new bool:g_blVoteing[MAX_PLAYERS+1];

public plugin_init(){
	register_plugin("Basebuilder Mod Oylamasi", "0.1", "` BesTCore;");

	set_task(5.0, "nextvote");
}
public nextvote(){
	static num = 10;
	num--;
	if(num >= 0){
		client_print_color(0, 0, "^3Basebuilder mod oylamasinin baslamasina^4 %d Saniye^3 kaldi.", num);
		set_task(1.0, "nextvote");
	}
	else {
		g_iVotes[1] = g_iVotes[2] = 0;
		g_iCount = 30;
		startcountdown();
		votestarting();
	}
}
public startcountdown(){
	if(g_iCount > 0){
		g_iCount--;
		set_task(1.0, "startcountdown");
	}
	else {
		voteEnd();
	}
}
public votestarting(){
	new g_iVoteMenu = menu_create(fmt("%s Basebuilder Mod Oylamasi^n\dOylamanin Bitmesine Kalan:\r %d Saniye", iUstTag, g_iCount), "votestarting_");

	menu_additem(g_iVoteMenu, fmt("%s Boss Mod \d[\r%d \yOY\d]", iAltTag, g_iVotes[1]), "1");
	menu_additem(g_iVoteMenu, fmt("%s Normal Mod \d[\r%d \yOY\d]^n^n\wGeçerli Oy Sayisi:\r %d", iAltTag, g_iVotes[2], g_iVoteing), "2");

	menu_setprop(g_iVoteMenu, MPROP_EXIT, MEXIT_NEVER);
	for(new id = 1; id <= MaxClients; id++){
		if(is_user_connected(id)){
			menu_display(id, g_iVoteMenu);
		}
	}

	if(ActiveMode == 0 && g_iCount > 0){
		set_task(0.5, "votestarting");
	}
	return PLUGIN_HANDLED;
}
public votestarting_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	if(!g_blVoteing[id] && ActiveMode == 0){
		ToVote(id, key);
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public ToVote(const id, votenum){
	if(votenum == 1 || votenum == 2){
		g_blVoteing[id] = true;
		if(votenum == 1){
			g_iVotes[1]++;
			client_print_color(0, 0, "^1%n ^3adli oyuncu^4 Boss Mod^1[^4%d OY^1]^3'una oy verdi.", id, g_iVotes[1]);
		}
		if(votenum == 2){
			g_iVotes[2]++;
			client_print_color(0, 0, "^1%n ^3adli oyuncu^4 Normal Mod^1[^4%d OY^1]^3'una oy verdi.", id, g_iVotes[2]);
		}
	}
	g_iVoteing++;
}
public voteEnd(){
	for(new i = 1; i <= MaxClients; i++){
		if(is_user_connected(i)){
			g_blVoteing[i] = false;
			show_menu(i, 0, "");
		}
	}
	if(g_iVotes[2] > g_iVotes[1]){
		client_print_color(0, 0, "^3Oylama sonucunu oynanilan oyun modu^4 Normal Mod^3 olarak degistirilmistir.");
		client_print_color(0, 0, "^3Oylama sonucunu oynanilan oyun modu^4 Normal Mod^3 olarak degistirilmistir.");
		ActiveMode = 2;
	}
	else if(g_iVotes[1] > g_iVotes[2]) {
		client_print_color(0, 0, "^3Oylama sonucunu oynanilan oyun modu^4 Boss Mod^3 olarak degistirilmistir.");
		client_print_color(0, 0, "^3Oylama sonucunu oynanilan oyun modu^4 Boss Mod^3 olarak degistirilmistir.");
		ActiveMode = 1;
	}
	else {
		client_print_color(0, 0, "^3Oylama sonucu esit oldugu icin oynanilan oyun modu otomatikmen^4 Normal Mod ^3olarak degistirilmistir.");
		client_print_color(0, 0, "^3Oylama sonucu esit oldugu icin oynanilan oyun modu otomatikmen^4 Normal Mod ^3olarak degistirilmistir.");
	}
}