#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new bool:blPlayerToSlay[MAX_PLAYERS+1];

public plugin_init()
{
	register_plugin("Slay Menu", "0.1", "` BesTCore;");

	register_clcmd("say /slaymenu", "clcmd_slaymenu");
	register_clcmd("say /kurtul", "clcmd_getoff");

	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer_Spawn_Post", .post = true);
}
public clcmd_slaymenu(const id)
{
	new bestm = menu_create("\rSlay Menu", "clcmd_slaymenu_handler");

	for(new i = 1; i <= MaxClients; i++)
	{
		if(!(is_user_connected(i)) || get_user_flags(i) & ADMIN_IMMUNITY || blPlayerToSlay[i])
		{
			continue;
		}
		menu_additem(bestm, fmt("%n", i), fmt("%i", i));
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public clcmd_slaymenu_handler(const id, const menu, const item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	blPlayerToSlay[key] = true;

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public RG_CBasePlayer_Spawn_Post(const this)
{
	if(get_member(this, m_bJustConnected))
	{
		return;
	}

	if(blPlayerToSlay[this])
	{
		set_task(1.0, "ToSlay", this);
	}
}
public ToSlay(const this)
{
	user_kill(this);
	set_entvar(this, var_frags, get_entvar(this, var_frags) + 1);
	client_print_color(this, this, "^4Admin tarafindan her el slaylaniyorsunuz.");
}
public clcmd_getoff(const id)
{
	blPlayerToSlay[id] = false;
	client_print_color(id, id, "^4Kurtuldugunuz icin artik slaylanmayacaksiniz.");
}
public client_disconnected(id)
{
	blPlayerToSlay[id] = false;
}