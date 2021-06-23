#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new Float:g_cvar;

public plugin_init()
{
	register_plugin("Flashbang Explode Time", "0.1", "` BesTCore;");

	RegisterHookChain(RG_ThrowFlashbang, "RG_ThrowFlashbang_Pre", .post = false);

	bind_pcvar_float(create_cvar("FlashBang_Patlama_Suresi", "0.5", _, "Flashbang kac saniye sonra patlasin. (Değer ondalıklı olmalıdır.)"), g_cvar);
}
public RG_ThrowFlashbang_Pre(const index, Float:vecStart[3], Float:vecVelocity[3], Float:time)
{
	if(!(GetHookChainReturn(ATYPE_INTEGER)))
	{
		return;
	}
	SetHookChainArg(4, ATYPE_FLOAT, g_cvar);
}