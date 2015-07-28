
// Nadgets mutator
// Intended for the Camping Rifle Arena mode

void HG_Init() {
    g_nadgets_double = CVAR(g_nadgets_double);

    addstat(STAT_HGFORCE, AS_FLOAT, hg_power);
    addstat(STAT_HGAMMO, AS_INT, hg_ammo1);
    addstat(STAT_HGREGEN, AS_FLOAT, hg_regentime1);
    addstat(STAT_HGREGENMAX, AS_FLOAT, hg_maxregentime1);
    addstat(STAT_HGREGENPAUSED, AS_INT, hg_regenpaused1);
    addstat(STAT_HGREGENRATE, AS_FLOAT, hg_regenrate1);
    addstat(STAT_HGDETONABLES, AS_INT, hg_detonables);
    addstat(STAT_HGLAUNCH, AS_FLOAT, hg_launchspeed);
    addstat(STAT_HGSHIELD, AS_FLOAT, hg_shieldstat);
    addstat(STAT_HGSHIELDPOWER, AS_FLOAT, hg_shieldpower);
    addstat(STAT_HGSHIELDSTORE, AS_INT, hg_shield_stored);
    addstat(STAT_HGSHIELDSTOREMAX, AS_INT, hg_shield_stored_limit);
    addstat(STAT_HGTYPE, AS_INT, hg_type1);
    addstat(STAT_HGBONUS, AS_INT, hg_bonus);
    addstat(STAT_HGBONUSTYPE, AS_INT, hg_bonustype);
    addstat(STAT_STEALTH, AS_INT, hg_stealth);
    addstat(STAT_STEALTH_SAVED, AS_INT, hg_stealth_saved);
    addstat(STAT_HGREFIRE, AS_FLOAT, hg_next1);

    if(g_nadgets_double) {
        addstat(STAT_HGTYPE2, AS_INT, hg_type2);
        addstat(STAT_HGREFIRE2, AS_FLOAT, hg_next2);
        addstat(STAT_HGAMMO2, AS_INT, hg_ammo2);
        addstat(STAT_HGREGEN2, AS_FLOAT, hg_regentime2);
        addstat(STAT_HGREGENMAX2, AS_FLOAT, hg_maxregentime2);
        addstat(STAT_HGREGENPAUSED2, AS_INT, hg_regenpaused2);
        addstat(STAT_HGREGENRATE2, AS_FLOAT, hg_regenrate2);
    }
    
    g_nadgets_oldhitboxes = CVAR(g_nadgets_oldhitboxes);
    g_nadgets_detonatelaunches = CVAR(g_nadgets_detonatelaunches);
}

void HG_Precache() {
    precache_sound("hk/alarm.wav");
    precache_sound("weapons/grenade_bounce1.wav");
    precache_sound("weapons/grenade_bounce2.wav");
    precache_sound("weapons/grenade_bounce3.wav");
    precache_sound("weapons/grenade_bounce4.wav");
    precache_sound("weapons/grenade_bounce5.wav");
    precache_sound("weapons/grenade_bounce6.wav");
    precache_sound("weapons/grenade_fire.wav");
    precache_sound("weapons/grenade_stick.wav");
    precache_sound("weapons/rm_nadebeep.wav");
    precache_sound("weapons/electro_bounce.wav");
    precache_sound("weapons/rocket_mode.wav");
    precache_sound("weapons/nexfire.wav");
    precache_sound("weapons/electro_fire2.wav");
    precache_sound("porto/expire.wav");
    precache_sound("misc/powerup_shield.wav");
    precache_sound("misc/gg.wav");
    precache_sound("misc/stealth.wav");
    precache_sound("misc/unstealth.wav");
    precache_sound("kh/capture.wav");
    precache_sound(RM_SOUND_LASER_PRIMARY);
    precache_sound(RM_SOUND_LASER_SECONDARY);
    precache_model("models/mine.md3");
    precache_model("models/hg_transloc.md3");
    precache_model("models/ctf/shield.md3");
    precache_model("models/turrets/tesla.md3");
}

void HG_SetContext(float isalt) {
    hg_context_isaltintended = isalt;

    if(!g_nadgets_double)
        isalt = FALSE;

    if(isalt) {
        hg_ctx_next = hg_next2;
        hg_ctx_ammo = hg_ammo2;
        hg_ctx_type = hg_type2;
        hg_ctx_type_picked = hg_type2_picked;
        hg_ctx_type_picked_nextround = hg_type2_picked_nextround;
        hg_ctx_regentime = hg_regentime2;
        hg_ctx_maxregentime = hg_maxregentime2;
        hg_ctx_regenrate = hg_regenrate2;
        hg_ctx_regenpaused = hg_regenpaused2;
    } else {
        hg_ctx_next = hg_next1;
        hg_ctx_ammo = hg_ammo1;
        hg_ctx_type = hg_type1;
        hg_ctx_type_picked = hg_type1_picked;
        hg_ctx_type_picked_nextround = hg_type1_picked_nextround;
        hg_ctx_regentime = hg_regentime1;
        hg_ctx_maxregentime = hg_maxregentime1;
        hg_ctx_regenrate = hg_regenrate1;
        hg_ctx_regenpaused = hg_regenpaused1;
    }

    hg_context_isalt = isalt;
}

void HG_GiveBonus(entity p, float hgtype, float amount, string reason, float allowOptout) {
    if(!g_nadgets || (allowOptout && p.hg_optout))
        return;

    amount *= GRENVAR(hgtype, "bonus_amount_multiplier") * Buffs_NadgetBonusMultiplier(p);

    if(amount < 1)
        return;

    if(p.hg_bonustype != hgtype)
        p.hg_bonus = 0;

	p.hg_bonus += amount;
	p.hg_bonustype = hgtype;
    p.hg_bonus_next = 0;

	string n = HG_TypeToExpandedName(hgtype);
	entity e;
	
	FOR_EACH_REALCLIENT(e) if(e.iscreature || e.classname == "spectator") {
        entity check = e;
        if(!e.iscreature)
            check = e.enemy;

        if(check == p)
            bigprint(e, strcat("^7You got a ^3", n, "^7 bonus!"), reason, 3);
        else if(IsDifferentTeam(check, p))
            bigprint(e, strcat("^3Enemy got a ^1", n, " ^3bonus!"), strcat("Given to ^3", p.netname, " ^7(", reason, ")"), 3);
        else
            centerprint(e, strcat("^3", p.netname, "^7 got a ^3", n, " ^7bonus (", reason, ")"));
    }

	bprint(strcat("^3", p.netname, " ^7got a ^3", n, "^7 bonus (", reason, ")\n"));
    play2all("kh/alarm.wav");
}

void HG_GiveRandomBonus(entity p, float amount, string reason, float allowOptout) {
    if(!g_nadgets || (allowOptout && p.hg_optout))
        return;

    RandomSelection_Init();

    float n;
    for(n = HG_START; n <= HG_END; ++n) {
        if(g_freeze || (n != HG_BAIT)) {
            float w = GRENVAR(n, "bonus_random_weight");
            if(w)
                RandomSelection_Add(world, n, string_null, w, 1);
        }
    }

    if(RandomSelection_chosen_float)
        HG_GiveBonus(p, RandomSelection_chosen_float, amount, reason, allowOptout);
}

void HG_Napalm_Burn(float dt, float dist, float damage, float edgedamage, float burntime, float dtype)
{
    entity e, o;
    float d, df, ismedic, sameteam;
    vector p;
    
    o = self.owner;
    df = 1;

    if(o.classname != "jailbreak_torture" && (o.classname != "player" || o.team != self.team)) {
        remove(self);
        return;
    }

    ismedic = Buffs_BuffPower(o, BUFF_MEDIC);
    for(e = findradius(self.origin, dist); e; e = e.chain) if(e.classname == "player")
    {
        sameteam = !IsDifferentTeam(o, e);

        if(!ismedic) {
            if(sameteam && o != e)
                if(!CVAR(g_friendlyfire))
                        continue;
                
            if(!Buffs_TenacityDamage(e, o, damage, dtype))
                continue;
        }
        
        p = e.origin;
        p_x += e.mins_x + random() * (e.maxs_x - e.mins_x);
        p_y += e.mins_y + random() * (e.maxs_y - e.mins_y);
        p_z += e.mins_z + random() * (e.maxs_z - e.mins_z);
        d = vlen(self.origin - p);
        if(d < dist)
        {
            traceline(p, self.origin, MOVE_NORMAL, e);
            if(/* trace_startsolid || */ trace_fraction != 1)
                continue;
            
            if(e.frozen && !(ismedic && sameteam)) {
                e.revprogress = 0;
                continue;
            }
            
            e.fireball_impactvec = p;
            d = vlen(self.origin - e.fireball_impactvec);
            d = damage + (edgedamage - damage) * (d / dist);
            Fire_AddDamage(e, o, d * burntime * df, burntime, dtype);
        }
    }
}

.entity heal_emitter;
.float heal_emitter_radius;

void HG_HealEmitter_Think(void) {
    if(!self.owner || wasfreed(self.owner)) {
        remove(self);
        return;
    }
    
    if(self.origin != self.oldorigin)
        UpdateCSQCProjectile(self);

    self.oldorigin = self.origin;
    self.nextthink = time;
}

void HG_HealEmitter(void) {
    if(Buffs_BuffPower(self.owner, BUFF_MEDIC)) {
        if(!self.heal_emitter) {
            entity e = spawn();
            e.owner = self;
            e.movetype = MOVETYPE_FOLLOW;
            e.aiment = self;
            e.think = HG_HealEmitter_Think;
            e.nextthink = time;
            //e.velocity = self.velocity;
            e.csqcprojectile_extradata = self.heal_emitter_radius;
            
            CSQCProjectile(e, TRUE, PROJECTILE_HEAL_PARTICLE_EMITTER, TRUE);
            self.heal_emitter = e;
        }
    } else {
        if(self.heal_emitter) {
            remove(self.heal_emitter);
            self.heal_emitter = world;
        }
    }
}

void HG_Napalm_Think(void) {
    if(time > self.pushltime) {
        remove(self);
        return;
    }

    HG_HealEmitter();

    HG_Napalm_Burn(GRENVAR(self.hg_type, "burndelay"), GRENVAR(self.hg_type, "burnradius"), GRENVAR(self.hg_type, "burndamage"), GRENVAR(self.hg_type, "edgeburndamage"), GRENVAR(self.hg_type, "burntime"), self.projectiledeathtype);

    self.nextthink = time + GRENVAR(self.hg_type, "burndelay");
}

void HG_Napalm_Middlefire_Think() {
	if(time > self.pushltime) {
		remove(self);
		return;
	}
	
    /*
    if(time >= self.nextparticle) {
        
        float i; for(i = 0; i < 5; ++i) {
            vector v = randomvec();
            v_z = max(0, v_z * 0.3);
            pointparticles(particleeffectnum("fire_big"), self.origin + v * CVAR(g_nadgets_napalm_middleburnradius), '0 0 0', 1);
        }
        
		self.nextparticle = time + 0.1 + random () * 0.5;
	}
    */
    
	HG_Napalm_Burn(0.1, CVAR(g_nadgets_napalm_middleburnradius), CVAR(g_nadgets_napalm_burndamage), CVAR(g_nadgets_napalm_edgeburndamage), CVAR(g_nadgets_napalm_burntime), self.projectiledeathtype);
	self.nextthink = time + 0.1;
}

void HG_Napalm_Projectile_Touch()
{
    PROJECTILE_TOUCH;
}

