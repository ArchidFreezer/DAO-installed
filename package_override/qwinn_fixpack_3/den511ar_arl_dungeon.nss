//::///////////////////////////////////////////////
//:: Area Core
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events
*/
//:://////////////////////////////////////////////
//:: Created By: Craig Graff
//:: Created On: March 13, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"

//#include "den_constants_h"
#include "den_functions_h"

#include "plt_denpt_rescue_the_queen"
#include "plt_bec100pt_soris"
#include "plt_bec000pt_main"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;

    object oSoris = UT_GetNearestObjectByTag(oPC, DEN_CR_SORIS);
    object oVaughan = UT_GetNearestObjectByTag(oPC, DEN_CR_VAUGHAN);

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: it is for playing things like cutscenes and movies when
        // you enter an area, things that do not involve AI or actual game play
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            if (!GetLocalInt(OBJECT_SELF, ENTERED_FOR_THE_FIRST_TIME))
            {
                if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_PARTY_IS_DISGUISED, TRUE))
                {
                    DEN_CreateDisguises();
                    UT_TeamAppears(DEN_TEAM_RESCUE_DUNGEON_WELCOME_SPEAKERS);
                }

                if (!WR_GetPlotFlag(PLT_BEC100PT_SORIS, BEC_SORIS_SAVED))
                {
                    WR_SetObjectActive(oSoris, TRUE);
                }
                if (!WR_GetPlotFlag(PLT_BEC000PT_MAIN, BEC_MAIN_VAUGHAN_DEAD))
                {
                    WR_SetObjectActive(oVaughan, TRUE);
                }
                UT_TeamGoesHostile(DEN_TEAM_RESCUE_MAGE_AMBUSH);
            }
            else if (WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_PARTY_IS_DISGUISED, TRUE))
                DEN_CreateDisguises();
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: fires at the same time that the load screen is going away,
        // and can be used for things that you want to make sure the player sees.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            if (!GetLocalInt(OBJECT_SELF, ENTERED_FOR_THE_FIRST_TIME))
            {
                DoAutoSave();
            }
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {
            object oCreature = GetEventCreator(ev);

            break;
        }

        // Qwinn added
        case EVENT_TYPE_TEAM_DESTROYED:
        {
            int nTeamID = GetEventInteger(ev, 0); // Team ID

            switch (nTeamID)
            {
                case DEN_TEAM_RESCUE_DUNGEON_WELCOME_SPEAKERS:
                {
                    // Qwinn: if cutscene didn't run because they were made hostile by AOE,
                    // set the correct flags when they're dead and restore equipment
                    if (!WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_GATEKEEPER_GOES_HOSTILE))
                        WR_SetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_GATEKEEPER_GOES_HOSTILE,TRUE,TRUE);
                    break;
                }
            }
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, DEN_SCRIPT_AREA_CORE);
    }
}