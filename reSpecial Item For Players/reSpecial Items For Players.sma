/*
	* Plugin coded by ` BesTCore;
	* Plugin coded for "forum.csduragi.com"
	* Date: 12.07.2021 - Time: 13:21
*/
#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new const g_szItemsFile[] = "addons/amxmodx/configs/Items.ini";

enum any:ItemsData
{
	aFlags,
	aPlayerModelFile[64],
	aKnifeModelFile[64],
	aWeapon[MAX_FMT_LENGTH],
	aMoney[12]
};
new Array:g_aItems;

public plugin_init()
{
	register_plugin("Special Item For Players", "0.1", "` BesTCore;");

	Hooks();
}
// Add player model function.
public RG_CBasePlayer_SetClientUserInfoModel_Pre(const id, infobuffer[], szNewModel[])
{
	new iSize = ArraySize(g_aItems);

	for(new i = 0, aData[ItemsData]; i < iSize; i++)
	{
		ArrayGetArray(g_aItems, i, aData);

		if(~get_user_flags(id) & aData[aFlags])
		{
			continue;
		}

		SetHookChainArg(3, ATYPE_STRING, aData[aPlayerModelFile]);
		break;
	}
}
// Add knife model function.
public RG_CBasePlayerWeapon_DefaultDeploy_Pre(const iWeapon, szViewModel[], szWeaponModel[], iAnim, szAnimExt[], skiplocal)
{
	if(get_member(iWeapon, m_iId) != WEAPON_KNIFE)
	{
		return;
	}

	new id = get_member(iWeapon, m_pPlayer);

	new iSize = ArraySize(g_aItems);

	for(new i = 0, aData[ItemsData]; i < iSize; i++)
	{
		ArrayGetArray(g_aItems, i, aData);

		if(~get_user_flags(id) & aData[aFlags])
		{
			continue;
		}

		SetHookChainArg(2, ATYPE_STRING, aData[aKnifeModelFile]);
		break;
	}
}
public RG_CSGameRules_RestartRound_Post()
{
	static bool:blGameDesc;

	if(!(blGameDesc))
	{
		if(get_member_game(m_iNumCTWins) + get_member_game(m_iNumTerroristWins) > 0)
		{
			blGameDesc = true;
		}
	}

	new iSize = ArraySize(g_aItems);

	new szItems[MAX_FMT_LENGTH][3];

	for(new j = 0, aData[ItemsData]; j < iSize; j++)
	{
		ArrayGetArray(g_aItems, j, aData);

		for(new i = 1; i <= MaxClients; i++)
		{
			if(!(is_user_connected(i)))
			{
				continue;
			}

			if(~get_user_flags(i) & aData[aFlags])
			{
				continue;
			}

			rg_add_account(i, aData[aMoney], AS_ADD); // Add money;

			if(!(blGameDesc))
			{
				for(new k = 0; k < 3; k++)
				{
					strtok2(aData[aWeapon], szItems[k], charsmax(szItems), aData[aWeapon], charsmax(aData), '-');

					rg_give_item(i, fmt("%s", szItems[k]));
					//client_print_color(0,0,"%s", szItems[k]);
				}
			}
		}
	}
}
// Load items data.
public plugin_precache()
{
	g_aItems = ArrayCreate(ItemsData);

	new iFile = fopen(g_szItemsFile, "rt");

	if(iFile)
	{
		new szBuffer[MAX_FMT_LENGTH], aData[ItemsData],
			szFlags[32], szPlayerModelFile[64], szKnifeModelFile[64], szWeapon[MAX_FMT_LENGTH], szMoney[12];

		while(fgets(iFile, szBuffer, charsmax(szBuffer)))
		{
			trim(szBuffer);

			if(szBuffer[0] == EOS || szBuffer[0] == ';')
			{
				continue;
			}

			parse(szBuffer, szFlags, charsmax(szFlags), szPlayerModelFile, charsmax(szPlayerModelFile), szKnifeModelFile, charsmax(szKnifeModelFile), szWeapon, charsmax(szWeapon), szMoney, charsmax(szMoney));

			copy(aData[aFlags], charsmax(aData), szFlags);
			copy(aData[aPlayerModelFile], charsmax(aData), szPlayerModelFile);
			copy(aData[aKnifeModelFile], charsmax(aData), szKnifeModelFile);
			copy(aData[aWeapon], charsmax(aData), szWeapon);
			aData[aMoney] = str_to_num(szMoney);
			//server_print("%s", aData[aWeapon]);

			ArrayPushArray(g_aItems, aData);

			precache_model(fmt("models/player/%s/%s.mdl", szPlayerModelFile, szPlayerModelFile));
			precache_model(szKnifeModelFile);
		}

		fclose(iFile);
	}
}
// Hooks
Hooks()
{
	RegisterHookChain(RG_CBasePlayer_SetClientUserInfoModel, "RG_CBasePlayer_SetClientUserInfoModel_Pre", .post = false);
	RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "RG_CBasePlayerWeapon_DefaultDeploy_Pre", .post = false);

	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_Post", .post = true);
}