void HG_Napalm()
{
	entity proj;
	vector kick;
    
	proj = spawn();
	proj.owner = self.owner;
    proj.hg_type = self.hg_type;
	proj.classname = "hg_napalm";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = GRENVAR(self.hg_type, "burnradius") + 300; //Havoc said set at least +60 to hit radius
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = self.projectiledeathtype | HITTYPE_SECONDARY;
	proj.touch = HG_Napalm_Projectile_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '0 0 -3', '0 0 -3');
	setorigin (proj, self.origin);
	proj.org_explosion = self.origin;
	proj.think = HG_Napalm_Think;
	proj.nextthink = time;
	proj.reset = SUB_Remove;
	proj.damageforcescale = GRENVAR(self.hg_type, "damageforcescale");
	kick_x = (random () - 0.5) * 2 * GRENVAR(self.hg_type, "spread_xy");
	kick_y = (random () - 0.5) * 2 * GRENVAR(self.hg_type, "spread_xy");
	kick_z = max(
						GRENVAR(self.hg_type, "spread_z")
					*	random(),
					
						GRENVAR(self.hg_type, "spread_z_min")
					+ 	GRENVAR(self.hg_type, "spread_z_min_randomfactor")
					*	(random() - 0.5) * 2
				);
	proj.velocity = kick;
	proj.pushltime = time + Buffs_NadgetPower(self.owner) * (GRENVAR(self.hg_type, "fire_lifetime") + GRENVAR(self.hg_type, "fire_lifetime_randomfactor") * (random() - 0.5) * 2);
    
	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.csqcprojectile_extradata = GRENVAR(self.hg_type, "burnradius");
    proj.heal_emitter_radius = proj.csqcprojectile_extradata;
    proj.team = self.owner.team;
    proj.effects = EF_NODEPTHTEST;
    
    Buffs_MEODP_Point_Attach(proj, Buffs_MEODP_Death_Remove_Multiple);
    proj.meodp_point_offs = '0 0 64';
    
	CSQCProjectile(proj, TRUE, PROJECTILE_HG_NAPALMSHARD, TRUE);
    proj.jb_proj_ownerstate = self.jb_proj_ownerstate;
}

void HG_Napalm_Explode() {
	local float c;
	for (c = 0; c < CVAR(g_nadgets_napalm_numparticles); c ++) HG_Napalm();
	
	entity mid = spawn();
	mid.owner = self.owner;
	mid.origin = self.origin;
	setorigin(mid, mid.origin);
	mid.think = HG_Napalm_Middlefire_Think;
    mid.reset = SUB_Remove;
	mid.nextthink = time;
	mid.pushltime = time + CVAR(g_nadgets_napalm_fire_lifetime);
    mid.team = self.team;
    mid.projectiledeathtype = HG_NAPALM;
    mid.csqcprojectile_extradata = CVAR(g_nadgets_napalm_middleburnradius);
	setsize(mid, '0 0 0', '0 0 0');
    
    CSQCProjectile(mid, TRUE, PROJECTILE_HG_NAPALMSHARD, TRUE);
}

void HG_Plasma_Projectile_Explode() {
    if(self.meodp_point.enemy) {
        self.owner = self.meodp_point.enemy;
        self.team = self.meodp_point.enemy.team;
    }

	self.event_damage = SUB_Null;
	self.takedamage = DAMAGE_NO;
    self.damage_noinfo = FALSE;
    float p = Buffs_NadgetPower(self.owner);
	RadiusDamage(self, self.owner, CVAR(g_nadgets_plasma_projectile_damage)*p, CVAR(g_nadgets_plasma_projectile_edgedamage)*p, CVAR(g_nadgets_plasma_projectile_radius), world, CVAR(g_nadgets_plasma_projectile_force)*p, HG_PLASMA | HITTYPE_BOUNCE, other);
	remove(self);
}

void HG_Plasma_Projectile_Think() {
    entity e;
    float found;
    
    if(time >= self.hg_detonatetime) {
        HG_Plasma_Projectile_Explode();
        return;
    }
    
    if(self.hg_plasma_projdist) {
        for(e = world; (e = findfloat(e, csqcprojectile_extradata, self.csqcprojectile_extradata));) if(e != self)
            if(e.owner == self.owner) if(e.projectiledeathtype == self.projectiledeathtype)
            if(vlen(self.origin - e.origin) < self.hg_plasma_projdist) {
                found = TRUE;
                break;
            }
        
        if(!found) {
            HG_Plasma_Projectile_Explode();
            return;
        }
    }
    
    if(time > self.hg_plasma_projdps_next) {
        float pdmg = self.hg_plasma_projdps * (time - self.hg_plasma_projdps_last);
        RadiusDamage(self, self.owner, pdmg, pdmg, self.hg_plasma_projrange, world, 0, self.projectiledeathtype, world);
        self.hg_plasma_projdps_next = time + self.hg_plasma_projdps_delay;
        self.hg_plasma_projdps_last = time;
    }
    
    HG_HealEmitter();

    self.nextthink = time;
}

void HG_Plasma_Projectile_Touch()
{
    PROJECTILE_TOUCH;
    spamsound(self, CHAN_PROJECTILE, "weapons/electro_bounce.wav", VOL_BASE, ATTN_NORM);
}

void HG_Plasma_Projectile() {
	local entity proj;
    vector kick;
    
	proj = spawn();
	proj.classname = "hg_plasma";
	proj.owner = self.owner;
    proj.team = proj.owner.team;
	proj.use = HG_Plasma_Projectile_Explode;
	proj.think = HG_Plasma_Projectile_Think;
    proj.nextthink = time;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = CVAR(g_nadgets_plasma_projectile_damage) + 300; // just avoid plasma
    proj.hg_detonatetime = time + CVAR(g_nadgets_plasma_projectile_lifetime) + random() * CVAR(g_nadgets_plasma_projectile_lifetime_randomfactor);

    PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = HG_PLASMA | HITTYPE_SECONDARY;
	setorigin(proj, self.origin);
    
	proj.movetype = MOVETYPE_BOUNCE;
    
    kick_x = (random () - 0.5) * 2 * CVAR(g_nadgets_plasma_spread_xy);
	kick_y = (random () - 0.5) * 2 * CVAR(g_nadgets_plasma_spread_xy);
	kick_z = max(
						CVAR(g_nadgets_plasma_spread_z)
					*	random(),
					
						CVAR(g_nadgets_plasma_spread_z_min)
					+ 	CVAR(g_nadgets_plasma_spread_z_min_randomfactor)
					*	(random() - 0.5) * 2
				);

    proj.velocity = kick;
	proj.touch = HG_Plasma_Projectile_Touch;
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.takedamage = DAMAGE_NO;
	proj.flags = FL_PROJECTILE;
    proj.hg_plasma_projrange = CVAR(g_nadgets_plasma_projectile_dps_range);
    proj.hg_plasma_projdps = CVAR(g_nadgets_plasma_projectile_dps) * Buffs_NadgetPower(self.owner);
    proj.hg_plasma_projdps_delay = CVAR(g_nadgets_plasma_projectile_dps_delay);
    proj.hg_plasma_projdist = CVAR(g_nadgets_plasma_projectile_maxdistance);
    proj.hg_plasma_projdps_next = time + CVAR(g_nadgets_plasma_projectile_dps_pause) + random() * CVAR(g_nadgets_plasma_projectile_dps_pause_randomfactor);
    proj.hg_plasma_projdps_last = proj.hg_plasma_projdps_next - proj.hg_plasma_projdps_delay;
    proj.csqcprojectile_extradata = hg_plasma_group;
    proj.heal_emitter_radius = proj.hg_plasma_projrange;
    proj.damage_noinfo = TRUE;
    
    Buffs_MEODP_Point_Attach(proj, Buffs_MEODP_Death_Use_Multiple);
    proj.meodp_point_offs = '0 0 16';
    
    sound(proj, CHAN_WEAPON, "weapons/electro_fire2.wav", VOL_BASE, ATTN_NORM);
	CSQCProjectile(proj, TRUE, PROJECTILE_HG_PLASMA_SHARD, FALSE);
    proj.jb_proj_ownerstate = self.jb_proj_ownerstate;
}

void HG_Plasma_Explode() {
    float c;
    
    if(self.hg_adept)
        return;
    
    ++hg_plasma_group;
    for (c = 0; c < CVAR(g_nadgets_plasma_projectile_count); c ++) HG_Plasma_Projectile();
}

void HG_Remote_Explode() {
    float c;
    for (c = 0; c < CVAR(g_nadgets_remote_numparticles); c ++) HG_Napalm();
}

void HG_Translocator_Explode() {
    if(g_jailbreak && self.owner.jb_isprisoned)
        return;
        
    if(time < self.jb_jail_resettime)
        return;
    
    setsize(self, PL_MIN, PL_MAX);
    
    if(!move_out_of_solid(self)) {
        if(!self.hg_isbonus) HG_DO_IN_ALL_CONTEXTS(if(self.owner.hg_ctx_type == HG_TRANSLOC)
            self.owner.hg_ctx_ammo += 1;)
            
        bprint("^1Couldn't move ", self.owner.netname, "^1's translocator out of solid! Teleport aborted. Origin: ", vtos(self.origin), ", velocity: ", vtos(self.velocity), "\n");
        return;
    }
    
    if(self.owner.flagcarried)
        DropFlag(self.owner.flagcarried, world, world);
    
    vector a;
    a = vectoangles(normalize(self.hg_lastvel));
    a_x = self.owner.v_angle_x;
    makevectors(a);
    
    tdeath_hit = 0;
    tdeath_deathtype = self.hg_type;
    TeleportPlayer(self, self.owner, self.origin, a, v_forward * (0.5 + 0.5 * Buffs_NadgetPower(self.owner)) * (
                    GRENVAR(self.hg_type, "push_base")
                  + GRENVAR(self.hg_type, "push_playerfactor") * vlen(self.owner.velocity)
                  + GRENVAR(self.hg_type, "push_projfactor")   * vlen(self.velocity)), '0 0 0', '0 0 0');
    tdeath_deathtype = 0;
    
    if(tdeath_hit && !self.hg_isbonus) {
        float b = CVAR(g_nadgets_transloc_telefragbonus);
        
        if(b) HG_DO_IN_ALL_CONTEXTS({
            self.owner.hg_ctx_ammo += b * tdeath_hit;
            HG_SetRegenTime(self.owner, HG_RegenTime(self.owner));
        })
    }
    
    entity oldself = self;
    self = self.owner;
    if(GRENVAR(oldself.hg_type, "reloadonuse")) {
        weapon_action(self.weapon, WR_RESETPLAYER);
        ATTACK_FINISHED(self) = TRUE;
    }
    self = oldself;
}

float HG_TypeToCSQCProjType(float t) {
	switch(t) {
		case HG_NAPALM  :   return PROJECTILE_HG_NAPALM;
		case HG_PLASMA  :   return PROJECTILE_HG_PLASMA;
        case HG_TRANSLOC:   return PROJECTILE_HG_TRANSLOC;
        case HG_REMOTE  :   return PROJECTILE_HG_REMOTE;
        case HG_LASER   :   return PROJECTILE_HG_LASER;
		default         :   return PROJECTILE_HG_GENERIC;
	}
}

#define GV(v) (GRENVAR(self.hg_type, v))
void HG_Grenade_RadiusDamage() {
    float p = Buffs_NadgetPower(self.owner);
    float dmgmod = 1;
    float frcmod = 1;
    
    if(self.hg_adept) {
        if(GV("adept_damagemod")) {
            dmgmod = dmgmod * (1 + (GV("adept_damagemod") - 1) * self.hg_adept);
        }
        
        if(GV("adept_forcemod")) {
            frcmod = frcmod * (1 + (GV("adept_forcemod")  - 1) * self.hg_adept);
        }
    }

    dmgmod *= pow(GV("damage_bouncemultiplier"), GV("bouncelimit") - self.cnt);
    
    dmgmod *= pow(GV("damage_bouncemultiplier"), GV("bouncelimit") - self.cnt);

    RadiusDamage(self, self.owner,
                       GV("damage") * p * dmgmod,
                       GV("edgedamage") * p * dmgmod,
                       GV("radius"), 
                       world,
                       GV("force") * frcmod,
                       self.projectiledeathtype,
                       other
                );
}

void HG_Grenade_Explode()
{
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.owner, other))
				if(IsFlying(other))
					announce(self.owner, "announcer/male/airshot.wav");

	self.event_damage = SUB_Null;
	self.takedamage = DAMAGE_NO;
	
    if(self.hg_type == HG_NAPALM) {
        HG_Napalm_Explode();
    } else if(self.hg_type == HG_PLASMA) {
        HG_Plasma_Explode();
    } else if(self.hg_type == HG_REMOTE) {
        HG_Remote_Explode();
    } else if(self.hg_type == HG_TRANSLOC) {
        HG_Translocator_Explode();
    }
    
    HG_Grenade_RadiusDamage();
    HG_Grenade_Remove();
}
#undef GV

