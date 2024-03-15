#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = "[ANY] Auto Mapcycle",
    author = "sh0tx",
    description = "Automatically generates mapcycle.txt from maps/ folder with the possibility of filtering out certain maps.",
    version = "1.0",
    url = "sourcemod.net",
};

char szMapcycleFile[64] = "cfg/mapcycle.txt";

public void OnPluginStart() {
    ConVar cvFilterMaps = CreateConVar("sm_automapcycle_filtermaps", "surf_", "Only add maps starting with this string to the mapcycle.\nSpecify 'none' if you don't want a filter. \nExample: bhop_", FCVAR_ARCHIVE|FCVAR_SPONLY);

    char szFilterMapsValue[16];

    File fiMapCycle = OpenFile(szMapcycleFile, "w");
    DirectoryListing dlMaps = OpenDirectory("maps");

    char szMap[64];
    FileType ftType;

    cvFilterMaps.GetString(szFilterMapsValue, sizeof(szFilterMapsValue));

    // Loop through all files in maps/
    while (dlMaps.GetNext(szMap, sizeof(szMap), ftType)) {
        if (ftType != FileType_File) continue;

        // filter specific maps
        if (!StrEqual(szFilterMapsValue, "none")) {
            // if str x starts with y then its position 0, otherwise it's another position or -1
            if (StrContains(szMap, szFilterMapsValue) != 0) continue;
        }

        // Write map name to mapcycle.txt file
        ReplaceString(szMap, sizeof(szMap), ".bsp", "", false);
        PrintToServer("Writing map %s to mapcycle.txt", szMap);
        fiMapCycle.WriteLine(szMap);
    }

    fiMapCycle.Flush();
    fiMapCycle.Close();
}
