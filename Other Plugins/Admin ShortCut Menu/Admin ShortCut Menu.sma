#pragma semicolon 1

#include <amxmodx>

#define ADMIN_SPECIALMENU    ADMIN_BAN

new const g_szMenus[][][] =
{
	// Menudeki Başlık,   Konsola işlenecek kod,   Sebep belirtilecek mi ?  , Süre Belirlenecek mi ?
	{"Ban Menu", "amx_ban", 1, 1},
	{"Kick Menu", "amx_kick", 0, 0},
	{"Slap Menu", "amx_slap", 0, 0}
};

enum _:intEnum
{
	iPickPlayer,
	iMenuTime,
	iMenuReasonType,
	iMenuTimeType
};
new g_int[intEnum][MAX_PLAYERS+1];

new g_szMenuTitle[MAX_PLAYERS+1][30],
	g_szMenuCode[MAX_PLAYERS+1][20],
	g_szMenuReason[MAX_PLAYERS+1][MAX_FMT_LENGTH];

new bool:g_blPickKey[MAX_PLAYERS+1];

public plugin_init()
{
	register_plugin("Admin ShortCut Menu", "0.1", "` BesTCore;");

	register_clcmd("say /adminmenu", "clcmd_adminmenu");

	register_clcmd("Belirle", "clcmd_determine");
}
public clcmd_adminmenu(const id)
{
	new bestm = menu_create("\rAdmin Menu", "clcmd_adminmenu_");

	for(new i = 0; i < sizeof(g_szMenus); i++)
	{
		menu_additem(bestm, fmt("%s", g_szMenus[i][0]), fmt("%i", i));
	}
	menu_display(id, bestm);
}
public clcmd_adminmenu_(const id, const menu, const item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	
	copy(g_szMenuTitle[id], charsmax(g_szMenuTitle[]), g_szMenus[key][0]);
	copy(g_szMenuCode[id], charsmax(g_szMenuCode[]), g_szMenus[key][1][0]);
	g_int[iMenuReasonType][id] = g_szMenus[key][2][0];
	g_int[iMenuTimeType][id] = g_szMenus[key][3][0];
	ShowMenu(id);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public ShowMenu(const id)
{
	new bestm = menu_create(fmt("\r%s", g_szMenuTitle[id]), "ShowMenu_");

	menu_additem(bestm, fmt("Oyuncu:\r %s", fmt(g_int[iPickPlayer][id] ? "%n":"Tikla Belirle", g_int[iPickPlayer][id])), "1");
	
	if(g_int[iMenuTimeType][id] == 1)
	{
		menu_additem(bestm, fmt("Sure:\r %s^n", fmt(g_int[iMenuTime][id] > 0 ? "%i":"Tikla Belirle", g_int[iMenuTime][id])), "2");
	}
	if(g_int[iMenuReasonType][id] == 1)
	{
		menu_additem(bestm, fmt("Sebep:\r %s^n", fmt(g_szMenuReason[id][0] == EOS ? "Tikla Yaz":"%s", g_szMenuReason[id])), "3");
	}
	menu_additem(bestm, "Uygula", "4");

	menu_display(id, bestm);
}
public ShowMenu_(const id, const menu, const item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key)
	{
		case 1:
		{
			ChoosePlayer(id);
		}
		case 2:
		{
			client_cmd(id, "messagemode Belirle");
			g_blPickKey[id] = true;
		}
		case 3:
		{
			client_cmd(id, "messagemode Belirle");
			g_blPickKey[id] = false;
		}
		case 4:
		{
			if(!(g_int[iPickPlayer][id])){
				client_print_color(id, id, "^3Oyuncu secmeden islem yapamazsiniz.");
				return PLUGIN_HANDLED;
			}
			client_cmd(id, "%s %n%s%s", g_szMenuCode[id], g_int[iPickPlayer][id], fmt(g_int[iMenuTime][id] > 0 ? " %i":"", g_int[iMenuTime][id]), fmt(g_szMenuReason[id][0] == EOS ? "":" %s", g_szMenuReason[id]));
			sifirla(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public clcmd_determine(const id)
{
	new szArg[32];
	read_args(szArg, charsmax(szArg));
	remove_quotes(szArg);

	switch(g_blPickKey[id])
	{
		case true:
		{
			new iTime = str_to_num(szArg);
			if(iTime > 0)
			{
				g_int[iMenuTime][id] = iTime;
			}
		}
		case false:
		{
			g_szMenuReason[id] = szArg;
		}
	}
	ShowMenu(id);
	return PLUGIN_HANDLED;
}
public ChoosePlayer(const id)
{
	new bestm = menu_create("\rOyuncu Sec", "ChoosePlayer_");

	for(new i = 1; i <= MaxClients; i++)
	{
		if(is_user_connected(i) && !(get_user_flags(id) & ADMIN_IMMUNITY))
		{
			menu_additem(bestm, fmt("%n", i), fmt("%i", i));
		}
	}
	menu_display(id, bestm);
}
public ChoosePlayer_(const id, const menu, const item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	
	g_int[iPickPlayer][id] = key;
	ShowMenu(id);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public client_disconnected(id)
{
	sifirla(id);
}
public sifirla(const id)
{
	g_int[iPickPlayer][id] = 0;
	g_int[iMenuTime][id] = 0;
	g_int[iMenuReasonType][id] = 0;
	g_int[iMenuTimeType][id] = 0;

	g_blPickKey[id] = false;

	g_szMenuTitle[id][0] = EOS;
	g_szMenuCode[id][0] = EOS;
	g_szMenuReason[id][0] = EOS;
}