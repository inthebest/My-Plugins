#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>

public plugin_init(){
	register_plugin("Pressed The Button", "0.1", "` BesTCore;");

	RegisterHam(Ham_Use, "func_button", "PressedButton");
}
public PressedButton(entity, id){
	client_print_color(0, 0, "^1%n ^3adli oyuncu bir tusa basti.", id);
	return HAM_IGNORED;
}