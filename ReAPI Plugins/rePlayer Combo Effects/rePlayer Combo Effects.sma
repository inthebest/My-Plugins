#include <amxmodx>
#include <reapi>

new g_iKillMeter[MAX_PLAYERS+1];

new const HeadShotSound[] = "misc/headshot.wav";
new const sound[][] = {
	"misc/kill_1.wav",
	"misc/kill_2.wav",
	"misc/kill_3.wav",
	"misc/kill_4.wav",
	"misc/kill_5.wav",
	"misc/kill_6.wav",
	"misc/kill_77.wav",
	"misc/kill_8.wav",
	"misc/kill_9.wav"
};

public plugin_init(){
	register_plugin("Player Combo Effects", "0.1", "` BesTCore;");

	RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed_Post", .post = true);
}

public CBasePlayer_Killed_Post(const pVictim, pAttacker, iGib) {
	if(!is_user_connected(pAttacker) || pAttacker == pVictim){
		return;
	}

	g_iKillMeter[pVictim] = 0;
	g_iKillMeter[pAttacker]++;

	if(get_member(pVictim, m_bHeadshotKilled) && g_iKillMeter[pAttacker] == 1){
		rg_send_audio(pAttacker, HeadShotSound);
	}
	else if(g_iKillMeter[pAttacker] >= sizeof(sound)) {
		rg_send_audio(pAttacker, sound[sizeof(sound) - 1]);
	}
	else {
		rg_send_audio(pAttacker, sound[g_iKillMeter[pAttacker] - 1]);
	}
}

public plugin_precache(){
    for(new i = 0; i < sizeof(sound); i++){
    	precache_sound(sound[i]);
    }
    precache_sound(HeadShotSound);
}

public client_disconnected(id){
	g_iKillMeter[id] = 0;
}