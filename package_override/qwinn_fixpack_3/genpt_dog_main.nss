// Dog plot script

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "sys_treasure_h"
#include "approval_h"

#include "plt_genpt_dog_main"
#include "plt_pre100pt_mabari"
#include "plt_gen00pt_party"
#include "plt_gen00pt_party"

#include "den_constants_h"
#include "orz_constants_h"

#include "plt_cod_bks_dog_tattered"
#include "plt_cod_bks_dog_letter"
#include "plt_cod_cha_dog"

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
    object oChild = UT_GetNearestCreatureByTag(oPC,DEN_CR_CHILD_DOG);
    object oModule = GetModule();

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info
    object oDog = Party_GetFollowerByTag(GEN_FL_DOG);

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case DOG_MAIN_LEAVES_FOREVER:
            {
                WR_SetObjectActive(oDog, FALSE);
                break;
            }
            case DOG_MAIN_GERIENT_LEAVES:
            {
                object oGerient = UT_GetNearestCreatureByTag(oPC,ORZ_CR_GERIENT_DOG);
                //ACTION: Guy disappears and is never seen again.
                WR_SetObjectActive(oGerient,FALSE);
                break;
            }
            case DOG_MAIN_WARLIKE_DECREMENT_1:
            {
                //SET: DOG_WAR_DEC_1
                int nWarlike = GetLocalInt(oModule,DOG_WARLIKE_COUNTER)-1;
                SetLocalInt(oModule,DOG_WARLIKE_COUNTER,nWarlike);
                break;
            }
            case DOG_MAIN_WARLIKE_INCREMENT_1:
            {
                //SET: DOG_WAR_INC_1
                int nWarlike = GetLocalInt(oModule,DOG_WARLIKE_COUNTER)+1;
                SetLocalInt(oModule,DOG_WARLIKE_COUNTER,nWarlike);
                break;
            }
            case DOG_MAIN_FINDS_DENERIM_CHILD:
            {
                //turn the conversation flag off
                WR_SetPlotFlag(PLT_GENPT_DOG_MAIN,DOG_MAIN_IN_DENERIM,FALSE);
                //ACTION: set child active
                WR_SetObjectActive(oChild,TRUE);
                break;
            }
            case DOG_MAIN_DENERIM_CHILD_LEAVES:
            {
                //ACTION: Set child inactive
                WR_SetObjectActive(oChild,FALSE);
                break;
            }
            case DOG_MAIN_GIVES_DOCKS_LETTER:
            {
                //add codex entry for letter
                WR_SetPlotFlag(PLT_COD_BKS_DOG_LETTER,COD_BKS_DOG_LETTER_DOCKS,TRUE,TRUE);
                break;
            }
            case DOG_MAIN_GIVES_BOOK:
            {
                // Qwinn added
                UT_AddItemToInventory(R"gen_im_gift_tatbook.uti");

                //add codex entry for book
                WR_SetPlotFlag(PLT_COD_BKS_DOG_TATTERED,COD_BKS_DOG_TATTERED,TRUE,TRUE);

                break;
            }
            case DOG_MAIN_GIVES_RANDOM_ITEM:
            {
                //Dog finds something from random loot table.
                TS_GenerateItems(oPC, CREATURE_RANK_CRITTER, 1, 2, OBJECT_TYPE_CREATURE, 1.0f, -1.0f);

                break;
            }
            case DOG_MAIN_FADE_OUT_AND_IN:
            {
                //Fade out, fade in.

                break;
            }
            case DOG_MAIN_APPROVAL_MAXED_ON_RECRUITING:
            {
                //Max out dog's approval status. Should stay for remainder of game.
                Approval_ChangeApproval(APP_FOLLOWER_DOG,100);
                break;
            }
            case DOG_MAIN_GIVE_NAME:
            {
                /*void ShowPopup
                (int nMessageStrRef, int nPopupType, object oOwner = OBJECT_INVALID,
                int bShowInputField = FALSE, int nDefaultInputStrRef = 0)

                • nMessageStrRef is a string reference to the text of the message box.
                • nPopupType is a reference to the popup type, defined in popups.xls
                • oOwner is the owner of this popup
                • bShowInputField is a boolean which controls
                whether the pop-up will have a text-input field.
                • nDefaultInputStrRef is a string reference
                to the default text for the text-input.
                If 0, the input field will start empty.

                When a button is pressed and the pop-up is closed,
                the contents of the text-entry field will be returned
                as the 0th string argument to the EVENT_TYPE_POPUP_RESULT event
                to the MODULE.

                Text is filtered as it’s typed using the same filter
                that’s applied to the player’s name;
                thus, you cannot enter spaces nor many forms of punctuation.
                The text-field is currently limited to 20 characters
                (same as the player name).
                This limit can be changed, or converted to a sixth parameter
                to ShowPopup() if necessary.
                Currently, it is not possible for the player to enter an empty string;
                this behaviour could also be changed or turned into a parameter.
                */
                ShowPopup(362390,2,oDog,TRUE); //commented out while broken
                int nNoble = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_HUMAN_NOBLE,TRUE);
                if(nNoble == FALSE)
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY,GEN_DOG_RECRUITED,TRUE,TRUE);
                    WR_SetPlotFlag(PLT_COD_CHA_DOG,COD_CHA_DOG_NON_NOBLE_ORIGINS,TRUE);
                    WR_SetPlotFlag(PLT_COD_CHA_DOG,COD_CHA_DOG_QUOTE,TRUE);

                    WR_SetPlotFlag(PLT_GENPT_DOG_MAIN,DOG_MAIN_NON_NOBLE_JOINS_PARTY,TRUE,TRUE);
                }
                break;
            }
            case DOG_MAIN_REMOVE_GORE:
            {
                //ACTION: Fade out, Dog regenerates some health.
                Gore_RemoveAllGore(oPC);
                HealCreature(oDog,FALSE,5.0f);
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case DOG_MAIN_ENCOUNTER_AFTER_PRELUDE:
            {
                if(!WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED) && WR_GetPlotFlag(PLT_PRE100PT_MABARI, PRE_MABARI_DOG_HEALED))
                    nResult = TRUE;
                break;
            }
        }
    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}