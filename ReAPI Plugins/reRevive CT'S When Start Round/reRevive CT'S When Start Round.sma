#pragma semicolon 1

#include <amxmodx>
#include <reapi>

public plugin_init()
{
	register_plugin("Revive CT'S When Start Round", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Post", .post = true);
}
public RG_CSGameRules_RestartRound_Post()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!(is_user_connected(i)) || get_member(i, m_iTeam) != TEAM_CT)
		{
			continue;
		}
		rg_round_respawn(i);
	}
}