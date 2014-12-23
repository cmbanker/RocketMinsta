// Chaiomanot: Jan 9th 2012:
//    Because the game type/mode/whatever was a huge mess when I got here,
//    I made this file and rewrote and pointed other code to here. Now it's
//    still a mess but at least a little more under control. Doing this also
//    removed the bug that would wipe the type/mode on the RM GUI reload. :-)
//    Besides 'Precious', I also add the 'Nothing' gametype, as an easy
//    way to deal with gametype related errors, when my other attempted
//    methods of correction failed.
// Chaiomanot: Feb 13th 2012:
//    Moved contants to header file for better unification.
//    And added type 'all' to list, for ease of map type handling.
//    Renamed functions to have more sane names.
//    Added menu & client gametype getter & setter procedures, so now
//    this file now handles _all_ game type getting & setting.
//    Added RPS and Infection to the lists

float gametype_GetMenu ()
{
	if(cvar("g_dm"))               return GAME_DEATHMATCH;
	if(cvar("g_tdm"))              return GAME_TEAM_DEATHMATCH;
	if(cvar("g_domination"))       return GAME_DOMINATION;
	if(cvar("g_ctf"))              return GAME_CTF;
	if(cvar("g_runematch"))        return GAME_RUNEMATCH;
	if(cvar("g_lms"))              return GAME_LMS;
	if(cvar("g_arena"))            return GAME_ARENA;
	if(cvar("g_keyhunt"))          return GAME_KEYHUNT;
	if(cvar("g_assault"))          return GAME_ASSAULT;
	if(cvar("g_onslaught"))        return GAME_ONSLAUGHT;
	if(cvar("g_race"))             return GAME_RACE;
	if(cvar("g_nexball"))          return GAME_NEXBALL;
	if(cvar("g_cts"))              return GAME_CTS;
	if(cvar("g_freezetag"))        return GAME_FREEZETAG;
	if(cvar("g_total_domination")) return GAME_TOTAL_DOMINATION;
	if(cvar("g_vip"))              return GAME_VIP;
	if(cvar("g_prec"))             return GAME_PRECIOUS;
//	if(cvar("g_inf"))              return GAME_INFECTION;
	if(cvar("g_jailbreak"))        return GAME_JAILBREAK;
    if(cvar("g_clanarena"))        return GAME_CLANARENA;
	if(cvar("g_no"))               return GAME_NOTHING;
	return 0;
}

void cvar_set_ifeq (float l_id, string l_name, float l_value) {
    if(l_id == l_value) cvar_set(l_name, "1"); else cvar_set(l_name, "0");   }

void gametype_SetMenu (float l_id)
{
	cvar_set_ifeq(l_id, "g_dm",               GAME_DEATHMATCH);
	cvar_set_ifeq(l_id, "g_tdm",              GAME_TEAM_DEATHMATCH);
	cvar_set_ifeq(l_id, "g_domination",       GAME_DOMINATION);
	cvar_set_ifeq(l_id, "g_ctf",              GAME_CTF);
	cvar_set_ifeq(l_id, "g_runematch",        GAME_RUNEMATCH);
	cvar_set_ifeq(l_id, "g_lms",              GAME_LMS);
	cvar_set_ifeq(l_id, "g_arena",            GAME_ARENA);
	cvar_set_ifeq(l_id, "g_keyhunt",          GAME_KEYHUNT);
	cvar_set_ifeq(l_id, "g_assault",          GAME_ASSAULT);
	cvar_set_ifeq(l_id, "g_onslaught",        GAME_ONSLAUGHT);
	cvar_set_ifeq(l_id, "g_race",             GAME_RACE);
	cvar_set_ifeq(l_id, "g_nexball",          GAME_NEXBALL);
	cvar_set_ifeq(l_id, "g_cts",              GAME_CTS);
	cvar_set_ifeq(l_id, "g_freezetag",        GAME_FREEZETAG);
	cvar_set_ifeq(l_id, "g_total_domination", GAME_TOTAL_DOMINATION);
	cvar_set_ifeq(l_id, "g_vip",              GAME_VIP);
	cvar_set_ifeq(l_id, "g_prec",             GAME_PRECIOUS);
//	cvar_set_ifeq(l_id, "g_inf",              GAME_INFECTION);
	cvar_set_ifeq(l_id, "g_jailbreak",        GAME_JAILBREAK);
    cvar_set_ifeq(l_id, "g_clanarena",        GAME_CLANARENA);
	cvar_set_ifeq(l_id, "g_no",               GAME_NOTHING);
}

