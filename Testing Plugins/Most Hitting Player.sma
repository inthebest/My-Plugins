#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <csstats>

public plugin_init(){
    register_plugin("Most Hitting Player", "0.1", "` BesTCore;");

    RegisterHookChain(RG_RoundEnd, "RG_RoundEnd_Pre", .post = false);
}
public RG_RoundEnd_Pre(WinStatus:status, ScenarioEventEndRound:event, Float:tmDelay){
    for(new id = 1;id <= MaxClients;id++) {
        for(new uid = 1;uid <= MaxClients;uid++) {
            if(!is_user_connected(id) || !is_user_connected(uid) || id == uid){
                continue;
            }
            new izStats[STATSX_MAX_STATS], izBody[STATSX_MAX_STATS];
            izStats[STATSX_DAMAGE] = 0;
            get_user_vstats(id, uid, izStats, izBody);

            /*new Score, iMax;
            if(izStats[STATSX_DAMAGE] > Score){
                Score = izStats[STATSX_DAMAGE];
                client_print_color(0, 0, "^4D");
                iMax = id;
                client_print_color(0, 0, "^4C");
            }*/
            //if(is_user_connected(iMax)){
                client_print_color(0, 0, "^4E");
                client_print_color(0, 0, "^3Bu elin en cok hasar veren oyuncusu^4 %d ^3hasar ile^4 %n", izStats[STATSX_DAMAGE], id);
            //}
        }
    }
}