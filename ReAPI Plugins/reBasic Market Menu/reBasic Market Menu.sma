#pragma semicolon 1

#include <amxmodx>
#include <reapi>

enum (+= 1337)
{
	TASK_FASTWALK = 1337,
	TASK_GRAVITY,
	TASK_INVISIBILITY
}

new g_cvars[6],
	Float:g_flFastWalk[MAX_PLAYERS+1];

public plugin_init()
{
	register_plugin("Market Menu", "0.1", "` BesTCore;");

	register_clcmd("say /market", "clcmd_market");

	ReapiHooks();
	Cvars();
}
public clcmd_market(const id)
{
	new bestm = menu_create("\rMarket Menu", "clcmd_market_handler");

	menu_additem(bestm, fmt("Hizli Kosma 15 Saniye \d[\r%i\y $\d]", g_cvars[0]));
	menu_additem(bestm, fmt("Gravity 20 Saniye \d[\r%i\y $\d]", g_cvars[1]));
	menu_additem(bestm, fmt("+50 HP \d[\r%i\y $\d]", g_cvars[2]));
	menu_additem(bestm, fmt("Gorunmezlik 15 Saniye \d[\r%i\y $\d]", g_cvars[3]));
	menu_additem(bestm, fmt("Rakibin Kiligina Girme \d[\r%i\y $\d]", g_cvars[4]));
	menu_additem(bestm, fmt("He Grenade 1 Adet \d[\r%i\y $\d]", g_cvars[5]));

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public clcmd_market_handler(const id, const iMenu, const iItem)
{
	switch(iItem)
	{
		case 0:
		{
			if(MoneyEnough(id, g_cvars[iItem]))
			{
				set_entvar(id, var_maxspeed, 350.0);
				g_flFastWalk[id] = 350.0;
				set_task(15.0, "FastWalkEnd", id + TASK_FASTWALK);
				client_print_color(id, id, "^3Basarili bir sekilde^4 Hizli Yurume^3 satin aldiniz.");
			}
		}
		case 1:
		{
			if(MoneyEnough(id, g_cvars[iItem]))
			{
				set_entvar(id, var_gravity, 0.5);
				client_print_color(id, id, "^3Basarili bir sekilde^4 Gravity^3 satin aldiniz.");
				set_task(20.0, "GravityEnd", id + TASK_GRAVITY);
			}
		}
		case 2:
		{
			if(MoneyEnough(id, g_cvars[iItem]))
			{
				set_entvar(id, var_health, Float:get_entvar(id, var_health) + 50.0);
				client_print_color(id, id, "^3Basarili bir sekilde^4 50 HP^3 satin aldiniz.");
			}
		}
		case 3:
		{
			if(MoneyEnough(id, g_cvars[iItem]))
			{
				set_entvar(id, var_effects, get_entvar(id, var_effects) | EF_NODRAW);
				client_print_color(id, id, "^3Basarili bir sekilde^4 Gorunmezlik^3 satin aldiniz.");
				set_task(15.0, "InvisibilityEnd", id + TASK_INVISIBILITY);
			}
		}
		case 4..5:
		{
			new TeamName:iTeam = get_member(id, m_iTeam);

			switch(iItem)
			{
				case 4:
				{
					if(iTeam != TEAM_TERRORIST)
					{
						client_print_color(id, id, "^3Bu ozellik terroristlere ozeldir.");
						return PLUGIN_HANDLED;
					}

					if(MoneyEnough(id, g_cvars[iItem]))
					{
						rg_set_user_model(id, "gign");
						client_print_color(id, id, "^3Basarili bir sekilde^4 Rakibin kiligina girme^3 satin aldiniz.");
					}
				}
				case 5:
				{
					if(iTeam != TEAM_CT)
					{
						client_print_color(id, id, "^3Bu ozellik ct takimina ozeldir.");
						return PLUGIN_HANDLED;
					}

					if(MoneyEnough(id, g_cvars[iItem]))
					{
						rg_give_item(id, "weapon_hegrenade");
						client_print_color(id, id, "^3Basarili bir sekilde^4 Bomba^3 satin aldiniz.");
					}
				}
			}
		}
	}
	menu_destroy(iMenu);
	return PLUGIN_HANDLED;
}
// Taskid
public FastWalkEnd(Taskid)
{
	new id = Taskid - TASK_FASTWALK;

	if(g_flFastWalk[id])
	{
		g_flFastWalk[id] = 0.0;
		set_entvar(id, var_maxspeed, 250.0);
		client_print_color(id, id, "^3Hizli yurume suresi sona erdi.");
	}
}
public InvisibilityEnd(Taskid)
{
	new id = Taskid - TASK_INVISIBILITY;

	set_entvar(id, var_effects, get_entvar(id, var_effects) & ~EF_NODRAW);
	client_print_color(id, id, "^3Gorunmezligin suresi doldu.");
}
public GravityEnd(Taskid)
{
	new id = Taskid - TASK_GRAVITY;

	set_entvar(id, var_gravity, 0.8);
	client_print_color(id, id, "^3Gravity ozelliginin suresi doldu.");
}
// Hooks
public RG_CBasePlayer_ResetMaxSpeed_Pre(const id)
{
	if(g_flFastWalk[id])
	{
		set_entvar(id, var_maxspeed, g_flFastWalk[id]);
		return HC_SUPERCEDE;
	}
	return HC_CONTINUE;
}
public RG_CBasePlayer_Spawn_Post(const id)
{
	if(get_member(id, m_bJustConnected))
	{
		return;
	}

	if(g_flFastWalk[id])
	{
		g_flFastWalk[id] = 0.0;
	}
	rg_reset_user_model(id);
}
// Shortcut
bool:MoneyEnough(const id, const iMoney)
{
	if(get_member(id, m_iAccount) >= iMoney)
	{
		rg_add_account(id, -iMoney, AS_ADD);
		return true;
	}
	return false;
}
public client_disconnected(id)
{
}
// Content
ReapiHooks()
{
	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer_Spawn_Post", .post = true);
	RegisterHookChain(RG_CBasePlayer_ResetMaxSpeed, "RG_CBasePlayer_ResetMaxSpeed_Pre", .post = false);
}
Cvars()
{
	bind_pcvar_num(create_cvar("HizliKosma_Fiyat", "10"), g_cvars[0]);
	bind_pcvar_num(create_cvar("Gravity_Fiyat", "10"), g_cvars[1]);
	bind_pcvar_num(create_cvar("Can_Fiyat", "10"), g_cvars[2]);
	bind_pcvar_num(create_cvar("Gorunmezlik_Fiyat", "10"), g_cvars[3]);
	bind_pcvar_num(create_cvar("KilikDegistirme_Fiyat", "10"), g_cvars[4]);
	bind_pcvar_num(create_cvar("HeGrenade_Fiyat", "10"), g_cvars[5]);
}