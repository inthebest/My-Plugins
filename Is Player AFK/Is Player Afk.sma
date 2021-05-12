#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new bool:g_blPlayerAFK[MAX_PLAYERS+1];

public plugin_init(){
	register_plugin("Is Player AFK", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer_Spawn_Post", .post = true);

	register_clcmd("say /afk", "clcmd_afk");
	
	register_clcmd("say", "clcmd_say");
	register_clcmd("say_team", "clcmd_say");
}
public clcmd_say(const id){
	if(g_blPlayerAFK[id]){
		client_print_color(id, id, "^3Afk sisteminde oldugunuz icin mesajlasamassiniz, cikis yapmak icin^4 /afk^3 yaziniz.");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public RG_CBasePlayer_Spawn_Post(const id){
	if(get_member(id, m_bJustConnected)){
		return;
	}

	if(g_blPlayerAFK[id]){
		set_task(3.0, "UserKill", id);
	}
}
public UserKill(id){
	client_print_color(id, id, "^3Afk sisteminde oldugun icin slaylandin, cikis yapmak icin^4 /afk^3 yaziniz.");
	user_kill(id);
}
public clcmd_afk(const id){
	if(g_blPlayerAFK[id]){
		client_print_color(id, id, "^3Basarili bir sekilde afk sisteminden cikis yaptiniz.");
		g_blPlayerAFK[id] = false;
		return PLUGIN_HANDLED;
	}
	else {
		g_blPlayerAFK[id] = true;
		client_print_color(id, id, "^3Afk sistemine giris yaptiniz, her el basi slaylanacak ve artik mesaj atamayacaksiniz.");
	}
	return PLUGIN_HANDLED;
}
public client_disconnected(id){
	g_blPlayerAFK[id] = false;
}