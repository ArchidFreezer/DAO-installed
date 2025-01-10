//::///////////////////////////////////////////////
//:: Area Core for the Spoiled Princess
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events for the Inn
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: 10/09/08
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"

#include "urn_constants_h"
#include "lit_constants_h"
#include "plt_genpt_oghren_main"
#include "plt_gen00pt_party"
#include "plt_lite_rogue_pieces"
#include "plt_lite_fite_condolences"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;
    object oFelsi = UT_GetNearestCreatureByTag(oPC,URN_CR_FELSI);

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            // Light Content: Dead Drops (Box of Certain Interests)
            WR_SetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_PLOT_SETUP,TRUE,TRUE);

            //Should the widows plot assist be on
            if (WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_QUEST_GIVEN) == TRUE &&
                WR_GetPlotFlag(PLT_LITE_FITE_CONDOLENCES, CONDOLENCES_LETTER_DELIVERED_2) == FALSE)
            {
                object oWidow = UT_GetNearestCreatureByTag(oPC, LITE_CR_CONDOLENCES_WIDOW2);
                SetPlotGiver(oWidow, TRUE);
            }

            if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED))
            {
               int nFelsiFailed = WR_GetPlotFlag(PLT_GENPT_OGHREN_MAIN,OGHREN_MAIN_FELSI_QUEST_FAILED,TRUE);
               int nFelsiMentioned = WR_GetPlotFlag(PLT_GENPT_OGHREN_MAIN,OGHREN_MAIN_FELSI_MENTIONED);
               int nFelsiActive = GetObjectActive(oFelsi);
               //--------------------------------------------------------------
               // if the PC enters the inn
               // and has refused to bring Oghren to see Felsi
               // and Felsi is active
               // set her inactive
               //--------------------------------------------------------------
               // Qwinn:  This bit of code doesn't work in the unmodded game because the else at the end was missing, so
               // Felsi got activated anyway.  As having this _FAILED flag set doesn't properly shut down the quest, and
               // in the unmodded game doesn't actually fail anything, and I can't see why Felsi would disappear because
               // you said something to Oghren half the world away, I'm just going to leave it out
               /* if (nFelsiFailed)
                   WR_SetObjectActive(oFelsi,FALSE);
               else */
               if (nFelsiMentioned)
                   WR_SetObjectActive(oFelsi,TRUE);
               else
                   WR_SetPlotFlag(PLT_GENPT_OGHREN_MAIN,OGHREN_MAIN_INN_ENTERED_BEFORE_FELSI_MENTIONED,TRUE);


               object oOghren = UT_GetNearestCreatureByTag(oPC,GEN_FL_OGHREN);
               int nOghren = WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_OGHREN_IN_PARTY,TRUE);
               int nIntroduced = WR_GetPlotFlag(PLT_GENPT_OGHREN_MAIN,OGHREN_MAIN_FELSI_MENTIONED,TRUE);
               int nOnce = GetLocalInt(OBJECT_SELF,AREA_DO_ONCE_A);
               //--------------------------------------------------------------
               // if Oghren is with the PC
               // and and Felsi is active
               // and has not initiated yet
               // he initiates
               //--------------------------------------------------------------
               if((nOghren == TRUE)
                   && (GetObjectActive(oFelsi) == TRUE)
                   && (nOnce == FALSE)
                   && (nIntroduced == TRUE))
               {
                   SetLocalInt(OBJECT_SELF,AREA_DO_ONCE_A,TRUE);
                   UT_Talk(oOghren,oPC);
               }
            }
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: fires at the same time that the load screen is going away,
        // and can be used for things that you want to make sure the player sees.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
    }
}