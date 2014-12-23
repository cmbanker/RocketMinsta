
void DamageTracker_Print(entity keeper, entity to) {
    float i, j;
    
    DamageTracker_Sort(keeper);
    sprint(to, "\n------------------------------------------------------------\n");
    sprint(to, strcat("^5", keeper.netname, "^6 stats for ^7", keeper.owner.netname, "^6:\n"));
    sprint(to, "------------------------------------------------------------\n");
    
    FOR_DTRACK_ENTRIES(keeper, i) {
        float damage = keeper.(dtrack_damage[i]);
        string ratio = ftos((damage / keeper.dtrack_totaldamage) * 100);
        ratio = substring(ratio, 0, strstrofs(ratio, ".", 0) + 3);
        string srcname = DamageTracker_DamageSourceName(keeper.(dtrack_type[i]), TRUE);
        sprint(to, strcat(ftos(i+1), ". ^2", srcname));
        float spaces = max(1, 45 - strlen(srcname));
        for(j = 0; j < spaces; ++j)
            sprint(to, " ");
        sprint(to, strcat("^3", FormatDamage(damage), "^7 (", ratio, "%)\n"));
    }
    
    sprint(to, "------------------------------------------------------------\n\n");
}

void DamageTracker_Overwrite(entity keeper, entity client, float dtflags) {
    float ecnt, i;
    
    if(!sv_damagestats)
        return;
    
    if(clienttype(client) != CLIENTTYPE_REAL)
        return;
    
    dtflags |= DTFLAG_OVERWRITE;
    
    ecnt = DamageTracker_Sort(keeper);
    
    msg_entity = client;
    WriteByte(MSG_ONE, SVC_TEMPENTITY);
    WriteByte(MSG_ONE, TE_CSQC_DTRACK);
    WriteByte(MSG_ONE, dtflags);
    WriteByte(MSG_ONE, ecnt);
    
    FOR_DTRACK_ENTRIES(keeper, i) {
        WriteShort(MSG_ONE, keeper.(dtrack_type[i]));
        WriteShort(MSG_ONE, keeper.(dtrack_damage[i]));
    }
}

void DamageTracker_RecordAndSend(entity keeper, float dtype, float damage, float dtflags) {
    if(!sv_damagestats)
        return;
    
    if(!keeper.owner.iscreature)
        return;
    
    if(damage <= 0)
        return;
    
    DamageTracker_Record(keeper, dtype, damage);
    
    dtflags &~= DTFLAG_OVERWRITE;
    dtflags &~= DTFLAG_SPEC;
    
    if(clienttype(keeper.owner) == CLIENTTYPE_REAL) {
        msg_entity = keeper.owner;
        WriteByte(MSG_ONE, SVC_TEMPENTITY);
        WriteByte(MSG_ONE, TE_CSQC_DTRACK);
        WriteByte(MSG_ONE, dtflags);
        WriteShort(MSG_ONE, dtype);
        WriteShort(MSG_ONE, damage * 10);
    }
    
    entity e;
    FOR_EACH_REALCLIENT(e)
        if(e.enemy == keeper.owner)
            if(e.classname == "spectator") {
                msg_entity = e;
                WriteByte(MSG_ONE, SVC_TEMPENTITY);
                WriteByte(MSG_ONE, TE_CSQC_DTRACK);
                WriteByte(MSG_ONE, dtflags | DTFLAG_SPEC);
                WriteShort(MSG_ONE, dtype);
                WriteShort(MSG_ONE, damage * 10);
            }
}

