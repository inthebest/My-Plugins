#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <reapi_reunion>

new g_cvar;

new bool:g_blIsUserSteam[MAX_PLAYERS+1];

public plugin_init()
{
	register_plugin("Item in Random Round For Steam", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Pre", .post = false);

	bind_pcvar_num(create_cvar("KacEldeBirItem", "4", _, "Kac elde bir item versin ?"), g_cvar);
}
public RG_CSGameRules_RestartRound_Pre()
{
	static iCount = 0;

	if(get_member_game(m_bCompleteReset))
	{
		//server_print("RESTART");
		iCount = 0;
	}

	iCount++;
	//server_print("ROUND = %i", iCount);
	if(iCount >= g_cvar)
	{
		for(new id = 1; id <= MaxClients; id++)
		{
			if(g_blIsUserSteam[id])
			{
				GiveItem(id);
			}
		}
		//server_print("ITEM VERILDI");
		client_print_color(0, 0, "^3Steam olan oyunculara^4 %i^3 round gectigi icin rastgele item verildi.", g_cvar);
		iCount = 0;
	}
}
public GiveItem(const id)
{
	new iRandom = random_num(0, 2);

	switch(iRandom)
	{
		case 0:
		{
			rg_add_account(id, 500, AS_ADD);
		}
		case 1:
		{
			set_entvar(id, var_armorvalue, Float:get_entvar(id, var_armorvalue) + 100.0);
		}
		case 2:
		{
			rg_give_item(id, "weapon_smokegrenade");
			rg_give_item(id, "weapon_hegrenade");
			rg_give_item(id, "weapon_flashbang");
		}
	}
}
public client_putinserver(id)
{
	if(is_user_steam(id))
	{
		g_blIsUserSteam[id] = true;
	}
}
public client_disconnected(id)
{
	g_blIsUserSteam[id] = false;
}