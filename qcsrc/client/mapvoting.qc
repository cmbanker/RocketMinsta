float mv_num_maps;

float mv_active;
string mv_maps[MAPVOTE_COUNT];
string mv_pics[MAPVOTE_COUNT];
string mv_pk3[MAPVOTE_COUNT];
float mv_preview[MAPVOTE_COUNT];
float mv_votes[MAPVOTE_COUNT];
float mv_avail[MAPVOTE_COUNT];
float mv_hoveralpha[MAPVOTE_COUNT];
float mv_removetime[MAPVOTE_COUNT];
entity mv_pk3list;
float mv_abstain;
float mv_ownvote;
float mv_detail;
float mv_timeout;
float mv_maps_mask;
float mv_starttime;

#define PREVIEW_FROMSERVER 2

vector mv_mousepos;
float mv_selection;

string GameTypeVote_DescriptionByID(float id);

vector mv_mousepos;
float mv_selection;

string GameTypeVote_DescriptionByID(float id);

float MapVote_Selection(vector topleft, vector cellsize, float rows, float columns)
{
	float cell;
	float c, r;

	cell = -1;

	for (r = 0; r < rows; ++r)
		for (c = 0; c < columns; ++c)
		{
			if (mv_mousepos_x >= topleft_x + cellsize_x *  c &&
				mv_mousepos_x <= topleft_x + cellsize_x * (c + 1) &&
				mv_mousepos_y >= topleft_y + cellsize_y *  r &&
				mv_mousepos_y <= topleft_y + cellsize_y * (r + 1))
			{
				cell = r * columns + c;
				break;
			}
		}

	if (cell >= mv_num_maps)
		cell = -1;

	if (mv_abstain && cell < 0)
		return mv_num_maps;

	return cell;
}

/*
float GametypeVote_Selection()
{
	float r;
	float offset = sbar_fontsize_y * 10;
	float i;
	r = -1;
	
	for(i = 0; i < mv_num_maps; ++i) {
		float l_size;
		float lines;
		if(GameTypeVote_DescriptionByID(i) == "")
			lines = 0;
		else
			lines = tokenizebyseparator(GameTypeVote_DescriptionByID(i), "\n");
		l_size = sbar_fontsize_y * 1.4 + lines * sbar_fontsize_y; // 1.2

		if(mv_mousepos_y >= offset && mv_mousepos_y <= offset + l_size)
			r = i;
			
		offset += l_size + (sbar_fontsize_y * 0.5);
	}
	
	return r;
}
*/

float GametypeVote_Selection()
{
	float r;
	float offset = sbar_fontsize_y * 10;
	float i;
	r = -1;

	for(i = 0; i < mv_num_maps; ++i) {
		float sz;
		sz = sbar_fontsize_y * 1.4 + tokenizebyseparator(GameTypeVote_DescriptionByID(i), "\n") * sbar_fontsize_y;

		if(mv_mousepos_y >= offset && mv_mousepos_y <= offset + sz)
			r = i;

		offset += sz + sbar_fontsize_y;
	}

	return r;
}

string MapVote_FormatMapItem(float id, string map, float count, float maxwidth)
{
	string pre, post;
// not visually number-based voting in NeX
//	if(id >= 9) pre = strcat(ftos(id+1), ". ");
//	else pre = strcat("0", ftos(id+1), ". ");
	if(mv_detail && count >= 0)
	{
		if(count == 1)
			post = strcat(" (1 vote)");
		else
			post = strcat(" (", ftos(count), " votes)");
	}
	else
		post = "";
	maxwidth -= stringwidth(pre, FALSE) + stringwidth(post, FALSE);
	map = textShortenToWidth(map, maxwidth, stringwidth_nocolors);
	return strcat(pre, map, post);
}

vector MapVote_RGB(float id)
{
	if(id == mv_ownvote)
		return '0 1 0';
	else if (id == mv_selection)
		return '1 1 0';
	else
		return '1 1 1';
}

