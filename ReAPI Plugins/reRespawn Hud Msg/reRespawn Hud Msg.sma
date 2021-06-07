#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new g_syncobj,
	iNumber;

public plugin_init()
{
	register_plugin("Respawn Hud Msg", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Post", .post = true);

	g_syncobj = CreateHudSyncObj();
}
public RG_CSGameRules_RestartRound_Post()
{
	iNumber = 60;

	set_task(1.0, "StartCountDown", .flags = "b");
}
public StartCountDown()
{
	iNumber--;

	set_hudmessage(255, 255, 42, 0.80, 0.77, 0, _, 1.0, 0.1, 0.1);

	if(iNumber >= 0)
	{
		ShowSyncHudMsg(0, g_syncobj, "Respawn Bitmesine - %i", iNumber);
	}
	else
	{
		ShowSyncHudMsg(0, g_syncobj, "Respawn Bitti.");
		remove_task();
	}
}