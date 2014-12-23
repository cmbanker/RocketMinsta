
#define ON_BUFF_ADDED(b) if(self.buffs & (b)) if not(self.oldbuffs & (b))
#define ON_BUFF_REMOVED(b) if(self.oldbuffs & (b)) if not(self.buffs & (b))

void Buffs_Init(void) {
    float i, b;
    
    g_buffs = cvar("g_buffs");
    
    if(g_clanarena)
        g_buffs = (g_buffs && cvar("g_clanarena_buffs"));
    
    if(!g_buffs)
        return;
    
    g_buffs_team_only = cvar("g_buffs_team_only");
    g_buffs_stack = cvar("g_buffs_stack");
    g_buffs_noteam = cvar("g_buffs_noteam");
    g_buffs_randomize = cvar("g_buffs_randomize");
    g_buffs_randomize_dual = cvar("g_buffs_randomize_dual");
    g_buffs_randomize_byinstance = cvar("g_buffs_randomize_byinstance");
    g_buffs_randomize_chaos = cvar("g_buffs_randomize_chaos");
    g_buffs_randomize_interval = cvar("g_buffs_randomize_interval");
    g_buffs_spawn_on_powerups = cvar("g_buffs_spawn_on_powerups");
    g_buffs_lockon = cvar("g_buffs_lockon");
    
    if(g_clanarena)
        g_buffs_team_only = cvar("g_clanarena_buffs_team_only");
    
    precache_sound("misc/strength_respawn.wav");
    precache_sound("misc/shield_respawn.wav");
    precache_sound("misc/arc1.wav");
    precache_sound("misc/arc2.wav");
    precache_model("models/buffs/buff_ring.md3");
    precache_model("models/runematch/rune.mdl");
    
    addstat(STAT_BUFFS, AS_INT, buffstat);
    
    float enabled;
    for(i = 0, b = 1; i < BUFF_COUNT; ++i, b *= 2) {
        if(b == BUFF_MEDIC)
        if(!teams_matter)
            continue;
        
        if(b == BUFF_WRATH || b == BUFF_ADEPT)
        if(!g_nadgets)
            continue;
        
        if(cvar(strcat("g_buffs_", Buffs_TypeToName(b)))) {
            g_buffs_enabled |= b;
            ++enabled;
        }
        
        if(cvar(strcat("g_buffs_", Buffs_TypeToName(b), "_baseline")))
            g_buffs_baseline |= b;
    }
    
    if(enabled < 2)
        g_buffs_randomize_dual = 0;
    
    g_buffs_adept = (g_buffs_enabled & BUFF_ADEPT || g_buffs_baseline & BUFF_ADEPT);
    g_buffs_meodp = (g_buffs_enabled & BUFF_MEODP || g_buffs_baseline & BUFF_MEODP);
    
    InitializeEntity(world, Buffs_Init_Delayed, INITPRIO_LAST);
}

void Buffs_Randomize_Reset(void) {
    float i;
    
    for(i = 0; i < BUFF_COUNT; ++i) {
        g_buffs_replacements[i] = 0;
        g_buffs_used[i] = 0;
        g_buffs_used_dual[i] = 0;
        g_buffs_randomize_ulevel = 0;
        g_buffs_randomize_ulevel_dual = 0;
    }
}

float Buffs_Randomize_Yield(void) {
    float found, sub, choosen, j, b;
    RandomSelection_Init();
    
    while(!found) {
        for(j = 0, b = 1; j < BUFF_COUNT; ++j, b *= 2)
            if(g_buffs_enabled & b && (g_buffs_used[j] < g_buffs_randomize_ulevel || g_buffs_randomize_chaos)) {
                RandomSelection_Add(world, j, string_null, cvar(strcat("g_buffs_", Buffs_TypeToName(b), "_randomspawn_weight")), 1);
                ++found;
            }
        
        if(!found)
            ++g_buffs_randomize_ulevel;
    }
    
    choosen = RandomSelection_chosen_float;
    g_buffs_used[choosen] = g_buffs_randomize_ulevel;
    sub = pow(2, choosen);
    
    if(g_buffs_randomize_dual >= 1 || random() < g_buffs_randomize_dual) {
        RandomSelection_Init();
        found = 0;
        
        while(!found) {
            for(j = 0, b = 1; j < BUFF_COUNT; ++j, b *= 2)
                if(g_buffs_enabled & b && j != choosen && (g_buffs_used_dual[j] < g_buffs_randomize_ulevel_dual || g_buffs_randomize_chaos)) {
                    RandomSelection_Add(world, j, string_null, cvar(strcat("g_buffs_", Buffs_TypeToName(b), "_randomspawn_weight")), 1);
                    ++found;
                }
            
            if(!found)
                ++g_buffs_randomize_ulevel_dual;
        }
        
        g_buffs_used_dual[RandomSelection_chosen_float] = g_buffs_randomize_ulevel_dual;
        sub = sub | pow(2, RandomSelection_chosen_float);
    }
    
    return sub;
}