void HG_Grenade_Touch() {
    PROJECTILE_SKIPNONSOLID
    if(SUB_OwnerCheck())
        return;
    
    if(SUB_NoImpactCheck()) {
        if(self.hg_type == HG_TRANSLOC) {
            if(trace_dphitcontents & DPCONTENTS_PLAYERCLIP)
                goto troll;
            self.use();
            return;
        }
        HG_Grenade_Remove();
        return;
    }
    
    if(!self.hg_sticked)
    if(trace_ent && trace_ent.solid > SOLID_TRIGGER) {
        UpdateCSQCProjectileNextFrame(self);
    }
    
    if(other.classname == "hg_grenade" && other.owner == self.owner)
        return;
    
    if(other.takedamage == DAMAGE_AIM) {
        if(self.hg_type == HG_TRANSLOC && teams_matter && other.team == self.owner.team) {
            float adeptRev = (Buffs_BuffPower(self.owner, BUFF_ADEPT) && CVAR(g_nadgets_transloc_adept_revive));

            if(adeptRev || Buffs_BuffPower(self.owner, BUFF_MEDIC)) {
                if(g_freeze && other.frozen) {
                    self.owner.chain = world;
                    Freeze_RevivePlayer(other, self.owner);
                    self.hg_tl_revived = TRUE;

                    float m = CVAR(g_nadgets_transloc_medic_revive_health_multiplier);
                    float h = other.health * m;
                    float a = other.armorvalue * m;

                    if(adeptRev)
                        m = max(1.0, m);

                    if(m > 1.0)
                        Heal(other, self, self.owner, other.health - h, other.armorvalue - a, 0, 0, HG_TRANSLOC, 0, 0, self.origin, '0 0 0');
                    else if(m < 1.0) {
                        other.health = h;
                        other.armorvalue = a;
                        other.pauseregen_finished = time + CVAR(g_balance_pause_health_regen);
                    }
                }
            } else goto troll;
        } else if(self.hg_type == HG_REMOTE)
            goto troll;
            
        self.use();
    } else {
        vector normal = trace_plane_normal;

        if(self.hg_type == HG_TRANSLOC && CVAR(g_nadgets_transloc_bounceresetorigin))
            self.spawnorigin = self.origin;

        // Check if we should stop bouncing around, then stick or explode if so.
        if(self.cnt <= 0) {
            float isFloor = (normal == '0 0 1');
            float doStick;

            if(self.hg_adept)
                doStick = GRENVAR(self.hg_type, "adept_stick");
            else
                doStick = GRENVAR(self.hg_type, "stick");

            if(doStick) {
                self.velocity = '0 0 0';

                if(self.hg_type == HG_TRANSLOC) {
                    // Check if it's ok to teleport in this location
                    // by assuming a player-sized bbox and trying to move out of solid.
                    // If that fails, remove and refund the translocator
                    
                    if(!self.hg_transloc_solidcheck) {
                        self.hg_transloc_solidcheck = TRUE;
                        
                        vector omins = self.mins;
                        vector omaxs = self.maxs;
                        vector oorig = self.origin;
                        setsize(self, PL_MIN, PL_MAX);
                        
                        if(!move_out_of_solid(self)) {
                            if(!self.hg_isbonus) HG_DO_IN_ALL_CONTEXTS(if(self.owner.hg_ctx_type == HG_TRANSLOC) 
                                self.owner.hg_ctx_ammo += 1;)
                            
                            bprint("^1Couldn't move ", self.owner.netname, "^1's translocator out of solid! Teleport aborted.\n");
                            HG_Grenade_Remove();
                            return;
                        }
                        
                        setsize(self, omins, omaxs);
                        setorigin(self, oorig);
                    }
                }

                trace_plane_normal = normal;
                HG_Stick();

                return;
            } else
                self.use();

            return;
        } else if(self.hg_type == HG_LASER)
            HG_Grenade_RadiusDamage();

:troll

        if(self.hg_type == HG_LASER)
            spamsound(self, CHAN_PROJECTILE, RM_SOUND_LASER_SECONDARY, VOL_BASE, ATTN_NORM);
        else {
            float r;
            r = random() * 6;
            if(r < 1)
                spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce1.wav", VOL_BASE, ATTN_NORM);
            else if(r < 2)
                spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce2.wav", VOL_BASE, ATTN_NORM);
            else if(r < 3)
                spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce3.wav", VOL_BASE, ATTN_NORM);
            else if(r < 4)
                spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce4.wav", VOL_BASE, ATTN_NORM);
            else if(r < 5)
                spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce5.wav", VOL_BASE, ATTN_NORM);
            else
                spamsound(self, CHAN_PROJECTILE, "weapons/grenade_bounce6.wav", VOL_BASE, ATTN_NORM);
        }
    
        self.cnt -= 1;
        self.hg_state = TRUE;
    }
}

void HG_Stick(void) {
    spamsound(self, CHAN_PROJECTILE, "weapons/grenade_stick.wav", 1, ATTN_NORM);

    vector normal = trace_plane_normal;

    // TODO: A better, more general fix
    if(trace_ent.classname == "misc_terminal")
        return;

    entity e = spawn();
    float d = self.owner.hg_detonables;
    
    e.classname = self.classname;
    e.bot_dodge = self.bot_dodge;
    e.bot_dodgerating = self.bot_dodgerating;
    e.owner = self.owner;

    if(self.hg_type == HG_TRANSLOC)
        e.angles = randomvec() * 360;
    else
        e.angles = vectoangles(-normal);
    

    e.skin = TeamColorSkin(e.owner.team);

    // FIXME: a better way to sync this with client code?
    switch(self.hg_type) {
        case HG_REMOTE:
            setmodel(e, "models/mine.md3");
            break;
        case HG_TRANSLOC:
            setmodel(e, "models/hg_transloc.md3");
            e.pflags = PFLAGS_FULLDYNAMIC | PFLAGS_CORONA;
            e.light_lev = 50;
            e.color = TeamColor(if(self.team > 0) self.team else COLOR_TEAM4);
            break;
        case HG_LASER:
            setmodel(e, "models/elaser.mdl");
            break;
        default:
            setmodel(e, "models/grenademodel.md3");
            break;
    }
    
    e.damageforcescale = self.damageforcescale;
    e.health = self.health;
    e.max_health = self.max_health;
    e.takedamage = self.takedamage;
    e.event_damage = self.event_damage;
    e.solid = self.solid;
    e.dphitcontentsmask = self.dphitcontentsmask;
    e.use = self.use;
    e.movetype = if(trace_ent) MOVETYPE_TOSS else MOVETYPE_NONE;
    e.hg_type = self.hg_type;
    e.projectiledeathtype = self.projectiledeathtype;
    e.think = HG_Grenade_Think;
    e.nextthink = self.nextthink;
    e.flags = self.flags;
    e.team = self.team;
    e.hg_sticked = TRUE;
    e.hg_deathtime = self.hg_deathtime;
    e.hg_sndcount = self.hg_sndcount;
    e.hg_nextsnd = self.hg_nextsnd;
    e.hg_detonable = self.hg_detonable;
    e.hg_detonatetime = self.hg_detonatetime;
    e.hg_detonatedelay = self.hg_detonatedelay;
    e.hg_detonateready = self.hg_detonateready;
    e.hg_detonable_updated = self.hg_detonable_updated;
    e.reset = self.reset;
    e.jb_proj_ownerstate = self.jb_proj_ownerstate;
    e.hg_state = TRUE;
    e.hg_adept = self.hg_adept;
    setsize(e, '-5 -5 -5', '5 5 5');
    setorigin(e, self.origin);
    
    // For the translocator (face against the wall when teleporting)
    if(normal == '0 0 1')
        e.hg_lastvel = self.hg_lastvel;
    else
        e.hg_lastvel = normal;

    e.meodp_point = self.meodp_point;
    e.meodp_point_offs = self.meodp_point_offs;
    e.meodp_death = self.meodp_death;
    if(e.meodp_point)
        e.meodp_point.owner = e;

    if(self.hg_type == HG_REMOTE) {    
        if(normal_x)
            setorigin(e, e.origin - normal * 4.5);
    }

    move_out_of_solid(e);
    
    if(self.hg_waypoint) {
        entity wp = self.hg_waypoint;
        self.hg_waypoint = world;
        wp.owner = e;
        wp.exteriormodeltoclient = e;
        e.hg_waypoint = wp;
    }
        
    HG_Grenade_Remove();
    self = e;
    
    self.owner.hg_detonables = d;
}

float HG_RegenTime(entity e) {
    float base      = GRENVAR(e.hg_ctx_type, "regen_time");
    float exponent  = GRENVAR(e.hg_ctx_type, "regen_exponent");
    float factor    = GRENVAR(e.hg_ctx_type, "regen_factor");

    return base * (1 + pow(e.hg_ctx_ammo, exponent) * factor);
}

void HG_SetRegenTime(entity e, float t) {
    e.hg_ctx_regentime = t;
    e.hg_ctx_maxregentime = t;
}

float HG_PlayerMayDetonate(entity p) {
    if(CVAR(g_nadgets_detonate_on_death))
        return TRUE;
    return (p.health >= 1) && !(g_freeze && p.frozen);
}

void HG_Detonate(entity nade) {
    if(!nade || !nade.hg_detonable || nade.hg_detonatetime || nade.hg_detonateready > time)
        return;
        
    nade.hg_detonatetime = time + nade.hg_detonatedelay;
    if(nade.hg_detonable_updated && nade.owner) {
        nade.hg_detonable_updated = FALSE;
        nade.owner.hg_detonables -= 1;
    }
}

void HG_DetonateAll(entity plr) {
    float c;
    entity nade, tl;
    
    if(!plr.hg_detonables)
        return;
    
    if(!HG_PlayerMayDetonate(plr))
        return;

    for(nade = world; (nade = find(nade, classname, "hg_grenade"));) {
        if(nade.owner == plr && nade.hg_type == HG_TRANSLOC) {
            if(!tl || nade.hg_nadesused < tl.hg_nadesused)
                tl = nade;
        }
    }
    
    if(tl) {
        c = 1;
        HG_Detonate(tl);
    } else for(nade = world; (nade = find(nade, classname, "hg_grenade"));) if(nade.owner == plr) {
        HG_Detonate(nade);
        ++c;
    }

    if(c)
        sound(plr, CHAN_WEAPON2, "weapons/rocket_mode.wav", VOL_BASE, ATTN_NORM);
}

void HG_RemoveAll(entity plr) {
    entity n;
    
    if(!g_nadgets)
        return;
    
    for(n = world; (n = findfilter(n, inline float(entity e) {
        var c = e.classname;
        return (c == "hg_grenade")  ||
               (c == "hg_plasma")   ||
               (c == "hg_napalm")   ||
               (c == "hg_linker")   ||
               (c == "hg_sentry");
    }));) {
        if((n.realowner && n.realowner == plr) || n.owner == plr)
            HG_Grenade_FadeOut(n);
    }
}

void HG_Grenade_Remote_Waypoint_Update(string wpname) {
    if(!self.hg_waypoint) {
        float ownerhack = (self.hg_type == HG_BAIT || self.hg_type == HG_SENTRY);

        WaypointSprite_Spawn(wpname, 0, 0, self, '0 0 32' * (1 + 1 * ownerhack + 1 * (self.hg_type == HG_SENTRY)), (if(ownerhack) self.realowner else self.owner), 0, self, hg_waypoint, 1);

        if(self.hg_type == HG_SENTRY) {
            WaypointSprite_UpdateMaxHealth(self.hg_waypoint, 1);
            WaypointSprite_UpdateTeamRadar(self.hg_waypoint, 0, '1 0.5 0');
        } else if(self.hg_detonateready > time) {
            WaypointSprite_UpdateTeamRadar(self.hg_waypoint, 0, '0 1 1');
            WaypointSprite_UpdateBuildFinished(self.hg_waypoint, self.hg_detonateready);
        } else if(self.hg_type == HG_TRANSLOC || self.hg_type == HG_BAIT) {
            WaypointSprite_UpdateTeamRadar(self.hg_waypoint, 0, '0 1 1');
            WaypointSprite_UpdateBuildFinished(self.hg_waypoint, self.hg_deathtime);
        }
    } else {
        WaypointSprite_UpdateSprites(self.hg_waypoint, wpname, "", "");

        if(self.hg_type == HG_SENTRY) {
            if(self.hg_wp_state) {
                WaypointSprite_UpdateMaxHealth(self.hg_waypoint, 1);
                WaypointSprite_UpdateHealth(self.hg_waypoint, self.hg_sentry_energy);
            } else
                WaypointSprite_UpdateMaxHealth(self.hg_waypoint, 0);
        }
    }
}

