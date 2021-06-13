#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <engine>

/***************** Kendine Göre Ayarla *************/

new const iUstTag[]  = "\rMoonGaming\d - ";
new const iAltTag[]  = "\wMoonGaming\d -\y ";
new const iChatTag[] = "^1[^4MoonGaming^1]";

new const KUTU_SES[] = "hjbmenu_kutusesi.wav";

#define FacebookAdresi  "MoonGaming"
#define SunucuAdresi    "213.238.173.56"
#define Ts3Adresi       "ts3moon"

#define VIP_YETKI      ADMIN_BAN
#define ADMINS_YETKI   ADMIN_MAP
#define KOMUTCU_YETKI  ADMIN_KICK
#define SLOT_YETKI     ADMIN_RESERVATION

/***************************************************/

enum (+= 1453) {
	TASK_ELEKTRIKLERIKES = 1453,
	TASK_GODMODE,
	TASK_GARDIYANLARIKALDIR,
	TASK_ZAMANHESAPLA,
	TASK_TLHIRSIZITLVER,
	TASK_KASA
}
enum _: intDeger {
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
	iSecilenOyuncu,
	g_iKey
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
	GorevMenuSunucudaOyna,
	GorevMenuCTOldur,
	GorevMenuFlashBombasiAl,
	GorevMenuCTGom,
	GorevMenuArkadasiniRevle,
	OldurmeBasinaTL,
	MaksTLTransfer
};
new cvars[intCvars];

new hudsync[3];

