#pragma semicolon 1

#include <amxmodx>
#include <reapi>

public plugin_init(){
	register_plugin("Command Block When Team Full", "0.1", "` BesTCore;");

	register_clcmd("amx_team", "clcmd_BlockCommand");
	register_clcmd("amx_transfer", "clcmd_BlockCommand");
	register_clcmd("amx_swap", "clcmd_BlockCommand");
	register_clcmd("amx_teammenu", "clcmd_BlockCommand");
}
public clcmd_BlockCommand(const id){
	if(get_member_game(m_iNumCT) == get_member_game(m_iNumTerrorist)){
		client_print_color(id, id, "^4Takimlar esitken bu islemi yapamazsiniz.");
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}