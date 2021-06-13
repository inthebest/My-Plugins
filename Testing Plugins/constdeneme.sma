#pragma semicolon 1

#include <amxmodx>

enum _: SilahIsimleri {
	ak,
	m4,
	awp
};
new const Weapons[SilahIsimleri][][] = {
	{"AK47", "Silah Model Yolu AK", 10, 30},
	{"M4A1", "Silah Model Yolu M4A1", 20, 50},
	{"AWP", "Silah Model Yolu AWP", 30, 70}
};

public plugin_init(){
	register_plugin("Const Deneme", "0.1", "` BesTCore;");

	register_clcmd("say /ver", "ver");
}
public ver(id){
	new bestm = menu_create("123213123", "ver_");
	for(new i = 0, nts[6]; i <= awp; i++){
		num_to_str(i, nts, charsmax(nts));
		menu_additem(bestm, fmt("%s \d[\r%s\d] \d[\r%i\d] \d[\r%i\d]", Weapons[i][0], Weapons[i][1][0], Weapons[i][2][0], Weapons[i][3][0]), nts);
	}
	menu_display(id, bestm);
}
public ver_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	client_print_color(id, id, "%s %s %i %i", Weapons[key][0], Weapons[key][1][0], Weapons[key][2][0], Weapons[key][3][0]);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}