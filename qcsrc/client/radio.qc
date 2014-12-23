
void Radio_Stopper_Think(void) {
    if(self.cnt < -2) {
        remove(self);
        return;
    }

    float t = gettime(GETTIME_CDTRACK);
    //print(ftos(t), "\n");

    if(self.cnt > t) {
        localcmd("cd reset;");
        remove(self);
    }

    self.cnt = t;
    self.nextthink = time;
}

void Radio_Think(void) {
    if(self.cnt < 0 || time - self.cnt > 300) {
        strunzone(self.netname);
        remove(self);
        return;
    }

    if(!fexists(self.netname)) {
        self.nextthink = time + 1;
        return;
    }

    if(cvar("bgmvolume") < 0.1)
        cvar_clientsettemp("bgmvolume", "0.1");

    float start = (self.flags? 0 : servertime - self.radio_starttime);
    localcmd("cd reset; cd remap ", self.netname, "; cd loop 1 ", ftos(start), ";");
    strunzone(self.netname);

    if(self.flags) {
        // loop
        remove(self);
    } else {
        // play once - we can't just use "cd play" here becase it's apparently broken
        // instead, detect when the track starts to loop and stop it
        self.cnt = -2;
        self.think = Radio_Stopper_Think;
        self.nextthink = time + 1;
    }
}

void Net_ReadRadio(void) {
    float preload = ReadByte();
    string url = ReadString();

    if(preload) {
        localcmd("curl --pak ", url, "\n");
        return;
    }

    string fname = strzone(ReadString());
    float loop = ReadByte();
    float start;
    
    if(!loop)
        start = ReadCoord();

    localcmd("curl --pak ", url, "\n");

    entity e;
    for(e = world; (e = find(e, classname, "radio"));)
        e.cnt = -3;

    e = spawn();
    e.classname = "radio";
    e.netname = fname;
    e.think = Radio_Think;
    e.nextthink = time;
    e.cnt = time;
    e.flags = loop;
    e.radio_starttime = start;
}
