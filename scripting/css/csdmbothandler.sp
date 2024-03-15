#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#pragma newdecls required
#pragma semicolon 1


public Plugin myinfo =
{
	name = "CSDM Extended Bot Handling",
	author = "sh0tx",
	description = "Removes all bots when there are 2 or more people playing on the server",
	version = "1.0.0",
	url = "sourcemod.net"
};


public void OnClientPostAdminCheck(int client) {
	if (GetClientCount() >= 2) {
		ServerCommand("cssdm_bots_balance 0");
		ServerCommand("bot_quota 0");
	}
}

public void OnClientDisconnect(int client) {
	if (GetClientCount() < 2) {
		ServerCommand("cssdm_bots_balance 8");
		ServerCommand("bot_quota 8");
	}
}
