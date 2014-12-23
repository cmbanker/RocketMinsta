
#ifdef USE_DPRM

void DPRM_Draw2D() {
    /*
	if(DPRM_VersionIsSuitable())
		return;
	
	float t_alpha = bound(0, time * 0.05, 1);
	vector t_size = '8.5 8.5 0'; // * (1.1 - 0.2 * bound(0, 5 * t_alpha, 1));
	vector t_pos  = '0 1 0' * (vid_conheight * 0.5 + vid_conheight * 0.2 * bound(0, 10 * ipol_pow2InOut(t_alpha), 1));
	
	#define S(t) drawcolorcodedstringcenter(t_pos, t, t_size, bound(0.2, 1 - t_alpha, 1), DRAWFLAG_NORMAL); t_pos_y += t_size_y;
	S("^1WARNING: ^7Your engine is out of date!")
	S("Please download and install an update patch from ^2" DPRM_WEBSITE_URL)
	S("Besides the new features, it includes many bugfixes and performance improvements")
	#undef S(t)
    */
}

#else
	#include "dprm_stub.qc"
#endif
