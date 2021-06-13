#pragma semicolon 1

#include <amxmodx>

new g_iKillMeter[MAX_PLAYERS+1];

public plugin_init(){
	register_plugin("Best Player EDO", "0.1", "` BesTCore;");

	AmxModXHooks();
}
public CBasePlayer_Killed_Post(){
	new pVictim = read_data(2);
	new pAttacker = read_data(1);
	if(!is_user_connected(pAttacker) || pAttacker == pVictim){
		return;
	}
	g_iKillMeter[pAttacker]++;
}
public RoundEnd_Pre(){
	new aWinner[MAX_PLAYERS+1], g_iWinnerName[MAX_PLAYERS+1], aEdoScore;
	aEdoScore = str_to_num(aWinner);
	for(new i = 1; i <= MaxClients; i++){
		if(g_iKillMeter[i] > aEdoScore){
			aEdoScore = g_iKillMeter[i];
			get_user_name(i, g_iWinnerName, charsmax(g_iWinnerName));
			break;
		}
	}
	if(aEdoScore){
		client_print_color(0, 0, "^3Bu elin en degerli oyuncusu^4 %d ^3kill ile^4 %s", aEdoScore, g_iWinnerName);
	}
	return PLUGIN_HANDLED;
}
public YeniRound(){
	for(new i = 1; i <= MaxClients; i++){
		g_iKillMeter[i] = 0;
	}
}
public client_disconnected(id){
	g_iKillMeter[id] = 0;
}
AmxModXHooks(){
	register_event("DeathMsg", "CBasePlayer_Killed_Post", "a");
	register_logevent( "RoundEnd_Pre", 2, "1=Round_End");
	register_event("HLTV", "YeniRound", "a", "1=0", "2=0");
}