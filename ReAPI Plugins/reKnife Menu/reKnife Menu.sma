#pragma semicolon 1

#include <amxmodx>
#include <reapi>

#define ADMIN_KNIFE    ADMIN_RESERVATION

new const iUpperTag[]  = "\rforum.csd\d -";
new const iChatTag[] = "^4forum.csd :";

new const g_szKnifes[][][] =
{
	{"", ""},      // Ilk satırı elleme.
	{"Bicak Ismi", "models/v_bicakmodel.mdl"},
	{"Bicak Ismi2", "models/v_bicakmodel2.mdl"}   // Alt alta böyle istediğin kadar ekle, en alttaki bıçağın sonuna "," koyma.
};

new g_iActiveKnife[MAX_PLAYERS+1];

public plugin_init()
{
	register_plugin("Knife Menu", "0.1", "` BesTCore;");

	register_clcmd("say /bicakmenu", "clcmd_knifemenu");
	register_clcmd("say /bicak", "clcmd_knifemenu");
	register_clcmd("say /fps", "clcmd_fps");

	RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "RG_CBasePlayerWeapon_DefaultDeploy_Pre", .post = false);
}
public clcmd_knifemenu(const id)
{
	if(~get_user_flags(id) & ADMIN_KNIFE)
	{
		client_print_color(id, id, "%s ^3Bicak menusu sadece klan oyuncularimiza ozeldir, klana katilmak icin TS3: SFV.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new bestm = menu_create(fmt("%s Bicak Menu", iUpperTag), "clcmd_knifemenu_handler");

	for(new i = 1; i < sizeof(g_szKnifes); i++)
	{
		menu_additem(bestm, fmt("%s%s", g_szKnifes[i][0], g_iActiveKnife[id] == i ? " \d[\rAKTIF\d]":""), fmt("%i", i));
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
	return PLUGIN_HANDLED;
}
public clcmd_knifemenu_handler(const id, const menu, const item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	set_entvar(id, var_viewmodel, g_szKnifes[key][1]);
	g_iActiveKnife[id] = key;

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public RG_CBasePlayerWeapon_DefaultDeploy_Pre(const iWeapon, szViewModel[], szWeaponModel[], iAnim, szAnimExt[], skiplocal)
{
	if(get_member(iWeapon, m_iId) != WEAPON_KNIFE)
	{
		return;
	}

	new id = get_member(iWeapon, m_pPlayer);

	if(g_iActiveKnife[id] > 0)
	{
		SetHookChainArg(2, ATYPE_STRING, g_szKnifes[g_iActiveKnife[id]][1]);
	}
}
public clcmd_fps(const id)
{
	g_iActiveKnife[id] = 0;
	client_print_color(id, id, "%s ^3Bicak modellerini kapattiniz.", iChatTag);
}
public plugin_precache()
{
	for(new i = 1; i < sizeof(g_szKnifes); i++)
	{
		precache_model(fmt("%s", g_szKnifes[i][1][0]));
	}
}
public client_disconnected(id)
{
	g_iActiveKnife[id] = 0;
}