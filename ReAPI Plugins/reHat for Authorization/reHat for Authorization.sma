#pragma semicolon 1

#include <amxmodx>
#include <reapi>

#define ADMIN_HAT     ADMIN_RCON

new const g_szModel[][] =
{
	"models/awesome.mdl",     // Terrorist Hat.
	"models/barrel.mdl"      // Counter-Terrorst Hat.
};

new g_iEnt[MAX_PLAYERS+1],
	g_iModelIndex[sizeof(g_szModel)];

public plugin_init()
{
	register_plugin("Hat for Authorization", "0.1", "` BesTCore;");
	
	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer_Spawn_Post", .post = true);
}
public RG_CBasePlayer_Spawn_Post(id)
{
	if(get_member(id, m_bJustConnected))
	{
		return;
	}
	
	if(get_user_flags(id) & ADMIN_HAT)
	{
		CreateModel(id);
	}
}
public CreateHat(const id)
{
	g_iEnt[id] = rg_create_entity("info_target");

	CreateModel(id);
}
public CreateModel(id)
{
	new TeamName:iTeam = get_member(id, m_iTeam);

	switch(iTeam)
	{
		case TEAM_TERRORIST:
		{
			set_entvar(g_iEnt[id], var_modelindex, g_iModelIndex[0]);
		}
		case TEAM_CT:
		{
			set_entvar(g_iEnt[id], var_modelindex, g_iModelIndex[1]);
		}
	}
	set_entvar(g_iEnt[id], var_movetype, MOVETYPE_FOLLOW);
	set_entvar(g_iEnt[id], var_aiment, id);
}
RemoveTheHat(const id)
{
	if(!is_nullent(g_iEnt[id]))
	{
		set_entvar(g_iEnt[id], var_flags, FL_KILLME);
		g_iEnt[id] = 0;
	}
}
public client_putinserver(id)
{
	if(get_user_flags(id) & ADMIN_HAT)
	{
		CreateHat(id);
	}
}
public client_disconnected(id)
{
	RemoveTheHat(id);
}
public plugin_precache()
{
	for(new i = 0; i < sizeof(g_szModel); i++)
	{
		g_iModelIndex[i] = precache_model(fmt("%s", g_szModel[i]));
	}
}