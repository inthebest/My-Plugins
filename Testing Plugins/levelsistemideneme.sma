#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <nvault>

new cvars[3],m_Vault,Syncobje;
new m_Rank[MAX_CLIENTS+1],m_RankXP[MAX_CLIENTS+1];

new const RankSystem[][][] = {
	{"Level 0", 0},
	{"Level 1", 100},
	{"Level 2", 200},
	{"Level 3", 300}
};

public plugin_init(){
	register_plugin("Level System","1.0","` BesTCore");

	register_clcmd("say /ranklar","ranklar");
	register_clcmd("nightvision","ranklar");

	register_clcmd("say","saykontrol");

	RegisterHookChain(RG_CSGameRules_PlayerKilled, "CSGameRules_PlayerKilled_Pre", 1);

	Syncobje = CreateHudSyncObj();

	bind_pcvar_num(create_cvar("Rank_KillBasinaXP", "5"), cvars[0]);
	bind_pcvar_num(create_cvar("Rank_OlunceGidecekXP", "3"), cvars[1]);
}
public saykontrol(id){
	new say[191];
	read_args(say,190);
	remove_quotes(say);
	if(strlen(say) > 0 && containi(say[0],"173") == -1 && containi(say[0],"@") == -1 && containi(say[0],"213") == -1){
		static sayinput[191];
		static saygecir[191];
		new flags = get_user_flags(id);
		if(is_user_alive(id)){
			if(flags & ADMIN_RESERVATION){
				formatex(sayinput, charsmax(sayinput), "^1[^4%s^1]^1[^4YETKILI^1] ^3%n^1: ^4%s", RankSystem[m_Rank[id]][0], id, say);
			}
			else {
				formatex(sayinput, charsmax(sayinput), "^1[^3%s^1] ^3%n^1: ^1%s", RankSystem[m_Rank[id]][0], id, say);
			}
		}
		else {
			if(flags & ADMIN_RESERVATION){
				formatex(sayinput, charsmax(sayinput), "^1(^4x^1) ^1[^4%s^1]^1[^4YETKILI^1] ^3%n^1: ^4%s", RankSystem[m_Rank[id]][0], id, say);
			}
			else {
				formatex(sayinput, charsmax(sayinput), "^1(^4x^1) ^1[^3%s^1] ^3%n^1: ^1%s", RankSystem[m_Rank[id]][0], id, say);
			}
		}
		vformat(saygecir, charsmax(saygecir), sayinput, 3);
	
		for(new i = 1; i <= MaxClients; i++){
			if(is_user_connected(i)){
				client_print_color(i, id, saygecir);
			}
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}
public ranklar(id){
	new bestm = menu_create(fmt("\rRanklar"),"ranklar_pre");

	new NTS[6];
	for(new i = 0; i < sizeof(RankSystem); i++){
		num_to_str(i, NTS, charsmax(NTS));
		menu_additem(bestm,fmt("%s \d[\r%d XP\d]",RankSystem[i][0],RankSystem[i][1][0]),NTS);
	}

	bestMenuEnd(id,bestm);
}
public CSGameRules_PlayerKilled_Pre(Victim, Attacker){
	if(is_user_connected(Victim) && is_user_connected(Attacker) && is_user_alive(Attacker) && Victim != Attacker){
		m_RankXP[Attacker] += cvars[0];
		client_print_color(Attacker,Attacker,"^3Bir oyuncu oldurdunuz ve^1 [^4%d XP^1] ^3kazandiniz.",cvars[0]);
		m_RankXP[Victim] -= cvars[1];
		client_print_color(Victim,Victim,"^3Oldugunuz icin^1 [^3%d XP^1] ^3kaybettiniz.",cvars[1]);
		if(m_RankXP[Attacker] >= RankSystem[m_Rank[Attacker]+1][1][0]){
			m_Rank[Attacker]++;
			client_print_color(Attacker,Attacker,"^3Basarili bir sekilde ^4level ^3atladiniz^1,^3artik leveliniz ^1[^4%s^1]",RankSystem[m_Rank[Attacker]][0]);
		}
		if(m_RankXP[Victim] < RankSystem[m_Rank[Victim]-1][1][0]){
			m_Rank[Victim]--;
			client_print_color(Victim,Victim,"^3Cok fazla oldugunuz icin maalesef ^4level ^3dustunuz^1,^3artik leveliniz ^1[^4%s^1]",RankSystem[m_Rank[Attacker]][0]);
		}
		savevault(Attacker);
		savevault(Victim);
	}
}
public client_disconnected(id){
	remove_task(id);
	savevault(id);
}
public client_connect(id){
	givevault(id);
}
public savevault(id){
	new bestformat1[100],bestformat2[100];

	new steamid[MAX_AUTHID_LENGTH];
	get_user_authid(id, steamid, charsmax(steamid));

	formatex(bestformat1, charsmax(bestformat1), "%s-rankxp", steamid);
	formatex(bestformat2, charsmax(bestformat2), "%i", m_RankXP[id]);
	nvault_pset(m_Vault,bestformat1,bestformat1);

	formatex(bestformat1, charsmax(bestformat1), "%s-rank", steamid);
	formatex(bestformat2, charsmax(bestformat2), "%i", m_Rank[id]);
	nvault_set(m_Vault, bestformat1, bestformat2);
}
public givevault(id){
	new bestformat1[100];

	new steamid[MAX_AUTHID_LENGTH];
	get_user_authid(id, steamid, charsmax(steamid));

	formatex(bestformat1, charsmax(bestformat1), "%s-rank", steamid);
	m_Rank[id] = nvault_get(m_Vault, bestformat1);

	formatex(bestformat1, charsmax(bestformat1) ,"%s-rankxp", steamid);
	m_RankXP[id] = nvault_get(m_Vault, bestformat1);
}
public client_putinserver(id){
	set_task(1.0,"hudMessage",id,_,_,"b");
}
public hudMessage(id){
	set_hudmessage(255, 170, 0, -1.0, 0.74, 0, 6.0, 12.0);
	ShowSyncHudMsg(id,Syncobje,"[ - Mevcut Leveliniz: %s - ]^n[ - Sonraki Leveliniz: %s - ]^n[ - %d/%d - ]",RankSystem[m_Rank[id]][0],RankSystem[m_Rank[id]+1][0],m_RankXP[id],RankSystem[m_Rank[id]][1][0]);
}
stock bestMenuEnd(bestID,bestEndID){
	menu_setprop(bestEndID,MPROP_BACKNAME,"\yOnceki Sayfa");
	menu_setprop(bestEndID,MPROP_NEXTNAME,"\ySonraki Sayfa");
	menu_setprop(bestEndID,MPROP_EXITNAME,"\yCikis");
	menu_setprop(bestEndID,MPROP_NUMBER_COLOR,"\r");
	menu_display(bestID,bestEndID);
}