#pragma semicolon 1

#include <amxmodx>
#include <reapi_reunion>

#define ADMIN_ADDSTEAM   ADMIN_BAN
new const iChatTag[] = "^4forum.csd :";

new const szSteamList[] = "addons/amxmodx/configs/steampluslar.ini";

native csd_checkuserac(id);

public plugin_init(){
	register_plugin("Steam+ Checker", "0.1", "` BesTCore;");

	register_concmd("amx_addsteam", "clcmd_addsteam");
}
public clcmd_addsteam(const id){
	if(~get_user_flags(id) & ADMIN_ADDSTEAM){
		client_print_color(id, id, "%s ^3Bu komutu kullanmak icin yetkin yok.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new szArg[32];
	read_argv(1, szArg, charsmax(szArg));

	if(szArg[0] == EOS){
		return PLUGIN_HANDLED;
	}

	new pPlayer = find_player("bl", szArg);
	if(!pPlayer){
		client_print_color(id, id, "%s ^3Oyuncu bulunamadi.", iChatTag);
		return PLUGIN_HANDLED;
	}

	new pPlayerSteam[MAX_AUTHID_LENGTH];
	get_user_authid(pPlayer, pPlayerSteam, charsmax(pPlayerSteam));

	if(ReadFile(pPlayer, false)){
		client_print_color(id, id, "%s ^3Eklemeye calistiginiz oyuncunun steamidsi zaten kayitli.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new iFile = fopen(szSteamList, "a+");
	if(iFile){
		fprintf(iFile, "%s // Oyuncu %n^n", pPlayerSteam, pPlayer);
		client_print_color(0, 0, "^1%n^3 adli admin^1 %n^3 adli oyuncuyu zorunlu^4 Steam+^3 kontrolune ekledi.", id, pPlayer);
		fclose(iFile);
	}
	return PLUGIN_HANDLED;
}
public client_putinserver(id){
	if(is_user_steam(id)){
		set_task(2.0, "UnSteamPlusKick", id);
	}
}
public UnSteamPlusKick(const id){
	if(ReadFile(id, true)){
		server_cmd("kick #%d ^"Steam+ kurmadigin icin sunucudan atildin.", get_user_userid(id));
		client_print_color(0, 0, "^1%n ^3adli oyuncu ^4Steam+^3 kurmadigi icin sunucudan atildi.", id);
	}
}
bool:ReadFile(const id, bool:confirm = false){
	new iFile = fopen(szSteamList, "r");

	if(iFile){
		new szBuffer[MAX_FMT_LENGTH], iSteamid[MAX_AUTHID_LENGTH], szSteamid[MAX_AUTHID_LENGTH];
		get_user_authid(id, iSteamid, charsmax(iSteamid));

		while(fgets(iFile, szBuffer, charsmax(szBuffer))){
			trim(szBuffer);

			if(szBuffer[0] == EOS || szBuffer[0] == ';'){
				continue;
			}

			parse(szBuffer, szSteamid, charsmax(szSteamid));

			if(!confirm){
				if(containi(iSteamid, szSteamid) != -1){
					return true;
				}
			}
			else {
				if(containi(iSteamid, szSteamid) != -1 && !csd_checkuserac(id)){
					return true;
				}
			}
		}
		fclose(iFile);
	}
	return false;
}