void HG_Grenade_Waypoint() {
    entity plr;
    float detected;
    float rng;
    
    if(time < self.hg_wp_nextthink)
        return;
    
    if(self.hg_type == HG_SENTRY) {
        if(self.hg_waypoint)
            WaypointSprite_UpdateHealth(self.hg_waypoint, self.hg_sentry_energy);

        detected = (self.hg_sentry_energy < 1);
    } else if(self.hg_type == HG_BAIT)
        detected = self.revprogress;
    else {
        if(self.hg_adept && GRENVAR(self.hg_type, "adept_detect_enemies"))
            rng = GRENVAR(self.hg_type, "adept_detect_enemies");
        else
            rng = GRENVAR(self.hg_type, "detect_enemies");
        
        if(!rng) {
            if(self.hg_waypoint)
                WaypointSprite_Disown(self.hg_waypoint, 0.5);
            return;
        }
        
        if(rng > 0) FOR_EACH_PLAYER(plr) if(plr.team != self.team || !teams_matter) if(plr != self.owner) if(!(g_freeze && plr.frozen)) {
            if(vlen(self.origin - plr.origin) < rng)
            if(checkpvs(self.origin, plr)) {
                detected = TRUE;
                break;
            }
        }
    }
    
    if(detected) {
        if(!self.hg_wp_state) {
            self.hg_wp_state = TRUE;
            HG_Grenade_Remote_Waypoint_Update("pointer_red");
        }
    } else if(self.hg_wp_state || !self.hg_waypoint) {
        self.hg_wp_state = FALSE;
        HG_Grenade_Remote_Waypoint_Update("pointer_cyan");
    }

    self.hg_wp_nextthink = time + 0.1;
}

void HG_Grenade_Think() {
	#define GV(v) (GRENVAR(self.hg_type, v))
    
    //print(vtos(self.velocity), " ^6", vtos(self.hg_lastvel), "\n");

    if(self.velocity != '0 0 0')
        self.hg_lastvel = self.velocity;
    
    if(self.solid == SOLID_NOT)
        self.solid = SOLID_TRIGGER;
    
    if(self.hg_type == HG_TRANSLOC) {
        tracebox(self.origin, self.mins, self.maxs, self.origin, MOVE_WORLDONLY, self);
        if(trace_startsolid && !self.hg_ranthink) {
            bprint(self.owner.netname, "^1's translocator spawned in solid! ", vtos(self.origin), "\n");
            HG_Grenade_Remove();
            return;
        }
    }
    
    HG_Grenade_Waypoint();
    
    //move_out_of_solid(self);
    if(time >= self.hg_deathtime) {
        if(self.hg_type == HG_TRANSLOC && self.health > 0)
            HG_Grenade_Remove();
        else
            self.use();
        return;
    }
    
    if(self.hg_detonable)
    if(time >= self.hg_detonateready)
    if(!self.hg_detonatetime)
    if(!self.hg_detonable_updated) {
        self.hg_detonable_updated = TRUE;
        self.owner.hg_detonables += 1;
    }
    
    if(self.hg_detonable && self.hg_detonatetime) {
        if(time >= self.hg_detonatetime) {
            if(self.hg_type == HG_REMOTE && self.hg_adept) {
                self.hg_adept = 0;
                self.health = self.max_health;
                HG_Remote_Explode();
                HG_Grenade_RadiusDamage();
                self.hg_detonateready = time + GRENVAR(self.hg_type, "adept_detonate_threshold");
                self.hg_detonatetime = 0;
                self.hg_sndcount = 0;
                WaypointSprite_Disown(self.hg_waypoint, 0.5);
            } else {
                self.use();
                return;
            }
        } else if(time >= self.hg_nextsnd) {
            spamsound(self, CHAN_PROJECTILE, "weapons/rm_nadebeep.wav", VOL_BASE * 0.5, ATTN_NORM * 2);
            self.hg_sndcount += 1;
            self.hg_nextsnd = time + max((self.hg_detonatedelay * 0.3) / (pow(self.hg_sndcount, 1.2)), 0.1);
        }
    }
    
    self.nextthink = time;
    self.hg_ranthink += 1;
    #undef GV
}

void HG_Grenade_ChangeOwner(entity o) {
    if(!o || o == self.owner)
        return;
    
    if(self.hg_detonable_updated) {
        self.owner.hg_detonables -= 1;
        o.hg_detonables += 1;
    }
    
    self.owner = o;
    self.team = o.team;
}

void HG_Grenade_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) {
    if(DEATH_ISHG(deathtype))
        return;
    if(self.health <= 0)
        return;
    if(!self.hg_state)
        return;
    self.health = self.health - damage;
    if(self.health <= 0) {
        if(self.hg_type != HG_TRANSLOC)
        if(attacker.classname == "player")
            HG_Grenade_ChangeOwner(attacker);
        self.hg_deathtime = time;
    }
}

float HG_PlayerGrenadeType(entity e) {
    float picked = HG_NameToType(CVAR_STR(g_nadgets_type));
    float argc = tokenize_console(CVAR_STR(g_nadgets_type_selectable));
    float i;
    
    if(argc)
        for(i = 0; i < argc; ++i)
            if(e.hg_ctx_type_picked == HG_NameToType(argv(i))) {
                picked = e.hg_ctx_type_picked;
                break;
            }
    
    
    if(picked == HG_RANDOM) {
        RandomSelection_Init();
        float n; for(i = 0; i < argc; ++i) {
            n = HG_NameToType(argv(i));
            if(n != HG_RANDOM && (!hg_context_isalt || n != e.hg_type1_picked))
                RandomSelection_Add(world, n, string_null, 1, 0);
        }
        picked = RandomSelection_chosen_float;
    }
    
    e.hg_ctx_type_picked = picked;
    return e.hg_ctx_type_picked;
}

void HG_SetGrenadeType(entity p, float t) {
    p.hg_ctx_type = t;
    
    if(p.scorekeeper) {
        p.scorekeeper.SendFlags |= pow(2, SP_NADEMODE);
        p.scorekeeper.(scores[SP_NADEMODE]) = HG_CompressDualType(p.hg_type1, p.hg_type2);
    }
}

void HG_FixNadeType(entity p) {
    if(!p.hg_ctx_type) {
        print("Player ", p.netname, " ^7doesn't have a grenade type - fixing\n");
        HG_SetGrenadeType(p, HG_PlayerGrenadeType(p));
    }
}

void HG_Grenade_Remove(void) {
    if(self.hg_waypoint)
        WaypointSprite_Disown(self.hg_waypoint, 0.5);
    
    stopsound(self, CHAN_PAIN);
    
    if(self.hg_detonable_updated && self.owner)
        self.owner.hg_detonables -= 1;
    
    remove(self);
}

void HG_Grenade_FadeOut_Think(void) {
    self.alpha = approach(self.alpha, 0, frametime);
    if(self.hg_linker_factor)
        self.enemy.alpha = self.alpha * 0.5;
    
    if(!self.alpha) {
        if(self.hg_linker_factor) {
            remove(self.enemy);
            remove(self);
        } else
            HG_Grenade_Remove();
        return;
    }
    
    self.nextthink = time;
}

void HG_Sentry_Explode(void);

void HG_Grenade_FadeOut(entity n) {
    if(n.classname == "hg_sentry") {
        entity o = self;
        self = n;
        HG_Sentry_Explode();
        self = o;
        return;
    }

    if(n.hg_waypoint)
        WaypointSprite_Disown(n.hg_waypoint, 0.5);
    
    if(n.hg_detonable_updated && n.owner)
        n.owner.hg_detonables -= 1;
    
    if(!n.alpha)
        n.alpha = 1;
    
    if(n.classname == "hg_linker")
        n.hg_linker_factor = TRUE;
    
    n.solid = SOLID_NOT;
    n.takedamage = DAMAGE_NO;
    n.hg_detonable_updated = FALSE;
    n.event_damage = func_null;
    n.use = SUB_Null;
    n.think = HG_Grenade_FadeOut_Think;
    n.nextthink = time;
}

void HG_Shield_Discharge_Arc(entity attacker, entity targ, float damage) {
    entity oldself = self;
    float wantteam = targ.team;
    float targetTeamMates = wantteam == attacker.team && Buffs_BuffPower(attacker, BUFF_MEDIC);
    float dist, shortest;
    vector arcoffset = attacker.maxs_z * '0 0 0.5';
    entity plr, newtarget;
    
    damage *= CVAR(g_nadgets_shield_damage_store_arc);

    if(damage < 1)
        return;

    shortest = CVAR(g_nadgets_shield_damage_store_arc_range);
    newtarget = world;
    targ.buffs_arc_hit = TRUE;
    
    FOR_EACH_PLAYER(plr)
    if(plr != attacker)
    if(plr != targ)
    if(plr.deadflag == DEAD_NO)
    if(plr.team == wantteam)
    if(!plr.hg_stealth || (targetTeamMates && plr.team == attacker.team))
    if(!plr.jb_isprisoned)
    if(!plr.buffs_arc_hit) {
        dist = vlen(plr.origin - targ.origin);
        if(dist < shortest) {
            traceline(targ.origin + arcoffset, plr.origin + arcoffset, MOVE_NORMAL, targ);
            
            if(trace_fraction != 1 && trace_ent == plr) {
                shortest = dist;
                newtarget = plr;
            }
        }
    }
    
    if(newtarget) {
        te_csqc_lightningarc(targ.origin + arcoffset, newtarget.origin + arcoffset, TRUE, attacker.team);
        Damage(newtarget, attacker, attacker, damage, HG_SHIELD | HITTYPE_SECONDARY | HITTYPE_BOUNCE, '0 0 0', normalize(newtarget.origin - targ.origin) * CVAR(g_nadgets_shield_damage_store_arc_pushback));
        HG_Shield_Discharge_Arc(attacker, newtarget, damage);
        sound(newtarget, CHAN_PROJECTILE, "weapons/nexfire.wav", VOL_BASE, ATTN_NORM * 0.3);
    }
    
    self = oldself;
}

void HG_Shield_Discharge_Think(void) {
    entity targ;
    vector start, end;
    float damage;
    float arc = CVAR(g_nadgets_shield_damage_store_arc);

    damage = min(self.owner.hg_shield_stored, CVAR(g_nadgets_shield_damage_store_burstamount));

    if(damage <= 0 || !self.owner || !self.owner.iscreature || !PlayerMayFire(self.owner)) {
        remove(self);
        return;
    }

    makevectors(self.owner.v_angle);
    W_SetupShot(self.owner, TRUE, 2, "weapons/nexfire.wav", -1);
    traceline_antilag(self.owner, w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, self.owner);
    targ = trace_ent;
    start = w_shotorg;
    end = trace_endpos;

    setorigin(self, end);
    RadiusDamage(self, self.owner, damage, damage * CVAR(g_nadgets_shield_damage_store_edgefactor),
                 CVAR(g_nadgets_shield_damage_store_radius), world,
                 damage * CVAR(g_nadgets_shield_damage_store_forcefactor), HG_SHIELD | HITTYPE_SECONDARY, targ);

    W_SetHitscanVisuals(self.owner, end);
    te_csqc_lightningarc(w_shotorg_visual, end, TRUE, if(teams_matter) self.owner.team else COLOR_TEAM3);
    //te_blast(end);

    if(arc && targ && targ.iscreature && (IsDifferentTeam(self.owner, targ) || Buffs_BuffPower(self.owner, BUFF_MEDIC))) {
        HG_Shield_Discharge_Arc(self.owner, targ, damage);
        entity e; for(e = world; (e = findfloat(e, buffs_arc_hit, TRUE));)
            e.buffs_arc_hit = FALSE;
    }

    self.owner.hg_shield_stored -= damage;
    if(self.owner.hg_shield_stored < 0)
        self.owner.hg_shield_stored = 0;

    self.nextthink = time + CVAR(g_nadgets_shield_damage_store_burstdelay);
}

