#ifdef INTERFACE
CLASS(NexuizNaggerDialog) EXTENDS(NexuizRootDialog)
    METHOD(NexuizNaggerDialog, fill, void(entity))
    ATTRIB(NexuizNaggerDialog, title, string, "Unsupported engine")
    ATTRIB(NexuizNaggerDialog, color, vector, SKINCOLOR_DIALOG_QUIT)
    ATTRIB(NexuizNaggerDialog, intendedWidth, float, 0.7)
    ATTRIB(NexuizNaggerDialog, rows, float, 6)
    ATTRIB(NexuizNaggerDialog, columns, float, 2)
    ATTRIB(NexuizNaggerDialog, name, string, "engineNagger")
ENDCLASS(NexuizNaggerDialog)
#endif

#ifdef IMPLEMENTATION
void fillNexuizNaggerDialog(entity me) {
    entity e;
    me.TR(me);
        me.TD(me, 1, me.columns, makeNexuizTextLabel(0.5, "Your engine version is not supported."));
    me.TR(me);
        me.TD(me, 1, me.columns, makeNexuizTextLabel(0.5, "You may experience crashes, poor performance and bugs."));
    me.TR(me);
        me.TD(me, 1, me.columns, makeNexuizTextLabel(0.5, "Please visit the following URL to update:"));
    me.TR(me);
        me.TD(me, 1, me.columns, e = makeNexuizTextLabel(0.5, DPRM_WEBSITE_URL));
        e.colorL = '0.1 1 0.1';
    me.TR(me);
    me.gotoRC(me, me.rows - 1, me.columns * 0.375);
        me.TD(me, 1, me.columns * 0.25, e = makeNexuizButton("OK", '1 0 0'));
            e.onClick = Dialog_Close;
            e.onClickEntity = me;
}

#endif
