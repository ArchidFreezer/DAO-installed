//::///////////////////////////////////////////////
//:: Area Core
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events
*/
//:://////////////////////////////////////////////
//:: Created By: Craig
//:: Created On: April 21st, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "lit_functions_h"

#include "den_constants_h"
#include "lit_constants_h"
#include "plt_denpt_main"
#include "plt_den220pt_noble_tavern"
#include "plt_den200pt_gen_assassin"
#include "plt_den200pt_assassin_nrd"
#include "plt_den200pt_assassin_orz"
#include "plt_den200pt_assassin_end"
#include "plt_den200pt_gen_assassin"
#include "plt_den200pt_thief_pick4"
#include "plt_lite_fite_blackstone"

vector QwConvToVector(float x, float y, float z)
{
    return Vector(x,y,z);
}


void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    object oThis = OBJECT_SELF;
    object oTarg;

    int nEventHandled = FALSE;

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            if ( GetTag(GetArea(oPC)) != GetTag(oThis) ) break;

            // Pick Pocket quest 4
            if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_ASSIGNED) &&
                !WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_SUCCESSFUL) )
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_SETUP_TAVERN, TRUE, TRUE);
            }

            // Cleanup Pick Pocket quest 4
            if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_SUCCESSFUL) &&
                !WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_CLEANUP_TAVERN) )
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_CLEANUP_TAVERN, TRUE, TRUE);
            }

            // If the Assassin Quest has been opened up then move Ignacio here
            if ( WR_GetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, CROW_ASSASIN_LETTER_RECEIVED) &&
                !WR_GetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, IGNACIO_MOVED_TO_NOBLE_TAVERN) )
            {
                // Ignacio has a quest for you
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_IGNACIO);
                SetPlotGiver(oTarg, TRUE);

                WR_SetPlotFlag(PLT_DEN200PT_GEN_ASSASSIN, IGNACIO_MOVED_TO_NOBLE_TAVERN, TRUE, TRUE);
                UT_TeamAppears(DEN_TEAM_IGNACIO);
            }

            // If you've completed the NRD Assassin mission, then put a reward in the chest
            // Qwinn:  Added money based on unimplemented rewards.xls DEN_ASSASSIN_NRD_DONE
            if ( WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_NRD, ASSINATED_QUNARI) &&
                !WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_NRD, ASSASSIN_NRD_REWARD_PLACED) )
            {
                object oChest = UT_GetNearestObjectByTag(oPC, DEN_IP_ASSASSIN_CHEST);
                object oMoney = CreateItemOnObject(R"gen_im_copper.uti", oChest, 60000, "", TRUE);
                WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_NRD, ASSASSIN_NRD_REWARD_PLACED, TRUE, TRUE);
            }

            // If you've completed the ORZ Assassin mission, then put a reward in the chest
            // Qwinn:  Added money based on unimplemented rewards.xls DEN_ASSASSIN_ORZ_DONE
            if ( WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_ORZ, AMBASSADOR_KILLED) &&
                !WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_ORZ, ASSASSIN_ORZ_REWARD_PLACED) )
            {
                object oChest = UT_GetNearestObjectByTag(oPC, DEN_IP_ASSASSIN_CHEST);
                object oMoney = CreateItemOnObject(R"gen_im_copper.uti", oChest, 60000, "", TRUE);
                WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_ORZ, ASSASSIN_ORZ_REWARD_PLACED, TRUE, TRUE);
            }

            // If you've completed the END Assassin mission, then put a reward in the chest
            // Qwinn:  Added money based on unimplemented rewards.xls DEN_ASSASSIN_END_PAY_TAKEN + DEN_GEN_ASSASSIN_ALL_DONE
            if ( WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_END, ASSASSIN_LAST_TARGET_KILLED) &&
                !WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_END, ASSASSIN_END_REWARD_PLACED) )
            {
                object oChest = UT_GetNearestObjectByTag(oPC, DEN_IP_ASSASSIN_CHEST);
                object oMoney = CreateItemOnObject(R"gen_im_copper.uti", oChest, 120000, "", TRUE);
                WR_SetPlotFlag(PLT_DEN200PT_ASSASSIN_END, ASSASSIN_END_REWARD_PLACED, TRUE, TRUE);
            }

            if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_QUEST_DONE))
            {
                UT_TeamAppears(DEN_TEAM_NOBLES, FALSE);
            }
            else if (WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLOT_OPENED))
            {
                UT_TeamAppears(DEN_TEAM_NOBLES, TRUE);

                // Move Sighard   (Modified by Qwinn to make him face correctly and to make Ceorlic non-interactive)
                if (WR_GetPlotFlag(PLT_DEN220PT_NOBLE_TAVERN, DEN_NOBLE_SIGHARD_LEAVES_CEORLIC))
                {
                    object oSighard     = UT_GetNearestCreatureByTag(oPC, DEN_CR_SIGHARD);
                    object oSighardWP   = UT_GetNearestObjectByTag(oPC, DEN_WP_NOBLE_SIGHARD);
                    SetPosition(oSighard, GetPosition(oSighardWP), FALSE);
                    vector vSigDir = QwConvToVector(83.4f, 0.0f, 0.0f);
                    SetOrientation(oSighard, vSigDir);
                    object oCeorlic     = UT_GetNearestCreatureByTag(oPC, DEN_CR_CEORLIC);
                    SetObjectInteractive(oCeorlic,FALSE);                    
                }
            }
            else
            {
                UT_TeamAppears(DEN_TEAM_NOBLES, FALSE);
            }

            //Light Content - should the blackstone irregular's box be active
            if (WR_GetPlotFlag(PLT_LITE_FITE_BLACKSTONE, FITE_BLACKSTONE_LEARNED_ABOUT) == TRUE)
            {
                //fighter box is now available
                object oBox = UT_GetNearestObjectByTag(oPC, LITE_IM_BLACKSTONE_BOX_2);
                SetObjectInteractive(oBox, TRUE);
            }

            object oBlackstone = UT_GetNearestCreatureByTag(oPC, "lite_fite_blackstone");
            SetPlotGiver(oBlackstone, BlackstoneTurnInPossible());

            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, DEN_SCRIPT_AREA_CORE);
    }
}