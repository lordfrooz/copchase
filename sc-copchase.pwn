//----------------------------------------------------------
//
//  GMD: Muteo (2021-2022), akafrooz (2021-2022)
//  FSD: Muteo (2021-2022), akafrooz (2021-2022)
//
//----------------------------------------------------------

#pragma compat 1
#pragma dynamic 500000
#pragma warning disable 239
#pragma warning disable 214
#pragma warning disable 217
#pragma tabsize 0

#include <a_samp>
#include <Muteo\m_variables>
#include <a_http>
#undef MAX_PLAYERS
#define MAX_PLAYERS (200)
#define MAX_BAGLANTI 3

#include <a_mysql>
#include <memory>
#define YSI_NO_OPTIMISATION_MESSAGE
#define YSI_NO_MODE_CACHE
#define YSI_NO_VERSION_CHECK
#include <YSI_Data\y_iterate>
#include <SKY>
#include <PreviewModelDialog>
#include <Muteo\m_dialog>
#include <sscanf2>
#include <streamer>
#include <Muteo\m_checkpoint>
#include <zcmd>
#include <Pawn.RakNet>
#include <crashdetect>
#include <gvar>
#include <strlib>

native MuteoRandom(min, max);
native IsValidVehicle(vehicleid);
native gpci(playerid, serial[], len);
native WP_Hash(buffer[], len, const str[]);

new MySQL:mysqlM;
#define SQL_HOST    "127.0.0.1"
#define SQL_USER    "root"
#define SQL_PASS    ""
#define SQL_DB      "sccc"

#define SERVER_NAME      "[0.3.DL] South Central — Copchase"
#define SERVER_URL       "copchase.south-central.net"
#define SERVER_MAP       "San Andreas"
#define SERVER_VERSION   "vBETA"
#define SERVER_DIL       "Turkish/English"

#if !defined IsNaN
    #define IsNaN(%0) ((%0) != (%0))
#endif

#define fonksiyon%0(%1) forward%0(%1); public%0(%1)

#define SendServerMessage(%0,%1) \
	SendClientMessageEx(%0, 0xff6961FF, "Sunucu:{dadada} "%1)

#define SendSyntaxMessage(%0,%1) \
	SendClientMessageEx(%0, 0xA9C4E4FF, "Kullaným:{dadada} "%1)

#define SendErrorMessage(%0,%1) \
	SendClientMessageEx(%0, 0xff6961FF, "Hata:{dadada} "%1)

#define SendWarningMessage(%0,%1) \
	SendClientMessageEx(%0, 0xF1C40FFF, "Uyarý:{dadada} "%1)

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

// Distances
#define EMOTE_DISTANCE (25.0)
// Admins
#define SICIL_BAN  (1)
#define SICIL_JAIL (2)
#define SICIL_KICK (3)
// Errors
#define E_INVALID_ID "Geçersiz ID."
#define E_INVALID_ID_OR_DISTANCE "Geçersiz ID veya kiþi çok uzak."
#define E_INVALID_VALUE(%0,%1) "Geçersiz deðer. ("%0"-"%1")"
// Max
#define MAX_DIST 7
#define INV_ARRAY (15)
#define MAX_HASAR (15)
#define MAX_BARRICADES (250)
#define MAX_ENTRANCES (100)
#define MAX_REPORTS (20)

// Timing
#define INJURED_TIME (120)

#define GetDistanceBetweenPoints3D(%1,%2,%3,%4,%5,%6)	VectorSize((%1)-(%4),(%2)-(%5),(%3)-(%6))

#define COLOR_BLACK       (0x000000FF)
#define COLOR_CLIENT      (0xAAC4E5FF)
#define COLOR_WHITE       (0xdadadaFF)
#define COLOR_RED         (0xFF0000FF)
#define COLOR_CYAN        (0xC2A2DAAA)
#define COLOR_MDO         (0xC2A2DAAA)
#define COLOR_LIGHTRED    (0xff6961FF)
#define COLOR_LIGHTGREEN  (0x9ACD32FF)
#define COLOR_YELLOW      (0xFFFF00FF)
#define COLOR_GREY        (0xAFAFAFFF)
#define COLOR_GRAD2       (0xAFAFAFFF)
#define COLOR_HOSPITAL    (0xFF8282FF)
#define COLOR_PURPLE      (0xD0AEEBFF)
#define COLOR_LIGHTYELLOW (0xF5DEB3FF)
#define COLOR_DARKBLUE    (0x1394BFFF)
#define COLOR_ORANGE      (0xFFA500FF)
#define COLOR_LIME        (0x00FF00FF)
#define COLOR_GREEN       (0x33CC33FF)
#define COLOR_BREEZEADMIN (0x62869dFF)
#define COLOR_BLUE        (0x2641FEFF)
#define COLOR_MBLUE       (0x4DAFFFFF)
#define COLOR_FACTION     (0xBDF38BFF)
#define COLOR_AJANS	  	  (0x68FF30FF)
#define COLOR_RADIO       (0x8D8DFFFF)
#define COLOR_LIGHTBLUE   (0x007FFFFF)
#define COLOR_TURQUOISE   (0x40E0D0FF)
#define COLOR_SERVER      (0xFFFF90FF)
#define COLOR_DEPARTMENT  (0xF0CC00FF)
#define COLOR_ADMINCHAT   (0x33EE33FF)
#define DEFAULT_COLOR     (0xdadadaFF)

enum playerData
{
	pID,
	pForumID,
    pEXP,
	pLevel,
	pPlayingHour,
	pSkin,
    pSuspectSkin,
    pPoliceSkin,
	Float:pPos[4],
	Float:pCan,
	Float:pZirh,
	pAnimation,
    pInterior,
    pWorld,
	pSettings[8],
	pASettings[6],
	pLogged,
	pMinutes,
	pAdmin,
	pAdminName[24],
    pTester,
	pMoney,
	pIP[16],
    pReportCount,
	pVerifiedIP[16],
	pTimers[13],
    pGuns[13],
	pAmmo[13],
    pReportAbout[120],
	pReportMute,
	pFreezed,
	pAFKSure,
    pInGame,
    bool: pReport,
    bool: CBug,
    pPolice,
    pSuspect,
	STREAMER_TAG_3D_TEXT_LABEL:pNameTag
}

enum reportData {
	rExists,
	rType,
	rPlayer,
	rYetkili,
	rText[128 char]
};

enum entranceData {
	entranceID,
	entranceExists,
	entranceName[32],
	entranceIcon,
	entranceLocked,
	Float:entrancePos[4],
	Float:entranceInt[4],
	entranceInterior,
	entranceExterior,
	entranceExteriorVW,
	entranceWorld,
	entrancePickup,
	entranceMapIcon,
	STREAMER_TAG_3D_TEXT_LABEL:entranceText3D
};

enum carData {
	Float:carHealth,
	carModel,
	carLocked,
	carVehicle,
	carInterior,
	carWorld,
	carSiren,
	carSirenObject,
	carCallSignType,
	carCallSign[24],
	STREAMER_TAG_3D_TEXT_LABEL:carCallSignLabel
};

enum lobbyData {
    lobbyPlayerCount,
    lobbyPlayers[18]
}

new const p_WeaponSlots[] = {
	0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 10, 10, 10, 10, 10, 10, 8, 8, 8, 0, 0, 0, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 4, 6, 6, 7, 7, 7, 7, 8, 12, 9, 9, 9, 11, 11, 11
};

new engine, alarm, doors, lights, bonnet, boot, objective;
new global_hour, global_minute, Iterator:Araclar<MAX_VEHICLES>, Iterator:Binalar<MAX_ENTRANCES>, Iterator:Spikelar<MAX_BARRICADES>;
new PlayerData[MAX_PLAYERS][playerData];
new EntranceData[MAX_ENTRANCES][entranceData];
new CarData[MAX_VEHICLES][carData];
new ReportData[MAX_REPORTS][reportData];
new FlasorTimer[MAX_VEHICLES];
new FlasorDurum[MAX_VEHICLES];
new Flasor[MAX_VEHICLES];
new LobbyData[3][lobbyData];

main()
{
	print("\n---------------------------------------");
	print("South Central Police Pursuits - Coded Muteo and akafrooz");
	print("---------------------------------------\n");
}

AntiDeAMX()
{
	new a[][] =
	{
		"Unarmed (Fist)",
		"Brass K"
	};
	#pragma unused a
}

WasteDeAMXersTime()
{
    new b;
    #emit load.pri b
    #emit stor.pri b
}

public OnGameModeInit()
{
    AntiDeAMX();
    WasteDeAMXersTime();
    MySQL_Connect();
    SetTimer("SecondCheck", 1000, true);
    SetTimer("MinuteCheck", 60000, true);
    SetTimer("HourCheck", 3600000, true);
    ShowPlayerMarkers(0);
	ShowNameTags(0);
	SetNameTagDrawDistance(15.0);
	ManualVehicleEngineAndLights();
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	Streamer_VisibleItems(STREAMER_TYPE_OBJECT, 1500);
	new rcon[80];
    format(rcon, sizeof(rcon), "hostname %s", SERVER_NAME);
    SendRconCommand(rcon);
    format(rcon, sizeof(rcon), "weburl %s", SERVER_URL);
    SendRconCommand(rcon);
    format(rcon, sizeof(rcon), "mapname %s", SERVER_MAP);
    SendRconCommand(rcon);
    format(rcon, sizeof(rcon), "language %s", SERVER_DIL);
    SendRconCommand(rcon);
    SendRconCommand("rcon_password aY1C4BB47!@1sHere@!4nD4kaFr0ZAnDmU7E0113@");
    SetGameModeText(SERVER_VERSION);
	//TextDrawLoad();
    //new time = GetTickCount();
    //LoadEntrances(time);
	global_hour =
	global_minute = -1;
    SetWeather(1);
    LobbyData[0][lobbyPlayerCount] =
    LobbyData[1][lobbyPlayerCount] =
    LobbyData[2][lobbyPlayerCount] = 0;
    for(new i = 0; i < 18; i++)
    {
        LobbyData[0][lobbyPlayers][i] =
        LobbyData[1][lobbyPlayers][i] =
        LobbyData[2][lobbyPlayers][i] = -1;
    }
    //HTTP(0, HTTP_GET, "213.238.172.66/downloadserver.txt", "", "UpdateDownloadServer");
    return 1;
}

public OnGameModeExit()
{
	mysql_tquery(mysqlM, "UPDATE `hesaplar` SET `online` = '0' WHERE `online` = '1'");
    mysql_close(mysqlM);
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(!success) SendErrorMessage(playerid, "Geçersiz bir komut kullandýn {FF6347}/yardim {dadada}veya {FF6347}/sorusor{dadada} ile bilgi alabilirsin.");
    else Log_Write("logs/komut_log.txt", "[%s] %s komut kullandi. > %s", ReturnDate(), ReturnName(playerid, 0), cmdtext);
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(!PlayerData[playerid][pLogged]) return 0;
	if(PlayerData[playerid][pAdmin] == 0 && GetTickCount() < GetPVarInt(playerid, "anti_CommandFloodTime"))
	{
		new t_floodwarn = GetPVarInt(playerid, "anti_CommandFlood");
	    if(t_floodwarn > 4)
	    {
	        if(t_floodwarn < 6) SetPVarInt(playerid, "anti_CommandFloodTime", GetTickCount() + 3000), SetPVarInt(playerid, "anti_CommandFlood", 6);
	        SendServerMessage(playerid, "Spam yaptýðýn için 3 saniye boyunca susturuldun.");
	        return 0;
	 	}
	 	else SetPVarInt(playerid, "anti_CommandFlood", t_floodwarn + 1);
	}
	else DeletePVar(playerid, "anti_CommandFlood"), DeletePVar(playerid, "anti_CommandFloodTime");
	SetPVarInt(playerid, "anti_CommandFloodTime", GetTickCount() + 800);
    if(GetPVarInt(playerid, "t_JailTime") != 0 && GetPVarInt(playerid, "t_JailType") == 0 && PlayerData[playerid][pAdmin] == 0)
    {
        SendErrorMessage(playerid, "Jailde komut kullanamazsýn.");
        return 0;
    }
	return 1;
}

fonksiyon MySQL_Connect()
{
    print("MySQL baðlantýsý kuruluyor...");
    new MySQLOpt: option_id = mysql_init_options();
    mysql_set_option(option_id, AUTO_RECONNECT, true);
    mysqlM = mysql_connect(SQL_HOST, SQL_USER, SQL_PASS, SQL_DB, option_id);
    if(mysqlM == MYSQL_INVALID_HANDLE || mysql_errno(mysqlM) != 0)
    {
        print("MySQL baðlantýsý baþarýsýz!");
        SendRconCommand("exit");
        return 1;
    }
    mysql_set_charset("latin1", mysqlM);
    mysql_log(ERROR | WARNING);
    print("MySQL baðlantýsý kuruldu!");
    return 1;
}

public OnPlayerConnect(playerid)
{
	new t_name[MAX_PLAYER_NAME + 1];
	format(t_name, sizeof(t_name), ReturnName(playerid));
	if(strlen(t_name) > 24)
	{
		SendServerMessage(playerid, "Kullanýcý adýnýz çok uzun.");
		KickEx(playerid);
	}
	else if(IsPlayerBot(playerid))
	{
		SendServerMessage(playerid, "anti-cheat tarafýndan sunucudan atýldýnýz. (RakSAMP)");
		KickEx(playerid);
	}
	else
	{
	    M_DestroyDynamic3DTextLabel(PlayerData[playerid][pNameTag]);
	    PlayerData[playerid][pNameTag] = CreateDynamic3DTextLabel("", DEFAULT_COLOR, 0.0, 0.0, 0.1, 20.0, playerid, INVALID_VEHICLE_ID, 1, -1, -1);
		Streamer_SetFloatData(STREAMER_TYPE_3D_TEXT_LABEL, PlayerData[playerid][pNameTag], E_STREAMER_ATTACH_OFFSET_Z, 0.100);
        if(PlayerData[playerid][pAdmin]){
            SetPlayerColor(playerid, 0xffb633ff);
        }
        else {
            SetPlayerColor(playerid, 0xf0f0f0ff);
        }
	    PlayerData[playerid][pLevel] =
		PlayerData[playerid][pMoney] =
		PlayerData[playerid][pAdmin] =
		PlayerData[playerid][pTester] =
		PlayerData[playerid][pFreezed] =
	    PlayerData[playerid][pAFKSure] =
	    PlayerData[playerid][pMinutes] = 0;
		PlayerData[playerid][pAnimation] =
		PlayerData[playerid][pLogged] = false;
        GetPlayerIp(playerid, PlayerData[playerid][pIP], 16);
		new query[144];
		format(query, sizeof(query), "SELECT * FROM `bans` WHERE `IP` = '%s' OR `name` = '%s'", PlayerData[playerid][pIP], t_name);
		mysql_tquery(mysqlM, query, "BanKontrol", "d", playerid);
	}
 	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    M_DestroyDynamic3DTextLabel(PlayerData[playerid][pNameTag]);
    M_KillTimer(PlayerData[playerid][pTimers][0]);
	if(!PlayerData[playerid][pLogged]) return Muteo_OnPlayerDisconnect(playerid);
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);
    new string[512];
    for (new i = 0; i != MAX_REPORTS; i ++)
    {
        if(ReportData[i][rExists] && ReportData[i][rYetkili] == playerid) ReportData[i][rYetkili] = INVALID_PLAYER_ID;
    }
	format(string, sizeof(string), "UPDATE `hesaplar` SET `online` = '0' WHERE `ID` = '%d'", PlayerData[playerid][pID]);
	mysql_tquery(mysqlM, string);
	foreach (new i: Player)
	{
		//if(GetPVarInt(i, "t_SpectatePlayer") == playerid + 1) cmd_specoff(i, "\1");
	}
    SQL_SavePlayer(playerid, 0);
    PlayerData[playerid][pID] = 0;
    PlayerData[playerid][pLogged] = false;
    Muteo_OnPlayerDisconnect(playerid);
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(!PlayerData[playerid][pLogged]) return 1;
    if(GetPVarInt(playerid, "t_LastUpdate") == 999) DeletePVar(playerid, "t_AFK");
	SetPVarInt(playerid, "t_LastUpdate", GetTickCount());
	if(!IsPlayerPaused(playerid) && (GetPlayerAnimationIndex(playerid) == 747 || GetPlayerAnimationIndex(playerid) == 748)) M_ClearAnimations(playerid), M_LoadObjects(playerid, 2, 0, 0);
    return 1;
}


