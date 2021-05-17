#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new SecilenOyuncu[MAX_PLAYERS+1];

public plugin_init(){
	register_plugin("Secilen Oyuncuya Frag Ver", "0.1", "` BesTCore;");

	register_clcmd("say /oyuncusec", "chooseplayer");
	register_clcmd("Verilecek_Frag", "fragver");
}
public chooseplayer(id){
	new bestm = menu_create(fmt("\yOyuncu Frag Ver"), "chooseplayer_");
	for(new i = 1, nts[6]; i <= MaxClients; i++){
		if(!is_user_connected(i) || is_user_bot(i)){
			continue;
		}
		num_to_str(i, nts, charsmax(nts));
		menu_additem(bestm, fmt("%n", i), nts);
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public chooseplayer_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	SecilenOyuncu[id] = key;
	client_cmd(id, "messagemode Verilecek_Frag");

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public fragver(id){
	new arg[256];
	read_args(arg, charsmax(arg));
	remove_quotes(arg);

	new miktar = str_to_num(arg);

	if(!is_str_num(arg) || equal(arg, "") || miktar <= 0){
		client_print_color(id, id, "^3Gecersiz parametre.");
		return PLUGIN_HANDLED;
	}
	set_entvar(SecilenOyuncu[id], var_frags, get_entvar(SecilenOyuncu[id], var_frags)+miktar);
	return PLUGIN_HANDLED;
}