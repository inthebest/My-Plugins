// Plugin Coded by ` BesTCore;

#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <engine>

/***************** Kendine Göre Ayarla *************/

new const iUstTag[]  = "\rCSDuragi.COM\d - ";
new const iAltTag[]  = "\wCSDuragi.COM\d -\y ";
new const iChatTag[] = "^1[^4CSDuragi.COM^1]";

#define VIP_YETKI      ADMIN_BAN
#define ADMINS_YETKI   ADMIN_MAP
#define KOMUTCU_YETKI  ADMIN_KICK
#define SLOT_YETKI     ADMIN_RESERVATION

/***************************************************/

native iLogin(id);
native iRegister(id);
native iOtoRegister(id);
native iExit(id);
native iAccountsNum(id);
native iAccountsNumControl(id);
native iLastAccountsNum();

enum (+= 1453) {
	TASK_ELEKTRIKLERIKES = 1453,
	TASK_GODMODE,
	TASK_GARDIYANLARIKALDIR,
	TASK_ZAMANHESAPLA,
	TASK_TLHIRSIZITLVER
}
enum _: intDeger {
	uid,
	iTL,
	iEsyaDeger,
	iEsyaFiyat,
	iPlayersTime,
	iCTOldur,
	iFlashBombasiAl,
	iCTGom,
	iArkadasiniRevle,
	iStrAktifMeslek[27],
	iAktifMeslek,
	iSecilenOyuncu
};
new nInt[MAX_CLIENTS+1][intDeger];

enum _: boolDeger {
	bMarket,
	bBicak1,
	bBicak2,
	bBicak3,
	bKanBagis,
	bSunucudaOyna,
	bCTOldur,
	bFlashBombasiAl,
	bCTGom,
	bArkadasiniRevle,
	bBonusMenu,
	bMeslekMenu,
	bTLGonder
};
new bool:bInt[MAX_CLIENTS+1][boolDeger];

enum _: intCvars {
	MarketBicak1,
	MarketBicak2,
	MarketBicak3,
	MarketKanBagis,
	IsyanMenu100HP,
	IsyanMenuHizliYurume,
	IsyanMenuYuksekZiplama,
	IsyanMenuKendiniKaldir,
	IsyanMenuArkadasiniRevle,
	IsyanMenuElektrikleriKes,
	IsyanMenuGodMode,
	CephaneMenuFlashBombasi,
	CephaneMenuElBombasi,
	CephaneMenuBombaSeti,
	CephaneMenuUsp,
	CephaneMenuGlock,
	CephaneMenuAWP,
	CephaneMenuKalkan,
	SavunmaMenuMahkumHPVer,
	SavunmaMenuMahkumElBombasiVer,
	SavunmaMenuMahkumFlashBombasiVer,
	SavunmaMenuGardiyanGom,
	GorevMenuSunucudaOyna,
	GorevMenuCTOldur,
	GorevMenuFlashBombasiAl,
	GorevMenuCTGom,
	GorevMenuArkadasiniRevle,
	OldurmeBasinaTL,
	MaksTLTransfer
};
new cvars[intCvars];

enum _: Models {
	v_DefaultT,p_DefaultT,
	v_DefaultCT,p_DefaultCT,
	v_Bicak1,
	v_Bicak2,
	v_Bicak3
};
new const iModels[][] = {
	/*********** Default T Models **********/
	"models/[Shop]JailBreak/Punos/Punos.mdl",
	"models/[Shop]JailBreak/Punos/Punos2.mdl",

	/*********** Default CT Models ************/
	"models/[Shop]JailBreak/Electro/Electro.mdl",
	"models/[Shop]JailBreak/Electro/Electro2.mdl",

	/*********** Market Menu 1. Model ***********/
	"models/jbmenubicak/v_kelebek.mdl",
	/*********** Market Menu 2. Model ***********/
	"models/jbmenubicak/v_karambit.mdl",
	/*********** Market Menu 3. Model ***********/
	"models/jbmenubicak/v_hunstman.mdl"
};