void Buffs_Randomize(entity blist, float force) {
    float i, j;
    entity b;
    
    if(g_buffs_randomize >= 2)
        force = TRUE;
    
    Buffs_Randomize_Reset();
    
    if(force && g_buffs_randomize_byinstance <= 1) for(i = 0; i < BUFF_COUNT; ++i)
        g_buffs_replacements[i] = Buffs_Randomize_Yield();
    
    if(!blist)
        blist = findchain(classname, "item_buff");
    
    for(b = blist; b; b = b.chain) {
        if(b.origbuffs == BUFF_RANDOM || g_buffs_randomize_byinstance > 1 || (g_buffs_randomize_byinstance && !b.team))
            b.buffs = Buffs_Randomize_Yield();
        else if(force) {
            i = Buffs_TypeToIndex(b.origbuffs);
            j = g_buffs_replacements[i];
            if(j) b.buffs = j;
        }
        
        if(roundstate != ROUNDSTATE_GAME)
            Buffs_BuffPickup_SetInitialCooldown(b);
    }
}

#define BUFFS_RANDOMIZER_NEXTTHINK (time + max3(game_starttime - time, next_round_starttime - time, 0) + g_buffs_randomize_interval)

void Buffs_Randomizer_Think(void) {
    if(roundstate == ROUNDSTATE_GAME)
        Buffs_Randomize(world, TRUE);
    self.nextthink = BUFFS_RANDOMIZER_NEXTTHINK;
}

void Buffs_Randomizer_Reset(void) {
    self.nextthink = BUFFS_RANDOMIZER_NEXTTHINK;
}

float buff_teamfound[4];
void Buffs_Init_Delayed(void) {
    entity blist, b, o;
    float idx, teams_found, teams_total, bcnt = g_buffs_count;
    
    if(g_buffs_spawn_on_powerups && !g_buffs_team_only) {
        o = self;
        for(b = findchain(classname, "buff_placeholder"); b; b = b.chain) {
            if(bcnt) {
                b.nextthink = time;
                b.think = SUB_Remove;
            } else {
                self = b;
                self.buffs = BUFF_RANDOM;
                Buffs_BuffPickup_Setup();
                if(self.owner && !wasfreed(self.owner)) {
                    remove(self.owner);
                    self.owner = world;
                }
            }
        }
        self = o;
    }
    
    if(teams_matter) {
        teams_total = TeamCount_TotalTeams();

        blist = findchain(classname, "item_buff");
        for(b = blist; b; b = b.chain) if(b.team) {
            idx = Team_Index(b.team);
            if(!buff_teamfound[idx]) {
                buff_teamfound[idx] = TRUE;
                ++teams_found;
            }
            
            if(b.team == COLOR_TEAM3 && teams_total < 3 || b.team == COLOR_TEAM4 && teams_total < 4) {
                b.think = Buffs_BuffPickup_Remove;
                b.nextthink = time;
            }
        }
        
        if(teams_total > teams_found)
        for(b = blist; b; b = b.chain) if(b.team) {
            b.think = Buffs_BuffPickup_Remove;
            b.nextthink = time;
        }
    }
    
    Buffs_Randomize(blist, g_buffs_randomize);
    
    if(g_buffs_randomize)
    if(g_buffs_randomize_interval)
    if(cvar("g_buffs_randomize_interval_force") || !EndRound_Allowed()) {
        entity e = spawn();
        e.classname = "buff_randomizer";
        e.reset = Buffs_Randomize_Reset;
        e.think = Buffs_Randomizer_Think;
        e.nextthink = BUFFS_RANDOMIZER_NEXTTHINK;
    }
}

.float buffpowercalls;

float Buffs_BuffPower(entity p, float b) {
    /*
    p.buffpowercalls += 1;
    if(clienttype(p) == CLIENTTYPE_REAL)
        sprint(p, strcat(ftos(b), "\n"));
    */
    
    if(!g_buffs)
        return 0;
    
    if(p.nobuffs)
        return 0;
    
    if(p.buffs & b == b)
        return 1;
    
    float pw;
    
    if(g_buffs_baseline & b == b) {
        if(b & (b - 1)) // multibuff
            return 1;
        pw = max(pw, cvar(strcat("g_buffs_", Buffs_TypeToName(b), "_baseline")));
    }
    
    if(p.hg_linker.buffs & b == b)
        pw = max(pw, p.hg_linker.hg_linker_buffpower);
    
    return pw;
}

float Buffs_Model_Send(entity to, float sf) {
    entity o = self.owner;

    if(self.flags & FL_ITEM)
        o = world;
    else if(o)
        sf &~= (2 | 16);

    WriteByte(MSG_ENTITY, ENT_CLIENT_BUFFMODEL);
    WriteByte(MSG_ENTITY, sf);

    if(sf & 1) {
        WriteByte(MSG_ENTITY, num_for_edict(o));
    }

    if(sf & 2) {
        WriteByte(MSG_ENTITY, self.buff_active);
    }

    if(sf & 4) {
        WriteShort(MSG_ENTITY, self.buffs);
    }

    if(sf & 8) {
        WriteCoord(MSG_ENTITY, self.origin_x);
        WriteCoord(MSG_ENTITY, self.origin_y);
        WriteCoord(MSG_ENTITY, self.origin_z);
    }

    if(sf & 16) {
        WriteByte(MSG_ENTITY, self.team);
    }

    return TRUE;
}

