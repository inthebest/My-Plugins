/*
	* Plugin coded by ` BesTCore;
	* Plugin coded for "forum.csduragi.com"
	* Date: 30.06.2021 - Time: 17:08
*/	
#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new g_iEntityValue,
	g_iEntityThinkValue[MAX_FMT_LENGTH],
	bool:g_blPlayerIsInfected[MAX_PLAYERS+1],
	g_msgid;

public plugin_init()
{
	register_plugin("Infection Bomb", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CGrenade_ExplodeSmokeGrenade, "RG_CGrenade_ExplodeSmokeGrenade_Post", .post = true);

	g_msgid = get_user_msgid("ScreenFade");
}
public RG_CGrenade_ExplodeSmokeGrenade_Post(const iEntity)
{
	g_iEntityValue++;

	if(g_iEntityValue >= MAX_FMT_LENGTH)
	{
		g_iEntityValue = 0;
	}

	SetThink(iEntity, "EntityThink");
	set_entvar(iEntity, var_frame, g_iEntityValue);
}
public EntityThink(const iEntity)
{
	new iEntValue = get_entvar(iEntity, var_frame);

	if(g_iEntityThinkValue[iEntValue] <= 10)
	{
		g_iEntityThinkValue[iEntValue]++;

		new Float:flEntOrigin[3];

		get_entvar(iEntity, var_origin, flEntOrigin);

		for(new i = 1, Float:flOrigin[3]; i <= MaxClients; i++)
		{
			if(!(is_user_alive(i)) || g_blPlayerIsInfected[i])
			{
				continue;
			}

			get_entvar(i, var_origin, flOrigin);

			if(get_distance_f(flEntOrigin, flOrigin) < 250.0 && get_entvar(i, var_health) > 10.0)
			{
				//client_print_color(0, 0, "Enfeksiyon bulasti.");
				InfectedThePlayer(i);
				g_blPlayerIsInfected[i] = true;
			}
		}
	}
	else
	{
		g_iEntityThinkValue[iEntValue] = 0;
		set_entvar(iEntity, var_flags, FL_KILLME);
		return;
	}

	set_entvar(iEntity, var_nextthink, get_gametime() + 0.5);
}
public InfectedThePlayer(const id)
{
	g_blPlayerIsInfected[id] = true;

	GiveEffects(id, _:{0, 255, 0});

	rg_set_user_rendering(id, {0.0, 255.0, 0.0});

	set_task(0.8, "ReduceHealth", id, .flags = "b");
}
public ReduceHealth(const id)
{
	new Float:flHealth = get_entvar(id, var_health);

	flHealth -= 3.0;
	set_entvar(id, var_health, flHealth);

	static iMeter[MAX_PLAYERS+1];

	iMeter[id]++;

	if(iMeter[id] >= 13 || flHealth <= 10.0)
	{
		iMeter[id] = 0;
		g_blPlayerIsInfected[id] = false;

		rg_set_user_rendering(id);

		remove_task(id);
	}
}
public client_disconnected(id)
{
	g_blPlayerIsInfected[id] = false;
}
// Effects and Glow
public GiveEffects(const id, const _:iColor[3])
{
	message_begin(MSG_ONE, g_msgid, _, .player = id);

	write_short(1<<13);
	write_short(1<<7);
	write_short((1<<12));

	for(new i = 0; i < 3; i++)
	{
		write_byte(iColor[i]); // r, g, b
	}
	write_byte(211);

	message_end();
}
rg_set_user_rendering(const id, const {Float,_}:iColor[3] = {0.0,0.0,0.0})
{
	set_entvar(id, var_renderfx, kRenderFxGlowShell);
	set_entvar(id, var_rendercolor, iColor);
	set_entvar(id, var_rendermode, kRenderNormal);
	set_entvar(id, var_renderamt, 30.0);
}