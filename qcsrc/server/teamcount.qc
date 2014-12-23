
float TeamCount_TotalTeams(void) {
    float i;
    
    if(time == 1)
        CheckAllowedTeams(world);
        // we must ensure c1..c4 are correct during the world initialization frame
        // for things like g_buffs_team_swap to work
    
    if(g_keyhunt)   // TODO: find out what the hell is going on here
        return kh_teams;
    
    if(c1 >= 0) ++i;
    if(c2 >= 0) ++i;
    if(c3 >= 0) ++i;
    if(c4 >= 0) ++i;
    
    return i;
}

void TeamCount_RecountPlayers(float(entity) alivecheck) {
    float i;
    float nteams;
    entity e;
    
    nteams = TeamCount_TotalTeams();
    
    for(i = 0; i < 4; ++i) {
        teamcount_playersalive[i] = 0;
        teamcount_playerstotal[i] = 0;
    }
    
    FOR_EACH_CLIENT(e) if(e.iscreature || ((g_jailbreak || g_clanarena) && e.jb_specteam)) {
        float idx = Team_Index(e.team);
        float fteqcc_sucks;
        
        fteqcc_sucks = teamcount_playerstotal[idx];
        teamcount_playerstotal[idx] = fteqcc_sucks + 1;
        
        if(alivecheck(e)) {
            fteqcc_sucks = teamcount_playersalive[idx];
            teamcount_playersalive[idx] = fteqcc_sucks + 1;
        }
    }
    
    FOR_EACH_REALCLIENT(e) {
        e.redalive_stat     = teamcount_playersalive[0];
        e.bluealive_stat    = teamcount_playersalive[1];
        e.yellowalive_stat  = ((nteams > 2)? teamcount_playersalive[2] : -1);
        e.pinkalive_stat    = ((nteams > 3)? teamcount_playersalive[3] : -1);
    }
}

float TeamCount_AliveCheck_Null(entity e) {
    return TRUE;
}

float TeamCount_NextTeam(float t) {
    float tc = TeamCount_TotalTeams();
    
    switch(t) {
        case COLOR_TEAM1:
            return COLOR_TEAM2;
        
        case COLOR_TEAM2:
            return ((tc > 2)? COLOR_TEAM3 : COLOR_TEAM1);
        
        case COLOR_TEAM3:
            return ((tc > 3)? COLOR_TEAM4 : ((tc < 3)? COLOR_TEAM3 : COLOR_TEAM1));
        
        case COLOR_TEAM4:
            return ((tc < 4)? COLOR_TEAM4 : COLOR_TEAM1);
    }
    
    return t;
}

entity TeamCount_PlayerPool_GetPlayer(entity pool, float idx) {
    return pool.(teamcount_playerpool[idx]);
}

float TeamCount_PlayerPool_PlayerValue(entity plr) {
    switch(cvar("g_balance_teams_method")) {
        case 1  :   return plr.scorekeeper.(scores[SP_SCORE]) / plr.playtime;
        case 2  :   return plr.scorekeeper.(scores[SP_DAMAGE]);
        case 3  :   return plr.scorekeeper.(scores[SP_DAMAGE]) / plr.playtime;
        case 4  :   return plr.scorekeeper.(scores[SP_KILLS]);
        case 5  :   return plr.scorekeeper.(scores[SP_KILLS]) / max(1, plr.scorekeeper.(scores[SP_DEATHS]));
        default :   return plr.scorekeeper.(scores[SP_SCORE]);
    }
    
    return 0;
}

float TeamCount_PlayerPool_GetValue(entity pool, float idx) {
    return TeamCount_PlayerPool_PlayerValue(TeamCount_PlayerPool_GetPlayer(pool, idx));
}

float TeamCount_PlayerPool_IndexOf(entity pool, entity plr) {
    float i; for(i = 0; i < pool.teamcount_poolsize; ++i)
        if(TeamCount_PlayerPool_GetPlayer(pool, i) == plr)
            return i;
    return -1;
}

void TeamCount_PlayerPool_Add(entity pool, entity plr) {
    if(pool.teamcount_poolsize >= TC_POOL_MAX)
        error(strcat("TeamCount_PlayerPool_Add: maximum size of ", ftos(TC_POOL_MAX), " exceeded"));
    
    float idx = pool.teamcount_poolsize;
    pool.(teamcount_playerpool[idx]) = plr;
    pool.teamcount_poolsize += 1;
    pool.teamcount_totalscore += TeamCount_PlayerPool_PlayerValue(plr);
}

