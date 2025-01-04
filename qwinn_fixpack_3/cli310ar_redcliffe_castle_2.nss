// Climax castle redcliffe second floor area script

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "cli_constants_h"
#include "party_h"

#include "plt_clipt_main"
#include "plt_gen00pt_party"
#include "plt_clipt_morrigan_ritual"     

#include "plt_qwinn"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: it is for playing things like cutscenes and movies when
        // you enter an area, things that do not involve AI or actual game play
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            RevealCurrentMap();
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            // Place Alistair/Loghain near Riordan's door when Riordan is waiting

            if(WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_RIORDAN_WAITING_IN_ROOM) &&
                !WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_RIORDAN_FINISHED_TALKING_IN_REDCLIFFE))
            {
                Log_Trace(LOG_CHANNEL_PLOT, "Redcliffe climax: Riordan waiting at room - setting Alistair/Loghain to wait outside his room");
                object [] arParty = GetPartyPoolList();
                int nSize = GetArraySize(arParty);
                int i;
                object oCurrent;
                for(i = 0; i < nSize; i++)
                {
                    oCurrent = arParty[i];
                    if(GetTag(oCurrent) == GEN_FL_ALISTAIR || GetTag(oCurrent) == GEN_FL_LOGHAIN)
                    {
                        if(GetTag(oCurrent) == GEN_FL_ALISTAIR)
                            WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                        // else if(GetTag(oCurrent) == GEN_FL_LOGHAIN) WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_IN_CAMP, TRUE, TRUE);
                        // Qwinn:  Commented out above, replaced with prep for Anora ambient dialogue
                        else if(GetTag(oCurrent) == GEN_FL_LOGHAIN)
                        {
                            WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_IN_CAMP, TRUE, TRUE);
                            object oAnora = UT_GetNearestCreatureByTag(oCurrent,"den510cr_anora");
                            object oRiordanDoor = UT_GetNearestObjectByTag( oCurrent,"genip_door_fer_lrg_riordan" );
                            object oHallsDoor = UT_GetNearestObjectByTag( oCurrent,"genip_door_fer_lrg_halls" );
                            int nDialogStarted = WR_GetPlotFlag(PLT_QWINN, CLI_LOGHAIN_ANORA_DLG_STARTED);
                            SetObjectInteractive(oCurrent,nDialogStarted);
                            WR_SetObjectActive(oAnora,!nDialogStarted);
                            SetObjectInteractive(oRiordanDoor,nDialogStarted);
                            if(nDialogStarted) WR_SetPlotFlag(PLT_QWINN, CLI_LOGHAIN_ANORA_DLG_DONE, TRUE, FALSE);

                        }
                        WR_SetObjectActive(oCurrent, TRUE);
                        UT_LocalJump(oCurrent, CLI_WP_WAITING_OUTSIDE_RIORDANS_ROOM);                        
                        break;
                    }

                }
            }
            // Otherwise (Riordan NOT waiting in room) - spawn Alistair/Loghain in their room
            else
            {
                Log_Trace(LOG_CHANNEL_PLOT, "Redcliffe climax: Riordan NOT waiting at room - setting Alistair/Loghain to be on their rooms");
                object [] arParty = GetPartyPoolList();
                int nSize = GetArraySize(arParty);
                int i;
                object oCurrent;
                string sWPTag;
                for(i = 0; i < nSize; i++)
                {
                    oCurrent = arParty[i];
                    if(GetTag(oCurrent) == GEN_FL_ALISTAIR || GetTag(oCurrent) == GEN_FL_LOGHAIN)
                    {
                        if(GetTag(oCurrent) == GEN_FL_ALISTAIR)
                        {
                            WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                            sWPTag = CLI_WP_ALISTAIR_IN_ROOM;
                        }
                        else if(GetTag(oCurrent) == GEN_FL_LOGHAIN)
                        {
                            WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LOGHAIN_IN_CAMP, TRUE, TRUE);
                            sWPTag = CLI_WP_LOGHAIN_IN_ROOM;
                            object oAnora = UT_GetNearestCreatureByTag(oCurrent,"den510cr_anora");
                            WR_SetObjectActive(oAnora,FALSE);
                            WR_SetPlotFlag(PLT_QWINN, CLI_LOGHAIN_ANORA_DLG_DONE, TRUE, FALSE);
                        }
                        WR_SetObjectActive(oCurrent, TRUE);
                        UT_LocalJump(oCurrent, sWPTag);
                        break;
                    }

                }
            }

            // Place Morrigan (game will load into denerim if ritual refused)
            // should be the same code as clipt_main
            // Qwinn:  Don't spawn her until after you've talked to Riordan, fixes a lot of bugs
            if(WR_GetPlotFlag(PLT_CLIPT_MAIN,CLI_MAIN_RIORDAN_FINISHED_TALKING_IN_REDCLIFFE))
            {
               if(!WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED)) // Morrigan has left
               {
                   // find fake Morrigan
                   object oFakeMorrigan = GetObjectByTag("cli310cr_morrigan_fake");
                   // Activate the placed Morrigan object
                   WR_SetObjectActive(oFakeMorrigan, TRUE);
                   // set her tag to match the party Morrigan
                   SetTag(oFakeMorrigan, GEN_FL_MORRIGAN);

               }
               else // Morrigan is still in party -> activate the stored party object
               {
                   object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);
                   string sWP = "cli310wp_" + GetTag(oMorrigan);
                   WR_SetObjectActive(oMorrigan, TRUE);
                   UT_LocalJump(oMorrigan, sWP);
               }

            }

            // Qwinn:  Good time to remove extra plot items
            UT_RemoveItemFromInventory(R"den360im_slaver_documents.uti");
            UT_RemoveItemFromInventory(R"den200im_pick3_silver_key.uti");
            UT_RemoveItemFromInventory(R"den100im_paedan_order.uti");
            UT_RemoveItemFromInventory(R"gen_it_corpse_gall.uti",100);
            UT_RemoveItemFromInventory(R"urn200im_dragons_blood.uti");

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