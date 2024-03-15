#include <sourcemod>
#include <tf2attributes>
#include <sdktools>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
    name = "[TF2] Movement Speed Unlocker",
    description = "Removes the 520 HU/s constraint on move speed, configurably.",
    author = "Deathreus, sh0tx",
    version = "1.1",
    url = "sourcemod.net"
};

// 1.1: removed useless code

Handle g_hProcessMovement = null;

ConVar cvarSpeedLimit;

public void OnPluginStart()
{
    Handle hConfig = LoadGameConfigFile("tf2.gamemovement");

    if (!hConfig)
    {
        SetFailState("Failed to open gamedata/tf2.gamemovement.txt");
        return;
    }
    
    g_hProcessMovement = DHookCreateFromConf(hConfig, "CTFGameMovement::ProcessMovement");
    if (!DHookEnableDetour(g_hProcessMovement, false, CTFGameMovement_ProcessMovement))
    {
        delete g_hProcessMovement;
        delete hConfig;
        SetFailState("Failed to create \"CTFGameMovement::ProcessMovement\" detour");
    }
    
    cvarSpeedLimit = CreateConVar("sm_tf2_maxspeed", "520", "Override the game enforced maximum player speed.", FCVAR_SPONLY|FCVAR_NOTIFY);
    
    // NOP out the assignment of m_flMaxSpeed
    MemoryPatch("ProcessMovement", hConfig, {0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90}, 7);
    
    LoadTranslations("common.phrases");
    
    delete hConfig;
}

public void OnPluginEnd()
{
    DHookDisableDetour(g_hProcessMovement, false, CTFGameMovement_ProcessMovement);
}

public MRESReturn CTFGameMovement_ProcessMovement(Handle hParams)
{
    DHookSetParamObjectPtrVar(hParams, 2, 60, ObjectValueType_Float, cvarSpeedLimit.FloatValue);
    return MRES_ChangedHandled;
}

stock bool IsValidClient(int iClient) {
    return (1 <= iClient <= MaxClients) && IsClientInGame(iClient) && !(IsClientReplay(iClient) || IsClientSourceTV(iClient));
}

// Modified from Pelipoika
void MemoryPatch(const char[] patch, Handle &hConf, int[] PatchBytes, int iCount)
{
    Address iAddr = GameConfGetAddress(hConf, patch);
    if(iAddr == Address_Null)
    {
        LogError("Can't find %s address.", patch);
        return;
    }
    
    for (int i = 0; i < iCount; i++)
    {
        //int instruction = LoadFromAddress(iAddr + view_as<Address>(i), NumberType_Int8);
        //PrintToServer("%s 0x%x %i", patch, instruction, instruction);
        
        StoreToAddress(iAddr + view_as<Address>(i), PatchBytes[i], NumberType_Int8);
    }
    
    PrintToServer("APPLIED PATCH: %s", patch);
}