#ifdef SERVER_SIDE

float gametype_Extrapolate ()
{
	local float game_new;
	game_new = 0;

	if(cvar("g_dm") || g_dm) {
		game_new = GAME_DEATHMATCH; }
	if(cvar("g_tdm") || g_tdm) {
		if(game_new) return 0;
		game_new = GAME_TEAM_DEATHMATCH; }
	if(cvar("g_domination") || g_domination) {
		if(game_new) return 0;
		game_new = GAME_DOMINATION; }
	if(cvar("g_ctf") || g_ctf) {
		if(game_new) return 0;
		game_new = GAME_CTF; }
	if(cvar("g_runematch") || g_runematch) {
		if(game_new) return 0;
		game_new = GAME_RUNEMATCH; }
	if(cvar("g_lms") || g_lms) {
		if(game_new) return 0;
		game_new = GAME_LMS; }
	if(cvar("g_arena") || g_arena) {
		if(game_new) return 0;
		game_new = GAME_ARENA; }
	if(cvar("g_keyhunt") || g_keyhunt || _is_key_hunt) {
		if(game_new) return 0;
		game_new = GAME_KEYHUNT; }
	if(cvar("g_assault") || g_assault) {
		if(game_new) return 0;
		game_new = GAME_ASSAULT; }
	if(cvar("g_onslaught") || g_onslaught) {
		if(game_new) return 0;
		game_new = GAME_ONSLAUGHT; }
	if(cvar("g_race") || g_race) {
		if(game_new) return 0;
		game_new = GAME_RACE; }
	if(cvar("g_nexball") || g_nexball) {
		if(game_new) return 0;
		game_new = GAME_NEXBALL; }
	if(cvar("g_cts") || g_cts) {
		if(game_new) return 0;
		game_new = GAME_CTS; }
	if(cvar("g_freezetag") || g_freezetag) {
		if(game_new) return 0;
		game_new = GAME_FREEZETAG; }
	if(cvar("g_total_domination") || g_total_domination) {
		if(game_new && game_new != GAME_DOMINATION) return 0;
		game_new = GAME_TOTAL_DOMINATION; }
	if(cvar("g_vip") || g_vip) {
		if(game_new) return 0;
		game_new = GAME_VIP; }
	if(cvar("g_prec") || g_prec) {
		if(game_new) return 0;
		game_new = GAME_PRECIOUS; }
	/*
	if(cvar("g_inf") || g_inf) {
		if(game_new) return 0;
		game_new = GAME_INFECTION; }
	*/
	if(cvar("g_jailbreak") || g_jailbreak) {
		if(game_new) return 0;
		game_new = GAME_JAILBREAK; }
    if(cvar("g_clanarena") || g_clanarena) {
        if(game_new) return 0;
        game_new = GAME_CLANARENA; }
	if(cvar("g_no") || g_no) {
		if(game_new) return 0;
		game_new = GAME_NOTHING; }

	return game_new;
}

