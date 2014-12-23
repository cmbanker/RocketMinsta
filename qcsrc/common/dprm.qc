#ifdef USE_DPRM

void DPRM_Start() {
	dprm_version = DPRM_GetVersion();
	
	if not(DPRM_VersionIsSuitable())
		print("\n====================================================================\n^1WARNING: ^7Your engine is out of date!\nPlease download and install the update from ^2" DPRM_WEBSITE_URL "^7\n====================================================================\n\n");
}

float DPRM_GetVersion() {
    if(!(cvar_type("dprm_version") & CVAR_TYPEFLAG_ENGINE))
        return 0;
	return cvar("dprm_version");
}

float DPRM_VersionIsSuitable() {
	return dprm_version >= DPRM_MINVERSION;
}

#else
	#include "dprm_stub.qc"
#endif

float DPRM_IsDPRMEngine() {
	return dprm_version;
}
