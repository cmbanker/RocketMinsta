
.float buffs;
.float buffstat;
.float buff_active;
.float light_lev;

.vector lightcolor;

string buff_modelnames[BUFF_COUNT];
.entity buffmdl[BUFF_COUNT];

.entity buff_ring;

void Buffs_LoadModels(void) {
    float i, b;

    for(i = 0, b = 1; i < BUFF_COUNT; ++i, b *= 2) if(b & g_buffs_enabled) {
        string s = strcat("models/buffs/buff_", Buffs_TypeToName(b), ".md3");
        if(!fexists(s)) {
            s = "models/buffs/buff.md3";
            print("No model found for the ", Buffs_TypeToName(b), " Buff! Falling back to default.\n");
        }
            
        buff_modelnames[i] = strzone(s);
        precache_model(buff_modelnames[i]);
    }
}

void Buffs_Model_Draw(void) {
    InterpolateOrigin_Do();

    if(!(self.effects & EF_NODRAW))
    if(self.alpha > 0)
        R_AddEntity(self);

    if(self.light_lev)
        R_AddDynamicLight(self.origin, self.light_lev, self.lightcolor);

    if(self.effects & EF_STARDUST)
        pointparticles(particleeffectnum("EF_STARDUST"), self.origin, '0 0 0', frametime);
}

void Buffs_Model_Multi_Think(void) {
    if(!self.owner || wasfreed(self.owner) || self.owner.buffs != self.buffstat) {
        remove(self);
        return;
    }

    self.effects = self.owner.effects;
    self.effects &~= EF_NODRAW;
    self.light_lev = self.owner.light_lev * 0.7;
    self.alpha = self.owner.alpha;
    
    if(self.buffs == BUFF_MEODP) {
        self.lightcolor = '1 0 0';
        self.effects &~= EF_ADDITIVE;
    }
    
    vector ang;
    ang_y = mod(time * 120 + self.cnt, 360);
    makevectors(ang);
    setorigin(self, self.owner.origin + v_forward * 10 + v_up * 3 * sin(time * 0.32 + self.cnt));
    self.angles_y = ang_y + 90;
    
    self.nextthink = time;
}

void Buffs_Model_Think(void) {
    if(self.sv_entnum) {
        // this is an overhead buff model

        self.alpha = 1;
        float me = ((spectatee_status > 0)? spectatee_status : player_localentnum);

        if(self.sv_entnum == me)
        if(!cvar("chase_active"))
            self.alpha = -1;

        self.angles_y = 200 * time;
    } else {
        if(!self.buff_active) {
            // this is an inactive buff pickup model

            self.alpha = 0.3;
            self.effects &~= EF_FULLBRIGHT | EF_ADDITIVE;
            self.light_lev = 0;
        } else {
            // this is an active buff pickup model

            self.alpha = 1;
            self.effects |= EF_FULLBRIGHT | EF_ADDITIVE;
            
            if(self.buffs == BUFF_MEODP)
                self.effects &~= EF_ADDITIVE;
            
            self.light_lev = 220 + 36 * sin(time);
        }
        
        self.angles_y = time * 110.1;
    }

    self.nextthink = time;
}

void Buffs_Model_Multi_Set(entity bmdl, entity parent, float offs) {
    bmdl.owner = parent;
    float bi = Buffs_TypeToIndex(bmdl.buffs);
    Buffs_Model_Set(bmdl, bmdl.buffs);
    bmdl.owner = parent;
    bmdl.draw = Buffs_Model_Draw;
    bmdl.scale = (parent.scale? parent.scale : 1); // * 0.90;
    bmdl.cnt = offs;
    bmdl.think = Buffs_Model_Multi_Think;
    bmdl.buffstat = parent.buffs;
    bmdl.sv_entnum = parent.sv_entnum;
    bmdl.nextthink = time;
}

void Buffs_Model_UpdateColor(entity ment) {
    ment.lightcolor = ment.colormod = Buffs_TypeToColor(ment.buffs);

    if(ment.buffs == BUFF_MEODP)
        ment.lightcolor = '1 0 0';

    if(ment.buff_ring)
        ment.buff_ring.colormod = (ment.team? GetTeamRGB(ment.team) + '0.1 0.1 0.1' : ment.colormod);
}