void Buffs_Model_Update(entity e) {
    if(e.buff_active != e.buff_active_old) {
        e.buff_active_old = e.buff_active;
        e.SendFlags |= 2;
    }

    if(e.buffs != e.oldbuffs) {
        e.oldbuffs = e.buffs;
        e.SendFlags |= 4;
    }

    if(e.origin != e.oldorigin) {
        e.oldorigin = e.origin;
        e.SendFlags |= 8;
    }

    if(e.oldteam != e.team) {
        e.oldteam = e.team;
        e.SendFlags |= 16;
    }
} 

float Buffs_Model_Overhead_Customize(void) {
    if(!other.iscreature)
        return TRUE;
    
    if(self.owner.hg_stealth)
    if(IsDifferentTeam(self.owner, other))
        return FALSE;

    return TRUE;
}

float Buffs_TeamWaypoint_VisibleForPlayer(entity plr) {
    if(plr == self.owner)
        return FALSE;
    return WaypointSprite_visible_for_player(plr);
}

void Buffs_SetTeamWaypoint(entity plr, string txt, vector clr, float btype) {
    entity wp = plr.buff_teamwp;
    
    if(!wp) {
        wp = WaypointSprite_Spawn(txt, 0, 0, plr, '0 0 120', world, plr.team, plr, buff_teamwp, TRUE);
        wp.waypointsprite_visible_for_player = Buffs_TeamWaypoint_VisibleForPlayer;
    } else
        WaypointSprite_UpdateSprites(wp, txt, "", "");
    
    WaypointSprite_UpdateTeamRadar(wp, RADARICON_GENERATOR, clr);
    WaypointSprite_UpdateTextColors(wp, clr, '0 0 0', '0 0 0');
    wp.buffs = btype;
}

void Buffs_RemoveTeamWaypoint(entity plr) {
    WaypointSprite_Disown(plr.buff_teamwp, 0.5);
}

void Buffs_ClientFrame(void) {
    if(!g_buffs)
        return;
    
    self.buffstat = self.buffs;
    if(self.hg_linker.hg_linker_buffpower)
        self.buffstat = self.buffstat | self.hg_linker.buffs;
    
    if(self.classname != "player") {
        if(self.buff_model) {
            remove(self.buff_model);
            self.buff_model = world;
        }
        
        if(self.buff_teamwp)
            Buffs_RemoveTeamWaypoint(self);
        
        return;
    }
    
    if(self.buffs != self.oldbuffs) {
        ON_BUFF_ADDED(BUFF_SUPPLY) {
            self.campingrifle_bulletcounter = 9001;
            
            if(!g_weaponarena) {
                float a = cvar("g_buffs_supply_grant_ammo");
                self.ammo_cells += a;
                self.ammo_shells += a;
                self.ammo_rockets += a;
                self.ammo_nails += a;
            }
        }
        
        ON_BUFF_ADDED(BUFF_GUARD) {
            if(g_clanarena)
                self.health = max(min(cvar("g_clanarena_heal_limit"), cvar("g_buffs_guard_pickup_health")), self.health);
            else {
                self.health = max(cvar("g_buffs_guard_pickup_health"), self.health);
                self.armorvalue = max(cvar("g_buffs_guard_pickup_armor"), self.armorvalue);
            }
        }
        
        ON_BUFF_REMOVED(BUFF_VAMPIRE) {
            self.buff_vamp_ticks = self.buff_vamp_healthpool = self.buff_vamp_nexttick = 0;
        }
        
        ON_BUFF_ADDED(BUFF_VAMPIRE) {
            self.buff_vamp_ticks = self.buff_vamp_healthpool = self.buff_vamp_nexttick = 0;
        }
        
        ON_BUFF_REMOVED(BUFF_ADEPT) {
            self.hg_stealth_saved = 0;
        }
        
        self.oldbuffs = self.buffs;
    }
    
    if(self.buffstat) {
        if(!self.buff_model) {
            entity m = spawn();
            float bi = Buffs_TypeToIndex(self.buffstat);
            setsize(m, '0 0 -40', '0 0 40');
            m.owner = self;
            m.customizeentityforclient = Buffs_Model_Overhead_Customize;
            Net_LinkEntity(m, FALSE, 0, Buffs_Model_Send);
            self.buff_model = m;
        }
        
        self.buff_model.buffs = self.buffstat;
        setorigin(self.buff_model, self.origin + '0 0 70');
        Buffs_Model_Update(self.buff_model);

    } else if(self.buff_model) {
        remove(self.buff_model);
        self.buff_model = world;
    }
    
    if(self.buff_vamp_ticks > 0) if(time > self.buff_vamp_nexttick) {
        float heal = self.buff_vamp_healthpool / self.buff_vamp_ticks;
        Heal(self, world, self, heal, 0, 0, 0, DEATH_VAMPIRE, cvar("g_buffs_vampire_pauserot"), 0, '0 0 0');
        self.buff_vamp_healthpool -= heal;
        self.buff_vamp_ticks -= 1;
        self.buff_vamp_nexttick = time + 1;
    }
    
    if(!self.buff_teamwp) {
        if(Buffs_BuffPower(self, BUFF_MEDIC))
            Buffs_SetTeamWaypoint(self, "HEALER", Buffs_TypeToColor(BUFF_MEDIC), BUFF_MEDIC);
    } else if(!Buffs_BuffPower(self, self.buff_teamwp.buffs))
        Buffs_RemoveTeamWaypoint(self);
    
    if(g_buffs_adept)
        self.buffpower_adept = Buffs_BuffPower(self, BUFF_ADEPT);
    
    if(g_buffs_meodp)
        self.buffpower_meodp = Buffs_BuffPower(self, BUFF_MEODP);
    
    /*
    sprint(self, strcat("^5", ftos(self.buffpowercalls), "\n"));
    self.buffpowercalls = 0;
    */
}

