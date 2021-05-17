#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new const iChatTag[] = "^4forum.csd :";

new bool:g_blCount[MAX_PLAYERS+1],
	bool:g_blCountSecond[MAX_PLAYERS+1];

new const g_szClcmd[][] = 
{
	"say_team /ct",
	"say_team .ct",
	"say_team !ct",
	"say_team /t",
	"say_team .t",
	"say_team !t"
};

public plugin_init()
{
	register_plugin("Player Change Team Command", "0.1", "` BesTCore;");

	for(new i = 0; i <= 2; i++)
	{
		register_clcmd(g_szClcmd[i], "clcmd_ct");
	}
	for(new i = 3; i <= 5; i++)
	{
		register_clcmd(g_szClcmd[i], "clcmd_te");
	}

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Post", .post = true);
}
public clcmd_ct(const id)
{
	if(ifControl(id, 1))
	{
		return;
	}
	else if(PlayerNumberControl(id))
	{
		g_blCount[id] = true;
		return;
	}
	ChangeTeam(id, 0);
}
public clcmd_te(const id)
{
	if(ifControl(id, 0))
	{
		return;
	}
	else if(PlayerNumberControl(id))
	{
		g_blCount[id] = true;
		return;
	}
	ChangeTeam(id, 1);
}
public ChangeTeam(const id, const iType)
{
	switch(iType)
	{
		case 0:
		{
			if(is_user_alive(id))
			{
				rg_set_user_team(id, TEAM_CT);
				rg_round_respawn(id);
			}
			else
			{
				rg_set_user_team(id, TEAM_CT);
			}
		}
		case 1:
		{
			if(is_user_alive(id))
			{
				rg_set_user_team(id, TEAM_TERRORIST);
				rg_round_respawn(id);
			}
			else
			{
				rg_set_user_team(id, TEAM_TERRORIST);
			}
		}
	}
	g_blCountSecond[id] = true;
}
bool:PlayerNumberControl(const id)
{
	new TeamName:iTeam = get_member(id, m_iTeam);

	new iNum[2];

	iNum[0] = get_member_game(m_iNumCT);
	iNum[1] = get_member_game(m_iNumTerrorist);

	switch(iTeam)
	{
		case TEAM_TERRORIST:
		{
			if(iNum[0] > iNum[1])
			{
				client_print_color(id, id, "%s ^3Karsi takimdaki oyuncular fazla oldugu icin takim degistiremezsiniz.", iChatTag);
				return true;
			}
		}
		case TEAM_CT:
		{
			if(iNum[1] > iNum[0])
			{
				client_print_color(id, id, "%s ^3Karsi takimdaki oyuncular fazla oldugu icin takim degistiremezsiniz.", iChatTag);
				return true;
			}
		}
	}
	return false;
}
bool:ifControl(const id, const iType)
{
	new TeamName:iTeam = get_member(id, m_iTeam);

	if(g_blCountSecond[id])
	{
		client_print_color(id, id, "%s ^3Bu komutu kullandin, 3 el gectikten sonra kullanabilirsin.", iChatTag);
		return true;
	}
	else if(g_blCount[id])
	{
		client_print_color(id, id, "%s ^3Bu komutu bir sonraki el kullanabilirsin.", iChatTag);
		return true;
	}
	switch(iType)
	{
		case 0:
		{
			if(iTeam == TEAM_TERRORIST)
			{
				client_print_color(id, id, "%s ^3Sen zaten te takimindasin.", iChatTag);
				return true;
			}
		}
		case 1:
		{
			if(iTeam == TEAM_CT)
			{
				client_print_color(id, id, "%s ^3Sen zaten ct takimindasin.", iChatTag);
				return true;
			}
		}
	}
	return false;
}
public RG_CSGameRules_RestartRound_Post()
{
	new iCount;

	for(new id = 1; id <= MaxClients; id++)
	{
		if(!is_user_connected(id))
		{
			continue;
		}
		switch(g_blCount[id])
		{
			case true:
			{
				g_blCount[id] = false;
			}
		}

		switch(g_blCountSecond[id])
		{
			case true:
			{
				iCount++;
				switch(iCount)
				{
					case 3:
					{
						iCount = 0;
						g_blCountSecond[id] = false;
					}
				}
			}
		}
	}
}		