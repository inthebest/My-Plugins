#pragma semicolon 1

#include <amxmodx>
#include <reapi>

#define ADMIN_DIA  ADMIN_BAN  // Belirlediğiniz yetkiye sahip kullanıcılara ürünlerde 2, 5 tl indirim sağlar.

new const iUstTag[]  = "\rforum.csd\d -";
new const iChatTag[] = "^4forum.csd :";

enum (+= 1337){
	TASK_GODMODE = 1337,
	TASK_GIVEHEGRENADE,
	TASK_GIVEHEALTH,
	TASK_UNLIMITEDAMMO,
	TASK_INVISIBLE
}

enum _:intenum {
	iTL,
	iHeLimited,
	iHealthLimited
};
new g_int[intenum][MAX_PLAYERS+1];

enum _:cvarenum {
	cvKillTL,
	cvHealth,
	cvArmor,
	cvFastWalking,
	cvResetHPArmor,
	cvFootsteps,
	cvGodmode,
	cvKillHP,
	cv2xTL,
	cvSecondHegrenade,
	cvSecondHealth,
	cvHighJump,
	cvInVisibility,
	cvBeAnEnemy,
	cvUnlimitedAmmo
};
new g_cvars[cvarenum];

new bool:g_blOneUse[MAX_PLAYERS+1][14];

