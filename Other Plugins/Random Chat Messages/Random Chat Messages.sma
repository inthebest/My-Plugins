#pragma semicolon 1

#include <amxmodx>

// Alt alta aynı şekilde istediğiniz kadar mesajlarınızı yazınız en altta olanın sonuna "," koymayınız.
// Renkli yazmak isterseniz mesajlara, ^1- Sarı, ^4- Yeşil, ^3- Takım rengi kodlarını ekleyiniz.
new const szChatMsg[][] = {
	"^1Sari renkte mesaj yaziyorum.",
	"^3Takimimin renginde mesaj yaziyorum.",
	"^4Yesil renkte mesaj yaziyorum."
};

public plugin_init(){
	register_plugin("Random Chat Messages", "0.1", "` BesTCore;");

	set_task(40.0, "RandomMsg", .flags = "b");
}
public RandomMsg(){
	new iRandom = random_num(0, charsmax(szChatMsg));

	client_print_color(0, 0, "%s", szChatMsg[iRandom]);
}
public client_disconnected(id){
	remove_task();
}