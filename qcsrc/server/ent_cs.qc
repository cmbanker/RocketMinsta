/**
 * The point of these entities is to avoid the problems
 * with clientprediction.
 * If you add SendEntity to players, the engine will not
 * do any prediction anymore, and you'd have to write the whole
 * prediction code in CSQC, you want that? :P
 * Data can depend on gamemode. For now, it serves as GPS entities
 * in onslaught... YAY ;)
 */

// Beware: do not redefine those in other files
// and NO, you cannot use ".version", which already exists (at least
// it did when I added this) But you have to use .Version
// Capital V

.entity entcs;

void entcs_init(void) {
    print("Initializing ClientSide information entities\n");
}

.float entcs_culled[256];


float entcs_cull(entity what, entity forwhom) {
    if(what.owner == forwhom) {
        return TRUE;
    }

    float isspect;

    if(!forwhom.iscreature) {
        if(what.owner == forwhom.enemy)
        if(forwhom.classname == "spectator")
            return TRUE;

        if(!forwhom.jb_specteam)
            isspect = TRUE;
    }

    if(what.owner.deadflag != DEAD_NO)
        return TRUE;

    if(what.owner.classname != "player") if(what.owner.bait_ref.classname != "player")
        return TRUE;

    if(vlen(what.owner.origin - forwhom.origin) > SHOWNAMES_MAXDISTANCE)
        return TRUE;

    if(isspect)
        return FALSE;

    if(IsDifferentTeam(what.owner, forwhom)) {
        if(what.owner.hg_stealth)
            return TRUE;

        vector v1, v2;
        v1 = what.owner.origin + what.owner.view_ofs;
        v2 = forwhom.origin + forwhom.view_ofs;

        if(cvar("sv_cullentities_pvs")) {
            if(!checkpvs(v1, forwhom))
                return TRUE;
        }

        if(cvar("sv_cullentities_trace")) {
            save_nasty_globals();

            makevectors(forwhom.v_angle);
            if(normalize(v1 - v2) * v_forward < 0) {
                restore_nasty_globals();
                return TRUE;
            }

            traceline(forwhom.origin + forwhom.view_ofs, what.owner.origin + what.owner.view_ofs, MOVE_NOMONSTERS, forwhom);
            if(trace_fraction < 1) {
                restore_nasty_globals();
                return TRUE;
            }

            restore_nasty_globals();
        }
    }

    return FALSE;
}

float entcs_customize(void) {
    return !(self.(entcs_culled[num_for_edict(other)]));
}

//
//  sendflags:
//
//  id           1
//  origin_xy    2
//  origin_z     4
//  angles_y     8
//  health       16
//  armor        32
//  sameteam     64
//

float entcs_send(entity to, float sf) {
    entity o;
    o = self.owner;

    sf = sf & 255;

    entity check = to;
    if(check.classname == "spectator")
        check = to.enemy;

    if(!IsDifferentTeam(check, o) || (check.hg_stealth && !o.hg_stealth) || sv_cheats) {
        sf |= 64;
    } else {
        sf &~= (8 | 16 | 32 | 64);
    }
    
    if(entcs_cull(self, check)) {
        // this is for team mates. Enemy cull is done in entcs_customize.
        sf &~= (4 | 16 | 32);
    }

    WriteByte(MSG_ENTITY, ENT_CLIENT_ENTCS);
    WriteByte(MSG_ENTITY, sf);

    if(sf & 1) {
        WriteByte(MSG_ENTITY, num_for_edict(o.bait_ref? o.bait_ref : o));
        WriteByte(MSG_ENTITY, self.owner.bait_ref && self.owner.frozen);
    }

    if(sf & 2) {
        WriteShort(MSG_ENTITY, o.origin_x);
        WriteShort(MSG_ENTITY, o.origin_y);
    }

    if(sf & 4) {
        WriteShort(MSG_ENTITY, o.origin_z);
    }

    if(sf & 8) {
        WriteByte(MSG_ENTITY, o.angles_y * 256.0 / 360);
    }

    if(sf & 16) {
        WriteShort(MSG_ENTITY, self.health);
    }

    if(sf & 32) {
        WriteShort(MSG_ENTITY, self.armorvalue);
    }
    
    return TRUE;
}

void entcs_think(void) {
    self.nextthink = time + cvar("sv_shownames_update");

    vector org;
    entity o;
    o = self.owner;

    if(o.origin_x != self.origin_x || o.origin_z != self.origin_z) {
        org = o.origin;
        org_z = self.origin_z;
        setorigin(self, org);
        self.SendFlags |= 2;
    }

    if(o.origin_z != self.origin_z) {
        org = self.origin;
        org_z = o.origin_z;
        setorigin(self, org);
        self.SendFlags |= 4;
    }

    if(o.angles_y != self.angles_y) {
        self.angles = o.angles;
        self.SendFlags |= 8;
    }

    if(!sv_shownames)
        return;

    float h = max(0, floor(self.owner.health));
    float a = max(0, floor(self.owner.armorvalue));

    if(self.health != h) {
        self.health = h;
        self.SendFlags |= 16;
    }

    if(self.armorvalue != a) {
        self.armorvalue = a;
        self.SendFlags |= 32;
    }

    float i; for(i = 0; i < maxclients; ++i) {
        entity c = edict_num(i);

        if(clienttype(c) == CLIENTTYPE_REAL)
            self.(entcs_culled[i]) = entcs_cull(self, c);
    }
}

entity attach_entcs(void) {
    entity ent;
    
    ent = spawn();
    ent.classname = "entcs_sender_v2";
    ent.owner = self;
    ent.think = entcs_think;
    ent.nextthink = time;

    Net_LinkEntity(ent, FALSE, 0, entcs_send);
    ent.customizeentityforclient = entcs_customize;

    self.entcs = ent;

    return ent;
}

void detach_entcs(void) {
    remove(self.entcs);
    self.entcs = world;
}