public OnPlayerSpawn(playerid)
{
    M_OnPlayerSpawn(playerid, 0);
	return 1;
}

fonksiyon M_OnPlayerSpawn(playerid, death)
{
	SetPVarInt(playerid, "t_LoadAccessories", 1);
	UpdateHealth(playerid);
    Streamer_Update(playerid);
	if(GetPVarInt(playerid, "t_PreloadAnimLibs") == 1)
	{
	    PreloadAnimLib(playerid,"AIRPORT");
		PreloadAnimLib(playerid,"Attractors");
		PreloadAnimLib(playerid,"BAR");
		PreloadAnimLib(playerid,"BASEBALL");
		PreloadAnimLib(playerid,"BD_FIRE");
		PreloadAnimLib(playerid,"benchpress");
        PreloadAnimLib(playerid,"BF_injection");
        PreloadAnimLib(playerid,"BIKED");
        PreloadAnimLib(playerid,"BIKEH");
        PreloadAnimLib(playerid,"BIKELEAP");
        PreloadAnimLib(playerid,"BIKES");
        PreloadAnimLib(playerid,"BIKEV");
        PreloadAnimLib(playerid,"BIKE_DBZ");
        PreloadAnimLib(playerid,"BMX");
        PreloadAnimLib(playerid,"BOX");
        PreloadAnimLib(playerid,"BSKTBALL");
        PreloadAnimLib(playerid,"BUDDY");
        PreloadAnimLib(playerid,"BUS");
        PreloadAnimLib(playerid,"CAMERA");
        PreloadAnimLib(playerid,"CAR");
        PreloadAnimLib(playerid,"CAR_CHAT");
        PreloadAnimLib(playerid,"CASINO");
        PreloadAnimLib(playerid,"CHAINSAW");
        PreloadAnimLib(playerid,"CHOPPA");
        PreloadAnimLib(playerid,"CLOTHES");
        PreloadAnimLib(playerid,"COACH");
        PreloadAnimLib(playerid,"COLT45");
        PreloadAnimLib(playerid,"COP_DVBYZ");
        PreloadAnimLib(playerid,"CRIB");
        PreloadAnimLib(playerid,"DAM_JUMP");
        PreloadAnimLib(playerid,"DANCING");
        PreloadAnimLib(playerid,"DILDO");
        PreloadAnimLib(playerid,"DODGE");
        PreloadAnimLib(playerid,"DOZER");
        PreloadAnimLib(playerid,"DRIVEBYS");
        PreloadAnimLib(playerid,"FAT");
        PreloadAnimLib(playerid,"FIGHT_B");
        PreloadAnimLib(playerid,"FIGHT_C");
        PreloadAnimLib(playerid,"FIGHT_D");
        PreloadAnimLib(playerid,"FIGHT_E");
        PreloadAnimLib(playerid,"FINALE");
        PreloadAnimLib(playerid,"FINALE2");
        PreloadAnimLib(playerid,"Flowers");
        PreloadAnimLib(playerid,"FOOD");
        PreloadAnimLib(playerid,"Freeweights");
        PreloadAnimLib(playerid,"GANGS");
        PreloadAnimLib(playerid,"GHANDS");
        PreloadAnimLib(playerid,"GHETTO_DB");
        PreloadAnimLib(playerid,"goggles");
        PreloadAnimLib(playerid,"GRAFFITI");
        PreloadAnimLib(playerid,"GRAVEYARD");
        PreloadAnimLib(playerid,"GRENADE");
        PreloadAnimLib(playerid,"GYMNASIUM");
        PreloadAnimLib(playerid,"HAIRCUTS");
        PreloadAnimLib(playerid,"HEIST9");
        PreloadAnimLib(playerid,"INT_HOUSE");
        PreloadAnimLib(playerid,"INT_OFFICE");
        PreloadAnimLib(playerid,"INT_SHOP");
        PreloadAnimLib(playerid,"JST_BUISNESS");
        PreloadAnimLib(playerid,"KART");
        PreloadAnimLib(playerid,"KISSING");
        PreloadAnimLib(playerid,"KNIFE");
        PreloadAnimLib(playerid,"LAPDAN1");
        PreloadAnimLib(playerid,"LAPDAN2");
        PreloadAnimLib(playerid,"LAPDAN3");
        PreloadAnimLib(playerid,"LOWRIDER");
        PreloadAnimLib(playerid,"MD_CHASE");
        PreloadAnimLib(playerid,"MEDIC");
        PreloadAnimLib(playerid,"MD_END");
        PreloadAnimLib(playerid,"MISC");
        PreloadAnimLib(playerid,"MTB");
        PreloadAnimLib(playerid,"MUSCULAR");
        PreloadAnimLib(playerid,"NEVADA");
        PreloadAnimLib(playerid,"ON_LOOKERS");
        PreloadAnimLib(playerid,"OTB");
        PreloadAnimLib(playerid,"PARACHUTE");
        PreloadAnimLib(playerid,"PARK");
        PreloadAnimLib(playerid,"PAULNMAC");
        PreloadAnimLib(playerid,"PED");
        PreloadAnimLib(playerid,"PLAYER_DVBYS");
        PreloadAnimLib(playerid,"PLAYIDLES");
        PreloadAnimLib(playerid,"POLICE");
        PreloadAnimLib(playerid,"POOL");
        PreloadAnimLib(playerid,"POOR");
        PreloadAnimLib(playerid,"PYTHON");
        PreloadAnimLib(playerid,"QUAD");
        PreloadAnimLib(playerid,"QUAD_DBZ");
        PreloadAnimLib(playerid,"RIFLE");
        PreloadAnimLib(playerid,"RIOT");
        PreloadAnimLib(playerid,"ROB_BANK");
        PreloadAnimLib(playerid,"ROCKET");
        PreloadAnimLib(playerid,"RUSTLER");
        PreloadAnimLib(playerid,"RYDER");
        PreloadAnimLib(playerid,"SCRATCHING");
        PreloadAnimLib(playerid,"SHAMAL");
        PreloadAnimLib(playerid,"SHOTGUN");
        PreloadAnimLib(playerid,"SILENCED");
        PreloadAnimLib(playerid,"SKATE");
        PreloadAnimLib(playerid,"SPRAYCAN");
        PreloadAnimLib(playerid,"STRIP");
        PreloadAnimLib(playerid,"SUNBATHE");
        PreloadAnimLib(playerid,"SWAT");
        PreloadAnimLib(playerid,"SWEET");
        PreloadAnimLib(playerid,"SWIM");
        PreloadAnimLib(playerid,"SWORD");
        PreloadAnimLib(playerid,"TANK");
        PreloadAnimLib(playerid,"TATTOOS");
        PreloadAnimLib(playerid,"TEC");
        PreloadAnimLib(playerid,"TRAIN");
        PreloadAnimLib(playerid,"TRUCK");
        PreloadAnimLib(playerid,"UZI");
        PreloadAnimLib(playerid,"VAN");
        PreloadAnimLib(playerid,"VENDING");
        PreloadAnimLib(playerid,"VORTEX");
        PreloadAnimLib(playerid,"WAYFARER");
        PreloadAnimLib(playerid,"WEAPONS");
        PreloadAnimLib(playerid,"WUZI");
        PreloadAnimLib(playerid,"SNM");
        PreloadAnimLib(playerid,"BLOWJOBZ");
        PreloadAnimLib(playerid,"SEX");
   		PreloadAnimLib(playerid,"BOMBER");
   		PreloadAnimLib(playerid,"RAPPING");
    	PreloadAnimLib(playerid,"SHOP");
   		PreloadAnimLib(playerid,"BEACH");
   		PreloadAnimLib(playerid,"SMOKING");
    	PreloadAnimLib(playerid,"FOOD");
    	PreloadAnimLib(playerid,"ON_LOOKERS");
    	PreloadAnimLib(playerid,"DEALER");
		PreloadAnimLib(playerid,"CRACK");
		PreloadAnimLib(playerid,"CARRY");
		PreloadAnimLib(playerid,"COP_AMBIENT");
		PreloadAnimLib(playerid,"PARK");
		PreloadAnimLib(playerid,"INT_HOUSE");
		PreloadAnimLib(playerid,"FOOD");
		DeletePVar(playerid, "t_PreloadAnimLibs");
	}
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL, 0);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 0);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 0);
    Streamer_ToggleIdleUpdate(playerid, true);
	SetCameraBehindPlayer(playerid);
    return 1;
}

forward Flas(aracid);
public Flas(aracid)
{
	if(Flasor[aracid] == 1)
	{
 		new panelsx, doorsx, lightsx, tiresx;
	    if(FlasorDurum[aracid] == 1)
	    {
	        GetVehicleDamageStatus(aracid, panelsx, doorsx, lightsx, tiresx);
	        UpdateVehicleDamageStatus(aracid, panelsx, doorsx, 4, tiresx);
	        FlasorDurum[aracid] = 0;
	    }
	    else
	    {
	        GetVehicleDamageStatus(aracid, panelsx, doorsx, lightsx, tiresx);
	        UpdateVehicleDamageStatus(aracid, panelsx, doorsx, 1, tiresx);
	        FlasorDurum[aracid] = 1;
	    }
	}
	return 1;
}

PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0,1);
}

public OnPlayerDeath(playerid, killerid, reason)
{
	M_OnPlayerDeath(playerid, killerid, reason, 1);
	return 1;
}

fonksiyon M_OnPlayerDeath(playerid, killerid, reason, death)
{
	new vehicleid = GetPlayerVehicleID(playerid), seatid = GetPVarInt(playerid, "t_LastSeatID");
    if(death == 1)
    {
        GetPlayerPos(playerid, PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2]), GetPlayerFacingAngle(playerid, PlayerData[playerid][pPos][3]);
    	SetSpawnInfo(playerid, 0, GetPlayerSkinEx(playerid), PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2] - 0.5, PlayerData[playerid][pPos][3], 0, 0, 0, 0, 0, 0);
        M_SetPlayerPos(playerid, PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2]);
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    }
	M_ClearAnimations(playerid);
	M_OnPlayerSpawn(playerid, death);
	SetPlayerArmedWeapon(playerid, 0);
	CanDegistir(playerid, 100.0);
    ZirhDegistir(playerid, 0.0);
	if(GetPVarInt(playerid, "t_Injured") == 0)
	{
		if(vehicleid == 0) ApplyAnimation(playerid, "WUZI", "CS_Dead_Guy", 4.1, 0, 1, 1, 1, 0, 1);
        SetPVarInt(playerid, "t_Injured", 1);
		SendClientMessageEx(playerid, COLOR_LIGHTRED, "(( Yaralandýn, birinin sana ilkyardým yapmasýný bekle. ))");
		//M_InfoTextForPlayer(playerid, "~b~Yaralandin.", 2);
	}
	else if(killerid != INVALID_PLAYER_ID && 22 <= reason <= 38)
	{
		if(vehicleid == 0) ApplyAnimation(playerid, "WUZI", "CS_Dead_Guy", 4.1, 0, 1, 1, 1, 0, 1);
        SetPVarInt(playerid, "t_Injured", 2);
		SendClientMessageEx(playerid, COLOR_YELLOW, "** %s tarafýndan öldürüldün 3 saniye sonra lobiye aktarýlacaksýn.", ReturnName(killerid, 1));
	}
	if(killerid != INVALID_PLAYER_ID && GetPVarInt(playerid, "t_Injured") == 1 && killerid != playerid) SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s, %s kiþisini yaraladý.", ReturnName(killerid, 1), ReturnName(playerid, 1));
	if(vehicleid != 0 && IsEngineVehicle(vehicleid)) M_PutPlayerInVehicle(playerid, vehicleid, seatid, 500, 1);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    M_TogglePlayerSpectating(playerid, 1);
    SetPlayerVirtualWorld(playerid, playerid + 1000);
	return 1;
}

fonksiyon BanKontrol(playerid)
{
	if(!M_IsPlayerConnected(playerid)) return 1;
	if(!cache_num_rows())
	{
		new query[78];
	    format(query, sizeof(query), "SELECT * FROM `hesaplar` WHERE `isim` = '%s'", SQL_ReturnEscaped(ReturnName(playerid)));
	    mysql_tquery(mysqlM, query, "HesapKontrol", "d", playerid);
	}
	else
	{
		new opendate, name[MAX_PLAYER_NAME + 1], reason[32], date[32];
		cache_get_value_name_int(0, "opendate", opendate);
		cache_get_value_name(0, "reason", reason);
		cache_get_value_name(0, "date", date);
        cache_get_value_name(0, "admin", name);
		new t_str[64];
		if(opendate == 0) format(t_str, sizeof(t_str), "{FF6347}sýnýrsýz {dadada}yasaklandýn.");
		else
        {
            opendate = (opendate - gettime()) / 86400;
            format(t_str, sizeof(t_str), "yasaklandýn.\nYasaðýn {FF6347}%d {dadada}gün sonra bitiyor.", opendate);
        }
		Dialog_Show(playerid, BanBox, DIALOG_STYLE_MSGBOX, "{dadada}Yasaklanma Bilgisi", "{dadada}Sunucudan {FF6347}%s {dadada}tarafýndan {FF6347}%s {dadada}tarihinde {FF6347}%s {dadada}sebebiyle %s", "Tamam", "", name, date, reason, t_str);
		KickEx(playerid, 300);
	}
	return 1;
}

fonksiyon HesapKontrol(playerid)
{
	if(!M_IsPlayerConnected(playerid)) return 1;
	new rows;
	cache_get_row_count(rows);
    if(!rows)
    {
		Dialog_Show(playerid, KayitOl, DIALOG_STYLE_PASSWORD, "{FF6347}South Central {dadada}- Kayýt Ol", "{dadada}Hoþ geldin, veritabanýnda bir hesabýn bulunmuyor.\nHemen þifreni gir ve hesabýný oluþtur:", "Kayýt Ol", "Çýkýþ");
	}
	else
	{
		Dialog_Show(playerid, GirisYap, DIALOG_STYLE_PASSWORD, "{FF6347}South Central {dadada}- Giriþ", "{dadada}Hoþ geldin, devam edebilmek için 120 saniye içinde þifreni gir:", "Giriþ", "Çýkýþ");
	}
    return 1;
}