#undef ON_BUFF_ADDED
#undef ON_BUFF_REMOVED

float Buffs_NadgetPower(entity plr) {
    float bp = Buffs_BuffPower(plr, BUFF_WRATH);
    
    if(!bp)
        return 1;
    
    return bp * cvar("g_buffs_wrath_hgpower");
}

float Buffs_NadgetRegen(entity plr) {
    return (1 + (cvar("g_buffs_supply_hg_regenscale") - 1) * Buffs_BuffPower(self, BUFF_SUPPLY)) *
           (1 + (cvar("g_buffs_wrath_hgregen")        - 1) * Buffs_BuffPower(self, BUFF_WRATH));
}

float Buffs_NadgetCooldown(entity plr) {
    float bp = Buffs_BuffPower(plr, BUFF_WRATH);
    
    if(!bp)
        return 1;
    
    return bp * cvar("g_buffs_wrath_hgcooldown");
}

float Buffs_NadgetRegenDmgPause(entity plr) {
    return (1 - (1 - cvar("g_buffs_wrath_hgregen_damagepause")) * Buffs_BuffPower(plr, BUFF_WRATH));
}

float Buffs_NadgetBonusMultiplier(entity plr) {
    float wrath = Buffs_BuffPower(plr, BUFF_WRATH);

    if(!wrath)
        return 1;

    return rint(1 + (cvar("g_buffs_wrath_hgbonusmultiplier") - 1) * wrath);
}

float Buffs_IgniteDamage(entity targ, entity attacker, entity inflictor, float damage, float deathtype) {
    float diffteam;
    
    if(damage)
    if(targ != attacker)
    if(targ != inflictor)
    if(attacker.classname == "player")
    if(deathtype != DEATH_HG_TRANSLOC)
    if(!DEATH_ISSPECIAL(deathtype) || deathtype == DEATH_ARC) {
        float ignite = Buffs_BuffPower(attacker, BUFF_IGNITE);
        if(ignite)
        if((diffteam = IsDifferentTeam(attacker, targ)) || Buffs_BuffPower(attacker, BUFF_MEDIC)) {
            float fdamage = damage * cvar("g_buffs_ignite_damage_fire") * ignite;
            if(!diffteam || Buffs_TenacityDamage(targ, attacker, fdamage, DEATH_IGNITE))
                Fire_AddDamage(targ, attacker, fdamage, cvar("g_buffs_ignite_burntime"), DEATH_IGNITE);
            damage = damage * (1 - (1 - cvar("g_buffs_ignite_damage_base")) * ignite);
        }
    }
    
    return damage;
}

float Buffs_TenacityDamage(entity targ, entity attacker, float damage, float deathtype) {
    float tenacity = Buffs_BuffPower(targ, BUFF_TENACITY);
    
    if(!tenacity)
        return damage;
    
    if(DEATH_ISSPECIAL(deathtype) && deathtype != DEATH_ARC && deathtype != DEATH_IGNITE)
        return damage;
    
    if(targ == attacker)
        return damage * (1 - (1 - cvar("g_buffs_tenacity_takedamage_self")) * tenacity);
    
    if(DEATH_ISHG(deathtype) || (deathtype & HITTYPE_SPLASH) || deathtype == DEATH_ARC || deathtype == DEATH_IGNITE)
        return damage * (1 - (1 - cvar("g_buffs_tenacity_takedamage_aoe")) * tenacity);
    
    return damage * (1 - (1 - cvar("g_buffs_tenacity_takedamage")) * tenacity);
}