void gametype_Set (float gametype)
{
	gametype_Reset ();
	switch(gametype)
	{
		case GAME_DEATHMATCH:
			cvar_set("g_dm", "1"); g_dm = 1;
			break;
		case GAME_TEAM_DEATHMATCH:
			cvar_set("g_tdm", "1"); g_tdm = 1;
			break;
		case GAME_DOMINATION:
			cvar_set("g_domination", "1"); g_domination = 1;
			break;
		case GAME_CTF:
			cvar_set("g_ctf", "1"); g_ctf = 1;
			break;
		case GAME_RUNEMATCH:
			cvar_set("g_runematch", "1"); g_runematch = 1;
			break;
		case GAME_LMS:
			cvar_set("g_lms", "1"); g_lms = 1;
			break;
		case GAME_ARENA:
			cvar_set("g_arena", "1"); g_arena = 1;
			break;
		case GAME_KEYHUNT:
			cvar_set("g_keyhunt", "1"); g_keyhunt = 1;
			_is_key_hunt = 0;
			break;
		case GAME_ASSAULT:
			cvar_set("g_assault", "1"); g_assault = 1;
			break;
		case GAME_ONSLAUGHT:
			cvar_set("g_onslaught", "1"); g_onslaught = 1;
			break;
		case GAME_RACE:
			cvar_set("g_race", "1"); g_race = 1;
			break;
		case GAME_NEXBALL:
			cvar_set("g_nexball", "1"); g_nexball = 1;
			break;
		case GAME_CTS:
			cvar_set("g_cts", "1"); g_cts = 1;
			break;
		case GAME_FREEZETAG:
			cvar_set("g_freezetag", "1"); g_freezetag = 1;
			break;
		case GAME_TOTAL_DOMINATION:
			cvar_set("g_domination", "1"); g_domination = 1;
			cvar_set("g_total_domination", "1"); g_total_domination = 1;
			break;
		case GAME_VIP:
			cvar_set("g_vip", "1"); g_vip = 1;
			break;
		case GAME_PRECIOUS:
			cvar_set("g_prec", "1"); g_prec = 1;
			break;
		/*
		case GAME_INFECTION:
			cvar_set("g_inf", "1"); g_inf = 1;
			break;
		*/
		case GAME_JAILBREAK:
			cvar_set("g_jailbreak", "1"); g_jailbreak = 1;
			break;
        case GAME_CLANARENA:
            cvar_set("g_clanarena", "1"); g_clanarena = 1;
            break;
		case GAME_NOTHING:
			cvar_set("g_no", "1"); g_no = 1;
			break;
		default:
			return;
	}
	game = gametype;
	cvar_set("gamecfg", ftos(gametype));
}

void gametype_Reset ()
{
	cvar_set("g_dm",               "0"); g_dm               = 0;
	cvar_set("g_tdm",              "0"); g_tdm              = 0;
	cvar_set("g_domination",       "0"); g_domination       = 0;
	cvar_set("g_ctf",              "0"); g_ctf              = 0;
	cvar_set("g_runematch",        "0"); g_runematch        = 0;
	cvar_set("g_lms",              "0"); g_lms              = 0;
	cvar_set("g_arena",            "0"); g_arena            = 0;
	cvar_set("g_keyhunt",          "0"); g_keyhunt          = 0;
	cvar_set("g_assault",          "0"); g_assault          = 0;
	cvar_set("g_onslaught",        "0"); g_onslaught        = 0;
	cvar_set("g_race",             "0"); g_race             = 0;
	cvar_set("g_nexball",          "0"); g_nexball          = 0;
	cvar_set("g_cts",              "0"); g_cts              = 0;
	cvar_set("g_freezetag",        "0"); g_freezetag        = 0;
	cvar_set("g_total_domination", "0"); g_total_domination = 0;
	cvar_set("g_vip",              "0"); g_vip              = 0;
	cvar_set("g_prec",             "0"); g_prec             = 0;
	cvar_set("g_inf",              "0"); g_inf              = 0;
	cvar_set("g_jailbreak",        "0"); g_jailbreak        = 0;
    cvar_set("g_clanarena",        "0"); g_clanarena        = 0;
	cvar_set("g_no",               "0"); g_no               = 0;

	cvar_set("gamecfg", "0");
	_is_key_hunt = 0;
	cvar_set("teamplay", "0"); teams_matter = 0;
	forbidrestart = 0;
	game = 0;
}

#endif

