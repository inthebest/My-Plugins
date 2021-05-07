#pragma semicolon 1

#include <amxmodx>
#include <amxmisc>
#include <reapi>

#define ADMIN_GIVEC4    ADMIN_BAN

new SyncObj;

public plugin_init(){
	register_plugin("Takeing C4 from Player", "0.1", "` BesTCore;");

	register_concmd("amx_c4ver", "clcmd_givec4", ADMIN_GIVEC4, "<name>");
	SyncObj = CreateHudSyncObj();
}
public clcmd_givec4(const id){
	if(!(get_user_flags(id) & ADMIN_GIVEC4)){
		client_print_color(id, id, "^4Bu komutu kullanabilmek icin yeterli yetkiniz bulunmuyor.");
		return PLUGIN_HANDLED;
	}
	new szArg[32];
	read_argv(1, szArg, charsmax(szArg));

	static pPlayer;
	pPlayer = cmd_target(id, szArg, 6);

	if(!(is_user_alive(pPlayer) || pPlayer) || szArg[0] == EOS){
		client_print_color(id, id, "^4Bir oyuncu girmelisiniz.");
		return PLUGIN_HANDLED;
	}
	else if(get_member(pPlayer, m_iTeam) != TEAM_TERRORIST){
		client_print_color(id, id, "^4Sectiginiz oyuncu terrorist takiminda degil.");
		return PLUGIN_HANDLED;
	}

	for(new i = 1; i <= MaxClients; i++){
		if(get_member_game(m_iC4Guy) != i){
			continue;
		}
		rg_transfer_c4(i, pPlayer);
		client_print_color(i, i, "^4C4 bombaniz^1 %n^4 adli admin tarafindan alinip^1 %n^4 adli oyuncuya verildi.", id, pPlayer);
		client_print_color(pPlayer, pPlayer, "^4C4 bombasi^1 %n^4 adli admin tarafindan size verildi.", id);
		set_hudmessage(0, 0, 255, -1.0, 0.24, 0, 6.0, 4.0);
		ShowSyncHudMsg(id, SyncObj, "Gorev yapmayan %n adli oyuncudan c4 alindi.^nC4 %n adli oyuncuya verildi.", i, pPlayer);
	}
	return PLUGIN_HANDLED;
}