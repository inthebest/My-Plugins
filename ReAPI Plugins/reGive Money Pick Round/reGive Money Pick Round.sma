#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new cvars[2];

public plugin_init(){
	register_plugin("Give Money Pick Round","1.0","` BesTCore");

	RegisterHookChain(RG_CSGameRules_RestartRound, "CSGameRules_RestartRound_", 0);

	bind_pcvar_num(create_cvar("RoundSayisi", "2"), cvars[0]); // Kac round gectikten sonra para verilsin.
	bind_pcvar_num(create_cvar("ParaMiktar", "4000"), cvars[1]); // Verilecek para miktari.
}
public CSGameRules_RestartRound_(){
	static sayac = 0;
	sayac++;
	if(sayac == cvars[0]){
		for(new i = 1; i <= MaxClients; i++){
			if(is_user_connected(i)){
				rg_add_account(i, cvars[1], AS_ADD);
				client_print_color(0,0,"^3Butun oyunculara^4 %d ^3round gectigi icin^4 %d ^3TL verildi.",cvars[0],cvars[1]);
				break;
				}
		}
		sayac = 0;
	}
	if(get_member_game(m_bCompleteReset)){
		sayac = 0;
	}
}