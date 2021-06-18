#pragma semicolon 1

#include <amxmodx>
#include <reapi>

#define ADMIN_NPC    ADMIN_IMMUNITY   // NPC ayarlarina girmek icin gerekli yetki. * Authority required to edit NPC settings.

new const g_szNPCModels[] = "models/NPCShop.mdl";   // Npc Model.

new const g_szNPCSaveFile[] = "addons/amxmodx/configs/NPCVerileri";    // NPC konum verileri, kayıt dosyası. * NPC location data, save file.

new const szUpperTag[]  = "\rforum.csd\d -";
new const szUnderTag[]  = "\yforum.csd\d -\w";
new const szChatTag[] = "^4forum.csd :";

native entity_set_size(index, const Float:mins[3], const Float:maxs[3]);

enum _:DataEnum
{
	iModelIndex,
	pEntity,
	szMapName[MAX_MAPNAME_LENGTH]
};
new g_data[DataEnum],
	g_iNPCMoney[MAX_PLAYERS+1];

public plugin_init()
{
	register_plugin("Advanced NPC Shop", "0.1", "` BesTCore;");

	register_clcmd("say /npcayar", "clcmd_npcoption");

	get_mapname(g_data[szMapName], charsmax(g_data[szMapName]));

	ActivateNPC();
}
public clcmd_npcoption(const id)
{
	if(!(get_user_flags(id) & ADMIN_NPC))
	{
		client_print_color(id, id, "%s ^3Bu menuye girebilmek icin yetkin yok.", szChatTag);
		return;
	}
	if(!(is_user_alive(id)))
	{
		client_print_color(id, id, "%s ^3NPC ayarlarini canliyken duzenleyebilirsin.", szChatTag);
		return;
	}

	new bestm = menu_create(fmt("%s NPC Ayarlari", szUpperTag), "clcmd_npcoption_handler");

	menu_additem(bestm, fmt("%s NPC'yi Yanina Birak^n", szUnderTag));
	menu_additem(bestm, fmt("%s %sNPC'nin Konumunu Degistir", szUnderTag, IsNPCActive() ? "":"\d"));
	menu_additem(bestm, fmt("%s %sNPC'nin Bakis Acisini Degistir^n", szUnderTag, IsNPCActive() ? "":"\d"));
	menu_additem(bestm, fmt("%s %sNPC'yi Bulundugu Konumda Kaydet^n", szUnderTag, IsNPCActive() ? "":"\d"));
	menu_additem(bestm, fmt("%s %sHaritadaki NPC Verilerini Sil", szUnderTag, IsNPCActive() ? "\r":"\d"));

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public clcmd_npcoption_handler(const id, const menu, const item)
{
	switch(item)
	{
		case 0:
		{
			CreateNPC(id);
			clcmd_npcoption(id);
			client_print_color(id, id, "%s ^3Basarili bir sekilde^4 NPC^3 olusturuldu.", szChatTag);
		}
		case 1:
		{
			if(!(IsNPCActive()))
			{
				client_print_color(id, id, "%s ^3NPC olusturmadan konumunu degistiremezsin.", szChatTag);
				clcmd_npcoption(id);
				return PLUGIN_HANDLED;
			}
			EntityLocationOptions(id);
		}
		case 2:
		{
			if(!(IsNPCActive()))
			{
				client_print_color(id, id, "%s ^3NPC olusturmadan bakis acisini degistiremezsin.", szChatTag);
				clcmd_npcoption(id);
				return PLUGIN_HANDLED;
			}
			new Float:flAngles[3];

			get_entvar(g_data[pEntity], var_angles, flAngles);
			flAngles[1] += 15.0;
			set_entvar(g_data[pEntity], var_angles, flAngles);
			clcmd_npcoption(id);
		}
		case 3:
		{
			if(!(IsNPCActive()))
			{
				client_print_color(id, id, "%s ^3NPC olusturmadan verileri kayit edemezsiniz.", szChatTag);
				clcmd_npcoption(id);
				return PLUGIN_HANDLED;
			}
			WriteDataToFile(g_szNPCSaveFile, 0);
			client_print_color(id, id, "%s ^3Basarili bir sekilde^4 NPC^3 verilerini kayit ettiniz.", szChatTag);
		}
		case 4:
		{
			if(!(IsNPCActive()))
			{
				client_print_color(id, id, "%s ^3Bu haritaya kurulu bir NPC bulunamadi.", szChatTag);
				clcmd_npcoption(id);
				return PLUGIN_HANDLED;
			}
			WriteDataToFile(g_szNPCSaveFile, 1);
			set_entvar(g_data[pEntity], var_flags, FL_KILLME);
			g_data[pEntity] = 0;
			client_print_color(id, id, "%s ^3Basarili bir sekilde haritadaki^4 NPC^3 verilerini sildiniz.", szChatTag);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public EntityLocationOptions(const id)
{
	new bestm = menu_create(fmt("%s NPC Konum Ayarlari", szUpperTag), "EntityLocationOptions_handler");

	menu_additem(bestm, "10 Birim Hareket Ettir \d[\rX Ekseni\d]");
	menu_additem(bestm, "10 Birim Hareket Ettir \d[\rX Ekseni \y(Ters Yonde)\d]^n");
	menu_additem(bestm, "10 Birim Hareket Ettir \d[\rY Ekseni\d]");
	menu_additem(bestm, "10 Birim Hareket Ettir \d[\rY Ekseni \y(Ters Yonde)\d]^n");
	menu_additem(bestm, "10 Birim Hareket Ettir \d[\rZ Ekseni\d]");
	menu_additem(bestm, "10 Birim Hareket Ettir \d[\rZ Ekseni \y(Ters Yonde)\d]^n");

	menu_additem(bestm, "\rNPC Konumunu Kayit Et");

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public EntityLocationOptions_handler(const id, const menu, const item)
{
	if(item != MENU_EXIT || item != 6)
	{

	}
	switch(item)
	{
		case 0..5:
		{
			EntityEditLocation(item);
			EntityLocationOptions(id);
		}
		case 6:
		{
			new Float:flOrigin[3], flAngles[3];

			get_entvar(g_data[pEntity], var_origin, flOrigin);
			get_entvar(g_data[pEntity], var_angles, flAngles);
			
			CreateNPC(0, flOrigin, flAngles);
			client_print_color(id, id, "%s ^3NPC konumu kayit edildi.", szChatTag);
		}
	}

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public EntityEditLocation(const iType)
{
	new Float:flOrigin[3];

	get_entvar(g_data[pEntity], var_origin, flOrigin);

	switch(iType)
	{
		case 0: flOrigin[0] += 10;
		case 1: flOrigin[0] -= 10;
		case 2: flOrigin[1] += 10;
		case 3: flOrigin[1] -= 10;
		case 4: flOrigin[2] += 10;
		case 5: flOrigin[2] -= 10;
	}
	set_entvar(g_data[pEntity], var_origin, flOrigin);
}
// Create a NPC
CreateNPC(const id, {Float, _}:flOrigin[3] = {0.0, 0.0, 0.0}, {Float, _}:flAngles[3] = {0.0, 0.0, 0.0})
{
	if(IsNPCActive())
	{
		set_entvar(g_data[pEntity], var_flags, FL_KILLME);
		g_data[pEntity] = 0;
	}

	g_data[pEntity] = rg_create_entity("func_button");

	if(id)
	{
		get_entvar(id, var_origin, flOrigin);
		flOrigin[0] += 100.0;
	}

	set_entvar(g_data[pEntity], var_origin, flOrigin);
	set_entvar(g_data[pEntity], var_angles, flAngles);

	set_entvar(g_data[pEntity], var_modelindex, g_data[iModelIndex]);
	set_entvar(g_data[pEntity], var_solid, SOLID_BBOX);

	entity_set_size(g_data[pEntity], Float:{-50.0, -50.0, 0.0}, Float:{50.0, 50.0, 50.0});

	SetUse(g_data[pEntity], "EntitySetUse");
}
public EntitySetUse(const pEntity, const activator, const caller, USE_TYPE:useType, Float:value)
{
	//client_print_color(activator, activator, "Entity has been called.");
	ShowNPCShop(activator);
}
// NPC Shop
public ShowNPCShop(const id)
{
	new bestm = menu_create(fmt("%s NPC Market^n\dMevcut NPC Money:\y %i", szUpperTag, g_iNPCMoney[id]), "ShowNPCShop_handler");

	menu_additem(bestm, fmt("%s Silah Marketi", szUnderTag));
	menu_additem(bestm, fmt("%s Can Marketi^n", szUnderTag));
	menu_additem(bestm, fmt("%s NPC Money Kazan", szUnderTag));

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public ShowNPCShop_handler(const id, const menu, const item)
{
	if(item != MENU_EXIT)
	{
		if(!(IsPlayerStandByNPC(id)))
		{
			client_print_color(id, id, "%s ^3Menuyu kullanabilmek icin NPC'nin yaninda olmalisin.", szChatTag);
			return PLUGIN_HANDLED;
		}
	}

	switch(item)
	{
		case 0:
		{
			GunShop(id);
		}
		case 1:
		{
			HealthShop(id);
		}
		case 2:
		{
			EarnNPCMoney(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public GunShop(const id)
{
	new bestm = menu_create(fmt("%s NPC Silah Marketi", szUpperTag), "GunShop_handler");

	menu_additem(bestm, "M4A1 \d[\r10\y NPC Money\d]");
	menu_additem(bestm, "AK47 \d[\r12\y NPC Money\d]");
	menu_additem(bestm, "AWP \d[\r15\y NPC Money\d]");

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public GunShop_handler(const id, const menu, const item)
{
	if(item != MENU_EXIT)
	{
		if(!(IsPlayerStandByNPC(id)))
		{
			client_print_color(id, id, "%s ^3Menuyu kullanabilmek icin NPC'nin yaninda olmalisin.", szChatTag);
			return PLUGIN_HANDLED;
		}
	}

	switch(item)
	{
		case 0:
		{
			if(g_iNPCMoney[id] >= 10)
			{
				g_iNPCMoney[id] -= 10;
				rg_give_item(id, "weapon_m4a1", GT_DROP_AND_REPLACE);
				rg_set_user_bpammo(id, WEAPON_M4A1, 90);
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 M4A1^3 satin aldiniz.", szChatTag);
			}
			else
			{
				client_print_color(id, id, "%s ^3Yetersiz NPC Money.", szChatTag);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			if(g_iNPCMoney[id] >= 12)
			{
				g_iNPCMoney[id] -= 12;
				rg_give_item(id, "weapon_ak47", GT_DROP_AND_REPLACE);
				rg_set_user_bpammo(id, WEAPON_AK47, 90);
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 AK47^3 satin aldiniz.", szChatTag);
			}
			else
			{
				client_print_color(id, id, "%s ^3Yetersiz NPC Money.", szChatTag);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			if(g_iNPCMoney[id] >= 15)
			{
				g_iNPCMoney[id] -= 15;
				rg_give_item(id, "weapon_awp", GT_DROP_AND_REPLACE);
				rg_set_user_bpammo(id, WEAPON_AWP, 30);
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 AWP^3 satin aldiniz.", szChatTag);
			}
			else
			{
				client_print_color(id, id, "%s ^3Yetersiz NPC Money.", szChatTag);
				return PLUGIN_HANDLED;
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public HealthShop(const id)
{
	new bestm = menu_create(fmt("%s NPC Can Marketi", szUpperTag), "HealthShop_handler");

	menu_additem(bestm, "50 HP \d[\r5\y NPC Money\d]");
	menu_additem(bestm, "100 HP \d[\r8\y NPC Money\d]");
	menu_additem(bestm, "150 HP \d[\r12\y NPC Money\d]");

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public HealthShop_handler(const id, const menu, const item)
{
	if(item != MENU_EXIT)
	{
		if(!(IsPlayerStandByNPC(id)))
		{
			client_print_color(id, id, "%s ^3Menuyu kullanabilmek icin NPC'nin yaninda olmalisin.", szChatTag);
			return PLUGIN_HANDLED;
		}
	}

	switch(item)
	{
		case 0:
		{
			if(g_iNPCMoney[id] >= 5)
			{
				g_iNPCMoney[id] -= 5;
				set_entvar(id, var_health, Float:get_entvar(id, var_health) + 50.0);
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 50 HP^3 satin aldiniz.", szChatTag);
			}
			else
			{
				client_print_color(id, id, "%s ^3Yetersiz NPC Money.", szChatTag);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			if(g_iNPCMoney[id] >= 8)
			{
				g_iNPCMoney[id] -= 8;
				set_entvar(id, var_health, Float:get_entvar(id, var_health) + 100.0);
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 100 HP^3 satin aldiniz.", szChatTag);
			}
			else
			{
				client_print_color(id, id, "%s ^3Yetersiz NPC Money.", szChatTag);
				return PLUGIN_HANDLED;
			}
		}
		case 2:
		{
			if(g_iNPCMoney[id] >= 12)
			{
				g_iNPCMoney[id] -= 12;
				set_entvar(id, var_health, Float:get_entvar(id, var_health) + 150.0);
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 150 HP^3 satin aldiniz.", szChatTag);
			}
			else
			{
				client_print_color(id, id, "%s ^3Yetersiz NPC Money.", szChatTag);
				return PLUGIN_HANDLED;
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public EarnNPCMoney(const id)
{
	new bestm = menu_create(fmt("%s NPC Can Marketi", szUpperTag), "EarnNPCMoney_handler");

	menu_additem(bestm, "5 NPC Money \d[\r5000\y Dolar\d]");
	menu_additem(bestm, "10 NPC Money \d[\r8000\y Dolar\d]");
	menu_additem(bestm, "15 NPC Money \d[\r12000\y Dolar\d]");

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public EarnNPCMoney_handler(const id, const menu, const item)
{
	if(item != MENU_EXIT)
	{
		if(!(IsPlayerStandByNPC(id)))
		{
			client_print_color(id, id, "%s ^3Menuyu kullanabilmek icin NPC'nin yaninda olmalisin.", szChatTag);
			return PLUGIN_HANDLED;
		}
	}

	new iMoney = get_member(id, m_iAccount);

	switch(item)
	{
		case 0:
		{
			if(iMoney >= 5000)
			{
				rg_add_account(id, -5000, AS_ADD);
				g_iNPCMoney[id] += 5;
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 5 NPC Money^3 satin aldiniz.", szChatTag);
			}
			else
			{
				client_print_color(id, id, "%s ^3Yetersiz dolar.", szChatTag);
				return PLUGIN_HANDLED;
			}
		}
		case 1:
		{
			if(iMoney >= 8000)
			{
				rg_add_account(id, -8000, AS_ADD);
				g_iNPCMoney[id] += 10;
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 10 NPC Money^3 satin aldiniz.", szChatTag);
			}
			else
			{
				client_print_color(id, id, "%s ^3Yetersiz dolar.", szChatTag);
				return PLUGIN_HANDLED;
			}			
		}
		case 2:
		{
			if(iMoney >= 12000)
			{
				rg_add_account(id, -12000, AS_ADD);
				g_iNPCMoney[id] += 15;
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 15 NPC Money^3 satin aldiniz.", szChatTag);
			}
			else
			{
				client_print_color(id, id, "%s ^3Yetersiz dolar.", szChatTag);
				return PLUGIN_HANDLED;
			}			
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
// NPC data file editing.
WriteDataToFile(const szFileName[], iType)
{
	new szFile[MAX_FMT_LENGTH];

	formatex(szFile, charsmax(szFile), "%s/%s.ini", szFileName, g_data[szMapName]);

	switch(iType)
	{
		case 0:
		{
			if(!(dir_exists(fmt("%s", szFileName))))
			{
				mkdir(fmt("%s", szFileName));
			}

			if(file_exists(szFile))
			{
				delete_file(szFile);
			}

			new iFile = fopen(szFile, "a+");

			if(iFile)
			{
				new Float:flOrigin[3], Float:flAngles[3];

				get_entvar(g_data[pEntity], var_origin, flOrigin);
				get_entvar(g_data[pEntity], var_angles, flAngles);

				for(new i = 0; i < 3; i++)
				{
					fprintf(iFile, "^"%0.2f^" ", flOrigin[i]);
				}
				for(new i = 0; i < 3; i++)
				{
					fprintf(iFile, "^"%0.2f^" ", flAngles[i]);
				}

				fclose(iFile);
			}
		}
		case 1:
		{
			delete_file(szFile);
		}
	}
}
// Create NPC when change map.
ActivateNPC()
{
	new iFile = fopen(fmt("%s/%s.ini", g_szNPCSaveFile, g_data[szMapName]), "rt");

	if(iFile)
	{
		new szBuffer[MAX_FMT_LENGTH], szOrigins[3][32], Float:flOrigin[3], szAngles[3][32], Float:flAngles[3];

		while(fgets(iFile, szBuffer, charsmax(szBuffer)))
		{
			trim(szBuffer);

			if(szBuffer[0] == EOS || szBuffer[0] == ';')
			{
				continue;
			}

			parse(szBuffer, szOrigins[0], charsmax(szOrigins[]), szOrigins[1], charsmax(szOrigins[]), szOrigins[2], charsmax(szOrigins[]),
				szAngles[0], charsmax(szAngles[]), szAngles[1], charsmax(szAngles[]), szAngles[2], charsmax(szAngles[]));

			for(new i = 0; i < 3; i++)
			{
				flOrigin[i] = str_to_float(szOrigins[i]);
				flAngles[i] = str_to_float(szAngles[i]);
			}

			CreateNPC(0, flOrigin, flAngles);
		}
		fclose(iFile);
	}
}
// İs the player stand by NPC.
bool:IsPlayerStandByNPC(const id)
{
	new Float:flOrigin[3], Float:flNPCOrigin[3];

	get_entvar(id, var_origin, flOrigin);
	get_entvar(g_data[pEntity], var_origin, flNPCOrigin);

	return get_distance_f(flOrigin, flNPCOrigin) <= 150.0 ? true:false;
}
// NPC activity check.
bool:IsNPCActive()
{
	return bool:g_data[pEntity];
}
public client_putinserver(id)
{
	g_iNPCMoney[id] = 0;
}
public plugin_precache()
{
	g_data[iModelIndex] = precache_model(fmt("%s", g_szNPCModels));
}