string GameTypeVote_DescriptionByID(float id)
{
	switch(mv_avail[id])
	{
		case GTV_FORBIDDEN:
		case GTV_AVAILABLE:
			return gametype_Name_to_Description(mv_maps[id]);

		case GTV_OVERPLAYED:
			return "This gametype is currently overplayed.";
/*
		case GTV_FORBIDDEN:
			return "This gametype is forbidden on this map.";
*/
		default:
			return "wtf?";
	}
}

#define drawGameTypeLine(s,c,sc,a) \
drawstring(o, (s), sbar_fontsize * (sc), (c), a * alpha, DRAWFLAG_NORMAL); \
o_y += sbar_fontsize_y * sc *  (1 - pow(alpha - 1, 2))

vector GameTypeVote_DrawGametypeItem(vector o, string gtype, float count, float id)
{
	local string s;
	s = GameTypeVote_DescriptionByID(id);

	float a, i, n = tokenizebyseparator(s, "\n");
	float alpha = bound(0, 0.5 * (time - mv_starttime), 1);
	
	if(sv_oldfag)
		alpha = 1;
	
	if(mv_avail[id] != GTV_AVAILABLE)
		a = 0.3; //0.5
	else
		a = 1;

	float oldx = o_x;
	o_x -= 10 * ipol_swingInOut(mv_hoveralpha[id]); //(1 - pow(mv_hoveralpha[id] - 1, 2));
	
	drawGameTypeLine(MapVote_FormatMapItem(id, gametype_Name_to_LongName(gtype), count, 500), MapVote_RGB(id), 1.4, a); // 1.2
	if(s != "") for(i = 0; i < n; ++i) {
		drawGameTypeLine(argv(i), '1 1 1', 1, a);
	}

	drawGameTypeLine("", '1 1 1', 01, 1);
	o_x = oldx;
	return o;
}

void MapVote_DrawMapItem(vector pos, float isize, float tsize, string map, string pic, float count, float id)
{
	//print("ENTERED MapVote_DrawMapItem(", pic, ")\n");
	
	vector img_size;
	vector rgb;
	vector txtpos;
    float origsize;
	string label;
	float text_size;

	float alpha = 1 - pow(bound(0, (time - mv_starttime), 1) - 1, 2);
	float ha = 	ipol_swingInOut(mv_hoveralpha[id]);
				//((id == mv_selection)? ipol_swingOut : ipol_swingIn)(mv_hoveralpha[id]);
	float fromserver = mv_preview[id] == PREVIEW_FROMSERVER;
	
	float alpha2;
	alpha2 = 1;
	
	if(mv_votes[id] < 0)
		alpha2 = 1 - bound(0, time - mv_removetime[id], 1) * 0.7;
	
	if(sv_oldfag) {
		alpha = 1;
		
		if(alpha2 != 1)
			alpha2 = 0.3;
	}
	
    origsize = isize;
	isize *= alpha + ha * 0.07;
	isize -= sbar_fontsize_y; // respect the text when calculating the image size

	rgb = MapVote_RGB(id);

	img_size_y = isize;
	img_size_x = isize / 0.75; // 4:3 x can be stretched easily, height is defined in isize

	drawfont = sbar_font;
	pos_y = pos_y + img_size_y;

	label = MapVote_FormatMapItem(id, map, count, tsize / sbar_fontsize_x);

	text_size = stringwidth(label, false) * sbar_fontsize_x;

	pos_x -= text_size*0.5;
	txtpos = pos;

	pos_x = pos_x + text_size*0.5 - img_size_x*0.5;
	pos_y = pos_y - img_size_y - (isize - origsize) * 0.5;

    pos += sbar_border_thickness * '1 1 0';
    img_size -= (sbar_border_thickness * 2) * '1 1 0';
    
    if(id < mv_num_maps)
        drawborderlines(sbar_border_thickness, pos, img_size, ((rgb == '1 1 1')? '0 0 0' : rgb), 1, DRAWFLAG_NORMAL);

	if(pic != "") {
        drawpic(pos, pic, img_size, '1 1 1' * alpha2, alpha * alpha2, DRAWFLAG_NORMAL);
	}

	vector hs = img_size * 0.5;
	//if(id < 9)
	//	drawpic_rotated_ex(pos + '1 0 0', strcat("gfx/hud/num_", ftos(id+1)), (img_size_y / 5) * '1 1 0', '1 1 1', angle, hs, 0.6 * alpha, DRAWFLAG_NORMAL);
	// TODO: make more numbers > 9
	drawstring(txtpos, label, sbar_fontsize, rgb * alpha * alpha2, alpha * alpha2, DRAWFLAG_NORMAL);
	
	//print("EXITED MapVote_DrawMapItem(", pic, ")\n");
}