float gametype_ID_to_MapID (float l_gametype)
{
	switch(l_gametype)
	{
		case GAME_DEATHMATCH:       return MAPINFO_TYPE_DEATHMATCH;
		case GAME_TEAM_DEATHMATCH:  return MAPINFO_TYPE_DEATHMATCH;
		case GAME_DOMINATION:       return MAPINFO_TYPE_DOMINATION;
		case GAME_CTF:              return MAPINFO_TYPE_CTF;
		case GAME_RUNEMATCH:        return MAPINFO_TYPE_DEATHMATCH;
		case GAME_LMS:              return MAPINFO_TYPE_DEATHMATCH;
		case GAME_ARENA:            return MAPINFO_TYPE_DEATHMATCH;
		case GAME_KEYHUNT:          return MAPINFO_TYPE_DEATHMATCH;
		case GAME_ASSAULT:          return MAPINFO_TYPE_ASSAULT;
		case GAME_ONSLAUGHT:        return MAPINFO_TYPE_ONSLAUGHT;
		case GAME_RACE:             return MAPINFO_TYPE_RACE;
		case GAME_NEXBALL:          return MAPINFO_TYPE_NEXBALL;
		case GAME_CTS:              return MAPINFO_TYPE_CTS;
		case GAME_FREEZETAG:        return MAPINFO_TYPE_DEATHMATCH;
		case GAME_TOTAL_DOMINATION: return MAPINFO_TYPE_DOMINATION;
		case GAME_VIP:              return MAPINFO_TYPE_DEATHMATCH;
		case GAME_PRECIOUS:         return MAPINFO_TYPE_DEATHMATCH;
//		case GAME_INFECTION:        return MAPINFO_TYPE_DEATHMATCH;
		case GAME_JAILBREAK:        return MAPINFO_TYPE_JAILBREAK;
        case GAME_CLANARENA:        return MAPINFO_TYPE_DEATHMATCH;
		case GAME_NOTHING:          return MAPINFO_TYPE_DEATHMATCH;
		case GAME_ALL:              return MAPINFO_TYPE_ALL;
		default:                    return 0;
	}
}

float gametype_MapID_to_ID (float l_maptype)
{
	switch(l_maptype)
	{
		case MAPINFO_TYPE_DEATHMATCH:      return GAME_DEATHMATCH;
		case MAPINFO_TYPE_TEAM_DEATHMATCH: return GAME_TEAM_DEATHMATCH;
		case MAPINFO_TYPE_DOMINATION:      return GAME_DOMINATION;
		case MAPINFO_TYPE_CTF:             return GAME_CTF;
		case MAPINFO_TYPE_RUNEMATCH:       return GAME_RUNEMATCH;
		case MAPINFO_TYPE_LMS:             return GAME_LMS;
		case MAPINFO_TYPE_ARENA:           return GAME_ARENA;
		case MAPINFO_TYPE_KEYHUNT:         return GAME_KEYHUNT;
		case MAPINFO_TYPE_ASSAULT:         return GAME_ASSAULT;
		case MAPINFO_TYPE_ONSLAUGHT:       return GAME_ONSLAUGHT;
		case MAPINFO_TYPE_RACE:            return GAME_RACE;
		case MAPINFO_TYPE_NEXBALL:         return GAME_NEXBALL;
		case MAPINFO_TYPE_CTS:             return GAME_CTS;
		case MAPINFO_TYPE_JAILBREAK:       return GAME_JAILBREAK;
        case MAPINFO_TYPE_CLANARENA:       return GAME_CLANARENA;
		case MAPINFO_TYPE_ALL:             return GAME_ALL;
		default:                           return 0;
	}
}

