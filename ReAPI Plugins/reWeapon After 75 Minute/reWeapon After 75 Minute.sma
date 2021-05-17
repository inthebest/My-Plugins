#pragma semicolon 1

#include <amxmodx>
#include <reapi>

public plugin_init(){
	register_plugin("After 75 Minute Weapon","1.0","` BesTCore");

	set_task(75.0,"@allplayersawp");
}
@allplayersawp(){
	new players[32],inum,id;
	get_players(players,inum);
	for(new i; i <inum; i++){
		id = players[i];
		rg_give_item(id,"weapon_awp");
		rg_set_user_bpammo(id,WEAPON_AWP,30);
		client_print_color(id,id,"^4Herkese AWP Silahi Verildi.");
	}
}
public client_disconnected(id){
	remove_task(id);
}