#pragma semicolon 1

#include <amxmodx>

new const g_fReport[] = "addons/amxmodx/configs/reportlar.ini";
new	g_iPickPlayer[MAX_PLAYERS+1];

public plugin_init(){
	register_plugin("Report Sistemi", "0.1", "` BesTCore;");

	register_clcmd("say /reportet", "clcmd_reportet");
}
public clcmd_reportet(id){
	new bestm = menu_create("\rReport Edecegin Oyuncuyu Sec", "clcmd_reportet_");

	for(new i = 1; i <= MaxClients; i++){
		if(is_user_connected(i) && id != i && !is_user_bot(i)){
			menu_additem(bestm, fmt("%n", i), fmt("%i", i));
		}
	}
	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public clcmd_reportet_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	g_iPickPlayer[id] = key;
	ReasonForReport(id);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public ReasonForReport(id){
	new bestm = menu_create("Report Nedenin Nedir ?", "ReasonForReport_");

	menu_additem(bestm, "Hile");
	menu_additem(bestm, "Gereksiz Yetki");
	menu_additem(bestm, "Kufur");

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_display(id, bestm);
}
public ReasonForReport_(id, menu, item){
	new date[20], iFile = fopen(g_fReport, "a");
	get_time("%d.%m.%Y|>|%H:%M", date, charsmax(date));

	if(iFile){
		switch(item){
			case 0:{
				fprintf(iFile, "%s | Reportlayan: %n | Reportlanan: %n | Neden: Hile^n", date, id, g_iPickPlayer[id]);
			}
			case 1:{
				fprintf(iFile, "%s | Reportlayan: %n | Reportlanan: %n | Neden: Gereksiz Yetki^n", date, id, g_iPickPlayer[id]);
			}
			case 2:{
				fprintf(iFile, "%s | Reportlayan: %n | Reportlanan: %n | Neden: Kufur^n", date, id, g_iPickPlayer[id]);
			}
		}
		fclose(iFile);
	}
	client_print_color(id, id, "^4Sikayetin iletildi.");

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}