void HG_Shield_Trigger(void) {
    entity e, o;
    for(e = world; (e = find(e, classname, "hg_shield_discharge"));)
        if(e.owner == self)
            return;

    sound(self, CHAN_WEAPON2, "porto/expire.wav", VOL_BASE, ATTN_NORM);
    
    // Discharge
    float extend, renew;
    if(self.hg_shield_stored) {
        if(Buffs_BuffPower(self, BUFF_ADEPT)) {
            extend = CVAR(g_nadgets_shield_adept_discharge_extend);
            renew = CVAR(g_nadgets_shield_adept_discharge_renew);
        }

        e = spawn();
        e.classname = "hg_shield_discharge";
        e.owner = self;
        e.think = HG_Shield_Discharge_Think;
        e.reset = SUB_Remove;

        o = self;
        self = e;
        self.think();
        self = o;
    }
    
    if(extend || renew) {
        self.hg_shield = max(self.hg_shield, renew) + extend;
        stopsound(self, CHAN_AUTO);
        sound(self, CHAN_AUTO, "misc/powerup_shield.wav", VOL_BASE, ATTN_NORM);
    } else {
        self.hg_shield = 0;
        stopsound(self, CHAN_AUTO);
    }
}

void HG_Shield_Model_Think(void) {
    if(self.owner.hg_shield)
        self.alpha = approach(self.alpha, 1, frametime * 3);
    else
        self.alpha = approach(self.alpha, 0, frametime * 3);
        
    if(!self.alpha) {
        self.owner.hg_shieldmodel = world;
        remove(self);
        return;
    }
    
    self.colormod = '1 1 0';
    self.colormod_z = 1 - self.owner.hg_shieldpower;
    if(self.hg_adept && self.owner.hg_shieldpower == 1)
        self.colormod_z = 1;
    setorigin(self, self.owner.origin);
    self.nextthink = time;
}

void HG_Shield(float hgtype) {
    entity e;
    float d;
    float adept = Buffs_BuffPower(self, BUFF_ADEPT);
    
    if(adept) {
        d = GRENVAR(hgtype, "adept_duration");
    } else {
        d = GRENVAR(hgtype, "duration");
        
        if(GRENVAR(hgtype, "immobile")) {
            self.hg_shield_oldmovetype = self.movetype;
            self.movetype = MOVETYPE_NONE;
        }
    }
    
    self.hg_shieldmax = d * Buffs_NadgetPower(self);
    self.hg_shield = self.hg_shieldmax;
    self.hg_shieldhealth = GRENVAR(hgtype, "health");
    self.hg_shieldpower = 1;
    
    self.hg_shield_stored = GRENVAR(hgtype, "damage_store_base");
    self.hg_shield_stored_limit = GRENVAR(hgtype, "damage_store_limit");
    self.nobuffs = GRENVAR(hgtype, "nobuffs");
    
    if(GRENVAR(hgtype, "immobile")) {
        self.hg_shield_oldmovetype = self.movetype;
        self.movetype = MOVETYPE_NONE;
    }
    
    sound(self, CHAN_AUTO, "misc/powerup_shield.wav", VOL_BASE, ATTN_NORM);
    
    if(!self.hg_shieldmodel) {
        e = spawn();
        e.classname = "hg_shieldmodel";
        e.owner = self;
        e.think = HG_Shield_Model_Think;
        e.nextthink = time;
        e.alpha = 0.1;
        e.effects = EF_ADDITIVE | EF_FULLBRIGHT;
        e.glow_size = 256;
        e.glow_color = 230;
        e.glow_trail = 1;
        e.avelocity = '14 0 22';
        e.movetype = MOVETYPE_FOLLOW;
        e.aiment = e.owner;
        setorigin(e, self.origin);
        setmodel(e, "models/ctf/shield.md3");
        e.scale = 0.5;
        e.hg_adept = adept;
        e.skin = 10 + !!adept;
        e.exteriormodeltoclient = self;
        setsize(e, e.scale * e.mins, e.scale * e.maxs);
        
        self.hg_shieldmodel = e;
    }
}

void HG_Shield_Frame(void) {
    if(self.hg_shieldmax && self.hg_shield)
        self.hg_shieldstat = self.hg_shield / self.hg_shieldmax;
    else
        self.hg_shieldstat = 0;
    
    if(!self.hg_shield) {
        self.nobuffs = 0;

        if(self.hg_shield_oldmovetype) {
            self.movetype = self.hg_shield_oldmovetype;
            self.hg_shield_oldmovetype = 0;
        }

        if(self.hg_shield_stored && !findfilter(world, inline float(entity e) {
            return e.owner == self && e.classname == "hg_shield_discharge";
        })) self.hg_shield_stored = 0;

        return;
    }
    
    if(!self.movetype) {
        // with MOVETYPE_NONE the player model rotation will not correspond to the view direction, so fix it here
        self.angles_y = self.v_angle_y;
    }
    
    if(self.hg_shieldhealth <= 0)
        self.hg_shield = 0;
    else {
        self.hg_shield = max(0, self.hg_shield - frametime);
        if(CVAR(g_nadgets_shield_diminish))
            self.hg_shieldpower = self.hg_shield / self.hg_shieldmax;
    }
}

float HG_Shield_Damage(entity attacker, float damage, float deathtype, vector hitloc) {
    if not(g_nadgets && damage && attacker.iscreature && self.hg_shield)
        return damage;

    if(DEATH_HGTYPE(deathtype) == HG_TRANSLOC && CVAR(g_nadgets_transloc_counters_shield)) {
        self.hg_shield = 0;
        return damage;
    }

    if not(DEATH_HGTYPE(deathtype) != HG_SHIELD && deathtype != DEATH_NOISE && deathtype != DEATH_ARC && DEATH_HGTYPE(deathtype) != HG_GG)
        return damage;

    vector offs = '0 0 1' * self.maxs_z * 0.5;
    float reflect    = damage * CVAR(g_nadgets_shield_damage_reflect) * self.hg_shieldpower;
    float takefactor = 1 - (1 - CVAR(g_nadgets_shield_damage_take))   * self.hg_shieldpower;
    float absorb     = damage * (1 - takefactor);

    float o = self.hg_shield_stored;
    self.hg_shield_stored = min(CVAR(g_nadgets_shield_damage_store_limit), self.hg_shield_stored + damage * CVAR(g_nadgets_shield_damage_store));
    damage *= takefactor;

    if(self.hg_shield_stored > o)
        te_eleblast(hitloc, if(teams_matter) self.team else 0);

    if(DEATH_HGTYPE(deathtype) == HG_TRANSLOC)
        reflect = 0;
    else if(DEATH_ISHG(deathtype))
        reflect *= CVAR(g_nadgets_shield_damage_reflect_hg);
    
    if(reflect) {
        vector start = self.origin + offs;
        vector end   = attacker.origin + offs;

        traceline(start, end, FALSE, self);
        end = trace_endpos;

        if(trace_ent.takedamage)
            Damage(trace_ent, self, self, reflect, HG_SHIELD, end, '0 0 0');

        trailparticles(world, particleeffectnum("TE_TEI_G3YELLOW"), start, end);
    }

    self.hg_shieldhealth -= absorb;
    if(self.hg_shieldhealth <= 0)
        self.hg_shield = 0;

    return damage;
}

void HG_Cloak(float hgtype) {
    self.hg_stealth = self.hg_stealth + CVAR(g_nadgets_cloak_duration) * Buffs_NadgetPower(self);
    self.fire_endtime = 0;
    self.hg_stealth_protectionexpiretime = time + CVAR(g_nadgets_cloak_damagereduction_time);
    pointparticles(particleeffectnum("smoke_ring"), self.origin + self.maxs_z * '0 0 0.5', '0 0 0', 10);
    sound(self, CHAN_AUTO, "misc/stealth.wav", VOL_BASE, ATTN_NORM);
}

void HG_Cloak_Trigger(void) {
    if(!Buffs_BuffPower(self, BUFF_ADEPT)) {
        self.hg_stealth = 0;
        return;
    }
    
    if(self.hg_stealth) {
        self.hg_stealth_saved = self.hg_stealth;
        self.hg_stealth = 0;
    } else if(self.hg_stealth_saved) {
        sound(self, CHAN_AUTO, "misc/stealth.wav", VOL_BASE, ATTN_NORM);
        self.hg_stealth = self.hg_stealth_saved;
        self.hg_stealth_saved = 0;
        self.fire_endtime = 0;
    }
}

void HG_Cloak_Frame() {
    if(self.hg_stealth) {
        if(self.flagcarried)
            DropFlag(self.flagcarried, world, world);
        self.hg_wasstealth = TRUE;
        self.hg_stealthtime = time;
        if(self.hg_stealthalpha < 1)
            self.hg_stealthalpha = approach(self.hg_stealthalpha, 1, frametime * CVAR(g_nadgets_cloak_stealthrate));
        self.hg_stealth = approach(self.hg_stealth, 0, frametime);
    } else {
        if(self.hg_wasstealth) {
            self.hg_wasstealth = FALSE;

            HG_DO_IN_ALL_CONTEXTS({
                if(self.hg_ctx_type == HG_CLOAK)
                    HG_SetCooldown(hg_ctx_next, 0, CVAR(g_nadgets_cloak_cooldown_decloak));
            })

            sound(self, CHAN_AUTO, "misc/unstealth.wav", VOL_BASE, ATTN_NORM);
        }
        if(self.hg_stealthalpha)
            self.hg_stealthalpha = approach(self.hg_stealthalpha, 0, frametime * CVAR(g_nadgets_cloak_unstealthrate));
    }
}

.float spawntime;
.float hg_linker_nexteffect;
.float hg_linker_effecttime;

void HG_Linker_Adept_Push(entity p) {
    if(vlen(p.origin - self.origin) <= self.hg_linker_range) {
        float v = max(400, vlen(p.velocity));
        p.velocity = normalize(p.origin - self.origin) * v;
        UpdateCSQCProjectile(p);
    }
}

void HG_Linker_Think() {
    entity p, e;
    float denom, thealth, tarmor, sharefactor;
    
    if(!self.owner.iscreature || self.owner.team != self.team) {
        remove(self);
        return;
    }
    
    float sharingframe = (time > self.hg_linker_nexteffect);

    if(sharingframe)
        self.buffs = 0;
    
    FOR_EACH_PLAYER(p) {
        if(p.team != self.team || (!teams_matter && p != self.owner)) {
            if(p.hg_linker == self)
                p.hg_linker = world;
        } else if(p.hg_linker == self) {
            if(vlen(self.origin - p.origin) > self.hg_linker_range)
                p.hg_linker = world;
        } else if(!p.hg_linker) {
            if(vlen(self.origin - p.origin) <= self.hg_linker_range)
                p.hg_linker = self;
        }
        
        if(sharingframe)
        if(p.hg_linker == self) IF_HG_LINKER_APPLICABLE(p) {
            ++denom;
            thealth += p.health;
            tarmor += p.armorvalue;

            self.buffs |= p.buffs;
                
            if(time > p.hg_linker_effecttime) {
                FOR_EACH_PLAYER(e) if(e != p) if(e.hg_linker == self) if(time > e.hg_linker_effecttime) IF_HG_LINKER_APPLICABLE(e) {
                    te_csqc_lightningarc(p.origin, e.origin, FALSE, e.team);
                }
            }

            p.hg_linker_effecttime = time;
        }
        
        if(self.hg_adept)
            if(p != self.owner && !p.frozen && (!teams_matter || p.team != self.team))
                HG_Linker_Adept_Push(p);
    }
    
    self.buffs &~= CVAR(g_nadgets_linker_sharedbuffs_banmask);

    if(self.hg_adept)
        for(p = findchainflags(flags, FL_PROJECTILE); p; p = p.chain)
            if(p.classname != "bullet" && p.owner != self.owner && (!teams_matter || p.owner.team != self.team))
                HG_Linker_Adept_Push(p);
        
    if(sharingframe) {
        self.hg_linker_nexteffect = time + 1;
        
        if(denom >= 1) {
            if(denom > 1) sound(self, CHAN_AUTO, "kh/capture.wav", 0.4, 1.5);
            sharefactor = if(g_clanarena) 1 else CVAR(g_nadgets_linker_sharefactor);

            FOR_EACH_PLAYER(p) if(p.hg_linker == self) IF_HG_LINKER_APPLICABLE(p) {
                if(denom > 1) {
                    float newhealth = (1 - sharefactor) * p.health     + sharefactor * (thealth / denom);
                    float newarmor  = (1 - sharefactor) * p.armorvalue + sharefactor * (tarmor  / denom);

                    if(self.hg_linker_hps) {
                        float lim = g_balance_health_limit;
                        if(g_clanarena)
                            lim = min(lim, CVAR(g_clanarena_heal_limit));
                        newhealth = newhealth + min(self.hg_linker_hps, max(0, lim - newhealth));
                    }

                    Heal(p, self, self.owner,
                            max(0, newhealth - p.health), max(0, newarmor - p.armorvalue), 0, 0, HG_LINKER | HITTYPE_SECONDARY,
                            HEAL_PAUSEROT_DEFAULT, HEAL_PAUSEROT_DEFAULT, '0 0 0', '0 0 0');
                    
                    p.health = newhealth;
                    p.armorvalue = newarmor;
                } else {
                    Heal(p, self, self.owner, self.hg_linker_hps, 0, 0, 0, HG_LINKER,
                         HEAL_PAUSEROT_DEFAULT, HEAL_PAUSEROT_DEFAULT, '0 0 0', '0 0 0');
                }
            }
        }
    }
    
    self.alpha = bound(0, (self.cnt - time) * 2, 1);
    
    if(self.alpha == 0) {
        remove(self);
        return;
    }
    
    self.alpha = max(0.01, self.alpha * bound(0, (time - self.spawntime) * 2, 1));
    self.glow_size = self.hg_linker_range * self.alpha * 3;
    self.nextthink = time;
}