public plugin_init(){
	register_plugin("[REAPI] DeathMatch Shop", "0.1", "` BesTCore;");

	register_dictionary("reDMShop.txt");

	register_clcmd("say /dmmarket", "clcmd_dmshop");
	register_clcmd("nightvision", "clcmd_dmshop");

	RegisterHookChain(RG_CBasePlayer_Killed, "RG_CBasePlayer_Killed_Post", .post = true);
	RegisterHookChain(RG_CBasePlayer_Spawn, "RG_CBasePlayer_Spawn_Post", .post = true);
	RegisterHookChain(RG_CBasePlayer_ResetMaxSpeed, "RG_CBasePlayer_ResetMaxSpeed_Pre", .post = false);
	register_event("CurWeapon", "CurWeapon_", "be", "1=1", "3=1");

	bind_pcvar_num(create_cvar("KillBasinaTL", "5"), g_cvars[cvKillTL]);

	bind_pcvar_num(create_cvar("150HP_Fiyat", "10"), g_cvars[cvHealth]);
	bind_pcvar_num(create_cvar("150Armor_Fiyat", "8"), g_cvars[cvArmor]);
	bind_pcvar_num(create_cvar("HizliYurume_Fiyat", "12"), g_cvars[cvFastWalking]);
	bind_pcvar_num(create_cvar("HPveZirhYenileme_Fiyat", "5"), g_cvars[cvResetHPArmor]);
	bind_pcvar_num(create_cvar("SessizYurume_Fiyat", "6"), g_cvars[cvFootsteps]);
	bind_pcvar_num(create_cvar("GodMode_Fiyat", "25"), g_cvars[cvGodmode]);
	bind_pcvar_num(create_cvar("KillBasinaHP_Fiyat", "12"), g_cvars[cvKillHP]);
	bind_pcvar_num(create_cvar("2KatTL_Fiyat", "22"), g_cvars[cv2xTL]);
	bind_pcvar_num(create_cvar("1DakikaBomba_Fiyat", "12"), g_cvars[cvSecondHegrenade]);
	bind_pcvar_num(create_cvar("1DakikaCan_Fiyat", "11"), g_cvars[cvSecondHealth]);
	bind_pcvar_num(create_cvar("YuksekZiplama_Fiyat", "8"), g_cvars[cvHighJump]);
	bind_pcvar_num(create_cvar("Gorunmezlik_Fiyat", "23"), g_cvars[cvInVisibility]);
	bind_pcvar_num(create_cvar("DusmanKiliginaBurun_Fiyat", "24"), g_cvars[cvBeAnEnemy]);
	bind_pcvar_num(create_cvar("SinirsizMermi_Fiyat", "32"), g_cvars[cvUnlimitedAmmo]);
}
public clcmd_dmshop(const id){
	new bestm = menu_create(fmt("%s DeathMatch Market^nDurum: %s^n\dUzerinizdeki Miktar:\r %d TL", iUstTag, get_user_flags(id) & ADMIN_DIA ? "\rDiamond Uye":"\wNormal Uye", g_int[iTL][id]), "clcmd_dmshop_");

	menu_additem(bestm, fmt("%s150 HP \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvHealth]), 0) ? "":"\d", IsThePlayerDia(id, g_cvars[cvHealth])));
	menu_additem(bestm, fmt("%s150 Armor \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvArmor]), 1) ? "":"\d", IsThePlayerDia(id, g_cvars[cvArmor])));
	menu_additem(bestm, fmt("%sHizli Yurume \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvFastWalking]), 2) ? "":"\d", IsThePlayerDia(id, g_cvars[cvFastWalking])));
	menu_additem(bestm, fmt("%sCan ve Zirh Yenile \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvResetHPArmor]), 3) ? "":"\d", IsThePlayerDia(id, g_cvars[cvResetHPArmor])));
	menu_additem(bestm, fmt("%sSessiz Yurume \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvFootsteps]), 4) ? "":"\d", IsThePlayerDia(id, g_cvars[cvFootsteps])));
	menu_additem(bestm, fmt("%sGodMode\d(10 Saniye) \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvGodmode]), 5) ? "":"\d", IsThePlayerDia(id, g_cvars[cvGodmode])));
	menu_additem(bestm, fmt("%sKill Basina HP \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvKillHP]), 6) ? "":"\d", IsThePlayerDia(id, g_cvars[cvKillHP])));
	menu_additem(bestm, fmt("%s2 Kat TL \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cv2xTL]), 7) ? "":"\d", IsThePlayerDia(id, g_cvars[cv2xTL])));
	menu_additem(bestm, fmt("%s10 Saniyede Bir Bomba\d(1 Dakika) \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvSecondHegrenade]), 8) ? "":"\d", IsThePlayerDia(id, g_cvars[cvSecondHegrenade])));
	menu_additem(bestm, fmt("%s10 Saniyede Bir 10 HP\d(1 Dakika) \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvSecondHealth]), 9) ? "":"\d", IsThePlayerDia(id, g_cvars[cvSecondHealth])));
	menu_additem(bestm, fmt("%sYuksek Ziplama \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvHighJump]), 10) ? "":"\d", IsThePlayerDia(id, g_cvars[cvHighJump])));
	menu_additem(bestm, fmt("%sGorunmezlik\d(1 Dakika) \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvInVisibility]), 11) ? "":"\d", IsThePlayerDia(id, g_cvars[cvInVisibility])));
	menu_additem(bestm, fmt("%sDusman Kiligina Gir \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvBeAnEnemy]), 12) ? "":"\d", IsThePlayerDia(id, g_cvars[cvBeAnEnemy])));
	menu_additem(bestm, fmt("%sSinirsiz Mermi\d(30 Saniye) \d[\r%d \yTL\d]", CanUsePlayer(id, IsThePlayerDia(id, g_cvars[cvUnlimitedAmmo]), 13) ? "":"\d", IsThePlayerDia(id, g_cvars[cvUnlimitedAmmo])));

	menu_setprop(bestm, MPROP_EXITNAME, "\rCikis");
	menu_setprop(bestm, MPROP_SHOWPAGE, 0);
	menu_display(id, bestm);
}
public clcmd_dmshop_(const id, menu, item){
	switch(item){
		case 0: buyitem(id, "150 HP", IsThePlayerDia(id, g_cvars[cvHealth]), 0);
		case 1: buyitem(id, "150 Armor", IsThePlayerDia(id, g_cvars[cvArmor]), 1);
		case 2: buyitem(id, "Hizli Yurume", IsThePlayerDia(id, g_cvars[cvFastWalking]), 2);
		case 3: buyitem(id, "Can ve Zirh Yenile", IsThePlayerDia(id, g_cvars[cvResetHPArmor]), 3);
		case 4: buyitem(id, "Sessiz Yurume", IsThePlayerDia(id, g_cvars[cvFootsteps]), 4);
		case 5: buyitem(id, "GodMode", IsThePlayerDia(id, g_cvars[cvGodmode]), 5);
		case 6: buyitem(id, "Kill Basina HP", IsThePlayerDia(id, g_cvars[cvKillHP]), 6);
		case 7: buyitem(id, "2 Kat TL", IsThePlayerDia(id, g_cvars[cv2xTL]), 7);
		case 8: buyitem(id, "10 Saniyede Bir Bomba", IsThePlayerDia(id, g_cvars[cvSecondHegrenade]), 8);
		case 9: buyitem(id, "10 Saniyede Bir 10 HP", IsThePlayerDia(id, g_cvars[cvSecondHealth]), 9);
		case 10: buyitem(id, "Yuksek Ziplama", IsThePlayerDia(id, g_cvars[cvHighJump]), 10);
		case 11: buyitem(id, "Gorunmezlik", IsThePlayerDia(id, g_cvars[cvInVisibility]), 11);
		case 12: buyitem(id, "Dusman Kiligina Gir", IsThePlayerDia(id, g_cvars[cvBeAnEnemy]), 12);
		case 13: buyitem(id, "Sinirsiz Mermi", IsThePlayerDia(id, g_cvars[cvUnlimitedAmmo]), 13);
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
/********************************* Queries **********************************/
public buyitem(const id, szItem[], iCost, iType){
	if(g_blOneUse[id][iType]){
		client_print_color(id, id, "%l", "ONE_USE", iChatTag);
		return PLUGIN_HANDLED;
	}
	else if(g_int[iTL][id] >= iCost){
		g_int[iTL][id] -= iCost;
		g_blOneUse[id][iType] = true;
		client_print_color(id, id, "%l", "BUY_ITEM", iChatTag, szItem);
		switch(iType){
			case 0:{
				set_entvar(id, var_health, Float:get_entvar(id, var_health) +150.0);
			}
			case 1:{
				set_entvar(id, var_armorvalue, Float:get_entvar(id, var_armorvalue) +150.0);
			}
			case 2:{
				set_entvar(id, var_maxspeed, 350.0);
			}
			case 3:{
				set_entvar(id, var_health, 100.0);
				set_entvar(id, var_armorvalue, 100.0);
			}
			case 4:{
				rg_set_user_footsteps(id, true);
			}
			case 5:{
				set_entvar(id, var_takedamage, DAMAGE_NO);
				if(!task_exists(id + TASK_GODMODE)){
					set_task(10.0, "GodmodeClose", id + TASK_GODMODE);
				}
			}
			case 8:{
				rg_give_item(id, "weapon_hegrenade");
				set_task(10.0, "GiveHegrenade", id + TASK_GIVEHEGRENADE, .flags = "b");
			}
			case 9:{
				set_entvar(id, var_health, Float:get_entvar(id, var_health) +10.0);
				set_task(10.0, "GiveHealth", id + TASK_GIVEHEALTH, .flags = "b");
			}
			case 10:{
				set_entvar(id, var_gravity, 0.6);
			}
			case 11:{
				set_entvar(id, var_effects, get_entvar(id, var_effects) | EF_NODRAW);
				set_task(60.0, "InvisibleClose", id + TASK_INVISIBLE);
			}
			case 12:{
				if(get_member(id, m_iTeam) == TEAM_CT){
					rg_set_user_model(id, "leet");
				}
				else {
					rg_set_user_model(id, "gign");
				}
			}
			case 13:{
				set_task(30.0, "UnlimitedAmmoClose", id + TASK_UNLIMITEDAMMO);
			}
		}
	}
	else {
		client_print_color(id, id, "%l", "INSUFFICIENT_COST", iChatTag);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}
bool:CanUsePlayer(const id, cvCvars, iType){
	if(g_blOneUse[id][iType]){
		return false;
	}
	else if(g_int[iTL][id] >= cvCvars){
		return true;
	}
	return false;
}
public IsThePlayerDia(const id, iCost){
	if(get_user_flags(id) & ADMIN_DIA){
		if(iCost > 10){
			iCost = iCost-5;
		}
		else {
			iCost = iCost-2;
		}
	}
	return iCost;
}
/**************************** Registers ****************************/
public RG_CBasePlayer_ResetMaxSpeed_Pre(const id){
	if(g_blOneUse[id][2]){
		set_entvar(id, var_maxspeed, 450.0);
		return HC_SUPERCEDE;
	}
	return HC_CONTINUE;
}
public RG_CBasePlayer_Killed_Post(const this, pevAttacker, iGib){
	if(!(is_user_connected(this) || is_user_connected(pevAttacker)) || this == pevAttacker){
		return;
	}

	if(g_blOneUse[pevAttacker][6]){
		set_entvar(pevAttacker, var_health, Float:get_entvar(pevAttacker, var_health) +10.0);
	}
	if(g_blOneUse[pevAttacker][7]){
		g_int[iTL][pevAttacker] += g_cvars[cvKillTL]*2;
	}
	else {
		g_int[iTL][pevAttacker] += g_cvars[cvKillTL];
	}
}
public RG_CBasePlayer_Spawn_Post(const id){
	if(get_member(id, m_bJustConnected)){
		return;
	}
	ResetData(id);
	rg_reset_user_model(id);
}
public CurWeapon_(const id){
	if(g_blOneUse[id][13]){
		set_member(get_member(id, m_pActiveItem), m_Weapon_iClip, rg_get_weapon_info(read_data(2), WI_GUN_CLIP_SIZE));
	}
}

/**************************** Tasks Close ***************************/
public GodmodeClose(Taskid){
	new id = Taskid - TASK_GODMODE;

	set_entvar(id, var_takedamage, DAMAGE_AIM);
	client_print_color(id, id, "%l", "GODMODE_CLOSE", iChatTag);
}
public GiveHegrenade(Taskid){
	new id = Taskid - TASK_GIVEHEGRENADE;

	if(rg_has_item_by_name(id, "weapon_hegrenade")){
		rg_set_user_bpammo(id, WEAPON_HEGRENADE, rg_get_user_bpammo(id, WEAPON_HEGRENADE)+1);
	}
	else {
		rg_give_item(id, "weapon_hegrenade");
		rg_set_user_bpammo(id, WEAPON_HEGRENADE, 1);
	}
	g_int[iHeLimited][id]++;

	if(g_int[iHeLimited][id] >= 6){
		remove_task(id + TASK_GIVEHEGRENADE);
		client_print_color(id, id, "%l", "GIVE_HEGRENADE_CLOSE", iChatTag);
	}
}
public GiveHealth(Taskid){
	new id = Taskid - TASK_GIVEHEALTH;

	set_entvar(id, var_health, Float:get_entvar(id, var_health) +10.0);
	g_int[iHealthLimited][id]++;

	if(g_int[iHealthLimited][id] >= 6){
		remove_task(id + TASK_GIVEHEALTH);
		client_print_color(id, id, "%l", "GIVE_HEALTH_CLOSE", iChatTag);
	}
}
public UnlimitedAmmoClose(Taskid){
	new id = Taskid - TASK_UNLIMITEDAMMO;

	g_blOneUse[id][13] = false;
	client_print_color(id, id, "%l", "UNLIMITED_AMMO_CLOSE", iChatTag);
}
public InvisibleClose(Taskid){
	new id = Taskid - TASK_INVISIBLE;

	set_entvar(id, var_effects, get_entvar(id, var_effects) & ~EF_NODRAW);
	client_print_color(id, id, "%l", "INVISIBLE_CLOSE", iChatTag);
}
/********************************************************************/
public client_disconnected(id){
	ResetData(id);
	g_int[iTL][id] = 0;
}
public client_connect(id){
	ResetData(id);
}
public ResetData(const id){
	remove_task(id + TASK_GODMODE);
	remove_task(id + TASK_GIVEHEGRENADE);
	remove_task(id + TASK_GIVEHEALTH);
	remove_task(id + TASK_UNLIMITEDAMMO);
	remove_task(id + TASK_INVISIBLE);

	g_int[iHeLimited][id] = 0;
	g_int[iHealthLimited][id] = 0;

	for(new i = 0; i <= 13; i++){
		g_blOneUse[id][i] = false;
	}
}