void TeamCount_PlayerPool_Remove(entity pool, entity plr) {
    float i, idx = TeamCount_PlayerPool_IndexOf(pool, plr);
    
    if(idx < 0)
        error(strcat("TeamCount_PlayerPool_Remove: player ", plr.netname, " not in pool"));
    
    pool.teamcount_totalscore -= TeamCount_PlayerPool_PlayerValue(plr);
    
    for(i = idx + 1; i < pool.teamcount_poolsize; ++i)
        pool.(teamcount_playerpool[i-1]) = TeamCount_PlayerPool_GetPlayer(pool, i);
    
    pool.teamcount_poolsize -= 1;
}

void TeamCount_PlayerPool_Swap(float i1, float i2, entity pool) {
    entity tmp;
    tmp = pool.(teamcount_playerpool[i1]);
    pool.(teamcount_playerpool[i1]) = pool.(teamcount_playerpool[i2]);
    pool.(teamcount_playerpool[i2]) = tmp;
}

float TeamCount_PlayerPool_Compare(float i1, float i2, entity pool) {
    return TeamCount_PlayerPool_GetValue(pool, i2) - 
           TeamCount_PlayerPool_GetValue(pool, i1);
}

void TeamCount_PlayerPool_Sort(entity pool) {
    heapsort(pool.teamcount_poolsize, TeamCount_PlayerPool_Swap, TeamCount_PlayerPool_Compare, pool);
}

entity teamcount_balance_pools[4];

entity TeamCount_BalanceTeams_SelectPool(float tc, entity plr) {
    float change = TeamCount_PlayerPool_PlayerValue(plr), i;
    entity p = teamcount_balance_pools[0];
    
    if(change == 0) {
        for(i = 1; i < tc; ++i)
            if(teamcount_balance_pools[i].teamcount_poolsize < p.teamcount_poolsize)
                p = teamcount_balance_pools[i];
    } else if(change > 0) {
        for(i = 1; i < tc; ++i)
            if(teamcount_balance_pools[i].teamcount_totalscore < p.teamcount_totalscore)
                p = teamcount_balance_pools[i];
    } else {
        for(i = 1; i < tc; ++i)
            if(teamcount_balance_pools[i].teamcount_totalscore > p.teamcount_totalscore)
                p = teamcount_balance_pools[i];
    }
    
    return p;
}

float TeamCount_BalanceTeams_SortPools_Compare(float i1, float i2, entity pass) {
    return teamcount_balance_pools[i2].teamcount_totalscore 
         - teamcount_balance_pools[i1].teamcount_totalscore;
}

void TeamCount_BalanceTeams_SortPools_Swap(float i1, float i2, entity pass) {
    entity tmp = teamcount_balance_pools[i1];
    teamcount_balance_pools[i1] = teamcount_balance_pools[i2];
    teamcount_balance_pools[i2] = tmp;
}

float TeamCount_BalanceTeams_SortTeams_Compare(float i1, float i2, entity pass) {
    return TeamScore_Get(teamcount_balance_pools[i1].team, ST_SCORE) 
         - TeamScore_Get(teamcount_balance_pools[i2].team, ST_SCORE);
}

void TeamCount_BalanceTeams_SortTeams_Swap(float i1, float i2, entity pass) {
    float tmp = teamcount_balance_pools[i1].team;
    teamcount_balance_pools[i1].team = teamcount_balance_pools[i2].team;
    teamcount_balance_pools[i2].team = tmp;
}

