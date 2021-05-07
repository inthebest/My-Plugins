#pragma semicolon 1

#include <amxmodx>

new const iUstTag[] = "\dCSDuragi.COM -\r";
new const iAltTag[] = "\dCSD -\w";
new const iChatTag[] = "^4[CSDuragi.COM]";

#define GIRIS_YETKI ADMIN_BAN

new g_fMenuTitle[MAX_PLAYERS+1][30],
	g_fAuthorityTag[MAX_PLAYERS+1][15],
	g_fAuthorityEndTag[MAX_PLAYERS+1][15],
	g_fAuthority[MAX_PLAYERS+1][30];

new g_iTag[MAX_PLAYERS+1][15],
	g_iEndTag[MAX_PLAYERS+1][15],
	g_iLevel[MAX_PLAYERS+1][30],
	g_iTotalMenu;

new g_iName[MAX_PLAYERS+1][30],
	g_iPass[MAX_PLAYERS+1][30];

enum _:Bools{
	bNameTime,
	bPassTime
};
new g_bools[MAX_PLAYERS+1][Bools];

new const szFileName[] = "addons/amxmodx/configs/Yetkiver.ini";
new const szUsersini[] = "addons/amxmodx/configs/users.ini";

public plugin_init(){
	register_plugin("Gelismis Yetkiver [INI]", "0.1", "` BesTCore;");

	Files();

	register_clcmd("say /yetkiver", "clcmd_yetkiver");
	register_clcmd("KullaniciAdi", "clcmd_kullaniciadi");
	register_clcmd("Sifre", "clcmd_sifre");
}
public clcmd_yetkiver(id){
	if(!(get_user_flags(id) & GIRIS_YETKI)){
		client_print_color(id, id, "%s ^3Bu menuye girebilmek icin yeterli yetkiniz bulunmamaktadir.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new bestm = menu_create(fmt("%s Gelismis Yetkiver", iUstTag), "clcmd_yetkiver_");

	for(new i = 1, nts[6]; i < g_iTotalMenu; i++){
		num_to_str(i, nts, charsmax(nts));
		menu_additem(bestm, fmt("%s %s", iAltTag, g_fMenuTitle[i]), nts);
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
	return PLUGIN_HANDLED;
}
public clcmd_yetkiver_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	copy(g_iTag[id], charsmax(g_iTag), g_fAuthorityTag[key]);
	copy(g_iEndTag[id], charsmax(g_iEndTag), g_fAuthorityEndTag[key]);
	copy(g_iLevel[id], charsmax(g_iLevel), g_fAuthority[key]);
	ShowMenu(id);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public ShowMenu(id){
	new bestm = menu_create(fmt("%s Gelismis Yetkiver", iUstTag), "ShowMenu_");

	menu_additem(bestm, fmt("Kullanici Adi: \d[\r%s\d]", fmt(g_iName[id][0] == EOS ? "Girilmedi":"%s", g_iName[id])));
	menu_additem(bestm, fmt("Sifre: \d[\r%s\d]^n", fmt(g_iPass[id][0] == EOS ? "Girilmedi":"%s", g_iPass[id])));
	menu_additem(bestm, fmt("%sYetkiyi Yaz^n", g_iPass[id][0] == EOS ? "\d":"\w"));

	menu_addtext(bestm, fmt("\dKlan Tagi:\r %s%s^n\dYetkileri:\r %s", g_iTag[id], fmt(equal(g_iEndTag[id], "") ? "":"^n\dYetki Tagi:\r %s", g_iEndTag[id]), g_iLevel[id]));

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
	return PLUGIN_HANDLED;
}
public ShowMenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			client_cmd(id, "messagemode KullaniciAdi");
			g_bools[id][bNameTime] = true;
		}
		case 1:{
			if(g_iName[id][0] == EOS){
				client_print_color(id, id, "%s ^3Kullanici adini belirlemeden sifre belirleyemezsiniz.", iChatTag);
				ShowMenu(id);
				return PLUGIN_HANDLED;
			}
			client_cmd(id, "messagemode Sifre");
		}
		case 2:{
			if(g_iName[id][0] == EOS || g_iPass[id][0] == EOS){
				client_print_color(id, id, "%s ^3Kullanici adi veya sifrenizi belirlemeden yetki yazamazsiniz.", iChatTag);
				ShowMenu(id);
				return PLUGIN_HANDLED;
			}
			AuthorityApprove(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public clcmd_kullaniciadi(id){
	new szArg[32];
	read_args(szArg, charsmax(szArg));
	remove_quotes(szArg);

	if(!g_bools[id][bNameTime]){
		client_print_color(id, id, "%s ^3Erisim engellendi.", iChatTag);
		return PLUGIN_HANDLED;
	}
	else if(szArg[0] == EOS){
		client_print_color(id, id, "%s ^3Kullanici adi bos birakilamaz.", iChatTag);
		ShowMenu(id);
		return PLUGIN_HANDLED;
	}
	copy(g_iName[id], charsmax(g_iName[]), szArg);
	g_bools[id][bNameTime] = false;
	g_bools[id][bPassTime] = true;
	ShowMenu(id);
	return PLUGIN_HANDLED;
}
public clcmd_sifre(id){
	new szArg[32];
	read_args(szArg, charsmax(szArg));
	remove_quotes(szArg);

	if(!g_bools[id][bPassTime]){
		client_print_color(id, id, "%s ^3Erisim engellendi.", iChatTag);
		return PLUGIN_HANDLED;
	}
	else if(szArg[0] == EOS){
		client_print_color(id, id, "%s ^3Sifre bos birakilamaz.", iChatTag);
		ShowMenu(id);
		return PLUGIN_HANDLED;
	}
	copy(g_iPass[id], charsmax(g_iPass[]), szArg);
	ShowMenu(id);
	return PLUGIN_HANDLED;
}
public client_disconnected(id){
	g_bools[id][bNameTime] = false;
	g_bools[id][bPassTime] = false;
	g_iName[id][0] = EOS;
	g_iPass[id][0] = EOS;
}
public AuthorityApprove(id){
	new iFile = fopen(szUsersini, "a+");

	if(iFile){
		fprintf(iFile, "^n^"%s %s%s^" ^"%s^" ^"%s^" ^"a^" // Yetkiyi yazan: %n"
		, g_iTag[id], g_iName[id], fmt(equal(g_iEndTag[id], "") ? "":" %s", g_iEndTag[id]), g_iPass[id], g_iLevel[id], id);
		fclose(iFile);
	}
	client_print_color(id, id, "^3Basarili bir sekilde yetki aktiflestirildi.");
	client_print_color(id, id, "^1[^3 Kullanici Adi:^4 %s %s%s^1 ]^3 - ^1[^3 Sifre:^4 %s^1 ]^3 - ^1[^3 Yetkileri:^4 %s^1 ]", g_iTag[id], g_iName[id], fmt(equal(g_iEndTag[id], "") ? "":" %s", g_iEndTag[id]), g_iPass[id], g_iLevel[id]);
	g_bools[id][bNameTime] = false;
	g_bools[id][bPassTime] = false;
	g_iName[id][0] = EOS;
	g_iPass[id][0] = EOS;
	server_cmd("amx_reloadadmins");
	return PLUGIN_HANDLED;
}
Files(){
	new iFile = fopen(szFileName, "r");

	if(iFile){
		new szBuffer[MAX_FMT_LENGTH], i = 1;

		while(fgets(iFile, szBuffer, charsmax(szBuffer))){
			if(szBuffer[0] == EOS || szBuffer[0] == ';'){
				continue;
			}
			parse(szBuffer, g_fMenuTitle[i], charsmax(g_fMenuTitle), g_fAuthorityTag[i], charsmax(g_fAuthorityTag), g_fAuthorityEndTag[i], charsmax(g_fAuthorityEndTag), g_fAuthority[i], charsmax(g_fAuthority));
			i++;
		}
		g_iTotalMenu = i;
		fclose(iFile);
	}
}