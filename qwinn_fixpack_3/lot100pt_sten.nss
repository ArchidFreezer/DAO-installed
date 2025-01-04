//==============================================================================
/*
    lot100pt_sten.ncs
    Sten's plot in Lothering.
*/
//==============================================================================
// Owner: Kaelin
//==============================================================================
#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "global_objects_h"

#include "lot_constants_h"

#include "plt_lot100pt_sten"
#include "plt_gen00pt_party"
#include "plt_cod_cha_sten"
#include "plt_mnp000pt_autoss_main"
// Qwinn:  Added this for the change below.
#include "plt_genpt_sten_talked"

//------------------------------------------------------------------------------

int StartingConditional()
{
    event   eParms              = GetCurrentEvent();            // Contains all input parameters

    int     nType               = GetEventType(eParms);         // GET or SET call
    int     nFlag               = GetEventInteger(eParms, 1);   // The bit flag # being affected
    int     nResult             = FALSE;                        // used to return value for DEFINED GET events

    string  strPlot             = GetEventString(eParms, 0);    // Plot GUID

    object  oParty              = GetEventCreator(eParms);      // The owner of the plot table for this script
    object  oConversationOwner  = GetEventObject(eParms, 0);    // Owner on the conversation, if any
    object  oPC                 = GetHero();

    plot_GlobalPlotHandler(eParms);                             // any global plot operations, including debug info

    object  oSten               = UT_GetNearestCreatureByTag(oPC, GEN_FL_STEN);

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue      = GetEventInteger(eParms, 2);           // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   = GetEventInteger(eParms, 3);           // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            // Qwinn:  STEN_TOLD_MURDER is the only variable that gets set when Sten tells you of his crime, but the
            // variable that is actually checked during his personal quest intro is
            // genpt_sten_talked:STEN_TALKED_KNOWS_ABOUT_FARM_MURDERS.  Can't set it directly because it also needs
            // to be set in Ser Bryant and the Revered Mothers' dialogues, and they can't access genpt_sten_talked.
            // They can access this, though.  So, if this one gets set, so does the other.
            case STEN_TOLD_MURDER:
            {
                WR_SetPlotFlag(PLT_GENPT_STEN_TALKED, STEN_TALKED_KNOWS_ABOUT_FARM_MURDERS, TRUE, TRUE);
                break;
            }

            case STEN_FOUND:
            {
                SetPlotGiver(GetObjectByTag(GEN_FL_STEN), FALSE);

                // Codex entry for meeting Sten.
                WR_SetPlotFlag(PLT_COD_CHA_STEN, COD_CHA_STEN_MAIN, TRUE, TRUE);

                //Take an automatic screenshot
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_LOT_QUNARI_IN_A_CAGE, TRUE, TRUE);

                break;

            }

            case STEN_PC_HAS_CAGE_KEY:
            {

                object  oRevMother  =   UT_GetNearestObjectByTag(oPC, LOT_CR_CHANTRY_GRAND_CLERIC);

                RewardItem(LOT_IM_STENS_KEY);

                // Remove the key from the Revered Mother.
                UT_RemoveItemFromInventory(LOT_IM_STENS_KEY, 1, oRevMother);

                break;

            }

            case STEN_CAGE_OPENED:
            {
                WR_SetPlotFlag(strPlot,STEN_CAGE_OPENED,FALSE);

                int bStenFound  =   WR_GetPlotFlag(PLT_LOT100PT_STEN, STEN_FOUND);

                if(!bStenFound)
                {

                    WR_SetPlotFlag(PLT_LOT100PT_STEN, STEN_FOUND, TRUE, TRUE);

                }

                // Open Sten's cage and remove the key if the player has it.
                SetPlaceableState(GetObjectByTag(LOT_IP_STENS_CAGE),PLC_STATE_CAGE_OPEN);


                UT_Talk(oSten, oPC);

                break;

            }

            case STEN_CLERIC_AGREED_TO_RELEASE_STEN:
            {

                // Give the player the key.
                WR_SetPlotFlag(strPlot,STEN_PC_HAS_CAGE_KEY, TRUE, TRUE);

                break;

            }

            case STEN_DIALOG_OPEN_CAGE:
            {
                string sKey = ResourceToTag(LOT_IM_STENS_KEY);

                object oKey = GetObjectByTag(sKey);

                // Open Sten's cage and remove the key if the player has it.
                SetPlaceableState(GetObjectByTag(LOT_IP_STENS_CAGE),PLC_STATE_CAGE_OPEN);

                //if(IsObjectValid(oKey))
                {
                    UT_RemoveItemFromInventory(LOT_IM_STENS_KEY);
                }


                break;

            }

            case STEN_REMAINS:
            {
                SetPlaceableState(GetObjectByTag(LOT_IP_STENS_CAGE),PLC_STATE_CAGE_LOCKED);

                break;

            }

            case STEN_RELEASED:
            {
                //Automatic screenshot
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN, AUTOSS_LOT_STEN_JOINS, TRUE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_LOTHERING_1);

                break;
            }

            case STEN_ASK_TO_TALK_TO_CLERIC:
            {

                object  oCage   =   UT_GetNearestObjectByTag(oPC, LOT_IP_STENS_CAGE);

                // Make Sten's cage interactive.
                SetObjectInteractive(oCage, TRUE);

                break;

            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case STEN_FOUND_NO_KEY_NO_OPEN_CAGE:
            {
                if(WR_GetPlotFlag( strPlot, STEN_FOUND) &&
                    !WR_GetPlotFlag( strPlot, STEN_CAGE_OPENED) &&
                    !WR_GetPlotFlag( strPlot, STEN_PC_HAS_CAGE_KEY))
                    nResult = TRUE;
                break;
            }
            case STEN_CLERIC_REFUSED_TO_RELEASE_STEN_PLUS:
            {
                if(WR_GetPlotFlag( strPlot, STEN_CLERIC_REFUSED_TO_RELEASE_STEN) &&
                    !WR_GetPlotFlag( strPlot, STEN_CAGE_OPENED) &&
                    !WR_GetPlotFlag( strPlot, STEN_PC_HAS_CAGE_KEY))
                    nResult = TRUE;
                break;
            }

            case STEN_FOUND_NOT_RELEASED:
            {
                int bCondition1 = WR_GetPlotFlag(PLT_LOT100PT_STEN, STEN_FOUND);
                int bCondition2 = WR_GetPlotFlag(PLT_LOT100PT_STEN, STEN_RELEASED);

                nResult = ((bCondition1) && !(bCondition2));
                break;
            }

            case STEN_TOLD_MURDER_AND_ALISTAIR_IN_PARTY:
            {

                int bCondition1 =   WR_GetPlotFlag(PLT_LOT100PT_STEN, STEN_TOLD_MURDER);
                int bCondition2 =   WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY);

                nResult = ( !(bCondition1) && (bCondition2) );

                break;

            }

        }

    }

    return nResult;
}