#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PLUGIN_NAME     "[TF2] Third Person"
#define PLUGIN_VERSION  "1.1"

#define DELAY   0.250   // Delay is set in seconds
#define PREFIX  "[SM]"  // For colored chat

#define COLOR_DEFAULT   0x01
#define COLOR_GREEN     0x04

new Handle:g_Cvar_Default = INVALID_HANDLE;
new Handle:g_Cvar_CanChange = INVALID_HANDLE;

new bool:g_bInThirdPersonView[MAXPLAYERS + 1];

public Plugin:myinfo = {
    name = PLUGIN_NAME,
    author = "sh0tx",
    description = "Toggles the view to thirdperson and back",
    version = PLUGIN_VERSION,
    url = "http://www.sourcemod.net/"
};

public OnPluginStart() {
    LoadTranslations("common.phrases");
    LoadTranslations("core.phrases");
    LoadTranslations("thirdperson.phrases");
    
    CreateConVar("sm_tp_version", PLUGIN_VERSION, "Plugin version", FCVAR_SPONLY | FCVAR_NOTIFY);
    
    g_Cvar_Default = CreateConVar("sm_tp_default", "0", "Set default view (0 firstperson, 1 thirdperson, def. 0)", 0, true, 0.0, true, 1.0);
    g_Cvar_CanChange = CreateConVar("sm_tp_can_change", "1", "Can clients change their view? (0 no, 1 yes, def. 1)", FCVAR_SPONLY | FCVAR_NOTIFY, true, 0.0, true, 1.0);
    
    RegConsoleCmd("sm_firstperson", Command_FirstPerson);
    RegConsoleCmd("sm_thirdperson", Command_ThirdPerson);
    RegConsoleCmd("sm_fp", Command_FirstPerson);
    RegConsoleCmd("sm_tp", Command_ThirdPerson);
    
    HookEvent("player_class", PlayerSpawn);
    HookEvent("player_spawn", PlayerSpawn);
    
    HookEvent("teamplay_round_start", RoundStart);
    
    AutoExecConfig(true, "thirdperson");
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    new userid = GetEventInt(event, "userid");
    new client = GetClientOfUserId(userid);
    
    CreateTimer(DELAY, ThirdPersonOnSpawn, client);
}

public Action:ThirdPersonOnSpawn(Handle:timer, any:client)
{
    if (IsClientInGame(client) && g_bInThirdPersonView[client] && IsPlayerAlive(client))
    {
        SetThirdPersonView(client);
    }
}

public Action:RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
    for (new i = 1; i <= MaxClients; i++)
    {
        CreateTimer(DELAY, ThirdPersonOnSpawn, i);
    }
}

public OnClientConnected(client)
{
    g_bInThirdPersonView[client] = GetConVarBool(g_Cvar_Default);
}

public Action:Command_FirstPerson(client, args)
{
    if (client == 0)
    {
        ReplyToCommand(client, "%s %t", PREFIX, "Command is in-game only");
        return Plugin_Handled;
    }
    
    FirstPersonRequest(client);
    
    return Plugin_Handled;
}

public Action:Command_ThirdPerson(client, args)
{
    if (client == 0)
    {
        ReplyToCommand(client, "%s %t", PREFIX, "Command is in-game only");
        return Plugin_Handled;
    }
    
    ThirdPersonRequest(client);
    
    return Plugin_Handled;
}

SetThirdPersonView(client)
{
    g_bInThirdPersonView[client] = true;
    
    SetVariantInt(1);
    AcceptEntityInput(client, "SetForcedTauntCam");
}

SetFirstPersonView(client)
{
    g_bInThirdPersonView[client] = false;
    
    SetVariantInt(0);
    AcceptEntityInput(client, "SetForcedTauntCam");
}

ThirdPersonRequest(client)
{
    if (!GetConVarBool(g_Cvar_CanChange))
    {
        ReplyToCommand(client, "%s %t", PREFIX, "No Access");
        return;
    }
    
    if (g_bInThirdPersonView[client])
    {
        ReplyToCommand(client, "%s %t", PREFIX, "Thirdperson Already Enabled");
    }
    else
    {
        SetThirdPersonView(client);
        ReplyToCommand(client, "%s %t", PREFIX, "Thirdperson Enabled");
    }
}

FirstPersonRequest(client)
{
    if (!GetConVarBool(g_Cvar_CanChange))
    {
        ReplyToCommand(client, "%s %t", PREFIX, "No Access");
        return;
    }
    
    if (!g_bInThirdPersonView[client])
    {
        ReplyToCommand(client, "%s %t", PREFIX, "Firstperson Already Enabled");
    }
    else
    {
        SetFirstPersonView(client);
        ReplyToCommand(client, "%s %t", PREFIX, "Firstperson Enabled");
    }
}