void Buffs_VampireDamage(entity targ, entity a, float damage, float deathtype) {
    if(damage <= 0)
        return;
    
    float vamp = Buffs_BuffPower(a, BUFF_VAMPIRE);
    
    if(!vamp)
        return;
    
    // paranoid sanity check, should not happen
    if(!a.buff_vamp_ticks  &&  a.buff_vamp_healthpool ||
        a.buff_vamp_ticks  && !a.buff_vamp_healthpool)
        a.buff_vamp_ticks  =   a.buff_vamp_healthpool = 0;
    
    float ticks = cvar("g_buffs_vampire_time");
    float factor = cvar("g_buffs_vampire_factor") * vamp;
    
    if(ticks > 0) {
        // refresh duration, extend the pool
        a.buff_vamp_ticks = ticks;
        a.buff_vamp_healthpool += damage * factor;
    } else {
        // instant-healing mode, don't use the buffer, just heal
        Heal(a, world, a, damage * factor, 0, 0, 0, DEATH_VAMPIRE, cvar("g_buffs_vampire_pauserot"), 0, '0 0 0');
    }
}

void Buffs_ArcEffect(vector from, vector to, float t) {
    te_csqc_lightningarc(from, to, t, t);
}

void Buffs_ArcDamage_Proc(entity targ, entity attacker, float damage, float deathtype, float arcdeathtype,
                          float buffpow, vector arcoffset, float range, float mul, float mul_hg, float force,
                          float targetTeamMates, float targetFrozen, float targetAlive, .float hitfield) {
    entity oldself = self;
    entity plr, newtarget;
    float dist, shortest;
    
    if(targetFrozen)
        damage = 1;
    else {
        if(DEATH_ISHG(deathtype))
            damage = damage * mul_hg;
        damage = damage * mul * buffpow;
    }
    
    if(damage < 1)
        return;
    
    newtarget = world;
    shortest = range;
    targ.hitfield = TRUE;
    
    FOR_EACH_PLAYER(plr)
    if(plr != attacker)
    if(plr != targ)
    if(plr.deadflag == DEAD_NO)
    if(!plr.hg_stealth || (targetTeamMates && plr.team == attacker.team))
    if(!plr.jb_isprisoned)
    if(!plr.hitfield) {
        float sameteam = (teams_matter && plr.team == attacker.team);
        if((!sameteam && ((!plr.frozen && targetAlive) || (plr.frozen && targetFrozen))) || (sameteam && targetTeamMates)) {
            dist = vlen(plr.origin - targ.origin);
            if(dist < shortest) {
                traceline(targ.origin + arcoffset, plr.origin + arcoffset, MOVE_NORMAL, targ);
                
                if(trace_fraction < 1 && trace_ent == plr) {
                    shortest = dist;
                    newtarget = plr;
                }
            }
        }
    }
    
    if(newtarget) {
        Buffs_ArcEffect(targ.origin + arcoffset, newtarget.origin + arcoffset, (targetTeamMates? 0 : (teams_matter? attacker.team : COLOR_TEAM2)));
        Damage(newtarget, attacker, attacker, damage, arcdeathtype, '0 0 0', normalize(newtarget.origin - targ.origin) * force);
        Buffs_ArcDamage_Proc(newtarget, attacker, damage, arcdeathtype, arcdeathtype,
                             buffpow, arcoffset, range, mul, mul_hg, force,
                             targetTeamMates, targetFrozen, targetAlive, hitfield);
        if(targetTeamMates)
            sound(newtarget, CHAN_PROJECTILE, "kh/capture.wav", 0.4, ATTN_NORM);
        else
            sound(newtarget, CHAN_PROJECTILE, strcat("misc/arc", ftos(1 + (random() > 0.5)), ".wav"), VOL_BASE, ATTN_NORM * 0.3);
    }
    
    self = oldself;
}

void Buffs_ArcDamage(entity targ, entity attacker, float damage, float deathtype) {
    if(DEATH_ISWEAPON(deathtype, WEP_ZAPPER) && (deathtype & HITTYPE_BOUNCE))
        return;

    float bp = Buffs_BuffPower(attacker, BUFF_ARC);
    
    if(!bp)
        return;
    
    float targetTeamMates = (teams_matter && Buffs_BuffPower(attacker, BUFF_MEDIC) && targ.team == attacker.team);
    
    if(targ.team == attacker.team && !targetTeamMates)
        return;
    
    float targetFrozen = targ.frozen && !targetTeamMates;
    float targetAlive = !targetFrozen && !targetTeamMates;
    
    Buffs_ArcDamage_Proc(targ, attacker, damage, deathtype, DEATH_ARC, bp,
                         attacker.maxs_z * '0 0 0.5',
                         cvar("g_buffs_arc_range"),
                         cvar("g_buffs_arc_multiplier"),
                         cvar("g_buffs_arc_multiplier_hg"),
                         cvar("g_buffs_arc_pushback"),
                         targetTeamMates, targetFrozen, targetAlive, buffs_arc_hit);
    
    entity e; for(e = world; (e = findfloat(e, buffs_arc_hit, TRUE));)
        e.buffs_arc_hit = FALSE;
}

void Buffs_MEODP_Point_Think(void) {
    if(!self.owner || wasfreed(self.owner)) {
        remove(self);
        return;
    }
    
    self.angles = self.angles + (self.owner.angles - self.angles) * frametime;
    makevectors(self.angles + '0 30 0' * time * self.health);
    //setorigin(self, self.owner.origin + v_forward * 50 + v_up * self.owner.maxs_z * 0.5);
    setorigin(self, self.owner.meodp_point_offs + (self.owner.absmax + self.owner.absmin) * 0.5 + v_forward * (45 + 10 * sin(time * self.armorvalue)));
    
    self.nextthink = time;
}

