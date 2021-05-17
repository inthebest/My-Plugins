// Plugins coded by ` BesTCore. 

#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <fun>
#include <fakemeta>
#include <cstrike>

#define YETKI ADMIN_RCON

new m_TL[33],cvars[18],AmmoYenile[33],Elde2kere[33];
new bool: Birkere[33][15];
new bool: Oldurme5HP[33] = false,bool: Her15SaniyedeBomb[33] = false,bool: Her10Saniyede5HP[33] = false,bool: Falldamage[33] = false,bool: UnlimitedAmmo[33] = false;
#define fm_find_ent_by_class(%1,%2) engfunc(EngFunc_FindEntityByString, %1, "classname", %2)

new const m_UstTag[] = "\d[ - \wCSDuragi.COM \d- ] \y";
new const m_ChatTag[] = "^1[^4CSDuragi.COM^1]";

public plugin_init(){
	register_plugin("DeathMatch Shop","0.1","` BesTCore");

	register_clcmd("say /dmmarket","dmmarket");
	register_clcmd("nightvision","dmmarket");
	register_clcmd("say /paraver","paraver");
	set_task(60.0,"bilgiver",_,_,_,"b");

	RegisterHookChain(RG_CSGameRules_PlayerKilled,"bestPK",1);
	RegisterHookChain(RG_CBasePlayer_Spawn, "bestPS", 1);
	RegisterHookChain(RG_CSGameRules_FlPlayerFallDamage, "bestFD", 1);
	register_event("CurWeapon", "bestCW", "be", "1=1");
	
	bind_pcvar_num(create_cvar("KillBasinaTL", "2"), cvars[4]);
	bind_pcvar_num(create_cvar("MaxKazanmaTL", "100"), cvars[12]);

	bind_pcvar_num(create_cvar("AnaMenu_250HPFiyat","15"), cvars[1]);
	bind_pcvar_num(create_cvar("AnaMenu_250ArmorFiyat","15"), cvars[2]);
	bind_pcvar_num(create_cvar("AnaMenu_HizliKosmaFiyat","15"), cvars[3]);
	bind_pcvar_num(create_cvar("AnaMenu_CanveZirhYenileFiyat","15"), cvars[5]);
	bind_pcvar_num(create_cvar("AnaMenu_SessizYurumeFiyat","15"), cvars[6]);
	bind_pcvar_num(create_cvar("AnaMenu_GodmodeFiyat","15"), cvars[7]);
	bind_pcvar_num(create_cvar("AnaMenu_HerOldurme5HPFiyat","15"), cvars[8]);
	bind_pcvar_num(create_cvar("AnaMenu_Her15SaniyedeBombaFiyat","15"), cvars[9]);
	bind_pcvar_num(create_cvar("AnaMenu_Her10SaniyedeBir5HPFiyat","15"), cvars[10]);
	bind_pcvar_num(create_cvar("AnaMenu_KilikDegistirmeFiyat","15"), cvars[11]);
	bind_pcvar_num(create_cvar("AnaMenu_SG550SilahiFiyat","15"), cvars[13]);
	bind_pcvar_num(create_cvar("AnaMenu_AWPSilahiFiyat","15"), cvars[14]);
	bind_pcvar_num(create_cvar("AnaMenu_YuksekZiplama15SaniyeFiyat","15"), cvars[15]);
	bind_pcvar_num(create_cvar("AnaMenu_FallDamageFiyat","15"), cvars[16]);
	bind_pcvar_num(create_cvar("AnaMenu_SinirsizMermiFiyat","15"), cvars[17]);
}
public paraver(p_ID){
	if(get_user_flags(p_ID) & YETKI){
	m_TL[p_ID] += 100;
	client_print_color(p_ID,p_ID,"%s ^3Basarili bir sekilde^4 100 TL ^3aldin.",m_ChatTag);}
	else {client_print_color(p_ID,p_ID,"%s ^3Yetersiz yetki.",m_ChatTag);}}