void HG_Linker_MEODP_Death(entity attacker, entity inflictor) {
    remove(self);
}

void HG_Linker(float hgtype) {
    entity e = spawn();
    e.classname = "hg_linker";
    e.owner = self;
    e.team = self.team;
    e.think = HG_Linker_Think;
    e.nextthink = time;
    e.spawntime = time;
    e.reset = SUB_Remove;
    e.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION | EF_DOUBLESIDED;
    e.gravity = 100;
    e.hg_linker_range = GRENVAR(hgtype, "range");
    e.hg_linker_factor = GRENVAR(hgtype, "damagefactor");
    e.hg_linker_hps = GRENVAR(hgtype, "hps");
    e.hg_linker_buffpower = GRENVAR(hgtype, "sharedbuffpower");
    e.cnt = time + GRENVAR(hgtype, "duration") * Buffs_NadgetPower(self);
    e.alpha = 0.01;
    setmodel(e, "models/ctf/shield.md3");
    e.scale = e.hg_linker_range / e.maxs_x;
    e.glow_color = 0xF5;
    e.hg_adept = Buffs_BuffPower(self, BUFF_ADEPT);
    e.movetype = MOVETYPE_TOSS;

    if(e.team)
        e.skin = TeamColorSkin(e.team);

    if(e.hg_adept)
        e.skin += 5;

    setorigin(e, self.origin + self.view_ofs);
    setsize(e, '-32 -32 0', '32 32 32');
    
    Buffs_MEODP_Point_Attach(e, HG_Linker_MEODP_Death);

    sound(e, CHAN_PROJECTILE, "misc/powerup.wav", 1, 1.5);
}

float HG_GG_Button(float hgtype) {
    entity p;
    float pwned;
    float allow;
    
    float damage = GRENVAR(hgtype, "damage");
    float range  = GRENVAR(hgtype, "range");
    
    FOR_EACH_PLAYER(p)
    if(p != self)
    if(!teams_matter || p.team != self.team || Buffs_BuffPower(self, BUFF_MEDIC) || Buffs_BuffPower(self, BUFF_ADEPT))
    if(p.deadflag == DEAD_NO)
    if(!p.frozen)
    if(!p.jb_isprisoned)
    if(vlen(self.origin - p.origin) < range) {
        vector o = self.origin + self.view_ofs;
        vector e = p.origin + p.view_ofs;
        traceline(o, e, TRUE, self);
        
        allow = (trace_endpos == e);
        if(!allow)
            allow = (vlen(trace_endpos - e) < 5);
        
        if(allow) {
            Damage(p, world, self, damage, HG_GG, e, normalize(e - o) * 1000);
            trailparticles(world, particleeffectnum("TE_TEI_G3RED_HIT"), o, e + randomvec() * 10);
            trailparticles(world, particleeffectnum("TE_TEI_G3BLUE_HIT"), o, e + randomvec() * 10);
            trailparticles(world, particleeffectnum("TE_TEI_G3YELLOW_HIT"), o, e + randomvec() * 10);
            trailparticles(world, particleeffectnum("TE_TEI_G3PINK_HIT"), o, e + randomvec() * 10);
            
            if(Buffs_BuffPower(self, BUFF_ADEPT)) {
                float i; for(i = 0; i < 4; ++i)
                    te_csqc_lightningarc(o, e + randomvec() * 10, TRUE, Team_FromIndex(i));
            }
            
            ++pwned;
        }
    }
    
    if(pwned)
        sound(self, CHAN_AUTO, "misc/gg.wav", 1, ATTN_NORM);
    
    return pwned;
}

string HG_TypeToAttackSound(float hgtype) {
    switch(hgtype) {
        case HG_LASER:
            return RM_SOUND_LASER_PRIMARY;
        default:
            return "weapons/grenade_fire.wav";
    }
}

void HG_GenericProjectile_MEODP_Death(entity attacker, entity inflictor) {
    self.takedamage = DAMAGE_AIM;
    self.health = max(10, self.health);
    self.event_damage = HG_Grenade_Damage;
    self.hg_state = 1;
    Damage(self, inflictor, attacker, self.health, DEATH_MEODP, self.meodp_point.origin, '0 0 0');
}

#define GV(v) (GRENVAR(hgtype, v))
entity HG_GenericProjectile(float hgtype, vector ang, float silent) {
    vector hitmins, hitmaxs;
    
    if(g_nadgets_oldhitboxes) {
        hitmins = '0 0 -3';
        hitmaxs = '0 0 -3';
    } else {
        hitmins = '-8 -4 -3';
        hitmaxs = ' 8  4  3';
    }
    
    makevectors(self.v_angle);
    W_SetupShot_ProjectileSize(self, hitmins, hitmaxs, FALSE, 4, if(silent) "" else HG_TypeToAttackSound(hgtype), -1);
    pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
    
    vector a = vectoangles(w_shotdir);
    a_x = -a_x;
    makevectors(a + ang);
    w_shotdir = v_forward;
    
    entity gren = spawn();
    gren.owner = self;
    gren.classname = "hg_grenade";
    gren.bot_dodge = TRUE;
    gren.bot_dodgerating = GV("damage") + 300; //added +100 by Havocs words about at least +60 to radius;
    PROJECTILE_MAKETRIGGER(gren);
    gren.projectiledeathtype = hgtype;
    gren.hg_type = hgtype;
	gren.spawnorigin = self.origin;
    
    if(hgtype != HG_NAPALM)
        gren.hg_adept = Buffs_BuffPower(self, BUFF_ADEPT);
    
    if(gren.hg_adept && GV("adept_detonable")) {
        gren.hg_detonable = GV("adept_detonable");
        gren.hg_detonatedelay = GV("adept_detonate_delay");
        gren.hg_detonateready = time + GV("adept_detonate_threshold");
    } else {        
        gren.hg_detonable = GV("detonable");
        gren.hg_detonatedelay = GV("detonate_delay");
        gren.hg_detonateready = time + GV("detonate_threshold");
    }
    
    if(gren.hg_adept && GV("adept_movetype"))
        gren.movetype = GV("adept_movetype");
    else
        gren.movetype = GV("movetype");
    
    gren.gravity = GV("gravity");
    setsize(gren, hitmins, hitmaxs);
    setorigin(gren, w_shotorg);

    float lt;
    if(hgtype == HG_TRANSLOC && self.BUTTON_CROUCH) {
        if(gren.hg_adept) {
            lt = GV("adept_crouch_lifetime");
            if(!lt)
                lt = GV("crouch_lifetime");
        } else
            lt = GV("crouch_lifetime");
    } else if(gren.hg_adept) {
        lt = GV("adept_lifetime");
        if(!lt)
            lt = GV("lifetime");
        else if(hgtype == HG_REMOTE)
            lt = lt * Buffs_NadgetPower(self);
    } else
        lt = GV("lifetime");

    if(gren.hg_adept)
        gren.cnt = GV("adept_bouncelimit");
    else
        gren.cnt = GV("bouncelimit");

    gren.hg_deathtime = if(self.hg_power == 1 && GV("launch_fullforce_explodes_in_yo_face"))
                            time + 0.01
                        else
                            time + lt * (if(hgtype == HG_TRANSLOC) Buffs_NadgetPower(self) else 1);
                          
    gren.think = HG_Grenade_Think;
    gren.nextthink = time;
    gren.use = HG_Grenade_Explode;
    gren.touch = HG_Grenade_Touch;
    gren.reset = HG_Grenade_Remove;
    gren.team = self.team;
    gren.hg_isbonus = self.hg_bonus;
    
    if(gren.hg_type == HG_TRANSLOC)
        gren.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
    
    if(gren.hg_adept)
        gren.health = GV("adept_health");
    
    if(GV("takedamage") || gren.health) {
        gren.takedamage = DAMAGE_AIM;
        gren.event_damage = HG_Grenade_Damage;
    } else {
        gren.takedamage = DAMAGE_NO;
        gren.event_damage = SUB_Null;
    }
    
    if(!gren.health)
        gren.health = GV("health");
    gren.damageforcescale = GV("damageforcescale");
    
    float spd, mspd, upspd;

    if(hgtype == HG_TRANSLOC && self.BUTTON_CROUCH) {
        spd   = GV("crouch_speed");
        mspd  = GV("crouch_speed_min");
        upspd = GV("crouch_speed_up");
    } else {
        spd   = GV("speed");
        mspd  = GV("speed_min");
        upspd = GV("speed_up");
    }
    
    if(GV("launchspeed") && !g_nadgets_detonatelaunches) {
        gren.velocity = w_shotdir * (mspd + (spd-mspd) * self.hg_power) + v_up * upspd * self.hg_power;
    } else
        gren.velocity = w_shotdir * spd + v_up * upspd;
        
    W_SetupProjectileVelocity(gren);
    
    gren.max_health = gren.health;
    gren.angles = vectoangles(gren.velocity);
    gren.flags = FL_PROJECTILE;
    gren.hg_nadesused = self.hg_nadesused;
    
    Buffs_MEODP_Point_Attach(gren, HG_GenericProjectile_MEODP_Death);
    
    CSQCProjectile(gren, TRUE, HG_TypeToCSQCProjType(hgtype), TRUE);
    
    if(hgtype == HG_NAPALM && self.hg_power == 1 && GV("launch_fullforce_explodes_in_yo_face"))
        Damage(self, self, self, GV("kamikaze_damage") * Buffs_NadgetPower(self), HG_NAPALM, self.origin, '0 0 0');
    
    if(hgtype == HG_TRANSLOC)
        self.hg_transloc_last = gren;
    
    self.hg_power = 0;
    return gren;
}

void HG_Bait_Body_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) {
    PlayerDamage(inflictor, attacker, damage, deathtype, hitloc, force * Freeze_CVar("frozen_force"));
}

void HG_Bait_Body_Remove(entity body) {
    if(body.freeze_waypoint)
        WaypointSprite_Disown(body.freeze_waypoint, 0.5);

    if(body.hg_waypoint)
        WaypointSprite_Disown(body.hg_waypoint, 0.5);

    if(body.iceblock)
        remove(body.iceblock);

    if(body.exteriorweaponentity)
        remove(body.exteriorweaponentity);

    if(body.entcs)
        remove(body.entcs);

    remove(body);
}

float HG_Bait_Iceblock_Customize(void) {
    if(other.iscreature && other.team == self.owner.realowner.team)
        self.colormod = '0 2 0';
    else
        self.colormod = '1 1 1';

    return TRUE;
}

void HG_Bait_Body_Think(void) {
    Freeze_Hook_PlayerPreThink();
    SV_PlayerPhysics();

    if(time > self.hg_deathtime || self.realowner.team != self.hg_state) {
        HG_Bait_Body_Remove(self);
        return;
    }

    // freeze sound doesn't work properly if this is not delayed
    if(!self.iceblock) {
        Freeze_SpawnIceBlock(self);
        
        if(Freeze_CVar("iceblocks_teamcolored"))
            self.iceblock.skin = TeamColorSkin(self.team);

        if(teams_matter)
            self.iceblock.customizeentityforclient = HG_Bait_Iceblock_Customize;
    }

    if(time > self.hg_nextsnd)
    if(self.revprogress > 0.85) {
        self.hg_nextsnd = time + 0.1;
        sound(self, CHAN_PROJECTILE, "weapons/rm_nadebeep.wav", VOL_BASE * 0.5, ATTN_NORM * 2);
    }

    HG_Grenade_Waypoint();
    self.nextthink = time;
}

