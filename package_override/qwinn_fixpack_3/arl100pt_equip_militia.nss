//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Sheryl
//:: Created On: Feb 26th, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "arl_constants_h"
#include "arl_siege_h"

#include "plt_arl100pt_equip_militia"
#include "plt_arl100pt_siege"


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

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case ARL_EQUIP_MILITIA_OWEN_MAKING_WEAPONS:
            {
                int bCrateMoved = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_PC_MOVED_CRATE);

                if (bCrateMoved == TRUE)
                {
                    object oRewardStash = UT_GetNearestObjectByTag(oPC, ARL_IP_OWEN_STASH_REWARD);
                    object oPlotStash = UT_GetNearestObjectByTag(oPC, ARL_IP_OWEN_STASH_PLOT);

                    WR_SetObjectActive(oRewardStash, TRUE);
                    WR_SetObjectActive(oPlotStash, FALSE);
                }
            }
            break;

            case ARL_EQUIP_MILITIA_OPEN_FREE_STORE:
            {
                object oStore = GetObjectByTag(ARL_STORE_OWEN_EXTRA);
                if (IsObjectValid(oStore) == TRUE)
                {
                    ScaleStoreItems(oStore);
                    OpenStore(oStore);
                }
            }
            break;

            case ARL_EQUIP_MILITIA_OWEN_DOOR_UNLOCKED:
            {
                // Unlocks Owen's door if the flag is set.
                object oDoor = UT_GetNearestObjectByTag(oPC, ARL_IP_DOOR_BLACKSMITH);
                SetPlaceableState(oDoor, PLC_STATE_AREA_TRANSITION_UNLOCKED);
            }
            break;

            case ARL_EQUIP_MILITIA_MURDOCK_GIVEN_STASH:
            {
                // Takes Stash item from PC's inventory
                UT_RemoveItemFromInventory(ARL_R_IT_STASH, 1);

            }
            break;

            case ARL_EQUIP_MILITIA_OWEN_ATTACKS:
            {
                UT_TeamGoesHostile(ARL_TEAM_OWEN, TRUE);

            }
            break;

            case ARL_EQUIP_MILITIA_OWEN_UNLOCKS_TRAP_DOOR:
            {
                object oRewardStash = UT_GetNearestObjectByTag(oPC, ARL_IP_OWEN_STASH_REWARD);
                SetPlaceableState(oRewardStash, PLC_STATE_CONTAINER_UNLOCKED);

                //This should be redundant:
                object oPlotStash = UT_GetNearestObjectByTag(oPC, ARL_IP_OWEN_STASH_PLOT);
                SetPlaceableState(oPlotStash, PLC_STATE_CONTAINER_UNLOCKED);
            }
            break;

            case ARL_EQUIP_MILITIA_VILLAGE_ENTERED:
            {
                if (WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_SIEGE_OVER) == TRUE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_1, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_2, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_3, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_4, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_5, TRUE, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_1) == FALSE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_1, TRUE, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_2) == FALSE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_2, TRUE, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_3) == FALSE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_3, TRUE, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_4) == FALSE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_4, TRUE, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_5) == FALSE)
                {
                    WR_SetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_5, TRUE, TRUE);
                }
            }
            break;

            case ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_1:
            {
                object oMilitia1 = UT_GetNearestObjectByTag(oPC, ARL_CR_MILITIA_1);
                ARL_SiegeEquipMilitiaMember(oMilitia1);
            }
            break;

            case ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_2:
            {
                object oMilitia2 = UT_GetNearestObjectByTag(oPC, ARL_CR_MILITIA_2);
                ARL_SiegeEquipMilitiaMember(oMilitia2);

                object oTomas = UT_GetNearestObjectByTag(oPC, ARL_CR_TOMAS);
                ARL_SiegeEquipMilitiaMember(oTomas);
            }
            break;

            case ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_3:
            {
                object oMilitia3 = UT_GetNearestObjectByTag(oPC, ARL_CR_MILITIA_3);
                ARL_SiegeEquipMilitiaMember(oMilitia3);

                object oWatchman = UT_GetNearestObjectByTag(oPC, ARL_CR_WATCHMAN);
                ARL_SiegeEquipMilitiaMember(oWatchman);
            }
            break;

            case ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_4:
            {
                object oMilitia4 = UT_GetNearestObjectByTag(oPC, ARL_CR_MILITIA_4);
                ARL_SiegeEquipMilitiaMember(oMilitia4);
            }
            break;

            case ARL_EQUIP_MILITIA_UPGRADE_EQUIPMENT_5:
            {
                object oMilitia5 = UT_GetNearestObjectByTag(oPC, ARL_CR_MILITIA_5);
                ARL_SiegeEquipMilitiaMember(oMilitia5);

                object oMurdock = UT_GetNearestObjectByTag(oPC, ARL_CR_MURDOCK);
                ARL_SiegeEquipMilitiaMember(oMurdock);
            }
            break;

            case ARL_EQUIP_MILITIA_MURDOCK_READY:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_REDCLIFFE_1c);

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case ARL_EQUIP_MILITIA_MILITIA_HAS_EQUIPMENT_OF_SOME_KIND:
            {
                // IF ARL_EQUIP_MILITIA_MURDOCK_GIVEN_STASH
                // OR
                // IF ARL_EQUIP_MILITIA_OWEN_MAKING_WEAPONS

                int bGivenStash = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_MURDOCK_GIVEN_STASH);
                int bWeaponsMade = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_OWEN_MAKING_WEAPONS);

                nResult = (bGivenStash == TRUE) || (bWeaponsMade == TRUE);
            }
            break;

            case ARL_EQUIP_MILITIA_PC_ON_QUEST_TO_EQUIP_MILITIA:
            {
                // IF ARL_EQUIP_MILITIA_PC_KNOWS_ABOUT_OWEN
                // IF NOT ARL_EQUIP_MILITIA_OWEN_MAKING_WEAPONS

                int bOwenKnown = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_PC_KNOWS_ABOUT_OWEN);
                int bWeaponsMade = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_OWEN_MAKING_WEAPONS);

                nResult = (bOwenKnown == TRUE) && (bWeaponsMade == FALSE);
            }
            break;

            case ARL_EQUIP_MILITIA_PC_HAS_STASH:
            {
                  // If PC has the Stash plot item
                  int nStash = UT_CountItemInInventory(ARL_R_IT_STASH);

                  nResult = (nStash >= 1);
            }
            break;
        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}