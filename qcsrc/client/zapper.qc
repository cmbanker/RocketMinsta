
.float zapper_range;
.vector zapper_start;
.vector zapper_end;
.vector zapper_offs;

void Zapper_Draw(void) {
    vector start;

    InterpolateOrigin_Do();
    self.zapper_end = self.origin;

    float me = ((spectatee_status > 0)? spectatee_status : player_localentnum);

    start = self.zapper_start;
    if(self.sv_entnum == me) if(!cvar("chase_active"))
        start = view_origin + view_forward * zapper_shotorigin_x + view_right * zapper_shotorigin_y + view_up * zapper_shotorigin_z;

    start = start + randomvec();

    self.zapper_offs += (randomvec() - self.zapper_offs) * drawframetime * 10;

    vector end1 = self.zapper_end;
    vector end2 = self.zapper_end + self.zapper_offs * 70;
    vector d = end2 - start;
    float maxlen = vlen(end1 - start);

    if(vlen(d) > maxlen)
        end2 = start + normalize(d) * maxlen;

    string tex;
    vector rgb;

    switch(self.team) {
        case COLOR_TEAM1:            tex = "particles/hook_red";    rgb = '3 1 1'; break;
        case COLOR_TEAM2: default:   tex = "particles/hook_blue";   rgb = '2 3 2'; break;
        case COLOR_TEAM3:            tex = "particles/hook_yellow"; rgb = '2 3 2'; break;
        case COLOR_TEAM4:            tex = "particles/hook_pink";   rgb = '2 3 2'; break;
    }

    Draw_CylindricLine(end1, start, 12, tex, 0.01, 5 * time, rgb, 10, DRAWFLAG_ADDITIVE);
    Draw_CylindricLine(end2, start,  7, tex, 0.03, 7 * time, rgb, 10, DRAWFLAG_ADDITIVE);

    float eff_zap = rm_particleeffectnum_team("RM_ZAPPER", self.team, 2);
    float eff_muz = rm_particleeffectnum_team("RM_ZAPPER_MUZZLEFLASH", self.team, 2);

    pointparticles(eff_zap, end1, '0 0 0', 1);
    pointparticles(eff_zap, end2, '0 0 0', 1);
    pointparticles(eff_muz, start, end1 - start, 1);
}

.float snd_looping;
void Zapper_Remove(void) {
    sound(self, CHAN_PROJECTILE, "misc/null.wav", VOL_BASE, ATTN_NORM);
}

void Zapper_Read(void) {
    float sf = ReadByte();

    if(sf & 1) {
        self.draw = Zapper_Draw;
        self.entremove = Zapper_Remove;
        self.sv_entnum = ReadByte();
        self.team = GetPlayerColor(self.sv_entnum - 1);

        sound(self, CHAN_PROJECTILE, "weapons/zapper_fly.wav", VOL_BASE, ATTN_NORM);
    }

    if(sf & 2) {
        self.zapper_start_x = ReadCoord();
        self.zapper_start_y = ReadCoord();
        self.zapper_start_z = ReadCoord();
    }

    if(sf & 4) {
        self.zapper_end_x = ReadCoord();
        self.zapper_end_y = ReadCoord();
        self.zapper_end_z = ReadCoord();
        setorigin(self, self.zapper_end);
        InterpolateOrigin_Note();
    }
    
    if(sf & 8) {
        zapper_shotorigin = decompressShotOrigin(ReadInt24_t());
    }
}

void Zapper_ReadLightning(void) {
    float ateam;
    vector from, to;
    
    ateam  = ReadByte();
    from_x = ReadCoord(); from_y = ReadCoord(); from_z = ReadCoord();
    to_x   = ReadCoord(); to_y   = ReadCoord(); to_z   = ReadCoord();

    pointparticles(rm_particleeffectnum_team("RM_HG_PLASMA_SHARD_EXPLODE", ateam, 2), to, '0 0 0', 1);

    if(cvar("cl_effects_lightningarc_simple")) {
        LightingArc_Segment(from, to, ateam);
    } else {
        float seglength, drifts, drifte, branchfactor, branchfactor_add, lcount;

        seglength        = 24;
        drifts           = 0.1;
        drifte           = 0.25;
        branchfactor     = 0;
        branchfactor_add = 0;
        lcount           = cvar("cl_effects_lightningarc_count");
        
        for(; lcount; --lcount)
            LightingArc_Full(from, to, seglength, drifts, drifte, branchfactor, branchfactor_add, ateam);
    }

    pointparticles(particleeffectnum("electro_muzzleflash"), from, normalize(to - from) * 1000, 1);
}