public dmmarket(p_ID){
	new bestm = menu_create(fmt("%s DeathMatch Market^n\d[ - \wMevcut TL:\r %d \d- ]^n\dSayfa: \r",m_UstTag,m_TL[p_ID]),"dmmarket_handler");

	if(m_TL[p_ID] >= cvars[1]){menu_additem(bestm,fmt("250 HP \d[\r%d TL\d]",cvars[1]),"1");}
	else{menu_additem(bestm,fmt("\d250 HP \d[\r%d TL\d]",cvars[1]),"1");}
	if(m_TL[p_ID] >= cvars[2]){menu_additem(bestm,fmt("250 Armor \d[\r%d TL\d]",cvars[2]),"2");}
	else{menu_additem(bestm,fmt("\d250 Armor \d[\r%d TL\d]",cvars[2]),"2");}
	if(m_TL[p_ID] >= cvars[3]){menu_additem(bestm,fmt("Hizli Yurume \d(\r15 Saniye\d) \d[\r%d TL\d]",cvars[3]),"3");}
	else{menu_additem(bestm,fmt("\dHizli Yurume \d(\r15 Saniye\d) \d[\r%d TL\d]",cvars[3]),"3");}
	if(m_TL[p_ID] >= cvars[5]){menu_additem(bestm,fmt("Can ve Zirh Yenile \d[\r%d TL\d]",cvars[5]),"4");}
	else{menu_additem(bestm,fmt("\dCan ve Zirh Yenile \d[\r%d TL\d]",cvars[5]),"4");}
	if(m_TL[p_ID] >= cvars[6]){menu_additem(bestm,fmt("Sessiz Yurume \d(15 Saniye\d) \d[\r%d TL\d]",cvars[6]),"5");}
	else{menu_additem(bestm,fmt("\dSessiz Yurume \d(15 Saniye\d) \d[\r%d TL\d]",cvars[6]),"5");}
	if(m_TL[p_ID] >= cvars[7]){menu_additem(bestm,fmt("GodMode \d(10 Saniye\d) \d[\r%d TL\d]",cvars[7]),"6");}
	else{menu_additem(bestm,fmt("\dGodMode \d(10 Saniye\d) \d[\r%d TL\d]",cvars[7]),"6");}
	if(m_TL[p_ID] >= cvars[8]){menu_additem(bestm,fmt("Oldurme Basina 5 HP \d[\r%d TL\d]",cvars[8]),"7");}
	else{menu_additem(bestm,fmt("\dOldurme Basina 5 HP \d[\r%d TL\d]",cvars[8]),"7");}
	if(m_TL[p_ID] >= cvars[9]){menu_additem(bestm,fmt("15 Saniyede Bir Bomba \d[\r%d TL\d]",cvars[9]),"8");}
	else{menu_additem(bestm,fmt("\d15 Saniyede Bir Bomba \d[\r%d TL\d]",cvars[9]),"8");}
	if(m_TL[p_ID] >= cvars[10]){menu_additem(bestm,fmt("10 Saniyede Bir 5 HP \d[\r%d TL\d]",cvars[10]),"9");}
	else{menu_additem(bestm,fmt("\d10 Saniyede Bir 5 HP \d[\r%d TL\d]",cvars[10]),"9");}
	if(m_TL[p_ID] >= cvars[11]){menu_additem(bestm,fmt("Kilik Degistirme \d[\r%d TL\d]",cvars[11]),"10");}
	else{menu_additem(bestm,fmt("\dKilik Degistirme \d[\r%d TL\d]",cvars[11]),"10");}
	if(m_TL[p_ID] >= cvars[13]){menu_additem(bestm,fmt("SG550 Silahi \d(\rOTO AWP\d) \d[\r%d TL\d]",cvars[13]),"11");}
	else{menu_additem(bestm,fmt("\dSG550 Silahi \d(\rOTO AWP\d) \d[\r%d TL\d]",cvars[13]),"11");}
	if(m_TL[p_ID] >= cvars[14]){menu_additem(bestm,fmt("AWP Silahi \d[\r%d TL\d]",cvars[14]),"12");}
	else{menu_additem(bestm,fmt("\dAWP Silahi \d[\r%d TL\d]",cvars[14]),"12");}
	if(m_TL[p_ID] >= cvars[15]){menu_additem(bestm,fmt("Yuksek Ziplama \d(\r15 Saniye\d) \d[\r%d TL\d]",cvars[15]),"13");}
	else{menu_additem(bestm,fmt("\dYuksek Ziplama \d(\r15 Saniye\d) \d[\r%d TL\d]",cvars[15]),"13");}
	if(m_TL[p_ID] >= cvars[16]){menu_additem(bestm,fmt("FallDamage \d(\rOlene Kadar\d) \d[\r%d TL\d]",cvars[16]),"14");}
	else{menu_additem(bestm,fmt("\dFallDamage \d(\rOlene Kadar\d) \d[\r%d TL\d]",cvars[16]),"14");}
	if(m_TL[p_ID] >= cvars[17]){menu_additem(bestm,fmt("Sinirsiz Mermi \d(\r15 Saniye\d) \d[\r%d TL\d]",cvars[17]),"15");}
	else{menu_additem(bestm,fmt("\dSinirsiz Mermi \d(\r15 Saniye\d) \d[\r%d TL\d]",cvars[17]),"15");}

	bestMenuEnd(p_ID,bestm);
}
public dmmarket_handler(p_ID, menu, item){
	if(item == MENU_EXIT){menu_destroy(menu);return PLUGIN_HANDLED;}
	if(!is_user_alive(p_ID)){client_print_color(p_ID,p_ID,"%s ^3Oluyken menuden birsey satin alamazsin.",m_ChatTag);return PLUGIN_HANDLED;}
	if(Elde2kere[p_ID] >= 2){client_print_color(p_ID,p_ID,"%s ^3Her el bu menuden 2 kere alisveris yapabilirsin.",m_ChatTag); return PLUGIN_HANDLED;}
	new data[6],key;menu_item_getinfo(menu, item, _, data, charsmax(data));key = str_to_num(data);
	switch(key){
		case 1:{if(Birkere[p_ID][0] == false){
				new kontrol = kontrolet(p_ID,"250 HP",cvars[1]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][0] = true;
				Elde2kere[p_ID]++;
				set_entvar(p_ID,var_health,Float:get_entvar(p_ID,var_health)+250.0);}
				else {client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED;}}
		case 2:{if(Birkere[p_ID][1] == false){
				new kontrol = kontrolet(p_ID,"250 Armor",cvars[2]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][1] = true;
				Elde2kere[p_ID]++;
				set_entvar(p_ID,var_armorvalue,Float:get_entvar(p_ID,var_armorvalue)+250.0);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 3:{if(Birkere[p_ID][2] == false){
				new kontrol = kontrolet(p_ID,"Hizli Kosma",cvars[3]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][2] = true;
				Elde2kere[p_ID]++;
				set_entvar(p_ID,var_maxspeed,600.0);set_task(15.0,"hizlikosmabitir",p_ID);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 4:{if(Birkere[p_ID][3] == false){
				new kontrol = kontrolet(p_ID,"Can ve Zirh Yenile",cvars[5]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][3] = true;
				Elde2kere[p_ID]++;
				set_entvar(p_ID,var_health,100.0);set_entvar(p_ID,var_armorvalue,100.0);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 5:{if(Birkere[p_ID][4] == false){
				new kontrol = kontrolet(p_ID,"Sessiz Yurume",cvars[6]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][4] = true;
				Elde2kere[p_ID]++;
				rg_set_user_footsteps(p_ID,true);set_task(15.0,"sessizyurumekapat",p_ID);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 6:{if(Birkere[p_ID][5] == false){
				new kontrol = kontrolet(p_ID,"Godmode",cvars[7]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][5] = true;
				Elde2kere[p_ID]++;
				set_entvar(p_ID,var_takedamage,DAMAGE_NO);set_task(10.0,"godmodekapat",p_ID);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 7:{if(Birkere[p_ID][6] == false){
				new kontrol = kontrolet(p_ID,"Oldurme Basina 5 HP",cvars[8]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][6] = true;
				Elde2kere[p_ID]++;
				Oldurme5HP[p_ID] = true;}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 8:{if(Birkere[p_ID][7] == false){
				new kontrol = kontrolet(p_ID,"Her 15 Saniyede Bomba",cvars[9]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][7] = true;
				Elde2kere[p_ID]++;
				Her15SaniyedeBomb[p_ID] = true;
				set_task(15.0,"her15saniyedebomba",p_ID);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 9:{if(Birkere[p_ID][8] == false){
				new kontrol = kontrolet(p_ID,"Her 10 Saniyede 5 HP",cvars[10]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][8] = true;
				Elde2kere[p_ID]++;
				Her10Saniyede5HP[p_ID] = true;
				set_task(10.0,"her10saniyede5hp",p_ID);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 10:{if(Birkere[p_ID][9] == false){
				new kontrol = kontrolet(p_ID,"Kilik Degistirme",cvars[11]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][9] = true;
				Elde2kere[p_ID]++;
				if(get_member(p_ID,m_iTeam) == TEAM_CT){ rg_set_user_model(p_ID,"leet");}
				else{rg_set_user_model(p_ID,"gign");}}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 11:{if(Birkere[p_ID][10] == false){
				new kontrol = kontrolet(p_ID,"SG550 Silahi",cvars[13]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][10] = true;
				Elde2kere[p_ID]++;
				rg_give_item(p_ID,"weapon_sg550");rg_set_user_bpammo(p_ID,WEAPON_SG550,30);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 12:{if(Birkere[p_ID][11] == false){
				new kontrol = kontrolet(p_ID,"AWP Silahi",cvars[14]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][11] = true;
				Elde2kere[p_ID]++;
				rg_give_item(p_ID,"weapon_awp");rg_set_user_bpammo(p_ID,WEAPON_AWP,30);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 13:{if(Birkere[p_ID][12] == false){
				new kontrol = kontrolet(p_ID,"Yuksek Ziplama",cvars[15]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][12] = true;
				Elde2kere[p_ID]++;
				set_entvar(p_ID,var_gravity,Float:0.450);
				set_task(15.0,"gravitybitir",p_ID);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 14:{if(Birkere[p_ID][13] == false){
				new kontrol = kontrolet(p_ID,"Fall Damage",cvars[16]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][13] = true;
				Elde2kere[p_ID]++;
				Falldamage[p_ID] = true;}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
		case 15:{if(Birkere[p_ID][14] == false){
				new kontrol = kontrolet(p_ID,"Sinirsiz Mermi",cvars[17]);if(!kontrol){ return PLUGIN_HANDLED; }
				Birkere[p_ID][14] = true;
				Elde2kere[p_ID]++;
				UnlimitedAmmo[p_ID] = true;
				set_task(15.0,"sinirsizmermibitir",p_ID);}
				else { client_print_color(p_ID,p_ID,"%s ^3Bu secenegi her el bir kere kullanabilirsin.",m_ChatTag); return PLUGIN_HANDLED; }}
	}
	menu_destroy(menu);return PLUGIN_HANDLED;
}
public client_connect(p_ID){m_TL[p_ID] = 0; Oldurme5HP[p_ID] = false; Her15SaniyedeBomb[p_ID] = false; Her10Saniyede5HP[p_ID] = false; Falldamage[p_ID] = false; Elde2kere[p_ID] = 0;}
public client_disconnected(p_ID){m_TL[p_ID] = 0; Oldurme5HP[p_ID] = false; Her15SaniyedeBomb[p_ID] = false; Her10Saniyede5HP[p_ID] = false; Falldamage[p_ID] = false; Elde2kere[p_ID] = 0;}

public bilgiver(p_ID){ client_print_color(p_ID,p_ID,"^3|N| ^1Tusuna Basarak ^4Veya ^1Saydan ^3/Market ^1Yazarak ^4Kazandiginiz Puanlar Sayesinde ^1Ozellik Satın Alabilirsiniz"); }

public bestCW(id) {if(UnlimitedAmmo[id]){
	new wpnid = read_data(2);
	new clip = read_data(3);
	if(wpnid == CSW_C4 || wpnid == CSW_KNIFE) return;
	if(wpnid == CSW_HEGRENADE || wpnid == CSW_SMOKEGRENADE || wpnid == CSW_FLASHBANG) return;
	if (clip == 0) reloadAmmo(id);}}
public reloadAmmo(id){
	if (!is_user_connected(id)) return;
	if (AmmoYenile[id] >= get_systime() - 1) return;AmmoYenile[id] = get_systime();
	new clip, ammo, wpn[32];new wpnid = get_user_weapon(id, clip, ammo);
	if (wpnid == CSW_C4 || wpnid == CSW_KNIFE || wpnid == 0) return;
	if (wpnid == CSW_HEGRENADE || wpnid == CSW_SMOKEGRENADE || wpnid == CSW_FLASHBANG) return;
	if(clip == 0){
	get_weaponname(wpnid,wpn,31);
	new iWPNidx = -1;
	while((iWPNidx = fm_find_ent_by_class(iWPNidx, wpn)) != 0){if(id == pev(iWPNidx, pev_owner)){		
	cs_set_weapon_ammo(iWPNidx, getMaxClipAmmo(wpnid));
	break;}}}}
stock getMaxClipAmmo(wpnid) {
	new clipammo = 0;switch (wpnid) {case CSW_P228 : clipammo = 13;case CSW_SCOUT : clipammo = 10;case CSW_HEGRENADE : clipammo = 0;case CSW_XM1014 : clipammo = 7;case CSW_C4 : clipammo = 0;
	case CSW_MAC10 : clipammo = 30;case CSW_AUG : clipammo = 30;case CSW_SMOKEGRENADE : clipammo = 0;case CSW_ELITE : clipammo = 15;case CSW_FIVESEVEN : clipammo = 20;case CSW_UMP45 : clipammo = 25;
	case CSW_SG550 : clipammo = 30;case CSW_GALI : clipammo = 35;case CSW_FAMAS : clipammo = 25;case CSW_USP : clipammo = 12;case CSW_GLOCK18 : clipammo = 20;case CSW_AWP : clipammo = 10;
	case CSW_MP5NAVY : clipammo = 30;case CSW_M249 : clipammo = 100;case CSW_M3 : clipammo = 8;case CSW_M4A1 : clipammo = 30;case CSW_TMP : clipammo = 30;case CSW_G3SG1 : clipammo = 20;
	case CSW_FLASHBANG : clipammo = 0;case CSW_DEAGLE : clipammo = 7;case CSW_SG552 : clipammo = 30;case CSW_AK47 : clipammo = 30;case CSW_KNIFE : clipammo = 0;case CSW_P90 : clipammo = 50;}return clipammo;}

public bestFD(p_ID){if(Falldamage[p_ID] == true){SetHookChainReturn(ATYPE_FLOAT,0.0);}}
public bestPK(const Victim, const Attacker){
	if(m_TL[Attacker] <= cvars[12] && is_user_alive(Attacker)){
	if(is_user_alive(Attacker)){
	if(get_member(Attacker,m_iTeam) == TEAM_CT && get_member(Victim,m_iTeam) == TEAM_TERRORIST){ client_print_color(Attacker,Attacker,"%s ^3Bir oyuncu oldurdun ve^4 %d TL^3 kazandin.",m_ChatTag,cvars[4]); }
	else{ client_print_color(Attacker,Attacker,"%s ^3Bir oyuncu oldurdun ve^4 %d TL^3 kazandin.",m_ChatTag,cvars[4]);}
	m_TL[Attacker] += cvars[4];}
	else { client_print_color(Attacker,Attacker,"%s ^3Paraniz^4 100 TL ^3oldugu icin daha fazla para kazanamazsiniz.",m_ChatTag);}
	if(Oldurme5HP[Attacker] == true){
	set_entvar(Attacker,var_health,Float:get_entvar(Attacker,var_health)+5.0);
	client_print_color(Attacker,Attacker,"%s ^3Oldurme basina 5 hp aldiginiz icin ekstra 5 hp kazandiniz.",m_ChatTag);}}
	else{ client_print_color(Attacker,Attacker,"%s ^3Mevcut TL'niz^4 %d TL^3'nin uzerinde oldugu icin paraniz artmadi.",m_ChatTag,cvars[12]);}}
public bestPS(p_ID){for(new i = 0; i <= 15; i++){ Birkere[p_ID][i] = false; Oldurme5HP[p_ID] = false; Her15SaniyedeBomb[p_ID] = false; Her10Saniyede5HP[p_ID] = false; Falldamage[p_ID] = false;if(Elde2kere[p_ID] >= 2){Elde2kere[p_ID] = 0;}}}

public her10saniyede5hp(p_ID){if(Her10Saniyede5HP[p_ID] == true){
	set_entvar(p_ID,var_health,Float:get_entvar(p_ID,var_health)+5.0);
	client_print_color(p_ID,p_ID,"%s ^3Her 10 Saniyede 5 HP Aldigin icin^4 5 HP ^3verildi",m_ChatTag);set_task(10.0,"her10saniyede5hp",p_ID);}}
public her15saniyedebomba(p_ID){if(Her15SaniyedeBomb[p_ID] == true){
	rg_give_item(p_ID,"weapon_hegrenade");
	client_print_color(p_ID,p_ID,"%s ^3Her 15 Saniyede Bomba Aldigin icin^4 Bomba ^3verildi",m_ChatTag);set_task(10.0,"her15saniyedebomba",p_ID);}}

public godmodekapat(p_ID){if(is_user_alive(p_ID)){set_entvar(p_ID,var_takedamage,DAMAGE_YES);client_print_color(p_ID,p_ID,"%s ^3Godmode ozelligin sona erdi.",m_ChatTag);}}
public sessizyurumekapat(p_ID){if(is_user_alive(p_ID)){rg_set_user_footsteps(p_ID,false);client_print_color(p_ID,p_ID,"%s ^3Sessiz yurume ozelligin sona erdi.",m_ChatTag);}}
public hizlikosmabitir(p_ID){if(is_user_alive(p_ID)){rg_reset_maxspeed(p_ID);client_print_color(p_ID,p_ID,"%s ^3Hizli yurume ozelligin sona erdi.",m_ChatTag);}}
public gravitybitir(p_ID){if(is_user_alive(p_ID)){set_entvar(p_ID,var_gravity,Float:0.800);client_print_color(p_ID,p_ID,"%s ^3Yuksek ziplama ozelligin sona erdi.",m_ChatTag);}}
public sinirsizmermibitir(p_ID){if(is_user_alive(p_ID)){UnlimitedAmmo[p_ID] = false; client_print_color(p_ID,p_ID,"%s ^3Sinirsiz mermi ozelligin sona erdi.",m_ChatTag);}}

public kontrolet(p_ID,const item[],fiyat){
	if(m_TL[p_ID] >= fiyat){ 
	if(strlen(item)){ client_print_color(p_ID,p_ID,"%s ^3Basarili bir sekilde^4 %s ^3satin aldiniz.",m_ChatTag,item); } 
	m_TL[p_ID] -= fiyat; return 1; }
	else { client_cmd(p_ID,"spk ^"buttons/blip2.wav^""); client_print_color(p_ID,p_ID,"%s ^3Yetersiz miktar.",m_ChatTag); return 0; }}
stock bestMenuEnd(bestID,bestEnd){
	
	menu_setprop(bestEnd,MPROP_BACKNAME,"\yOnceki Sayfa");
	menu_setprop(bestEnd,MPROP_NEXTNAME,"\ySonraki Sayfa");
	menu_setprop(bestEnd,MPROP_EXITNAME,"\yCikis^n^n\dCoded by ` BesTCore");
	menu_setprop(bestEnd,MPROP_NUMBER_COLOR,"\r");
	menu_display(bestID,bestEnd);
}