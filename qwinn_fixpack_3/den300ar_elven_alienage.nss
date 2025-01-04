//::///////////////////////////////////////////////
//:: den300ar_elven_alienage
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Handles global area events for the alienage
*/
//:://////////////////////////////////////////////
//:: Created By: Craig
//:: Created On: February 11, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "2da_constants_h"
#include "campaign_h"
#include "lit_constants_h"
#include "den_constants_h"
#include "party_h"

#include "plt_denpt_slave_trade"
#include "plt_gen00pt_backgrounds"
#include "plt_den300pt_enc_beggar"
#include "plt_den300pt_last_request"
#include "plt_den300pt_generic"

#include "plt_lite_mage_places"
#include "plt_lite_fite_conscripts"
#include "plt_lite_mabari_dom"
#include "plt_gen00pt_party"
#include "plt_genpt_leliana_main"
#include "plt_lite_fite_grease"
#include "plt_den300pt_some_wicked"

#include "sys_audio_h"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;

    object oVeras = UT_GetNearestCreatureByTag(oPC, DEN_CR_VERAS);
    object oAlleyGuard = UT_GetNearestCreatureByTag(oPC, DEN_CR_ALLEY_GUARD);
    object oOpenGates = UT_GetNearestObjectByTag(oPC, DEN_IP_ALIEANGE_GATES_OPEN);
    object oClosedGates = UT_GetNearestObjectByTag(oPC, DEN_IP_ALIEANGE_GATES_CLOSED);
    object oAlienageGuard = UT_GetNearestCreatureByTag(oPC, DEN_CR_ALIENAGE_GUARD);
    object oValendriansDoor = UT_GetNearestObjectByTag(oPC, DEN_IP_VALENDRIANS_ENTRANCE);
    object oElfThug1 = UT_GetNearestCreatureByTag(oPC, DEN_CR_ELF_THUG_1);
    object oElfThug2 = UT_GetNearestCreatureByTag(oPC, DEN_CR_ELF_THUG_2);

    switch(nEventType)
    {
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: it is for playing things like cutscenes and movies when
        // you enter an area, things that do not involve AI or actual game play
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_SPECIAL:
        {
            break;
        }
        ///////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: for things you want to happen while the load screen is still up,
        // things like moving creatures around
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {
            if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_EXITING_APARTMENTS_TO_ALLEY)
                && !WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_ALLEY_GUARD_AMBUSHES))
            {
                object oApartmentMapPin = UT_GetNearestObjectByTag(oPC, DEN_WP_ALLEY_FROM_APARTMENTS);
                object oCompoundMapPin = UT_GetNearestObjectByTag(oPC, DEN_WP_ALLEY_FROM_COMPOUND);
                SetMapPinState(oApartmentMapPin, TRUE);
                SetMapPinState(oCompoundMapPin, TRUE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_ALLEY_GUARD_AMBUSH, TRUE);
            }
            if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_FREED_SLAVES_IN_COMPOUND)
                && !WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY))
            {
                SetPlaceableState(oValendriansDoor, PLC_STATE_AREA_TRANSITION_UNLOCKED);
            }
            //set shianni inactive if she has no lines (healers attacked and bribe accepted)
            if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_LEFT_SLAVES_WITH_CALADRIUS)
                && WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ATTACKED_VERAS))
            {
                object oShianni = UT_GetNearestCreatureByTag(oPC, DEN_CR_SHIANNI);
                WR_SetObjectActive(oShianni, FALSE);
            }

            if (UT_CountItemInInventory(DEN_IM_HOSPICE_KEY))
            {
                object oSideGuard = UT_GetNearestCreatureByTag(oPC, DEN_CR_HOSPICE_SIDE_GUARD);
                object oSaritor = UT_GetNearestCreatureByTag(oPC, DEN_CR_SARITOR);
                if (IsObjectValid(oSideGuard))
                {
                    UT_RemoveItemFromInventory(DEN_IM_HOSPICE_KEY, 1, oSideGuard);
                }
                if (IsObjectValid(oSaritor))
                {
                    UT_RemoveItemFromInventory(DEN_IM_HOSPICE_KEY, 1, oSaritor);
                }
            }



            if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_TEVINTERS_GONE, TRUE))
            {
                object oWarehouseLocation = GetObjectByTag(WML_DEN_TEVINTER_WAREHOUSE);
                int bSuppressFlash = WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ACQUIRED_EVIDENCE);
                SetWorldMapLocationStatus(oWarehouseLocation, WM_LOCATION_ACTIVE, bSuppressFlash);

                UT_TeamAppears(DEN_TEAM_ALIENAGE_ELF_CROWD, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_ELF_CROWD_EXPLODERS, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_HOSPICE_SIDE_GUARD, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_HOSPICE_FRONT_GUARD, FALSE);

                // No more crowd sound
                AudioTriggerPlotEvent(46);
            }
            else if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ENTERED_HOSPICE))
            {
                UT_TeamAppears(DEN_TEAM_ALIENAGE_HOSPICE_SIDE_GUARD, FALSE);
            }

            // Beggar Event Checks
            int bCondition1 = WR_GetPlotFlag(PLT_DEN300PT_ENC_BEGGAR, BEGGAR_GAVE_FIRST_DONATION);
            int bCondition2 = WR_GetPlotFlag(PLT_DEN300PT_ENC_BEGGAR, BEGGAR_GAVE_SECOND_DONATION);
            int bCondition3 = WR_GetPlotFlag(PLT_DEN300PT_ENC_BEGGAR, BEGGAR_READY_FOR_SECOND_DONATION);
            int bCondition4 = WR_GetPlotFlag(PLT_DEN300PT_ENC_BEGGAR, BEGGAR_READY_FOR_THIRD_DONATION);

            // If the PC gave money the first time, then on area enter it's ready for another donation
            if ( bCondition1 && !bCondition3 )
            {
                WR_SetPlotFlag(PLT_DEN300PT_ENC_BEGGAR, BEGGAR_READY_FOR_SECOND_DONATION, TRUE, TRUE);
            }

            // If the PC gave money the second time, then on area enter it's ready for another donation
            if ( bCondition2 && !bCondition4 )
            {
                WR_SetPlotFlag(PLT_DEN300PT_ENC_BEGGAR, BEGGAR_READY_FOR_THIRD_DONATION, TRUE, TRUE);
            }

            // If you rejected the beggars, make them disappear
            // This is handled in the plot script now.
            /*if ( WR_GetPlotFlag(PLT_DEN300PT_ENC_BEGGAR, BEGGAR_SECOND_DONATION_REJECTED) )
            {
                UT_TeamAppears(DEN_TEAM_ALIENAGE_BEGGAR_2, FALSE);
            }*/

            // After the third wave, they all disappear
            if ( /*WR_GetPlotFlag(PLT_DEN300PT_ENC_BEGGAR, BEGGAR_THIRD_DONATION_REJECTED) ||*/
                WR_GetPlotFlag(PLT_DEN300PT_ENC_BEGGAR, BEGGAR_PC_GAVE_THIRD_DONATION) )
            {
                UT_TeamAppears(DEN_TEAM_ALIENAGE_BEGGAR_2, FALSE);
                UT_TeamAppears(DEN_TEAM_ALIENAGE_BEGGAR_3, FALSE);
            }

            // If the LAST REQUEST quest is active, run the script on area enter so the door is selectable
            if ( WR_GetPlotFlag(PLT_DEN300PT_LAST_REQUEST, LAST_QUEST_ACTIVE) )
                WR_SetPlotFlag(PLT_DEN300PT_LAST_REQUEST, LAST_QUEST_ACTIVE, TRUE, TRUE);

            if (!WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_ELF_CITY)
                && !WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_SORIS_IN_ALIENAGE, TRUE))
            {
                //For non-city elf characters, Cyrion's house is not accessible, unless you have rescued Soris.
                object oCyrionDoor = UT_GetNearestObjectByTag(oPC, DEN_IP_CYRIONS_ENTRANCE);
                object oCyrionWP = UT_GetNearestObjectByTag(oPC, DEN_WP_CYRIONS_ENTRANCE);
                SetObjectInteractive(oCyrionDoor, FALSE);
                SetMapPinState(oCyrionWP, FALSE);
                WR_SetObjectActive(oCyrionWP, FALSE);

            }

            // If Ser Otto has gone to the Orphanage, make the clues non-interactive.
            if( WR_GetPlotFlag(PLT_DEN300PT_SOME_WICKED, OTTO_GOES_TO_ORPHANAGE) )
            {
                object  [] arClues  =   UT_GetTeam(DEN_TEAM_OTTO_CLUES, OBJECT_TYPE_ALL);
                object  oCurrent;

                int     nTeam       =   GetArraySize(arClues);
                int     nLoop;

                for( nLoop = 0; nLoop < nTeam; nLoop++)
                {
                    oCurrent = arClues[nLoop];

                    SetObjectInteractive(oCurrent, FALSE);
                }
                // Qwinn added
                object oOtto = UT_GetNearestCreatureByTag(oPC,"den300cr_otto");
                WR_SetObjectActive(oOtto,FALSE);
            }

            //If the player went through an area transition before the haggard
            //human encounter finished, skip to the fighting.
            int bThugsStarted = WR_GetPlotFlag(PLT_DEN300PT_GENERIC, DEN_ALIENAGE_GENERIC_THUGS_INITIATED);
            int bThugsScared = WR_GetPlotFlag(PLT_DEN300PT_GENERIC, DEN_ALIENAGE_GENERIC_THUGS_SCARED);
            int bThugsFight = WR_GetPlotFlag(PLT_DEN300PT_GENERIC, DEN_ALIENAGE_GENERIC_THUGS_ATTACK);

            if ( (bThugsStarted == TRUE) && (bThugsScared == FALSE) && (bThugsFight == FALSE) )
            {
                WR_SetPlotFlag(PLT_DEN300PT_GENERIC, DEN_ALIENAGE_GENERIC_THUGS_ATTACK, TRUE, TRUE);
            }

            //Light_Mage_Places
            if ( WR_GetPlotFlag( PLT_LITE_MAGE_PLACES, PLACES_QUEST_GIVEN) == TRUE)
            {
                object oPlace = UT_GetNearestObjectByTag(oPC, LITE_IP_MAGE_MYSTICSITE);
                SetObjectInteractive(oPlace, TRUE);
            }

            if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_EXITING_APARTMENTS_TO_ALLEY)
                && !WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_ALLEY_GUARD_AMBUSHES))
            {
                UT_Talk(oAlleyGuard, oPC);
            }

            //CNM: if you have unlocked the hospice front door from the inside
            //and it has not already been unlocked
            //unlock it
            object oHospiceFront = UT_GetNearestObjectByTag(oPC,DEN_IP_TO_HOSPICE_FRONT);
            int nInsideUnlocked = WR_GetPlotFlag(PLT_DEN300PT_GENERIC,DEN_ALIENAGE_GENERIC_HOSPICE_FRONT_DOOR_UNLOCKED);
            int nOutsideState = GetPlaceableState(oHospiceFront);
            if((nInsideUnlocked == TRUE)
                && (nOutsideState == PLC_STATE_DOOR_LOCKED))
            {
                SetPlaceableActionResult(oHospiceFront,PLACEABLE_ACTION_UNLOCK,TRUE);
            }

            if(WR_GetPlotFlag(PLT_LITE_FITE_CONSCRIPTS, CONSCRIPTS_QUEST_GIVEN) == TRUE &&
                WR_GetPlotFlag(PLT_LITE_FITE_CONSCRIPTS, CONSCRIPTS_RECRUITED_THREE) == FALSE)
            {

                object oVeral = UT_GetNearestObjectByTag(oPC, "lite_conscripts_varel");
                SetPlotGiver(oVeral, TRUE);

                SetObjectInteractive(oVeral, TRUE);

            }

            //check plot giver for couriers - light content
            if (WR_GetPlotFlag(PLT_LITE_FITE_GREASE, GREASE_QUEST_GIVEN) == TRUE &&
                WR_GetPlotFlag(PLT_LITE_FITE_GREASE, GREASE_NOTICE_DELIVERED_3) == FALSE)
            {
                //set the plot giver status
                object oCourier3 = UT_GetNearestCreatureByTag(oPC, LITE_CR_GREASE_COURIER_3);
                SetPlotGiver(oCourier3, TRUE);
            }


            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: fires at the same time that the load screen is going away,
        // and can be used for things that you want to make sure the player sees.
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            if (!GetLocalInt(OBJECT_SELF, ENTERED_FOR_THE_FIRST_TIME))
            {
                //WR_SetPlotFlag(PLT_DEN300PT_GENERIC, DEN_ALIENAGE_GENERIC_THUGS_INITIATED, TRUE);
                //UT_Talk(oElfThug1, oElfThug2);
                DoAutoSave();
            }

            if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ENTERED_HOSPICE))
            {
                UT_TeamAppears(DEN_TEAM_ALIENAGE_HOSPICE_SIDE_GUARD, FALSE);
                if (!WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ATTACKED_VERAS))
                {
                    WR_SetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_ATTACKED_VERAS, TRUE, TRUE);

                    if (WR_GetPlotFlag(PLT_DENPT_SLAVE_TRADE, DEN_SLAVE_TRADE_PC_QUARANTINED))
                    {
                        UT_PartyRestore();
                    }
                }

            }
            //Check for Mabari Dominance
            if (WR_GetPlotFlag(PLT_LITE_MABARI_DOM, MABARI_DOM_ELVEN_ALIENAGE) == TRUE)
            {
                //if dog is in the party -
                int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
                if (nDog == TRUE)
                {
                    object oDog = Party_GetFollowerByTag("gen00fl_dog");
                    //if this flag has been set - activate the bonus and show the message
                    UI_DisplayMessage(oDog, 4010);

                    //Activate Bonus here
                    effect eDog = EffectMabariDominance();
                    ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eDog, oDog, 0.0f, oDog, 200261);
                }

            }
            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature enters the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_ENTER:
        {
            object oCreature = GetEventCreator(ev);

            break;
        }
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature exits the area
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_EXIT:
        {
            //if dog is in the party -
            int nDog = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY);
            if (nDog == TRUE)
            {
                object oDog = Party_GetFollowerByTag("gen00fl_dog");
                //DeActivate Bonus here
                RemoveEffectsByParameters(oDog, EFFECT_TYPE_INVALID, 200261);
            }

            break;
        }
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, DEN_SCRIPT_AREA_CORE);
    }
}