Dialog:KayitOl(playerid, response, listitem, inputtext[])
{
	if (!response) return Kick(playerid);
	else if (m_isnull(inputtext) || strlen(inputtext) < 4) return Dialog_Show(playerid, KayitOl, DIALOG_STYLE_PASSWORD, "{FF6347}Þifre en az 4 karakter olmalýdýr.\n{FF6347}South Central {dadada}- Kayýt Ol", "{dadada}Hoþ geldin, veritabanýnda bir hesabýn bulunmuyor.\nHemen þifreni gir ve hesabýný oluþtur:", "Kayýt Ol", "Çýkýþ");
	else
	{
        new query[512], buffer[129];
	    WP_Hash(buffer, sizeof(buffer), inputtext);
    	format(query, sizeof(query), "INSERT INTO `hesaplar` (`isim`, `Sifre`, `CreateTime`) VALUES('%s', '%s', '%s')", SQL_ReturnEscaped(ReturnName(playerid)), buffer, ReturnDate());
    	mysql_tquery(mysqlM, query, "AutoLogin", "ds", playerid, ReturnIP(playerid));
	}
	return 1;
}

fonksiyon AutoLogin(playerid, ip[])
{
	if(!M_IsPlayerConnected(playerid)) return 1;
    if(strcmp(ReturnIP(playerid), ip) != 0) return 1;
    new query[86];
    format(query, sizeof(query), "SELECT * FROM `hesaplar` WHERE `isim` = '%s'", SQL_ReturnEscaped(ReturnName(playerid)));
    mysql_tquery(mysqlM, query, "HesapYukle", "ds", playerid, ReturnIP(playerid));
    return 1;
}

Dialog:GirisYap(playerid, response, listitem, inputtext[])
{
	if(response)
	{
        new query[300], sifre[129];
		WP_Hash(sifre, sizeof(sifre), inputtext);
	    format(query, sizeof(query), "SELECT * FROM `hesaplar` WHERE `isim` = '%s' AND `Sifre` = '%s'", SQL_ReturnEscaped(ReturnName(playerid)), sifre);
	    mysql_tquery(mysqlM, query, "HesapKontrol2", "ds", playerid, ReturnIP(playerid));
	}
	else KickEx(playerid);
	return 1;
}

fonksiyon HesapKontrol2(playerid, ip[])
{
	if(!M_IsPlayerConnected(playerid)) return 1;
    if(strcmp(ReturnIP(playerid), ip) != 0) return 1;
	new rows = cache_num_rows();
    if(!rows)
    {
		new count = GetPVarInt(playerid, "t_WrongPassword") + 1;
        SendErrorMessage(playerid, "Yanlýþ þifre girdiniz! (%d/3)", count);
		if(count > 2)
        {
            SendErrorMessage(playerid, "Çok fazla hatalý þifre girdiðiniz için atýldýnýz.");
            KickEx(playerid);
        }
		Dialog_Show(playerid, GirisYap, DIALOG_STYLE_PASSWORD, "{FF6347}South Central {dadada}- Giriþ", "{dadada}Hoþ geldin, devam edebilmek için 120 saniye içinde þifreni gir:", "Giriþ", "Çýkýþ");
		SetPVarInt(playerid, "t_WrongPassword", count);
	}
	else
	{
		DeletePVar(playerid, "t_WrongPassword");
        new query[86];
        format(query, sizeof(query), "SELECT * FROM `hesaplar` WHERE `isim` = '%s'", SQL_ReturnEscaped(ReturnName(playerid)));
		mysql_tquery(mysqlM, query, "HesapYukle", "ds", playerid, ReturnIP(playerid));
	}
    return 1;
}