float Buffs_MEODP_Point_VisibleForPlayer(entity p, entity plr) {
    if(!plr.buffpower_meodp)
        return FALSE;
    
    if(p.owner.iscreature)
    if(!IsDifferentTeam(p.owner, plr))
        return FALSE;
    
    return TRUE;
}

float Buffs_MEODP_Point_Customize(void) {
    if(other.classname == "spectator")
        other = other.enemy;
    
    return Buffs_MEODP_Point_VisibleForPlayer(self, other);
}

void Buffs_MEODP_TriggerDeath(entity targ, entity attacker, entity inflictor) {
    entity oself = self;
    self = targ;
    targ.meodp_point.solid = SOLID_NOT;
    te_meodp(targ.meodp_point.origin);
    targ.meodp_death(attacker, inflictor);
    self = oself;
}

void Buffs_MEODP_Point_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) {
    if(self.solid == SOLID_NOT || RadiusDamage_running)
        return; // hitscan only
    
    if(!damage)
        return;
    
    if(!Buffs_MEODP_Point_VisibleForPlayer(self, attacker))
        return;
    
    Buffs_MEODP_TriggerDeath(self.owner, attacker, inflictor);
}

void Buffs_MEODP_Point_Attach(entity e, meodp_death_f death) {
    if(!g_buffs_meodp)
        return;
    
    if(e.meodp_point)
        return;
    
    entity p = spawn();
    p.classname = "meodp_point";
    p.owner = e;
    p.customizeentityforclient = Buffs_MEODP_Point_Customize;
    p.think = Buffs_MEODP_Point_Think;
    p.nextthink = time;
    p.solid = SOLID_NOT;
    p.colormod = '-10 -10 -10';
    p.glow_size = 256;
    p.glow_trail = 1;
    p.glow_color = 251;
    p.health = random();
    p.armorvalue = random();
    p.takedamage = DAMAGE_AIM;
    p.event_damage = Buffs_MEODP_Point_Damage;
    setmodel(p, "models/runematch/rune.mdl");
    setsize(p, '-8 -8 -8', '8 8 8');
    
    e.meodp_point = p;
    e.meodp_death = death;
}

void Buffs_MEODP_Point_Detach(entity e) {
    if(!e.meodp_point)
        return;
    
    remove(e.meodp_point);
    e.meodp_point = world;
    e.meodp_death = func_null;
}

.entity meodp_chain;

entity Buffs_MEODP_Hitscan_Begin(entity plr) {
    if(!plr.buffpower_meodp)
        return world;
    
    entity p, pts = findchain_tofield(classname, "meodp_point", meodp_chain);
    
    for(p = pts; p; p = p.meodp_chain)
        p.solid = SOLID_CORPSE;
        
    return pts;
}

void Buffs_MEODP_Hitscan_End(entity pts) {
    entity p; for(p = pts; p; p = p.meodp_chain)
        p.solid = SOLID_NOT;
}

void Buffs_MEODP_Death_Player(entity attacker, entity inflictor) {
    float d = attacker.buffpower_meodp * (self.health * cvar("g_buffs_meodp_healthfactor") + self.armorvalue * cvar("g_buffs_meodp_armorfactor"));
    float s = d * cvar("g_buffs_meodp_selfdamage");
    
    Damage(self, inflictor, attacker, d, DEATH_MEODP, self.meodp_point.origin, '0 0 0');
    
    if(s)
        Damage(attacker, inflictor, attacker, s, DEATH_MEODP, attacker.origin, '0 0 0');
}

void Buffs_MEODP_Death_Remove(entity attacker, entity inflictor) {
    remove(self);
}

void Buffs_MEODP_Death_Use(entity attacker, entity inflictor) {
    self.use();
}

float Buffs_BuffPickup_Waypoint_VisibleForPlayer(entity plr) {
    if((!self.owner.buff_active && !self.owner.buff_activetime) || plr.buffs & self.owner.buffs || (plr.buffs && !g_buffs_stack))
        return FALSE;
    return WaypointSprite_visible_for_player(plr);
}

void Buffs_BuffPickup_SpawnWaypoint(entity e) {
    vector c = Buffs_TypeToColor(e.buffs);
    WaypointSprite_Spawn(Buffs_TypeToExpandedName(e.buffs), 0, 0, e, '0 0 40', world, e.team, e, buff_waypoint, TRUE);
    WaypointSprite_UpdateTextColors(e.buff_waypoint,c, '0 0 0', '0 0 0');
    WaypointSprite_UpdateTeamRadar(e.buff_waypoint, RADARICON_FLAG, c);
    e.buff_waypoint.waypointsprite_visible_for_player = Buffs_BuffPickup_Waypoint_VisibleForPlayer;
    
    if(e.buff_activetime && roundstate == ROUNDSTATE_GAME)
        WaypointSprite_UpdateBuildFinished(e.buff_waypoint, time + e.buff_activetime);
}

