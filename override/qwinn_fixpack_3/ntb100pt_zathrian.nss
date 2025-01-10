//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Zathrian
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Jan 22/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_ntb100pt_zathrian"
#include "plt_cod_cha_zathrian"
#include "plt_ntb000pt_main"
#include "ntb_constants_h"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int nResult = FALSE; // used to return value for DEFINED GET events
    object oPC = GetHero();
    object oZathrian = UT_GetNearestCreatureByTag(oPC,NTB_CR_ZATHRIAN);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case NTB_ZATHRIAN_MITHRA_RETURNS_TO_POST:
            {
                // -----------------------------------------------------
                //CUTSCENE: Mithra bows and returns to her post
                // -----------------------------------------------------
                object oMithra = UT_GetNearestCreatureByTag(oPC,NTB_CR_MITHRA);
                UT_LocalJump(oMithra,NTB_WP_MITHRA_POST, FALSE);
                //UT_QuickMoveObject(oMithra, NTB_WP_MITHRA_POST);
                // Qwinn Added
                object oChest = UT_GetNearestObjectByTag(oPC,"ntb100ip_varathorn_chest");
                SetObjectInteractive(oChest, FALSE);
                break;
            }
            case NTB_ZATHRIAN_JUMP_TO_TENTS_AND_INITIATE:
            {
                // -----------------------------------------------------
                //ACTION: jump to wounded's tents and init dialog
                // -----------------------------------------------------
                UT_LocalJump(oZathrian,NTB_WP_WOUNDED_TENTS);
                UT_LocalJump(oPC,NTB_WP_WOUNDED_TENTS);
                UT_Talk(oZathrian,oPC);
                break;
            }
            case NTB_ZATHRIAN_RETURNS_TO_CAMP:
            {
                // -----------------------------------------------------
                //SET: EVENT_ELVES_CURED
                //CUTSCENE: Zathrian leaves for the camp
                //ACTION: make sure Zathrian waits at the camp.
                //When the player enters the camp:
                //- show the Curing cutscene
                //- have Zathrian init dialog afterwards.
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_CURED,TRUE,TRUE);

                WR_SetObjectActive(oZathrian,FALSE);

                //other werewolves can appear
                UT_TeamAppears(NTB_TEAM_WEREWOLF_LAIR_GATEKEEPER, TRUE);
                UT_TeamAppears(NTB_TEAM_GATEKEEPER_GUARDS, TRUE);
                UT_TeamGoesHostile(NTB_TEAM_WEREWOLF_LAIR_GATEKEEPER, TRUE);
                UT_TeamGoesHostile(NTB_TEAM_GATEKEEPER_GUARDS, TRUE);

                break;
            }
            case NTB_ZATHRIAN_RETURNS_TO_CAMP_WITH_PC:
            {
                // -----------------------------------------------------
                //SET: EVENT_ELVES_CURED (Main)
                //CUTSCENE: show elves being cured (BIG)
                //ACTION: jump all to camp and have Zathrian init dialog.
                // -----------------------------------------------------
                //other werewolves can appear
                UT_TeamAppears(NTB_TEAM_WEREWOLF_LAIR_GATEKEEPER, TRUE);
                UT_TeamAppears(NTB_TEAM_GATEKEEPER_GUARDS, TRUE);
                UT_TeamGoesHostile(NTB_TEAM_WEREWOLF_LAIR_GATEKEEPER, TRUE);
                UT_TeamGoesHostile(NTB_TEAM_GATEKEEPER_GUARDS, TRUE);

                WR_SetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ELVES_CURED,TRUE,TRUE);
                WR_SetObjectActive(oZathrian,FALSE);
                UT_DoAreaTransition(NTB_AR_DALISH_CAMP,NTB_WP_ZATHRIAN_INTERVIEW);
                break;
            }
            case NTB_ZATHRIAN_GIVE_MAIN_CODEX:
            {
                // -----------------------------------------------------
                //ACTION: Give Zathrian's main codex entry (either for elves or non-elves
                // -----------------------------------------------------
                if ( GetPlayerBackground(oPC) == BACKGROUND_DALISH )
                {
                    WR_SetPlotFlag(PLT_COD_CHA_ZATHRIAN, COD_CHA_ZATHRIAN_DALISH_MAIN,TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_COD_CHA_ZATHRIAN, COD_CHA_ZATHRIAN_ALL_OTHERS_MAIN,TRUE);
                }
                WR_SetPlotFlag(PLT_COD_CHA_ZATHRIAN, COD_CHA_ZATHRIAN_QUOTE, TRUE);

                break;
            }
            case NTB_ZATHRIAN_MOVE_TO_POST:
            {
                // -----------------------------------------------------
                //ACTION: Zathrian's moves back to his tent
                // -----------------------------------------------------

                // Qwinn changed.
                // UT_QuickMoveObject(oZathrian, NTB_WP_ZATHRIAN_POST); 
                UT_QuickMoveObject(oZathrian, NTB_WP_WOUNDED_TENTS );

                break;
            }
            // Added by Qwinn
            case NTB_ZATHRIAN_SENT_TO_VARATHORN:
            {
                object oChest = UT_GetNearestObjectByTag(oPC,"ntb100ip_varathorn_chest");
                SetObjectInteractive(oChest, TRUE);
                break;
            }

        }
     }

    return nResult;
}