// Qwinn created this script from her previous Zathrian script and adding
// case EVENT_TYPE_CUSTOM_COMMAND_COMPLETE.

//::///////////////////////////////////////////////
//:: Creature Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature events for Zathrian
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: 17/01/08
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "ntb_constants_h"
#include "plt_ntb000pt_main"
#include "plt_ntb000pt_plot_items"
#include "plt_ntb220pt_danyla"

// Qwinn added these includes
#include "plt_ntb100pt_lanaya"
#include "plt_qwinn"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;
    string sTag = GetTag(OBJECT_SELF);

    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creatures suffered 1 or more points of damage in a
        //       single attack
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DAMAGED:
        {
            object oDamager = GetEventCreator(ev);
            int nDamage = GetEventInteger(ev, 0);
            int nDamageType = GetEventInteger(ev, 1);

            int nAttack = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ATTACK_ZATHRIAN_AT_ALTAR,TRUE);
            int nAttackLady = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ATTACK_LADY_OF_FOREST,TRUE);
            float fCurrent = GetCurrentHealth(OBJECT_SELF);
            // -----------------------------------------------------
            // if you are attacking Zathrian in the Lady's Lair
            // -----------------------------------------------------
            if((nAttack == TRUE) && (sTag == NTB_CR_ZATHRIAN))
            {
                int nOnce = GetLocalInt(OBJECT_SELF,CREATURE_DO_ONCE_A);
                // -----------------------------------------------------
                // if Zathrian's hit points are too low
                // -----------------------------------------------------
                if((fCurrent <= NTB_HIT_POINTS_LOW) && (nOnce == FALSE))
                {
                    object oLady = UT_GetNearestCreatureByTag(oPC,NTB_CR_LADY);
                    object oWitherfang = UT_GetNearestCreatureByTag(oPC,NTB_CR_WHITE_WOLF);
                    object oDoorLady = UT_GetNearestObjectByTag(oPC,NTB_IP_DOOR_LADY);
                    object oDoorShortcut = UT_GetNearestObjectByTag(oPC,NTB_IP_DOOR_SHORTCUT);
                    object oGolem1 = UT_GetNearestCreatureByTag(oPC, "ntb340cr_golem_a");
                    object oGolem2 = UT_GetNearestCreatureByTag(oPC, "ntb340cr_golem_b");
                    object oGolem3 = UT_GetNearestCreatureByTag(oPC, "ntb340cr_golem_c");

                    SetLocalInt(OBJECT_SELF,CREATURE_DO_ONCE_A,TRUE);
                    Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"ntb100cr_zathrian.nss","Zathrian surrenders");

                    // -----------------------------------------------------
                    // Witherfang disappears, the Lady appears
                    // The doors out of the room unlock
                    // The various teams stop fighting each other
                    // The summoned shades disappear
                    // Zathrian surrenders
                    // -----------------------------------------------------
                    WR_SetObjectActive(oLady,TRUE);
                    WR_SetObjectActive(oWitherfang,FALSE);
                    WR_SetObjectActive(oGolem1, FALSE);
                    WR_SetObjectActive(oGolem2, FALSE);
                    WR_SetObjectActive(oGolem3, FALSE);
                    SetPlaceableState(oDoorLady,PLC_STATE_DOOR_UNLOCKED);
                    SetPlaceableState(oDoorShortcut,PLC_STATE_DOOR_UNLOCKED);
                    UT_TeamGoesHostile(NTB_TEAM_WEREWOLF_LAIR_GOLEM,FALSE);
                    UT_TeamGoesHostile(NTB_TEAM_WEREWOLF_LAIR_SHADES,FALSE);
                    UT_TeamAppears(NTB_TEAM_WEREWOLF_LAIR_SHADES,FALSE);
                    UT_Surrender(OBJECT_SELF);
                }
            }
            // -----------------------------------------------------
            // if you are attacking the lady of the forest with Zathrian
            // and Zathrian's hit points get too low
            // -----------------------------------------------------
            if((nAttackLady == TRUE) && (sTag == NTB_CR_ZATHRIAN))
            {
                int nOnce = GetLocalInt(OBJECT_SELF,CREATURE_DO_ONCE_B);
                if((fCurrent <= NTB_HIT_POINTS_LOW) && (nOnce == FALSE))
                {
                    SetLocalInt(OBJECT_SELF,CREATURE_DO_ONCE_B,TRUE);
                    Log_Trace(LOG_CHANNEL_COMBAT_DAMAGE,"ntb100cr_zathrian.nss","Zathrian defeated");

                    // -----------------------------------------------------
                    // Sets Zathrian neutral and sleeping (so he looks unconcious)
                    // -----------------------------------------------------
                    SetGroupId(OBJECT_SELF,GROUP_NEUTRAL);
                    ForceSleepStart(OBJECT_SELF);
                }
            }
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creature dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DEATH:
        {
            object oKiller = GetEventCreator(ev);
            int nAttack = WR_GetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_ATTACKS_ZATHRIAN_AT_ALTAR_AFTER_WITHERFANG,TRUE);
            int nTeam = GetTeamId(OBJECT_SELF);
            Log_Trace(LOG_CHANNEL_COMBAT_DEATH,"ntb100cr_zathrian." + GetTag(OBJECT_SELF),IntToString(nTeam)+ ": Team Number");

            // -----------------------------------------------------
            //  if the PC attacked Zathrian in the Lady's lair
            // -----------------------------------------------------
            if((nAttack == TRUE) && (sTag == NTB_CR_ZATHRIAN))
            {
                object oHeart = GetItemPossessedBy(oPC,NTB_IM_WITHERFANG_HEART);
                // -----------------------------------------------------
                // The flag EVENT_ZATHRIAN_KILLED_BY_PC should be set
                // when Zathrian dies at this point.
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_ZATHRIAN_KILLED_BY_PC,TRUE,TRUE);
                // -----------------------------------------------------
                // Zathrian should drop the heart when dead
                // if the PC doesn't already have it
                // -----------------------------------------------------
                if(!IsObjectValid(oHeart))
                {
                    WR_SetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_GETS_WITHERFANG_HEART,TRUE,TRUE);
                }
            }
            if(sTag == NTB_CR_ATHRAS)
            {
                WR_SetPlotFlag(PLT_NTB220PT_DANYLA,NTB_DANYLA_ATHRAS_DEAD,TRUE,TRUE);
            }
            break;
        }
        case EVENT_TYPE_CUSTOM_COMMAND_COMPLETE:    
        {

            object oActor = GetEventCreator(ev); // creature acting
            int nLastCommand = GetEventInteger(ev, 0); // Type of the last command

            object oZathrian = UT_GetNearestCreatureByTag(oPC,NTB_CR_ZATHRIAN);
            object oLanaya = UT_GetNearestCreatureByTag(oPC,NTB_CR_LANAYA);
            int nLanayaTalk = WR_GetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_SPEAKS_TO_ZATHRIAN);
            int nLanayaReturn = WR_GetPlotFlag(PLT_NTB100PT_LANAYA, NTB_LANAYA_RETURNS_TO_POST_AFTER_ZATHRIAN);
            if (nLastCommand == COMMAND_TYPE_MOVE_TO_OBJECT && nLanayaTalk )
            {
                WR_SetPlotFlag(PLT_QWINN, NTB_LANAYA_PC_CAN_OPEN_CHEST,TRUE);
                UT_Talk(oLanaya,oPC);
                nEventHandled = TRUE;
            } else
            if (nLastCommand == COMMAND_TYPE_MOVE_TO_OBJECT && nLanayaReturn )
            {
                SetObjectInteractive(oLanaya, TRUE);
                nEventHandled = TRUE;
            }
            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}