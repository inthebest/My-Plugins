#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new const m_UstTag[] = "\dCSDuragi.COM \d-\y ";
new const m_AltTag[] = "\dCSDuragi.COM \d-\w";
new const m_ChatTag[] = "^1[^4CSDuragi.COM^1]";

new bool:engelter[33],bool:engelct[33];

public plugin_init(){
	register_plugin("Takim Dagitma Sistemi","1.0","` BesTCore");

	register_clcmd("say /takimsec","takimsec");
}
public takimsec(id){
	if(get_member(id,m_iTeam) == TEAM_CT || get_member(id,m_iTeam) == TEAM_TERRORIST){

		new bestm = menu_create(fmt("%s Takim Dagitma Sistemi",m_UstTag),"takimsec_handler");

		menu_additem(bestm,fmt("%s Oyuncu Sec \d",m_AltTag),"1");

		menu_setprop(bestm,MPROP_EXITNAME,"\yCikis");
		menu_setprop(bestm,MPROP_EXIT,MEXIT_ALL);
		menu_display(id,bestm);
	}
}
public takimsec_handler(id,menu,item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6],key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			if(engelter[id]){
				client_print_color(id,id,"%s ^3Takim secme sirasi^4 COUNTER-TERRORIST^3 takiminda.",m_ChatTag);
				takimsec(id);
			}
			if(engelct[id]){
				client_print_color(id,id,"%s ^3Takim secme sirasi^4 TERRORIST^3 takiminda.",m_ChatTag);
				takimsec(id);
			}
			new team = get_member(id,m_iTeam);
			switch(team){
				case 1:{
					oyuncular(id);
				}
				case 2:{
					if(get_member_game(m_iNumTerrorist) > 1){
						oyuncular(id);
					}
					else{
						client_print_color(id,id,"%s ^3Ilk oyuncuyu yalnizca^4 Terrorist^3 takimi secebilir.",m_ChatTag);
						takimsec(id);
					}
				}
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public oyuncular(id){
	new bestm = menu_create(fmt("%s Oyuncu Sec",m_UstTag),"oyuncular_handler");

	new NTS[10],players[32],num,ids;
	get_players(players,num,"bch","TEAM_SPECTATOR");
	for(new i = 1; i <= num; i++){
		ids = players[i];
		if(!is_user_connected(ids) || ids == id){
			continue;
		}
		num_to_str(ids,NTS,charsmax(NTS));
		menu_additem(bestm,fmt("%n",ids),NTS);
	}
	menu_display(id,bestm);
}
public oyuncular_handler(id,menu,item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6],Oyuncu;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	Oyuncu = str_to_num(data);
	if(is_user_connected(Oyuncu)){
		if(get_member(id,m_iTeam) == TEAM_CT){
			rg_set_user_team(Oyuncu,TEAM_CT);
			client_print_color(Oyuncu,Oyuncu,"%s^1 %n ^3adli oyuncu sizi secti, artik takiminiz^4 COUNTER-TERRORIST^1.",m_ChatTag,id);
			takimsec(id);
			engelct[id] = true;
			engelter[id] = false;
		}
		else {
			rg_set_user_team(Oyuncu,TEAM_TERRORIST);
			client_print_color(Oyuncu,Oyuncu,"%s^1 %n ^3adli oyuncu sizi secti, artik takiminiz^4 TERRORIST^1.",m_ChatTag,id);
			takimsec(id);
			engelter[id] = true;
			engelct[id] = false;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public client_connect(id){
	engelter[id] = false;
	engelct[id] = false;
}
