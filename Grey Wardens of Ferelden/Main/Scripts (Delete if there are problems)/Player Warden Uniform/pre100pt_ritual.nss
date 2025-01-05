//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 21st, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "cutscenes_h"
#include "pre_objects_h"
#include "party_h"

#include "sys_ambient_h"

#include "plt_pre100pt_ritual"
#include "plt_gen00pt_party"
#include "plt_pre100pt_generic"
#include "plt_gen00pt_backgrounds"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    int nGetResult = FALSE; // used to return value for DEFINED GET events

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    object oPC = GetHero();

    int iPCclass = GetCreatureCoreClass(oPC);

    object oEnchanter = UT_GetNearestCreatureByTag(oPC, PRE_CR_ULDRED);
    object oGrandCleric = UT_GetNearestCreatureByTag(oPC, PRE_CR_GRAND_CLERIC);
    object oCailan = UT_GetNearestCreatureByTag(oPC, PRE_CR_CAILAN);
    object oLoghain = UT_GetNearestCreatureByTag(oPC, PRE_CR_LOGHAIN);
    object oMap = UT_GetNearestObjectByTag(oPC, PRE_IP_STRATEGY_MAP);

    object oJory        = UT_GetNearestCreatureByTag(oPC, PRE_CR_JORY);
    object oDuncan      = UT_GetNearestCreatureByTag(oPC, PRE_CR_DUNCAN);
    object oDaveth      = UT_GetNearestCreatureByTag(oPC, PRE_CR_DAVETH);
    object oAlistair    = UT_GetNearestCreatureByTag(oPC, GEN_FL_ALISTAIR);
    object oDog         = UT_GetNearestCreatureByTag(oPC, GEN_FL_DOG);
    object oRitualCup   = UT_GetNearestObjectByTag(oPC, PRE_IP_RITUAL_CUP);
    object oRitualDoors = UT_GetNearestObjectByTag(oPC, PRE_IP_RITUAL_DOORS);
    object oWildsGate   = UT_GetNearestObjectByTag(oPC, PRE_IP_WILDS_GATE);

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case PRE_RITUAL_START:
            {

                if (nValue == 1)
                {
                    // Jump PC, Jory, Daveth, Alistairto the ritual area. Set ritual stage for the night and
                    // Jory inits dialog while Duncan is still not present.
                    // Fire Alistair, Daveth and Jory (Alistair rejoins at the 'beacon' plot

                    // CUTSCENE: fade in

                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                    WR_SetObjectActive(oAlistair, TRUE);


                    if (ReadIniEntry("DebugOptions","E3Mode") == "1" ||
                    GetLocalInt(GetModule(), DEMO_ACTIVE) == TRUE)
                    {
                        UT_FireFollower(oDaveth, TRUE, FALSE);
                    }
                    else // NOT DEMO!!!

                    WR_SetObjectActive(oRitualCup, TRUE);

                    SetPlaceableState(oRitualDoors, PLC_STATE_DOOR_LOCKED);

                    // Set up Jory's weapons to suit the cutscene (since the player
                    // may have messed with them while he was a party member)
                    object oMain = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oJory);
                    object oOffHand = GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oJory);
                    // switch to melee weapon set, if necessary (and if possible)
                    if(GetItemType(oMain) != ITEM_TYPE_WEAPON_MELEE)
                    {
                        int nMeleeSet = Items_GetMeleeWeaponSet(oJory);
                        if(nMeleeSet > -1)
                        {
                            SwitchWeaponSet(oJory, nMeleeSet);
                        }
                        else
                        {
                            // Ok, he doesn't have a melee weapon. What kind
                            // of player would steal a guy's weapon? Geez.
                            UnequipItem(oJory, oMain);
                            UnequipItem(oJory, oOffHand);
                            object oWeapon = UT_AddItemToInventory(PRE_IM_JORYS_SWORD, 1, oJory);
                            EquipItem(oJory, oWeapon, INVENTORY_SLOT_MAIN);
                        }
                    }
                    // unequip shield (if equipped)
                    if(GetItemType(oOffHand) == ITEM_TYPE_SHIELD)
                    {
                        UnequipItem(oJory, oOffHand);
                    }

                    // Get rid of Duncan's weapons by switching to empty weapon set
                    SwitchWeaponSet(oDuncan);

                    UT_Talk(oJory, oPC);

                    // CUTSCENE: fade out
                }
                break;
            }
            case PRE_RITUAL_DUNCAN_JOINS:
            {
                if (nValue == 1)
                {
                    UT_Talk(oDuncan, oPC);
                }
                break;
            }
            case PRE_RITUAL_CUTSCENE:
            {

                if (nValue == 1)
                {
                    // CUTSCENE: play the big cutscene
                    if (GetCreatureRacialType(oPC) == 1)
                    {
                        CS_LoadCutscene(CUTSCENE_PRE_JOINING_RITUAL_DM, PLT_PRE100PT_RITUAL,
                        PRE_RITUAL_CUTSCENE_ENDS, PRE_CR_DUNCAN);

                    WR_SetObjectActive(oRitualCup, FALSE);
                    }

                    if (GetCreatureRacialType(oPC) == 2 && GetCreatureGender(oPC) == 1)
                    {
                        CS_LoadCutscene(CUTSCENE_PRE_JOINING_RITUAL_EM, PLT_PRE100PT_RITUAL,
                        PRE_RITUAL_CUTSCENE_ENDS, PRE_CR_DUNCAN);

                    WR_SetObjectActive(oRitualCup, FALSE);
                    }

                    if (GetCreatureRacialType(oPC) == 2 && GetCreatureGender(oPC) == 2)
                    {
                        CS_LoadCutscene(CUTSCENE_PRE_JOINING_RITUAL_EF, PLT_PRE100PT_RITUAL,
                        PRE_RITUAL_CUTSCENE_ENDS, PRE_CR_DUNCAN);

                    WR_SetObjectActive(oRitualCup, FALSE);
                    }

                    if (GetCreatureRacialType(oPC) == 3 && GetCreatureGender(oPC) == 1)
                    {
                        CS_LoadCutscene(CUTSCENE_PRE_JOINING_RITUAL_HM, PLT_PRE100PT_RITUAL,
                        PRE_RITUAL_CUTSCENE_ENDS, PRE_CR_DUNCAN);

                    WR_SetObjectActive(oRitualCup, FALSE);
                    }

                    if (GetCreatureRacialType(oPC) == 3 && GetCreatureGender(oPC) == 2)
                    {
                        CS_LoadCutscene(CUTSCENE_PRE_JOINING_RITUAL_HF, PLT_PRE100PT_RITUAL,
                        PRE_RITUAL_CUTSCENE_ENDS, PRE_CR_DUNCAN);

                    WR_SetObjectActive(oRitualCup, FALSE);
                    }

/*                  CS_LoadCutscene(CUTSCENE_PRE_JOINING_RITUAL, PLT_PRE100PT_RITUAL,
                        PRE_RITUAL_CUTSCENE_ENDS, PRE_CR_DUNCAN);

                    WR_SetObjectActive(oRitualCup, FALSE);
*/

                    // End of cutscene: Duncan inits dialog (handled in cutscene-end script)
                }
                break;
            }
            case PRE_RITUAL_CUTSCENE_ENDS:
            {
                // Deactivate Jory and Daveth - they are placed
                // in the cutscene, they'll still appear there, but this
                // ensures they'll be gone after the scene has played.

                    UT_FireFollower(oDaveth, TRUE);

                    UT_FireFollower(oJory, TRUE);
                WR_SetObjectActive(oDaveth, FALSE);
                WR_SetObjectActive(oJory, FALSE);

                break;
            }
            case PRE_RITUAL_END:
            {
                if (nValue == 1)
                {
                    // Restore Duncan's weapons
                    //SwitchWeaponSet(oDuncan);

                    // Duncan walks to the strategy meeting.
                    // Alistair walks to the campfire

                    // THESE CANT BE STATIC!!! - otherwise Alistair will be stuck still trying to move after the meeting
                    UT_QuickMoveObject(oAlistair, "6", FALSE, TRUE, FALSE, FALSE);
                    UT_QuickMoveObject(oDuncan, "4", FALSE, TRUE, TRUE, FALSE);
                    //UT_LocalJump(oAlistair, PRE_WP_DUNCANS_FIRE);
                    //UT_LocalJump(oDuncan, PRE_WP_MEETING_DUNCAN);


                    SetPlaceableState(oRitualDoors, PLC_STATE_DOOR_OPEN);
                    SetPlaceableState(oWildsGate, PLC_STATE_DOOR_LOCKED);

                    // Enable strategists and jump them to the proper location

                    WR_SetObjectActive(oCailan, TRUE);
                    WR_SetObjectActive(oLoghain, TRUE);
                    WR_SetObjectActive(oEnchanter, TRUE);
                    WR_SetObjectActive(oGrandCleric, TRUE);
                    WR_SetObjectActive(oMap, TRUE);

                    UT_LocalJump(oCailan, PRE_WP_MEETING_CAILAN);
                    UT_LocalJump(oLoghain, PRE_WP_MEETING_LOGHAIN);
                    UT_LocalJump(oEnchanter, PRE_WP_MEETING_ENCHANTER);
                    UT_LocalJump(oGrandCleric, PRE_WP_MEETING_GRAND_CLERIC);

                    WR_SetPlotFlag(PLT_PRE100PT_GENERIC, PRE_GENERIC_DUNCAN_WAIT_AT_FIRE_BEFORE_STRATEGY_MEETING, TRUE, TRUE);

                    // if PC is human noble, rehire dog
                    if (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE, TRUE))
                    {
                        // Stop any ambient behaviour before adding him back to the party.
                        // adding dog only if not running a demo
                        if (ReadIniEntry("DebugOptions","E3Mode") != "1" &&
                            GetLocalInt(GetModule(), DEMO_ACTIVE) == FALSE)
                        {
                            Ambient_Stop(oDog);
                            WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY, TRUE, TRUE);
                        }
                        else // DEMO ACTIVE
                        {
                            // add Daveth instead of Dog
                            WR_SetObjectActive(oDog, FALSE);
                            //WR_ClearAllCommands(oAlistair);
                            //WR_ClearAllCommands(oDuncan);
                            //WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                            //WR_SetPlotFlag(PLT_PRE100PT_GENERIC, PRE_GENERIC_STRATEGY_MEETING_END, TRUE, TRUE);
                        }
                    }

                    //Spawn uniform

                    if (iPCclass == 1) //for warrior PC
                    {
                        UT_AddItemToInventory(R"gen_im_arm_cht_hvy_wmd.uti", 1);
                        UT_AddItemToInventory(R"gen_im_arm_glv_hvy_wmd.uti", 1);
                        UT_AddItemToInventory(R"gen_im_arm_bot_hvy_wmd.uti", 1);
                        UT_AddItemToInventory(R"gen_im_arm_hel_hvy_wmd.uti", 1);
                        UT_AddItemToInventory(R"gen_im_arm_shd_kit_wrd.uti", 1);
                        UT_AddItemToInventory(R"gen_im_wep_mel_lsw_war.uti", 2);
                        UT_AddItemToInventory(R"gen_im_wep_mel_gsw_war.uti", 1);
                        UT_AddItemToInventory(R"gen_im_wep_mel_gsw_wrd.uti", 1);
                        UT_AddItemToInventory(R"gen_im_wep_mel_dag_war.uti", 1);
                    }

                    if (iPCclass == 2) //for mage PC
                    {
                        UT_AddItemToInventory(R"gen_im_arm_cht_lgt_wrb.uti", 1);
                        UT_AddItemToInventory(R"gen_im_arm_glv_lgt_wrb.uti", 1);
                        UT_AddItemToInventory(R"gen_im_arm_bot_lgt_wrb.uti", 1);
                        UT_AddItemToInventory(R"gen_im_arm_hel_lgt_wrb.uti", 1);
                        UT_AddItemToInventory(R"gen_im_wep_mag_sta_war.uti", 1);
                    }

                    if (iPCclass == 3) //for rogue PC
                    {
                        UT_AddItemToInventory(R"gen_im_arm_cht_med_wlt.uti", 1);
                        UT_AddItemToInventory(R"gen_im_arm_glv_med_wlt.uti", 1);
                        UT_AddItemToInventory(R"gen_im_arm_bot_med_wlt.uti", 1);
                        UT_AddItemToInventory(R"gen_im_arm_hel_med_wlt.uti", 1);
                        UT_AddItemToInventory(R"gen_im_wep_rng_lbw_war.uti", 1);
                        UT_AddItemToInventory(R"gen_im_wep_mel_lsw_war.uti", 1);
                        UT_AddItemToInventory(R"gen_im_wep_mel_dag_war.uti", 2);
                    }
                }
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {



        }

    }

    return nGetResult;
}