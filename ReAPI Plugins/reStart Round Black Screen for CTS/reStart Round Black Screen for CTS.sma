#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <screenfade_util>

new Float:g_cvar;

public plugin_init()
{
	register_plugin("Start Round Black Screen for CTS", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Post", .post = true);

	bind_pcvar_float(create_cvar("BlackScreen_Time", "20.0", _, "Ekran karartma suresi"), g_cvar);
}
public RG_CSGameRules_RestartRound_Post()
{
	if(g_cvar < 1)
	{
		return;
	}

	for(new i = 1; i <= MaxClients; i++)
	{
		if(!(is_user_alive(i)))
		{
			continue;
		}

		remove_task(i);

		UTIL_FadeToBlack(i);
		set_task(g_cvar, "ScreenFadeOff", i);
	}
}
public ScreenFadeOff(const id)
{
	UTIL_ScreenFade(id);
}
public client_disconnected(id)
{
	remove_task(id);
}