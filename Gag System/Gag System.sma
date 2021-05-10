#pragma semicolon 1

#include <amxmodx>
#include <nvault>

new const iChatTag[] = "^4forum.csd :";
#define ADMIN_GAG    ADMIN_RESERVATION

#define DEFAULTGAG_TIME   120    // Gag süresi boş bırakılırsa atılacak default süre. * If Gag time is left blank, the default time for Gag throw.

enum _:intenum {
	iGagTime[MAX_PLAYERS+1],
	iPickPlayer[MAX_PLAYERS+1]
};
new g_int[intenum];

public plugin_init(){
	register_plugin("[NVAULT] Gelişmiş Gag Sistemi", "0.1", "` BesTCore;");

	register_clcmd("say /gagmenu", "clcmd_gagmenu");
	register_clcmd("say !gagmenu", "clcmd_gagmenu");
	register_clcmd("say .gagmenu", "clcmd_gagmenu");
	register_clcmd("SureBelirle", "clcmd_SureBelirle");

	register_clcmd("say", "clcmd_say");
	register_clcmd("say_team", "clcmd_say");
	register_concmd("amx_gag", "clcmd_gag", ADMIN_GAG, "<name> <time>, oyuncuya gag atar.");
	register_concmd("amx_ungag", "clcmd_ungag", ADMIN_GAG, "<name>, oyuncunun gagini kaldirir.");
}
/********************************* Menuden Gag Atma **************************************/
public clcmd_gagmenu(id){
	if(~get_user_flags(id) & ADMIN_GAG){
		client_print_color(id, id, "%s ^3Bu komutu kullanmak icin yetkin yok.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new bestm = menu_create(fmt("\rGaglamak Icin Oyuncu Sec"), "clcmd_gagmenu_");

	for(new i = 1; i <= MaxClients; i++){
		if(!is_user_connected(i) || is_user_bot(i) || get_user_flags(i) & ADMIN_IMMUNITY){
			continue;
		}
		menu_additem(bestm, fmt("%n", i), fmt("%i", i));
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
	return PLUGIN_HANDLED;
}
public clcmd_gagmenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	g_int[iPickPlayer][id] = key;
	client_cmd(id, "messagemode SureBelirle");

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public clcmd_SureBelirle(id){
	if(~get_user_flags(id) & ADMIN_GAG){
		client_print_color(id, id, "%s ^3Bu komutu kullanmak icin yetkin yok.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new szArg[32];
	read_args(szArg, charsmax(szArg));
	remove_quotes(szArg);

	if(!g_int[iPickPlayer][id]){
		client_print_color(id, id, "%s ^3Oyuncuyu secmeden gag atamazsiniz.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new iTime = str_to_num(szArg);
	GagThePlayer(id, g_int[iPickPlayer][id], iTime);
	return PLUGIN_HANDLED;
}
/******************************* Say Gag İşlemleri *********************************/
public clcmd_say(const id){
	if(g_int[iGagTime][id] > 0){
		client_print_color(id, id, "%s ^3Gaginin kaldirilmasina^4 %i Saniye^3 kaldi.", iChatTag, g_int[iGagTime][id]);
		return PLUGIN_HANDLED;
	}
	new szArg[32];
	read_args(szArg, charsmax(szArg));
	remove_quotes(szArg);

	new szTitle[7], szName[32], iTime[10];
	parse(szArg, szTitle, charsmax(szTitle), szName, charsmax(szName), iTime, charsmax(iTime));

	new iTimes, pPlayer;
	iTimes = str_to_num(iTime);
	pPlayer = find_player("bl", szName);

	if(equal(szTitle, "/gag") || equal(szTitle, "!gag") || equal(szTitle, ".gag")){
		if(~get_user_flags(id) & ADMIN_GAG){
			client_print_color(id, id, "%s ^3Bu komutu kullanmak icin yetkin yok.", iChatTag);
			return PLUGIN_HANDLED;
		}
		else if(szName[0] == EOS){
			client_print_color(id, id, "%s ^3Oyuncu ismini bos birakamazsiniz.", iChatTag);
			return PLUGIN_HANDLED;
		}
		GagThePlayer(id, pPlayer, iTime[0] == EOS ? DEFAULTGAG_TIME:iTimes);
		return PLUGIN_HANDLED;
	}
	if(equal(szTitle, "/ungag") || equal(szTitle, "!ungag") || equal(szTitle, ".ungag")){
		if(~get_user_flags(id) & ADMIN_GAG){
			client_print_color(id, id, "%s ^3Bu komutu kullanmak icin yetkin yok.", iChatTag);
			return PLUGIN_HANDLED;
		}
		else if(szName[0] == EOS){
			client_print_color(id, id, "%s ^3Oyuncu ismini bos birakamazsiniz.", iChatTag);
			return PLUGIN_HANDLED;
		}
		else if(g_int[iGagTime][pPlayer] > 0){
			remove_task(pPlayer);
			g_int[iGagTime][pPlayer] = 0;
			client_print_color(0, 0, "^1%n ^3adli admin^1 %n^3 adli oyuncunun gagini kaldirdi.", id, pPlayer);
			return PLUGIN_HANDLED;
		}
		else {
			client_print_color(id, id, "%s ^3Belirlenen oyuncunun gagi bulunmuyor.", iChatTag);
			return PLUGIN_HANDLED;
		}
	}
	return PLUGIN_CONTINUE;
}
/**************************** Oyuncuya konsoldan gag atma *****************************/
public clcmd_gag(const id){
	if(~get_user_flags(id) & ADMIN_GAG){
		client_print_color(id, id, "%s ^3Bu komutu kullanmak icin yetkin yok.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new szArg[32], iArg[10];
	read_argv(1, szArg, charsmax(szArg));
	read_argv(2, iArg, charsmax(iArg));

	new iTime, pPlayer;
	iTime = str_to_num(iArg);
	pPlayer = find_player("bl", szArg);

	if(szArg[0] == EOS){
		client_print_color(id, id, "%s ^3Oyuncu ismini bos birakamazsiniz.", iChatTag);
		return PLUGIN_HANDLED;
	}

	GagThePlayer(id, pPlayer, iArg[0] == EOS ? DEFAULTGAG_TIME:iTime);
	return PLUGIN_HANDLED;
}
/******************************* Oyuncunun konsoldan gagini kaldirma *********************************/
public clcmd_ungag(const id){
	if(~get_user_flags(id) & ADMIN_GAG){
		client_print_color(id, id, "%s ^3Bu komutu kullanmak icin yetkin yok.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new szArg[32];
	read_argv(1, szArg, charsmax(szArg));

	new pPlayer;
	pPlayer = find_player("bl", szArg);

	if(szArg[0] == EOS){
		client_print_color(id, id, "%s ^3Oyuncu ismini bos birakamazsiniz.", iChatTag);
		return PLUGIN_HANDLED;
	}
	if(g_int[iGagTime][pPlayer] > 0){
		remove_task(pPlayer);
		g_int[iGagTime][pPlayer] = 0;
		client_print_color(0, 0, "^1%n ^3adli admin^1 %n^3 adli oyuncunun gagini kaldirdi.", id, pPlayer);
		return PLUGIN_HANDLED;
	}
	else {
		client_print_color(id, id, "%s ^3Belirlenen oyuncunun gagi bulunmuyor.", iChatTag);
		return PLUGIN_HANDLED;
	}
}
/***************************************************************************************************/

public GagThePlayer(const id, const pPlayer, iTime){
	if(GagTermsOfUse(id, pPlayer, true, true, true)){
		return PLUGIN_HANDLED;
	}
	else if(!(iTime > 0)){
		client_print_color(id, id, "%s ^3Gag suresini 0'dan buyuk girmelisiniz.", iChatTag);
		return PLUGIN_HANDLED;
	}
	else {
		g_int[iGagTime][pPlayer] = iTime;
		set_task(1.0, "CountdownGag", pPlayer, .flags = "b");
		client_print_color(0, 0, "^1%n ^3adli admin^1 %n^3 adli oyuncuya ^4%i Saniye^3 gag atti.", id, pPlayer, iTime);
		return PLUGIN_HANDLED;
	}
}
bool:GagTermsOfUse(const id, const pPlayer, bool:blFlags, bool:blPlayer, bool:blOnGag){
	if(blPlayer && !pPlayer){
		client_print_color(id, id, "%s ^3Gaglamak icin oyuncu bulunamadi.", iChatTag);
		return true;
	}
	if(blFlags && get_user_flags(pPlayer) & ADMIN_IMMUNITY){
		client_print_color(id, id, "%s ^3Belirlenen oyuncunun dokunulmazligi mevcut.", iChatTag);
		return true;
	}
	if(blOnGag && g_int[iGagTime][pPlayer] > 0){
		client_print_color(id, id, "%s ^3Belirlenen oyuncunun zaten gagi var.", iChatTag);
		return true;
	}
	return false;
}
public CountdownGag(const id){
	if(g_int[iGagTime][id] > 0){
		g_int[iGagTime][id]--;
	}
	else {
		g_int[iGagTime][id] = 0;
		remove_task(id);
		client_print_color(0, 0, "^1%n ^3adli oyuncunun gag suresi bitti.", id);
	}
}
public client_disconnected(id){
	remove_task(id);
	savevault(id);
	g_int[iGagTime][id] = 0;
	g_int[iPickPlayer][id] = 0;
}

/******************************** Nvault ****************************/
new g_vault;
public plugin_cfg(){
	g_vault = nvault_open("GagSistemiVault");

	if(g_vault == INVALID_HANDLE){
		set_fail_state("Bulunamayan nvault dosyasi: GagSistemiVault");
	}
}
public plugin_end(){
	nvault_close(g_vault);
}
public client_authorized(id, const authid[]){
	g_int[iGagTime][id] = nvault_get(g_vault, fmt("%s-gagtime", authid));
	if(g_int[iGagTime][id] > 0){
		set_task(1.0, "CountdownGag", id, .flags = "b");
	}
}
public savevault(id){
	new authid[MAX_AUTHID_LENGTH];
	get_user_authid(id, authid, charsmax(authid));

	nvault_pset(g_vault, fmt("%s-gagtime", authid), fmt("%i", g_int[iGagTime][id]));
}
