#pragma semicolon 1

#include <amxmodx>
#include <reapi>

#define ADMIN_AFK    ADMIN_BAN

new bool:g_blPlayerAFK[MAX_PLAYERS+1],
	bool:g_blAdminAFK[MAX_PLAYERS+1],
	Float:g_cvars;

new const g_szBlockCommand[][] = {
	"amx_slay",
	"amx_slap"    // Alt alta sırala sonundakine virgül koyma.
};

public plugin_init(){
	register_plugin("Is Player AFK", "0.1", "` BesTCore;");

	for(new i = 0; i < sizeof(g_szBlockCommand); i++){
		register_clcmd(g_szBlockCommand[i], "clcmd_blockcommand");
	}

	register_clcmd("say /afk", "clcmd_afk");
	register_clcmd("say /afkadmin", "clcmd_afkadmin");
	
	register_clcmd("say", "clcmd_say");
	register_clcmd("say_team", "clcmd_say");

	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer_Spawn_Post", .post = true);

	bind_pcvar_float(create_cvar("KacSaniyeSonraKill", "5.0", _, "Kac Saniye sonra slaylansinlar."), g_cvars);
}
public clcmd_blockcommand(const id){
	if(g_blAdminAFK[id]){
		client_print_color(id, id, "^3Admin afk sistemindeyken bu komutu kullanamazsiniz.");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public clcmd_say(const id){
	if(g_blPlayerAFK[id] || g_blAdminAFK[id]){
		client_print_color(id, id, "^3Afk sisteminde oldugunuz icin mesajlasamassiniz, cikis yapmak icin^4 /afk^3 yaziniz.");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public RG_CBasePlayer_Spawn_Post(const id){
	if(get_member(id, m_bJustConnected)){
		return;
	}

	if(g_blPlayerAFK[id] || g_blAdminAFK[id]){
		set_task(g_cvars, "UserKill", id);
	}
}
public UserKill(id){
	client_print_color(id, id, "^3Afk sisteminde oldugun icin slaylandin, cikis yapmak icin^4 /afk^3 yaziniz.");
	user_kill(id);
	set_entvar(id, var_frags, 0.0);
	set_member(id, m_iDeaths, 0);
}
public clcmd_afk(const id){
	if(~get_user_flags(id) & ADMIN_USER){
		client_print_color(id, id, "^3Afk sistemini kullanabilmek icin user olmaniz gerekiyor.");
		return PLUGIN_HANDLED;
	}
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
public clcmd_afkadmin(const id){
	if(~get_user_flags(id) & ADMIN_AFK){
		client_print_color(id, id, "^3Admin afk sistemini kullanabilmek icin yetkiniz yok.");
		return PLUGIN_HANDLED;
	}
	if(g_blAdminAFK[id]){
		client_print_color(id, id, "^3Basarili bir sekilde afk sisteminden cikis yaptiniz.");
		g_blAdminAFK[id] = false;
		return PLUGIN_HANDLED;
	}
	else {
		g_blAdminAFK[id] = true;
		client_print_color(id, id, "^3Afk sistemine giris yaptiniz, her el basi slaylanacak, komut kullanamayacak ve artik mesaj atamayacaksiniz.");
	}
	return PLUGIN_HANDLED;
}
public client_disconnected(id){
	g_blPlayerAFK[id] = false;
	g_blAdminAFK[id] = false;
}