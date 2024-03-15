#include <sourcemod>
#include <multicolors>

#pragma newdecls required
#pragma semicolon 1

int tkCounter[MAXPLAYERS + 1];

public Plugin myinfo = {
    name = "[L4D2] Announce Teamkill",
    author = "sh0tx",
    description = "Description",
    version = "1.0.0",
    url = "sourcemod.net",
};

public void OnPluginStart() {
    HookEvent("player_incapacitated", OnTeamkill);
}

public void OnClientConnected(int client) {
    tkCounter[client] = 0;
}

public Action OnTeamkill(Event event, const char[] name, bool shuttheFuckup) {
    char nameVictim[MAX_NAME_LENGTH];
    char nameAttacker[MAX_NAME_LENGTH];

    int idVictim = GetEventInt(event, "userid");
    int idAttacker = GetEventInt(event, "attacker");

    int victim = GetClientOfUserId(idVictim);
    int attacker = GetClientOfUserId(idAttacker);

    if (!IsClientInGame(victim) || !IsClientInGame(attacker)) {
        return Plugin_Continue;
    }

    GetClientName(victim, nameVictim, sizeof(nameVictim));
    GetClientName(attacker, nameAttacker, sizeof(nameAttacker));

    if (victim == attacker || StrEqual(nameVictim, nameAttacker)) {
        return Plugin_Continue;
    }

    if (GetClientTeam(victim) == GetClientTeam(attacker)) {
        tkCounter[attacker]++;
        CPrintToChatAll("{green}%s {default}(count {blue}%i{default}) killed {green}%s", nameAttacker, tkCounter[attacker], nameVictim);
    }

    return Plugin_Continue;
}
