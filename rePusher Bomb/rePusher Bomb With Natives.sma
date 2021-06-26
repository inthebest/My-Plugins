#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <hamsandwich>

new g_iRemainigUse[MAX_PLAYERS+1],
	bool:g_blEntityType[MAX_PLAYERS+1];

public plugin_init()
{
	register_plugin("Pusher Bomb", "0.1", "` BesTCore;");

	RegisterHookChain(RG_ThrowSmokeGrenade, "RG_ThrowSmokeGrenade_Post", .post = true);
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_smokegrenade", "Ham_Weapon_SecondaryAttack_Post", .Post = true);
}
public RG_ThrowSmokeGrenade_Post(const index, Float:vecStart[3], Float:vecVelocity[3], Float:time, const usEvent)
{
	if(!(g_blEntityType[index]))
	{
		return;
	}

	new pEntity = GetHookChainReturn(ATYPE_INTEGER);

	if(is_nullent(pEntity))
	{
		return;
	}

	g_iRemainigUse[index]--;
	client_print_color(index, index, "^3Itici bomba firlatildi,^1Kalan kullanim hakki:^4 %i", g_iRemainigUse[index]);
	g_blEntityType[index] = false;

	set_entvar(pEntity, var_owner, index);

	set_task(0.1, "CancelWhenTheEntityStop", pEntity, .flags = "b");

	SetTouch(pEntity, "Touch_Entity");
}
public Touch_Entity(const pEntity, const id)
{
	if(!(is_user_alive(id)))
	{
		return;
	}

	new iOwner = get_entvar(pEntity, var_owner);

	if(iOwner == id || get_member(iOwner, m_iTeam) == get_member(id, m_iTeam))
	{
		return;
	}

	new Float:flVelocity[3];

	get_entvar(pEntity, var_velocity, flVelocity);
	flVelocity[0] += 31;
	set_entvar(id, var_velocity, flVelocity);

	remove_task(pEntity);
	set_entvar(pEntity, var_flags, FL_KILLME);
	//client_print_color(0, 0, "Entity Touched");
}
public CancelWhenTheEntityStop(pEntity)
{
	new Float:flVelocity[3];

	get_entvar(pEntity, var_velocity, flVelocity);

	for(new i = 0; i < 3; i++)
	{
		if(flVelocity[i] == 0.0)
		{
			remove_task(pEntity);
			set_entvar(pEntity, var_flags, FL_KILLME);
			//client_print_color(0, 0, "Entity Stopped.");
			break;
		}
	}
}
public Ham_Weapon_SecondaryAttack_Post(const iWeapon)
{
	if(get_member_game(m_bFreezePeriod)) {
		return HAM_IGNORED;
	}
	if(is_nullent(iWeapon))
	{
		return HAM_IGNORED;
	}
	
	new id = get_member(iWeapon, m_pPlayer);

	if(g_iRemainigUse[id] < 1)
	{
		client_print_color(id, id, "^3Itici bomba hakkin olmadigi icin bomba tipini degistiremezsin.");
		return HAM_IGNORED;
	}

	g_blEntityType[id] = g_blEntityType[id] ? false:true;
	client_print(id, print_center, "Bomba Tipi: %s", g_blEntityType[id] ? "Itici Bomba":"Normal Bomba");
	return HAM_IGNORED;
}
public client_putinserver(id)
{
	g_iRemainigUse[id] = 0;
	g_blEntityType[id] = false;
}
public plugin_natives()
{
	register_native("set_user_pusherbomb", "native_set_user_pusherbomb");
	register_native("get_user_pusherbomb", "native_get_user_pusherbomb");
}
public native_set_user_pusherbomb()
{
	new id = get_param(1);
	new ammount = get_param(2);

	g_iRemainigUse[id] = ammount;
}
public native_get_user_pusherbomb()
{
	new id = get_param(1);

	return g_iRemainigUse[id];
}