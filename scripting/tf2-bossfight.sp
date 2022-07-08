#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_DESCRIPTION "A gamemode for TF2 where you fight bosses in the middle of an arena."
#define PLUGIN_VERSION "1.0.0"

#define MAX_BOSSES 64
#define MAX_ATTACKS 256
#define NO_BOSS -1

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>

enum struct Boss {
	char name[MAX_NAME_LENGTH];

	void Add(const char[] name) {
		strcopy(this.name, sizeof(Boss::name), name);
	}
}

Boss g_Boss[MAX_BOSSES];
int g_TotalBosses;

enum struct Data {
	int boss;
	int hostbot;

	void Init() {
		this.boss = NO_BOSS;
		this.hostbot = 0;
	}

	void AddHostBot() {
		this.KickHostBot();

		if (this.boss == NO_BOSS) {
			return;
		}

		this.hostbot = CreateFakeClient(g_Boss[this.boss].name);
		ChangeClientTeam(this.hostbot, 2);
		TF2_SetPlayerClass(this.hostbot, TFClass_Heavy);
		TF2_RespawnPlayer(this.hostbot);
		SetEntProp(this.hostbot, Prop_Data, "m_takedamage", 0, 1);
	}

	void KickHostBot() {
		if (this.hostbot > 0) {
			KickClient(this.hostbot, "");
		}

		this.hostbot = 0;
	}
}

Data g_Data;

enum struct Attacks {
	int boss;
	char name[MAX_NAME_LENGTH];

	void Add(int boss, const char[] name) {
		this.boss = boss;
		strcopy(this.name, sizeof(Attacks::name), name);
	}
}

Attacks g_Attacks[MAX_ATTACKS];
int g_TotalAttacks;

public Plugin myinfo = {
	name = "[TF2] Bossfight", 
	author = "Drixevel", 
	description = PLUGIN_DESCRIPTION, 
	version = PLUGIN_VERSION, 
	url = "https://scoutshideaway.tf/"
};

public void OnPluginStart() {

	g_Boss[g_TotalBosses++].Add("Heavy Skull");

	g_Attacks[g_TotalAttacks++].Add(0, "Rockets Barrage");
	g_Attacks[g_TotalAttacks++].Add(0, "Fear Induction");
	g_Attacks[g_TotalAttacks++].Add(0, "Saw Blades");

	g_Data.Init();
	g_Data.boss = 0;

	HookEvent("teamplay_round_start", Event_OnRoundStart);

	g_Data.AddHostBot();
}

public void OnPluginEnd() {
	g_Data.KickHostBot();
}

public void Event_OnRoundStart(Event event, const char[] name, bool dontBroadcast) {
	if (g_Data.boss == NO_BOSS) {
		return;
	}

	g_Data.AddHostBot();

	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || !IsPlayerAlive(i) || IsFakeClient(i)) {
			continue;
		}

		TF2_ChangeClientTeam(i, TFTeam_Blue);
		TF2_RespawnPlayer(i);
	}
}