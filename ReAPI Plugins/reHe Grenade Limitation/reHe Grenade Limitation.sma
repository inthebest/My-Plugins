#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new g_iMeter[MAX_PLAYERS+1],
	g_cvars;

public plugin_init(){
	register_plugin("He Grenade Limitation", "0.1", "` BesTCore;");

	RegisterHookChain(RG_ShowVGUIMenu, "RG_ShowVGUIMenu_Pre", .post = false);
	RegisterHookChain(RG_RoundEnd, "RG_RoundEnd_Post", .post = true);

	bind_pcvar_num(create_cvar("ToplamBomba", "1", .description = "Bir elde kac adet bomba alinsin."), g_cvars);
}
public RG_ShowVGUIMenu_Pre(const id, VGUIMenu:VGUI_Menu_Buy_Item, const bitsSlots, szOldMenu[]){
	if(VGUI_Menu_Buy_Item != WEAPON_HEGRENADE){
		return HC_CONTINUE;
	}
	if(g_iMeter[id] >= g_cvars){
		client_print_color(id, id, "^3Bir elde^4 %d^3 adet bomba alabilirsin.", g_cvars);
		SetHookChainReturn(ATYPE_INTEGER, false);
		return HC_SUPERCEDE;
	}
	g_iMeter[id]++;
	return HC_CONTINUE;
}
public RG_RoundEnd_Post(){
	for(new i = 1; i <= MaxClients; i++){
		g_iMeter[i] = 0;
	}
}