#!/bin/sed -f
s/g_balance_minstanex_explosive/g_rocketminsta/g
s/g_explosive_norecoil/g_rocketminsta_norecoil/g
s/g_explosive_health_drain/g_rocketminsta_health_drain/g
s/g_explosive_hook_forcerules/g_rocketminsta_hook_forcerules/g
s/g_explosive_hook_breakable/g_rocketminsta_hook_breakable/g
s/g_explosive_hook_damagefactor/g_rocketminsta_hook_damagefactor/g
s/g_explosive_hook/g_balance_grapplehook/g
s/g_explosive_score/g_rocketminsta_score/g
s/g_explosive_health/g_rocketminsta_health/g
s/g_explosive_armor/g_rocketminsta_armor/g
s/g_explosive_default_velocity_influence/g_balance_push_velocityinfluence/g
s/g_explosive_laser/g_rocketminsta_laser/g
s/g_explosive_vote/sv_vote/g
s/g_explosive_showspecs/sv_showspecs/g
s/g_explosive_splash/g_rocketminsta_splash/g
s/g_explosive_rmcustom/sv_rmcustom/g
s/g_explosive_keyhunt/g_keyhunt/g
s/g_explosive_minsta/g_balance_minstanex/g
s/g_explosive_anonspecs/sv_anonspecs/g
s/g_explosive_domination/g_domination/g
s/g_explosive_gametypevote/sv_vote_gametype/g
s/g_explosive_shownames/sv_shownames/g
s/g_explosive_speedaward/sv_speedaward/g
s/g_explosive_autoaway/sv_autoaway/g
s/g_explosive_infomessages/sv_infomessages/g
s/g_explosive_ip2country/sv_ip2country/g
s/g_ip2c/sv_ip2country/g
s/g_explosive_randomspawns/sv_randomspawns/g
s/g_explosive_allow_fakeflag/sv_fakeflag/g
s/g_explosive_secretvotes/sv_vote_secretcommands/g
s/g_explosive_allowmadoka/sv_madoka/g
s/g_explosive_oldnex/sv_oldnex/g
s/g_explosive_extendfragmessages/sv_extendfragmessages/g
s/g_explosive_powerupsonbases/g_balance_powerupsonbases/g
s/g_explosive_spawnclosetoteam/g_spawnclosetoteam/g
s/g_explosive_allow_hidecountry/sv_hidecountry/g
s/g_explosive_weaponarena/g_weaponarena/g
s/g_explosive_gotoserver/sv_gotoserver/g
s/g_explosive_serveralias/sv_serveralias/g
s/g_explosive_autokickafk/sv_autoaway_kick/g
s/g_explosive_ballisticbullet/g_ballistics/g
s/g_explosive_droppowerups/g_droppowerups/g
s/g_explosive_boobs/g_boobs/g
s/g_explosive_chat/sv_chat/g
s/g_explosive_handgrenades/g_nadgets/g
s/g_explosive_dodging/g_dodging/g
s/g_explosive_freezetag/g_freezetag/g
s/g_explosive_vip/g_vip/g
s/g_explosive_jailbreak/g_jailbreak/g
s/g_explosive_walljump/g_walljump/g
s/g_explosive_hidedamage/sv_hidedamage/g
s/g_explosive_ctf/g_ctf/g
s/g_explosive_/g_rocketminsta_/g
s/g_handgrenades/g_nadgets/g
s/g_\(nadgets\|handgrenades\)_\([a-zA-Z]*\)_regenscale/g_nadgets_\2_regen_scale/g
s/g_\(nadgets\|handgrenades\)_\([a-zA-Z]*\)_stacklimit/g_nadgets_\2_regen_limit/g