void MapVote_DrawAbstain(vector pos, float isize, float tsize, float count, float id)
{
	vector rgb;
	float text_size;
	string label;

	rgb = MapVote_RGB(id);

	drawfont = sbar_font;
	pos_y = pos_y + sbar_fontsize_y;

	label = MapVote_FormatMapItem(id, "Don't care", count, tsize / sbar_fontsize_x);

	text_size = stringwidth(label, false) * sbar_fontsize_x;

	pos_x -= text_size*0.5;
	drawstring(pos, label, sbar_fontsize, rgb, 1, DRAWFLAG_NORMAL);
}

vector MapVote_GridVec(vector gridspec, float i, float m)
{
	float r;
	r = mod(i, m);
	return
		'1 0 0' * (gridspec_x * r)
		+
		'0 1 0' * (gridspec_y * (i - r) / m);
}

void MapVote_Draw()
{
	string map;
	float i, tmp;
	vector pos;
	float isize;
	float center;
	float columns, rows;
	float tsize;
	vector dist;

	if(!mv_active)
		return;

	mv_mousepos = mv_mousepos + getmousepos();

	mv_mousepos_x = bound(0, mv_mousepos_x, vid_conwidth);
	mv_mousepos_y = bound(0, mv_mousepos_y, vid_conheight);

	center = (vid_conwidth - 1)/2;
	xmin = vid_conwidth*0.05; // 5% border must suffice
	xmax = vid_conwidth - xmin;
	ymin = 20;
	i = cvar("con_chatpos"); //*cvar("con_chatsize");
	if(i < 0)
		ymax = vid_conheight + (i - cvar("con_chat")) * cvar("con_chatsize");
	if(i >= 0 || ymax < (vid_conheight*0.5))
		ymax = vid_conheight - ymin;

	drawfont = sbar_bigfont;
	sbar_fontsize = Sbar_GetFontsize("sbar_fontsize");

	pos_y = ymin;
	pos_z = 0;
	pos_x = center - stringwidth((gametypevote? "Decide the gametype" : "Vote for a map"), false) * 0.5 * 24;
	drawstring(pos, (gametypevote? "Decide the gametype" : "Vote for a map"), '24 24 0', '1 1 1', 1, DRAWFLAG_NORMAL);
	pos_y += 26;

	i = ceil(max(0, mv_timeout - time));
	map = strcat(ftos(i), " seconds left");
	pos_x = center - stringwidth(map, false) * 0.5 * 16;
	drawstring(pos, map, '16 16 0', '0 1 0', 1, DRAWFLAG_NORMAL);
	pos_y += 22;
	pos_x = xmin;

	drawfont = sbar_font;

	// base for multi-column stuff...
	ymin = pos_y;
	if(mv_abstain)
		mv_num_maps -= 1;

	if(mv_num_maps > 4)
	{
		if not(mod(mv_num_maps, 4))
			columns = 4;
		else
			columns = 3;
	} else {
		columns = mv_num_maps;
	}
	rows = ceil(mv_num_maps / columns);

	dist_x = (xmax - xmin) / columns;
	dist_y = (ymax - pos_y) / rows;
	tsize = dist_x - 10;
	isize = min(dist_y - 10, 0.75 * tsize);

	mv_selection = (gametypevote? GametypeVote_Selection() : MapVote_Selection(pos, dist, rows, columns));

	pos_x += (xmax - xmin) / (2 * columns);
	pos_y += (dist_y - isize) / 2;
	ymax -= isize;

	vector o;
    
	if(gametypevote)
	{
		// draws the picked map
		float rawalpha = bound(0, (time - mv_starttime), 1);
		float alpha = ipol_swingOut(rawalpha);

		if(sv_oldfag)
			rawalpha = alpha = 1;

		vector img_size;
		vector img_fullsize;

        isize = vid_conwidth * 0.25;
		img_size_y = isize;
		img_size_x = isize / 0.75;
		img_fullsize = img_size;
		img_size *= alpha;
        
        o_x = vid_conwidth * 0.75 - img_fullsize_x * 0.5;
        o_y = sbar_fontsize_y * 10;
        
        vector o2 = o + 0.5 * (img_fullsize - img_size);
        drawborderlines(sbar_border_thickness, o2, img_size, '0 0 0', 1, DRAWFLAG_NORMAL);
        if(mapvote_choosenmappic != "")
            drawpic(o2, mapvote_choosenmappic, img_size, '1 1 1', alpha, DRAWFLAG_NORMAL);

		vector sz = sbar_fontsize * alpha;
		img_size = img_fullsize;
		
		o_y += img_size_y + 10;
		o_x += img_size_x / 2 - ((stringwidth_nocolors(mapvote_choosenmap) / 2) * sz_x);
		
		drawstring(o, mapvote_choosenmap, sz, '1 1 1' * alpha * alpha, alpha * alpha, DRAWFLAG_NORMAL);
	}

	o_x = max(vid_conwidth * 0.25 - (sbar_fontsize_x * gametypevote_longest) * 0.25, sbar_fontsize_x);
	o_y = sbar_fontsize_y * 10;

	for(i = 0; i < mv_num_maps; ++i)
	{
		float ha = mv_hoveralpha[i];
		float ha_speed = 5;
		
		if(i == mv_selection)
			ha = bound(0, ha + frametime * ha_speed, 1);
		else
			ha = bound(0, ha - frametime * ha_speed, 1);
		
		if(sv_oldfag)
			ha = 0;
		
		mv_hoveralpha[i] = ha;
		
		if(!gametypevote && i == mv_selection)
			continue;	// draw selection on top of everything else
		
		tmp = mv_votes[i]; // FTEQCC bug: too many array accesses in the function call screw it up
		//if(tmp < 0)
		//	continue;
		map = mv_maps[i];
		
		if(gametypevote)
		{
			o = GameTypeVote_DrawGametypeItem(o, map, tmp, i);
		}
		else
		{
			if(mv_preview[i])
				MapVote_DrawMapItem(pos + MapVote_GridVec(dist, i, columns), isize, tsize, map, mv_pics[i], tmp, i);
			else
				MapVote_DrawMapItem(pos + MapVote_GridVec(dist, i, columns), isize, tsize, map, "", tmp, i);
		}
	}
	
	if(!gametypevote && mv_selection >= 0 && mv_selection < 16) {
		tmp = mv_votes[mv_selection]; // FTEQCC bug: too many array accesses in the function call screw it up
		//if(tmp >= 0) {
			map = mv_maps[mv_selection];
			
			if(mv_preview[mv_selection])
				MapVote_DrawMapItem(pos + MapVote_GridVec(dist, mv_selection, columns), isize, tsize, map, mv_pics[mv_selection], tmp, mv_selection);
			else
				MapVote_DrawMapItem(pos + MapVote_GridVec(dist, mv_selection, columns), isize, tsize, map, "", tmp, mv_selection);
		//}
	}
	
	if(mv_abstain) {
		tmp = mv_votes[i];
		pos_y = ymax + isize - sbar_fontsize_y;
		pos_x = (xmax+xmin)*0.5;
		MapVote_DrawAbstain(pos, isize, xmax - xmin, tmp, i);
		++mv_num_maps;
	}
	
	drawpic(mv_mousepos, strcat("gfx/menu/", cvar_string("menu_rmskin"), "/cursor.tga"), '32 32 0', '1 1 1', sbar_alpha_fg, DRAWFLAG_NORMAL);
}

