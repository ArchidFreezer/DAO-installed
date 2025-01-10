//==============================================================================
/*
        lot100pt_bandits.ncs
        The first encounter with bandits in Lothering.
*/
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_lot100pt_bandits"
#include "campaign_h"
#include "lot_constants_h"

//------------------------------------------------------------------------------

void RemoveBandits();
void BanditsHostile();

int StartingConditional()
{
    event   eParms              =   GetCurrentEvent();              // Contains all input parameters

    int     nType               =   GetEventType(eParms);           // GET or SET call
    int     nFlag               =   GetEventInteger(eParms, 1);     // The bit flag # being affected
    int     nResult             =   FALSE;

    string  strPlot             =   GetEventString(eParms, 0);      // Plot GUID

    object  oParty              =   GetEventCreator(eParms);        // The owner of the plot table for this script
    object  oConversationOwner  =   GetEventObject(eParms, 0);      // Owner on the conversation, if any

    object  oPC                 =   GetHero();
    object  oLeader             =   UT_GetNearestObjectByTag(oPC, LOT_CR_BANDIT_LEADER);
    object  oBandit1            =   UT_GetNearestObjectByTag(oPC, LOT_CR_BANDIT);
    object  oBandit2            =   UT_GetNearestObjectByTag(oPC, LOT_CR_BANDIT_2);
    object  oBandit3            =   UT_GetNearestObjectByTag(oPC, LOT_CR_BANDIT_3);
    object  oBandit4            =   UT_GetNearestObjectByTag(oPC, LOT_CR_BANDIT_4);

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)                                // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!

        switch(nFlag)
        {
            case BANDITS_PC_GIVE_BRIBE:
            {
                UT_MoneyTakeFromObject(oPC, 0, LOT_BANDITS_BRIBE, 0);

                break;
            }

            case BANDITS_PC_GIVE_BRIBE_2:
            {
                UT_MoneyTakeFromObject(oPC, 0, LOT_BANDITS_BRIBE_2, 0);

                // Have the bandits move back to their original positions.
                UT_QuickMove(LOT_CR_BANDIT_LEADER);

                UT_QuickMove(LOT_CR_BANDIT);

                UT_QuickMove(LOT_CR_BANDIT_2);

                UT_QuickMove(LOT_CR_BANDIT_3);

                UT_QuickMove(LOT_CR_BANDIT_4);

                break;
            }

            case BANDITS_ATTACK:
            {

                UT_SetSurrenderFlag(oLeader, TRUE, PLT_LOT100PT_BANDITS, BANDITS_LEADER_SURRENDERS);

                // Set the non-interactive bandits to be interactive.
                SetObjectInteractive(oBandit2, TRUE);
                SetObjectInteractive(oBandit3, TRUE);
                SetObjectInteractive(oBandit4, TRUE);

                UT_TeamGoesHostile(LOT_TEAM_BANDITS);

                break;
            }

            case BANDITS_ATTACK_POST_SURRENDER:
            {

                // Set the non-interactive bandits to be interactive.
                SetObjectInteractive(oBandit2, TRUE);
                SetObjectInteractive(oBandit3, TRUE);
                SetObjectInteractive(oBandit4, TRUE);
                // Qwinn adding Surveyor for player to loot
                if(WR_GetPlotFlag(PLT_LOT100PT_BANDITS, BANDITS_GIVE_LOOT) == FALSE)
                {
                  UT_AddItemToInventory(R"gen_im_acc_rng_r05.uti",1,oLeader,"gen_im_acc_rng_r05",TRUE);
                }
                UT_TeamGoesHostile(LOT_TEAM_BANDITS);

                break;
            }

            case BANDITS_LET_GO:
            {
                WR_SetPlotFlag(strPlot, BANDITS_DONE, TRUE);

                RemoveBandits();

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_LOTHERING_2c);

                break;
            }

            case BANDITS_KILLED:
            {

                WR_SetPlotFlag(strPlot, BANDITS_DONE, TRUE, TRUE);

                //UT_TeamGoesHostile(LOT_TEAM_BANDITS);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_LOTHERING_2b);

                break;
            }

            case BANDITS_LEADER_SURRENDERS:
            {
                UT_SetSurrenderFlag(oLeader, FALSE);

                if(!IsDeadOrDying(oBandit1))
                {
                    UT_LocalJump(oBandit1, "", TRUE, TRUE, TRUE);
                }

                // Make them non-interactive if they are still alive.
                if(!IsDeadOrDying(oBandit2))
                {
                    SetObjectInteractive(oBandit2, FALSE);

                    UT_LocalJump(oBandit2, "", TRUE, TRUE, TRUE);

                }

                if(!IsDeadOrDying(oBandit3))
                {
                    SetObjectInteractive(oBandit3, FALSE);

                    UT_LocalJump(oBandit3, "", TRUE, TRUE, TRUE);

                }

                if(!IsDeadOrDying(oBandit4))
                {
                    SetObjectInteractive(oBandit4, FALSE);

                    UT_LocalJump(oBandit3,"", TRUE, TRUE, TRUE);
                }

                break;
            }

            case BANDITS_JUST_INTIMIDATED:
            {
                // This non functional flag previously just made the bandits disappear,
                // but gave no experience, journal entry or quest closure.  You only got
                // it when bribing then intimidating the bandits to leave town.  If you
                // intimidated them twice, you got "BANDITS_LET_GO" which gave an incorrect
                // journal entry.  Made flag functional, gave it a new journal entry and
                // implemented it for both cases.  Copied the below "BANDITS_LET_GO" actions
                // here.
                WR_SetPlotFlag(strPlot, BANDITS_DONE, TRUE);

                RemoveBandits();

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_LOTHERING_2c);

                break;
            }

            case BANDITS_INTIMIDATED_BY_GREY_WARDEN:
            case BANDITS_INTIMIDATED_BY_MAGE:
            {

                // Make them non-interactive if they are still alive.
                if(!IsInvalidDeadOrDying(oBandit2))
                {
                    SetObjectInteractive(oBandit2, FALSE);
                }

                if(!IsInvalidDeadOrDying(oBandit3))
                {
                    SetObjectInteractive(oBandit3, FALSE);
                }

                if(!IsInvalidDeadOrDying(oBandit4))
                {
                    SetObjectInteractive(oBandit4, FALSE);
                }

                // Move them back to their original positions.
                UT_QuickMove(LOT_CR_BANDIT_LEADER);

                UT_QuickMove(LOT_CR_BANDIT);

                UT_QuickMove(LOT_CR_BANDIT_2);

                UT_QuickMove(LOT_CR_BANDIT_3);

                UT_QuickMove(LOT_CR_BANDIT_4);

                break;
            }

            case BANDITS_BRYNAT_SENT_TEMPLARS:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_LOTHERING_2a);

                break;
            }
        }

     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case BANDITS_PC_HAS_BRIBE:
            {
                // check for bribe money
                if(UT_MoneyCheck(oPC, 0, LOT_BANDITS_BRIBE, 0))
                    nResult = TRUE;
                break;
            }

            case BANDITS_PC_HAS_BRIBE_2:
            {
                // check for bribe money
                if(UT_MoneyCheck(oPC, 0, LOT_BANDITS_BRIBE_2, 0))
                    nResult = TRUE;
                break;
            }

            case BANDITS_PC_LEFT_BANDITS_THERE:
            {
                nResult = TRUE;
                // Qwinn:  Added BANDITS_JUST_INTIMIDATED check here
                if (WR_GetPlotFlag(PLT_LOT100PT_BANDITS,BANDITS_KILLED)
                 || WR_GetPlotFlag(PLT_LOT100PT_BANDITS,BANDITS_LET_GO)
                 || WR_GetPlotFlag(PLT_LOT100PT_BANDITS,BANDITS_JUST_INTIMIDATED))
                    nResult = FALSE;

                break;

            }

            case BANDITS_DONE_AND_ANGRY_REF_TOLD:
            {
                // Qwinn:  This condition always ran, every time.
                // Fixed, also changed the dialogue to check it for being true instead of false.

                int bCondition1 =   WR_GetPlotFlag(PLT_LOT100PT_BANDITS, BANDITS_ANGRY_REG_TOLD);
                int bCondition2 =   WR_GetPlotFlag(PLT_LOT100PT_BANDITS, BANDITS_PC_LEFT_BANDITS_THERE);
                // nResult = bCondition1 && !bCondition2;
                nResult = (!bCondition1) && (!bCondition2);

            }

        }

    }

    return nResult;
}

void RemoveBandits()
{
   UT_TeamExit(LOT_TEAM_BANDITS, TRUE, LOT_WP_BANDITS_EXIT);

}

void BanditsHostile()
{
    object oPC = GetHero();
    UT_CombatStart(oPC, GetObjectByTag("lot100cr_bandit_leader"));

}