float gametype_Name_to_ID (string l_typename)
{
	string typename = gametype_Name_to_Name(l_typename);
	     if(typename == "dm"      ) return GAME_DEATHMATCH;
	else if(typename == "tdm"     ) return GAME_TEAM_DEATHMATCH;
	else if(typename == "dom"     ) return GAME_DOMINATION;
	else if(typename == "ctf"     ) return GAME_CTF;
	else if(typename == "rune"    ) return GAME_RUNEMATCH;
	else if(typename == "lms"     ) return GAME_LMS;
	else if(typename == "arena"   ) return GAME_ARENA;
	else if(typename == "kh"      ) return GAME_KEYHUNT;
	else if(typename == "as"      ) return GAME_ASSAULT;
	else if(typename == "ons"     ) return GAME_ONSLAUGHT;
	else if(typename == "rc"      ) return GAME_RACE;
	else if(typename == "nexball" ) return GAME_NEXBALL;
	else if(typename == "cts"     ) return GAME_CTS;
	else if(typename == "ft"      ) return GAME_FREEZETAG;
	else if(typename == "vip"     ) return GAME_VIP;
	else if(typename == "totaldom") return GAME_TOTAL_DOMINATION;
	else if(typename == "prec"    ) return GAME_PRECIOUS;
//	else if(typename == "inf"     ) return GAME_INFECTION;
	else if(typename == "jb"      ) return GAME_JAILBREAK;
    else if(typename == "ca"      ) return GAME_CLANARENA;
	else if(typename == "no"      ) return GAME_NOTHING;
	else if(typename == "all"     ) return GAME_ALL;
	else                            return 0;
}

string gametype_ID_to_Name (float l_gametype)
{
	switch(l_gametype)
	{
		case GAME_DEATHMATCH:       return "dm";
		case GAME_TEAM_DEATHMATCH:  return "tdm";
		case GAME_DOMINATION:       return "dom";
		case GAME_CTF:              return "ctf";
		case GAME_RUNEMATCH:        return "rune";
		case GAME_LMS:              return "lms";
		case GAME_ARENA:            return "arena";
		case GAME_KEYHUNT:          return "kh";
		case GAME_ASSAULT:          return "as";
		case GAME_ONSLAUGHT:        return "ons";
		case GAME_RACE:             return "rc";
		case GAME_NEXBALL:          return "nexball";
		case GAME_CTS:              return "ctf";
		case GAME_FREEZETAG:        return "ft";
		case GAME_TOTAL_DOMINATION: return "totaldom";
		case GAME_VIP:              return "vip";
		case GAME_PRECIOUS:         return "prec";
//		case GAME_INFECTION:        return "inf";
		case GAME_JAILBREAK:        return "jb";
        case GAME_CLANARENA:        return "ca";
		case GAME_NOTHING:          return "no";
		default:                    return "";
	}
}

string gametype_ID_to_LongName (float l_gametype)
{
	switch(l_gametype)
	{
		case GAME_DEATHMATCH:       return "Deathmatch";
		case GAME_TEAM_DEATHMATCH:  return "Team Deathmatch";
		case GAME_DOMINATION:       return "Domination";
		case GAME_CTF:              return "Capture the Flag";
		case GAME_RUNEMATCH:        return "Runematch";
		case GAME_LMS:              return "Last Man Standing";
		case GAME_ARENA:            return "Arena";
		case GAME_KEYHUNT:          return "Key Hunt";
		case GAME_ASSAULT:          return "Assault";
		case GAME_ONSLAUGHT:        return "Onslaught";
		case GAME_RACE:             return "Race";
		case GAME_NEXBALL:          return "Nexball";
		case GAME_CTS:              return "Race CTS";
		case GAME_FREEZETAG:        return "Freeze Tag";
		case GAME_TOTAL_DOMINATION: return "Total Domination";
		case GAME_VIP:              return "VIP";
		case GAME_PRECIOUS:         return "Precious";
//		case GAME_INFECTION:        return "Infection";
		case GAME_JAILBREAK:        return "Jailbreak";
        case GAME_CLANARENA:        return "Clan Arena";
		case GAME_NOTHING:          return "Nothing";
		case GAME_ALL:              return "All";
		default:                    return "Unknown";
	}
}

