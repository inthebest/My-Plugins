#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new Sayac[MAX_CLIENTS+1];

public plugin_init(){
	register_plugin("Chat Kill Meter","1.0","` BesTCore;");

	RegisterHookChain(RG_CSGameRules_PlayerKilled, "RG_CSGameRules_PlayerKilled_", .post = true);
	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_", .post = false);
}
public RG_CSGameRules_PlayerKilled_(Victim, Attacker){
	if(!is_user_connected(Victim) || !is_user_connected(Attacker) || Attacker == Victim){
		return PLUGIN_HANDLED;
	}
	Sayac[Attacker]++;
	client_print_color(Attacker, Attacker, "Bu round oldurdugun kisi sayisi: %i", Sayac[Attacker]);
	return PLUGIN_HANDLED;
}
public RG_CSGameRules_RestartRound_(){
	for(new id = 1; id <= MaxClients; id++){
		Sayac[id] = 0;
	}
}
public client_disconnected(id){
	Sayac[id] = 0;
}
public client_connect(id){
	Sayac[id] = 0;
}