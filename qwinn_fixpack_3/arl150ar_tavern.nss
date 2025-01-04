//::///////////////////////////////////////////////
//:: Area Core
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events for the tavern
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Mar 6/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "sys_audio_h"

#include "arl_constants_h"
#include "plt_arl100pt_activate_shale"
#include "plt_arl100pt_siege"
#include "plt_arl100pt_siege_prep"
#include "plt_arl100pt_after_siege"
#include "plt_gen00pt_stealing"'

// Qwinn added
#include "plt_arl150pt_loghain_spy"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);

    HandleEvent(ev, ARL_R_GENERIC_AREA_SCRIPT);

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            object oTomas = UT_GetNearestCreatureByTag(oPC, ARL_CR_TOMAS);
            object oLloyd = UT_GetNearestCreatureByTag(oPC, ARL_CR_LLOYD);



            int bTomasTavern = WR_GetPlotFlag(PLT_ARL100PT_AFTER_SIEGE, ARL_AFTER_SIEGE_TOMAS_IN_TAVERN);
            int bBattleOver = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OVER);
            int bAbandoned = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_VILLAGE_ABANDONED);
            int bPlayerKnowsKeg = WR_GetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_PC_KNOWS_ROD_UNDER_KEG);
            int bPlayerKnowsLloyd = WR_GetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_PC_KNOWS_LLOYD_HAS_ROD);
            int bSiegeOver = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OVER);

            // if village was abandoned, deactivate everyone
            if ((bAbandoned == TRUE))
            {
                AudioTriggerPlotEvent(75);
                UT_TeamAppears(ARL_TEAM_VILLAGERS, FALSE);
            }

            // if PC is told the rod is under the keg, activate the keg
            // if the village is abandoned and the player knows Lloyd has the rod, activate the keg as well.
            if ( (bPlayerKnowsKeg == TRUE) || ((bAbandoned == TRUE) && (bPlayerKnowsLloyd == TRUE)) )
            {
                object oKeg = UT_GetNearestObjectByTag(oPC, ARL_IP_KEG);

                SetObjectInteractive(oKeg, TRUE);
            }

            //Activate or deactivate the gossipcs, dependingon if they are there.
            object oGossipTrigger = UT_GetNearestObjectByTag(oPC, ARL_TR_TAVERN_GOSSIP);
            int bGossipsActive = ((bAbandoned == FALSE) && (bBattleOver == TRUE));

            UT_TeamAppears(ARL_TEAM_TAVERN_GOSSIP, bGossipsActive);
            WR_SetObjectActive(oGossipTrigger, bGossipsActive);
            
            // Qwinn:  Remove letter from berwick if we already have it.
            if (WR_GetPlotFlag(PLT_ARL150PT_LOGHAIN_SPY, ARL_LOGHAIN_SPY_PC_HAS_BERWICKS_LETTER))
            {   object oBerwick = UT_GetNearestCreatureByTag(oPC, ARL_CR_BERWICK);
                UT_RemoveItemFromInventory(ARL_R_IT_SPY_LETTER, 1, oBerwick);
            }

            break;
        }

        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: all game objects in the area have loaded
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            Log_Systems("*** AREA FINISHED LOADING", LOG_LEVEL_WARNING);

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);
            Log_Systems("*** Object entered area: " + GetTag(oCreature));

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

        case EVENT_TYPE_STEALING_FAILURE:
        {
            WR_SetPlotFlag(PLT_GEN00PT_STEALING, STEALING_ARL_INFAMY, TRUE, TRUE);
            break;
        }
    }
    HandleEvent(ev, RESOURCE_SCRIPT_AREA_CORE);
}