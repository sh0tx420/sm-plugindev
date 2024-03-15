#include <sourcemod>
#include <cstrike>
#include <sdktools_functions>
#pragma newdecls required
#pragma semicolon 1


public Plugin myinfo = {
	name = "[CSS] Kill for grenade",
	author = "sh0tx",
	description = "Gives you a HE grenade when you kill 3 players.",
	version = "1.0.0",
	url = "sourcemod.net"
};

public void OnPluginStart() {
    HookEvent("player_death", OnPlayerDeath);
}

int kills[MAXPLAYERS + 1];

public void OnClientConnected(int client) {
    kills[client] = 0;
}

Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) {
    int killer = GetClientOfUserId(event.GetInt("attacker"));

    if (killer) {
        kills[killer]++;
        if ((kills[killer] == 3) && (!IsFakeClient(killer))) {
            GivePlayerItem(killer, "weapon_hegrenade");
            kills[killer] = 0;
        }
    }
}
