//::///////////////////////////////////////////////
//:: Broken Circle Sidequests
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    These are for incidental things that don't
    have a journal attached to them.
*/
//:://////////////////////////////////////////////
//:: Created By: Ferret
//:: Created On: December 8th, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "plt_gen00pt_party"

#include "cir_constants_h"
#include "cir_functions_h"

#include "plt_cir000pt_encounters"
#include "plt_cir300pt_shapeshifting"
#include "plt_cir000pt_main"
#include "plt_cir000pt_talked_to"
#include "plt_cir000pt_litany"

#include "plt_orz400pt_rogek"

const float ULDRED_DRAIN_TIME = 10.0f;


object GetSacrificedMage();

void UldredHeal(object oUldred);

void SummonAbomination(object oMage);

void SlothShapeshift(object oSloth, object oTarg, int nPlot);

int StartingConditional()
{
    event eParms = GetCurrentEvent();                       // Contains all input parameters
    int nType = GetEventType(eParms);                       // GET or SET call
    string strPlot = GetEventString(eParms, 0);             // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);                 // The bit flag # being affected
    object oParty = GetEventCreator(eParms);                // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0);  // Owner on the conversation, if any
    int nResult = FALSE;                                    // used to return value for DEFINED GET events
    object oPC = GetHero();

    object oTarg;

    plot_GlobalPlotHandler(eParms);                         // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)                        // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);            // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);         // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case GODWIN_EMERGES:                // CIR210_GODWIN_CLOSET
                                                // Godwin comes out of the closet and speaks
                {

                    oTarg = GetObjectByTag(CIR_CR_GODWIN);
                    WR_SetObjectActive(oTarg, TRUE);

                    // Then Godwin speaks
                    UT_Talk(oTarg, oPC);

                    //Never mind. Don't think I need this anymore. Set the closet to non-interactive (Godwin has come out of the closet, haha)
                    //WR_SetObjectActive(GetObjectByTag(CIR_IP_GODWIN_CLOSET), FALSE);
                }
                break;

            case GODWIN_HAS_LYRIUM:             // CIR210_GODWIN
                                                // Godwin gets the Lyrium delivered
                {
                }
                break;

            case GODWIN_KILLED:                 // CIR210_GODWIN
                                                // Godwin gets the Lyrium delivered
                {
                    oTarg = GetObjectByTag(CIR_CR_GODWIN);
                    DestroyObject(oTarg, 0);
                }
                break;

            case DESIRE_AND_TEMPLAR_ATTACK:     // CIR220_DESIRE
                                                // Desire and her ensnared templar attack
                {
                    UT_TeamGoesHostile(CIR_TEAM_3RD_DESIRE_DEMON,TRUE);
                    UT_TeamGoesHostile(CIR_TEAM_3RD_DESIRE_DEMON_CORPSES, TRUE); //And their minions attack too.
                }
                break;

            case DESIRE_AND_TEMPLAR_LEAVE:      // CIR220_DESIRE
                                                // Desire and her ensnared templar leave
                {

                    object  oDemon  =   UT_GetNearestObjectByTag(oPC, "cir220cr_desire_demon");

                    effect  eEffect =   EffectVisualEffect(1101);
                    Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY, eEffect, GetLocation(oDemon), 3.5, oDemon);

                    UT_TeamExit(CIR_TEAM_3RD_DESIRE_DEMON,FALSE);
                }
                break;

            case BLOOD_MAGE_2_ABOMINATION_APPEARS:
                                                // CIR230_BLOOD_MAGE
                                                // An abomination appears. Then they continue to speak.
                {
                    oTarg = GetObjectByTag(CIR_CR_BMS_ABOMINATION);
                    //Show an animation on entry
                    WR_SetObjectActive(oTarg, TRUE, COMBAT_ANIMATION_ENTER_BERSERK, FADE_VFX_TELEPORT);
                    //Fire a talk event after a short pause
                    DelayEvent(0.2, GetObjectByTag(CIR_CR_BLOOD_MAGE_2_1), Event(EVENT_TYPE_CUSTOM_EVENT_01));
                }
                break;

            case BLOOD_MAGE_2_ABOMINATION_ATTACKS:
                                                // CIR230_BLOOD_MAGE
                                                // The abomination attacks the blood mages
                {
                    //Abomination attacks the blood mages
                    object oDemon = GetObjectByTag(CIR_CR_BMS_ABOMINATION);

                    object oBloodMage1 = GetObjectByTag(CIR_CR_BLOOD_MAGE_2_1);
                    object oBloodMage2 = GetObjectByTag(CIR_CR_BLOOD_MAGE_2_2);

                    //Set blood mage to interactive
                    SetObjectInteractive(oBloodMage1, TRUE);

                    SetGroupHostility(GROUP_CIR_BLOOD_MAGE_1, GROUP_CIR_BLOOD_MAGE_2, TRUE);
                    SetGroupHostility(GROUP_CIR_BLOOD_MAGE_1, GROUP_PC, TRUE);
                    SetGroupHostility(GROUP_CIR_BLOOD_MAGE_2, GROUP_PC, TRUE);

                    UT_CombatStart(oDemon, oBloodMage2, TRUE, TRUE); //Force the demon to engage the second blood mage
                    UT_CombatStart(oBloodMage1, oDemon, TRUE, TRUE); //Force the first blood mage to defend the second

                }
                break;

            case CULLEN_CASTS_DISPEL:           // CIR230_CULLEN
                                                // Cullen casts dispel magic - trying to see through an illusion
                {
                }
                break;

            case CULLEN_AND_PC_ARE_ATTACKED_BY_WYNNE:
                                                // CIR230_CULLEN
                                                // Wynne attacks Cullen and the PC
            {

                oTarg = GetObjectByTag(GEN_FL_WYNNE);

                //Remove her from the team
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED, FALSE, TRUE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_CAMP, FALSE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY, FALSE);

                WR_SetFollowerState(oTarg, FOLLOWER_STATE_INVALID);

                //WR_ClearAllCommands(oTarg, TRUE);

                SetTeamId(oTarg, CIR_TEAM_WYNNE_HOSTILE);
                SetGroupId(oTarg, GROUP_HOSTILE);

                WR_SetObjectActive(oTarg, TRUE);

                SetImmortal(oTarg, FALSE); //For some reason Wynne is now immortal on leaving the party.

                //Start combat.
                UT_CombatStart(oTarg, oPC);

                WR_SetPlotFlag( PLT_CIR000PT_TALKED_TO, CULLEN_TALKED_TO, TRUE);

                SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);

                 break;

            }



           case ENRAGED_GROUP_1_RISES:
                {
                    UT_TeamGoesHostile(CIR_TEAM_ENRAGED_1);
                }
                break;

          case ENRAGED_GROUP_2_RISES:
                {
                    UT_TeamGoesHostile(CIR_TEAM_ENRAGED_2);
                }
                break;

          case ENRAGED_GROUP_3_RISES:
                {
                    UT_TeamGoesHostile(CIR_TEAM_ENRAGED_3);
                }
                break;

          case CHARMED_TEMPLARS_INITIAL_RISE:
                {
                    oTarg = GetObjectByTag(CIR_CR_TEMPLAR_DESIRE);
                    UT_Talk(oTarg,oPC);

                    UT_TeamGoesHostile(CIR_TEAM_CHARMED_TEMPLAR, TRUE);
                }
                break;

          case SLOTH_DIALOG:
                {
                    UT_Surrender(oPC);
                    oTarg = GetObjectByTag(CIR_CR_SLOTH_ON_4TH);
                    UT_Talk(oTarg,oPC);
                }
                break;

          case ASH_WRAITH_50_PERCENT:
          { //Now done at 25%
            oTarg = GetObjectByTag(CIR_CR_ASH_WRAITH);
            //Set him inactive
            WR_SetObjectActive(oTarg,FALSE,TRUE,1100);
            //And explode
            Effect_DoOnDeathExplosion(oTarg);
            //Spawn the new creatures
            object [] arShade = GetTeam(CIR_TEAM_ASH_SHADES);
            vector vWraith = GetPosition(oTarg);
            vector vTemp;
            vTemp = GetPosition(arShade[0]);
            FireProjectile(10,vWraith,vTemp);
            vTemp = GetPosition(arShade[1]);
            FireProjectile(10,vWraith,vTemp);
            vTemp = GetPosition(arShade[2]);
            FireProjectile(10,vWraith,vTemp);
            UT_TeamAppears(CIR_TEAM_ASH_SHADES,TRUE);
            break;
          }

        case ULDRED_DRAINS_MAGE:
        {

            if (!WR_GetPlotFlag(PLT_CIR000PT_MAIN,ALL_MAGES_DEAD))       // if there is a mage left to be drained
            {
                object oMage   = GetSacrificedMage();
                object oUldred = GetObjectByTag(CIR_CR_ULDRED);

                event evCustom = Event(EVENT_TYPE_CUSTOM_EVENT_01);

                UldredShield(TRUE);

                //This is Uldred's VFX part of the abominationification of a mage
                DelayEvent(2.0, oUldred, Event(EVENT_TYPE_CUSTOM_EVENT_03));

                //This is the time given until Uldred drains the mage entirely
                DelayEvent(ULDRED_DRAIN_TIME, oUldred, evCustom);

                SetFacingObject(oUldred,oMage);

                //VFX
                ApplyEffectVisualEffect(oUldred, oMage, CIR_ULDRED_DRAIN_EFFECT, EFFECT_DURATION_TYPE_TEMPORARY, ULDRED_DRAIN_TIME);
                //A big obvious VFX
                ApplyEffectVisualEffect(oMage, oMage, CIR_ULDRED_MAGE_DRAIN_EFFECT, EFFECT_DURATION_TYPE_TEMPORARY, ULDRED_DRAIN_TIME);

                if(GetTag(oMage) == CIR_CR_IRVING_FOURTH_FLOOR)
                {
                    //Nice soundset for irving to have when he is being changed
                    PlaySoundSet(oMage, SS_COMBAT_NEAR_DEATH, 1.0f);
                }

                object oWynne = GetObjectByTag(GEN_FL_WYNNE);

                //If Wynne is there and not dying or dead make her bark a string
                if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY) && IsDeadOrDying(oWynne) == FALSE)
                {
                   WR_SetPlotFlag(PLT_CIR000PT_LITANY, ULDRED_DOES_HIS_THING, TRUE);
                   UT_Talk(oWynne, oPC, R"", FALSE); //Talk without resurrection
                }

                //Make Uldred bark a string
                UT_Talk(oUldred, oMage, CIR_DIALOGUE_ULDRED_BARK, FALSE);

                //ApplyEffectVisualEffect(oMage, oUldred, CIR_ULDRIC_DRAIN_EFFECT, EFFECT_DURATION_TYPE_TEMPORARY, 7.0);
            }
            break;
          }


          case ULDRED_BREAK_MAGE_DRAIN:
          {
            object oUldred = UT_GetNearestObjectByTag(oPC, CIR_CR_ULDRED);
            object oMage = GetSacrificedMage();

            //Remove casting effects
            RemoveVisualEffect(oUldred, CIR_ULDRED_DRAIN_EFFECT);
            RemoveVisualEffect(oMage, CIR_ULDRED_DRAIN_EFFECT);
            //Remove a big obvious VFX
            RemoveVisualEffect(oMage, CIR_ULDRED_MAGE_DRAIN_EFFECT);

            //Remove the shield as of now
            UldredShield(FALSE);

            ApplyEffectVisualEffect(oPC, oUldred, CIR_ULDRED_CANCEL, EFFECT_DURATION_TYPE_INSTANT, 1.0);
            ApplyEffectVisualEffect(oPC, oMage, CIR_ULDRED_MIND_BREAK, EFFECT_DURATION_TYPE_TEMPORARY, 5.0);
            WR_SetPlotFlag(PLT_CIR000PT_ENCOUNTERS, ULDRED_DRAINS_MAGE, FALSE);
            ApplyEffectVisualEffect(oPC, oPC, CIR_PC_MIND_BREAK, EFFECT_DURATION_TYPE_INSTANT, 0.0);

            WR_SetPlotFlag(PLT_CIR000PT_ENCOUNTERS,ULDRED_DRAINS_MAGE,FALSE);

            WR_ClearAllCommands(oUldred, TRUE);
            break;
          }


          case ULDRED_FINISHES_DRAIN:
          {
                WR_SetPlotFlag(PLT_CIR000PT_ENCOUNTERS,ULDRED_DRAINS_MAGE,FALSE);
                object oMage = GetSacrificedMage();
                object oUldred = GetObjectByTag(CIR_CR_ULDRED);
                if(IsDeadOrDying(oUldred) == FALSE) //If uldred isn't dead or dying carry on
                {
                    SummonAbomination(oMage);

                    UldredHeal(oUldred);

                    PlaySoundSet(oMage, SS_BERSERK, 1.0f);

                    SetImmortal(oMage, FALSE); //The mage is no longer immortal
                    KillCreature(oMage,oUldred);
                    ApplyEffectVisualEffect(oUldred,oMage,1044,EFFECT_DURATION_TYPE_INSTANT,0.0);
                    // If irving was sacrificed, set all mages dead (check to see if mage is immortal for debug and don't set flag)
                    if (GetTag(oMage) == CIR_CR_IRVING_FOURTH_FLOOR && IsImmortal(oMage) == FALSE)
                    {
                        WR_SetPlotFlag(PLT_CIR000PT_MAIN,ALL_MAGES_DEAD,TRUE,TRUE);
                    }
                }
                break;
          }


          case SLOTH_TRANSFORM_OGRE:
          {
            object oSloth = UT_GetNearestObjectByTag(oPC, CIR_CR_SLOTH_DEMON);
            SignalEvent(oSloth, Event(EVENT_TYPE_CUSTOM_EVENT_01));
            break;
          }
        }
     }

     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
           case PC_IN_LYRIUM_QUEST_HEARD_ABOUT_ADDICTS:
           {
              // Qwinn: Added delivery condition to check, otherwise this is true the first time you talk to Godwin after accepting Rogek's quest
              if((WR_GetPlotFlag(PLT_CIR000PT_ENCOUNTERS, GODWIN_HEARD_ABOUT_ADDICTS) == FALSE) &&
                 (WR_GetPlotFlag(PLT_ORZ400PT_ROGEK, ORZ_ROGEK___PLOT_01_ACCEPTED) == TRUE) &&
                 ((WR_GetPlotFlag(PLT_ORZ400PT_ROGEK, ORZ_ROGEK___PLOT_02_DELIVERY_MADE) == TRUE) ||
                  (WR_GetPlotFlag(PLT_ORZ400PT_ROGEK, ORZ_ROGEK_GODWIN_DENIED_LYRIUM))
                 ))
              {
                nResult = TRUE;
              }
              break;
           }

           //Test to see if the PC is in combat or not
           case PC_IN_COMBAT:
           {
                 nResult = GetCombatState(oPC);
                 break;
           }
        }

    }

    return nResult;
}


