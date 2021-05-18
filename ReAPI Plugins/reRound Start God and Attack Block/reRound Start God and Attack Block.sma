#pragma semicolon 1

#include <amxmodx>
#include <reapi>

enum (+= 1337)
{
	TASK_GOD,
	TASK_ATTACKBLOCK
}

enum _:boolEnum
{
	blGod,
	blAttackBlock
};
new g_bools[boolEnum][MAX_PLAYERS+1];

public plugin_init()
{
	register_plugin("Round Start God and Attack Block", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer_Spawn_Post", .post = true);
	RegisterHookChain(RG_CSGameRules_FPlayerCanTakeDamage, "RG_CSGameRules_FPlayerCanTakeDamage_Pre", .post = false);
}
public RG_CSGameRules_FPlayerCanTakeDamage_Pre(const id, const attacker)
{
	if(g_bools[attacker][blAttackBlock])
	{
		SetHookChainReturn(ATYPE_INTEGER, false);
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

	g_bools[blGod][id] = true;
	set_entvar(id, var_takedamage, DAMAGE_NO);

	g_bools[blAttackBlock][id] = true;

	remove_task();

	set_task(5.0, "GodOff", id + TASK_GOD);
	set_task(3.0, "AttackBlockOff", id + TASK_ATTACKBLOCK);
}
public GodOff(Taskid)
{
	new id = Taskid - TASK_GOD;

	set_entvar(id, var_takedamage, DAMAGE_AIM);
}
public AttackBlockOff(Taskid)
{
	new id = Taskid - TASK_ATTACKBLOCK;

	g_bools[blAttackBlock][id] = false;
}
public client_disconnected(id)
{
	g_bools[blGod][id] = false;
	g_bools[blAttackBlock][id] = false;

	remove_task();
}