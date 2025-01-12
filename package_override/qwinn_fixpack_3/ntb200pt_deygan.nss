//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Deygan
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: 18/01/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "sys_achievements_h"
#include "plt_ntb220pt_danyla"
#include "plt_ntb100pt_varathorn"
#include "plt_ntb100pt_cammen"
#include "plt_ntb000pt_main"

#include "plt_ntb200pt_deygan"
#include "plt_ntb100pt_mithra"

#include "plt_ntb000pt_generic"
#include "plt_gen00pt_ai"
#include "plt_gen00pt_random"
#include "ntb_constants_h"
#include "plt_gen00pt_backgrounds"
#include "plt_ntb000pt_plot_items"

// Qwinn:  Added this include for the healing check below.
#include "plt_gen00pt_generic_actions"


void NTB_Acv_Check()
{
    ////////////////////////////////////////////////////////////////////////
    // FAB 7/2: Adding achievement for NotB
    ////////////////////////////////////////////////////////////////////////
    int bCondition1 = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE);
    int bCondition2 = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE);
    if ( !bCondition1 && !bCondition2 ) return;

    int nCounter;
    if ( WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_COUPLE_IN_LOVE) ) nCounter++;
    if ( WR_GetPlotFlag(PLT_NTB100PT_VARATHORN, NTB_VARATHORN_IRONBARK_PLOT_DONE) ) nCounter++;
    if ( WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_PC_TOLD_ATHRAS) ) nCounter++;

    if ( nCounter >= 1 ) Acv_Grant(30);
    ////////////////////////////////////////////////////////////////////////
    // End achievement code
    ////////////////////////////////////////////////////////////////////////
}

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
    object oDeygan = UT_GetNearestCreatureByTag(oPC,NTB_CR_DEYGAN);
    object oMithra = UT_GetNearestCreatureByTag(oPC,NTB_CR_MITHRA);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case NTB_DEYGAN_PC_RETURNED_BODY:
            {
                ////////////////////////////////////////////////////////////////////////
                //CUTSCENE: Mithra and other hunters leave and disappear permanently
                ////////////////////////////////////////////////////////////////////////
                UT_TeamAppears(NTB_TEAM_WEST_DEYGEN_RETRIEVERS, FALSE);
                WR_SetObjectActive(oDeygan,FALSE);
                NTB_Acv_Check();

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_4a);

                break;
            }
            case NTB_DEYGAN_RETURNED_ALIVE_WITH_PC:
            {
                ////////////////////////////////////////////////////////////////////////
                //CUTSCENE: 2 hunters approach and take Deygan.
                //They all disappear, including Mithra.
                //
                ////////////////////////////////////////////////////////////////////////
                WR_SetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_ALIVE_DEYGAN,FALSE);
                WR_SetObjectActive(oDeygan,FALSE);
                UT_TeamAppears(NTB_TEAM_WEST_DEYGEN_RETRIEVERS, FALSE);
                NTB_Acv_Check();

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_4a);

                break;
            }
            case NTB_DEYGAN_FALLS_UNCONSCIOUS:
            {
                ////////////////////////////////////////////////////////////////////////
                // Deygan goes unconscious. (Maybe in staging)
                ////////////////////////////////////////////////////////////////////////
                command cUnconscious = CommandPlayAnimation(BASE_ANIMATION_DEAD_1);
                WR_AddCommand(oDeygan,cUnconscious);
                break;
            }
            case NTB_DEYGAN_KILLED_BY_PC:
            {
                ////////////////////////////////////////////////////////////////////////
                //BLANK CUTSCENE: ntb200cs_pc_kills_deygan
                //You cover the hunter's mouth and nose with your hands.
                //His eyes go wide and he struggles weakly,
                //but within moments he falls unconscious and quickly dies.
                ////////////////////////////////////////////////////////////////////////
                WR_SetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_DIED,TRUE,TRUE);
                break;
            }
            case NTB_DEYGAN_PC_CAST_HEALING_SPELL:
            {
                ////////////////////////////////////////////////////////////////////////
                //CUTSCENE: pc casts a healing spell on Deygan who stands up
                //Action: cast healing spell
                ////////////////////////////////////////////////////////////////////////

                // Qwinn:  Disabled this as you wouldn't cast the spell till after conversation done.
                // Ability_UseAbilityWrapper(oPC,ABILITY_SPELL_HEAL);
                break;
            }
            case NTB_DEYGAN_HEALED_BY_PC:
            {
                ////////////////////////////////////////////////////////////////////////
                //CUTSCENE: Deygan returns to camp
                //ACTION: bring Deygan back to the camp
                ////////////////////////////////////////////////////////////////////////
                WR_SetObjectActive(oDeygan,FALSE);
                NTB_Acv_Check();

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_4a);

                break;
            }
            case NTB_DEYGAN_EQUIPMENT_LOOTED:
            {
                ////////////////////////////////////////////////////////////////////////
                //ACTION: give player Deygan's equipment (in rewards.2da)
                //he still possesses a blood-encrusted blade and most of his arrows.
                //The hunter also still possesses his boots as well as a belt pouch
                //with various small personal items in it,
                //including a small figurine carved from bone.
                ////////////////////////////////////////////////////////////////////////
                // Qwinn:  The rewards.2da does not give the player the arrows, though they can be looted off his body
                // Adding it here.
                UT_AddItemToInventory(R"gen_im_wep_rng_amm_elf.uti",7);
                int nFigurine = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_GETS_DEYGAN_FIGURINE,TRUE);
                if(nFigurine == FALSE)
                {
                    WR_SetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_GETS_DEYGAN_FIGURINE,TRUE,TRUE);
                }

                break;
            }
            case NTB_DEYGAN_PICK_UP_LIVE_DEYGAN:
            {
                ////////////////////////////////////////////////////////////////////////
                //ACTION: remove Deygan
                //If the party returns to the dalish area while carryin the body,
                //then they will be met by Mithra and two hunters.
                //Mithra will init dialog.
                ////////////////////////////////////////////////////////////////////////
                //WR_SetObjectActive(oDeygan,FALSE);
                WR_SetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_ALIVE_DEYGAN,TRUE,TRUE);

                //Activate Mithra
                object oMithra          = UT_GetNearestCreatureByTag(oPC, NTB_CR_MITHRA);
                object oMaleHunter      = UT_GetNearestCreatureByTag(oPC, NTB_CR_ELF_MALE);
                object oFemaleHunter    = UT_GetNearestCreatureByTag(oPC, NTB_CR_ELF_FEMALE_03);

                UT_TeamAppears(NTB_TEAM_WEST_DEYGEN_RETRIEVERS, TRUE);

                UT_LocalJump(oPC, NTB_WP_WEST_DEYGEN_RETURN, TRUE, TRUE, FALSE, TRUE);

                UT_Talk(oMithra, oPC);
                //UT_PCJumpOrAreaTransition(NTB_AR_DALISH_CAMP,NTB_WP_FROM_FOREST);
                break;
            }
            case NTB_DEYGAN_REWARDS_PC:
            {
                ////////////////////////////////////////////////////////////////////////
                //ACTION: if the pc is dalish, Deygan gives a cloak,
                //otherwise he gives a gem
                ////////////////////////////////////////////////////////////////////////
                int nDalish = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_ELF_DALISH,TRUE);
                if(nDalish == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_GIVES_CLOAK_REWARD,TRUE,TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_GIVES_GEM_REWARD,TRUE,TRUE);
                }
                break;
            }
            case NTB_DEYGAN_PICK_UP_DEAD_DEYGAN:
            {
                ////////////////////////////////////////////////////////////////////////
                //ACTION: remove Deygan
                //If the party returns to the dalish area while carryin the body,
                //then they will be met by Mithra and two hunters.
                //Mithra will init dialog.
                ////////////////////////////////////////////////////////////////////////
                WR_SetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_DEAD_DEYGAN,TRUE,TRUE);
                //WR_SetObjectActive(oDeygan,FALSE);
                //Activate Mithra
                object oMithra          = UT_GetNearestCreatureByTag(oPC, NTB_CR_MITHRA);
                object oMaleHunter      = UT_GetNearestCreatureByTag(oPC, NTB_CR_ELF_MALE);
                object oFemaleHunter    = UT_GetNearestCreatureByTag(oPC, NTB_CR_ELF_FEMALE_03);

                UT_TeamAppears(NTB_TEAM_WEST_DEYGEN_RETRIEVERS, TRUE);

                //UT_LocalJump(oPC, NTB_WP_WEST_DEYGEN_RETURN, TRUE, TRUE, FALSE, TRUE);

                UT_Talk(oMithra, oPC);
                break;
            }
            case NTB_DEYGAN_PC_RETURNS_DEYGAN_FIGURINE:
            {
                ////////////////////////////////////////////////////////////////////////
                //ACTION: take figurine from pc if possessed
                ////////////////////////////////////////////////////////////////////////
                object oFigurine = GetItemPossessedBy(oPC,NTB_IM_DEYGAN_FIGURINE);
                if(IsObjectValid(oFigurine))
                {
                    WR_DestroyObject(oFigurine);
                }
                break;
            }
            case NTB_DEYGAN_LEAVES:
            {
                ////////////////////////////////////////////////////////////////////////
                //CUTSCENE: Deygans walks to an araval door and disappears
                ////////////////////////////////////////////////////////////////////////
                WR_SetObjectActive(oDeygan,FALSE);
                break;
            }
            case NTB_DEYGAN_MITHRA_PROMISED_REWARD_FOR_RETURNED_FIGURINE:
            {
                ////////////////////////////////////////////////////////////////////////
                //ACTION: Mithra takes the figurine
                ////////////////////////////////////////////////////////////////////////
                WR_SetPlotFlag(PLT_NTB100PT_MITHRA,NTB_MITHRA_TAKES_FIGURINE_FROM_PC,TRUE,TRUE);
                break;
            }
            case NTB_DEYGAN_DIED:
            {
                ////////////////////////////////////////////////////////////////////////
                // Play dead animation
                ////////////////////////////////////////////////////////////////////////
                command cDead = CommandPlayAnimation(BASE_ANIMATION_DEAD_1);
                WR_AddCommand(oDeygan,cDead);
                break;
            }
            case NTB_DEYGAN_PC_LEAVES_BODY:
            {
                //Check if Deygen should be dead
                if (WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_DIED) == TRUE)
                {

                    object oDeadDeygen = UT_GetNearestCreatureByTag(oPC, NTB_CR_DEYGAN_DEAD);
                    WR_SetObjectActive(oDeygan, FALSE);
                    WR_SetObjectActive(oDeadDeygen, TRUE);

                    WR_SetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_BODY_LEFT_IN_FOREST, TRUE, TRUE);

                    //if already looted - should not be interactive
                    if (WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_EQUIPMENT_LOOTED) == TRUE)
                    {
                        SetObjectInteractive(oDeadDeygen, FALSE);
                        WR_SetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_BODY_LEFT_IN_FOREST, TRUE, TRUE);
                    }
                }

                break;

            }

            case NTB_DEYGAN_BODY_LEFT_IN_FOREST:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_4a);

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case NTB_DEYGAN_NOT_DEAD_AND_NOT_REVIVED:
            {
                int nDead = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_DIED,TRUE);
                int nRevived = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_REVIVED_BY_PC,TRUE);
                ////////////////////////////////////////////////////////////////////////
                // if Deygan not dead
                //and not revived
                ////////////////////////////////////////////////////////////////////////
                if((nDead == FALSE) && (nRevived == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_DEYGAN_NOT_DEAD_AND_PC_HAS_HEALING_AND_HAS_EXAMINED:
            {
                //
                int nExamined = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_EXAMINED_BY_PC,TRUE);
                // Qwinn:  The following check for healing doesn't work, but did find one that does.
                // int nHealing = WR_GetPlotFlag(PLT_GEN00PT_AI,GEN_HAS_HEALING,TRUE);
                // As Deygan has dialogue for non mage PC's once healed, will allow Morrigan or Wynne to cast it too
                int nHealing = ( WR_GetPlotFlag(PLT_GEN00PT_GENERIC_ACTIONS,GEN_PC_HAS_HEALING) ||
                                 WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_WYNNE_IN_PARTY));
                if ((nHealing == FALSE) && WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_MORRIGAN_IN_PARTY))
                {
                   object oMorrigan = UT_GetNearestCreatureByTag(oPC,GEN_FL_MORRIGAN);
                   if(HasAbility(oMorrigan, ABILITY_SPELL_HEAL) || HasAbility(oMorrigan, ABILITY_SPELL_CURE) ||
                      HasAbility(oMorrigan, ABILITY_SPELL_PURIFY) || HasAbility(oMorrigan, ABILITY_SPELL_REGENERATION))
                     nHealing = TRUE;
                }
                int nDead = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_DIED,TRUE);
                ////////////////////////////////////////////////////////////////////////
                // if PC examined Deygan
                // and pc has healing
                // and Deygan not dead
                ////////////////////////////////////////////////////////////////////////
                if((nDead == FALSE) && (nExamined == TRUE) && (nHealing == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_DEYGAN_PC_EXPLORED_RUINS_AND_NOT_RETURNED_DEYGAN:
            {
                //
                int nRuins = WR_GetPlotFlag(PLT_NTB000PT_GENERIC,NTB_GENERIC_PC_HAS_EXPLORED_RUINS,TRUE);
                int nAlive = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_RETURNED_ALIVE_WITH_PC,TRUE);
                int nDead = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_PC_RETURNED_BODY,TRUE);
                ////////////////////////////////////////////////////////////////////////
                // if Deygan has explored ruins
                // and Deygan hasn't been returned yet
                // and Deygan isn't dead
                ////////////////////////////////////////////////////////////////////////
                if((nRuins == TRUE) && ((nAlive == FALSE) && (nDead == FALSE)))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_DEYGAN_PC_RETURNED_BODY_AND_RANDOM:
            {
                int nBody = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_PC_RETURNED_BODY,TRUE);
                int nRandom = WR_GetPlotFlag(PLT_GEN00PT_RANDOM,GEN_R50,TRUE);
                ////////////////////////////////////////////////////////////////////////
                //EVENT_PC_RETURNED_DEYGANS_BODY (Deygan)
                //*AND* 50%
                ////////////////////////////////////////////////////////////////////////
                if((nBody == TRUE) && (nRandom == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_DEYGAN_HEALED_OR_RETURNED_ALIVE_AND_RANDOM:
            {
                int nAlive = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_RETURNED_ALIVE_WITH_PC,TRUE);
                int nHeal = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_HEALED_BY_PC,TRUE);
                int nRandom = WR_GetPlotFlag(PLT_GEN00PT_RANDOM,GEN_R50,TRUE);
                ////////////////////////////////////////////////////////////////////////
                // EVENT_PC_RETURNED_DEYGAN_ALIVE (Deygan)
                //* OR*  EVENT_PC_HEALED_DEYGAN (Deygan) ]
                //*AND* 50%
                ////////////////////////////////////////////////////////////////////////
                if(((nAlive == TRUE) || (nHeal == TRUE)) && (nRandom == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_DEYGAN_HEALED_OR_RETURNED_ALIVE:
            {
                int nAlive = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_RETURNED_ALIVE_WITH_PC,TRUE);
                int nHeal = WR_GetPlotFlag(PLT_NTB200PT_DEYGAN,NTB_DEYGAN_HEALED_BY_PC,TRUE);
                ////////////////////////////////////////////////////////////////////////
                //[ EVENT_PC_RETURNED_DEYGAN_ALIVE (Deygan)
                //* OR*  EVENT_PC_HEALED_DEYGAN (Deygan) ]
                ////////////////////////////////////////////////////////////////////////
                if((nAlive == TRUE) || (nHeal == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
        }
    }

    return nResult;
}