	#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <nvault>

new g_vault,
	g_iLevel[MAX_PLAYERS+1],
	g_iXP[MAX_PLAYERS+1],
	syncobj;

enum _:cvarenum 
{
	cvKillXP,
	cvDeadXP,
	cvXPLimited
};
new g_cvars[cvarenum];

public plugin_init()
{
	register_plugin("Level System", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CBasePlayer_Killed, "RG_CBasePlayer_Killed_Post", .post = true);

	bind_pcvar_num(create_cvar("KillBasinaXP", "2", _, "Kill alinca gelecek xp"), g_cvars[cvKillXP]);
	bind_pcvar_num(create_cvar("OlunceGidecekXPXP", "2", _, "Olunce kac xp gitsin."), g_cvars[cvDeadXP]);
	bind_pcvar_num(create_cvar("XPSinir", "20", _, "Kac xp olunca level atlasin."), g_cvars[cvXPLimited]);

	syncobj = CreateHudSyncObj();
}
public RG_CBasePlayer_Killed_Post(const this, pevAttacker, iGib)
{
	if(!(is_user_connected(this) || is_user_connected(pevAttacker)) || this == pevAttacker)
	{
		return;
	}
	g_iXP[pevAttacker] += g_cvars[cvKillXP];
	g_iXP[this] -= g_cvars[cvDeadXP];

	if(g_iXP[pevAttacker] >= g_cvars[cvXPLimited])
	{
		g_iLevel[pevAttacker]++;
		g_iXP[pevAttacker] = 0;
		client_print_color(0, 0, "^1%n ^3adli oyuncu level atladi^1,^3yeni leveli^4 %d.", pevAttacker, g_iLevel[pevAttacker]);
	}
	if(g_iXP[this] < 0)
	{
		g_iXP[this] = 0;
	}
}
public client_authorized(id, const authid[])
{
	set_task(1.0, "HudMessages", id, .flags = "b");

	g_iLevel[id] = nvault_get(g_vault, fmt("%s-level", authid));
	g_iXP[id] = nvault_get(g_vault, fmt("%s-xp", authid));
}
public HudMessages(const id)
{
	set_hudmessage(255, 255, 255, 0.01, 0.18, 0, _, 1.5);
	ShowSyncHudMsg(id, syncobj, "[ Level: %d - XP: %d/%d ]", g_iLevel[id], g_iXP[id], g_cvars[cvXPLimited]);
}
public client_disconnected(id)
{
	savenvault(id);
	g_iLevel[id] = 0;
	g_iXP[id] = 0;
}
public savenvault(const id)
{
	new authid[MAX_AUTHID_LENGTH];
	get_user_authid(id, authid, charsmax(authid));

	nvault_pset(g_vault, fmt("%s-level", authid), fmt("%i", g_iLevel[id]));
	nvault_pset(g_vault, fmt("%s-xp", authid), fmt("%i", g_iXP[id]));
}
// native
public plugin_natives()
{
	register_native("get_user_rank", "native_get_user_rank");
}
public native_get_user_rank()
{
	new id = get_param(1);

	return g_iLevel[id];
}
// nvault
public plugin_cfg()
{
	g_vault = nvault_open("Level System");
}
public plugin_end()
{
	nvault_close(g_vault);
}