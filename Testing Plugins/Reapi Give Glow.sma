#pragma semicolon 1

#include <amxmodx>
#include <reapi>

public plugin_init(){
	register_plugin("Reapi Give Glow", "0.1", "` BesTCore;");

	register_clcmd("say /glow", "clcmd_glow");
}
public clcmd_glow(id){
	rg_set_user_rendering(id, {0.0, 255.0, 0.0});
}
rg_set_user_rendering(const id, const {Float,_}:color[3] = {0.0,0.0,0.0}){
	set_entvar(id, var_renderfx, kRenderFxGlowShell);
	set_entvar(id, var_rendercolor, color);
	set_entvar(id, var_rendermode, kRenderNormal);
	set_entvar(id, var_renderamt, 30.0);
}