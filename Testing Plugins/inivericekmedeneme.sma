	#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new const m_UstTag[] = "\dCSDuragi.COM \d-\y ";
//new const m_AltTag[] = "\dCSDuragi.COM \d-\w";
new const m_ChatTag[] = "^1[^4CSDuragi.COM^1]";

new const Silahlar[] = "addons/amxmodx/configs/silahlar2.ini";

new const Modelkonum[] = "models/";

new SilahName[MAX_CLIENTS+1][50];
new SilahVModel[MAX_CLIENTS+1][50];
new SilahPModel[MAX_CLIENTS+1][50];
new SilahFiyat[MAX_CLIENTS+1];
new Silahid[MAX_CLIENTS+1];
new Float:SilahHasar[MAX_CLIENTS+1];
new WeaponNum;
new UseSkin[MAX_CLIENTS+1][30];

public plugin_init(){
	register_plugin("Deneme INI","v1","` BesTCore");

	register_clcmd("say /silahal","silahal");

	register_event("CurWeapon","bestCurWeapon","be","1=1");

	RegisterHookChain(RG_CBasePlayer_TakeDamage,"bestCBasePlayer_TakeDamage", .post = false);
}
public silahal(id){
	new bestm = menu_create(fmt("%s Deneme INI Silah Menu",m_UstTag),"silahal_handler");

	new NTS[10];
	for(new i = 1; i < WeaponNum; i++){
		num_to_str(i, NTS, charsmax(NTS));
		menu_additem(bestm,fmt("%s \d[\r%i TL\d]",SilahName[i],SilahFiyat[i]),NTS);
	}
	bestMenuEnd(id,bestm);

}
public silahal_handler(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6],key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	new Silahadi[30];
	new Silahidi = Silahid[key];
	UseSkin[id][Silahidi] = key;
	get_weaponname(Silahidi,Silahadi, charsmax(Silahadi));
	rg_give_item(id,Silahadi);
	client_print_color(id,id,"%s ^3Basarili bir sekilde^1 [^4 %s ^1] ^3adli silahi satin aldiniz.",m_ChatTag,SilahName[key]);

	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public plugin_precache(){
	new file;
	if(!(file = fopen(Silahlar,"a+"))){
		set_fail_state("Silah ini dosyasi bulunamadi.");
	}
	else {
		new i = 1,hasar[5],fiyat[5],silahidi[5];
		new data[256],bestModel[50];
		while(!(feof(file))){
			fgets(file,data, charsmax(data));
			if(strlen(data)){
				parse(data,SilahName[i],49,SilahVModel[i],49,SilahPModel[i],49,fiyat,4,hasar,4,silahidi,4);
				SilahFiyat[i] = str_to_num(fiyat);
				Silahid[i] = str_to_num(silahidi);
				SilahHasar[i] = str_to_float(hasar);
				formatex(bestModel, charsmax(bestModel),"%s%s.mdl",Modelkonum,SilahVModel[i]);
				if(file_exists(bestModel)){
					precache_model(bestModel);
				}
				else {
					set_fail_state("Bulunamayan Silah Modeli: %s",bestModel);
				}
				formatex(bestModel, charsmax(bestModel),"%s%s.mdl",Modelkonum,SilahPModel[i]);
				if(file_exists(bestModel)){
					precache_model(bestModel);
				}
				else {
					set_fail_state("Bulunamayan Silah Modeli: %s",bestModel);
				}
				i++;
			}
		}
		WeaponNum = i;
		fclose(file);
	}
}
public bestCBasePlayer_TakeDamage(Victim, inflictor, Attacker, Float:damage, damage_bits){
	if(is_user_connected(Victim) && is_user_connected(Attacker) && get_member(Attacker, m_iTeam) == TEAM_CT && Victim != Attacker){
		if(!(damage_bits & DMG_GRENADE)){
			new UseWeapon = get_user_weapon(Attacker);
			if(UseWeapon != CSW_KNIFE){
				new UsesSkin = UseSkin[Attacker][UseWeapon];
				if(UsesSkin){
					damage += SilahHasar[UsesSkin];
				}
			}
		}
	}
	SetHookChainArg(4, ATYPE_FLOAT, damage);
}
public bestCurWeapon(id){
	new PlayerWeapon = get_user_weapon(id);
	new UseWeapon = UseSkin[id][PlayerWeapon];
	new Model[100];
	if(UseWeapon){
		formatex(Model, charsmax(Model),"%s%s.mdl",Modelkonum,SilahVModel[UseWeapon]);
		set_entvar(id,var_viewmodel,Model);

		formatex(Model, charsmax(Model),"%s%s.mdl",Modelkonum,SilahPModel[UseWeapon]);
		set_entvar(id,var_weaponmodel,Model);
	}
}
stock bestMenuEnd(bestID,bestEndID){
	menu_setprop(bestEndID,MPROP_BACKNAME,"\yOnceki Sayfa");
	menu_setprop(bestEndID,MPROP_NEXTNAME,"\ySonraki Sayfa");
	menu_setprop(bestEndID,MPROP_EXITNAME,"\yCikis");
	menu_setprop(bestEndID,MPROP_NUMBER_COLOR,"\r");
	menu_display(bestID,bestEndID);
}