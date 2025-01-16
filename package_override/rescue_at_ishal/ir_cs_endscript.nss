//::///////////////////////////////////////////////
//:: Generic cutscene-end script
//:: Copyright (c) 2007 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Generic cutscene-end script. Checks module
    cutscene variables to determine what (if
    anything) needs to be done after a cutscene
    has played.
*/
//:://////////////////////////////////////////////
//:: Created By: Jonathan Epp
//:: Created On: Jan. 18, 2007
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plt_pre100pt_light_beacon"
#include "pre_objects_h"

void main()
{
    CS_CutsceneEnd();
    WR_SetPlotFlag(PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_AFTER_BEACON_CUTSCENE, TRUE, TRUE);
    //WR_SetPlotFlag(PLT_PRE100PT_LIGHT_BEACON, PRE_BEACON_AFTER_RESCUE_CUTSCENE, TRUE);
    //UT_DoAreaTransition(PRE_AR_FLEMETH_HUT_INTERIOR, PRE_WP_FLEMETH_HUT_INSIDE);


}