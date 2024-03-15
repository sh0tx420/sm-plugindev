#include <sourcemod>
#include <clientprefs>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_NAME "[L4D2] Map Display"

public Plugin myinfo = {
    name = PLUGIN_NAME,
    author = "sh0tx",
    description = "Show map in hint text",
    version = "1.0.0",
    url = "sourcemod.net",
};

char mapname[32];
Handle MapDisplayCookie;

Action PrintMapname(Handle timer, int client) {
    PrintHintText(client, mapname);

    return Plugin_Continue;
}

public void OnPluginStart() {
    PrintToServer("Loaded plugin: %s", PLUGIN_NAME);

    MapDisplayCookie = RegClientCookie("l4d2_mapdisplay_enabled", "Map Display", CookieAccess_Protected);
    SetCookiePrefabMenu(MapDisplayCookie, CookieMenu_OnOff, "HUD Map display");
}

public void OnClientPostAdminCheck(int client) {
    if (AreClientCookiesCached(client)) {
        // get cookie and display map depending on it
        char isMenuEnabled[4];
        GetClientCookie(client, MapDisplayCookie, isMenuEnabled, sizeof(isMenuEnabled));


        if (StrEqual(isMenuEnabled, "on")) {
            CreateTimer(1.0, PrintMapname, client, TIMER_REPEAT);
        }
    }
}

public void OnMapStart() {
    GetCurrentMap(mapname, sizeof(mapname));
}