public plugin_init(){
	register_plugin("[REAPI] Gelismis Hesap Sistemli JBMenu","1.0","` BesTCore;");

	register_clcmd("say /asd", "asd");
	register_clcmd("say /jbmenu", "jbmenu");
	register_clcmd("nightvision", "jbmenu");
	register_clcmd("say /mg", "tlver");

	register_clcmd("MIKTAR_BELIRLE", "tlvermiktar");

	for(new i = 0; i < 3; i++) {
		hudsync[i] = CreateHudSyncObj();
	}

	//RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "RG_CBasePlayerWeapon_DefaultDeploy_", .post = false);
	RegisterHookChain(RG_CSGameRules_RestartRound, "RG_CSGameRules_RestartRound_", .post = false);
	RegisterHookChain(RG_CBasePlayer_Killed, "RG_CBasePlayer_Killed_", .post = true);
	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer_Spawn_", .post = true);
	RegisterHookChain(RG_CSGameRules_FlPlayerFallDamage, "RG_CSGameRules_FlPlayerFallDamage_", .post = true);

	/*********************** JBMenu Market Menu Cvars *************************/
	bind_pcvar_num(create_cvar("MarketMenu_Bicak1", "-2"), cvars[MarketBicak1]);
	bind_pcvar_num(create_cvar("MarketMenu_Bicak2", "10"), cvars[MarketBicak2]);
	bind_pcvar_num(create_cvar("MarketMenu_Bicak3", "20"), cvars[MarketBicak3]);
	bind_pcvar_num(create_cvar("MarketMenu_KanBagis", "10"), cvars[MarketKanBagis]);
	/*********************** JBMenu Isyan Menu Cvars *************************/
	bind_pcvar_num(create_cvar("IsyanMenu_100HP", "10"), cvars[IsyanMenu100HP]);
	bind_pcvar_num(create_cvar("IsyanMenu_HizliYurume", "25"), cvars[IsyanMenuHizliYurume]);
	bind_pcvar_num(create_cvar("IsyanMenu_YuksekZiplama", "15"), cvars[IsyanMenuYuksekZiplama]);
	bind_pcvar_num(create_cvar("IsyanMenu_ArkadasiniRevle", "120"), cvars[IsyanMenuArkadasiniRevle]);
	bind_pcvar_num(create_cvar("IsyanMenu_ElektrikleriKes", "100"), cvars[IsyanMenuElektrikleriKes]);
	bind_pcvar_num(create_cvar("IsyanMenu_Godmode", "100"), cvars[IsyanMenuGodMode]);
	/*********************** JBMenu Cephane Menu Cvars *************************/
	bind_pcvar_num(create_cvar("CephaneMenu_1AdetFlashBombasi", "15"), cvars[CephaneMenuFlashBombasi]);
	bind_pcvar_num(create_cvar("CephaneMenu_2AdetElBombasi", "30"), cvars[CephaneMenuElBombasi]);
	bind_pcvar_num(create_cvar("CephaneMenu_BombaSeti", "35"), cvars[CephaneMenuBombaSeti]);
	bind_pcvar_num(create_cvar("CephaneMenu_USP", "65"), cvars[CephaneMenuUsp]);
	bind_pcvar_num(create_cvar("CephaneMenu_Glock", "65"), cvars[CephaneMenuGlock]);
	bind_pcvar_num(create_cvar("CephaneMenu_AWP", "65"), cvars[CephaneMenuAWP]);
	bind_pcvar_num(create_cvar("CephaneMenu_Kalkan", "65"), cvars[CephaneMenuKalkan]);
	/*********************** JBMenu Savunma Menu Cvars *************************/
	bind_pcvar_num(create_cvar("SavunmaMenu_MahkumlaraHPVer", "10"), cvars[SavunmaMenuMahkumHPVer]);
	bind_pcvar_num(create_cvar("SavunmaMenu_MahkumlaraElBombasiVer", "10"), cvars[SavunmaMenuMahkumElBombasiVer]);
	bind_pcvar_num(create_cvar("SavunmaMenu_MahkumlaraFlashBombasiVer", "10"), cvars[SavunmaMenuMahkumFlashBombasiVer]);
	/*********************** JBMenu Gorev Menu Cvars *************************/
	bind_pcvar_num(create_cvar("GorevMenu_SunucudaTakilOdul", "10"), cvars[GorevMenuSunucudaOyna]);
	bind_pcvar_num(create_cvar("GorevMenu_CTOldurOdul", "10"), cvars[GorevMenuCTOldur]);
	bind_pcvar_num(create_cvar("GorevMenu_FlashBombasiAlOdul", "10"), cvars[GorevMenuFlashBombasiAl]);
	bind_pcvar_num(create_cvar("GorevMenu_CTGomOdul", "10"), cvars[GorevMenuCTGom]);
	bind_pcvar_num(create_cvar("GorevMenu_ArkadasiniRevleOdul", "10"), cvars[GorevMenuArkadasiniRevle]);
	/*********************** JBMenu Extra Cvars *************************/
	bind_pcvar_num(create_cvar("OldurmeBasinaTL", "3"), cvars[OldurmeBasinaTL]);
	bind_pcvar_num(create_cvar("MaksimumTLTransfer", "150"), cvars[MaksTLTransfer]);
}
public asd(id){
	nInt[id][iTL] += 24924;
}
public jbmenu(id){
	if(get_member(id, m_iTeam) == TEAM_TERRORIST && PlayerCanUse(id, true, true)){
		new bestm = menu_create(fmt("%s Jailbreak Menu^n\dMevcut TL:\y %d TL", iUstTag, nInt[id][iTL]), "jbmenu_");

		menu_additem(bestm, fmt("%s Market Menu %s", iAltTag, bInt[id][bMarket] ? "\d[\rKullandiniz\d]":""));
		menu_additem(bestm, fmt("%s %sAlisveris Menu", iAltTag, godmode() ? "\d":"\y"));
		menu_additem(bestm, fmt("%s Gorev Menu", iAltTag));
		menu_additem(bestm, fmt("%s Bonus Menu", iAltTag));
		menu_additem(bestm, fmt("%s Meslek Menu", iAltTag));
		menu_additem(bestm, fmt("%s Kasa Menu", iAltTag));
		menu_additem(bestm, fmt("%s Bilgi & Detay Menu", iAltTag));

		bestMenuEnd(id, bestm);
	}
	return PLUGIN_HANDLED;
}
public jbmenu_(id, menu, item){
	if(!PlayerCanUse(id, true, true)){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			if(bInt[id][bMarket]){
				client_print_color(id, id, "%s ^3Market menuyu her el bir kere kullanabilirsin.", iChatTag);
				jbmenu(id);
			}
			else {
				marketmenu(id);
			}
		}
		case 1:{
			alisverismenu(id);
		}
		case 2:{
			gorevmenu(id);
		}
		case 3:{
			if(!bInt[id][bBonusMenu]){
				bonusmenu(id);
			}
			else {
				client_print_color(id, id, "%s ^3Bonus menuyu her elde bir kere kullanabilirsin.", iChatTag);
				jbmenu(id);
			}
		}
		case 4:{
			meslekmenu(id);
		}
		case 5:{
			kasamenu(id);
		}
		case 6:{
			bilgidetaymenu(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public bilgidetaymenu(id){
	new bestm = menu_create(fmt("%s Bilgi & Detay Menu", iUstTag), "bilgidetaymenu_");

	new szMapName[50];
	get_mapname(szMapName, charsmax(szMapName));

	menu_additem(bestm, fmt("Map Ismini Ogren \d[\r%s\d]", szMapName));
	menu_additem(bestm, fmt("Facebook \d[\r%s\d]", FacebookAdresi));
	menu_additem(bestm, fmt("Sunucu Adresi \d[\r%s\d]", SunucuAdresi));
	menu_additem(bestm, fmt("TeamSpeak 3 Adresi \d[\r%s\d]", Ts3Adresi));

	bestMenuEnd(id, bestm);
}
public bilgidetaymenu_(id, menu, item){
	switch(item){
		case 0..3:{
			bilgidetaymenu(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
enum _:KasaIcerigi {
	kSiyah,
	kBeyaz,
	kKirmizi,
	kSari,
	kMavi,
	kYesil,
	kMor
}
new const g_szKasaIcerigi[KasaIcerigi][] = {
	"Siyah Item",
	"Beyaz Item",
	"Kirmizi Item",
	"Sari Item",
	"Mavi Item",
	"Yesil Item",
	"Mor Item"
};
new g_szPre[MAX_CLIENTS+1][30],
	g_szPresent[MAX_CLIENTS+1][30],
	g_szPost[MAX_CLIENTS+1][30],
	g_iPreColor[MAX_CLIENTS+1][3],
	g_iPresentColor[MAX_CLIENTS+1][3],
	g_iPostColor[MAX_CLIENTS+1][3];

public kasamenu(id){
	if(!PlayerCanUse(id, true, true)){
		return;
	}
	new bestm = menu_create(fmt("%s Kasa Menu", iUstTag), "kasamenu_");

	menu_additem(bestm, "Kasa Ac^n");
	
	menu_additem(bestm, "Kasa Anahtari \d[\r15\y TL\d]");
	menu_addtext(bestm, fmt("Mevcut Anahtar:\r %d\y Adet", nInt[id][g_iKey]));

	bestMenuEnd(id, bestm);
}
public kasamenu_(id, menu, item){
	if(!PlayerCanUse(id, true, true)){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			if(!(nInt[id][g_iKey] >= 1)){
				client_print_color(id, id, "%s ^3Kasa acmak icin anahtariniz eksik^1,^4Mevcut Anahtar:^3 %d Adet", iChatTag, nInt[id][g_iKey]);
				return PLUGIN_HANDLED;
			}
			if(task_exists(id + TASK_KASA)) {
				client_print_color(id, id, "%s ^3Zaten suanda kasa aciyorsunuz.", iChatTag);
			}
			else {
				KasaAc(id);
				nInt[id][g_iKey]--;
			}
		}
		case 1:{
			buyitem(id, "Kasa Anahtari", 15, 21);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public KasaAc(id){
	g_szPre[id][0] = EOS;
	g_szPresent[id][0] = EOS;
	g_szPost[id][0] = EOS;

	for(new i = 0; i < 3; i++){
		g_iPreColor[id][i] = 255;
		g_iPresentColor[id][i] = 255;
		g_iPostColor[id][i] = 255;
	}
	set_task(0.1, "HudAktifEt", id + TASK_KASA, .flags = "b");
}
public HudAktifEt(Task){
	static id;
	id = Task - TASK_KASA;

	copy(g_szPost[id], charsmax(g_szPost[]), g_szPresent[id]);
	copy(g_szPresent[id], charsmax(g_szPresent[]), g_szPre[id]);

	ColorOptions(id, g_szKasaIcerigi[random_num(kSiyah, kMor)], 0, 0, 255);

	set_hudmessage(g_iPreColor[id][0], g_iPreColor[id][1], g_iPreColor[id][2], 0.45, 0.55, 0, _, 1.0, 0.1, 0.1);
	ShowSyncHudMsg(id, hudsync[0], " %s", g_szPre[id]);

	set_dhudmessage(g_iPresentColor[id][0], g_iPresentColor[id][1], g_iPresentColor[id][2], 0.43, 0.55, 0, _, 1.0, 0.1, 0.1);
	ShowSyncHudMsg(id, hudsync[1], "^n->   %s", g_szPresent[id]);

	set_hudmessage(g_iPostColor[id][0], g_iPostColor[id][1], g_iPostColor[id][2], 0.45, 0.55, 0, _, 1.0, 0.1, 0.1);
	ShowSyncHudMsg(id, hudsync[2], "^n^n %s", g_szPost[id]);

	for(new i = 0; i < 3; i++) {
		g_iPostColor[id][i] = g_iPresentColor[id][i];
		g_iPresentColor[id][i] = g_iPreColor[id][i];
	}

	static g_intsayac[MAX_CLIENTS+1];
	g_intsayac[id]++;

	switch(g_intsayac[id]) {
		case 25: {
			change_task(id + TASK_KASA, 0.5);
		}
		case 40:{
			change_task(id + TASK_KASA, 0.7);
		}
		case 47:{
			change_task(id + TASK_KASA, 1.0);
		}
		case 50: {
			for(new i = 0; i < KasaIcerigi; i++) {
				if(equali(g_szPresent[id], g_szKasaIcerigi[i])) {
					HediyesiniVer(id, i);
					break;
				}
			}
		}
		case 51:{
			g_intsayac[id] = 0;
			remove_task(id + TASK_KASA);
			ClearKasaHuds(id);
			return;
		}
	}
	rg_send_audio(id, KUTU_SES);
}
public HediyesiniVer(const id, const iIcerik){
	client_print_color(0, 0, "^1%n^3 adli oyuncu kasadan^4 %s^3 cikardi.", id, g_szKasaIcerigi[iIcerik]);
	switch(iIcerik){
		case kSiyah:{
			// Verilecek Itemler.
		}
		case kBeyaz:{
			// Verilecek Itemler.
		}
		case kKirmizi:{
			// Verilecek Itemler.
		}
		case kSari:{
			// Verilecek Itemler.
		}
		case kMavi:{
			// Verilecek Itemler.
		}
		case kYesil:{
			// Verilecek Itemler.
		}
		case kMor:{
			// Verilecek Itemler.
		}
	}
}
public ColorOptions(const id, const szItem[], const iRed, const iGreen, const iBlue){
	formatex(g_szPre[id], charsmax(g_szPre[]), szItem);

	g_iPreColor[id][0] = iRed;
	g_iPreColor[id][1] = iGreen;
	g_iPreColor[id][2] = iBlue;
}
public ClearKasaHuds(id){
	for(new i = 0; i < 3; i++){
		ClearSyncHud(id, hudsync[i]);
	}
}
public meslekmenu(id){
	new bestm = menu_create(fmt("%s Meslek Menu", iUstTag), "meslekmenu_");

	menu_additem(bestm, "\yAvci  \w- \d(Her CT Oldurdugunde +5 TL ve +20 HP)");
	menu_additem(bestm, "\yAstronot \w- \d(Yere Dusunce Can Gitmez)");
	menu_additem(bestm, "\yTL Hirsizi \w- \d(Her 5 Dakikada Bir 5 TL)");
	menu_additem(bestm, "\yBombaci \w- \d(Her El Bomba Seti)");
	menu_additem(bestm, "\yTerminatör \w- \d(Her El 150 HP + 150 Armor)");

	bestMenuEnd(id, bestm);
}
public meslekmenu_(id, menu, item){
	if(!PlayerCanUse(id, true, true)){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	if(bInt[id][bMeslekMenu]){
		client_print_color(id, id, "%s ^3Her el bir kere meslek degistirebilirsin.", iChatTag);
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
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
		case 1:{
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
		case 2:{
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
		case 3:{
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
		case 4:{
			if(nInt[id][iAktifMeslek] == 5){
				client_print_color(id, id, "%s ^3Sen zaten^4 Terminatör^3 meslegini kullaniyorsun.", iChatTag);
				return PLUGIN_HANDLED;
			}
			else {
				nInt[id][iStrAktifMeslek] = "Aktif Meslegin: Terminator";
				nInt[id][iAktifMeslek] = 5;
				bInt[id][bMeslekMenu] = true;
				client_print_color(id, id, "%s ^3Basarili bir sekilde meslegin^4 Terminatör^3 olarak secildi.", iChatTag);
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
		menu_additem(bestm, "+15 TL");
		menu_additem(bestm, "+50 Can");
		menu_additem(bestm, "Yuksek Ziplama");
		menu_additem(bestm, "Hizli Yurume");
	}
	else if(flags & ADMINS_YETKI) {
		menu_additem(bestm, "+12 TL");
		menu_additem(bestm, "+30 Can");
		menu_additem(bestm, "Yusek Ziplama");
		menu_additem(bestm, "Hizli Yurume");
	}
	else if(flags & KOMUTCU_YETKI) {
		menu_additem(bestm, "+10 TL");
		menu_additem(bestm, "+20 Can");
		menu_additem(bestm, "Yuksek Ziplama");
	}
	else if(flags & SLOT_YETKI) {
		menu_additem(bestm, "+7 TL");
		menu_additem(bestm, "+10 Can");
		menu_additem(bestm, "Yuksek Ziplama");
	}
	else {
		menu_additem(bestm, "+2 TL");
		menu_additem(bestm, "+5 Can");
	}

	bestMenuEnd(id, bestm);
}
public bonusmenu_(id, menu, item){
	if(!PlayerCanUse(id, true, true)){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new flags = get_user_flags(id);
	switch(item){
		case 0:{
			if(flags & VIP_YETKI) nInt[id][iTL] += 15;
				else if(flags & ADMINS_YETKI) nInt[id][iTL] += 12;
					else if(flags & KOMUTCU_YETKI) nInt[id][iTL] += 10;
						else if(flags & SLOT_YETKI) nInt[id][iTL] += 7;
							else nInt[id][iTL] += 2;
			bInt[id][bBonusMenu] = true;
			jbmenu(id);
		}
		case 1:{
			if(flags & VIP_YETKI) set_entvar(id, var_health, Float:get_entvar(id, var_health)+50.0);
				else if(flags & ADMINS_YETKI) set_entvar(id, var_health, Float:get_entvar(id, var_health)+30.0);
					else if(flags & KOMUTCU_YETKI) set_entvar(id, var_health, Float:get_entvar(id, var_health)+20.0);
						else if(flags & SLOT_YETKI) set_entvar(id, var_health, Float:get_entvar(id, var_health)+10.0);
							else set_entvar(id, var_health, Float:get_entvar(id, var_health)+5.0);
			bInt[id][bBonusMenu] = true;
			jbmenu(id);
		}
		case 2:{
			if(flags & VIP_YETKI) set_entvar(id, var_gravity, 0.4);
				else if(flags & ADMINS_YETKI) set_entvar(id, var_gravity, 0.5);
					else if(flags & KOMUTCU_YETKI) set_entvar(id, var_gravity, 0.6);
						else if(flags & SLOT_YETKI) set_entvar(id, var_gravity, 0.6);
			bInt[id][bBonusMenu] = true;
			jbmenu(id);
		}
		case 3:{
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

	bestMenuEnd(id, bestm);
}
public marketmenu_(id, menu, item){
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public gorevmenu(id){
	new bestm = menu_create(fmt("%s Gorev Menu", iUstTag), "gorevmenu_");

	if(bInt[id][bSunucudaOyna]) menu_additem(bestm, fmt("20 Dakika Sunucuda Oyna \d[\rTamamlandi\d] \d[\r%i \yTL\d]", cvars[GorevMenuSunucudaOyna]));
	else if (nInt[id][iPlayersTime] >= 20) menu_additem(bestm, fmt("20 Dakika Sunucuda Oyna \d[\rTikla Parani Al\d] \d[\r%i \yTL\d]", cvars[GorevMenuSunucudaOyna]));
	else if (!bInt[id][bSunucudaOyna]) menu_additem(bestm, fmt("20 Dakika Sunucuda Oyna \d[\w%d\d/\r20\d] \d[\r%i \yTL\d]", nInt[id][iPlayersTime], cvars[GorevMenuSunucudaOyna]));

	if(bInt[id][bCTOldur]) menu_additem(bestm, fmt("CT Oldur \d[\rTamamlandi\d] \d[\r%i \yTL\d]", cvars[GorevMenuCTOldur]));
	else if (nInt[id][iCTOldur] >= 10) menu_additem(bestm, fmt("CT Oldur \d[\rTikla Parani Al\d] \d[\r%i \yTL\d]", cvars[GorevMenuCTOldur]));
	else if (!bInt[id][bCTOldur]) menu_additem(bestm, fmt("CT Oldur \d[\w%d\d/\r10\d] \d[\r%i \yTL\d]", nInt[id][iCTOldur], cvars[GorevMenuCTOldur]));

	if(bInt[id][bFlashBombasiAl]) menu_additem(bestm, fmt("Flash Bombasi Al \d[\rTamamlandi\d] \d[\r%i \yTL\d]", cvars[GorevMenuFlashBombasiAl]));
	else if (nInt[id][iFlashBombasiAl] >= 5) menu_additem(bestm, fmt("Flash Bombasi Al \d[\rTikla Parani Al\d] \d[\r%i \yTL\d]", cvars[GorevMenuFlashBombasiAl]));
	else if (!bInt[id][bFlashBombasiAl]) menu_additem(bestm, fmt("Flash Bombasi Al \d[\w%d\d/\r5\d] \d[\r%i \yTL\d]", nInt[id][iFlashBombasiAl], cvars[GorevMenuFlashBombasiAl]));

	if(bInt[id][bCTGom]) menu_additem(bestm, fmt("CTleri Gom \d[\rTamamlandi\d] \d[\r%i \yTL\d]", cvars[GorevMenuCTGom]));
	else if (nInt[id][iCTGom] >= 2) menu_additem(bestm, fmt("CTleri Gom \d[\rTikla Parani Al\d] \d[\r%i \yTL\d]", cvars[GorevMenuCTGom]));
	else if (!bInt[id][bCTGom]) menu_additem(bestm, fmt("CTleri Gom \d[\w%d\d/\r2\d] \d[\r%i \yTL\d]", nInt[id][iCTGom], cvars[GorevMenuCTGom]));

	if(bInt[id][bArkadasiniRevle]) menu_additem(bestm, fmt("Arkadasini Revle \d[\rTamamlandi\d] \d[\r%i \yTL\d]", cvars[GorevMenuArkadasiniRevle]));
	else if (nInt[id][iArkadasiniRevle] >= 2) menu_additem(bestm, fmt("Arkadasini Revle \d[\rTikla Parani Al\d] \d[\r%i \yTL\d]", cvars[GorevMenuArkadasiniRevle]));
	else if (!bInt[id][bArkadasiniRevle]) menu_additem(bestm, fmt("Arkadasini Revle \d[\w%d\d/\r4\d] \d[\r%i \yTL\d]", nInt[id][iArkadasiniRevle], cvars[GorevMenuArkadasiniRevle]));

	bestMenuEnd(id, bestm);
}
public gorevmenu_(id, menu, item){
	if(!PlayerCanUse(id, true, true)){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
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
		case 1:{
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
		case 2:{
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
		case 3:{
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
		case 4:{
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

	menu_additem(bestm, fmt("%s Isyan Menu", iAltTag));
	menu_additem(bestm, fmt("%s Cephane Menu", iAltTag));
	menu_additem(bestm, fmt("%s Savunma Menu", iAltTag));

	bestMenuEnd(id, bestm);
}
public alisverismenu_(id, menu, item){
	if(!PlayerCanUse(id, true, true)){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			isyanmenu(id);
		}
		case 1:{
			cephanemenu(id);
		}
		case 2:{
			savunmamenu(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public savunmamenu(id){
	new bestm = menu_create(fmt("%s Savunma Menu", iUstTag), "savunmamenu_");

	menu_additem(bestm, fmt("Mahkumlara +35 HP Ver \d[\r%i \yTL\d]", cvars[SavunmaMenuMahkumHPVer]));
	menu_additem(bestm, fmt("Mahkumlara El Bombasi Ver \d[\r%i \yTL\d]", cvars[SavunmaMenuMahkumElBombasiVer]));
	menu_additem(bestm, fmt("Mahkumlara Flash Bombasi Ver \d[\r%i \yTL\d]", cvars[SavunmaMenuMahkumFlashBombasiVer]));

	bestMenuEnd(id, bestm);
}
public savunmamenu_(id, menu, item){
	if(!PlayerCanUse(id, true, true)){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			buyitem(id, "Mahkumlara +35 HP Ver", cvars[SavunmaMenuMahkumHPVer], 18);
		}
		case 1:{
			buyitem(id, "Mahkumlara El Bombasi Ver", cvars[SavunmaMenuMahkumElBombasiVer], 19);
		}
		case 2:{
			buyitem(id, "Mahkumlara Flash Bombasi Ver", cvars[SavunmaMenuMahkumFlashBombasiVer], 20);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public cephanemenu(id){
	new bestm = menu_create(fmt("%s Cephane Menu", iUstTag), "cephanemenu_");

	menu_additem(bestm, fmt("1 Adet Flash Bombasi \d[\r%i \yTL\d]", cvars[CephaneMenuFlashBombasi]));
	menu_additem(bestm, fmt("2 Adet El Bombasi \d[\r%i \yTL\d]", cvars[CephaneMenuElBombasi]));
	menu_additem(bestm, fmt("Bomba Seti \d[\r%i \yTL\d]", cvars[CephaneMenuBombaSeti]));
	menu_additem(bestm, fmt("12 Mermili Usp \d[\r%i \yTL\d]", cvars[CephaneMenuUsp]));
	menu_additem(bestm, fmt("20 Mermili Glock \d[\r%i \yTL\d]", cvars[CephaneMenuGlock]));
	menu_additem(bestm, fmt("3 Mermili AWP \d[\r%i \yTL\d]", cvars[CephaneMenuAWP]));
	menu_additem(bestm, fmt("Kalkan \d[\r%i \yTL\d]", cvars[CephaneMenuKalkan]));

	bestMenuEnd(id, bestm);
}
public cephanemenu_(id, menu, item){
	if(!PlayerCanUse(id, true, true)){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			buyitem(id, "1 Adet Flash Bombasi", cvars[CephaneMenuFlashBombasi], 11);
		}
		case 1:{
			buyitem(id, "2 Adet El Bombasi", cvars[CephaneMenuElBombasi], 12);
		}
		case 2:{
			buyitem(id, "Bomba Seti", cvars[CephaneMenuBombaSeti], 13);
		}
		case 3:{
			buyitem(id, "12 Mermili Usp", cvars[CephaneMenuUsp], 14);
		}
		case 4:{
			buyitem(id, "20 Mermili Glock", cvars[CephaneMenuGlock], 15);
		}
		case 5:{
			buyitem(id, "3 Mermili AWP", cvars[CephaneMenuAWP], 16);
		}
		case 6:{
			buyitem(id, "Kalkan", cvars[CephaneMenuKalkan], 17);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public isyanmenu(id){
	new bestm = menu_create(fmt("%s Isyan Menu", iUstTag), "isyanmenu_");

	menu_additem(bestm, fmt("100 HP \d[\r%i \yTL\d]", cvars[IsyanMenu100HP]));
	menu_additem(bestm, fmt("Hizli Yurume \d[\r%i \yTL\d]", cvars[IsyanMenuHizliYurume]));
	menu_additem(bestm, fmt("Yuksek Ziplama \d[\r%i \yTL\d]", cvars[IsyanMenuYuksekZiplama]));
	menu_additem(bestm, fmt("Arkadasini Revle \d[\r%i \yTL\d]", cvars[IsyanMenuArkadasiniRevle]));
	menu_additem(bestm, fmt("Elektrikleri Kes \d[\r%i \yTL\d] \d(\r5 \ySaniye\d)", cvars[IsyanMenuElektrikleriKes]));
	menu_additem(bestm, fmt("GodMode \d[\r%i \yTL\d] \d(\r3 \ySaniye\d)", cvars[IsyanMenuGodMode]));

	bestMenuEnd(id, bestm);
}
public isyanmenu_(id, menu, item){
	if(!PlayerCanUse(id, true, true)){
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	switch(item){
		case 0:{
			buyitem(id, "100 HP", cvars[IsyanMenu100HP], 4);
		}
		case 1:{
			buyitem(id, "Hizli Yurume", cvars[IsyanMenuHizliYurume], 5);
		}
		case 2:{
			buyitem(id, "Yuksek Ziplama", cvars[IsyanMenuYuksekZiplama], 6);
		}
		case 3:{
			buyitem(id, "Arkadasini Revle", cvars[IsyanMenuArkadasiniRevle], 8);
		}
		case 4:{
			buyitem(id, "Elektrikleri Kes", cvars[IsyanMenuElektrikleriKes], 9);
		}
		case 5:{
			buyitem(id, "3 Saniye GodMode", cvars[IsyanMenuGodMode], 10);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public arkadasinirevle(id){
	new bestm = menu_create(fmt("%s Arkadasini Revle", iUstTag), "arkadasinirevle_");

	for(new i = 1; i <= MaxClients; i++){
		if(is_user_connected(i) && get_member(i, m_iTeam) == TEAM_TERRORIST && !is_user_alive(i)){
			menu_additem(bestm, fmt("%n", i), fmt("%i", i));
		}
	}
	bestMenuEnd(id, bestm);
	return PLUGIN_HANDLED;
}
public arkadasinirevle_(id, menu, item){
	if(!PlayerCanUse(id, true, true)){
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

	menu_additem(bestm, fmt("%s TL Ver", iAltTag));
	menu_additem(bestm, fmt("%s TL Al", iAltTag));

	bestMenuEnd(id, bestm);
}
public tlver_(id, menu, item){
	switch(item){
		case 0:{
			bInt[id][bTLGonder] = true;
			PlayerList(id);
		}
		case 1:{
			bInt[id][bTLGonder] = false;
			PlayerList(id);
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public PlayerList(id){
	new bestm = menu_create(fmt("%s Oyuncu Listesi", iUstTag), "PlayerList_");

	for(new i = 1; i <= MaxClients; i++){
		if(is_user_connected(i) && get_member(i, m_iTeam) == TEAM_TERRORIST){
			menu_additem(bestm, fmt("%n \d[\r%d TL\d]", i, nInt[i][iTL]), fmt("%i", i));
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
bool:PlayerCanUse(const id, const bool:bAlive, const bool:bLastPlayer) {
	if(bAlive && !is_user_alive(id)) {
		client_print_color(id, id, "%s ^3Oluyken bu islemi yapamazsin!", iChatTag);
		return false;
	}
	if(bLastPlayer) {
		new iLastPlayer;
		rg_initialize_player_counts(iLastPlayer);

		if(iLastPlayer <= 1){
			client_print_color(id, id, "%s ^3Sona kaldigin icin bu islemi yapamazsin!", iChatTag);
			return false;
		}
	}
	return true;
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
			name = "Bayonet";
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
					set_entvar(i, var_health, Float:get_entvar(i, var_health)+35.0);
					break;
				}
			}
			name = "Mahkumlara +35 HP";
			client_print_color(0, 0, "%s^1 %n ^3isimli oyuncu savunma menuden butun mahkumlara^4 35 HP^3 verdi.", iChatTag, id);
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
			name = "Kasa Anahtari";
			nInt[id][g_iKey]++;
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
			client_print_color(id, id, "%s ^3Meslegin^4 Terminatör^3 oldugu icin^1 150 HP + 150 Armor^3 verildi.", iChatTag);
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
/*public RG_CBasePlayerWeapon_DefaultDeploy_(const Entity, v_Model[], w_Model[], Anim, AnimExt[], skiplocal){
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
}*/
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
	precache_sound(KUTU_SES);
}
public client_disconnected(id){
	remove_task(id);
	ClearKasaHuds(id);
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