public plugin_init(){
	register_plugin("[REAPI] Gelismis Hesap Sistemli JBMenu","1.0","` BesTCore;");

	register_clcmd("say /jbmenu", "control");
	register_clcmd("nightvision", "control");
	register_clcmd("say /mg", "tlver");

	register_clcmd("MIKTAR_BELIRLE", "tlvermiktar");

	RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "RG_CBasePlayerWeapon_DefaultDeploy_", .post = false);
	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_", .post = false);
	RegisterHookChain(RG_CBasePlayer_Killed, "RG_CBasePlayer_Killed_", .post = true);
	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer_Spawn_", .post = true);
	RegisterHookChain(RG_CSGameRules_FlPlayerFallDamage, "RG_CSGameRules_FlPlayerFallDamage_", .post = true);

	/*********************** JBMenu Market Menu Cvars *************************/
	bind_pcvar_num(create_cvar("MarketMenu_Bicak1", "-1"), cvars[MarketBicak1]);
	bind_pcvar_num(create_cvar("MarketMenu_Bicak2", "10"), cvars[MarketBicak2]);
	bind_pcvar_num(create_cvar("MarketMenu_Bicak3", "20"), cvars[MarketBicak3]);
	bind_pcvar_num(create_cvar("MarketMenu_KanBagis", "10"), cvars[MarketKanBagis]);
	/*********************** JBMenu Isyan Menu Cvars *************************/
	bind_pcvar_num(create_cvar("IsyanMenu_100HP", "10"), cvars[IsyanMenu100HP]);
	bind_pcvar_num(create_cvar("IsyanMenu_HizliYurume", "10"), cvars[IsyanMenuHizliYurume]);
	bind_pcvar_num(create_cvar("IsyanMenu_YuksekZiplama", "10"), cvars[IsyanMenuYuksekZiplama]);
	bind_pcvar_num(create_cvar("IsyanMenu_KendiniKaldir", "10"), cvars[IsyanMenuKendiniKaldir]);
	bind_pcvar_num(create_cvar("IsyanMenu_ArkadasiniRevle", "10"), cvars[IsyanMenuArkadasiniRevle]);
	bind_pcvar_num(create_cvar("IsyanMenu_ElektrikleriKes", "10"), cvars[IsyanMenuElektrikleriKes]);
	bind_pcvar_num(create_cvar("IsyanMenu_Godmode", "10"), cvars[IsyanMenuGodMode]);
	/*********************** JBMenu Cephane Menu Cvars *************************/
	bind_pcvar_num(create_cvar("CephaneMenu_1AdetFlashBombasi", "10"), cvars[CephaneMenuFlashBombasi]);
	bind_pcvar_num(create_cvar("CephaneMenu_2AdetElBombasi", "10"), cvars[CephaneMenuElBombasi]);
	bind_pcvar_num(create_cvar("CephaneMenu_BombaSeti", "10"), cvars[CephaneMenuBombaSeti]);
	bind_pcvar_num(create_cvar("CephaneMenu_USP", "10"), cvars[CephaneMenuUsp]);
	bind_pcvar_num(create_cvar("CephaneMenu_Glock", "10"), cvars[CephaneMenuGlock]);
	bind_pcvar_num(create_cvar("CephaneMenu_AWP", "10"), cvars[CephaneMenuAWP]);
	bind_pcvar_num(create_cvar("CephaneMenu_Kalkan", "10"), cvars[CephaneMenuKalkan]);
	/*********************** JBMenu Savunma Menu Cvars *************************/
	bind_pcvar_num(create_cvar("SavunmaMenu_MahkumlaraHPVer", "10"), cvars[SavunmaMenuMahkumHPVer]);
	bind_pcvar_num(create_cvar("SavunmaMenu_MahkumlaraElBombasiVer", "10"), cvars[SavunmaMenuMahkumElBombasiVer]);
	bind_pcvar_num(create_cvar("SavunmaMenu_MahkumlaraFlashBombasiVer", "10"), cvars[SavunmaMenuMahkumFlashBombasiVer]);
	bind_pcvar_num(create_cvar("SavunmaMenu_GardiyanlariGom", "10"), cvars[SavunmaMenuGardiyanGom]);
	/*********************** JBMenu Gorev Menu Cvars *************************/
	bind_pcvar_num(create_cvar("GorevMenu_SunucudaTakilOdul", "10"), cvars[GorevMenuSunucudaOyna]);
	bind_pcvar_num(create_cvar("GorevMenu_CTOldurOdul", "10"), cvars[GorevMenuCTOldur]);
	bind_pcvar_num(create_cvar("GorevMenu_FlashBombasiAlOdul", "10"), cvars[GorevMenuFlashBombasiAl]);
	bind_pcvar_num(create_cvar("GorevMenu_CTGomOdul", "10"), cvars[GorevMenuCTGom]);
	bind_pcvar_num(create_cvar("GorevMenu_ArkadasiniRevleOdul", "10"), cvars[GorevMenuArkadasiniRevle]);
	/*********************** JBMenu Extra Cvars *************************/
	bind_pcvar_num(create_cvar("OldurmeBasinaTL", "10"), cvars[OldurmeBasinaTL]);
	bind_pcvar_num(create_cvar("MaksimumTLTransfer", "300"), cvars[MaksTLTransfer]);
}
public control(id){
	if(nInt[id][uid]){
		jbmenu(id);
	}
	else {
		giriskayit(id);
	}
}
public giriskayit(id){
	new bestm = menu_create(fmt("%s Jailbreak Menu Yonlendirme", iUstTag), "giriskayit_");

	menu_additem(bestm, fmt("%s Giris Yap", iAltTag), "1");
	menu_additem(bestm, fmt("%s Kayit Ol", iAltTag), "2");
	menu_additem(bestm, fmt("%s Otomatik Kayit Ol^n", iAltTag), "3");
	menu_addtext(bestm, "\dOtomatik kayit olursaniz rastgele isim ve sifre ile hesap olusturulur.");

	bestMenuEnd(id, bestm);
}
public giriskayit_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			iLogin(id);
		}
		case 2:{
			iRegister(id);
		}
		case 3:{
			iOtoRegister(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public jbmenu(id){
	new bestm = menu_create(fmt("%s Jailbreak Menu^n\dMevcut TL:\y %d TL", iUstTag, nInt[id][iTL]), "jbmenu_");

	if(!(get_member(id, m_iTeam) == TEAM_TERRORIST)) { client_print_color(id, id, "%s ^3Bu menuye sadece mahkumlar girebilir.", iChatTag); return PLUGIN_HANDLED; }
	else if(!is_user_alive(id)) { client_print_color(id, id, "%s ^3Bu menuye sadece canlilar girebilir.", iChatTag); return PLUGIN_HANDLED; }

	menu_additem(bestm, fmt("%s Market Menu %s", iAltTag, bInt[id][bMarket] ? "\d[\rKullandiniz\d]":""), "3");
	menu_additem(bestm, fmt("%s %sAlisveris Menu", iAltTag, godmode() ? "\d":"\y"), "4");
	menu_additem(bestm, fmt("%s Gorev Menu", iAltTag), "5");
	menu_additem(bestm, fmt("%s Bonus Menu", iAltTag), "6");
	menu_additem(bestm, fmt("%s Meslek Menu", iAltTag), "7");
	menu_additem(bestm, "Cikis yap", "120");

	bestMenuEnd(id, bestm);
	return PLUGIN_HANDLED;
}
public jbmenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			iLogin(id);
		}
		case 2:{
			iRegister(id);
		}
		case 3:{
			if(bInt[id][bMarket]){
				client_print_color(id, id, "%s ^3Market menuyu her el bir kere kullanabilirsin.", iChatTag);
				jbmenu(id);
			}
			else {
				marketmenu(id);
			}
		}
		case 4:{
			if(godmode()){
				client_print_color(id, id, "%s ^3Godmode varken alisveris menusune giris yapamazsiniz.", iChatTag);
				jbmenu(id);
			}
			else {
				alisverismenu(id);
			}
		}
		case 5:{
			gorevmenu(id);
		}
		case 6:{
			if(!bInt[id][bBonusMenu]){
				bonusmenu(id);
			}
			else {
				client_print_color(id, id, "%s ^3Bonus menuyu her elde bir kere kullanabilirsin.", iChatTag);
				jbmenu(id);
			}
		}
		case 7:{
			meslekmenu(id);
		}
		case 8:{
			jbmenu(id);
		}
		case 120:{
			iExit(id);
			sifirla(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public meslekmenu(id){
	new bestm = menu_create(fmt("%s Meslek Menu", iUstTag), "meslekmenu_");

	menu_additem(bestm, "\yAvci  \w- \d(Her CT Oldurdugunde +5 TL ve +20 HP)", "1");
	menu_additem(bestm, "\yAstronot \w- \d(Yere Dusunce Can Gitmez)", "2");
	menu_additem(bestm, "\yTL Hirsizi \w- \d(Her 5 Dakikada Bir 5 TL)", "3");
	menu_additem(bestm, "\yBombaci \w- \d(Her El Bomba Seti)", "4");
	menu_additem(bestm, "\yKral \w- \d(Her El 150 HP + 150 Armor)", "5");

	bestMenuEnd(id, bestm);
}
public meslekmenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	if(bInt[id][bMeslekMenu]){
		client_print_color(id, id, "%s ^3Her el bir kere meslek degistirebilirsin.", iChatTag);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			if(nInt[id][iAktifMeslek] == 1){
				client_print_color(id, id, "%s ^3Sen zaten^4 Avci^3 meslegini kullaniyorsun.", iChatTag);
				return PLUGIN_HANDLED;
			}
			else {
				nInt[id][iStrAktifMeslek] = "Aktif Meslegin: Avci";
				nInt[id][iAktifMeslek] = 1;
				bInt[id][bMeslekMenu] = true;
				client_print_color(id, id, "%s ^3Basarili bir sekilde meslegin^4 Avci^3 olarak secildi.", iChatTag);
				return PLUGIN_HANDLED;
			}
		}
		case 2:{
			if(nInt[id][iAktifMeslek] == 2){
				client_print_color(id, id, "%s ^3Sen zaten^4 Astronot^3 meslegini kullaniyorsun.", iChatTag);
				return PLUGIN_HANDLED;
			}
			else {
				nInt[id][iStrAktifMeslek] = "Aktif Meslegin: Astronot";
				nInt[id][iAktifMeslek] = 2;
				bInt[id][bMeslekMenu] = true;
				client_print_color(id, id, "%s ^3Basarili bir sekilde meslegin^4 Astronot^3 olarak secildi.", iChatTag);
				return PLUGIN_HANDLED;
			}
		}
		case 3:{
			if(nInt[id][iAktifMeslek] == 3){
				client_print_color(id, id, "%s ^3Sen zaten^4 TL Hirsizi^3 meslegini kullaniyorsun.", iChatTag);
				return PLUGIN_HANDLED;
			}
			else {
				nInt[id][iStrAktifMeslek] = "Aktif Meslegin: TL Hirsizi";
				nInt[id][iAktifMeslek] = 3;
				bInt[id][bMeslekMenu] = true;
				set_task(300.0, "TLHirsiziTLVer", id + TASK_TLHIRSIZITLVER);
				client_print_color(id, id, "%s ^3Basarili bir sekilde meslegin^4 TL Hirsizi^3 olarak secildi.", iChatTag);
				return PLUGIN_HANDLED;
			}
		}
		case 4:{
			if(nInt[id][iAktifMeslek] == 4){
				client_print_color(id, id, "%s ^3Sen zaten^4 Bombaci^3 meslegini kullaniyorsun.", iChatTag);
				return PLUGIN_HANDLED;
			}
			else {
				nInt[id][iStrAktifMeslek] = "Aktif Meslegin: Bombaci";
				nInt[id][iAktifMeslek] = 4;
				bInt[id][bMeslekMenu] = true;
				client_print_color(id, id, "%s ^3Basarili bir sekilde meslegin^4 Bombaci^3 olarak secildi.", iChatTag);
				return PLUGIN_HANDLED;
			}
		}
		case 5:{
			if(nInt[id][iAktifMeslek] == 5){
				client_print_color(id, id, "%s ^3Sen zaten^4 Kral^3 meslegini kullaniyorsun.", iChatTag);
				return PLUGIN_HANDLED;
			}
			else {
				nInt[id][iStrAktifMeslek] = "Aktif Meslegin: Kral";
				nInt[id][iAktifMeslek] = 5;
				bInt[id][bMeslekMenu] = true;
				client_print_color(id, id, "%s ^3Basarili bir sekilde meslegin^4 Kral^3 olarak secildi.", iChatTag);
				return PLUGIN_HANDLED;
			}
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public bonusmenu(id){
	new flags = get_user_flags(id);
	new bestm = menu_create(fmt("%s Bonus Menu", iUstTag), "bonusmenu_");

	if(flags & VIP_YETKI) {
		menu_additem(bestm, "+15 TL", "1");
		menu_additem(bestm, "+50 Can", "2");
		menu_additem(bestm, "Yuksek Ziplama", "3");
		menu_additem(bestm, "Hizli Yurume", "4");
	}
	else if(flags & ADMINS_YETKI) {
		menu_additem(bestm, "+12 TL", "1");
		menu_additem(bestm, "+30 Can", "2");
		menu_additem(bestm, "Yusek Ziplama", "3");
		menu_additem(bestm, "Hizli Yurume", "4");
	}
	else if(flags & KOMUTCU_YETKI) {
		menu_additem(bestm, "+10 TL", "1");
		menu_additem(bestm, "+20 Can", "2");
		menu_additem(bestm, "Yuksek Ziplama", "3");
	}
	else if(flags & SLOT_YETKI) {
		menu_additem(bestm, "+7 TL", "1");
		menu_additem(bestm, "+10 Can", "2");
		menu_additem(bestm, "Yuksek Ziplama", "3");
	}
	else {
		menu_additem(bestm, "+2 TL", "1");
		menu_additem(bestm, "+5 Can", "2");
	}

	bestMenuEnd(id, bestm);
}
public bonusmenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key, flags = get_user_flags(id);
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			if(flags & VIP_YETKI) nInt[id][iTL] += 15;
				else if(flags & ADMINS_YETKI) nInt[id][iTL] += 12;
					else if(flags & KOMUTCU_YETKI) nInt[id][iTL] += 10;
						else if(flags & SLOT_YETKI) nInt[id][iTL] += 7;
							else nInt[id][iTL] += 2;
			bInt[id][bBonusMenu] = true;
			jbmenu(id);
		}
		case 2:{
			if(flags & VIP_YETKI) set_entvar(id, var_health, Float:get_entvar(id, var_health)+50.0);
				else if(flags & ADMINS_YETKI) set_entvar(id, var_health, Float:get_entvar(id, var_health)+30.0);
					else if(flags & KOMUTCU_YETKI) set_entvar(id, var_health, Float:get_entvar(id, var_health)+20.0);
						else if(flags & SLOT_YETKI) set_entvar(id, var_health, Float:get_entvar(id, var_health)+10.0);
							else set_entvar(id, var_health, Float:get_entvar(id, var_health)+5.0);
			bInt[id][bBonusMenu] = true;
			jbmenu(id);
		}
		case 3:{
			if(flags & VIP_YETKI) set_entvar(id, var_gravity, 0.4);
				else if(flags & ADMINS_YETKI) set_entvar(id, var_gravity, 0.5);
					else if(flags & KOMUTCU_YETKI) set_entvar(id, var_gravity, 0.6);
						else if(flags & SLOT_YETKI) set_entvar(id, var_gravity, 0.6);
			bInt[id][bBonusMenu] = true;
			jbmenu(id);
		}
		case 4:{
			if(flags & VIP_YETKI) set_entvar(id, var_maxspeed, 350.0);
				else if(flags & ADMINS_YETKI) set_entvar(id, var_maxspeed, 400.0);
			bInt[id][bBonusMenu] = true;
			jbmenu(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public marketmenu(id){
	new bestm = menu_create(fmt("%s Market Menu", iUstTag), "marketmenu_");

	menu_additem(bestm, fmt("Kelebek \d[\r%i \yTL\d]", cvars[MarketBicak1]), "1");
	menu_additem(bestm, fmt("Karambit \d[\r%i \yTL\d]", cvars[MarketBicak2]), "2");

	if(get_user_flags(id) & VIP_YETKI) menu_additem(bestm, fmt("Huntsman \d[\r%i \yTL\d]^n", cvars[MarketBicak3]), "3");
	else menu_additem(bestm, fmt("Hunstman \d[\r%i TL\d] \d[\rVIP OZEL\d]^n", cvars[MarketBicak3]), "3");

	menu_additem(bestm, fmt("Kan Bagisla \d(\r-99 HP\d) \d[\r+%i \yTL\d]", cvars[MarketKanBagis]), "4");

	bestMenuEnd(id, bestm);
}
public marketmenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			buyitem(id, "Kelebek Bicagi", cvars[MarketBicak1], 1);
		}
		case 2:{
			buyitem(id, "Karambit Bicagi", cvars[MarketBicak2], 2);
		}
		case 3:{
			if(get_user_flags(id) & VIP_YETKI) buyitem(id, "Hunstman Bicagi", cvars[MarketBicak3], 3);
			else client_print_color(id, id, "%s ^3Bu bicagi satin almak icin yeterli yetkiniz bulunmamaktadir.", iChatTag); return PLUGIN_HANDLED;
		}
		case 4:{
			if(bInt[id][bKanBagis]){
				client_print_color(id, id, "%s ^3Her el bir kere kan bagislayabilirsin.", iChatTag);
				return PLUGIN_HANDLED;
			}
			else {
				new Float:can = get_entvar(id, var_health);
				if(can >= 100.0){
					nInt[id][iTL] += cvars[MarketKanBagis];
					bInt[id][bKanBagis] = true;
					set_entvar(id, var_health, can -99.0);
					client_print_color(id, id, "%s ^3Basarili bir sekilde kaninizi bagisladiniz.", iChatTag);
				}
				else {
					client_print_color(id, id, "%s ^3HP'niz^4 99^3'dan kucuk oldugu icin kan bagislayamazsiniz.", iChatTag);
					return PLUGIN_HANDLED;
				}
			}
			marketmenu(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public gorevmenu(id){
	new bestm = menu_create(fmt("%s Gorev Menu", iUstTag), "gorevmenu_");

	if(bInt[id][bSunucudaOyna]) menu_additem(bestm, fmt("20 Dakika Sunucuda Oyna \d[\rTamamlandi\d] \d[\r%i \yTL\d]", cvars[GorevMenuSunucudaOyna]), "1");
	else if (nInt[id][iPlayersTime] >= 20) menu_additem(bestm, fmt("20 Dakika Sunucuda Oyna \d[\rTikla Parani Al\d] \d[\r%i \yTL\d]", cvars[GorevMenuSunucudaOyna]), "1");
	else if (!bInt[id][bSunucudaOyna]) menu_additem(bestm, fmt("20 Dakika Sunucuda Oyna \d[\w%d\d/\r20\d] \d[\r%i \yTL\d]", nInt[id][iPlayersTime], cvars[GorevMenuSunucudaOyna]), "1");

	if(bInt[id][bCTOldur]) menu_additem(bestm, fmt("CT Oldur \d[\rTamamlandi\d] \d[\r%i \yTL\d]", cvars[GorevMenuCTOldur]), "2");
	else if (nInt[id][iCTOldur] >= 10) menu_additem(bestm, fmt("CT Oldur \d[\rTikla Parani Al\d] \d[\r%i \yTL\d]", cvars[GorevMenuCTOldur]), "2");
	else if (!bInt[id][bCTOldur]) menu_additem(bestm, fmt("CT Oldur \d[\w%d\d/\r10\d] \d[\r%i \yTL\d]", nInt[id][iCTOldur], cvars[GorevMenuCTOldur]), "2");

	if(bInt[id][bFlashBombasiAl]) menu_additem(bestm, fmt("Flash Bombasi Al \d[\rTamamlandi\d] \d[\r%i \yTL\d]", cvars[GorevMenuFlashBombasiAl]), "3");
	else if (nInt[id][iFlashBombasiAl] >= 5) menu_additem(bestm, fmt("Flash Bombasi Al \d[\rTikla Parani Al\d] \d[\r%i \yTL\d]", cvars[GorevMenuFlashBombasiAl]), "3");
	else if (!bInt[id][bFlashBombasiAl]) menu_additem(bestm, fmt("Flash Bombasi Al \d[\w%d\d/\r5\d] \d[\r%i \yTL\d]", nInt[id][iFlashBombasiAl], cvars[GorevMenuFlashBombasiAl]), "3");

	if(bInt[id][bCTGom]) menu_additem(bestm, fmt("CTleri Gom \d[\rTamamlandi\d] \d[\r%i \yTL\d]", cvars[GorevMenuCTGom]), "4");
	else if (nInt[id][iCTGom] >= 2) menu_additem(bestm, fmt("CTleri Gom \d[\rTikla Parani Al\d] \d[\r%i \yTL\d]", cvars[GorevMenuCTGom]), "4");
	else if (!bInt[id][bCTGom]) menu_additem(bestm, fmt("CTleri Gom \d[\w%d\d/\r2\d] \d[\r%i \yTL\d]", nInt[id][iCTGom], cvars[GorevMenuCTGom]), "4");

	if(bInt[id][bArkadasiniRevle]) menu_additem(bestm, fmt("Arkadasini Revle \d[\rTamamlandi\d] \d[\r%i \yTL\d]", cvars[GorevMenuArkadasiniRevle]), "5");
	else if (nInt[id][iArkadasiniRevle] >= 2) menu_additem(bestm, fmt("Arkadasini Revle \d[\rTikla Parani Al\d] \d[\r%i \yTL\d]", cvars[GorevMenuArkadasiniRevle]), "5");
	else if (!bInt[id][bArkadasiniRevle]) menu_additem(bestm, fmt("Arkadasini Revle \d[\w%d\d/\r4\d] \d[\r%i \yTL\d]", nInt[id][iArkadasiniRevle], cvars[GorevMenuArkadasiniRevle]), "5");

	bestMenuEnd(id, bestm);
}
public gorevmenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			if(bInt[id][bSunucudaOyna]){
				client_print_color(id, id, "%s ^3Bu gorevini tamamladin ve odulunu aldin.", iChatTag);
			}
			else if(nInt[id][iPlayersTime] >= 20){
				nInt[id][iTL] += cvars[GorevMenuSunucudaOyna];
				bInt[id][bSunucudaOyna] = true;
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 20 Dakika Sunucuda Oyna^3 gorevini tamamladin.", iChatTag);
			}
			else if(!bInt[id][bSunucudaOyna]){
				client_print_color(id, id, "%s ^3Bu gorevin hala devam ediyor^1 [^4%d ^1/^3 20^1]", iChatTag, nInt[id][iPlayersTime]);
			}
			gorevmenu(id);
		}
		case 2:{
			if(bInt[id][bCTOldur]){
				client_print_color(id, id, "%s ^3Bu gorevini tamamladin ve odulunu aldin.", iChatTag);
			}
			else if(nInt[id][iCTOldur] >= 10){
				nInt[id][iTL] += cvars[GorevMenuCTOldur];
				bInt[id][bCTOldur] = true;
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 CT Oldur^3 gorevini tamamladin.", iChatTag);
			}
			else if(!bInt[id][bCTOldur]){
				client_print_color(id, id, "%s ^3Bu gorevin hala devam ediyor^1 [^4%d ^1/^3 10^1]", iChatTag, nInt[id][iCTOldur]);
			}
			gorevmenu(id);
		}
		case 3:{
			if(bInt[id][bFlashBombasiAl]){
				client_print_color(id, id, "%s ^3Bu gorevini tamamladin ve odulunu aldin.", iChatTag);
			}
			else if(nInt[id][iFlashBombasiAl] >= 5){
				nInt[id][iTL] += cvars[GorevMenuFlashBombasiAl];
				bInt[id][bFlashBombasiAl] = true;
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 Flash Bombasi Al^3 gorevini tamamladin.", iChatTag);
			}
			else if(!bInt[id][bFlashBombasiAl]){
				client_print_color(id, id, "%s ^3Bu gorevin hala devam ediyor^1 [^4%d ^1/^3 5^1]", iChatTag, nInt[id][iFlashBombasiAl]);
			}
			gorevmenu(id);
		}
		case 4:{
			if(bInt[id][bCTGom]){
				client_print_color(id, id, "%s ^3Bu gorevini tamamladin ve odulunu aldin.", iChatTag);
			}
			else if(nInt[id][iCTGom] >= 2){
				nInt[id][iTL] += cvars[GorevMenuCTGom];
				bInt[id][bCTGom] = true;
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 CT Gom^3 gorevini tamamladin.", iChatTag);
			}
			else if(!bInt[id][bCTGom]){
				client_print_color(id, id, "%s ^3Bu gorevin hala devam ediyor^1 [^4%d ^1/^3 2^1]", iChatTag, nInt[id][iCTGom]);
			}
			gorevmenu(id);
		}
		case 5:{
			if(bInt[id][bArkadasiniRevle]){
				client_print_color(id, id, "%s ^3Bu gorevini tamamladin ve odulunu aldin.", iChatTag);
			}
			else if(nInt[id][iArkadasiniRevle] >= 4){
				nInt[id][iTL] += cvars[GorevMenuArkadasiniRevle];
				bInt[id][bArkadasiniRevle] = true;
				client_print_color(id, id, "%s ^3Basarili bir sekilde^4 Arkadasini Revle^3 gorevini tamamladin.", iChatTag);
			}
			else if(!bInt[id][bArkadasiniRevle]){
				client_print_color(id, id, "%s ^3Bu gorevin hala devam ediyor^1 [^4%d ^1/^3 4^1]", iChatTag, nInt[id][iArkadasiniRevle]);
			}
			gorevmenu(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public alisverismenu(id){
	new bestm = menu_create(fmt("%s Alisveris Menu", iUstTag), "alisverismenu_");

	menu_additem(bestm, fmt("%s Isyan Menu", iAltTag), "1");
	menu_additem(bestm, fmt("%s Cephane Menu", iAltTag), "2");
	menu_additem(bestm, fmt("%s Savunma Menu", iAltTag), "3");

	bestMenuEnd(id, bestm);
}
public alisverismenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			isyanmenu(id);
		}
		case 2:{
			cephanemenu(id);
		}
		case 3:{
			savunmamenu(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public savunmamenu(id){
	new bestm = menu_create(fmt("%s Savunma Menu", iUstTag), "savunmamenu_");

	menu_additem(bestm, fmt("Mahkumlara +75 HP Ver \d[\r%i \yTL\d]", cvars[SavunmaMenuMahkumHPVer]), "1");
	menu_additem(bestm, fmt("Mahkumlara El Bombasi Ver \d[\r%i \yTL\d]", cvars[SavunmaMenuMahkumElBombasiVer]), "2");
	menu_additem(bestm, fmt("Mahkumlara Flash Bombasi Ver \d[\r%i \yTL\d]", cvars[SavunmaMenuMahkumFlashBombasiVer]), "3");
	menu_additem(bestm, fmt("Gardiyanlari 3 Saniye Gom \d[\r%i \yTL\d]", cvars[SavunmaMenuGardiyanGom]), "4");

	bestMenuEnd(id, bestm);
}
public savunmamenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			buyitem(id, "Mahkumlara +75 HP Ver", cvars[SavunmaMenuMahkumHPVer], 18);
		}
		case 2:{
			buyitem(id, "Mahkumlara El Bombasi Ver", cvars[SavunmaMenuMahkumElBombasiVer], 19);
		}
		case 3:{
			buyitem(id, "Mahkumlara Flash Bombasi Ver", cvars[SavunmaMenuMahkumFlashBombasiVer], 20);
		}
		case 4:{
			buyitem(id, "Gardiyanlari 3 Saniye Gom", cvars[SavunmaMenuGardiyanGom], 21);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public cephanemenu(id){
	new bestm = menu_create(fmt("%s Cephane Menu", iUstTag), "cephanemenu_");

	menu_additem(bestm, fmt("1 Adet Flash Bombasi \d[\r%i \yTL\d]", cvars[CephaneMenuFlashBombasi]), "1");
	menu_additem(bestm, fmt("2 Adet El Bombasi \d[\r%i \yTL\d]", cvars[CephaneMenuElBombasi]), "2");
	menu_additem(bestm, fmt("Bomba Seti \d[\r%i \yTL\d]", cvars[CephaneMenuBombaSeti]), "3");
	menu_additem(bestm, fmt("12 Mermili Usp \d[\r%i \yTL\d]", cvars[CephaneMenuUsp]), "4");
	menu_additem(bestm, fmt("20 Mermili Glock \d[\r%i \yTL\d]", cvars[CephaneMenuGlock]), "5");
	menu_additem(bestm, fmt("3 Mermili AWP \d[\r%i \yTL\d]", cvars[CephaneMenuAWP]), "6");
	menu_additem(bestm, fmt("Kalkan \d[\r%i \yTL\d]", cvars[CephaneMenuKalkan]), "7");

	bestMenuEnd(id, bestm);
}
public cephanemenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			buyitem(id, "1 Adet Flash Bombasi", cvars[CephaneMenuFlashBombasi], 11);
		}
		case 2:{
			buyitem(id, "2 Adet El Bombasi", cvars[CephaneMenuElBombasi], 12);
		}
		case 3:{
			buyitem(id, "Bomba Seti", cvars[CephaneMenuBombaSeti], 13);
		}
		case 4:{
			buyitem(id, "12 Mermili Usp", cvars[CephaneMenuUsp], 14);
		}
		case 5:{
			buyitem(id, "20 Mermili Glock", cvars[CephaneMenuGlock], 15);
		}
		case 6:{
			buyitem(id, "3 Mermili AWP", cvars[CephaneMenuAWP], 16);
		}
		case 7:{
			buyitem(id, "Kalkan", cvars[CephaneMenuKalkan], 17);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public isyanmenu(id){
	new bestm = menu_create(fmt("%s Isyan Menu", iUstTag), "isyanmenu_");

	menu_additem(bestm, fmt("100 HP \d[\r%i \yTL\d]", cvars[IsyanMenu100HP]), "1");
	menu_additem(bestm, fmt("Hizli Yurume \d[\r%i \yTL\d]", cvars[IsyanMenuHizliYurume]), "2");
	menu_additem(bestm, fmt("Yuksek Ziplama \d[\r%i \yTL\d]", cvars[IsyanMenuYuksekZiplama]), "3");
	menu_additem(bestm, fmt("Kendini Kaldir \d[\r%i \yTL\d]", cvars[IsyanMenuKendiniKaldir]), "4");
	menu_additem(bestm, fmt("Arkadasini Revle \d[\r%i \yTL\d]", cvars[IsyanMenuArkadasiniRevle]), "5");
	menu_additem(bestm, fmt("Elektrikleri Kes \d[\r%i \yTL\d] \d(\r5 \ySaniye\d)", cvars[IsyanMenuElektrikleriKes]), "6");
	menu_additem(bestm, fmt("GodMode \d[\r%i \yTL\d] \d(\r3 \ySaniye\d)", cvars[IsyanMenuGodMode]), "7");

	bestMenuEnd(id, bestm);
}
public isyanmenu_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			buyitem(id, "100 HP", cvars[IsyanMenu100HP], 4);
		}
		case 2:{
			buyitem(id, "Hizli Yurume", cvars[IsyanMenuHizliYurume], 5);
		}
		case 3:{
			buyitem(id, "Yuksek Ziplama", cvars[IsyanMenuYuksekZiplama], 6);
		}
		case 4:{
			buyitem(id, "Kendini Kaldir", cvars[IsyanMenuKendiniKaldir], 7);
		}
		case 5:{
			buyitem(id, "Arkadasini Revle", cvars[IsyanMenuArkadasiniRevle], 8);
		}
		case 6:{
			buyitem(id, "Elektrikleri Kes", cvars[IsyanMenuElektrikleriKes], 9);
		}
		case 7:{
			buyitem(id, "3 Saniye GodMode", cvars[IsyanMenuGodMode], 10);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public arkadasinirevle(id){
	new bestm = menu_create(fmt("%s Arkadasini Revle", iUstTag), "arkadasinirevle_");

	for(new i = 1, NTS[6]; i <= MaxClients; i++){
		if(is_user_connected(i) && get_member(i, m_iTeam) == TEAM_TERRORIST && !is_user_alive(i)){
			num_to_str(i, NTS, charsmax(NTS));
			menu_additem(bestm, fmt("%n", i), NTS);
		}
	}
	bestMenuEnd(id, bestm);
	return PLUGIN_HANDLED;
}
public arkadasinirevle_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);

	if(!is_user_alive(key) && is_user_connected(key) && get_member(key, m_iTeam) == TEAM_TERRORIST){
		rg_round_respawn(key);
		client_print_color(key, key, "%s^1 %n ^3isimli oyuncu seni isyan menuden canlandirdi", iChatTag, id);
		return PLUGIN_HANDLED;
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public tlver(id){
	if(!(get_member(id, m_iTeam) == TEAM_CT)) client_print_color(id, id, "%s ^3Bu menuye sadece ct takimi girebilir.", iChatTag);
	
	new bestm = menu_create(fmt("%s TL Ver AL Menu", iUstTag), "tlver_");

	menu_additem(bestm, fmt("%s TL Ver", iAltTag), "1");
	menu_additem(bestm, fmt("%s TL Al", iAltTag), "2");

	bestMenuEnd(id, bestm);
}
public tlver_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			bInt[id][bTLGonder] = true;
			PlayerList(id);
		}
		case 2:{
			bInt[id][bTLGonder] = false;
			PlayerList(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public PlayerList(id){
	new bestm = menu_create(fmt("%s Oyuncu Listesi", iUstTag), "PlayerList_");

	for(new i = 1, NTS[6]; i <= MaxClients; i++){
		if(is_user_connected(i) && get_member(i, m_iTeam) == TEAM_TERRORIST){
			num_to_str(i, NTS, charsmax(NTS));
			menu_additem(bestm, fmt("%n \d[\r%d TL\d]", i, nInt[i][iTL]), NTS);
		}
	}
	bestMenuEnd(id, bestm);
}
public PlayerList_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	
	if(!is_user_alive(key) || !(get_member(key, m_iTeam) == TEAM_TERRORIST)){
		client_print_color(id, id, "%s ^3Sectiğiniz oyuncu bulunamadi.", iChatTag);
		return PLUGIN_HANDLED;
	}

	nInt[id][iSecilenOyuncu] = key;
	client_cmd(id, "MIKTAR_BELIRLE");
	
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public tlvermiktar(id){
	new arg[256], tlmiktar;
	read_args(arg, charsmax(arg));
	remove_quotes(arg);
	tlmiktar = str_to_num(arg);
	
	if(!(get_member(id, m_iTeam) == TEAM_CT)){
		return PLUGIN_HANDLED;
	}
	if(0 >= tlmiktar > cvars[MaksTLTransfer]){
		client_print_color(id, id, "%s ^3Sadece^4 0 ile %d TL^3 arasinda transfer yapabilirsiniz.", iChatTag);
		return PLUGIN_HANDLED;
	}
	if(bInt[id][bTLGonder]){
		nInt[nInt[id][iSecilenOyuncu]][iTL] += tlmiktar;
		client_print_color(0, 0, "%s^1 %n ^3isimli gardiyan^1 %n^3 isimli mahkuma^4 %d TL^3 gönderdi.", iChatTag, id, nInt[id][iSecilenOyuncu], tlmiktar);
	}
	else {
		if(tlmiktar > nInt[id][iSecilenOyuncu]){
			nInt[nInt[id][iSecilenOyuncu]][iTL] = 0;
			client_print_color(id, id, "%s^1 %n ^3isimli gardiyan^1 %n^3 isimli mahkumun butun tl'sini aldi", iChatTag, id, nInt[id][iSecilenOyuncu]);
		}
		else {
			nInt[nInt[id][iSecilenOyuncu]][iTL] -= tlmiktar;
			client_print_color(id, id, "%s^1 %n ^3isimli gardiyan^1 %n^3 isimli mahkumdan^4 %d TL^3 aldi.", iChatTag, id, nInt[id][iSecilenOyuncu], tlmiktar);
		}
	}
	return PLUGIN_HANDLED;
}

/********************* Sorgular **********************/

bool:godmode() {
	for(new i = 1; i <= MaxClients; i++){
		if(is_user_connected(i) && get_member(i, m_iTeam) == TEAM_CT){
			if(!get_entvar(i, var_takedamage)){
				return true;
			}
		}
	}
	return false;
}

/*************** Satin Alma Sistemi ***************/

public buyitem(id, item[], fiyat, deger){

	nInt[id][iEsyaFiyat] = fiyat;
	nInt[id][iEsyaDeger] = deger;

	new bestm = menu_create(fmt("%s Onay Sistemi", iUstTag), "buyitem_");

	menu_additem(bestm, "Satin Al", "1");
	menu_additem(bestm, fmt("Iptal Et^n^n\dIncelenen Urun: \w[\r%s\w]^n\dUrun Fiyati: \w[\r%d \yTL\w]", item, nInt[id][iEsyaFiyat]), "2");

	bestMenuEnd(id, bestm);
}
public buyitem_(id, menu, item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);
	switch(key){
		case 1:{
			if(nInt[id][iTL] >= nInt[id][iEsyaFiyat]){
				nInt[id][iTL] -= nInt[id][iEsyaFiyat];
				itemver(id, nInt[id][iEsyaDeger]);
			}
			else {
				client_cmd(id, "spk ^"buttons/blip2.wav^"");
				client_print_color(id, id, "%s ^3Yetersiz miktar. ^1[^4%d TL^1]", iChatTag, nInt[id][iTL]-nInt[id][iEsyaFiyat]);
				return PLUGIN_HANDLED;
			}
		}
		case 2:{
			client_print_color(id, id, "%s ^3Basarili bir sekilde isleminizi iptal ettiniz.", iChatTag);
			return PLUGIN_HANDLED;
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public itemver(id, deger){
	static name[30];
	switch(deger){
		case 1:{
			bInt[id][bBicak1] = true;
			bInt[id][bMarket]  = true;

			rg_remove_item(id, "weapon_knife");
			rg_give_item(id, "weapon_knife", GT_REPLACE);
			name = "Kelebek Bicagi";
		}
		case 2:{
			bInt[id][bBicak2] = true;
			bInt[id][bMarket]   = true;

			rg_remove_item(id, "weapon_knife");
			rg_give_item(id, "weapon_knife", GT_REPLACE);
			name = "Karambit Bicagi";
		}
		case 3:{
			bInt[id][bBicak3] = true;
			bInt[id][bMarket]   = true;

			rg_remove_item(id, "weapon_knife");
			rg_give_item(id, "weapon_knife", GT_REPLACE);
			name = "Hunstman";
		}
		case 4:{
			set_entvar(id, var_health, Float:get_entvar(id, var_health)+100.0);
			name = "100 HP";
		}
		case 5:{
			set_entvar(id, var_maxspeed, 350.0);
			name = "Hizli Yurume";
		}
		case 6:{
			set_entvar(id, var_gravity, 0.5);
			name = "Yuksek Ziplama";
		}
		case 7:{
			new Float:Origin[3];
			get_entvar(id, var_origin, Origin);
			Origin[2] += 35.0;
			set_entvar(id, var_origin, Origin);
			name = "Kendini Kaldir";
		}
		case 8:{
			arkadasinirevle(id);
			if(bInt[id][bArkadasiniRevle]){
				nInt[id][iArkadasiniRevle]++;
			}
			name = "Arkadasini Revle";
		}
		case 9:{
			remove_task(TASK_ELEKTRIKLERIKES);
			set_lights("a");
			set_task(5.0, "ElektrikleriAc", TASK_ELEKTRIKLERIKES);
			client_print_color(0, 0, "%s ^3Mahkumlardan birisi elektrikleri kesti.", iChatTag);
		}
		case 10:{
			remove_task(id + TASK_GODMODE);
			set_entvar(id, var_takedamage, DAMAGE_NO);
			set_task(3.0, "GodmodeKapat", id + TASK_GODMODE);
			name = "3 Saniye GodMode";
		}
		case 11:{
			rg_give_item(id, "weapon_flashbang");
			if(bInt[id][bFlashBombasiAl]){
				nInt[id][iFlashBombasiAl]++;
			}
			name = "1 Adet Flash Bombasi";
		}
		case 12:{
			if(rg_has_item_by_name(id, "weapon_hegrenade")){
				rg_set_user_bpammo(id, WEAPON_HEGRENADE, rg_get_user_bpammo(id, WEAPON_HEGRENADE)+2);
			}
			else {
				rg_give_item(id, "weapon_hegrenade");
				rg_set_user_bpammo(id, WEAPON_HEGRENADE, 1);
			}
			name = "2 Adet El Bombasi";
		}
		case 13:{
			rg_give_item(id, "weapon_hegrenade");
			rg_give_item(id, "weapon_flashbang");
			rg_give_item(id, "weapon_smokegrenade");
			name = "Bomba Seti";
		}
		case 14:{
			new wpn = rg_give_custom_item(id, "weapon_usp", GT_DROP_AND_REPLACE);
			rg_set_user_bpammo(id, WEAPON_USP, 0);
			set_member(wpn, m_Weapon_iClip, 12);
			name = "12 Mermili Usp";
		}
		case 15:{
			new wpn = rg_give_custom_item(id, "weapon_glock18", GT_DROP_AND_REPLACE);
			rg_set_user_bpammo(id, WEAPON_GLOCK18, 0);
			set_member(wpn, m_Weapon_iClip, 20);
			name = "20 Mermili Glock";
		}
		case 16:{
			new wpn = rg_give_custom_item(id, "weapon_awp", GT_DROP_AND_REPLACE);
			rg_set_user_bpammo(id, WEAPON_AWP, 0);
			set_member(wpn, m_Weapon_iClip, 3);
			name = "3 Mermili AWP";
		}
		case 17:{
			rg_give_shield(id);
			name = "Kalkan";
		}
		case 18:{
			for(new i = 1; i <= MaxClients; i++){
				if(is_user_connected(i) && is_user_alive(i) && get_member(i, m_iTeam) == TEAM_TERRORIST){
					set_entvar(i, var_health, Float:get_entvar(i, var_health)+75.0);
					break;
				}
			}
			name = "Mahkumlara +75 HP";
			client_print_color(0, 0, "%s^1 %n ^3isimli oyuncu savunma menuden butun mahkumlara^4 75 HP^3 verdi.", iChatTag, id);
		}
		case 19:{
			for(new i = 1; i <= MaxClients; i++){
				if(is_user_connected(i) && is_user_alive(i) && get_member(i, m_iTeam) == TEAM_TERRORIST){
					rg_give_item(i, "weapon_hegrenade");
					break;
				}
			}
			name = "Mahkumlara El Bombasi";
			client_print_color(0, 0, "%s^1 %n ^3isimli oyuncu savunma menuden butun mahkumlara^4 El Bombasi^3 verdi.", iChatTag, id);
		}
		case 20:{
			for(new i = 1; i <= MaxClients; i++){
				if(is_user_connected(i) && is_user_alive(i) && get_member(i, m_iTeam) == TEAM_TERRORIST){
					rg_give_item(i, "weapon_flashbang");
					break;
				}
			}
			name = "Mahkumlara Flash Bombasi";
			client_print_color(0, 0, "%s^1 %n ^3isimli oyuncu savunma menuden butun mahkumlara^4 Flash Bombasi^3 verdi.", iChatTag, id);
		}
		case 21:{
			for(new i = 1; i <= MaxClients; i++){
				if(is_user_connected(i) && is_user_alive(i) && get_member(i, m_iTeam) == TEAM_CT){
					new Origin[3];
					get_entvar(i, var_origin, Origin);
					Origin[2] -= 35.0;
					set_entvar(i, var_origin, Origin);
					set_task(5.0, "GardiyanlariKaldir", i + TASK_GARDIYANLARIKALDIR);
					break;
				}
			}
			if(bInt[id][bCTGom]){
				nInt[id][iCTGom]++;
			}
			name = "Gardiyanlari Gom";
			client_print_color(0, 0, "%s^1 %n ^3isimli oyuncu savunma menuden butun gardiyanlari gomdu.", iChatTag, id);
		}
	}
	client_print_color(id, id, "%s ^3Basarili bir sekilde^1 [^4%s^1] ^3satin aldiniz.", iChatTag, name);
}

/********************* Set Tasks Off *******************/

public TLHirsiziTLVer(Task){
	new id = Task - TASK_TLHIRSIZITLVER;

	if(nInt[id][iAktifMeslek] == 3){
		nInt[id][iTL] += 5;
		set_task(300.0, "TLHirsiziTLVer", id + TASK_TLHIRSIZITLVER);
	}
}
public ElektrikleriAc(){
	set_lights("#OFF");
}
public GodmodeKapat(Task){
	new id = Task - TASK_GODMODE;

	set_entvar(id, var_takedamage, DAMAGE_AIM);
	client_print_color(id, id, "%s ^3Isyan Menu'den aldigin godmode sona erdi.", iChatTag);
}
public GardiyanlariKaldir(Task){
	new id = Task - TASK_GARDIYANLARIKALDIR;

	new Origin[3];
	get_entvar(id, var_origin, Origin);
	Origin[2] += 35.0;
	set_entvar(id, var_origin, Origin);
	client_print_color(0, 0, "%s ^3Gardiyanlari gom ozelliginin suresi bitti.", iChatTag);
}
public ZamanHesapla(Task){
	new id = Task - TASK_ZAMANHESAPLA;

	nInt[id][iPlayersTime]++;
	set_task(60.0, "ZamanHesapla", id + TASK_ZAMANHESAPLA);
}

/************** Registers ***************/

public RG_CSGameRules_FlPlayerFallDamage_(id){
	if(nInt[id][iAktifMeslek] == 2){
		SetHookChainReturn(ATYPE_FLOAT, 0.0);
	}
}
public RG_CBasePlayer_Spawn_(id){
	if(!is_user_alive(id)){
		return;
	}
	switch(nInt[id][iAktifMeslek]){
		case 4:{
			rg_give_item(id, "weapon_hegrenade");
			rg_give_item(id, "weapon_smokegrenade");
			rg_give_item(id, "weapon_flashbang");
			client_print_color(id, id, "%s ^3Meslegin^4 Bombaci^3 oldugu icin^1 Bomba Seti^3 verildi.", iChatTag);
		}
		case 5:{
			set_entvar(id, var_health, Float:get_entvar(id, var_health)+150.0);
			set_entvar(id, var_armorvalue, Float:get_entvar(id, var_armorvalue)+150.0);
			client_print_color(id, id, "%s ^3Meslegin^4 Kral^3 oldugu icin^1 150 HP + 150 Armor^3 verildi.", iChatTag);
		}
	}
}
public RG_CBasePlayer_Killed_(const Victim, const Attacker){
	if(!is_user_connected(Attacker) || Victim == Attacker){
		return;
	}
	else if(!(get_member(Attacker, m_iTeam) == TEAM_TERRORIST && get_member(Victim, m_iTeam) == TEAM_CT)){
		return;
	}

	nInt[Attacker][iTL] += cvars[OldurmeBasinaTL];

	if(!bInt[Attacker][bCTOldur]){
		nInt[Attacker][iCTOldur]++;
	}
	if(nInt[Attacker][iAktifMeslek] == 1){
		nInt[Attacker][iTL] += 5;
		set_entvar(Attacker, var_health, Float:get_entvar(Attacker, var_health)+20.0);
		client_print_color(Attacker, Attacker, "%s ^3Bir ct oldurdun ve meslegin^4 Avci^3 oldugu icin^1 +5 TL +20 HP^3 kazandin.", iChatTag);
	}
}
public RG_CBasePlayerWeapon_DefaultDeploy_(const Entity, v_Model[], w_Model[], Anim, AnimExt[], skiplocal){
	if(get_member(Entity, m_iId) != WEAPON_KNIFE){
		return;
	}

	new id = get_member(Entity, m_pPlayer);
	new team = get_member(id, m_iTeam);

	switch(team){
		case TEAM_TERRORIST:{
			if(bInt[id][bBicak1]){
				SetHookChainArg(2, ATYPE_STRING, iModels[v_Bicak1]);
				SetHookChainArg(3, ATYPE_STRING, iModels[p_DefaultT]);
			}
			else if(bInt[id][bBicak2]){
				SetHookChainArg(2, ATYPE_STRING, iModels[v_Bicak2]);
				SetHookChainArg(3, ATYPE_STRING, iModels[p_DefaultT]);
			}
			else if(bInt[id][bBicak3]){
				SetHookChainArg(2, ATYPE_STRING, iModels[v_Bicak3]);
				SetHookChainArg(3, ATYPE_STRING, iModels[p_DefaultT]);
			}
			else {
				SetHookChainArg(2, ATYPE_STRING, iModels[v_DefaultT]);
				SetHookChainArg(3, ATYPE_STRING, iModels[p_DefaultT]);
			}
		}
		case TEAM_CT: {
			SetHookChainArg(2, ATYPE_STRING, iModels[v_DefaultCT]);
			SetHookChainArg(3, ATYPE_STRING, iModels[p_DefaultCT]);
		}
	}
}
public RG_CSGameRules_RestartRound_(){
	for(new id = 1; id <= MaxClients; id++){
		bInt[id][bMarket]   = false;
		bInt[id][bKanBagis] = false;
		bInt[id][bBicak1]  = false;
		bInt[id][bBicak2] = false;
		bInt[id][bBicak3] = false;
		bInt[id][bMeslekMenu] = false;
		bInt[id][bBonusMenu] = false;
	}
	remove_task(TASK_ELEKTRIKLERIKES);
}

/************** Precache ************/

public plugin_precache(){
	for(new i; i < Models; i++){
		precache_model(iModels[i]);
	}
}

/*************** Client Option *************/

public UserAccountLogin(id){
	new num = iAccountsNum(id);
	nInt[id][uid] = num;
}
public UserAccountMultiLogin(id){
	sifirla(id);
}
public UserAccountBanned(id){
	sifirla(id);
}
public client_connect(id){
	sifirla(id);
	set_task(60.0, "ZamanHesapla", id + TASK_ZAMANHESAPLA);
}
public client_disconnected(id){
	sifirla(id);
}
public sifirla(id){
	nInt[id][uid] = 0;
	nInt[id][iTL] = 0;
	nInt[id][iPlayersTime] = 0;
	nInt[id][iCTOldur] = 0;
	nInt[id][iFlashBombasiAl] = 0;
	nInt[id][iCTGom] = 0;
	nInt[id][iArkadasiniRevle] = 0;
	nInt[id][iStrAktifMeslek] = EOS;
	nInt[id][iAktifMeslek] = 0;
	bInt[id][bTLGonder] = false;
	bInt[id][bMeslekMenu] = false;
	bInt[id][bBonusMenu] = false;
	bInt[id][bArkadasiniRevle] = false;
	bInt[id][bCTGom] = false;
	bInt[id][bFlashBombasiAl] = false;
	bInt[id][bCTOldur] = false;
	bInt[id][bSunucudaOyna] = false;
	bInt[id][bBicak1]  = false;
	bInt[id][bBicak2] = false;
	bInt[id][bBicak3] = false;
	bInt[id][bMarket]   = false;
	bInt[id][bKanBagis] = false;
	remove_task(id + TASK_GODMODE);
}

/******************** Stocks *******************/

stock bestMenuEnd(id, menu){
	menu_setprop(menu, MPROP_BACKNAME,fmt("\yOnceki Sayfa"));
	menu_setprop(menu, MPROP_NEXTNAME,fmt("\ySonraki Sayfa"));
	menu_setprop(menu, MPROP_EXITNAME,fmt("\yCikis"));
	menu_setprop(menu, MPROP_NUMBER_COLOR,fmt("\r"));
	menu_display(id, menu);
}

/**********************************************/