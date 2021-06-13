#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <engine>

new const g_szModel[] = "models/reyna_orb.mdl";

new Float:g_flHeOrigin[3],
	iEnt,
	g_iModelIndex;

public plugin_init()
{
	register_plugin("Entity Test", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CBasePlayer_ThrowGrenade, "RG_CBasePlayer_ThrowGrenade_Post", .post = true);
}
public RG_CBasePlayer_ThrowGrenade_Post(const this, const grenade, Float:vecSrc[3], Float:vecThrow[3], Float:time, const usEvent)
{
	set_task(1.8, "GetHeGrenadeOrigin", grenade);
}
public GetHeGrenadeOrigin(const iGrenade)
{
	get_entvar(iGrenade, var_origin, g_flHeOrigin);

	set_task(1.0, "CreateModel");
}
public CreateModel()
{
	iEnt = rg_create_entity("func_button");

	set_entvar(iEnt, var_origin, g_flHeOrigin);

	set_entvar(iEnt, var_solid, SOLID_BBOX);
	set_entvar(iEnt, var_model, g_szModel);
	set_entvar(iEnt, var_modelindex, g_iModelIndex);

	entity_set_size(iEnt, Float:{-16.0, -10.0, 0.0}, Float:{16.0, 10.0, 30.0});

	set_task(1.0, "GiveHealth");
}
public GiveHealth()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		set_task(1.0, "GiveHealthSecond", i, .flags = "b");
	}
}
public GiveHealthSecond(const id)
{
	if(!is_nullent(iEnt))
	{
		remove_task();
	}

	new Float:flOrigin[3];

	get_entvar(id, var_origin, flOrigin);

	if((g_flHeOrigin[0] + 300.0) <= flOrigin[0])
	{
		set_entvar(id, var_health, Float:get_entvar(id, var_health) + 10.0);
	}
}
public plugin_precache()
{
	g_iModelIndex = precache_model(fmt("%s", g_szModel));
}