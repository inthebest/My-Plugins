#pragma semicolon 1

#include <amxmodx>

new const iUstTag[]  = "\rCSDuragi.COM\d -";
new const iChatTag[] = "^4CSDuragi.COM :";

#define GIRIS_YETKI ADMIN_BAN    // Menuye giris yetkisi.

new g_iPickPlayer[MAX_PLAYERS+1],
	g_iChangeName[MAX_PLAYERS+1][30],
	bool:g_blSecurity[MAX_PLAYERS+1];

public plugin_init(){
	register_plugin("Nick Degistirme Eklentisi", "0.1", "` BesTCore;");

	register_clcmd("say /nickmenu", "clcmd_nickmenu");
	register_clcmd("IsimBelirle", "clcmd_isimbelirle");
}
public clcmd_nickmenu(id){
	if(!(get_user_flags(id) & GIRIS_YETKI)){
		client_print_color(id, id, "%s ^3Bu menuye girebilmek icin yeterli yetkiniz bulunmamaktadir.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new bestm = menu_create(fmt("%s Nick Menu", iUstTag), "clcmd_nickmenu_");

	menu_additem(bestm, fmt("Secilen Oyuncu: \d[\r%s\d]", fmt(g_iPickPlayer[id] ? "%n":"Tikla Sec", g_iPickPlayer[id])));
	menu_additem(bestm, fmt("Degistirilecek Isim: \d[\r%s\d]^n", fmt(g_iChangeName[id][0] == EOS ? "Belirle":"%s", g_iChangeName[id])));

	menu_additem(bestm, fmt("%sIsimi Degistir", fmt(!g_iPickPlayer[id] || g_iChangeName[id][0] == EOS ? "\d":"")));

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
	return PLUGIN_HANDLED;
}
public clcmd_nickmenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			ChoosePlayer(id);
		}
		case 1:{
			if(!g_iPickPlayer[id]){
				client_print_color(id, id, "%s ^3Oyuncuyu secmeden isim belirleyemezsiniz.", iChatTag);
				clcmd_nickmenu(id);
				return PLUGIN_HANDLED;
			}
			client_cmd(id, "messagemode IsimBelirle");
			g_blSecurity[id] = true;
		}
		case 2:{
			if(g_iChangeName[id][0] == EOS){
				client_print_color(id, id, "%s ^3Bir oyuncu secmeden veya isim girmeden onaylayamazsiniz.", iChatTag);
				clcmd_nickmenu(id);
				return PLUGIN_HANDLED;
			}
			client_cmd(g_iPickPlayer[id], "name %s", g_iChangeName[id]);
			client_print_color(0, 0, "%s^1 %n^3 isimli admin^1 %n^3 isimli oyuncunun nickini^4 %s^3 yapti.", iChatTag, id, g_iPickPlayer[id], g_iChangeName[id]);
			g_iPickPlayer[id] = 0;
			g_iChangeName[id][0] = EOS;
			g_blSecurity[id] = false;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public ChoosePlayer(id){
	new bestm = menu_create(fmt("%s Oyuncu Sec", iUstTag), "ChoosePlayer_");

	for(new i = 1, nts[6]; i <= MaxClients; i++){
		if(is_user_connected(i) && id != i && !is_user_bot(i) && !(get_user_flags(i) & ADMIN_IMMUNITY)){
			num_to_str(i, nts, charsmax(nts));
			menu_additem(bestm, fmt("%n", i), nts);
		}
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public ChoosePlayer_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	g_iPickPlayer[id] = key;
	clcmd_nickmenu(id);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public clcmd_isimbelirle(id){
	new szArg[32];
	read_args(szArg, charsmax(szArg));
	remove_quotes(szArg);

	if(!g_blSecurity[id]){
		client_print_color(id, id, "%s ^3Gecersiz istek.", iChatTag);
		return PLUGIN_HANDLED;
	}
	else if(szArg[0] == EOS){
		client_print_color(id, id, "%s ^3Nick kismini bos birakamazsiniz.", iChatTag);
		clcmd_nickmenu(id);
		return PLUGIN_HANDLED;
	}
	else if(containi(szArg, " ") != -1){
		client_print_color(id, id, "%s ^3Nickin icerisinde bosluk kullanamazsiniz.", iChatTag);
		clcmd_nickmenu(id);
		return PLUGIN_HANDLED;
	}

	copy(g_iChangeName[id], charsmax(g_iChangeName), szArg);
	clcmd_nickmenu(id);
	return PLUGIN_HANDLED;
}