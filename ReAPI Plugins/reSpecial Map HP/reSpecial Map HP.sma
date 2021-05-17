#pragma semicolon 1

#include <amxmodx>
#include <reapi>

new const g_iMapName[][] = {
	"Mapname 1",
	"Mapname 2",
	"Mapname 3"
	// Tırnak içerisinde map ismi ve virgül, son mapı yazarken sonuna virgül ekleme. örnek gösterdim.
};

public plugin_init(){
	register_plugin("Special Map HP", "0.1", "` BesTCore;");

	static bool:g_icvar;
	static map[MAX_MAPNAME_LENGTH];
	rh_get_mapname(map, charsmax(map));

	for(new i = 0; i < sizeof(g_iMapName); i++){
		if(equal(map, g_iMapName[i])){
			g_icvar = true;
		}
	}
	if(g_icvar){
		RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn_Post", .post = true);
	}
}
public CBasePlayer_Spawn_Post(const id){
	set_entvar(id, var_health, 1.0);
}