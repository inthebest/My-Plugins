#pragma semicolon 1

#include <amxmodx>
#include <fakemeta>

public plugin_init(){
	register_plugin("Get Off", "0.1", "` BesTCore;");

	register_clcmd("say /kurtul", "clcmd_getoff");
}
public clcmd_getoff(const id){
	if(Stuck(id)){
		new Float:Origin[3];
		pev(id, pev_origin, Origin);
		Origin[0] += 35.0;
		set_pev(id, pev_origin, Origin);
		client_print_color(id, id, "^3Basarili bir sekilde bugdan kurtuldunuz.");
	}
	else {
		client_print_color(id, id, "^3Sen bugda degilsin.");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}
bool:Stuck(const id){
	static Float:Origin[3];
	pev(id, pev_origin, Origin);
	engfunc(EngFunc_TraceHull, Origin, Origin, IGNORE_MONSTERS, pev(id, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, 0, 0);
	if(get_tr2(0, TR_StartSolid)){
		return true;
	}
	return false;
}