void SummonAbomination(object oMage)
{
    object oAbom = UT_GetNearestCreatureByTag(oMage,CIR_CR_SUMMONED_ABOM);
    SetTeamId(oAbom, CIR_TEAM_ULDRED);
    WR_SetObjectActive(oAbom,TRUE,1,1070);

}

//  Determines which mage is being drained by Uldred
object GetSacrificedMage()
{
    object oMage; //The mage we are returning
    if(WR_GetPlotFlag(PLT_CIR000PT_ENCOUNTERS,ULDRED_20_PERCENT) == TRUE)
    {
        //Get a mage if available
         if(!IsInvalidDeadOrDying(GetObjectByTag(CIR_CR_MAGE1)))
         {
            oMage = GetObjectByTag(CIR_CR_MAGE1);
         }
         else if(!IsInvalidDeadOrDying(GetObjectByTag(CIR_CR_MAGE2)))
         {
            oMage  = GetObjectByTag(CIR_CR_MAGE2);
         }
         else if(!IsInvalidDeadOrDying(GetObjectByTag(CIR_CR_MAGE3)))
         {
            oMage  = GetObjectByTag(CIR_CR_MAGE3);
         }
         else
         { //All other mages are dead get irving
            oMage = UT_GetNearestObjectByTag(GetHero(), CIR_CR_IRVING_FOURTH_FLOOR);
         }

    }
    else if(WR_GetPlotFlag(PLT_CIR000PT_ENCOUNTERS,ULDRED_40_PERCENT) == TRUE)
    {
        oMage = GetObjectByTag(CIR_CR_MAGE3);
    }
    else if(WR_GetPlotFlag(PLT_CIR000PT_ENCOUNTERS,ULDRED_60_PERCENT) == TRUE)
    {
        oMage = GetObjectByTag(CIR_CR_MAGE2);
    }
    else if(WR_GetPlotFlag(PLT_CIR000PT_ENCOUNTERS,ULDRED_80_PERCENT) == TRUE)
    {
        oMage = GetObjectByTag(CIR_CR_MAGE1);
    }