string gametype_Name_to_Name (string typename)
{
	switch(typename)
	{
		case "dm": case "Deathmatch": // Deathmatch is aka Free For All in newer FPSs
		case "deathmatch": case "ffa": case "freeforall":
			return "dm";
		case "tdm": case "Team Deathmatch":
		case "teamdm": case "teamdeathmatch":
			return "tdm";
		case "dom": case "Domination":
		case "domination":
			return "dom";
		case "ctf": case "Capture the Flag":
		case "capturetheflag":
			return "ctf";
		case "rune": case "Runematch":
		case "runematch":
			return "rune";
		case "lms": case "Last Man Standing":
		case "lastmanstanding":
			return "lms";
		case "arena": case "Arena":
			return "arena";
		case "kh": case "Key Hunt":
		case "keyhunt":
			return "kh";
		case "as": case "Assault":
		case "assault":
			return "as";
		case "ons": case "Onslaught":
		case "onslaught":
			return "ons";
		case "rc": case "Race":
		case "race":
			return "rc";
		case "nexball": case "Nexball":
		case "ball":
			return "nexball";
		case "cts": case "Race CTS":
		case "racects":
			return "cts";
		case "ft": case "Freeze Tag":
		case "tag": case "freezetag":
			return "ft";
		case "totaldom": case "Total Domination":
		case "tdom": case "totaldomination":
			return "totaldom";
		case "vip": case "VIP":
			return "vip";
		case "prec": case "precious": case "Precious": // Precious is very similar to Xonotic's Keep Away
		case "runehunt": case "rh": case "keepaway": case "ka":
			return "prec";
		/*
		case "inf": case "Infection":
		case "zombies": case "stayalive":
			return "inf";
		*/
		case "jb": case "jailbreak": case "jbreak": case "jail": case "Jailbreak":
			return "jb";
        case "ca": case "clanarena": case "teamlms": case "tlms":
            return "ca";
		case "no": case "Nothing":
		case "nothing": case "none":
			return "no";
		case "all": case "All":
			return "all";
		default:
			return "";
	}
}

string gametype_Name_to_Description(string typename) {
	switch(gametype_Name_to_Name(typename))
	{
		case "ctf":
			return "Each team has a flag located in its base.\nYou must steal the enemy flag and bring it to yours to score.";
		case "kh":
			return "Every team begins the round with one key.\nSteal all the keys and bring them together to score.";
		case "ft":
			return "Frag your opponents to turn them into ice blocks.\nFreeze the entire opposite team to win the round.\nYou can unfreeze your frozen teammates by standing next to them.";
		case "dom":
			return "Several control points are placed around the map.\nWalk over a control point to capture it.\nWhile captured, control points keep adding to your score until the limit is reached.";
		case "totaldom":
			return "A round-based Domination spin-off.\nYou must take over ALL of the control points on the map to win the round.";
		case "vip":
			return "Each team gets a VIP player (as in Very Important Person).\nYou must kill the enemy VIP to win the round.";
		case "dm":
			return "Free-for-all: the player who gets the most frags wins.";
		case "tdm":
			return "Team-based deathmatch: the team that gets the most frags wins.";
		case "jb":
			return "Frag the enemy team to send them into a jail!\nCapture their controlpoint to release your imprisoned teammates.\nLock all of your opponents to win the round.";
		case "prec":
			return "Deathmatch-like gametype.\nYou have to capture and hold the Precious rune in order to gain frag points.";
		case "ca":
            return "Team-based survival mode.\nYou Only Live Once (per round)!";
        
		// TODO: Describe other gametypes
	}

	return "No description is available for this gametype";
}

float gametype_Name_to_MapID (string l_typename)
{
	return gametype_ID_to_MapID(gametype_Name_to_ID(l_typename));
}

string gametype_MapID_to_Name (float l_mapid)
{
	return gametype_ID_to_Name(gametype_MapID_to_ID(l_mapid));
}

string gametype_Name_to_LongName (string l_name)
{
	return gametype_ID_to_LongName(gametype_Name_to_ID(l_name));
}

// end of file
