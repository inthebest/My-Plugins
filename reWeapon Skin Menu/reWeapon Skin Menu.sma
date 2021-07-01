/*
	* Plugin created by ` BesTCore;
	* Plugin created for "forum.csduragi.com"
	* Date: 17.06.2021 - 23:32

	* Update 0.2; If you click on the models you use once more, the model is closed. Date: 29.06.2021 - Time: 13.01
	* Update 0.3; Added default weapon model setting to weapons. Date: 29.06.2021 - Time: 13.16
*/
#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new const szUpperTag[]  = "\rforum.csd\d -";
new const szChatTag[] = "^4forum.csd :";

#define iMaxSkin  30   // Kac adet skin varsa "+1" fazlası. !! Aksi takdirde hata çıkarabilir.

new const g_szSkinsFile[] = "addons/amxmodx/configs/Skins.ini";   // Skin verilerinin kayıt yolu. * The storage location of the skin data.
new const g_szDefaultSkinsFile[] = "addons/amxmodx/configs/DefaultSkins.ini";   // Default skin verilerinin kayıt yolu. * The storage location of the default skin data.

enum _:SkinData
{
	szSkinName[32],
	szSkinFile[64],
	szSkinWeaponCode[32]
};
new Array:g_aSkin;

enum _:DefaultSkinData
{
	szDefaultSkinFile[64],
	szDefaultSkinWeaponCode[32]
};
new Array:g_aDefaultSkin;
	
new	bool:g_blActiveSkin[MAX_PLAYERS+1][iMaxSkin];