void Buffs_BuffPickup_SetCooldown(entity buff, float cd) {
    cd = max(0, cd);
    
    if(!buff.buff_waypoint)
        Buffs_BuffPickup_SpawnWaypoint(buff);
    
    WaypointSprite_UpdateBuildFinished(buff.buff_waypoint, time + cd);
    buff.buff_activetime = cd;
    buff.buff_active = !cd;
}

void Buffs_BuffPickup_SetInitialCooldown(entity buff) {
    Buffs_BuffPickup_SetCooldown(buff, cvar((buff.buffs & (buff.buffs - 1))? "g_buffs_activate_delay_dual" : "g_buffs_activate_delay"));
}

void Buffs_BuffPickup_Think(void) {
    if(time < 1)
        return;
    
    if(self.buff_lockon)
    if(time > self.buff_lockon_updatetime)
        self.buff_lockon = world;
    
    if(roundstate == ROUNDSTATE_GAME)
    if(!self.buff_activetime_updated) {
        Buffs_BuffPickup_SetCooldown(self, self.buff_activetime);
        self.buff_activetime_updated = TRUE;
    }
    
    if(self.buffs != self.oldbuffs) {
        if(self.buff_waypoint) {
            WaypointSprite_Disown(self.buff_waypoint, 1);
            Buffs_BuffPickup_SpawnWaypoint(self);
        }
        
        self.SendFlags |= 4;
        self.oldbuffs = self.buffs;
    }
    
    if(!self.buff_active && !self.buff_activetime)
    if(!self.owner || self.owner.frozen || self.owner.jb_isprisoned || self.owner.deadflag != DEAD_NO || !self.owner.iscreature || !(self.owner.buffs & self.buffs)) {
        if(self.owner.buff_cdoverride) {
            Buffs_BuffPickup_SetCooldown(self, max(0, self.owner.buff_cdoverride) + frametime);
            self.owner.buff_cdoverride = 0;
        } else
            Buffs_BuffPickup_SetCooldown(self, cvar((self.buffs & (self.buffs - 1))? "g_buffs_reactivate_delay_dual" : "g_buffs_reactivate_delay") + frametime);
        self.owner = world;
    }
    
    if(self.buff_activetime) {
        if(roundstate == ROUNDSTATE_GAME) {
            self.buff_activetime = max(0, self.buff_activetime - frametime);
            
            if(!self.buff_activetime) {
                self.buff_active = TRUE;
                sound(self, CHAN_TRIGGER, "misc/strength_respawn.wav", VOL_BASE, ATTN_NORM); 
            }
        }
    }
    
    if(self.buff_active && !self.buff_waypoint)
        Buffs_BuffPickup_SpawnWaypoint(self);

    self.nextthink = time;
    self.angles_y = time * 110.1;

    Buffs_Model_Update(self);
}

void Buffs_BuffPickup_ResetWaypoint(void) {
    if(self.buff_waypoint)
        WaypointSprite_Kill(self.buff_waypoint);
    
    if(self.buff_activetime)
        Buffs_BuffPickup_SpawnWaypoint(self);
}

void Buffs_BuffPickup_Reset(void) {
    self.owner = world;
    Buffs_BuffPickup_SetInitialCooldown(self);
    Buffs_BuffPickup_ResetWaypoint();
    self.buff_activetime_updated = FALSE;
    Buffs_Model_Update(self);
}

void Buffs_BuffPickup_GiveTo(entity plr) {
    if(self.owner || plr.buffs & self.buffs == self.buffs || (plr.buffs && !g_buffs_stack))
        return;
    
    self.owner = plr;
    self.buff_active = FALSE;
    
    string bname = strcat(rgb_to_hexcolor(Buffs_TypeToColor(self.buffs)), Buffs_TypeToExpandedName(self.buffs), "^7 Buff!");
    string tn = (self.team? strcat(Team_ColorCode(self.team), strtoupper(Team_ColorName(self.team)), " ") : "");
    
    bprint("^3", plr.netname, " ^7got the ", tn, bname, "\n");
    bigprint_spec(plr, strcat("You got the ", bname), "", 3);
    sound(other, CHAN_TRIGGER, "misc/shield_respawn.wav", VOL_BASE, ATTN_NORM); 
    BUFFS_GIVE(plr, self.buffs);
}

void Buffs_BuffPickup_Touch(void) {
    if(self.team && other.team != self.team)
        return;
    
    if(other.deadflag != DEAD_NO)
        return;
    
    if(other.frozen)
        return;
    
    if(other.jb_isprisoned)
        return;
    
    if(other.classname != "player")
        return;
    
    if(!self.buff_active) {
        if(g_buffs_lockon && (!self.buff_lockon || self.buff_lockon == other)) {
            self.buff_lockon = other;
            self.buff_lockon_updatetime = time + 0.5;
        }
        return;
    }
    
    if(self.buff_lockon && self.buff_lockon != other)
        return;
    
    Buffs_BuffPickup_GiveTo(other);
    self.buff_lockon = world;
}