void HG_Bait_Body_Boom(entity body) {
    entity oldself = self;
    self = body;
    body.owner = body.realowner;
    HG_Grenade_RadiusDamage();
    HG_Bait_Body_Remove(body);
    self = oldself;
}

entity HG_Bait_Create(entity ref) {
    entity oldself = self;
    self = ref;

    entity body = CopyBody(FALSE);
    body.classname = "bait_body";
    body.team = ref.team;
    body.health = Freeze_CVar("frozen_health");
    body.armorvalue = Freeze_CVar("frozen_armor");
    body.think = HG_Bait_Body_Think;
    body.event_damage = HG_Bait_Body_Damage;
    body.reset = HG_Bait_Body_Remove;
    body.nextthink = time;
    body.frozen = TRUE;
    body.realowner = oldself;
    body.hg_type = body.projectiledeathtype = HG_BAIT;
    body.hg_deathtime = time + GRENVAR(HG_BAIT, "lifetime");
    body.aiment = body.bait_ref = ref;
    body.hg_state = oldself.team;
    body.colormod = ref.colormod;
    setorigin(body, oldself.origin);

    entity w = spawn();
    w.classname = "exteriorweaponentity";
    w.solid = SOLID_NOT;
    w.owner = body;
    setorigin(w, '0 0 0');
    w.angles = '0 0 0';
    w.effects = body.effects | EF_LOWPRECISION;
    w.effects = w.effects & EFMASK_CHEAP;
    w.colormap = ref.exteriorweaponentity.colormap;
    setmodel(w, ref.exteriorweaponentity.model);
    
    float tag_found;
    if((tag_found = gettagindex(w.owner, "tag_weapon"))) {
        w.tag_index = tag_found;
        w.tag_entity = w.owner;
    } else
        setattachment(w, w.owner, "bip01 r hand");

    body.exteriorweaponentity = w;
    
    self = body;
    attach_entcs();
    self = oldself;

    return body;
}

entity HG_Bait_PickRef(void) {
    entity plr;

    RandomSelection_Init();
    FOR_EACH_PLAYER(plr) if(plr.team != self.team)
        RandomSelection_Add(plr, 0, string_null, 1, 1);

    return RandomSelection_chosen_ent;
}

float HG_Bait(void) {
    entity ref = HG_Bait_PickRef();

    if(!ref)
        return FALSE;

    HG_Bait_Create(ref);
    return TRUE;
}

float HG_Sentry_TargetIsValid(entity e) {
    if(!e || e.classname != "player" || e.frozen || e.jb_isprisoned || e.deadflag != DEAD_NO)
        return FALSE;

    if(!IsDifferentTeam(e, self.realowner) && !Buffs_BuffPower(self.realowner, BUFF_MEDIC))
        return FALSE;

    vector o = self.origin + self.view_ofs;
    vector t = e.origin + e.view_ofs;

    if(vlen(o - t) > CVAR(g_nadgets_sentry_beam_range))
        return FALSE;

    traceline(o, t, MOVE_NORMAL, self);

    if(trace_ent != e)
        return FALSE;

    return TRUE;
}

entity HG_Sentry_FindTarget(void) {
    entity targ, p;
    float range = CVAR(g_nadgets_sentry_beam_range), mindist, dist;
    float medic = Buffs_BuffPower(self.realowner, BUFF_MEDIC), medicflag, diffteam;
    vector t, o = self.origin + self.view_ofs;

    mindist = range;

    FOR_EACH_PLAYER(p) if(!p.frozen && !p.jb_isprisoned && p.deadflag == DEAD_NO) {
        diffteam = (p != self.realowner && IsDifferentTeam(self, p));

        if(diffteam) {
            if(medicflag)
                continue;
        } else if(!medic)
            continue;

        t = p.origin + p.view_ofs;
        dist = vlen(o - t);

        if(diffteam || (!diffteam && medicflag)) {
            if(dist > mindist)
                continue;
        } else if(dist > range)
            continue;

        traceline(o, t, MOVE_NORMAL, self);

        if(trace_ent != p)
            continue;

        mindist = dist;
        targ = p;

        if(!diffteam)
            medicflag = TRUE;
    }

    return targ;
}

void HG_Sentry_Beam_Think(void) {
    entity targ = self.owner.enemy;
    vector end = targ.origin + targ.view_ofs * (0.5 + 0.5 * sin(time * 5 + num_for_edict(self)));
    vector start = self.owner.origin + self.owner.view_ofs;

    traceline(start, end, MOVE_NORMAL, self);

    targ = trace_ent;
    end = trace_endpos;

    if(!self.origin)
        self.origin = end;
    else
        self.origin += (end - self.origin) * frametime * 10;

    end = self.origin;

    if(targ.takedamage == DAMAGE_AIM && time > self.cnt) {
        Damage(targ, self, self.owner.realowner, CVAR(g_nadgets_sentry_beam_dps) * 0.1, HG_SENTRY, end, CVAR(g_nadgets_sentry_beam_force) * normalize(end - start));
        self.cnt = time + 0.1; // FIXME: this is inaccurate
    }

    end -= normalize(end - start) * 5;

    if(start != self.zapper_beam_start) {
        self.zapper_beam_start = start;
        self.SendFlags |= 2;
    }

    if(end != self.zapper_beam_end) {
        self.zapper_beam_end = end;
        self.SendFlags |= 4;
    }

    self.nextthink = time;
}

entity HG_Sentry_Beam_Spawn(void) {
    entity e = spawn();
    e.classname = "hg_sentry_beam";
    e.owner = self;
    e.team = self.team;
    e.zapper_beam_start = self.origin + self.view_ofs;
    e.zapper_beam_end = e.zapper_beam_start;
    e.think = HG_Sentry_Beam_Think;
    e.nextthink = time;

    Net_LinkEntity(e, FALSE, 0, W_Zapper_Beam_Send);

    return e;
}

void HG_Sentry_Remove(void) {
    self.realowner.hg_detonables -= 1;

    if(self.hg_waypoint)
        WaypointSprite_Disown(self.hg_waypoint, 0.5);

    if(self.zapper_beam)
        remove(self.zapper_beam);

    if(self.aiment) {
        stopsound(self.aiment, CHAN_PROJECTILE);
        remove(self.aiment);
    }

    remove(self);
}

void HG_Sentry_Explode(void) {
    te_blast(self.origin + self.view_ofs);
    HG_Sentry_Remove();
}

void HG_Sentry_Think(void) {
    if(self.team != self.realowner.team || !self.realowner.iscreature) {
        HG_Sentry_Explode();
        return;
    }

    if(self.hg_sentry_energy < CVAR(g_nadgets_sentry_beam_energyrequired)) {
        if(self.zapper_beam)
            remove(self.zapper_beam);
        self.zapper_beam = world;
        self.enemy = world;
    } else if(!self.zapper_beam) {
        if(!HG_Sentry_TargetIsValid(self.enemy))
            self.enemy = world;

        if(!self.enemy)
            self.enemy = HG_Sentry_FindTarget();

        if(self.enemy)
            self.zapper_beam = HG_Sentry_Beam_Spawn();
    } else {
        if(self.enemy && !HG_Sentry_TargetIsValid(self.enemy))
            self.enemy = HG_Sentry_FindTarget();

        if(!self.enemy) {
            remove(self.zapper_beam);
            self.zapper_beam = world;
            self.enemy = world;
        }
    }

    self.hg_sentry_energy = approach(self.hg_sentry_energy, 1, frametime * CVAR(g_nadgets_sentry_energy_regen));
    HG_Grenade_Waypoint();

    setorigin(self.aiment, self.origin + self.view_ofs);
    self.aiment.scale = bound(0.01, self.hg_sentry_energy, 1);
    self.aiment.light_lev = 100 + self.aiment.scale * 200;

    entity o = self;
    self = self.aiment;
    HG_HealEmitter();
    self = o;

    self.nextthink = time;
}

void HG_Sentry_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) {
    if(IsDifferentTeam(attacker, self.realowner)) {
        if(DEATH_ISHG(deathtype))
            damage *= CVAR(g_nadgets_sentry_damagefactor_nadgets);
        else
            damage *= CVAR(g_nadgets_sentry_damagefactor);

        self.health = bound(0, self.health - damage, self.health);
    } else {
        if(DEATH_ISHG(deathtype))
            damage *= CVAR(g_nadgets_sentry_repairfactor_nadgets);
        else
            damage *= CVAR(g_nadgets_sentry_repairfactor);

        Heal(self, inflictor, attacker, damage, 0, CVAR(g_nadgets_sentry_health), 0, deathtype, 0, 0, hitloc, '0 0 0');
    }

    if(self.health <= 0)
        HG_Sentry_Explode();
    else if(self.health < CVAR(g_nadgets_sentry_health))
        self.effects |= EF_FLAME;
    else
        self.effects &~= EF_FLAME;
}

void HG_Sentry_MEODP_Death(entity attacker, entity inflictor) {
    HG_Sentry_Explode();
}

#define HG_SENTRY_MINS '-24.4 -24.4   0.0'
#define HG_SENTRT_MAXS ' 24.4  24.4 110.0'

float HG_Sentry(void) {
    vector o = self.origin;

    entity e = spawn();
    setmodel(e, "models/turrets/tesla.md3");
    setsize(e, HG_SENTRY_MINS, HG_SENTRT_MAXS);
    setorigin(e, o);

    if(!move_out_of_solid(e)) {
        remove(e);
        return FALSE;
    }

    e.classname = "hg_sentry";
    e.team = self.team;
    e.realowner = self; // can't use owner here because we want to be blocked by it
    e.solid = SOLID_BBOX;
    e.movetype = MOVETYPE_TOSS;
    e.angles = '0 360 0' * random();
    e.reset = HG_Sentry_Remove;
    e.think = HG_Sentry_Think;
    e.nextthink = time;
    e.hg_type = HG_SENTRY;
    e.view_ofs = '0 0 100';
    e.takedamage = DAMAGE_AIM;
    e.skin = TeamColorSkin(self.team);
    e.health = CVAR(g_nadgets_sentry_health);
    e.event_damage = HG_Sentry_Damage;

    self.hg_detonables += 1;

    Buffs_MEODP_Point_Attach(e, HG_Sentry_MEODP_Death);

    entity c = spawn();
    setmodel(c, "models/ebomb.mdl");
    c.skin = TeamColorSkin(self.team);
    c.pflags = PFLAGS_FULLDYNAMIC;
    c.color = '0.3 0.3 0.3' + 0.7 * TeamColor(if(self.team > 0) self.team else COLOR_TEAM2);
    c.owner = self;
    sound(c, CHAN_PROJECTILE, "weapons/electro_fly.wav", 0.5, 2);

    e.aiment = c;

    // TODO: a better sound?
    spamsound(self, CHAN_PROJECTILE, "weapons/grenade_stick.wav", 1, ATTN_NORM);
    return TRUE;
}

void HG_Sentry_Trigger(void) {
    entity e, aimtarg;
    vector o = self.origin + self.view_ofs, aimloc;

    traceline_antilag(self, o, self.cursor_trace_endpos, MOVE_NORMAL, self);
    aimloc = trace_endpos;
    aimtarg = trace_ent;

    float c_dmg = CVAR(g_nadgets_sentry_shock_damage);
    float c_frc = CVAR(g_nadgets_sentry_shock_force);
    float c_cost;

    if(Buffs_BuffPower(self, BUFF_ADEPT))
        c_cost = CVAR(g_nadgets_sentry_adept_shock_energy_cost);
    else
        c_cost = CVAR(g_nadgets_sentry_shock_energy_cost);

    float found, triggered;

    for(e = world; (e = find(e, classname, "hg_sentry"));) if(e.realowner == self) {
        ++found;

        if(e.hg_sentry_energy < c_cost)
            continue;

        o = e.origin + e.view_ofs;
        traceline_antilag(self, o, aimloc, MOVE_NORMAL, self);

        if(trace_fraction == 1 || (aimtarg && trace_ent == aimtarg)) {
            vector dir = normalize(trace_endpos - o);

            traceline_antilag(self, o, o + dir * MAX_SHOT_DISTANCE, MOVE_NORMAL, self);            

            entity targ = trace_ent;
            vector endpos = trace_endpos;
            float noimpact = (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT);
            vector force = c_frc * dir;

            Damage(targ, self, self, c_dmg, HG_SENTRY | HITTYPE_SECONDARY, endpos, force);
            
            sound(e, CHAN_WEAPON, strcat("misc/arc", ftos(1 + (random() > 0.5)), ".wav"), VOL_BASE, ATTN_NORM);
            W_Zapper_Attack2_Effect(self.team, o, endpos);

            if(targ.solid == SOLID_BSP && !noimpact)
                Damage_DamageInfo(endpos, c_dmg, 0, 0, force, WEP_ZAPPER | HITTYPE_SECONDARY, self);

            e.hg_sentry_energy = bound(0, e.hg_sentry_energy - c_cost, 1);
            ++triggered;
        }
    }

    if(triggered)
        sound(self, CHAN_WEAPON2, "weapons/rocket_mode.wav", VOL_BASE, ATTN_NORM);
    else if(found)
        sound(self, CHAN_WEAPON2, "weapons/unavailable.wav", VOL_BASE, ATTN_NORM);
}