void Cmd_MapVote_MapDownload(float argc)
{
	float id;
	entity pak;

	if(argc != 2 || !mv_pk3list)
	{
		print("mv_mapdownload: ^3You're not supposed to use this command on your own!\n");
		return;
	}

	id = stof(argv(1));
	for(pak = mv_pk3list; pak; pak = pak.chain)
		if(pak.sv_entnum == id)
			break;

	if(!pak || pak.sv_entnum != id) {
		print("^1Error:^7 Couldn't find pak index.\n");
		return;
	}

	//print(strcat("^3Adding: ", ftos(id), " - ", pak.message, " - "));

	if(PreviewExists(pak.message))
	{
		mv_preview[id] = true;
		//print("^2Found...\n");
		return;
	} else {
		print("Requesting preview...\n");
		localcmd(strcat("\ncmd mv_getpic ", ftos(id), "\n"));
	}
}

void MapVote_CheckPK3(string pic, string pk3, float id)
{
	entity pak;
	pak = spawn();
	pak.netname = pk3;
	pak.message = pic;
	pak.sv_entnum = id;

	pak.chain = mv_pk3list;
	mv_pk3list = pak;

	if(pk3 != "")
	{
		localcmd(strcat("\ncurl --pak ", pk3, "; wait; cl_cmd mv_download ", ftos(id), "\n"));
	}
	else
	{
		Cmd_MapVote_MapDownload(tokenize_console(strcat("mv_download ", ftos(id))));
	}
}