    return oMage;
}

void UldredHeal(object oUldred)
{
    float fMax = GetMaxHealth(oUldred);
    float fCurrent = GetCurrentHealth(oUldred);
    float fPercent = fCurrent/fMax;

    //Fully restore mana.
    SetCreatureMana(oUldred, GetCreatureMaxMana(oUldred));
    ApplyEffectVisualEffect(oUldred,oUldred,1543,EFFECT_DURATION_TYPE_INSTANT,0.0);

}

//When sloth shapeshifts we actually replace him with the next model in a queue
//and transport that to his location
// @param oSloth The current sloth demon form
// @param oTarg The next form we want to use
// @param nPlot The plot id for the surrender
void SlothShapeshift(object oSloth, object oTarg, int nPlot)
{
    object oPC = GetHero();
    SetGroupId(oTarg,GROUP_NEUTRAL);
    Rubber_SetHome(oTarg,oSloth);
    location lHome = GetLocation(GetObjectByTag("cir360wp_sloth"));
    //Jump the new form to the current form location
    WR_AddCommand(oSloth, CommandJumpToLocation(lHome),TRUE,TRUE);
    WR_SetObjectActive(oTarg, TRUE, 1, SHAPESHIFT_TRANSFORM_EFFECT);
    SetLocalInt(oTarg, RUBBER_HOME_ENABLED,TRUE);


    lHome = Rubber_GetHome(oTarg);
    WR_AddCommand(oTarg, CommandJumpToLocation(lHome),TRUE,TRUE);
    //WR_AddCommand(oTarg, CommandStartConversation(oPC, CIR_DG_SLOTH_SHAPESHIFT));
    UT_Talk(oTarg, oPC, CIR_DG_SLOTH_SHAPESHIFT);
}