#pragma semicolon 1

#include <amxmodx>
#include <reapi>

enum _:ReviveEnum
{
	iKiller,
	iVictim
};
new Array:g_aRevive;

new g_iMeter[MAX_PLAYERS+1],
	g_cvar;

public plugin_init()
{
	register_plugin("Revive When The Killer Dies", "0.1", "` BesTCore;");
	
	g_aRevive = ArrayCreate(ReviveEnum);

	RegisterHookChain(RG_CBasePlayer_Killed, "RG_CBasePlayer_Killed_Post", .post = true);
	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Pre", .post = false);

	bind_pcvar_num(create_cvar("Closing_Day", "16", _, "Eklenti kacinci gunden sonra kapatilsin."), g_cvar);
}
public RG_CBasePlayer_Killed_Post(const this, pevAttacker, iGib)
{
	if(((get_member_game(m_iNumCTWins))+(get_member_game(m_iNumTerroristWins)))+1 >= g_cvar)
	{
		return;
	}

	if(!(is_user_connected(pevAttacker)) || this == pevAttacker)
	{
		return;
	}

	new iCount;
	rg_initialize_player_counts(iCount);

	if(iCount <= 1)
	{
		return;
	}

	new aData[ReviveEnum];

	if(get_member(pevAttacker, m_iTeam) == TEAM_TERRORIST)
	{
		aData[iKiller] = pevAttacker;
		aData[iVictim] = this;

		ArrayPushArray(g_aRevive, aData);
	}

	if(get_member(this, m_iTeam) == TEAM_TERRORIST)
	{
		g_iMeter[this] = 0;

		ArrayControl(this);
	}
}
public ArrayControl(const this)
{
	if(g_iMeter[this] > get_member_game(m_iNumCT))
	{
		return;
	}

	new aData[ReviveEnum], iSize = ArraySize(g_aRevive);

	for(new i = 0; i < iSize; i++)
	{
		ArrayGetArray(g_aRevive, i, aData);
		if(this == aData[iKiller])
		{
			if(!(is_user_alive(aData[iVictim])) && get_member(aData[iVictim], m_iTeam) == TEAM_CT)
			{
				rg_round_respawn(aData[iVictim]);
				client_print_color(0, 0, "^1%n ^3adli mahkum oldugu icin^1 %n^3 adli gardiyan revlendi.", this, aData[iVictim]);
				ArrayDeleteItem(g_aRevive, i);
				break;
			}
		}
	}
	g_iMeter[this]++;
	ArrayControl(this);
}
public RG_CSGameRules_RestartRound_Pre()
{
	ArrayClear(g_aRevive);
}
public plugin_end()
{
	ArrayDestroy(g_aRevive);
}
public client_disconnected(id)
{
	g_iMeter[id] = 0;
}