float MapVote_CheckPic(string pic, string pk3, float id)
{
	// never try to retrieve a pic for the "don't care" 'map'
	if(mv_abstain && id == mv_num_maps - 1)
		return 1;
	
	// never try to retrieve pics for gametype votes
	if(gametypevote)
		return 1;
	
	if(PreviewExists(pic)) {
		mv_preview[id] = true;
		return 1;
	}
    
    return 0;
}

void MapVote_Init()
{
	float i, n, j, power, tmp, oldnum;
	string map, pic, pk3, ssdir, q3ssdir;

	precache_sound ("misc/invshot.wav");

	registercmd("+showscores");
	registercmd("-showscores");

	mv_active = 1;
	mv_mousepos = '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
	mv_selection = -1;

	ssdir = ReadString();
    q3ssdir = "levelshots";
    
    oldnum = mv_num_maps;
	mv_num_maps = min(MAPVOTE_COUNT, ReadByte());
	mv_abstain = ReadByte();
	if(mv_abstain)
		mv_abstain = 1; // must be 1 for bool-true, makes stuff easier
	mv_detail = ReadByte();

	mv_ownvote = -1;
	mv_timeout = ReadCoord();

	gametypevote = ReadByte();

    if(gametypevote)
    {
        string cmap = ReadString();
        string cpic;
        
        for(i = 0; i < oldnum; ++i) {
            if(mv_maps[i] == cmap) {
                cpic = mv_pics[i];
                break;
            }
        }
        
        mapvote_choosenmap 		= strzone(cmap);
        mapvote_choosenmappic 	= strzone(cpic);
        
        print("^5Now decide the GAMETYPE!\n");
    }

	if(mv_num_maps <= 8)
		mv_maps_mask = ReadByte();
	else if(mv_num_maps <= 16)
		mv_maps_mask = ReadShort();
	else
		mv_maps_mask = ReadLong();

	// Assume mv_pk3list is NULL, there should only be 1 mapvote per round
	mv_pk3list = NULL; // I'm still paranoid!

    if(!mv_starttime || gametypevote)
        mv_starttime = time;
    
	for(i = 0, power = 1; i < mv_num_maps; ++i, power *= 2)
	{
		mv_votes[i] = 0;
        
		if(mv_maps_mask & power)
		{
            map = strzone(ReadString());
            pk3 = strzone(ReadString());
            mv_maps[i] = map;
            mv_pk3[i] = pk3;
            mv_preview[i] = false;
            
			if(gametypevote)
			{
				mv_avail[i] = ReadByte();
				map = mv_maps[i];
				n = tokenizebyseparator(GameTypeVote_DescriptionByID(i), "\n");
				for(j = 0; j < n; ++j)
				{
					tmp = strlen(argv(j));
					if(tmp > gametypevote_longest) {
						gametypevote_longest = tmp;
                    }
				}
			} else {
                pic = strzone(strcat(ssdir, "/", map));
                
                if(!MapVote_CheckPic(pic, pk3, i)) {
                    string q3pic = strcat(q3ssdir, "/", map);
                    
                    if(!MapVote_CheckPic(q3pic, pk3, i)) {
                        MapVote_CheckPK3(pic, pk3, i);
                    } else {
                        strunzone(pic);
                        pic = strzone(q3pic);
                    }
                }
                
                mv_pics[i] = pic;
            }
		}
		else
		{
			mv_maps[i] = strzone("if-you-see-this-the-code-is-broken");
			mv_pk3[i] = strzone("if-you-see-this-the-code-is-broken");
			mv_pics[i] = strzone("if-you-see-this-the-code-is-broken");
			mv_preview[i] = false;
			mv_avail[i] = false;
		}
	}
	if(mv_abstain)
		mv_votes[i] = 0;

	// do we NEED this, or can we handle key presses directly in CSQC?
	localcmd("\nin_bind 7 1 \"impulse 1\"; in_bind 7 2 \"impulse 2\"; in_bind 7 3 \"impulse 3\"; in_bind 7 4 \"impulse 4\"; in_bind 7 5 \"impulse 5\"; in_bind 7 6 \"impulse 6\"; in_bind 7 7 \"impulse 7\"; in_bind 7 8 \"impulse 8\"; in_bind 7 9 \"impulse 9\"; in_bind 7 0 \"impulse 10\"; in_bind 7 KP_1 \"impulse 1\"; in_bind 7 KP_2 \"impulse 2\"; in_bind 7 KP_3 \"impulse 3\"; in_bind 7 KP_4 \"impulse 4\"; in_bind 7 KP_5 \"impulse 5\"; in_bind 7 KP_6 \"impulse 6\"; in_bind 7 KP_7 \"impulse 7\"; in_bind 7 KP_8 \"impulse 8\"; in_bind 7 KP_9 \"impulse 9\"; in_bind 7 KP_0 \"impulse 10\"; in_bindmap 7 0\n");


}

