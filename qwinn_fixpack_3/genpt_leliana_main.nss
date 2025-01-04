// Leliana plot events

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"


#include "plt_genpt_leliana_main"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_alistair"
#include "plt_genpt_app_zevran"
#include "plt_genpt_app_morrigan"
#include "plt_cod_cha_leliana"
#include "plt_mnp000pt_generic"
#include "plt_gen00pt_party"
#include "plt_gen00pt_class_race_gend"
#include "plt_gen00pt_backgrounds"
#include "plt_ntb000pt_main"
#include "den_lc_constants_h"
#include "ran_constants_h"
#include "plt_genpt_leliana_events"
#include "plt_mnp000pt_autoss_main2"

int StartingConditional()
{
    event   eParms              = GetCurrentEvent();            // Contains all input parameters
    int     nType               = GetEventType(eParms);         // GET or SET call
    int     i;                                                  // Counter
    string  strPlot             = GetEventString(eParms, 0);    // Plot GUID
    int     nFlag               = GetEventInteger(eParms, 1);   // The bit flag # being affected
    object  oParty              = GetEventCreator(eParms);      // The owner of the plot table for this script
    object  oConversationOwner  = GetEventObject(eParms, 0);    // Owner on the conversation, if any
    int     nResult             = FALSE;                        // used to return value for DEFINED GET events
    object  oPC                 = GetHero();
    object  oLeader             = GetObjectByTag(RAN_409_ASSASIN);

    object [] oLelAssasin       = GetTeam(RAN_TEAM_409_ASSASINS);

    object oLeliana     = UT_GetNearestObjectByTag(oPC, GEN_FL_LELIANA);
    object oMarjolaine  = UT_GetNearestObjectByTag(oPC, "den250cr_marjolaine");
    object oQunWar_A    = UT_GetNearestObjectByTag(oPC, "den250cr_war_a");
    object oQunWar_B    = UT_GetNearestObjectByTag(oPC, "den250cr_war_b");
    object oQunMage_A   = UT_GetNearestObjectByTag(oPC, "den250cr_mage_a");
    object oQunMage_B   = UT_GetNearestObjectByTag(oPC, "den250cr_mage_b");
    object oNuggKid     = UT_GetNearestObjectByTag(oPC, "orz400cr_nugcatcher");

    resource rNugg      = R"gen_im_gift_nugg.uti";

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue      = GetEventInteger(eParms, 2);     // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case LELIANA_MAIN_REFUSED_BY_PC_AT_DANES_REFUGE:
            {
                WR_SetObjectActive(oLeliana, FALSE);
                break;
            }
            case LELIANA_MIAN_LELIANA_HAS_NUG:
            {
                //ACTION: Nug kid runs off.
                SetObjectActive(oNuggKid, FALSE);
                break;
            }
            case LELIANA_MIAN_KID_GOT_NUG:
            {
                //ACTION: Kid goes away for a day (an area transition or perhaps)
                SetObjectActive(oNuggKid, FALSE);
                break;
            }
            case LELIANA_MAIN_LEAVES_LOTHERING_FOREVER:
            {
                //Action: Leliana leaves and is gone forver.
                WR_SetObjectActive(oLeliana, FALSE);
                break;
            }
            case LELIANA_MAIN_SPARED_MARJOLAINE:
            {
                object [] oMarjTrap = GetObjectsInArea(GetArea(oPC), "den250ip_trap_explode_a");
                int i; // Counter

                //ACTION: Marjolaine walks away.
                WR_SetObjectActive(oMarjolaine, FALSE);
                UT_Talk(oLeliana, oPC);

                // Disable all traps
                for (i = 0; i < GetArraySize(oMarjTrap); i++)
                  WR_SetObjectActive(oMarjTrap[i], FALSE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COMPANIONS_2a);

                break;
            }
            case LELIANA_MAIN_KILLED_MARJOLAINE:
            {
                //ACTION: Marjolaine calls her men and there's a big fight.
                WR_SetObjectActive(oQunWar_A, TRUE);
                WR_SetObjectActive(oQunWar_B, TRUE);
                WR_SetObjectActive(oQunMage_A, TRUE);
                WR_SetObjectActive(oQunMage_B, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_MARJOLAINE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COMPANIONS_2a);

                break;
            }
            case LELIANA_MAIN_ASSASSIN_KILLED:
            {
                //ACTION: Assassin dies.
                SetImmortal(oLeader, FALSE);
                KillCreature(oLeader, oPC);
                WR_SetPlotFlag(PLT_GENPT_LELIANA_EVENTS, LELIANA_EVENT_ON, TRUE);
                UT_Talk(oLeliana, oPC);
                break;
            }
            case LELIANA_MAIN_ASSASSIN_RELEASED:
            {
                //ACTION: Assasin is disabled
                WR_ClearAllCommands(oLeader);
                WR_SetObjectActive(oLeader, FALSE);
                //UT_ExitDestroy(oLeader, TRUE, "wp_exit");
                WR_SetPlotFlag(PLT_GENPT_LELIANA_EVENTS, LELIANA_EVENT_ON, TRUE);
                UT_Talk(oLeliana, oPC);
                break;
            }
            case LELIANA_MAIN_ASSASSIN_PRE_CONVERSATION:
            {
                // Check if all other members are dead
                // if they aren't dead set them inactive

                for (i = 0; i < GetArraySize(oLelAssasin); i++)
                {
                    if (IsDead(oLelAssasin[i]) == FALSE)
                        WR_SetObjectActive(oLelAssasin[i], FALSE);
                }
                break;
            }
            case LELIANA_MAIN_SINGS:
            {
                //ACTION: Play Ambient Leliana music, only needs to play once
                break;
            }
            case LELIANA_MAIN_PC_GIVEN_NUG:
            {
                //ACTION: Create Nugg on character
                CreateItemOnObject(rNugg, oPC, 1);
                SetObjectActive(oNuggKid, FALSE);
                // Kid runs away
                break;
            }
            case LELIANA_MAIN_TEACHES_BARD:
            {
                //ACTION: Leliana teaches player how to be a bard
                RW_UnlockSpecializationTrainer(SPEC_ROGUE_BARD);
                break;
            }
            case LELIANA_MAIN_ATTACKS_PC:
            {
                // Leliana attacks the PC for destroying the urn of sacred
                // ashes.

                // Set in urn200pt_cult.nss
                // and urn230ip_urn.dlg
                object oTarg;

                oTarg = GetObjectByTag(GEN_FL_LELIANA);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED, FALSE, TRUE);
                UT_CombatStart(oTarg, oPC);
                break;
            }
            case LELIANA_MAIN_LEAVES:
            {
                SetObjectActive(oLeliana, FALSE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED, FALSE, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_LELIANA, COD_CHA_LELIANA_FIRED, TRUE);
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_LEL_LELIANA_LEAVES_PARTY, TRUE, TRUE);
                break;
            }
            case LELIANA_MAIN_JOIN_AT_LOTHERING_EXIT:
            {
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED, TRUE, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_LELIANA, COD_CHA_LELIANA_HIRED_AT_GATES, TRUE);
                break;
            }
            case LELIANA_MAIN_SPOKE_ABOUT_MARJ:
            {
                WR_SetPlotFlag(PLT_COD_CHA_LELIANA, COD_CHA_LELIANA_HUNTED, TRUE);
                break;
            }
            case LELIANA_MAIN_HEARD_MINSTREL:
            {                                                                        
                // Qwinn:  Moved this codex set to HEARD_SPY
                // WR_SetPlotFlag(PLT_COD_CHA_LELIANA, COD_CHA_LELIANA_SUPER_SPY, TRUE);
                break;
            }
            case LELIANA_MAIN_HEARD_SPY:
            {
                // So Leliana has to leave camp to get 2nd part of this conversation.
                // Qwinn:  Moved next line from HEARD_MINSTREL to here
                WR_SetPlotFlag(PLT_COD_CHA_LELIANA, COD_CHA_LELIANA_SUPER_SPY, TRUE);
                WR_SetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_STILL_IN_CAMP, TRUE);
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case LELIANA_MAIN_READY_TO_TALK_ABOUT_ORLAIS:
            {
                //IF: In camp
                //IF: APP_LELIANA_IS_WARM
                //IF: HEARD_LEL_SPY [leliana_main]
                int bAtCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);
                int bWarm = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_WARM, TRUE);
                int bKnowSpy = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_HEARD_SPY, TRUE);
                if ( (bAtCamp == TRUE) && (bWarm == TRUE) && (bKnowSpy == TRUE) )
                {
                    nResult = TRUE;
                }

                break;
            }
            case LELIANA_MAIN_READY_TO_START_ROMANCE_FEMALE:
            {
                //IF: Leliana is at +50 approval
                //IF: In camp
                //IF: PC is female
                // Qwinn:  Adding a ROMANCE_CUT_OFF and NOT_ELIGIBLE check
                int bCutOff = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_CUT_OFF, TRUE);
                int bNotEligible = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_NOT_ELIGIBLE_SAME_SEX, TRUE);

                int bAtCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);
                int bFemale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE, TRUE);
                //NOTE: I've gone with warm for this approval check. This may cause it to come up too early.
                int bApproval = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_WARM, TRUE);
                // if ( (bAtCamp == TRUE) && (bFemale == TRUE) && (bAproval == TRUE) )
                if ( bAtCamp && bFemale && bApproval && (!bCutOff) && (!bNotEligible) )
                {
                    nResult = TRUE;
                }
                break;
            }

            case LELIANA_MAIN_CONFRONTED_MARJOLAINE_AT_CAMP:
            {
                //IF: MARJOLAINE_CONFRONTED[lelia_main]
                //IF: in camp
                int bConfronted = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_MARJOLAINE_CONFRONTED, TRUE);
                int bAtCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);
                if ( (bConfronted == TRUE) && (bAtCamp == TRUE) )
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_MAIN_ANGRY_ABOUT_A_ROMANCE:
            {
                //if LELIANA_MAIN_ANGRY_ABOUT_MORRIGAN
                //OR
                //if LELIANA_MAIN_ANGRY_ABOUT_ZEVRAN
                int bAngryZevran = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_ANGRY_ABOUT_ZEVRAN, TRUE);
                int bAngryMorrigan = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_ANGRY_ABOUT_MORRIGAN, TRUE);

                // Qwinn:  As noted above, this should be an OR condition, not AND.
                if ( (bAngryZevran == TRUE) || (bAngryMorrigan == TRUE) )
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_MAIN_PLAYER_IN_OTHER_ROMANCE:
            {
                //IF: Romance with Morrigan/Zevran/Alisrair active.
                int bRomanceZevran = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_ROMANCE_ACTIVE, TRUE);
                int bRomanceMorrigan = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_ROMANCE_ACTIVE, TRUE);
                int bRomanceAlistair = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_ACTIVE, TRUE);
                if ( (bRomanceZevran == TRUE) || (bRomanceMorrigan == TRUE) || (bRomanceAlistair == TRUE) )
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_MAIN_FEMALE_AND_ROMANCE_ELIGABLE:
            {
                //IF: PC is female
                //IF NOT: NOT_ELIGIBLE_SAME_SEX
                // Qwinn:  In v2.0 of the fixpack I added an Adore check here, which was bad.  Bad Qwinn.
                // The proper fix is to add a ROMANCE_CUT_OFF check.
                int bFemale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE, TRUE);
                int bNotEligible = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_NOT_ELIGIBLE_SAME_SEX, TRUE);
                int bCutOff = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_CUT_OFF, TRUE);
                if ( bFemale && (!bNotEligible) && (!bCutOff) )
                {
                    nResult = TRUE;
                }
                break;
            }

            case LELIANA_MAIN_PLAYER_MALE_AND_ADORE:
            {
                //IF: LEliana is Adore/Love
                //IF: PC is male
                int bMale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE, TRUE);
                int bAdore = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_ADORE, TRUE);
                if ( (bMale == TRUE) && (bAdore == TRUE) )
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_MAIN_PLAYER_CAN_ASK_ABOUT_ANDRASTE_DEATH:
            {
                //IF: HEARD_ANDRASTE_CHOSEN [leliana_main]
                //IF NOT: HEARD_ANDRASTE_DEATH [lelia_talk]
                int bHeardDeath = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_HEARD_ANDRASTE_DEATH, TRUE);
                int bHeardChosen = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_HEARD_ANDRASTE_CHOSEN, TRUE);
                if ( (bHeardDeath == FALSE) && (bHeardChosen == TRUE) )
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_MAIN_READY_TO_TALK_ABOUT_DALISH:
            {
                //IF: PC is an elf
                //IF: in camp
                //IF: Leliana is warm

                int bElf = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_RACE_ELF, TRUE);
                int bMage = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_CLASS_MAGE, TRUE);
                int bInCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);
                int bWarm = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_WARM, TRUE);

                if ( (bElf && bInCamp && bWarm && !bMage) )
                {
                    nResult = TRUE;
                }

                break;
            }
            case LELIANA_MAIN_READY_TO_SING:
            {
                //IF: IN_PARTY_CAMP [leliana_main]
                // After nature of the beast
                // Heard Minstrel


                int bInCamp         = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);
                int bNatureOfBeast  = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_PLOT_COMPLETED, TRUE);
                int bMinstrel       = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_HEARD_MINSTREL, TRUE);

                if (bInCamp && bNatureOfBeast && bMinstrel)
                {
                    nResult = TRUE;
                }
                break;
            }
            case LELIANA_MAIN_ASSASSIN_ENC_DONE:
            {
                //IF: Assasin killed
                //IF: Assasin released

                int bKilled     = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_ASSASSIN_KILLED, TRUE);
                int bReleased   = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_ASSASSIN_RELEASED, TRUE);

                if (bKilled || bReleased)
                {
                    nResult = TRUE;
                }

                break;
            }

            case LELIANA_MAIN_READY_TO_TEACH_BARD:
            {
                // IF: HEARD_SPY
                // IF: PC has not learned bard class.

                int bSpy        = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_HEARD_SPY, TRUE);
                int bBardKnown  = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_TEACHES_BARD, TRUE);

                if (bSpy && !bBardKnown)
                {
                    nResult = TRUE;
                }

                break;

            }
            case LELIANA_MAIN_READY_TO_SHARE_TALE:
            {
                // IF: HEARD_MINSTREL [leliana_main]
                // IF NOT: LELIANA_MAIN_STORYTELLER

                int bMinstrel        = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_HEARD_MINSTREL, TRUE);
                int bStoryTeller     = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_STORYTELLER, TRUE);

                if (bMinstrel && !bStoryTeller)
                {
                    nResult = TRUE;
                }

                break;
            }
            case LELIANA_MAIN_HEARD_SPY_WARM:
            {
                int bSpy            = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_HEARD_SPY, TRUE);
                int bStillInCamp    = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_STILL_IN_CAMP, TRUE);
                int bWarmEnough;

                // Check if approval is above 25
                if (GetFollowerApproval(oLeliana) >= 25)
                    bWarmEnough = TRUE;

                if (bSpy && bWarmEnough && !bStillInCamp)
                    nResult = TRUE;

                break;
            }

            // Qwinn:  The conversation this triggered ("spies in Orlais)" is inappropriate if you are
            // romancing Leliana, added check.  The Heard Spy check is pointless as she can't be friendly without
            // having heard spy (required for personal quest) but whatever.
            // EDIT:  Upon further consideration, removing the Friendly check, replacing with warm
            case LELIANA_MAIN_HEARD_SPY_FRIENDLY:
            {
                int bHeardSpy  = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_HEARD_SPY);
                // int bFriendly  = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_FRIENDLY, TRUE);
                int bWarm  = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_WARM);
                int bRomance   = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_ACTIVE);
                if (bHeardSpy && bWarm && !bRomance)
                    nResult = TRUE;
                break;
            }

            case LELIANA_MAIN_ASSASSIN_ENC_START:
            {


                int bSpokeOfMarjolaine          = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_SPOKE_ABOUT_MARJ);
                int bSearchingForMarjolaine     = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_SEARCHING_FOR_MARJOLAINE, TRUE);
                int bLelianaHere                = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_PARTY);

                if (bSpokeOfMarjolaine && bLelianaHere && !bSearchingForMarjolaine)
                    nResult = TRUE;


                break;
            }
            case LELIANA_MAIN_TALKED_ABOUT_MOTIVATION_AFTER_TIME:
            {
                int bStillInCamp    = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_STILL_IN_CAMP, TRUE);
                int bMovitation     = WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_TALKED_ABOUT_MOTIVATION, TRUE);
                int bCamp         = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);

                if (!bStillInCamp && bMovitation && bCamp)
                    nResult = TRUE;

                break;
            }

        }

    }

    return nResult;
}