/* 
*     Scheduled Shutdown/Restart
*     By [BR5DY]
* 
*    This plugin could not have been made without the help of MikeJS's plugin and darklord1474's plugin.
* 
*     Automatically shuts down the server at the specified time, warning all players ahead of time.
*    Will restart automatically if you run some type of server checker or batch script :-)
* 
*     Very basic commands - it issues the "quit" command to SRCDS at the specified time
* 
*   Cvars:
*    sm_scheduledshutdown_hintsay 1        //Sets whether messages are shown in the hint area
*    sm_scheduledshutdown_chatsay  1        //Sets whether messages are shown in chat
*    sm_scheduledshutdown_centersay 1    //Sets whether messages are shown in the center of the screen
*    sm_scheduledshutdown_time 0500        //Sets the time to shutdown the server
*/
#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

Handle g_hEnabled = INVALID_HANDLE;
bool g_bEnabled;
Handle g_hTime = INVALID_HANDLE;
int g_iTime;

public Plugin myinfo = {
    name = "[ANY] Server Autorestart",
    author = "sh0tx",
    description = "Shutsdown SRCDS (with options). Special thanks to MikeJS, darklord1474 and BR5DY",
    version = "1.2",
    url = "https://rc7.pw"
}

public void OnPluginStart() {
    PrintToServer("autorestart.smx loaded successfully.");

    g_hEnabled = CreateConVar("sm_autorestart", "1", "Enable autorestart.");
    g_hTime = CreateConVar("sm_scheduledshutdown_time", "0100", "Time to shutdown server.");

    RegAdminCmd("sm_restart", Command_StartCountdown, ADMFLAG_ROOT, "Schedule a server restart immediately.");

    HookConVarChange(g_hEnabled, Cvar_enabled);
    HookConVarChange(g_hTime, Cvar_time);

    AutoExecConfig();
}

public void OnMapStart() {
    CreateTimer(60.0, CheckTime, 0, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void OnConfigsExecuted() {
    g_bEnabled = GetConVarBool(g_hEnabled);
    char iTime[8];
    GetConVarString(g_hTime, iTime, sizeof(iTime));
    g_iTime = StringToInt(iTime);
}

public void Cvar_enabled(ConVar convar, const char[] oldValue, const char[] newValue) {
    g_bEnabled = GetConVarBool(g_hEnabled);
}

public void Cvar_time(ConVar convar, const char[] oldValue, const char[] newValue) {
    char iTime[8];
    GetConVarString(g_hTime, iTime, sizeof(iTime));
    g_iTime = StringToInt(iTime);
}

public Action AlertServer(Handle timer, int seconds) {
    // print to chat, hud center and sound
    char szSuffix[8];

    if (seconds > 5 || seconds == 1) {
        PrintToChatAll("[SM] Server restarting in %i seconds...", seconds);
        PrintCenterTextAll("Server restarting in %i seconds...", seconds);
    }

    if (seconds == 120) {
        strcopy(szSuffix, sizeof(szSuffix), "2min");
    }
    if (seconds == 60) {
        strcopy(szSuffix, sizeof(szSuffix), "60sec");
    }

    switch (seconds) {
        case 120: {
            strcopy(szSuffix, sizeof(szSuffix), "2min");
        }
        case 60: {
            strcopy(szSuffix, sizeof(szSuffix), "60sec");
        }
        case 1: {
            strcopy(szSuffix, sizeof(szSuffix), "5sec");
        }
        case 2: {
            strcopy(szSuffix, sizeof(szSuffix), "4sec");
        }
        case 3: {
            strcopy(szSuffix, sizeof(szSuffix), "3sec");
        }
        case 4: {
            strcopy(szSuffix, sizeof(szSuffix), "2sec");
        }
        case 5: {
            strcopy(szSuffix, sizeof(szSuffix), "1sec");
        }
    }

    for (int i = 1; i <= MaxClients; i++) {
        ClientCommand(i, "playgamesound vo/announcer_ends_%s.mp3", szSuffix);
    }

    KillTimer(timer, true);

    return Plugin_Continue;
}

float IntToFloat(int integer) {
    char str_c[4];
    float result;

    IntToString(integer, str_c, sizeof(str_c));
    StringToFloatEx(str_c, result);
    
    return result;
}

public void StartCountdown() {
    // first warning, call alert instantly
    CreateTimer(0.1, AlertServer, 120);

    // start timer for second warning
    CreateTimer(60.0, AlertServer, 60);

    // after 2 minutes, start countdown from 5
    for (int i = 1; i <= 5; i++) {
        CreateTimer(IntToFloat(i) + 120.0, AlertServer, i);
    }

    // total time from timers: 0.1 + 60 + 120 + 5 = 185.1 (+ .4 seconds just for fun)
    LogAction(0, -1, "Server shutdown warning countdown started.");
    CreateTimer(125.5, ExitServer, _, TIMER_REPEAT);
}

public Action Command_StartCountdown(int client, int args) {
    StartCountdown();
    ReplyToCommand(client, "[SM] Scheduled a server restart.");
    return Plugin_Handled;
}

public Action CheckTime(Handle timer, any nig) {
    if (g_bEnabled) {
        char strtime[8];
        int gettime = GetTime();

        FormatTime(strtime, sizeof(strtime), "%H%M", gettime);
        int time = StringToInt(strtime);

        if (time >= g_iTime && time <= g_iTime + 1) {
            StartCountdown();
        }
    }

    return Plugin_Continue;
}

public Action ExitServer(Handle timer) {
    // Force clients to rejoin server (trol) (maybe make a cvar or something to disable this functionality?)
    for (int i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i) && !IsFakeClient(i)) {
            ClientCommand(i, "retry");   // get pranked
        }
    }

    // Cleanup and exit server
    KillTimer(timer);
    LogAction(0, -1, "Server shutdown.");
    ServerCommand("exit");

    return Plugin_Handled;
}