void HG_SetCooldown(.float cdfield, float gcd, float cd) {
    float cdmul = Buffs_NadgetCooldown(self);
    gcd *= cdmul;
    cd *= cdmul;

    self.hg_next1 = max(self.hg_next1, time + gcd);
    self.hg_next2 = max(self.hg_next2, time + gcd);
    self.hg_bonus_next = max(self.hg_bonus_next, time + gcd);
    self.cdfield = max(self.cdfield, time + cd);
}

void HG_Attack()
{
    if(self.deadflag != DEAD_NO)
        return;

    float hgtype;
    float used = 1;
    float avail;

    float n_bonus;
    var .float cdfield;

    if(hg_context_isaltintended)
        n_bonus = 0;
    else
        n_bonus = self.hg_bonus;

    HG_FixNadeType(self);

    if(n_bonus) {
        hgtype = self.hg_bonustype;
        avail = self.hg_bonus;
        cdfield = hg_bonus_next;
    } else {
        hgtype = self.hg_ctx_type;
        avail = self.hg_ctx_ammo;
        cdfield = hg_ctx_next;
    }

    if(time < self.cdfield)
        return;

    if(!n_bonus && !self.hg_ctx_ammo)
        return;
    
    if(hgtype == HG_SHIELD) {
        HG_Shield(hgtype);
    } else if(hgtype == HG_LINKER) {
        HG_Linker(hgtype);
    } else if(hgtype == HG_CLOAK) {
        if(self.hg_stealth && !CVAR(g_nadgets_cloak_usewhileactive))
            return;
        HG_Cloak(hgtype);
    } else if(hgtype == HG_GG) {
        if(!HG_GG_Button(hgtype)) {
            bigprint_spec(self, "Nobody to win against!", "", 1);
            self.cdfield = time + 1;
            return;
        }
    } else if(hgtype == HG_BAIT) {
        if(!HG_Bait()) {
            bigprint_spec(self, "No enemies!", "", 1);
            self.cdfield = time + 1;
            return;
        }
    } else if(hgtype == HG_SENTRY) {
        if(!HG_Sentry()) {
            bigprint_spec(self, "Can't put a sentry here!", "", 1);
            self.cdfield = time + 1;
            return;
        }
    } else {
        if(Buffs_BuffPower(self, BUFF_ADEPT) && (GV("adept_split") > 0 || (hgtype == HG_LASER && self.hg_detonatepressed))) {
            float split = GV("adept_split");
            float spread = GV("adept_split_spread");
            vector dir;
            float i;
            
            if(!split && hgtype == HG_LASER) {
                split = used = avail;
            }
            
            if(split == 1)
                HG_GenericProjectile(hgtype, '0 0 0', FALSE);
            else for(i = 0; i < split; ++i) {
                dir_y = spread * (-0.5 + (i / (split-1)));
                entity e = HG_GenericProjectile(hgtype, dir, i);
                e.solid = SOLID_NOT;
            }
        } else {
            HG_GenericProjectile(hgtype, '0 0 0', FALSE);
        }
    }

    HG_SetCooldown(cdfield, GV("global_cooldown"), GV("cooldown"));

    if(!n_bonus) {
        if(CVAR(g_nadgets_regen_compensate)) {
            float oregen = HG_RegenTime(self);
            self.hg_ctx_ammo -= used;
            self.hg_ctx_maxregentime = HG_RegenTime(self);
            self.hg_ctx_regentime = self.hg_ctx_regentime - oregen + self.hg_ctx_maxregentime;
        } else {
            self.hg_ctx_ammo -= used;
            HG_SetRegenTime(self, HG_RegenTime(self));
        }
    }
    
    if(self.hg_bonus)
        self.hg_bonus -= used;
    
    self.hg_nadesused += used;
}
#undef GV

void HG_UpdateDetonables() {
    entity nade;
    self.hg_detonables = 0;
    
    for(;(nade = find(nade, classname, "hg_grenade"));)
        if(nade.owner == self && !nade.hg_detonatetime && nade.hg_detonable && nade.hg_detonateready <= time)
            self.hg_detonables += 1;

    for(;(nade = find(nade, classname, "hg_sentry"));)
        if(nade.realowner == self)
            self.hg_detonables += 1;
}

float HG_RegenLimit(entity plr) {
    float mx = 0;
    
    mx = GRENVAR(plr.hg_ctx_type, "regen_limit");

    if(mx < 1)
        return 0;

    if(Buffs_BuffPower(plr, BUFF_ADEPT))
        mx += GRENVAR(plr.hg_ctx_type, "adept_regen_limit_extend");

    float supply = Buffs_BuffPower(plr, BUFF_SUPPLY);
    if(supply)
        mx += CVAR(g_buffs_supply_hg_extra_regen_limit) * rint(supply);
    
    return mx;
}

void HG_Frame()
{
    if(!g_nadgets)
        return;
    
    if(time < game_starttime)
        return;
    
    if(self.hg_linker && wasfreed(self.hg_linker))
        self.hg_linker = world;
    
    HG_FixNadeType(self);
    HG_Shield_Frame();
    HG_Cloak_Frame();
    
    if(roundstate == ROUNDSTATE_OVER) {
        self.hg_power = 0;
        return;
    }
    
	float mayfire = (!g_grappling_hook || (!self.hook && !CustomHGHookButton(self))) || self.hg_power;
	
    if(time < self.hg_plasmalock)
        mayfire = FALSE;
    
	float held, isalt;
	held = self.(if(g_nadgets_detonatelaunches) hg_detonatepressed else BUTTON_NADGET);

    float n_type;

    if(!held) {
        held = (self.BUTTON_NADGET2 || (!g_grappling_hook && self.BUTTON_USE));
        if(held) {
            isalt = TRUE;
        }
    }

    if(self.hg_power)
        isalt = self.hg_altstate;

    if((self.hg_power && !self.hg_state) ||
       (g_freeze && self.frozen) ||
       (g_jailbreak && self.jb_isprisoned))
            held = 0;

    HG_SetContext(isalt);

    if(!isalt && self.hg_bonus) {
        hg_ctx_ammo = hg_bonus;
        hg_ctx_next = hg_bonus_next;
        n_type = self.hg_bonustype;
    } else {
        n_type = self.hg_ctx_type;
    }

    if(held && held != self.hg_state && !self.hg_ctx_ammo && self.deadflag == DEAD_NO)
        bigprint_spec(self, strcat("Out of ", HG_TypeToExpandedName(n_type), "s!"), "", 1);
    
    if(held && time >= self.hg_ctx_next && self.hg_ctx_ammo && mayfire) {
        float ls;
        
        if(!g_nadgets_detonatelaunches)
            ls = GRENVAR(n_type, "launchspeed");
        
        self.hg_launchspeed = ls;
        
        if(ls)
            self.hg_power = bound(0, self.hg_power + frametime * ls, 1);
        else {
            self.hg_power = 0;
            HG_Attack();
        }
	} else {
		if(self.hg_state && mayfire && self.hg_launchspeed)
			HG_Attack();
		self.hg_power = 0;
	}
	
	if(self.hg_power == 1 && mayfire && GRENVAR(n_type, "launch_fullforce_launches_immediately"))
		HG_Attack();
	
	self.hg_state = held;
    self.hg_altstate = isalt;
    
    if(CVAR(g_nadgets_regen)) HG_DO_IN_ALL_CONTEXTS({
        float mx = HG_RegenLimit(self);
        float dpause = CVAR(g_nadgets_regen_damagepause) * Buffs_NadgetRegenDmgPause(self);
        
        self.hg_ctx_regenrate = GRENVAR(self.hg_ctx_type, "regen_scale");
        dpause = min(dpause, dpause / self.hg_ctx_regenrate);
        self.hg_ctx_regenpaused = (((self.hg_stealth || self.hg_stealth_saved) && self.hg_ctx_type == HG_CLOAK) || (time - self.lastdamage <= dpause));
        
        if(self.hg_ctx_ammo < mx || !mx) {
            if(!self.hg_ctx_regenpaused) {
                if(g_freeze && self.frozen)
                    self.hg_ctx_regenrate *= CVAR(g_nadgets_regen_frozenfactor);
                self.hg_ctx_regenrate *= Buffs_NadgetRegen(self);
                
                self.hg_ctx_regentime -= frametime * self.hg_ctx_regenrate;
                if(self.hg_ctx_regentime <= 0) {
                    self.hg_ctx_ammo += 1;
                    HG_SetRegenTime(self, HG_RegenTime(self));
                }
            }
        } else
            self.hg_ctx_regenrate = 0;
    })
    
    if(self.hg_detonatepressed)
        self.hg_detonatepressed = FALSE;
}

void HG_Trigger(void) {
    if(self.frozen || self.jb_isprisoned)
        return;

    if(self.hg_stealth || self.hg_stealth_saved)
        HG_Cloak_Trigger();
    else if(self.hg_shield)
        HG_Shield_Trigger();
    else {
        HG_Sentry_Trigger();

        self.hg_detonatepressed = TRUE;
        HG_DetonateAll(self);
        
        if(Buffs_BuffPower(self, BUFF_ADEPT)) {
            float i;
            HG_LOOP_FOR_ALL_CONTEXTS(i, {
                if(self.hg_ctx_type == HG_LASER) {
                    HG_Attack();
                    break;
                }
            })
        }
    }
}

void HG_ResetState(entity p) {
    p.hg_power = 0;
    p.hg_ammo1 = p.hg_ammo2 = if(p.hg_clearammo) 0 else CVAR(g_nadgets_ammo);
    p.hg_bonus = 0;
    p.hg_bonustype = HG_NORMAL;
    p.hg_clearammo = 0;
    p.hg_shield = 0;

    HG_DO_IN_ALL_CONTEXTS({
        HG_SetGrenadeType(p, HG_PlayerGrenadeType(p));
        HG_SetRegenTime(p, HG_RegenTime(p));
    })
}

void HG_PlayerSpawn()
{
    if(self.classname != "player")
        return;
    
    if(CVAR(g_nadgets_resetonrespawn))
        HG_ResetState(self);
        
    self.hg_shield = 0;
    HG_UpdateDetonables();
}

void HG_PlayerSpawnEx(entity p) {
    entity o;
    o = self;
    self = p;
    HG_PlayerSpawn();
    self = o;
}

void HG_PlayerJoin() {
    if(self.classname != "player")
        return;
        
    if((g_freeze && self.frozen) || (g_jailbreak && self.jb_isprisoned))
        self.hg_clearammo = TRUE;
    
    HG_ResetState(self);
    HG_UpdateDetonables();
}

float HG_ShowMenu(float always) {
    if(self.hg_type1_picked && self.BUTTON_CHAT)
        return FALSE;
    
    if(g_nadgets && CVAR_STR(g_nadgets_type_selectable) != "" && (always || !self.hg_type1_picked || (g_nadgets_double && !self.hg_type2_picked))) {
        if(g_nadgets_double)
            stuffcmd(self, strcat("set _nade_options \"", CVAR_STR(g_nadgets_type_selectable), "\"; menu_cmd update_rmvars; menu_shownadeselect2\n"));
        else
            stuffcmd(self, strcat("set _nade_options \"", CVAR_STR(g_nadgets_type_selectable), "\"; menu_cmd update_rmvars; menu_shownadeselect\n"));
        return TRUE;
    }
    
    return FALSE;
}
