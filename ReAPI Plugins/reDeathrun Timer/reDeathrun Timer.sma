#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new g_syncobj,
	g_iTimer[MAX_PLAYERS+1];

public plugin_init()
{
	register_plugin("Deathrun Timer", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer_Spawn_Post", .post = true);

	g_syncobj = CreateHudSyncObj();
}
public RG_CBasePlayer_Spawn_Post(const id)
{
	if(get_member(id, m_bJustConnected))
	{
		return;
	}

	g_iTimer[id] = 0;

	set_task(1.0, "StartTime", id, .flags = "b");
}
public StartTime(id)
{
	g_iTimer[id]++;

	set_hudmessage(255, 255, 42, 0.15, 0.77, 0, _, 1.0, 0.1, 0.1);
	ShowSyncHudMsg(0, g_syncobj, "Deathrun Timer^n           %i", g_iTimer[id]);
	
	if(!(is_user_alive(id)))
	{
		remove_task(id);
	}
}