fonksiyon HesapYukle(playerid, ip[])
{
	if(!M_IsPlayerConnected(playerid)) return 1;
    if(strcmp(ReturnIP(playerid), ip) != 0) return 1;
    if(cache_num_rows())
    {
		for (new i = 0; i < 25; i ++) SendClientMessage(playerid, -1, "");
        new string[512];
		SendServerMessage(playerid, "%s hoþ geldin!", ReturnName(playerid));
        if (PlayerData[playerid][pTester] > 0)
        {
            SendServerMessage(playerid, "Tester olarak giriþ yaptýnýz.");
        }
        if (PlayerData[playerid][pAdmin] > 0)
        {
            SendServerMessage(playerid, "Seviye %d admin olarak giriþ yaptýn.", PlayerData[playerid][pAdmin]);
            SendAdminAlert(1, playerid, "%s adlý yönetici %d seviye olarak giriþ yaptý.", ReturnName(playerid, 0), PlayerData[playerid][pAdmin]);
        }
        cache_get_value_name_int(0, "ID", PlayerData[playerid][pID]);
        if(PlayerData[playerid][pID] == 0)
        {
            KickEx(playerid);
            return 0;
        }
        //TextDrawHideForPlayer(playerid, loginscreen);
        //StopAudioStreamForPlayer(playerid);
        cache_get_value_name_float(0, "PosX", PlayerData[playerid][pPos][0]);
        cache_get_value_name_float(0, "PosY", PlayerData[playerid][pPos][1]);
        cache_get_value_name_float(0, "PosZ", PlayerData[playerid][pPos][2]);
        cache_get_value_name_float(0, "PosA", PlayerData[playerid][pPos][3]);
        cache_get_value_name_int(0, "VW", PlayerData[playerid][pWorld]);
        cache_get_value_name_int(0, "INTERIOR", PlayerData[playerid][pInterior]);
        cache_get_value_name(0, "AdminName", PlayerData[playerid][pAdminName]);
        cache_get_value_name_int(0, "Seviye", PlayerData[playerid][pLevel]);
		cache_get_value_name_int(0, "PlayingHour", PlayerData[playerid][pPlayingHour]);
        cache_get_value_name_int(0, "Skin", PlayerData[playerid][pSkin]);
        cache_get_value_name_int(0, "PoliceSkin", PlayerData[playerid][pPoliceSkin]);
        cache_get_value_name_int(0, "SuspectSkin", PlayerData[playerid][pSuspectSkin]);
        cache_get_value_name_int(0, "Admin", PlayerData[playerid][pAdmin]);
		cache_get_value_name_int(0, "Tester", PlayerData[playerid][pTester]);
        cache_get_value_name_int(0, "Para", PlayerData[playerid][pMoney]);
		if(string[0] != 0) SetPVarInt(playerid, "t_Cuffed", string[0]);
		cache_get_value_name_int(0, "JailTime", string[0]);
		if(string[0] != 0) SetPVarInt(playerid, "t_JailTime", string[0]);

		cache_get_value_name(0, "Settings", string);
		sscanf(string, "p<|>iiiiiiii", PlayerData[playerid][pSettings][0], PlayerData[playerid][pSettings][1], PlayerData[playerid][pSettings][2], PlayerData[playerid][pSettings][3], PlayerData[playerid][pSettings][4], PlayerData[playerid][pSettings][5], PlayerData[playerid][pSettings][6], PlayerData[playerid][pSettings][7]);

		cache_get_value_name(0, "ASettings", string);
		sscanf(string, "p<|>iiiiii", PlayerData[playerid][pASettings][0], PlayerData[playerid][pASettings][1], PlayerData[playerid][pASettings][2], PlayerData[playerid][pASettings][3], PlayerData[playerid][pASettings][4], PlayerData[playerid][pASettings][5]);

        cache_get_value_name(0, "ASlot", string);
		sscanf(string, "p<|>iiiiiiiiiiiiiii", string[0], string[1], string[2], string[3], string[4], string[5], string[6], string[7], string[8], string[9], string[10], string[11], string[12], string[13], string[14]);
		if(string[0] != 0) SetPVarInt(playerid, "a_M0", string[0]), SetPVarInt(playerid, "a_B0", string[1]), SetPVarInt(playerid, "a_T0", string[2]);
		if(string[3] != 0) SetPVarInt(playerid, "a_M1", string[3]), SetPVarInt(playerid, "a_B1", string[4]), SetPVarInt(playerid, "a_T1", string[5]);
		if(string[6] != 0) SetPVarInt(playerid, "a_M2", string[6]), SetPVarInt(playerid, "a_B2", string[7]), SetPVarInt(playerid, "a_T2", string[8]);
		if(string[9] != 0) SetPVarInt(playerid, "a_M3", string[9]), SetPVarInt(playerid, "a_B3", string[10]), SetPVarInt(playerid, "a_T3", string[11]);
		if(string[12] != 0) SetPVarInt(playerid, "a_M4", string[12]), SetPVarInt(playerid, "a_B4", string[13]), SetPVarInt(playerid, "a_T4", string[14]);

        cache_get_value_name(0, "ASlot2", string);
		sscanf(string, "p<|>iiiiiiiiiiiiiii", string[0], string[1], string[2], string[3], string[4], string[5], string[6], string[7], string[8], string[9], string[10], string[11], string[12], string[13], string[14]);
		if(string[0] != 0) SetPVarInt(playerid, "a_M5", string[0]), SetPVarInt(playerid, "a_B5", string[1]), SetPVarInt(playerid, "a_T5", string[2]);
		if(string[3] != 0) SetPVarInt(playerid, "a_M6", string[3]), SetPVarInt(playerid, "a_B6", string[4]), SetPVarInt(playerid, "a_T6", string[5]);
		if(string[6] != 0) SetPVarInt(playerid, "a_M7", string[6]), SetPVarInt(playerid, "a_B7", string[7]), SetPVarInt(playerid, "a_T7", string[8]);
		if(string[9] != 0) SetPVarInt(playerid, "a_M8", string[9]), SetPVarInt(playerid, "a_B8", string[10]), SetPVarInt(playerid, "a_T8", string[11]);
		if(string[12] != 0) SetPVarInt(playerid, "a_M9", string[12]), SetPVarInt(playerid, "a_B9", string[13]), SetPVarInt(playerid, "a_T9", string[14]);

        new Float:t_Pos[12];
        cache_get_value_name(0, "ASlotPos", string);
		sscanf(string, "p<|>fffffffff", t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
		SetPVarFloat(playerid, "a_P00", t_Pos[0]), SetPVarFloat(playerid, "a_P01", t_Pos[1]), SetPVarFloat(playerid, "a_P02", t_Pos[2]), SetPVarFloat(playerid, "a_P03", t_Pos[3]), SetPVarFloat(playerid, "a_P04", t_Pos[4]), SetPVarFloat(playerid, "a_P05", t_Pos[5]), SetPVarFloat(playerid, "a_P06", t_Pos[6]), SetPVarFloat(playerid, "a_P07", t_Pos[7]), SetPVarFloat(playerid, "a_P08", t_Pos[8]),
		sscanf(string, "p<|>ffffffffffffffffff", t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
		SetPVarFloat(playerid, "a_P10", t_Pos[0]), SetPVarFloat(playerid, "a_P11", t_Pos[1]), SetPVarFloat(playerid, "a_P12", t_Pos[2]), SetPVarFloat(playerid, "a_P13", t_Pos[3]), SetPVarFloat(playerid, "a_P14", t_Pos[4]), SetPVarFloat(playerid, "a_P15", t_Pos[5]), SetPVarFloat(playerid, "a_P16", t_Pos[6]), SetPVarFloat(playerid, "a_P17", t_Pos[7]), SetPVarFloat(playerid, "a_P18", t_Pos[8]),
		sscanf(string, "p<|>fffffffffffffffffffffffffff", t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
		SetPVarFloat(playerid, "a_P20", t_Pos[0]), SetPVarFloat(playerid, "a_P21", t_Pos[1]), SetPVarFloat(playerid, "a_P22", t_Pos[2]), SetPVarFloat(playerid, "a_P23", t_Pos[3]), SetPVarFloat(playerid, "a_P24", t_Pos[4]), SetPVarFloat(playerid, "a_P25", t_Pos[5]), SetPVarFloat(playerid, "a_P26", t_Pos[6]), SetPVarFloat(playerid, "a_P27", t_Pos[7]), SetPVarFloat(playerid, "a_P28", t_Pos[8]),
		sscanf(string, "p<|>ffffffffffffffffffffffffffffffffffff", t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
		SetPVarFloat(playerid, "a_P30", t_Pos[0]), SetPVarFloat(playerid, "a_P31", t_Pos[1]), SetPVarFloat(playerid, "a_P32", t_Pos[2]), SetPVarFloat(playerid, "a_P33", t_Pos[3]), SetPVarFloat(playerid, "a_P34", t_Pos[4]), SetPVarFloat(playerid, "a_P35", t_Pos[5]), SetPVarFloat(playerid, "a_P36", t_Pos[6]), SetPVarFloat(playerid, "a_P37", t_Pos[7]), SetPVarFloat(playerid, "a_P38", t_Pos[8]),
		sscanf(string, "p<|>fffffffffffffffffffffffffffffffffffffffffffff", t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
		SetPVarFloat(playerid, "a_P40", t_Pos[0]), SetPVarFloat(playerid, "a_P41", t_Pos[1]), SetPVarFloat(playerid, "a_P42", t_Pos[2]), SetPVarFloat(playerid, "a_P43", t_Pos[3]), SetPVarFloat(playerid, "a_P44", t_Pos[4]), SetPVarFloat(playerid, "a_P45", t_Pos[5]), SetPVarFloat(playerid, "a_P46", t_Pos[6]), SetPVarFloat(playerid, "a_P47", t_Pos[7]), SetPVarFloat(playerid, "a_P48", t_Pos[8]);
        cache_get_value_name(0, "ASlot2Pos", string);
        sscanf(string, "p<|>fffffffff", t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
		SetPVarFloat(playerid, "a_P50", t_Pos[0]), SetPVarFloat(playerid, "a_P51", t_Pos[1]), SetPVarFloat(playerid, "a_P52", t_Pos[2]), SetPVarFloat(playerid, "a_P53", t_Pos[3]), SetPVarFloat(playerid, "a_P54", t_Pos[4]), SetPVarFloat(playerid, "a_P55", t_Pos[5]), SetPVarFloat(playerid, "a_P56", t_Pos[6]), SetPVarFloat(playerid, "a_P57", t_Pos[7]), SetPVarFloat(playerid, "a_P58", t_Pos[8]),
		sscanf(string, "p<|>ffffffffffffffffff", t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
		SetPVarFloat(playerid, "a_P60", t_Pos[0]), SetPVarFloat(playerid, "a_P61", t_Pos[1]), SetPVarFloat(playerid, "a_P62", t_Pos[2]), SetPVarFloat(playerid, "a_P63", t_Pos[3]), SetPVarFloat(playerid, "a_P64", t_Pos[4]), SetPVarFloat(playerid, "a_P65", t_Pos[5]), SetPVarFloat(playerid, "a_P66", t_Pos[6]), SetPVarFloat(playerid, "a_P67", t_Pos[7]), SetPVarFloat(playerid, "a_P68", t_Pos[8]),
		sscanf(string, "p<|>fffffffffffffffffffffffffff", t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
		SetPVarFloat(playerid, "a_P70", t_Pos[0]), SetPVarFloat(playerid, "a_P71", t_Pos[1]), SetPVarFloat(playerid, "a_P72", t_Pos[2]), SetPVarFloat(playerid, "a_P73", t_Pos[3]), SetPVarFloat(playerid, "a_P74", t_Pos[4]), SetPVarFloat(playerid, "a_P75", t_Pos[5]), SetPVarFloat(playerid, "a_P76", t_Pos[6]), SetPVarFloat(playerid, "a_P77", t_Pos[7]), SetPVarFloat(playerid, "a_P78", t_Pos[8]),
		sscanf(string, "p<|>ffffffffffffffffffffffffffffffffffff", t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
		SetPVarFloat(playerid, "a_P80", t_Pos[0]), SetPVarFloat(playerid, "a_P81", t_Pos[1]), SetPVarFloat(playerid, "a_P82", t_Pos[2]), SetPVarFloat(playerid, "a_P83", t_Pos[3]), SetPVarFloat(playerid, "a_P84", t_Pos[4]), SetPVarFloat(playerid, "a_P85", t_Pos[5]), SetPVarFloat(playerid, "a_P86", t_Pos[6]), SetPVarFloat(playerid, "a_P87", t_Pos[7]), SetPVarFloat(playerid, "a_P88", t_Pos[8]),
		sscanf(string, "p<|>fffffffffffffffffffffffffffffffffffffffffffff", t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
		SetPVarFloat(playerid, "a_P90", t_Pos[0]), SetPVarFloat(playerid, "a_P91", t_Pos[1]), SetPVarFloat(playerid, "a_P92", t_Pos[2]), SetPVarFloat(playerid, "a_P93", t_Pos[3]), SetPVarFloat(playerid, "a_P94", t_Pos[4]), SetPVarFloat(playerid, "a_P95", t_Pos[5]), SetPVarFloat(playerid, "a_P96", t_Pos[6]), SetPVarFloat(playerid, "a_P97", t_Pos[7]), SetPVarFloat(playerid, "a_P98", t_Pos[8]);
        cache_get_value_name(0, "WeaponPos", string);
        sscanf(string, "p<|>ffffffffffff", t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8], t_Pos[9], t_Pos[10], t_Pos[11]);
        SetPVarFloat(playerid, "t_W10", t_Pos[0]), SetPVarFloat(playerid, "t_W11", t_Pos[1]), SetPVarFloat(playerid, "t_W12", t_Pos[2]), SetPVarFloat(playerid, "t_W13", t_Pos[3]), SetPVarFloat(playerid, "t_W14", t_Pos[4]), SetPVarFloat(playerid, "t_W15", t_Pos[5]);
        SetPVarFloat(playerid, "t_W20", t_Pos[6]), SetPVarFloat(playerid, "t_W21", t_Pos[7]), SetPVarFloat(playerid, "t_W22", t_Pos[8]), SetPVarFloat(playerid, "t_W23", t_Pos[9]), SetPVarFloat(playerid, "t_W24", t_Pos[10]), SetPVarFloat(playerid, "t_W25", t_Pos[11]);
		format(string, sizeof(string), "UPDATE `hesaplar` SET `online` = '1', `LastLogin` = '%s', `LastIP` = '%s' WHERE `ID` = '%d'", ReturnDate(), ReturnIP(playerid), PlayerData[playerid][pID]);
		mysql_tquery(mysqlM, string);
        SetPVarInt(playerid, "t_PreloadAnimLibs", 1);
		//PlayerTextDrawLoad(playerid), RemoveBuilds(playerid);
        format(string, sizeof(string), "SELECT null FROM `bildirimler` WHERE `ID` = '%d' AND `readed` = '0'", PlayerData[playerid][pID]);
    	new Cache:t_cache = mysql_query(mysqlM, string);
        if(cache_num_rows() > 0) SendClientMessageEx(playerid, COLOR_YELLOW, "** Okunmamýþ %d adet bildiriminiz var. (/bildirimler)", cache_num_rows()), cache_delete(t_cache);
		SpawnTimer(playerid);
    }
	else KickEx(playerid);
    return 1;
}

fonksiyon SpawnTimer(playerid)
{
    if(!M_IsPlayerConnected(playerid)) return 1;
    PlayerData[playerid][pLogged] = true;
    PlayerData[playerid][pInGame] = false;
    new skin = PlayerData[playerid][pSkin];
    new t_lobby = -1;
    if(LobbyData[0][lobbyPlayerCount] < 18) t_lobby = 0;
    else if(LobbyData[1][lobbyPlayerCount] < 18) t_lobby = 1;
    else if(LobbyData[2][lobbyPlayerCount] < 18) t_lobby = 2;
    if(t_lobby == -1)
    {
        SendErrorMessage(playerid, "Boþ lobi bulunmadýðý için sunucudan atýldýnýz.");
        KickEx(playerid);
        return 1;
    }
    LobbyData[t_lobby][lobbyPlayerCount]++;
    new t_temp = 0;
    for(new i = 0; i < 18; i++) if(LobbyData[t_lobby][lobbyPlayers][i] == -1)
    {
        t_temp = 1;
        LobbyData[t_lobby][lobbyPlayers][i] = playerid;
        break;
    }
    if(t_temp == 0)
    {
        SendErrorMessage(playerid, "Boþ lobi bulunmadýðý için sunucudan atýldýnýz. (#2)");
        KickEx(playerid);
        return 1;
    }
    SendServerMessage(playerid, "Lobiye aktarýldýnýz. (Lobi %d, Kapasite %d/18)", t_lobby + 1, LobbyData[t_lobby][lobbyPlayerCount]);
    new Float:t_Pos[3];
    switch(t_lobby)
    {
        case 0:
        {
            t_Pos[0] = 1710.433715;
            t_Pos[1] = -1669.379272;
            t_Pos[2] = 20.225049;
            t_temp = 18;
        }
    }
    M_SetPlayerInterior(playerid, t_temp);
    M_SetPlayerVirtualWorld(playerid, t_lobby);
    SetSpawnInfo(playerid, 0, skin, 1, t_Pos[0], t_Pos[1], t_Pos[2], 0.0, 0, 0, 0, 0, 0, 0);
	SetPVarInt(playerid, "t_Anticheat", 1);
	M_TogglePlayerSpectating(playerid, 0);
	SpawnPlayer(playerid);
    M_OnPlayerSpawn(playerid, 0);
	M_SetPlayerPos(playerid, t_Pos[0], t_Pos[1], t_Pos[2]), SetPlayerFacingAngle(playerid, 0.0);
	SetPVarInt(playerid, "t_LoadAccessories", 1);
	M_LoadObjects(playerid);
	UpdateHealth(playerid);
	if(global_hour != -1) SetPlayerTime(playerid, global_hour, global_minute);
	else
	{
		new time[3];
	 	gettime(time[0], time[1], time[2]);
        if(time[0] >= 18 && time[0] <= 23) SetPlayerTime(playerid, time[0] + 2, time[1]);
        else SetPlayerTime(playerid, time[0], time[1]);
	}
	if(GetPVarInt(playerid, "t_JailTime") != 0)
	{
		new t_str[32];
		format(t_str, sizeof(t_str), "~r~HAPIS:~w~ %ddk.", GetPVarInt(playerid, "t_JailTime"));
		//PlayerTextDrawSetString(playerid, hapistext[playerid], t_str);
		//PlayerTextDrawShow(playerid, hapistext[playerid]);
		if(GetPVarInt(playerid, "t_JailType") == 0)
		{
			M_SetPlayerPos(playerid, 2307.8108,576.3619,106.5366), SetPlayerFacingAngle(playerid, 260.0);
		    M_SetPlayerInterior(playerid, 3);
			M_SetPlayerVirtualWorld(playerid, (playerid + 100));
		}
	}
	return 1;
}

ReturnName(playerid, replace = 0)
{
	static name[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, name, sizeof(name));
	if(replace) for (new i = 0, l = strlen(name); i < l; i ++) if (name[i] == '_') name[i] = ' ';
	return name;
}

Report_GetCount(playerid)
{
	new count;
    for (new i = 0; i != MAX_REPORTS; i ++) if(ReportData[i][rExists] && ReportData[i][rPlayer] == playerid) count++;
	return count;
}

Report_Clear(playerid)
{
    for (new i = 0; i != MAX_REPORTS; i ++) if(ReportData[i][rExists] && ReportData[i][rPlayer] == playerid) Report_Remove(i);
	return 1;
}

Report_Add(playerid, const text[], type = 1)
{
	for (new i = 0; i != MAX_REPORTS; i ++) if(!ReportData[i][rExists])
	{
        ReportData[i][rExists] = true;
        ReportData[i][rType] = type;
        ReportData[i][rPlayer] = playerid;
        ReportData[i][rYetkili] = INVALID_PLAYER_ID;

        strpack(ReportData[i][rText], text, 128 char);
		return i;
	}
	return -1;
}

Report_Remove(reportid)
{
	if(reportid != -1 && ReportData[reportid][rExists])
	{
	    ReportData[reportid][rExists] = false;
	    ReportData[reportid][rPlayer] = ReportData[reportid][rYetkili] = INVALID_PLAYER_ID;
	}
	return 1;
}

stock ReturnDate()
{
	new date[36];
	getdate(date[2], date[1], date[0]);
	gettime(date[3], date[4], date[5]);
	format(date, sizeof(date), "%02d/%02d/%d, %02d:%02d", date[0], date[1], date[2], date[3], date[4]);
	return date;
}

stock TimeConvertEx(sec, &days, &hours, &minutes, &seconds)
{
    days = floatround(sec / 86400);
    hours = floatround((sec - (days * 86400)) / 3600);
    minutes = floatround((sec - (days * 86400) - (hours * 3600)) / 60);
    seconds = sec % 60;
    return 1;
}

stock SendNearbyMessageEx(playerid, Float:radius, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 16)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 16); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit CONST.alt 4
		#emit SUB
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (IsPlayerNearPlayer(i, playerid, radius)) {
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
 foreach (new i : Player)
	{
		if (IsPlayerNearPlayer(i, playerid, radius)) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

stock M_ChatBubble(playerid, color, const text[], time)
{
    SetPVarInt(playerid, "t_ChatBubble", gettime() + time);
    new t_str[144];
    format(t_str, 144, "{%06x}%s", color >>> 8, text);
    SetPVarString(playerid, "t_ChatBubble_Text", t_str);
    return 1;
}

stock SendNearbyMessage(playerid, Float:radius, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 16)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 16); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit CONST.alt 4
		#emit SUB
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (IsPlayerNearPlayer(i, playerid, radius)) {
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
 foreach (new i : Player)
	{
		if (IsPlayerNearPlayer(i, playerid, radius)) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

stock IsPlayerNearPlayer(playerid, targetid, Float:radius)
{
    if(!M_IsPlayerConnected(playerid) || !M_IsPlayerConnected(targetid)) return false;
    new Float:fX, Float:fY, Float:fZ;
    GetPlayerPos(targetid, fX, fY, fZ);
    return (GetPlayerInterior(playerid) == GetPlayerInterior(targetid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid)) && IsPlayerInRangeOfPoint(playerid, radius, fX, fY, fZ);
}

stock split(const src[], dest[][], const delimiter)
{
    new n_pos,num,old,str[1];
    str[0] = delimiter;
    while(n_pos != -1)
    {
        n_pos = strfind(src,str,false,n_pos+1);
        strmid(dest[num++], src, (!num)?0:old+1,(n_pos==-1)?strlen(src):n_pos,256);
        old=n_pos;
    }
    return 1;
}

stock ReturnIP(playerid)
{
	new ip[16];
	GetPlayerIp(playerid, ip, sizeof(ip));
	return ip;
}

stock UpdateHealth(playerid)
{
    SetPlayerHealth(playerid, PlayerData[playerid][pCan]), SetPlayerArmour(playerid, PlayerData[playerid][pZirh]);
	return 1;
}

stock SendTesterAlert(seviye = 1, color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if(args > 12)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 12); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		foreach (new i: Player) if(PlayerData[i][pTester] >= seviye) SendClientMessage(i, color, string);
		return 1;
	}
	foreach (new i: Player) if(PlayerData[i][pTester] >= seviye) SendClientMessage(i, color, str);
	return 1;
}

stock SendAdminAlert(seviye = 1, color, const str[], {Float,_}:...)
{
	static args, start, end, string[144];
	#emit LOAD.S.pri 8
	#emit STOR.pri args
	if(args > 12)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 12); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4
        foreach (new i: Player)
		{
			if(PlayerData[i][pAdmin] >= seviye) {
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i: Player)
	{
		if(PlayerData[i][pAdmin] >= seviye) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

stock SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static args, str[144];
	if((args = numargs()) == 3)
	{
	    SendClientMessage(playerid, color, text);
	}
	else
	{
		while (--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return 1;
}

stock SendClientMessageToAllEx(color, const text[], {Float, _}:...)
{
	static args, str[512];

	if((args = numargs()) == 2)
	{
	    SendClientMessageToAll(color, text);
	}
	else
	{
		while (--args >= 2)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessageToAll(color, str);

		#emit RETN
	}
	return 1;
}

stock Log_Write(const path[], const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    File:file,
	    string[1024]
	;
	if((start = strfind(path, "/")) != -1) {
	    strmid(string, path, 0, start + 1);

	    if(!fexist(string))
	        return printf("** Warning: Directory \"%s\" doesn't exist.", string);
	}
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	file = fopen(path, io_append);

	if(!file)
	    return 0;

	if(args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 1024
		#emit PUSH.C string
		#emit PUSH.C args
		#emit SYSREQ.C format

		fwrite(file, string);
		fwrite(file, "\r\n");
		fclose(file);

		#emit LCTRL 5
		#emit SCTRL 4
		#emit RETN
	}
	fwrite(file, str);
	fwrite(file, "\r\n");
	fclose(file);

	return 1;
}

stock IsPlayerBot(playerid)
{
    new TempId[80], TempNumb;
    gpci(playerid, TempId, sizeof(TempId));
    for(new i = 0; i < strlen(TempId); i++)
    {
        if(TempId[i] >= '0' && TempId[i] <= '9')  TempNumb++;
    }
    return (TempNumb >= 30 || strlen(TempId) <= 30);
}

Ban_Ex(ip[], character[], forumid, type, reason[], admin[], day)
{
	new query[280];
	format(query, sizeof(query), "INSERT INTO `bans` (`IP`, `isim`, `reason`, `admin`, `opendate`, `date`) VALUES('%s', '%s', '%s', '%s', '%d', '%s')",
		SQL_ReturnEscaped(ip),
		SQL_ReturnEscaped(character),
   		SQL_ReturnEscaped(reason),
		SQL_ReturnEscaped(admin),
		(day != 0) ? gettime() + day : 0,
		ReturnDate()
	);
	mysql_tquery(mysqlM, query);
}

stock SQL_SavePlayer(playerid, type = 0)
{
	if(!M_IsPlayerConnected(playerid)) return 0;
	switch(type)
	{
	    case 0: //ALL
		{
			static query[2048];
			format(query, sizeof(query), "UPDATE `hesaplar` SET `PosX` = '%.4f', `PosY` = '%.4f', `PosZ` = '%.4f', `PosA` = '%.4f', `VW` = '%d', `INTERIOR` = '%d', `Admin` = '%d', `Tester` = '%d', `AdminName` = '%s', `Seviye` = '%d', `Para` = '%d', `Skin` = '%d', `SuspectSkin` = '%d', `PoliceSkin` = '%d'",
                PlayerData[playerid][pPos][0],
                PlayerData[playerid][pPos][1],
                PlayerData[playerid][pPos][2],
                PlayerData[playerid][pPos][3],
                PlayerData[playerid][pWorld],
                PlayerData[playerid][pInterior],
				PlayerData[playerid][pAdmin],
				PlayerData[playerid][pTester],
				SQL_ReturnEscaped(PlayerData[playerid][pAdminName]),
				PlayerData[playerid][pLevel],
				PlayerData[playerid][pMoney],
				PlayerData[playerid][pSkin],
                PlayerData[playerid][pSuspectSkin],
                PlayerData[playerid][pPoliceSkin]
			);
			format(query, sizeof(query), "%s, `ReportCount` = '%d', `ReportMute` = '%d' WHERE `ID` = '%d'",
				query,
				PlayerData[playerid][pReportCount],
				PlayerData[playerid][pReportMute],
				PlayerData[playerid][pID]
			);
			mysql_tquery(mysqlM, query);
		}
	}
	return 1;
}

KickEx(playerid, time = 300)
{
    SetPVarInt(playerid, "t_Kicked", 1);
	PlayerData[playerid][pTimers][0] = SetTimerEx("KickTimer", time, false, "d", playerid);
	return 1;
}

fonksiyon KickTimer(playerid)
{
	if(!M_IsPlayerConnected(playerid)) return 1;
	return Kick(playerid);
}

stock IsValidTextDraw(&Text:textdrawid)
{
    if(textdrawid == Text:INVALID_TEXT_DRAW || _:textdrawid == 0) return 0;
    return 1;
}

stock M_Random(min, max = -1)
{
    if(max == -1) return MuteoRandom(0, min - 1);
    return MuteoRandom(min, max);
}

stock M_TextDrawDestroy(&Text:textdrawid)
{
    if(IsValidTextDraw(textdrawid)) TextDrawDestroy(textdrawid);
    textdrawid = Text:INVALID_TEXT_DRAW;
    return 1;
}

stock M_RemovePlayerFromVehicle(playerid)
{
	RemovePlayerFromVehicle(playerid);
	return 1;
}

stock M_DestroyDynamic3DTextLabel(&STREAMER_TAG_3D_TEXT_LABEL:id)
{
    if(_:id == 0)
    {
        id = STREAMER_TAG_3D_TEXT_LABEL:-1;
    }
    else if(id != STREAMER_TAG_3D_TEXT_LABEL:-1)
    {
        DestroyDynamic3DTextLabel(id);
        id = STREAMER_TAG_3D_TEXT_LABEL:-1;
    }
}

stock M_DestroyDynamicObject(&objectid)
{
    if(IsValidDynamicObject(objectid)) DestroyDynamicObject(objectid);
    objectid = -1;
    return 1;
}

stock M_DestroyDynamicPickup(&pickup)
{
    if(IsValidDynamicPickup(pickup)) DestroyDynamicPickup(pickup);
    pickup = 0;
    return 1;
}

stock M_SetPlayerPos(playerid, Float:x, Float:y, Float:z)
{
	if(!M_IsPlayerConnected(playerid)) return 1;
	SetPVarInt(playerid, "t_Anticheat", 1);
    SetPlayerPos(playerid, x, y, z);
	return 1;
}

stock M_KillTimer(&timerid)
{
	if(timerid != -1) KillTimer(timerid);
	timerid = -1;
	return 1;
}

stock M_DestroyVehicle(&vehicleid)
{
	DestroyVehicle(vehicleid);
	vehicleid = INVALID_VEHICLE_ID;
	return 1;
}

stock GetPlayerSkinEx(playerid)
	return (GetPlayerCustomSkin(playerid) >= 20001) ? (GetPlayerCustomSkin(playerid)) : (GetPlayerSkin(playerid));


stock M_IsPlayerConnected(playerid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
	return 1;
}

stock IsPlayerSpawnedEx(playerid)
{
	if(!M_IsPlayerConnected(playerid)) return 0;
	return (GetPlayerState(playerid) != PLAYER_STATE_SPECTATING && GetPlayerState(playerid) != PLAYER_STATE_NONE && GetPlayerState(playerid) != PLAYER_STATE_WASTED);
}

stock M_ClearAnimations(playerid)
{
    //ClearAnimations(playerid);
    ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
    return 1;
}

stock m_isnull(const text[])
{
    if(text[0] == '\0' || isnull(text) || !strcmp(text, "NULL", true)) return 1;
    return 0;
}

stock M_LoadObjects(playerid, time = 1, showtext = 1, protection = 1)
{
    if(protection) SetPVarInt(playerid, "t_SpawnProtection", time);
    M_TogglePlayerControllable(playerid, 0);
    if(GetPVarInt(playerid, "t_LoadingTimer") > 0)
	{
	    if(showtext) GameTextForPlayer(playerid, "~w~(OBJELER YUKLENIYOR)", 3000, 5);
		SetPVarInt(playerid, "t_LoadingTimer", time);
		return 1;
	}
	if(showtext) GameTextForPlayer(playerid, "~w~(OBJELER YUKLENIYOR)", 3000, 5);
 	SetPVarInt(playerid, "t_LoadingTimer", time);
    return 1;
}

stock M_TogglePlayerControllable(playerid, toggle)
{
	if(toggle) PlayerData[playerid][pFreezed] = 0;
	else PlayerData[playerid][pFreezed] = 1;
	TogglePlayerControllable(playerid, toggle);
}

stock M_TogglePlayerSpectating(playerid, toggle)
{
	if(toggle == 0) DeletePVar(playerid, "t_Spectating");
	else SetPVarInt(playerid, "t_Spectating", 1);
	TogglePlayerSpectating(playerid, toggle);
	return 1;
}

stock M_SetPlayerVirtualWorld(playerid, virtualworld)
{
	PlayerData[playerid][pWorld] = virtualworld, SetPlayerVirtualWorld(playerid, virtualworld);
	return 1;
}

stock M_SetPlayerInterior(playerid, interior)
{
	PlayerData[playerid][pInterior] = interior, SetPlayerInterior(playerid, interior);
	return 1;
}

stock M_PutPlayerInVehicle(playerid, vehicleid, seatid, time = 300, freeze = 0)
{
	if(time == 0) timer_PutPlayerInVehicle(playerid, vehicleid, seatid, freeze);
    else PlayerData[playerid][pTimers][1] = SetTimerEx("timer_PutPlayerInVehicle", time, false, "dddd", playerid, vehicleid, seatid, freeze);
	return 1;
}

fonksiyon timer_PutPlayerInVehicle(playerid, vehicleid, seatid, freeze)
{
    if(!M_IsPlayerConnected(playerid) || !IsValidVehicle(vehicleid)) return 0;
	PutPlayerInVehicle(playerid, vehicleid, seatid);
	if(freeze) M_TogglePlayerControllable(playerid, 0);
	return 1;
}

stock M_SetPlayerCheckpoint(playerid, Float:x, Float:y, Float:z, Float:size)
{
    DisablePlayerCheckpoint(playerid);
    PlayerData[playerid][pTimers][2] = SetTimerEx("timer_SetPlayerCheckpoint", 250, false, "dffff", playerid, x, y, z, size);
}

fonksiyon timer_SetPlayerCheckpoint(playerid, Float:x, Float:y, Float:z, Float:size)
{
    if(M_IsPlayerConnected(playerid)) SetPlayerCheckpoint(playerid, x, y, z, size);
	return 1;
}

GetMoney(playerid)
{
	return (PlayerData[playerid][pMoney]);
}

stock CanDegistir(playerid, Float:amount)
{
	if(amount < 0) amount = 0;
    PlayerData[playerid][pCan] = amount;
	UpdateHealth(playerid);
	return 1;
}

stock ZirhDegistir(playerid, Float:amount)
{
	if(amount < 0) amount = 0;
	PlayerData[playerid][pZirh] = amount;
	UpdateHealth(playerid);
	return 1;
}

stock IsEngineVehicle(vehicleid)
{
	static const g_aEngineStatus[] = {
	    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
	    1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	    1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	    1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	    1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1,
	    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	    1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	    1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1,
	    1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0
	};
    new modelid = GetVehicleModel(vehicleid);

    if(modelid < 400 || modelid > 611)
        return 0;

    return (g_aEngineStatus[modelid - 400]);
}

stock SQL_ReturnEscaped(const string[])
{
	new entry[256];
	mysql_escape_string(string, entry);
	return entry;
}

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

SendPlayerToPlayer(playerid, targetid)
{
	new Float:t_Pos[3];
	GetPlayerPos(targetid, t_Pos[0], t_Pos[1], t_Pos[2]);
	if(IsPlayerInAnyVehicle(playerid))
	{
		LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(targetid));
	}
	else M_SetPlayerPos(playerid, t_Pos[0] + 1, t_Pos[1], t_Pos[2]);
    M_LoadObjects(playerid);
	M_SetPlayerInterior(playerid, GetPlayerInterior(targetid));
	M_SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));
}

fonksiyon SecondCheck()
{
    new t_str[256];
    foreach (new i: Player) if(PlayerData[i][pLogged])
	{
		if(GetPlayerMoney(i) != PlayerData[i][pMoney]) ResetPlayerMoney(i), GivePlayerMoney(i, PlayerData[i][pMoney]);
		if(GetPlayerScore(i) != PlayerData[i][pLevel]) SetPlayerScore(i, PlayerData[i][pLevel]);
		if(GetPlayerState(i) == PLAYER_STATE_SPECTATING && PlayerData[i][pLogged] && !IsPlayerPaused(i) && GetPVarInt(i, "t_SpectatePlayer") == 0) SpawnTimer(i);
		if(GetPVarInt(i, "t_LastUpdate") != 999 && GetTickCount() - 3000 >= GetPVarInt(i, "t_LastUpdate")) SetPVarInt(i, "t_LastUpdate", 999), SetPVarInt(i, "t_AFK", 1), PlayerData[i][pAFKSure] = 3;
        t_str[0] = '\0';
		if (GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK && GetPVarInt(i, "t_Jetpack") == 0)
		{
			SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s adlý oyuncu Jetpack Hack sebebiyle sunucudan atýldý.", ReturnName(i, 1));
			SendErrorMessage(i, "Anti-cheat tarafýndan sunucudan atýldýnýz. (Jetpack)");
			KickEx(i);
		}
        /*
        if(!IsPlayerInRangeOfPoint(i, 2.5, 0.0, 0.0, 0.0) && IsPlayerSpawnedEx(i))
        {
			t_str[0] = GetPVarInt(i, "t_Anticheat");
			if(t_str[0] != 0)
			{
				SetPVarInt(i, "t_Anticheat", t_str[0] + 1);
				if(t_str[0] > 2) DeletePVar(i, "t_Anticheat");
			}
			else
			{
                if(PlayerData[i][pAdmin] < 3 && !IsPlayerInAnyVehicle(i) && GetPlayerSurfingVehicleID(i) == INVALID_VEHICLE_ID)
				{
					new Float:t_DFP = GetPlayerDistanceFromPoint(i, PlayerData[i][pPos][0], PlayerData[i][pPos][1], PlayerData[i][pPos][2]);
					if(t_DFP > 35 && !IsPlayerFalling(i)) SendAdminAlert(0, 1, COLOR_LIGHTRED, "AdmCmd: %s(%d) adlý oyuncu Teleport/Airbreak kullanýyor olabilir. (%.2fm)", ReturnName(i, 1), i, t_DFP);
				}
				for (new j = 0; j < 13; j++)
				{
				    GetPlayerWeaponData(i, j, t_str[0], t_str[1]);
				    if(t_str[0] != 0 && PlayerData[i][pGuns][j] != t_str[0])
				    {
						SendAdminAlert(0, 1, COLOR_LIGHTRED, "AdmCmd: %s adlý oyuncu Silah Hilesi sebebiyle sunucudan atýldý. (#2 - %s)", ReturnName(i, 1), ReturnWeaponName(t_str[0]));
				        Kick(i);
						break;
				    }
                    if(t_str[0] != 0 && (t_str[0] == 37 || t_str[0] >= 41 && t_str[0] <= 43) && PlayerData[i][pGuns][j] == t_str[0])
                    {
                        if(t_str[1] == 0) ResetWeapon(i, t_str[0]);
                        else PlayerData[i][pAmmo][j] = t_str[1];
                    }
				}
			}
    		GetPlayerPos(i, PlayerData[i][pPos][0], PlayerData[i][pPos][1], PlayerData[i][pPos][2]);
        }*/
        t_str[0] = t_str[1] = 0;
		t_str[2] = GetWeapon(i);
        if(PlayerData[i][pGuns][3] && t_str[2] != PlayerData[i][pGuns][3]) t_str[0] = PlayerData[i][pGuns][3];
	 	if(PlayerData[i][pGuns][5] && t_str[2] != PlayerData[i][pGuns][5]) t_str[1] = PlayerData[i][pGuns][5];
		if(t_str[0])
		{
		    if(!IsPlayerAttachedObjectSlotUsed(i, 5)) SetPlayerAttachedObject(i, 5, GetWeaponModel(t_str[0]), 1, GetPVarFloat(i, "t_W20"), GetPVarFloat(i, "t_W21"), GetPVarFloat(i, "t_W22"), GetPVarFloat(i, "t_W23"), GetPVarFloat(i, "t_W24"), GetPVarFloat(i, "t_W25"), 1.000000, 1.000000, 1.000000);
		}
        else if(IsPlayerAttachedObjectSlotUsed(i, 5)) RemovePlayerAttachedObject(i, 5);
		if(t_str[1])
		{
            if(!IsPlayerAttachedObjectSlotUsed(i, 6)) SetPlayerAttachedObject(i, 6, GetWeaponModel(t_str[1]), 1, GetPVarFloat(i, "t_W10"), GetPVarFloat(i, "t_W11"), GetPVarFloat(i, "t_W12"), GetPVarFloat(i, "t_W13"), GetPVarFloat(i, "t_W14"), GetPVarFloat(i, "t_W15"), 1.000000, 1.000000, 1.000000);
	    }
	    else if(IsPlayerAttachedObjectSlotUsed(i, 6)) RemovePlayerAttachedObject(i, 6);
		if(GetPVarInt(i, "t_LastTaserTime") != 0)
		{
			if(GetPVarInt(i, "t_LastTaserTime") > gettime()) SetPlayerArmedWeapon(i, 0);
			else DeletePVar(i, "t_LastTaserTime");
		}
		if(IsPlayerPaused(i))
        {
            PlayerData[i][pAFKSure]++;
            if(GetPlayerState(i) == PLAYER_STATE_PASSENGER) M_PutPlayerInVehicle(i, GetPlayerVehicleID(i), GetPlayerVehicleSeat(i));
        }
        else
		{
			PlayerData[i][pAFKSure] = 0;
			if(GetPVarInt(i, "t_LastPingCheck") < gettime())
			{
				SetPVarInt(i, "t_LastPingCheck", gettime() + 5);
                t_str[0] = GetPlayerPing(i);
                if(t_str[0] > 1000)
                {
                    if(GetPVarInt(i, "t_HighPing") > 2)
                    {
                        SendErrorMessage(i, "Yüksek ping sebebiyle sunucudan atýldýn.");
                        KickEx(i);
                    }
                    else SetPVarInt(i, "t_HighPing", GetPVarInt(i, "t_HighPing") + 1);
                }
                else
                {
                    DeletePVar(i, "t_HighPing");
    				if(t_str[0] > 400)
    				{
    					format(t_str, sizeof(t_str), "~y~Baglanti sorunu. (%dms, %.2floss)", t_str[0], NetStats_PacketLossPercent(i));
    					//M_InfoTextForPlayer(i, t_str, 5);
    				}
                }
			}
		}
        if(IsValidDynamic3DTextLabel(PlayerData[i][pNameTag]))
		{
			t_str[0] = '\0';
			if(PlayerData[i][pAFKSure] == 0) PlayerData[i][pAFKSure] = 1;
			if(PlayerData[i][pAFKSure] > 3600) format(t_str, sizeof(t_str), "%s{FF6347}[+1 saat AFK]\n", t_str);
			else if(PlayerData[i][pAFKSure] > 600) format(t_str, sizeof(t_str), "%s{FF6347}[+10 dakika AFK]\n", t_str);
			else if(IsPlayerPaused(i)) format(t_str, sizeof(t_str), "%s{FF6347}[%d saniye AFK]\n", t_str, PlayerData[i][pAFKSure]);
			if(GetPVarInt(i, "t_SpawnProtection") == 1) format(t_str, sizeof(t_str), "%s{2FA845}(( Spawn Korumasý ))\n", t_str);
			if(GetPVarInt(i, "t_Injured") != 0) format(t_str, sizeof(t_str), "%s{FF6347}(( BU OYUNCU YARALI ))\n", t_str);
            format(t_str, sizeof(t_str), "%s{dadada}%s (%d)\n{dadada}HP: {FF6347}%d", t_str, ReturnName(i, 1), i, floatround(PlayerData[i][pCan]));
	        UpdateDynamic3DTextLabelText(PlayerData[i][pNameTag], DEFAULT_COLOR, t_str);
		}
		if(GetPVarInt(i, "t_LoadAccessories") != 0 && !IsPlayerPaused(i))
		{
			new t_str2[7], Float:t_Pos[9];
			for(new j = 0; j < 10; j++)
			{
				format(t_str2, sizeof(t_str2), "a_M%d", j);
				if(GetPVarInt(i, t_str2) != 0)
				{
					format(t_str2, sizeof(t_str2), "a_T%d", j);
					if(GetPVarInt(i, t_str2) == 1)
					{
						format(t_str, sizeof(t_str), "a_M%d", j);
						format(t_str2, sizeof(t_str2), "a_P%d0", j);
						t_Pos[0] = GetPVarFloat(i, t_str2);
						format(t_str2, sizeof(t_str2), "a_P%d1", j);
						t_Pos[1] = GetPVarFloat(i, t_str2);
						format(t_str2, sizeof(t_str2), "a_P%d2", j);
						t_Pos[2] = GetPVarFloat(i, t_str2);
						format(t_str2, sizeof(t_str2), "a_P%d3", j);
						t_Pos[3] = GetPVarFloat(i, t_str2);
						format(t_str2, sizeof(t_str2), "a_P%d4", j);
						t_Pos[4] = GetPVarFloat(i, t_str2);
						format(t_str2, sizeof(t_str2), "a_P%d5", j);
						t_Pos[5] = GetPVarFloat(i, t_str2);
						format(t_str2, sizeof(t_str2), "a_P%d6", j);
						t_Pos[6] = GetPVarFloat(i, t_str2);
						format(t_str2, sizeof(t_str2), "a_P%d7", j);
						t_Pos[7] = GetPVarFloat(i, t_str2);
						format(t_str2, sizeof(t_str2), "a_P%d8", j);
						t_Pos[8] = GetPVarFloat(i, t_str2);
						format(t_str2, sizeof(t_str2), "a_B%d", j);
                        new slotid = -1;
                        for(new d = 0; d < 5; d++) if(!IsPlayerAttachedObjectSlotUsed(i, d))
                        {
                            slotid = d;
                            break;
                        }
                        if(slotid != -1)
                        {
                            SetPlayerAttachedObject(i, slotid, GetPVarInt(i, t_str), GetPVarInt(i, t_str2), t_Pos[0], t_Pos[1], t_Pos[2], t_Pos[3], t_Pos[4], t_Pos[5], t_Pos[6], t_Pos[7], t_Pos[8]);
                            format(t_str2, sizeof(t_str2), "a_I%d", j);
                            SetPVarInt(i, t_str2, slotid);
                        }
					}
				}
			}
			DeletePVar(i, "t_LoadAccessories");
		}
		if(GetPVarInt(i, "t_LoadingTimer") != 0)
		{
		    new t_loading = GetPVarInt(i, "t_LoadingTimer");
		    SetPVarInt(i, "t_LoadingTimer", t_loading + 1);
		    if(t_loading > 4) M_TogglePlayerControllable(i, 1), DeletePVar(i, "t_LoadingTimer"), DeletePVar(i, "t_SpawnProtection");
		}
	}
	return 1;
}

stock IsPlayerPaused(playerid)
{
	return GetPVarInt(playerid, "t_AFK");
}

stock GetWeaponModel(weaponid)
{
    switch(weaponid)
    {
        case 1:
        	return 331;

        case 2..8:
            return weaponid+331;

		case 9:
            return 341;

        case 10..15:
                return weaponid+311;

        case 16..18:
            return weaponid+326;

        case 22..29:
            return weaponid+324;

        case 30,31:
            return weaponid+325;

        case 32:
            return 372;

        case 33..45:
            return weaponid+324;

        case 46:
            return 371;
    }
    return 0;
}

stock GetWeapon(playerid)
{
	new weaponid = GetPlayerWeapon(playerid);
    if(weaponid < 1 || weaponid > 47) return 0;
    if(PlayerData[playerid][pGuns][p_WeaponSlots[weaponid]] == weaponid) return weaponid;
	return 0;
}

CMD:admins(playerid, params[])
{
    SendClientMessage(playerid, COLOR_LIGHTGREEN, "|______________________________|");
    new count = 0;
    foreach (new i : Player) if (PlayerData[i][pAdmin] > 0)
	{
		SendClientMessageEx(playerid, COLOR_LIGHTGREEN, "(Level: %d) %s", PlayerData[i][pAdmin], PlayerData[i][pAdminName]);
        count++;
	}
	if (!count) {
	    SendClientMessage(playerid, COLOR_GREY, "Aktif yönetici bulunmuyor.");
	}
	SendClientMessage(playerid, COLOR_LIGHTGREEN, "|______________________________|");
	return 1;
}

CMD:pm(playerid, params[])
{
    static userid, text[128];
	if (sscanf(params, "us[128]", userid, text)) return SendSyntaxMessage(playerid, "/pm [id/isim] [mesaj]");
	if (!M_IsPlayerConnected(userid)) return SendErrorMessage(playerid, E_INVALID_ID);
	if (userid == playerid) return SendErrorMessage(playerid, "Kendinize mesaj yollayamazsýnýz.");
	GameTextForPlayer(userid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~Yeni mesaj!", 3000, 3);
	PlayerPlaySound(userid, 1085, 0.0, 0.0, 0.0);
    foreach(new i : Player)
	{
	    if(PlayerData[i][pAdmin] >= 1)
	    {
	        SendClientMessageEx(i, COLOR_DEPARTMENT, "((  %s (%d) > %s (%d) : %s ))", ReturnName(playerid, 0), playerid, ReturnName(userid), userid, text);
		}
	}
	SendClientMessageEx(userid, COLOR_YELLOW, "(( PM geldi %s (%d): %s ))", ReturnName(playerid, 0), playerid, text);
	SendClientMessageEx(playerid, COLOR_YELLOW, "(( PM yollandý %s (%d): %s ))", ReturnName(userid, 0), userid, text);
	return 1;
}


CMD:setadmin(playerid, params[])
{
	if(PlayerData[playerid][pAdmin] < 5) return SendErrorMessage(playerid, "Yetersiz yetki.");
	new id, level;
    if(sscanf(params, "ud", id, level)) return SendSyntaxMessage(playerid, "/setadmin [id] [seviye]");
    if(!IsPlayerConnected(id) || !PlayerData[id][pLogged]) return SendErrorMessage(playerid, E_INVALID_ID);
    if(level < 0 || level > 7) return SendServerMessage(playerid, "Geçersiz seviye. (0 - 7)");
	PlayerData[id][pAdmin] = level;
    SQL_SavePlayer(id, 0);
    if(PlayerData[id][pAdmin] >= 1) {
        SendServerMessage(id, "Yetki seviyen %d olarak deðiþtirildi.", level);
        SendAdminAlert(5, COLOR_LIGHTRED, "AdmCmd: %s, %s isimli oyuncunun yetkisini %d olarak ayarladý.", PlayerData[playerid][pAdminName], ReturnName(id, 1), level);
    }
    else {
        SendAdminAlert(5, COLOR_LIGHTRED, "AdmCmd: %s, %s isimli yetkiliyi oyuncu yaptý.", PlayerData[playerid][pAdminName], PlayerData[id][pAdminName]);
        SendServerMessage(id, "Yetki seviyen oyuncu olarak deðiþtirildi.");
    }
    return 1;
}

CMD:setadminname(playerid, params[])
{
    if (PlayerData[playerid][pAdmin] < 5) return SendErrorMessage(playerid, "Yetersiz yetki.");
    static userid, newname[32];
	if (sscanf(params, "us[32]", userid, newname)) return SendSyntaxMessage(playerid, "/setadminname [id/isim] [adminname]");
	if (!M_IsPlayerConnected(userid && !PlayerData[userid][pLogged])) return SendErrorMessage(playerid, E_INVALID_ID);
	format(PlayerData[userid][pAdminName], 32, "%s", newname);
	SendServerMessage(userid, "%s adlý yetkili senin admin adýný %s olarak deðiþtirdi.", ReturnName(playerid, 0), newname);
	SendServerMessage(playerid, "%s adlý oyuncunun admin adýný %s olarak deðiþtirdiniz.", ReturnName(userid, 0), newname);
    SQL_SavePlayer(userid, 0);
	return 1;
}

CMD:kick(playerid, params[])
{
    if (PlayerData[playerid][pAdmin] < 1 && PlayerData[playerid][pTester] < 3) return SendErrorMessage(playerid, "Yetersiz yetki.");
    static userid,  reason[128];
	if (sscanf(params, "us[128]", userid, reason))  return SendSyntaxMessage(playerid, "/kick [id/isim] [sebep]");
	if (!M_IsPlayerConnected(userid)) return SendErrorMessage(playerid, E_INVALID_ID);
    if (PlayerData[userid][pAdmin] > PlayerData[playerid][pAdmin]) return SendErrorMessage(playerid, "Sizden yüksek birisini kickleyemezsin.");
	SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s, %s adlý kiþiyi %s sebebi ile oyundan attý.", PlayerData[playerid][pAdminName], ReturnName(userid, 0), reason);
	Log_Write("logs/kick_log.txt", "[%s] %s has kicked %s for: %s.", ReturnDate(), ReturnName(playerid, 0), ReturnName(userid, 0), reason);
	KickEx(userid);
	return 1;
}

CMD:kickall(playerid, params[])
{
    if (PlayerData[playerid][pAdmin] != 6) return SendErrorMessage(playerid, "Yetersiz yetki.");
	SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s adlý yetkili herkesi oyundan attý.", PlayerData[playerid][pAdminName]);
	foreach(new i : Player) { KickEx(i);}
	return 1;
}

CMD:me(playerid, params[])
{
    if (!PlayerData[playerid][pInGame]) return SendErrorMessage(playerid, "Lobide bu komutu kullanamazsýn.");
	if (isnull(params)) return SendSyntaxMessage(playerid, "/me [Hareket]");
	new action[256];
    strdel(action, 0, 256);
	strcat(action, params);
    if(strfind(action, "\"", true, 1) != -1)
	{
			new ilkdenden = strfind(action, "\"", true, 1);
			new sonrakidenden = strfind(action, "\"", true, ilkdenden+1);
			strins(action, "{FFFFFF}", ilkdenden);
			strins(action, "{C2A2DA}", sonrakidenden+9);
	}
	if (strlen(action) > 120) {
 	    SendNearbyMessage(playerid, 30.0, COLOR_CYAN, "* %s %.120s", ReturnName(playerid, 0), action);
	    SendNearbyMessage(playerid, 30.0, COLOR_CYAN, "...%s", action[120]);
	}
	else {
	    SendNearbyMessage(playerid, 30.0, COLOR_CYAN, "* %s %s", ReturnName(playerid, 0), action);
	}
	return 1;
}

CMD:do(playerid, params[])
{
    if (!PlayerData[playerid][pInGame]) return SendErrorMessage(playerid, "Lobide bu komutu kullanamazsýn.");
	if (isnull(params)) return SendSyntaxMessage(playerid, "/do [Durum]");
	if (strlen(params) > 120) {
	    SendNearbyMessage(playerid, 30.0, COLOR_CYAN, "* %.120s", params);
	    SendNearbyMessage(playerid, 30.0, COLOR_CYAN, "...%s (( %s ))", params[120], ReturnName(playerid, 0));
	}
	else {
	    SendNearbyMessage(playerid, 30.0, COLOR_CYAN, "* %s (( %s ))", params, ReturnName(playerid, 0));
	}
	return 1;
}

CMD:ame(playerid, params[])
{
    if (!PlayerData[playerid][pInGame]) return SendErrorMessage(playerid, "Lobide bu komutu kullanamazsýn.");
	if (isnull(params)) return SendSyntaxMessage(playerid, "/ame [Hareket]");
	M_ChatBubble(playerid, COLOR_CYAN, params, 5);
 	SendClientMessageEx(playerid, COLOR_CYAN, "* %s %s", ReturnName(playerid, 0), params);
	return 1;
}

CMD:ado(playerid, params[])
{
    if (!PlayerData[playerid][pInGame]) return SendErrorMessage(playerid, "Lobide bu komutu kullanamazsýn.");
	if (isnull(params)) return SendSyntaxMessage(playerid, "/ado [Durum]");
	M_ChatBubble(playerid, COLOR_GREEN, params, 5);
 	SendClientMessageEx(playerid, COLOR_GREEN, "* %s (( %s ))", params, ReturnName(playerid, 0));
	return 1;
}


CMD:s(playerid, params[])
{
    if (!PlayerData[playerid][pInGame]) return SendErrorMessage(playerid, "Lobide bu komutu kullanamazsýn.");
	if (isnull(params))  return SendSyntaxMessage(playerid, "/s [Baðýrma]");
	if (strlen(params) > 64) {
	    SendNearbyMessage(playerid, 30.0, COLOR_WHITE, "%s baðýrýr: %.64s", ReturnName(playerid, 0), params);
	    SendNearbyMessage(playerid, 30.0, COLOR_WHITE, "...%s!", params[64]);
	}
	else {
	    SendNearbyMessage(playerid, 30.0, COLOR_WHITE, "%s baðýrýr: %s!", ReturnName(playerid, 0), params);
	}
    M_ChatBubble(playerid, COLOR_GREY, params, 5);
	return 1;
}

CMD:c(playerid, params[])
{
    if (!PlayerData[playerid][pInGame]) return SendErrorMessage(playerid, "Lobide bu komutu kullanamazsýn.");
	if (isnull(params)) return SendSyntaxMessage(playerid, "/l [Kýsýk Ses]");
	if (strlen(params) > 64) {
	    SendNearbyMessage(playerid, 5.0, COLOR_WHITE, "%s kýsýk sesle söyler: %.64s", ReturnName(playerid, 0), params);
	    SendNearbyMessage(playerid, 5.0, COLOR_WHITE, "...%s", params[64]);
	}
	else {
	    SendNearbyMessage(playerid, 5.0, COLOR_WHITE, "%s kýsýk sesle söyler: %s", ReturnName(playerid, 0), params);
	}
    M_ChatBubble(playerid, COLOR_GREY, params, 5);
	return 1;
}

CMD:b(playerid, params[])
{
	if (isnull(params)) return SendSyntaxMessage(playerid, "/b [OOC]");
	if (strlen(params) > 64)
	{
	    if(PlayerData[playerid][pAdmin])
	    {
	        SendNearbyMessage(playerid, 20.0, COLOR_WHITE, "(( {ffb633}%s{FFFFFF} [%d]: %.64s", PlayerData[playerid][pAdmin], ReturnName(playerid, 0), playerid, params);
	    	SendNearbyMessage(playerid, 20.0, COLOR_WHITE, "...%s ))", params[64]);
	        return 1;
		}
	    SendNearbyMessageEx(playerid, 20.0, COLOR_WHITE, "(( %s [%d]: %.64s", ReturnName(playerid, 0), playerid, params);
	    SendNearbyMessageEx(playerid, 20.0, COLOR_WHITE, "...%s ))", params[64]);
	}
	else
	{
	    if(PlayerData[playerid][pAdmin])
	    {
	        SendNearbyMessage(playerid, 20.0, COLOR_WHITE, "(( {ffb633}%s{FFFFFF} [%d]: %s ))", ReturnName(playerid, 0), playerid, params);
			return 1;
		}
	    SendNearbyMessageEx(playerid, 20.0, COLOR_WHITE, "(( %s [%d]: %s ))", ReturnName(playerid, 0), playerid, params);
	}
	return 1;
}

CMD:a(playerid, params[])
{
	if (!PlayerData[playerid][pAdmin])  return SendErrorMessage(playerid, "Yetersiz yetki.");
	if (isnull(params)) return SendSyntaxMessage(playerid, "/a [yazý]");
	if (strlen(params) > 64) {
	    SendAdminAlert(1, 0xbf1004FF, "** %d Seviye Admin %s: %.64s", PlayerData[playerid][pAdmin], ReturnName(playerid, 0), params);
	    SendAdminAlert(1, 0xbf1004FF, "...%s **", params[64]);
	}
	else {
	    SendAdminAlert(1, 0xbf1004FF, "** %d Seviye Admin %s: %s **", PlayerData[playerid][pAdmin], ReturnName(playerid, 0), params);
	}
	return 1;
}


CMD:31(playerid)
{
    GivePlayerWeapon(playerid, 24, 31);
}

CMD:raporlar(playerid, params[])
{
	if(PlayerData[playerid][pAdmin] < 1 && PlayerData[playerid][pTester] < 1) return SendErrorMessage(playerid, "Yetersiz yetki.");
	new count, text[128], yetkili[24], string[1024];
    format(string, sizeof(string), "Rapor ID\tOyuncu\tYetkili\tTalep\n");
	for (new i = 0; i != MAX_REPORTS; i ++) if(ReportData[i][rExists])
	{
        format(yetkili, sizeof(yetkili), "Yok");
		if(ReportData[i][rYetkili] != INVALID_PLAYER_ID) format(yetkili, sizeof(yetkili), "%s", PlayerData[ReportData[i][rYetkili]][pAdminName]);
		strunpack(text, ReportData[i][rText]);
        format(string, sizeof(string), "%s{ededed}%d\t{ededed}%s\t{FF6347}%s\t{a3a3a3}%.64s\n", string, i, ReturnName(ReportData[i][rPlayer], 1), yetkili, text);
		count++;
	}
	if(!count)
    {
         if(isnull(params)) return SendErrorMessage(playerid, "Hiç rapor yok.");
         return 1;
    }
	Dialog_Show(playerid, Talepler, DIALOG_STYLE_TABLIST_HEADERS, "{FF6347}Raporlar", string, "Seç", "Kapat");
	return 1;
}

CMD:sorusor(playerid, params[]) return cmd_rapor(playerid, params);
CMD:soru(playerid, params[]) return cmd_rapor(playerid, params);
CMD:talep(playerid, params[]) return cmd_rapor(playerid, params);
CMD:rapor(playerid, params[])
{
	if(isnull(params)) return SendSyntaxMessage(playerid, "/rapor [metin]");
	//if(PlayerData[playerid][pJailTime] > 0) return SendWarningMessage(playerid, "Hapiste olduðunuz için bu komutu kullanamazsýnýz.");
	if(PlayerData[playerid][pReportMute] > gettime())
	{
	    new d, h, m, s;
    	TimeConvertEx((PlayerData[playerid][pReportMute] - gettime()) , d, h, m, s);
 		return SendErrorMessage(playerid, "Yeni bir rapor göndermek için %d saat, %d dakika, %d saniye beklemelisiniz.", h, m, s);
	}

	if(Report_GetCount(playerid) >= 1) return SendErrorMessage(playerid, "Zaten rapor göndermiþsiniz. (/raporiptal)");
	if(GetPVarInt(playerid, "t_ReportTime") >= gettime()) return SendErrorMessage(playerid, "Yeni bir rapor göndermek için %d saniye beklemen gerekiyor.", GetPVarInt(playerid, "t_ReportTime") - gettime());
	new reportid;
	if((reportid = Report_Add(playerid, params)) != -1)
	{
		SendServerMessage(playerid, "Raporun yetkililere gönderildi.");

        if(strlen(params) > 64)
		{
		    SendAdminAlert(1, COLOR_LIGHTRED, "** Rapor(%d) %s(%d): %.64s...", reportid, ReturnName(playerid, 1), playerid, params);
		    SendAdminAlert(1, COLOR_LIGHTRED, "...%s **", params[64]);
			SendTesterAlert(1, COLOR_LIGHTRED, "** Rapor(%d) %s(%d): %.64s...", reportid, ReturnName(playerid, 1), playerid, params);
		    SendTesterAlert(1, COLOR_LIGHTRED, "...%s **", params[64]);
		}
		else
		{
			SendAdminAlert(1, COLOR_LIGHTRED, "** Rapor(%d) %s(%d): %s **", reportid, ReturnName(playerid, 1), playerid, params);
			SendTesterAlert(1, COLOR_LIGHTRED, "** Rapor(%d) %s(%d): %s **", reportid, ReturnName(playerid, 1), playerid, params);
		}
		SetPVarInt(playerid, "t_ReportTime", gettime() + 60);
	}
	else
	{
	    SendErrorMessage(playerid, "Þu anda rapor gönderemezsiniz, lütfen biraz bekleyin.");
	}
	return 1;
}

Dialog:Talepler(playerid, response, listitem, inputtext[])
{
	if(response)
	{
 		new notreal[128], idx;
		notreal = strtok(inputtext, idx);
		new reportid = strval(notreal);
	    if(!ReportData[reportid][rExists]) return SendErrorMessage(playerid, "Bu rapor zaten cevaplanmýþ.");
	    if(ReportData[reportid][rYetkili] != INVALID_PLAYER_ID) return SendErrorMessage(playerid, "Bu raporla zaten %s ilgileniyor.", PlayerData[ReportData[reportid][rYetkili]][pAdminName]);
		SetPVarInt(playerid, "t_SelectedReport", reportid);
        ReportData[reportid][rYetkili] = playerid;
		new t_header[36], t_str[92];
		format(t_header, sizeof(t_header), "{FF6347}%s(%d)", ReturnName(ReportData[reportid][rPlayer], 1), ReportData[reportid][rPlayer]);
		if(PlayerData[playerid][pAdmin] >= 1) format(t_str, sizeof(t_str), "{ededed}Cevapla\n{ededed}Ýncele\n{ededed}Sil\n \n{ededed}Foruma Yönlendir\n{ededed}Engelle");
		else format(t_str, sizeof(t_str), "{ededed}Cevapla\n{ededed}Ýncele\n{ededed}Sil\n \n{ededed}Foruma Yönlendir");
		Dialog_Show(playerid, Talepler2, DIALOG_STYLE_TABLIST, t_header, t_str, "Seç", "Kapat");
	}
	return 1;
}

Dialog:Talepler2(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new reportid = GetPVarInt(playerid, "t_SelectedReport");
	    if(!ReportData[reportid][rExists]) return SendErrorMessage(playerid, "Bu rapor zaten cevaplanmýþ veya silinmiþ.");
        new text[128];
		strunpack(text, ReportData[reportid][rText]);
		switch(listitem)
		{
		    case 0:
		    {
		        new str[64];
				format(str, sizeof(str), "{FF6347}%s(%d)", ReturnName(ReportData[reportid][rPlayer], 1), ReportData[reportid][rPlayer]);
		        Dialog_Show(playerid, Talepler3, DIALOG_STYLE_INPUT, str, "Lütfen cevabýnýzý girin:", "Cevapla", "Kapat");
		    }
			case 1:
			{
                SendClientMessageEx(ReportData[reportid][rPlayer], COLOR_YELLOW, "[Rapor] (%s) %s: Selam, talebinizle þu anda ilgileniyorum, lütfen bekleyin.", (PlayerData[playerid][pAdminName] >= 1) ? "Admin" : "Tester", PlayerData[playerid][pAdminName]);
                new query[218], str[128];
                format(str, sizeof(str), "Selam, talebinizle þu anda ilgileniyorum.");
                strreplace(text, "'", "[:ayrac:]");
			    format(query, sizeof(query), "INSERT INTO `log_reports` (`Oyuncu`, `Soru`, `Yetkili`, `Cevap`, `Tarih`) VALUES('%s', '%s', '%s', '%s', '%s')", ReturnName(ReportData[reportid][rPlayer], 1), SQL_ReturnEscaped(text), PlayerData[playerid][pAdminName], SQL_ReturnEscaped(str), ReturnDate());
				mysql_tquery(mysqlM, query);
				Report_Remove(reportid);
			    PlayerData[playerid][pReportCount]++;
			    SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s, %d ID'li raporu cevapladý.", PlayerData[playerid][pAdminName], reportid);
			    cmd_raporlar(playerid, "yoruks");
			}
			case 2:
			{
			    SendClientMessageEx(ReportData[reportid][rPlayer], COLOR_YELLOW, "[Rapor] (%s) %s: Teknik bir sorun bulunmadýðý için talebiniz silindi.", (PlayerData[playerid][pAdminName] >= 1) ? "Admin" : "Tester", PlayerData[playerid][pAdminName]);
                new query[218], str[128];
                format(str, sizeof(str), "Teknik bir sorun bulunmadýðý için talebiniz silindi.");
                strreplace(text, "'", "[:ayrac:]");
			    format(query, sizeof(query), "INSERT INTO `log_reports` (`Oyuncu`, `Soru`, `Yetkili`, `Cevap`, `Tarih`) VALUES('%s', '%s', '%s', '%s', '%s')", ReturnName(ReportData[reportid][rPlayer], 1), SQL_ReturnEscaped(text), PlayerData[playerid][pAdminName], SQL_ReturnEscaped(str), ReturnDate());
				mysql_tquery(mysqlM, query);
			    Report_Remove(reportid);
			    PlayerData[playerid][pReportCount]++;
       			SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s, %d ID'li raporu sildi.", PlayerData[playerid][pAdminName], reportid);
			    cmd_raporlar(playerid, "yoruks");
			}
			case 3:
			{
    			new t_header[64], t_str[218];
				format(t_header, sizeof(t_header), "{FF6347}%s(%d)", ReturnName(ReportData[reportid][rPlayer], 1), ReportData[reportid][rPlayer]);
				if(PlayerData[playerid][pAdmin] >= 1) format(t_str, sizeof(t_str), "{ededed}Cevapla\n{ededed}Ýncele\n{ededed}Sil\n \n{ededed}Foruma Yönlendir\n{ededed}Engelle");
				else format(t_str, sizeof(t_str), "{ededed}Cevapla\n{ededed}Ýncele\n{ededed}Sil\n \n{ededed}Foruma Yönlendir");
				Dialog_Show(playerid, Talepler2, DIALOG_STYLE_TABLIST, t_header, t_str, "Seç", "Kapat");
			}
			case 4:
			{
			    SendClientMessageEx(ReportData[reportid][rPlayer], COLOR_YELLOW, "[Rapor] (%s) %s: Sorunuzun cevabýný forumda bulabilir veya ticket oluþturabilirsiniz. (south-central.net)", (PlayerData[playerid][pAdminName] >= 1) ? "Admin" : "Tester", PlayerData[playerid][pAdminName]);
                new query[218], str[128];
                format(str, sizeof(str), "Sorunuzun cevabýný forumda bulabilir veya ticket oluþturabilirsiniz. (south-central.net)");
                strreplace(text, "'", "[:ayrac:]");
			    format(query, sizeof(query), "INSERT INTO `log_reports` (`Oyuncu`, `Soru`, `Yetkili`, `Cevap`, `Tarih`) VALUES('%s', '%s', '%s', '%s', '%s')", ReturnName(ReportData[reportid][rPlayer], 1), SQL_ReturnEscaped(text), PlayerData[playerid][pAdminName], SQL_ReturnEscaped(str), ReturnDate());
				mysql_tquery(mysqlM, query);
				Report_Remove(reportid);
			    PlayerData[playerid][pReportCount]++;
			    SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s, %d ID'li raporu foruma yönlendirdi.", PlayerData[playerid][pAdminName], reportid);
			    cmd_raporlar(playerid, "yoruks");
			}
			case 5:
		    {
		        new str[64];
				format(str, sizeof(str), "{FF6347}%s(%d)", ReturnName(ReportData[reportid][rPlayer], 1), ReportData[reportid][rPlayer]);
		        Dialog_Show(playerid, Talepler4, DIALOG_STYLE_INPUT, str, "Lütfen dakika giriniz:", "Engelle", "Kapat");
		    }
		}
	}
	else
	{
	    ReportData[GetPVarInt(playerid, "t_SelectedReport")][rYetkili] = INVALID_PLAYER_ID;
		cmd_raporlar(playerid, "yoruks");
	}
	return 1;
}

Dialog:Talepler3(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new reportid = GetPVarInt(playerid, "t_SelectedReport");
	    if(!ReportData[reportid][rExists]) return SendErrorMessage(playerid, "Bu rapor zaten cevaplanmýþ veya silinmiþ.");
		if(strlen(inputtext) > 64)
		{
			SendClientMessageEx(ReportData[reportid][rPlayer], COLOR_YELLOW, "[Rapor] (%s) %s: %.64s...", (PlayerData[playerid][pAdminName] >= 1) ? "Admin" : "Tester", PlayerData[playerid][pAdminName], inputtext);
			SendClientMessageEx(ReportData[reportid][rPlayer], COLOR_YELLOW, "...%s", inputtext[64]);
			SendClientMessageEx(playerid, COLOR_YELLOW, "[Rapor] (%s) %s: %.64s", (PlayerData[playerid][pAdminName] >= 1) ? "Admin" : "Tester", PlayerData[playerid][pAdminName], inputtext);
			SendClientMessageEx(playerid, COLOR_YELLOW, "...%s", inputtext[64]);
		}
		else
		{
			SendClientMessageEx(ReportData[reportid][rPlayer], COLOR_YELLOW, "[Rapor] (%s) %s: %s", (PlayerData[playerid][pAdminName] >= 1) ? "Admin" : "Tester", PlayerData[playerid][pAdminName], inputtext);
			SendClientMessageEx(playerid, COLOR_YELLOW, "[Rapor] (%s) %s: %s", (PlayerData[playerid][pAdminName] >= 1) ? "Admin" : "Tester", PlayerData[playerid][pAdminName], inputtext);
		}
		new text[128];
		strunpack(text, ReportData[reportid][rText]);
		SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s, %d ID'li raporu cevapladý.", PlayerData[playerid][pAdminName], reportid);
		new query[218], cevap[128];
		format(cevap, sizeof(cevap), inputtext);
		//strreplace(text, "'", "[:ayrac:]");
		//strreplace(cevap, "'", "[:ayrac:]");
	    format(query, sizeof(query), "INSERT INTO `log_reports` (`Oyuncu`, `Soru`, `Yetkili`, `Cevap`, `Tarih`) VALUES('%s', '%s', '%s', '%s', '%s')", ReturnName(ReportData[reportid][rPlayer], 1), SQL_ReturnEscaped(text), PlayerData[playerid][pAdminName], SQL_ReturnEscaped(cevap), ReturnDate());
		mysql_tquery(mysqlM, query);
		Report_Remove(reportid);
		PlayerData[playerid][pReportCount]++;
		cmd_raporlar(playerid, "yoruks");
	}
	else
	{
	    ReportData[GetPVarInt(playerid, "t_SelectedReport")][rYetkili] = INVALID_PLAYER_ID;
		cmd_raporlar(playerid, "yoruks");
	}
	return 1;
}

Dialog:Talepler4(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new reportid = GetPVarInt(playerid, "t_SelectedReport");
	    if(!ReportData[reportid][rExists]) return SendErrorMessage(playerid, "Bu rapor zaten cevaplanmýþ veya silinmiþ.");
		new dakika;
		if(sscanf(inputtext, "d", dakika))
		{
		    new str[64];
			format(str, sizeof(str), "{FF6347}%s(%d)", ReturnName(ReportData[reportid][rPlayer], 1), ReportData[reportid][rPlayer]);
	        return Dialog_Show(playerid, Talepler4, DIALOG_STYLE_INPUT, str, "Lütfen dakika giriniz:", "Engelle", "Kapat");
		}
		if(dakika < 0 || dakika > 500)
		{
		    new str[64];
			format(str, sizeof(str), "{FF6347}%s(%d)", ReturnName(ReportData[reportid][rPlayer], 1), ReportData[reportid][rPlayer]);
	        return Dialog_Show(playerid, Talepler4, DIALOG_STYLE_INPUT, str, "Lütfen dakika giriniz:", "Engelle", "Kapat");
		}

		SendErrorMessage(ReportData[reportid][rPlayer], "%s adlý yetkili %d dakika boyunca rapor göndermeni engelledi.", PlayerData[playerid][pAdminName], dakika);
		SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s adlý yetkili %s(%d) adlý oyuncunun %d dakika rapor atmasýný engelledi.", PlayerData[playerid][pAdminName], ReturnName(ReportData[reportid][rPlayer], 1), ReportData[reportid][rPlayer], dakika);
		//SendTesterMessage2(COLOR_LIGHTRED, "AdmCmd: %s adlý yetkili %s(%d) adlý oyuncunun %d dakika rapor atmasýný engelledi.", PlayerData[playerid][pAdminName], ReturnName(ReportData[reportid][rPlayer], 0), ReportData[reportid][rPlayer], dakika);
		dakika = dakika * 60;
		PlayerData[ReportData[reportid][rPlayer]][pReportMute] = gettime() + dakika;
		Report_Remove(reportid);
		PlayerData[playerid][pReportCount]++;
		cmd_raporlar(playerid, "yoruks");
	}
	else
	{
	    ReportData[GetPVarInt(playerid, "t_SelectedReport")][rYetkili] = INVALID_PLAYER_ID;
		cmd_raporlar(playerid, "yoruks");
	}
	return 1;
}

CMD:freeze(playerid, params[])
{
	if(PlayerData[playerid][pAdmin] < 1 && PlayerData[playerid][pTester] < 3) return SendErrorMessage(playerid, "Yetersiz yetki.");
    new id;
    if(sscanf(params, "u", id)) return SendSyntaxMessage(playerid, "(/un)freeze [id]");
    if(!IsPlayerConnected(id) || !PlayerData[id][pLogged]) return SendErrorMessage(playerid, E_INVALID_ID);
    PlayerData[id][pFreezed] = !PlayerData[id][pFreezed]; TogglePlayerControllable(id,(PlayerData[id][pFreezed]) ? false : true);
	SendServerMessage(playerid, "%s adlý oyuncuyu %s.", ReturnName(id, 1), (PlayerData[id][pFreezed]) ? "dondurdun" : "çözdün");
    SendServerMessage(id, "%s adlý yetkili seni %s.", PlayerData[playerid][pAdminName], (PlayerData[id][pFreezed]) ? "dondurdu" : "çözdü");
    SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s kiþisi %s iþlemini %s kiþisinde uyguladý.", PlayerData[playerid][pAdminName], (PlayerData[id][pFreezed]) ? "dondurma" : "çözme", ReturnName(id, 1));
    return 1;
}

CMD:slap(playerid, params[])
{
	if(PlayerData[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "Yetersiz yetki.");
    new id;
    if(sscanf(params, "u", id)) return SendSyntaxMessage(playerid, "/slap [id]");
    if(!IsPlayerConnected(id) || !PlayerData[id][pLogged]) return SendErrorMessage(playerid, "Geçersiz ID.");
    if(PlayerData[id][pAdmin] > PlayerData[playerid][pAdmin] && id != playerid) return SendErrorMessage(playerid, "Senden yüksek kiþilere bunu yapamazsýn.");
    SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s adlý yetkili %s kiþisini slapladý.", PlayerData[playerid][pAdminName], ReturnName(id, 1));
    new Float:x, Float:y, Float:z;
    GetPlayerPos(id, x, y, z), SetPlayerPos(id, x, y, z + 4);
    return 1;
}

CMD:clearchat(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "Yetersiz yetki.");
    for (new i = 0; i < 25; i ++) SendClientMessageToAll(-1, "");
    SendAdminAlert(2, COLOR_LIGHTRED, "AdmCmd: %s adlý yetkili sohbeti temizledi.", PlayerData[playerid][pAdminName]);
	return 1;
}
CMD:cc(playerid, params[]) return cmd_clearchat(playerid, "\1");

// Helper Commands

CMD:ooc(playerid, params[]) return cmd_o(playerid, params);
CMD:o(playerid, params[])
{
	if(isnull(params))return SendSyntaxMessage(playerid, "/o [metin]");
    if(strlen(params) > 64)
	{
        foreach (new i : Player)
		{
		    SendClientMessageEx(i, 0xA9C4E4FF, "[Global Chat]%s: %.64s...", PlayerData[playerid][pAdminName], params);
		    SendClientMessageEx(i, 0xA9C4E4FF, "...%s ))", params[64]);
		}
	}
	else
	{
        foreach (new i : Player)
		{
		    SendClientMessageEx(i, 0xA9C4E4FF, "[Global Chat] %s: %s", PlayerData[playerid][pAdminName], params);
		}
	}
	return 1;
}

CMD:jetpack(playerid, params[])
{
	if(PlayerData[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "Yetersiz yetki.");
    new userid;
	if(sscanf(params, "u", userid))
 	{
 	    //PlayerData[playerid][pJetpack] = 1;
	 	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
		SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s jetpack aldý.", PlayerData[playerid][pAdminName]);
	}
	else
	{
		if(!IsPlayerConnected(userid)) return SendErrorMessage(playerid, E_INVALID_ID);
		//PlayerData[userid][pJetpack] = 1;
		SetPlayerSpecialAction(userid, SPECIAL_ACTION_USEJETPACK);
		SendServerMessage(playerid, "%s adlý oyuncuya jetpack verdiniz.", ReturnName(userid, 1));
		SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s kiþisi %s kiþisine jetpack verdi.", PlayerData[playerid][pAdminName], ReturnName(userid, 1));
	}
	return 1;
}

CMD:legfix(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1 && PlayerData[playerid][pTester] < 3) return SendErrorMessage(playerid, "Yetersiz yetki.");
	new userid;
	if(sscanf(params, "u", userid)) return SendSyntaxMessage(playerid, "/legfix [id]");
    if(!IsPlayerConnected(userid)) return SendErrorMessage(playerid, E_INVALID_ID);
	if(GetPVarInt(userid, "t_InjuredLeg") == 0) return SendErrorMessage(playerid, "Oyuncunun bacaðý yaralý deðil.");
	DeletePVar(userid, "t_InjuredLeg");
	ClearAnimations(userid);
	ApplyAnimation(userid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
	SendServerMessage(userid, "%s adlý yetkili sana legfix attý.", PlayerData[playerid][pAdminName]);
	SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s adlý yetkili %s(%d) adlý oyuncuya legfix attý.", PlayerData[playerid][pAdminName], ReturnName(userid, 1), userid);
	return 1;
}

CMD:sethp(playerid, params[])
{
	if(PlayerData[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "Yetersiz yetki.");
    new id, Float:health;
    if(sscanf(params, "uf", id, health)) return SendSyntaxMessage(playerid, "/sethp [id] [hp]");
    if(!IsPlayerConnected(id) || !PlayerData[id][pLogged]) return SendErrorMessage(playerid, "Geçersiz ID.");
    if(health < 0 || health > 100) return SendErrorMessage(playerid, "Geçersiz deðer. (0 - 100)");
    CanDegistir(id, health);
	SendServerMessage(id, "%s canýný %.0f olarak ayarladý.", PlayerData[playerid][pAdminName], health);
    SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s, %s kiþisinin HP'sini %.0f olarak ayarladý.", PlayerData[playerid][pAdminName], ReturnName(id, 1), health);
    return 1;
}

CMD:setarmour(playerid, params[])
{
	if(PlayerData[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "Yetersiz yetki.");
    new id, Float:zirh;
    if(sscanf(params, "uf", id, zirh)) return SendSyntaxMessage(playerid, "/setarmor [id] [armor]");
    if(!IsPlayerConnected(id) || !PlayerData[id][pLogged]) return SendErrorMessage(playerid, "Geçersiz ID.");
    if(zirh < 0 || zirh > 100) return SendErrorMessage(playerid, "Geçersiz deðer. (0 - 100)");
    ZirhDegistir(id, zirh);
	SendServerMessage(id, "%s zýrhýný %.0f olarak ayarladý.", PlayerData[playerid][pAdminName], zirh);
    SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s, %s kiþisinin zýrhýný %.0f olarak ayarladý.", PlayerData[playerid][pAdminName], ReturnName(id, 1), zirh);
    return 1;
}

CMD:ban(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 2) return SendErrorMessage(playerid, "Yetersiz yetki.");
	new userid, type, day, reason[32];
	if(sscanf(params, "udds[32]", userid, type, day, reason)) return SendSyntaxMessage(playerid, "/ban [id] [tür (0 = karakter, 1 = hesap)] [gün (0 = sýnýrsýz)] [sebep]");
    if(!IsPlayerConnected(userid)) return SendErrorMessage(playerid, E_INVALID_ID);
	if(userid == playerid) return SendErrorMessage(playerid, "Kendinizi yasaklayamazsýnýz.");
    if(PlayerData[userid][pAdmin] > PlayerData[playerid][pAdmin]) return SendAdminAlert(1, COLOR_LIGHTRED, "AdmCmd: %s adlý yetkili %s adlý yetkiliyi yasaklamaya çalýþtý.", PlayerData[playerid][pAdminName], PlayerData[userid][pAdminName]), SendErrorMessage(playerid, "Belirtilen oyuncu sizden yüksek yetkiye sahiptir.");
	if(type < 0 || type > 1) return SendErrorMessage(playerid, "Yasaklama türü 0 veya 1 olmalýdýr.");
	if(day < 0 || day > 999) return SendErrorMessage(playerid, "Gün 0 ile 999 arasýnda olmalýdýr.");
	foreach (new i : Player) if(i != userid && !strcmp(PlayerData[i][pIP], PlayerData[userid][pIP])) KickEx(i);
    new query[182];
	SendClientMessageToAllEx(COLOR_LIGHTRED, "AdmCmd: %s adlý oyuncu %s tarafýndan sunucudan %s sebebiyle yasaklandý.", ReturnName(userid, 1), PlayerData[playerid][pAdminName], reason);
    Ban_Ex(PlayerData[userid][pIP], ReturnName(userid), PlayerData[userid][pForumID], type, reason, PlayerData[playerid][pID], day * 86400);
	KickEx(userid, 1000);
	return 1;
}


CMD:skin(playerid, params[])
{
    if(PlayerData[playerid][pAdmin] < 1)  return SendErrorMessage(playerid, "Yetersiz yetki.");
    static userid, skinid;
	if(sscanf(params, "ud", userid, skinid))  return SendSyntaxMessage(playerid, "/skin [id] [skin id]");
    if(!IsPlayerConnected(userid)) return SendErrorMessage(playerid, E_INVALID_ID);
	if(skinid < 0) return SendErrorMessage(playerid, "Geçersiz skin ID. Skinler 0-311 arasýnda deðiþir.");
	SetPlayerSkin(userid, skinid);
	PlayerData[userid][pSkin] = skinid;
    SQL_SavePlayer(userid, 0);
	return 1;
}

CMD:ahelp(playerid, params[])
{
	if(PlayerData[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "Yetersiz yetki.");

	    SendServerMessage(playerid, "MODERATOR: /mjail - /a - /baslat - /cc - /kick - /spawn - /slap - /uyari - /aspec - /aspecoff, - /aduty");
	    SendServerMessage(playerid, "MODERATOR: /h - /raporlar - /restart - /sustur");
	if(PlayerData[playerid][pAdmin] >= 2)
	{
		SendServerMessage(playerid, "GAME ADMIN: /ban - /setvw - /setint - /goto - /gethere - /sethp - /freeze - /sustur");
		SendServerMessage(playerid, "GAME ADMIN: /jail - /unjail - /engelsifirla - /dmkitle - /cezaver");
	}
	if(PlayerData[playerid][pAdmin] >= 3)
	{
		SendServerMessage(playerid, "LEAD ADMIN: /offban - /unban - /makehelper - /gotopos - /getcar - /gotocar - /setweather - /settime");
		SendServerMessage(playerid, "LEAD ADMIN: /setskin - /setname - /setscore - /setarmor - /freeze2 - /fkapat - /muzik,");
	}
	if(PlayerData[playerid][pAdmin] >= 4)
		SendServerMessage(playerid, "SERVER MANAGEMENT: /makeadmin - /donatoryap - /event - /bakim - /dox - /gmx");
	return 1;
}

CMD:aspec(playerid, params[])
{
	if(PlayerData[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "Yetersiz yetki.");
	new hedefid;
	if(sscanf(params, "u", hedefid)) return SendSyntaxMessage(playerid, "/aspec [hedef adý/ID]");
  	if(!IsPlayerConnected(hedefid) || !PlayerData[hedefid][pLogged]) return SendErrorMessage(playerid, "Geçersiz ID.");
	if(playerid == hedefid)
		return SendErrorMessage(playerid, "Kendini izleyemezsin.");
	GetPlayerPos(playerid, PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2]);
	PlayerData[playerid][pWorld] = GetPlayerVirtualWorld(playerid);
	PlayerData[playerid][pInterior] = GetPlayerInterior(playerid);
	SetPlayerInterior(playerid, GetPlayerInterior(hedefid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(hedefid));
	TogglePlayerSpectating(playerid, 1);
	if(IsPlayerInAnyVehicle(hedefid))
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(hedefid));
	else PlayerSpectatePlayer(playerid, hedefid);
	return 1;
}

CMD:aspecoff(playerid, params[])
{
	if(PlayerData[playerid][pAdmin] < 1) return SendErrorMessage(playerid, "Yetersiz yetki.");
	TogglePlayerSpectating(playerid, 0);
	SetPlayerInterior(playerid, PlayerData[playerid][pInterior]);
	SetPlayerVirtualWorld(playerid, PlayerData[playerid][pWorld]);
	M_SetPlayerPos(playerid, PlayerData[playerid][pPos][0], PlayerData[playerid][pPos][1], PlayerData[playerid][pPos][2]);
	SendServerMessage(playerid, "Ýzlemeden çýktýn.");
	return 1;
}

CMD:elm(playerid, params)
{
	if(PlayerData[playerid][pInGame] == false) return SendErrorMessage(playerid, "Oyunda deðilsin.");
	if(PlayerData[playerid][pPolice] == false) return SendErrorMessage(playerid, "Polis deðilsin.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendErrorMessage(playerid, "Araçta deðilsin.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendErrorMessage(playerid, "Sürücü koltuðunda deðilsin.");
	new aracid = GetPlayerVehicleID(playerid);
	if(Flasor[aracid] == 1)
	{
		Flasor[aracid] = 0;
		KillTimer(FlasorTimer[aracid]);
		GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(aracid, engine, VEHICLE_PARAMS_OFF, alarm, doors, bonnet, boot, objective);
		SendServerMessage(playerid, "ELM kapatýldý.");
		return 1;
	}
	if(Flasor[aracid] == 0)
	{
	    FlasorDurum[aracid] = 1;
		FlasorTimer[playerid] = SetTimerEx("Flas", 200, true, "d", aracid);
		GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(aracid, engine, VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);
		SendServerMessage(playerid, "ELM kapatýldý.");
		Flasor[aracid] = 1;
		return 1;
	}
	return 1;
}
