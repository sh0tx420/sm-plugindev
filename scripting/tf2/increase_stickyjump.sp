#include <sourcemod>
#include <tf2_stocks>
#include <tf2items>

// #pragma newdecls required
#pragma semicolon 1

ConVar cvStickyLimit;

public Plugin myinfo = {
    name = "[TF2] Increase Sticky Jumper Bombs",
    author = "sh0tx",
    description = "Increases maximum sticky jumper bombs you can place.",
    version = "1.1",
    url = "sourcemod.net",
};

public void OnPluginStart() {
    cvStickyLimit = CreateConVar("mp_stickyjumper_limit", "3.0", "Max amount of sticky bombs for the Sticky Jumper", FCVAR_SPONLY, true, 2.0, true, 1000.0);
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, &Handle:hItem) {
    if (!IsClientInGame(client) || IsFakeClient(client))
        return Plugin_Continue;
    
    TFClassType class = TF2_GetPlayerClass(client);

    if (class != TFClass_DemoMan)
        return Plugin_Continue;
    
    // 265: Sticky Jumper - tf_weapon_pipebomblauncher
    // ted kaczynski
    if (iItemDefinitionIndex != 265)
        return Plugin_Continue;
    
    hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES|PRESERVE_ATTRIBUTES);

    TF2Items_SetClassname(hItem, classname);
    TF2Items_SetAttribute(hItem, 0, 88, GetConVarFloat(cvStickyLimit) - 2);
    TF2Items_SetNumAttributes(hItem, 1);

    TF2Items_GiveNamedItem(client, hItem);

    return Plugin_Changed;
}