void MapVote_UpdateMask()
{
	float i, power;
	float oldmask;

	oldmask = mv_maps_mask;
	if(mv_num_maps <= 8)
		mv_maps_mask = ReadByte();
	else if(mv_num_maps <= 16)
		mv_maps_mask = ReadShort();
	else
		mv_maps_mask = ReadLong();

	if(oldmask & mv_maps_mask != oldmask)
		if(oldmask & mv_maps_mask == mv_maps_mask)
			 sound(world, CHAN_AUTO, "misc_invshot.wav", VOL_BASE, ATTN_NONE);

	// remove votes that no longer apply
	for(i = 0, power = 1; i < mv_num_maps; ++i, power *= 2)
		if not(mv_maps_mask & power) {
			mv_votes[i] = -1;
			mv_removetime[i] = time;
		}
}

void MapVote_UpdateVotes()
{
	float i, power;
	for(i = 0, power = 1; i < mv_num_maps; ++i, power *= 2)
	{
		if(mv_maps_mask & power)
		{
			if(mv_detail)
				mv_votes[i] = ReadByte();
			else
				mv_votes[i] = 0;
		}
		else
			mv_votes[i] = -1;
	}

	mv_ownvote = ReadByte()-1;
}

void Ent_MapVote()
{
	float sf;

	sf = ReadByte();

	if(sf & 1)
		MapVote_Init();

	if(sf & 2)
		MapVote_UpdateMask();

	if(sf & 4)
		MapVote_UpdateVotes();
}

void Net_MapVote_Picture()
{
	float type;
	type = ReadByte();
	mv_preview[type] = PREVIEW_FROMSERVER;
	mv_pics[type] = strzone(ReadPicture());
}

float MapVote_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
	float imp;

	if (!mv_active)
		return false;

	if (bInputType != 0)
		return false;

	if ('0' <= nPrimary && nPrimary <= '9')
	{
		// number-based voting is not prefered in NeX - but still possible manually using impulse
		imp = nPrimary - '0';
		if (imp == 0) imp = 10;
		localcmd(strcat("\nimpulse ", ftos(imp), "\n"));
		return true;
	}

	if (nPrimary == K_MOUSE1)
		if (mv_selection >= 0)
		{
			imp = min(mv_selection + 1, mv_num_maps);
			localcmd(strcat("\nimpulse ", ftos(imp), "\n"));
			return true;
		}

	return false;
}
