#pragma semicolon 1

#include <amxmodx>
#include <reapi>

#define ADMIN_UNAMMO   ADMIN_IMMUNITY

public plugin_init(){
	register_plugin("Unammo for Authorization", "0.1", "` BesTCore;");

	register_event("CurWeapon", "CurWeapon_", "be", "1=1", "3=1");
}
public CurWeapon_(const id){
	if(~get_user_flags(id) & ADMIN_UNAMMO){
		return;
	}
	set_member(get_member(id, m_pActiveItem), m_Weapon_iClip, rg_get_weapon_info(read_data(2), WI_GUN_CLIP_SIZE));
}