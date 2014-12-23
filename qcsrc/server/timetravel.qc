
#define TIMETRAVEL_HANDLE_ALL \
        TIMETRAVEL_HANDLE(health,                       Float)      \
        TIMETRAVEL_HANDLE(armorvalue,                   Float)      \
        TIMETRAVEL_HANDLE(pushltime,                    Time)       \
        TIMETRAVEL_HANDLE(origin,                       Origin)     \
        TIMETRAVEL_HANDLE(angles,                       Angles)     \
        TIMETRAVEL_HANDLE(velocity,                     Vector)     \
        TIMETRAVEL_HANDLE(strength_finished,            Time)       \
        TIMETRAVEL_HANDLE(invincible_finished,          Time)       \
        TIMETRAVEL_HANDLE(jump_interval,                Time)       \
        TIMETRAVEL_HANDLE(ammo_shells,                  Float)      \
        TIMETRAVEL_HANDLE(ammo_nails,                   Float)      \
        TIMETRAVEL_HANDLE(ammo_rockets,                 Float)      \
        TIMETRAVEL_HANDLE(ammo_cells,                   Float)      \
        TIMETRAVEL_HANDLE(ammo_fuel,                    Float)      \
        TIMETRAVEL_HANDLE(weapons,                      Float)      \
        TIMETRAVEL_HANDLE(items,                        Float)      \
        TIMETRAVEL_HANDLE(cnt,                          Float)      \
        TIMETRAVEL_HANDLE(spawnshieldtime,              Time)       \
        TIMETRAVEL_HANDLE(pauserotarmor_finished,       Time)       \
        TIMETRAVEL_HANDLE(pauserothealth_finished,      Time)       \
        TIMETRAVEL_HANDLE(pauserotfuel_finished,        Time)       \
        TIMETRAVEL_HANDLE(pauseregen_finished,          Time)       \
        TIMETRAVEL_HANDLE(avelocity,                    Vector)     \
        TIMETRAVEL_HANDLE(punchangle,                   Vector)     \
        TIMETRAVEL_HANDLE(punchvector,                  Vector)     \
        TIMETRAVEL_HANDLE(oldvelocity,                  Vector)     \
        TIMETRAVEL_HANDLE(crouch,                       Float)      \
        TIMETRAVEL_HANDLE(lastdamage,                   Time)       \
        TIMETRAVEL_HANDLE(last_dodging_time,            Time)       \
        TIMETRAVEL_HANDLE(lastwj,                       Time)       \
        TIMETRAVEL_HANDLE(weapon_nextthink,             Time)       \
        TIMETRAVEL_HANDLE(weapon_think,                 VoidFunc)   \
        TIMETRAVEL_HANDLE(frozen,                       Float)      \
        TIMETRAVEL_HANDLE(freezetime,                   Time)       \
        TIMETRAVEL_HANDLE(jb_isprisoned,                Float)      \
        TIMETRAVEL_HANDLE(jb_prisontime,                Time)       \
        TIMETRAVEL_HANDLE(disableclientprediction,      Float)      \
        TIMETRAVEL_HANDLE_SPECIAL(WeaponState)

.float tt_weaponentity_state;
void TimeTravel_StoreWeaponState(entity e, entity moment) {
    if(!e.weaponentity)
        return;
    
    moment.tt_weaponentity_state = e.weaponentity.state;
    moment.weapon = e.weapon;
    
    entity oldself = self;
    self = e;
    tt_moment = moment;
    float w; for(w = WEP_FIRST; w <= WEP_LAST; ++w) {
        weapon_action(w, WR_TT_STORE);
        ATTACK_FINISHED_FOR(moment, w) = ATTACK_FINISHED_FOR(e, w) - time;
    }
    self = oldself;
}

void TimeTravel_RestoreWeaponState(entity e, entity moment) {
    if(!e.weaponentity)
        return;
    
    e.weaponentity.state = moment.tt_weaponentity_state;
    W_SwitchWeapon_Force(e, moment.weapon);
    e.w_instaswitch = TRUE;
    
    entity oldself = self;
    self = e;
    tt_moment = moment;
    float w; for(w = WEP_FIRST; w <= WEP_LAST; ++w) {
        weapon_action(w, WR_TT_RESTORE);
        ATTACK_FINISHED_FOR(e, w) = ATTACK_FINISHED_FOR(moment, w) + time;
    }
    self = oldself;
}

#define TIMETRAVEL_HANDLE(f,t) TimeTravel_Store##t(e, moment, f);
#define TIMETRAVEL_HANDLE_SPECIAL(t) TimeTravel_Store##t(e, moment);
entity TimeTravel_SaveMoment(entity e) {
    entity moment;
    
    if(!e)
        return world;
    
    moment = spawn();
    TIMETRAVEL_HANDLE_ALL
    return moment;
}
#undef TIMETRAVEL_HANDLE_SPECIAL
#undef TIMETRAVEL_HANDLE

#define TIMETRAVEL_HANDLE(f,t) TimeTravel_Restore##t(e, moment, f);
#define TIMETRAVEL_HANDLE_SPECIAL(t) TimeTravel_Restore##t(e, moment);
void TimeTravel_TakeBack(entity e, entity moment) {
    if(!e || !moment)
        return;
    
    TIMETRAVEL_HANDLE_ALL
}
#undef TIMETRAVEL_HANDLE_SPECIAL
#undef TIMETRAVEL_HANDLE

void TimeTravel_EraseMoment(entity moment) {
    remove(moment);
}

#undef TIMETRAVEL_HANDLE_ALL
#undef TIMETRAVEL_STORE_IDENTITY
#undef TIMETRAVEL_RESTORE_IDENTITY
#undef TIMETRAVEL_HANDLER