void Buffs_Model_Set(entity ment, float thebuffs) {
    float idx = Buffs_TypeToIndex(thebuffs);
    float i, j, b;
    
    ment.buffs = thebuffs;

    if(idx >= 0) {
        // single model - use ment to display it
        
        for(i = 0; i < BUFF_COUNT; ++i) {
            if(ment.(buffmdl[i])) {
                remove(ment.(buffmdl[i]));
                ment.(buffmdl[i]) = world;
            }
        }
        
        ment.effects &~= EF_NODRAW;
        
        vector omins = ment.mins;
        vector omaxs = ment.maxs;
        
        setmodel(ment, buff_modelnames[Buffs_TypeToIndex(thebuffs)]);
        setsize(ment, omins, omaxs);

        Buffs_Model_UpdateColor(ment);
    } else {
        // multiple buffs - hide ment and use additional models
        
        ment.effects |= EF_NODRAW;
        
        for(i = 0, b = 1; b <= BUFF_LAST; b *= 2) if(thebuffs & b) {
            if(!ment.(buffmdl[i]) || wasfreed(ment.(buffmdl[i])))
                ment.(buffmdl[i]) = spawn();
            ment.(buffmdl[i]).buffs = b;
            ++i;
        }
        
        for(j = 0; j < BUFF_COUNT; ++j) {
            if(j >= i) {
                if(ment.(buffmdl[j])) {
                    remove(ment.(buffmdl[j]));
                    ment.(buffmdl[j]) = world;
                }
            } else Buffs_Model_Multi_Set(ment.(buffmdl[j]), ment, (j/i)*360);
            
        }
    }
}

void Buffs_Model_Remove(void) {
    float i; for(i = 0; i < BUFF_COUNT; ++i) {
        if(self.(buffmdl[i])) {
            remove(self.(buffmdl[i]));
            self.(buffmdl[i]) = world;
        }
    }

    if(self.buff_ring) {
        remove(self.buff_ring);
    }
}

void Buffs_Model_Ring_Think(void) {
    self.nextthink = time;
    self.angles_y = time * 157.1;
    self.alpha = self.owner.alpha;
    self.effects = self.owner.effects;
    
    self.effects &~= EF_STARDUST | EF_NODRAW;
    
    if(self.owner.team)
        self.effects &~= EF_ADDITIVE;
    
    setorigin(self, self.owner.origin + '0 0 15');
}

void Buffs_Model_AttachRing(entity bmdl) {
    entity e = spawn();
    e.owner = self;
    e.effects = self.effects;
    e.alpha = self.alpha;
    e.scale = self.scale * 1.2;
    e.draw = Buffs_Model_Draw;
    e.think = Buffs_Model_Ring_Think;
    e.nextthink = time;

    setsize(e, self.mins, self.maxs);
    setorigin(e, self.origin + self.maxs * 0.5 * self.scale);
    setmodel(e, "models/buffs/buff_ring.md3");

    self.buff_ring = e;
}

void Buffs_Model_Read(void) {
    float sf = ReadByte();

    if(sf & 1) {
        self.sv_entnum = ReadByte(); // the buff owner

        self.entremove = Buffs_Model_Remove;
        self.draw = Buffs_Model_Draw;
        self.think = Buffs_Model_Think;
        self.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_NOSHADOW;
        self.light_lev = 200;
        self.nextthink = time;

        if(self.sv_entnum) {
            // this is an overhead buff model

            setsize(self, '0 0 -40', '0 0 40');
        } else {
            // this is a buff pickup model
            
            self.solid = SOLID_TRIGGER;
            self.movetype = MOVETYPE_TOSS;
            self.scale = 1.5;
            setsize(self, '-15 -15 -40', '15 15 40');
            self.gravity = 100;
            self.effects |= EF_STARDUST;

            Buffs_Model_AttachRing(self);
        }
    }

    if(sf & 2) {
        self.buff_active = ReadByte();
    }

    if(sf & 4) {
        Buffs_Model_Set(self, ReadShort());
    }

    if(sf & 8) {
        vector o;
        o_x = ReadCoord();
        o_y = ReadCoord();
        o_z = ReadCoord();
        setorigin(self, o);
    }

    if(sf & 16) {
        self.team = max(0, ReadByte()-1);
        Buffs_Model_UpdateColor(self);
    }
    
    InterpolateOrigin_Note();
}