public plugin_init()
{
	register_plugin("Weapon Skin Menu", "0.3", "` BesTCore;");

	register_clcmd("say /skin", "clcmd_skins");
	register_clcmd("nightvision", "clcmd_skins");

	RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "RG_CBasePlayerWeapon_DefaultDeploy_Pre", .post = false);
}
public clcmd_skins(const id)
{
	new bestm = menu_create(fmt("%s Skin Menu", szUpperTag), "clcmd_skins_handler"), iSize = ArraySize(g_aSkin);

	for(new i = 0, aData[SkinData]; i < iSize; i++)
	{
		ArrayGetArray(g_aSkin, i, aData);

		menu_additem(bestm, fmt("%s%s", aData[szSkinName], g_blActiveSkin[id][i] ? " \d[\yAKTIF\d]":""), fmt("%d", i));
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public clcmd_skins_handler(const id, const iMenu, const iItem)
{
	if(iItem != MENU_EXIT)
	{
		SkinActivated(id, iItem);
	}

	menu_destroy(iMenu);
	return PLUGIN_HANDLED;
}
// Skin activation function.
SkinActivated(const id, const iValue)
{
	new aDataPlayer[SkinData];

	ArrayGetArray(g_aSkin, iValue, aDataPlayer);

	replace_string(aDataPlayer[szSkinName], charsmax(aDataPlayer), "\r", "");   // Remove color codes.
	replace_string(aDataPlayer[szSkinName], charsmax(aDataPlayer), "\w", "");
	replace_string(aDataPlayer[szSkinName], charsmax(aDataPlayer), "\d", "");
	replace_string(aDataPlayer[szSkinName], charsmax(aDataPlayer), "\y", "");

	if(g_blActiveSkin[id][iValue])
	{
		g_blActiveSkin[id][iValue] = false;
		client_print_color(id, id, "%s ^3Basarili bir sekilde^4 %s ^3adli skini kullanmayi biraktiniz.", szChatTag, aDataPlayer[szSkinName]);
	}
	else
	{
		g_blActiveSkin[id][iValue] = true;
		client_print_color(id, id, "%s ^3Basarili bir sekilde^4 %s ^3adli skini kullanmaya basladiniz.", szChatTag, aDataPlayer[szSkinName]);
	}

	new iSize = ArraySize(g_aSkin);

	for(new i = 0, aData[SkinData]; i < iSize; i++)
	{
		ArrayGetArray(g_aSkin, i, aData);

		if(equal(aData[szSkinWeaponCode], aDataPlayer[szSkinWeaponCode]) && i != iValue)   // Remove other skins from the weapon.
		{
			g_blActiveSkin[id][i] = false;
		}
	}
}
public RG_CBasePlayerWeapon_DefaultDeploy_Pre(const iWeapon, szViewModel[], szWeaponModel[], iAnim, szAnimExt[], skiplocal)
{
	new id = get_member(iWeapon, m_pPlayer);

	new bool:blFound, iSize = ArraySize(g_aSkin);

	new iWeaponIdType = get_member(iWeapon, m_iId);

	for(new i = 0, aData[SkinData]; i < iSize; i++)
	{
		ArrayGetArray(g_aSkin, i, aData);

		if(iWeaponIdType != get_weaponid(aData[szSkinWeaponCode]) || !(g_blActiveSkin[id][i]))
		{
			continue;
		}

		SetHookChainArg(2, ATYPE_STRING, aData[szSkinFile]);   // Add your skin.
		blFound = true;
	}

	if(!(blFound))
	{
		new iSize2 = ArraySize(g_aDefaultSkin);

		for(new i = 0, aDefaultData[DefaultSkinData]; i < iSize2; i++)
		{
			ArrayGetArray(g_aDefaultSkin, i, aDefaultData);

			if(iWeaponIdType != get_weaponid(aDefaultData[szDefaultSkinWeaponCode]))
			{
				continue;
			}

			SetHookChainArg(2, ATYPE_STRING, aDefaultData[szDefaultSkinFile]);
		}
	}
}
public plugin_precache()
{
	g_aSkin = ArrayCreate(SkinData);
	g_aDefaultSkin = ArrayCreate(DefaultSkinData);

	ReadFile(g_szSkinsFile, true);
	ReadFile(g_szDefaultSkinsFile, false);
}
ReadFile(const szFile[], const bool:blType)
{
	new iFile = fopen(szFile, "rt");

	if(iFile)
	{
		new szBuffer[MAX_FMT_LENGTH];

		if(blType)
		{
			new pSkinName[32], pSkinFile[64], pSkinWeaponCode[32], aData[SkinData];

			while(fgets(iFile, szBuffer, charsmax(szBuffer)))
			{
				trim(szBuffer);

				if(szBuffer[0] == EOS || szBuffer[0] == ';')
				{
					continue;
				}

				parse(szBuffer, pSkinName, charsmax(pSkinName), pSkinFile, charsmax(pSkinFile), pSkinWeaponCode, charsmax(pSkinWeaponCode));

				copy(aData[szSkinName], charsmax(aData), pSkinName);
				copy(aData[szSkinFile], charsmax(aData), pSkinFile);
				copy(aData[szSkinWeaponCode], charsmax(aData), pSkinWeaponCode);

				ArrayPushArray(g_aSkin, aData);

				precache_model(fmt("%s", pSkinFile));
			}
		}
		else
		{
			new pDefaultSkinFile[64], pDefaultSkinWeaponCode[32], aData[DefaultSkinData];

			while(fgets(iFile, szBuffer, charsmax(szBuffer)))
			{
				trim(szBuffer);

				if(szBuffer[0] == EOS || szBuffer[0] == ';')
				{
					continue;
				}

				parse(szBuffer, pDefaultSkinFile, charsmax(pDefaultSkinFile), pDefaultSkinWeaponCode, charsmax(pDefaultSkinWeaponCode));

				copy(aData[szDefaultSkinFile], charsmax(aData), pDefaultSkinFile);
				copy(aData[szDefaultSkinWeaponCode], charsmax(aData), pDefaultSkinWeaponCode);

				ArrayPushArray(g_aDefaultSkin, aData);

				precache_model(fmt("%s", pDefaultSkinFile));
			}
		}
		fclose(iFile);
	}
}
public plugin_end()
{
	ArrayDestroy(g_aSkin);
	ArrayDestroy(g_aDefaultSkin);
}