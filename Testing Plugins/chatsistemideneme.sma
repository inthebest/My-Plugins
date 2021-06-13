
#pragma semicolon 1

#include <amxmodx>

public plugin_init(){
	register_plugin("Chat System","1.0","` BesTCore");

	register_clcmd("say","chatsystem");
	register_clcmd("say_team","chatsystemteam");
}
public chatsystem(id){
	new arg[255];
	read_args(arg, charsmax(arg));
	remove_quotes(arg);
	if(strlen(arg) > 0){
		new form[3][256], iFlags = get_user_flags(id);

		if(!is_user_alive(id)){
			form[0] = fmt("^1(x) ");
		}
		if(iFlags & ADMIN_RESERVATION){
			form[2] = fmt("^4%s", arg);
		}
		else{
			form[2] = fmt("^1%s", arg);
		}
		form[1] = fmt("^3%n", id);

		sendmsgs(id, fmt("%s%s%s %s: %s", form[0], form[1], form[2]));
	}
	return PLUGIN_HANDLED;
}
public sendmsgs(id, argformat[]){
	new team[20];
	get_user_team(id, team, charsmax(team));
	for(new i = 1; i <= MaxClients; i++){
		if(is_user_alive(i) && is_user_alive(id) || !is_user_alive(id) && !is_user_alive(i)){
			new iteam[20];
			get_user_team(i, iteam, charsmax(iteam));

			message_begin(MSG_ONE, get_user_msgid("TeamInfo"), _, i);
			write_byte(i);
			write_string(team);
			message_end();
			message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, i);
			write_byte(i);
			write_string(argformat);
			message_end();
			message_begin(MSG_ONE, get_user_msgid("TeamInfo"), _, i);
			write_byte(i);
			write_string(iteam);
			message_end();
		}
	}
}
public chatsystemteam(id){
	new arg[255];
	read_args(arg, charsmax(arg));
	remove_quotes(arg);
	if(strlen(arg) > 0){
		new argformatteam[255],formteam[5][255],flags = get_user_flags(id);
		if(!is_user_alive(id)){
			formatex(formteam[0], 254, "^1(x) ");
		}
		if(flags & ADMIN_RESERVATION){
			formatex(formteam[3], 254, "^4%s", arg);
			formatex(formteam[1], 254, "^1[^4ADMIN^1]");
		}
		else {
			formatex(formteam[3], 254, "^1%s", arg);
			formatex(formteam[1], 254, "^1[^4USER^1]");
		}
		switch(get_user_team(id)){
			case 1:{
				formatex(formteam[4], 254, "^1[^4Terrorist^1]");
			}
			case 2:{
				formatex(formteam[4], 254, "^1[^4Counter-Terrorist^1]");
			}
			case 3:{
				formatex(formteam[4], 254, "^1[^4Spectator^1]");
			}
		}
		formatex(formteam[2], 254, "^3%n", id);
		formatex(argformatteam, charsmax(argformatteam), "%s%s%s %s^1: %s", formteam[0], formteam[4], formteam[1], formteam[2], formteam[3]);
		sendmsgsteam(id, argformatteam);
	}
	return PLUGIN_CONTINUE;
}
public sendmsgsteam(id, argformatteam[]){
	new team[20];
	get_user_team(id, team, charsmax(team));

	for(new i = 1; i <= MaxClients; i++){
		new teams[2];
		teams[0] = get_user_team(i);
		teams[1] = get_user_team(id);
		if(is_user_alive(i) && is_user_alive(id) || !is_user_alive(id) && !is_user_alive(i) && teams[0] == teams[1]){
			new iteam[20];
			get_user_team(i, iteam, charsmax(iteam));
			message_begin(MSG_ONE, get_user_msgid("TeamInfo"), _, i);
			write_byte(i);
			write_string(team);
			message_end();
			message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, i);
			write_byte(i);
			write_string(argformatteam);
			message_end();
			message_begin(MSG_ONE, get_user_msgid("TeamInfo"), _, i);
			write_byte(i);
			write_string(iteam);
			message_end();
		}
	}
}