void TeamCount_BalanceTeams(void) {
    float i, j, k, tc = TeamCount_TotalTeams(), mi, delta, val;
    entity plr, pool, all, p1, p2;
    
    // Create player pools for each available team
    for(i = 0; i < tc; ++i) {
        teamcount_balance_pools[i] = spawn();
        teamcount_balance_pools[i].cnt = i;
    }
    
    // Create a pool of all players, sorted by score
    all = spawn();
    FOR_EACH_CLIENT(plr) if(plr.iscreature || plr.jb_specteam)
        TeamCount_PlayerPool_Add(all, plr);
    TeamCount_PlayerPool_Sort(all);
    
    // Divide that pool into teams, trying to keep the scores as balanced as possible
    for(i = 0; i < all.teamcount_poolsize; ++i) {
        plr = TeamCount_PlayerPool_GetPlayer(all, i);
        TeamCount_PlayerPool_Add(TeamCount_BalanceTeams_SelectPool(tc, plr), plr);
    }
    
    // Adjust the team pools to keep their sizes as balanced as possible
    for(i = 0; i < tc; ++i) {
        for(j = 0; j < tc; ++j) {
            if(j == i) continue;
            
            p1 = teamcount_balance_pools[i];
            p2 = teamcount_balance_pools[j];
            
            dprint("^1-----------------------------------\n");
            dprint("Comparing ", ftos(p1.cnt), " to ", ftos(p2.cnt), "\n");
            dprint(ftos(p1.teamcount_totalscore - p2.teamcount_totalscore), " --- ", ftos(p1.teamcount_poolsize - p2.teamcount_poolsize), "\n");
            dprint("^1-----------------------------------\n");
            
            while(((p1.teamcount_totalscore > p2.teamcount_totalscore) && (p1.teamcount_poolsize > p2.teamcount_poolsize)) ||
                   (p1.teamcount_poolsize - p2.teamcount_poolsize) > 1) {
                    dprint("^2-----------------------------------\n");
                    // Inacceptable teamsize imbalance - we need to move a player from p1 to p2
                    
                    plr = world;
                    mi = fabs(p1.teamcount_totalscore) + fabs(p2.teamcount_totalscore) + 1337;
                    
                    // Find the player that will affect the score balance the least
                    for(k = 0; k < p1.teamcount_poolsize; ++k) {
                        val = TeamCount_PlayerPool_GetValue(p1, k);
                        delta = fabs((p1.teamcount_totalscore - val) - (p2.teamcount_totalscore + val));
                        
                        dprint(ftos(p1.cnt), ": ^2", ftos(p1.teamcount_totalscore), "    ^7");
                        dprint(ftos(p2.cnt), ": ^2", ftos(p2.teamcount_totalscore), "    ^7");
                        dprint("mi: ^2", ftos(mi), "    ^7");
                        dprint("delta: ^2", ftos(delta), "    ^7");
                        dprint("val: ^2", ftos(val), "    ^7");
                        dprint("Player #", ftos(k), ": ", TeamCount_PlayerPool_GetPlayer(p1, k).netname, "\n");
                        
                        if(delta < mi) {
                            mi = delta;
                            plr = TeamCount_PlayerPool_GetPlayer(p1, k);
                        }
                    }
                    
                    // Move that player to p2
                    if(plr) {
                        TeamCount_PlayerPool_Remove(p1, plr);
                        TeamCount_PlayerPool_Add(p2, plr);
                        dprint("^1Moved ^7", plr.netname, "\n");
                    } else {    // should never happen
                        dprint("Couldn't move anyone from ", ftos(p1.cnt), " to ", ftos(p2.cnt), "!\n");
                        break;
                    }
                    dprint("^5", ftos(p1.teamcount_totalscore - p2.teamcount_totalscore), " --- ", ftos(p1.teamcount_poolsize - p2.teamcount_poolsize), "\n");
                }
        }
    }
    
    // Assign pools to teams
    heapsort(tc, TeamCount_BalanceTeams_SortPools_Swap, TeamCount_BalanceTeams_SortPools_Compare, world);
    for(i = 0; i < tc; ++i)
        teamcount_balance_pools[i].team = Team_FromIndex(i);
    heapsort(tc, TeamCount_BalanceTeams_SortTeams_Swap, TeamCount_BalanceTeams_SortTeams_Compare, world);
    
    // Assign players to their new teams
    for(i = 0; i < tc; ++i) {
        pool = teamcount_balance_pools[i];
        for(j = 0; j < pool.teamcount_poolsize; ++j) {
            plr = TeamCount_PlayerPool_GetPlayer(pool, j);
            
            if(plr.team != pool.team)
                bigprint_spec(plr, strcat("You are now on the ", Team_ColorCode(pool.team), strtoupper(Team_ColorName(pool.team)), " ^7Team!"), "", 5);
            
            if(plr.jb_specteam)
                plr.jb_specteam = pool.team;
            
            TeamchangeFrags(plr);
            SetPlayerTeam(plr, Team_Index(pool.team)+1, Team_Index(plr.team)+1, FALSE);
            plr.scorekeeper.SendFlags |= pow(2, SP_SCORE);
            plr.team = pool.team;
        }
    }
    
    // Clean up
    for(i = -1; i < tc; ++i) {
        if(i == -1)
            pool = all;
        else
            pool = teamcount_balance_pools[i];
        
        if(pool) {
            dprint("---------------------\n");
            dprint("pool #", ftos(i+1), " (", ftos(pool.teamcount_totalscore), ") \n");
            dprint("---------------------\n");
            for(j = 0; j < pool.teamcount_poolsize; ++j)
                dprint("- ", TeamCount_PlayerPool_GetPlayer(pool, j).netname, " - ", ftos(TeamCount_PlayerPool_GetValue(pool, j)), "\n");
            dprint("---------------------\n");
            
            remove(pool);
            if(i >= 0)
                teamcount_balance_pools[i] = world;
        }
    }
    
    teamcount_balancenext = FALSE;
    bprint("\x01^5* Team balance has been adjusted.\n");
}