void Buffs_BuffPickup_TeamSwap(void) {
    self.team = TeamCount_NextTeam(self.team);
    if(self.buff_waypoint)
        self.buff_waypoint.team = self.team;
}

void Buffs_BuffPickup_Setup(void) {
    if(!g_buffs || (self.team && !teams_matter) || (g_buffs_team_only && !self.team)) {
        remove(self);
        return;
    }
    
    if not(g_buffs_randomize)
    if not(g_buffs_enabled & self.buffs != self.buffs) {
        remove(self);
        return;
    }
    
    if(g_buffs_noteam)
        self.team = 0;
        
    if(cvar("g_buffs_team_swap"))
        self.team = TeamCount_NextTeam(self.team);
    
    self.origbuffs = self.buffs;
    
    if(time > 1)
    if(self.buffs == BUFF_RANDOM)
        self.buffs = Buffs_Randomize_Yield();
    
    self.classname = "item_buff";
    self.flags = FL_ITEM;
    self.solid = SOLID_TRIGGER;
    self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY;
    self.movetype = MOVETYPE_TOSS;
    self.think = Buffs_BuffPickup_Think;
    self.touch = Buffs_BuffPickup_Touch;
    self.reset = Buffs_BuffPickup_Reset;
    self.teamswap = Buffs_BuffPickup_TeamSwap;
    self.nextthink = time;
    Buffs_BuffPickup_SetInitialCooldown(self);
    self.buff_active = !self.buff_activetime;
    self.gravity = 100;
    
    setsize(self, '-15 -15 -40', '15 15 40');
    
    move_out_of_solid(self);
    droptofloor();
    
    Net_LinkEntity(self, FALSE, 0, Buffs_Model_Send);

    ++g_buffs_count;
}

void Buffs_BuffPickup_Remove(void) {
    if(self.buff_waypoint)
        WaypointSprite_Kill(self.buff_waypoint);
    remove(self);
}

void Buffs_BuffPickup_Placeholder(void) {
    if(!g_buffs || !g_buffs_spawn_on_powerups)
        return;
    
    entity e = spawn();
    setorigin(e, self.origin);
    e.owner = self;
    e.classname = "buff_placeholder";
    
    //error(strcat(vtos(e.origin), " ", vtos(e.owner.origin), " ", e.owner.classname));
}

void Buffs_BuffPickup_SetupQ3TACompat(string rune) {
    if(self.spawnflags & 2)
        self.team = COLOR_TEAM1;
    else if(self.spawnflags & 4)
        self.team = COLOR_TEAM2;
    
    if not((self.buffs = Buffs_NameToType(cvar_string(strcat("g_buffs_q3ta_", rune))))) {
        remove(self);
        return;
    }
    
    Buffs_BuffPickup_Setup();
}

#define BUFF_SPAWNFUNC(e,b,t) void spawnfunc_item_buff_##e() { self.buffs = b; self.team = t; Buffs_BuffPickup_Setup(); }
#define BUFF_SPAWNFUNC_Q3TA_COMPAT(o,r) void spawnfunc_##o() { Buffs_BuffPickup_SetupQ3TACompat(r); }
#define BUFF_SPAWNFUNCS(e,b)                         \
        BUFF_SPAWNFUNC(e,           b,  0)           \
        BUFF_SPAWNFUNC(e##_team1,   b,  COLOR_TEAM1) \
        BUFF_SPAWNFUNC(e##_team2,   b,  COLOR_TEAM2) \
        BUFF_SPAWNFUNC(e##_team3,   b,  COLOR_TEAM3) \
        BUFF_SPAWNFUNC(e##_team4,   b,  COLOR_TEAM4) 

BUFF_SPAWNFUNCS(arc,        BUFF_ARC)
BUFF_SPAWNFUNCS(guard,      BUFF_GUARD)
BUFF_SPAWNFUNCS(supply,     BUFF_SUPPLY)
BUFF_SPAWNFUNCS(haste,      BUFF_HASTE)
BUFF_SPAWNFUNCS(medic,      BUFF_MEDIC)
BUFF_SPAWNFUNCS(ignite,     BUFF_IGNITE)
BUFF_SPAWNFUNCS(vampire,    BUFF_VAMPIRE)
BUFF_SPAWNFUNCS(tenacity,   BUFF_TENACITY)
BUFF_SPAWNFUNCS(wrath,      BUFF_WRATH)
BUFF_SPAWNFUNCS(adept,      BUFF_ADEPT)
BUFF_SPAWNFUNCS(meodp,      BUFF_MEODP)
BUFF_SPAWNFUNCS(random,     BUFF_RANDOM)

// older RM compatibility
BUFF_SPAWNFUNCS(bash,       BUFF_IGNITE)

// q3ta compatibility
BUFF_SPAWNFUNC_Q3TA_COMPAT(item_doubler,    "doubler")
BUFF_SPAWNFUNC_Q3TA_COMPAT(item_guard,      "guard")
BUFF_SPAWNFUNC_Q3TA_COMPAT(item_scout,      "scount")
BUFF_SPAWNFUNC_Q3TA_COMPAT(item_ammoregen,  "ammoregen")


