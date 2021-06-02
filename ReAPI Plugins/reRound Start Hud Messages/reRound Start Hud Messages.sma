#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new g_sync[3],
	szMapName[MAX_MAPNAME_LENGTH];

public plugin_init()
{
	register_plugin("Round Start Hud Messages", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Post", .post = true);

	for(new i = 0; i < 3; i++)
	{
		g_sync[i] = CreateHudSyncObj();
	}

	get_mapname(szMapName, charsmax(szMapName));
}
public RG_CSGameRules_RestartRound_Post()
{
	new iData[2];
	iData[0] = ((get_member_game(m_iNumCTWins))+(get_member_game(m_iNumTerroristWins)))+1;
	iData[1] = get_playersnum();

	set_hudmessage(127, 255, 0, 0.45, 0.45, 0, _, 1.0, 0.1, 0.1);
	ShowSyncHudMsg(0, g_sync[0], "Round [ %i ]", iData[0]);

	set_hudmessage(255, 0, 0, 0.45, 0.45, 0, _, 1.0, 0.1, 0.1);
	ShowSyncHudMsg(0, g_sync[1], "^nHarita [ %s ]", szMapName);

	set_hudmessage(255, 255, 170, 0.45, 0.45, 0, _, 1.0, 0.1, 0.1);
	ShowSyncHudMsg(0, g_sync[2], "^n^nOyuncular [ %i/32 ]", iData[1]);

	set_task(5.0, "ClearHudMessages");
}
public ClearHudMessages()
{
	for(new i = 0; i < 3; i++)
	{
		ClearSyncHud(0, g_sync[i]);
	}
}