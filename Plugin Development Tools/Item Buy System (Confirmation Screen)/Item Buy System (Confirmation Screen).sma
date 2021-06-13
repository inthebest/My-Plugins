// forum.csduragi.com
#pragma semicolon 1

#include <amxmodx>

new const g_szItems[] = "addons/amxmodx/configs/Esyalar.ini";

enum _:ItemsData   // Array verilerini oluşturduk.
{
	szItemName[32],
	iItemMoney
};
new Array:g_aItems;  // İtem arrayi oluşturduk.

// Menüde işlemi yaptırmak için kullanacağımız değişkenler.
new g_szItemKey[MAX_PLAYERS+1][32],  // Seçtiğimiz itemin ismini saklamak icin kullanacağımız değişken. "32" değer aralığında ve "string" yani yazı türünde.
    g_iCostKey[MAX_PLAYERS+1];		 // Seçtiğimiz itemin fiyatini saklamak icin kullanacağımz değişken "integer" yani sayı türünde.

public plugin_init()
{
	register_plugin("Item Buy System (Confirmation Screen)", "0.1", "` BesTCore;");

	g_aItems = ArrayCreate(ItemsData);   // Arrayımızı oluşturduk.

	register_clcmd("say /market", "clcmd_market"); // Market cmd'si oluşturuyoruz.

	GetDataFromFile();  // Dosyadaki verileri işleyeceğimiz fonksiyon. İçeriği aşşağıda...
}
public clcmd_market(const id)
{
	new iSize = ArraySize(g_aItems);

	if(iSize < 1) // Eğer array boyutu "1"'den küçükse içi boş demektir, böylelikle bilgi mesajı ekleyebilirsiniz.
	{
		//client_print_color(id, id, "^3Markette satin alinacak birsey yok.");  
		return;    
	}

	new bestm = menu_create("\rMarket Menu", "clcmd_market_handler");

	new aData[ItemsData];   // Array verilerini çekmek için değişken oluşturduk.

	for(new i = 0; i < iSize; i++)
	{
		ArrayGetArray(g_aItems, i, aData);   // Bütün verileri for döngüsünde sıraladık ve "aData" değişkenine aktardık.
		menu_additem(bestm, fmt("%s\r %i TL", aData[szItemName], PlayerDiscount(id, aData[iItemMoney])), fmt("%i", i)); // Menüyü oluşturduk.
	}
	menu_display(id, bestm); // Oyuncuya menüyü gösterdik. Burayı, for döngüsü içerisinde kullanmayın, çalışmaz.
}
public clcmd_market_handler(const id, const menu, const item)
{
	/*if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}
	new data[6], key;
	menu_item_getinfo(menu, item, _, data, charsmax(data));
	key = str_to_num(data);*/  

	// "menu_item_getinfo" ile menü bilgilerini çekmiyoruz, eğer çekersek seçtiğimiz seçenek değeri "0" olarak değil "1" olarak gelir ve işlemimizi sıkıntıya sokar.

	new aData[ItemsData];
	ArrayGetArray(g_aItems, item, aData);    // Seçtiğimiz seçeneğin itemini array'dan çektik.

	ConfirmationScreen(id, aData[szItemName], PlayerDiscount(id, aData[iItemMoney]));  // Menü bilgilerini yerleştirdik.

	menu_destroy(menu); // Menüyü kapattık.
	return PLUGIN_HANDLED;
}
public ConfirmationScreen(const id, const szItem[], const iCost)   // Publicimizde bilgileri sıraladık.
{
	copy(g_szItemKey[id], charsmax(g_szItemKey[]), szItem);  // Public handlerinde kullanmak için eşyanın ismini değişkenimize aktardık.
//                                                              String olduğu için "copy" ile yaptık.
	g_iCostKey[id] = iCost;   // Public handlerinde kullanmak için eşyanın fiyatını değişkenimize aktardık.

	new bestm = menu_create("\rOnay Ekrani", "ConfirmationScreen_handler");

	menu_additem(bestm, fmt("Esya Ismi:\y %s", szItem));         // Esya ismini "Item" yazdırdık.
	menu_additem(bestm, fmt("\wEsya Fiyati:\y %i\r TL", iCost));  // Esya fiyatini "Cost" yazdırdık. 
	menu_additem(bestm, fmt("Size Ozel Indirim:\y %i\r TL^n", iCost - PlayerDiscount(id, iCost))); // Bu yontem ile indirim fiyatini çekebilirsiniz.

	menu_additem(bestm, "Satin Al");   // Satın alma seçeneği.
	menu_additem(bestm, "Iptal Et");   // İslemi iptal etme seçeneği.

	menu_display(id, bestm); // Menüyü gösterdik.
}
public ConfirmationScreen_handler(const id, const menu, const item)
{
	switch(item)
	{
		case 0..2:   // Bastığımız seçenek 0 ile 2 arasında ise..
		{
			menu_display(id, menu); // Menüyü tekrar gösterdik.

			ConfirmationScreen(id, g_szItemKey[id], g_iCostKey[id]);  // Menüyü tekrar gösterdik.

			// 2 türlüde yapabilirsiniz.
		}
		case 3:   // Eğer seçenek "3" ise yani "Satin Al" ise, işlem yaptırıyoruz.
		{
			client_print_color(id, id, "^3Basarili bir sekilde^4 %s^3 adli esyayi^4 %i TL^3'ye satin aldiniz.", g_szItemKey[id], g_iCostKey[id]);
		}   // Gördüğünüz gibi satın alma işlemimizi yaptırdık. Buradan sonrası sizin kodlama bilginize kalmış.
		case 4:
		{
			client_print_color(id, id, "^3Isleminizi iptal ettiniz."); // İşlemi iptal ettik.
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED;
}
public PlayerDiscount(const id, iCost) // Oyuncu indirimini çekme.
{
	new iFlags = get_user_flags(id);

	if(iFlags & ADMIN_RCON)   // Oyuncunun yetkisi "ADMIN_RCON" ise.
	{
		iCost = iCost - 3;
		return iCost;		// Fiyattan "3" eksiltip returnladık.
	}
	return iCost; // Eğer hiçbirşey olmaz ise aynı fiyatı tekrar döndürdük.
}
GetDataFromFile()    // Verileri aktarma fonksiyonu.
{
	new iFile = fopen(g_szItems, "rt");   // Esyalar dosyamızı açıp, veriye aktardık.

	if(iFile)
	{
		new szBuffer[MAX_FMT_LENGTH], aData[ItemsData],  // Değişkenler.
			szItem[32], iMoney[10];

		while(fgets(iFile, szBuffer, charsmax(szBuffer)))
		{
			trim(szBuffer);

			if(szBuffer[0] == EOS || szBuffer[0] == ';')
			{
				continue;
			}

			parse(szBuffer, szItem, charsmax(szItem), iMoney, charsmax(iMoney));

			copy(aData[szItemName], charsmax(aData), szItem);   // Burayı direk fiyatı eşitleme gibi yapabilirsiniz, ben sağlama alıp "copy" ile yaptım.
			aData[iItemMoney] = str_to_num(iMoney);

			ArrayPushArray(g_aItems, aData); // Verileri arraya aktardık.
		}
		fclose(iFile);  // Dosyayı kapattık.
	}
}
public plugin_end()
{
	ArrayDestroy(g_aItems); // Arrayı kapattık, kapatmazsak sorun çıkartır.
}