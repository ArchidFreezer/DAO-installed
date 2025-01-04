//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Craig
//:: Created On: March 4, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "sys_audio_h"

//#include "den_constants_h"
#include "plt_denpt_captured"
#include "plt_gen00pt_party"
#include "plt_gen00pt_combos"
#include "plt_genpt_app_alistair"
#include "plt_genpt_app_dog"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_morrigan"
#include "plt_genpt_app_oghren"
#include "plt_genpt_app_shale"
#include "plt_genpt_app_sten"
#include "plt_genpt_app_wynne"
#include "plt_genpt_app_zevran"
#include "party_h"
#include "cutscenes_h"
#include "den_functions_h"
#include "plt_tut_disguise"
#include "plt_cod_cha_cauthrien"
#include "sys_ambient_h"

#include "plt_cod_cha_anora"

// Qwinn added for scaling of disguises
#include "sys_rewards_h"

const resource DEN_IM_CAPTURED_CHANTRY_ROBE     = R"gen_im_cth_cha_a00.uti";
const resource DEN_IM_CAPTURED_CIRCUS_OUTFIT_1  = R"gen_im_cth_nob_b01.uti";
const resource DEN_IM_CAPTURED_CIRCUS_OUTFIT_2  = R"gen_im_cth_nob_c03.uti";

const string DEN_IT_CAPTURED_PARTY_DISGUISE = "den400im_party_disguise";

void DEN_Escape(int bFight, int bTalk, int bNoMoreTalk)
{
    object oPC      = GetHero();
    object oJailor  = UT_GetNearestCreatureByTag(oPC, DEN_CR_JAILOR);


    if (bTalk)
    {
        Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName() + ".DEN_Escape", "Jailor talking.");
        UT_Talk(oJailor, oPC);
    }
    if (bNoMoreTalk)
    {
        Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName() + ".DEN_Escape", "Jailor shouldn't talk anymore.");
        WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_JAILOR_SHOULD_NOT_TALK_WHEN_DOOR_CLICKED, TRUE);
    }
    if (bFight)
    {
        Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName() + ".DEN_Escape", "Jailor fighting.");
        WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_JAILOR_ATTACK_SOUND_START, TRUE, TRUE);
        UT_TeamGoesHostile(DEN_TEAM_CAPTURED_JAILOR);
    }
    else
    {
        Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName() + ".DEN_Escape", "Jailor incapacitated.");
        object oPlayerChest = UT_GetNearestObjectByTag(oPC, DEN_IP_PLAYER_STORAGE_CHEST);
        SetObjectInteractive(oPlayerChest, TRUE);
    }
}

void DEN_EquipFollowerDisguise(string sFollowerTag, resource rDisguise)
{
    object oFollower = Party_GetActiveFollowerByTag(sFollowerTag);
    object oDisguise = UT_AddItemToInventory(rDisguise, 1, OBJECT_INVALID, DEN_IT_CAPTURED_PARTY_DISGUISE, TRUE);

    UnequipItem(oFollower, GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oFollower));
    UnequipItem(oFollower, GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oFollower));
    UnequipItem(oFollower, GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oFollower));
    UnequipItem(oFollower, GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oFollower));
    EquipItem(oFollower, oDisguise);
}


// Qwinn - to make disguises match the uniforms of the other guards in Fort Drakon,
// we need to autoscale them.  Making a variant of the relevant functions from den_functions_h
// so that we don't have to modify an include of 20 scripts
void Qw_DEN_CreateDisguise(object oFollower);
void Qw_DEN_CreateDisguise(object oFollower)
{
    int n;
    object[] arrArmor;
    object oArmor;
    object oChest = UT_GetNearestObjectByTag(oFollower, DEN_DISGUISE_CHEST + GetTag(oFollower));

    arrArmor[0]   = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oFollower);
    arrArmor[1]   = GetItemInEquipSlot(INVENTORY_SLOT_GLOVES, oFollower);
    arrArmor[2]   = GetItemInEquipSlot(INVENTORY_SLOT_BOOTS, oFollower);
    arrArmor[3]   = GetItemInEquipSlot(INVENTORY_SLOT_HEAD, oFollower);

    for (n = 0; n < 4; n++)
    {
        MoveItem(oFollower, oChest, arrArmor[n]);
    }

    arrArmor[0]  = UT_AddItemToInventory(DEN_IM_CAPTURED_DISGUISE);
    arrArmor[1]  = UT_AddItemToInventory(DEN_IM_CAPTURED_DISGUISE_BOOTS);
    arrArmor[2]  = UT_AddItemToInventory(DEN_IM_CAPTURED_DISGUISE_GLOVES);
    arrArmor[3]  = UT_AddItemToInventory(DEN_IM_CAPTURED_DISGUISE_HELM);

    object oPC = GetHero();
    object oStorageGuard1 = UT_GetNearestCreatureByTag(oPC, DEN_CR_STORAGE_GUARD_1);
    int nLevel = GetLevel(oStorageGuard1);

    for (n = 0; n < 4; n++)
    {
        oArmor = arrArmor[n];
        RW_ScaleItem(oArmor, nLevel);
        SetItemIrremovable(oArmor, TRUE);
        SetItemIndestructible(oArmor, TRUE);
        EquipItem(oFollower, oArmor);
    }
}

void Qw_DEN_CreateDisguises();
void Qw_DEN_CreateDisguises()
{
    object    oPartyMember;
    object [] arParty    = GetPartyList(GetPartyLeader());

    int       nLoop;
    int       nPartySize = GetArraySize(arParty);

    for (nLoop = 0; nLoop < nPartySize; nLoop++)
    {
        oPartyMember = arParty[nLoop];
        if (GetTag(oPartyMember) != GEN_FL_DOG)
        {
            Qw_DEN_CreateDisguise(oPartyMember);
            // The next line is only for CA3505
            UnequipItem(oPartyMember, GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oPartyMember));
            UnequipItem(oPartyMember, GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oPartyMember));
        }
    }
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
    object oMainControlled = GetMainControlled();

    object oCage            = UT_GetNearestObjectByTag(oMainControlled, DEN_IP_CAPTURED_CAGE);
    object oBarracksDoor    = UT_GetNearestObjectByTag(oMainControlled, DEN_IP_CAPTURED_DOOR_BARRACKS);
    object oCaptainsDoor    = UT_GetNearestObjectByTag(oMainControlled, DEN_IP_CAPTURED_DOOR_CAPTAIN);
    object oFrontHallDoor   = UT_GetNearestObjectByTag(oMainControlled, DEN_IP_CAPTURED_DOOR_HALL_FRONT);
    object oRearHallDoor    = UT_GetNearestObjectByTag(oMainControlled, DEN_IP_CAPTURED_DOOR_HALL_REAR);
    object oReceptionDoor   = UT_GetNearestObjectByTag(oMainControlled, DEN_IP_CAPTURED_DOOR_RECEPTION);
    object oFrontGuard1     = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_CAPTURED_FRONT_GUARD_1);
    object oOffDuty1        = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_OFF_DUTY_1);
    object oOffDuty2        = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_OFF_DUTY_2);
    object oStorageGuard1   = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_STORAGE_GUARD_1);
    object oStorageGuard2   = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_STORAGE_GUARD_2);
    object oSergeant    = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_SERGEANT);
    object oCaptain     = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_CAPTURED_CAPTAIN);
    object oAugustine   = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_AUGUSTINE);
    object oAlistair    = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
    object oShale       = Party_GetFollowerByTag(GEN_FL_SHALE);

    object oExit    = UT_GetNearestObjectByTag(oMainControlled, DEN_IP_CAPTURED_EXIT);
    object oCityMap = GetObjectByTag( WM_DEN_TAG );
    object oCM_Fort = GetObjectByTag(WML_DEN_FORT_DRAKON);



    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case DEN_CAPTURED_RESTORE_OVERRIDE_CONVERSATION:
            {
                if (!WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_COMING_OUT, TRUE))
                {
                    // **IMPORTANT** this must be cleared or it may mess up later plots
                    DEN_SetPartyDialogOverride(DEN_CONV_PARTY_CLICKED);
                }
                break;
            }
            case DEN_CAPTURED_CAUTHRIEN_ATTACKS:
            {
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_CAUTHRIEN);
                UT_TeamAppears(DEN_TEAM_RESCUE_ANORA, FALSE);

                WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_RESCUE_FIGHT, TRUE, TRUE);


                break;
            }

            case DEN_CAPTURED_ANORA_BETRAYED_PC:
            {
                WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_RESCUE_BETRAYED, TRUE, TRUE);

                break;
            }

            case DEN_CAPTURED_CAUTHRIEN_DEFEATED:
            {
                object oArlMainDoor = UT_GetNearestObjectByTag(oPC, DEN_IP_RESCUE_MAIN_EXIT);
                SetPlaceableState(oArlMainDoor, PLC_STATE_AREA_TRANSITION_UNLOCKED);
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_RECRUITED))
                {
                    WR_SetFollowerState(oShale, FOLLOWER_STATE_AVAILABLE);
                }

                WR_SetPlotFlag(PLT_COD_CHA_CAUTHRIEN, COD_CHA_CAUTHRIEN_KILLED_IN_RESCUE, TRUE, TRUE);

                break;
            }
            case DEN_CAPTURED_PC_SURRENDERED:
            {
                WR_SetPlotFlag(PLT_COD_CHA_ANORA, COD_CHA_ANORA_SACRIFICE, TRUE, TRUE);

                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_CAPTURED, TRUE, TRUE);


                break;
            }
            case DEN_CAPTURED_PC_CAPTURED:
            {
                // Qwinn added:  If player is captured, they should be stripped of Cauthrien's sword, as she survives
                object oFollower, oSword;
                object [] oParty = GetPartyList();
                int nFoundSword, nIndex, nSize = GetArraySize(oParty);
                for ( nIndex = 0; nIndex < nSize; ++nIndex )
                {   oFollower = oParty[ nIndex ];
                    oSword = GetItemPossessedBy(oFollower,"gen_im_wep_mel_gsw_sum");
                    if (IsObjectValid(oSword)) UnequipItem(oFollower,oSword);
                }
                UT_RemoveItemFromInventory(R"gen_im_wep_mel_gsw_sum.uti", 1, oPC);


                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED, TRUE);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_WHILE_MORRIGAN_PRESENT, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_WHILE_ZEVRAN_PRESENT, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_WHILE_STEN_PRESENT, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_WHILE_DOG_PRESENT, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_WHILE_LELIANA_PRESENT, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_WHILE_WYNNE_PRESENT, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_WHILE_OGHREN_PRESENT, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_WHILE_SHALE_PRESENT, TRUE);
                }


                UT_DoAreaTransition(DEN_AR_EAMON_CAPTURED, DEN_WP_CAPTURED_EAMON);

                break;
            }
            case DEN_CAPTURED_FADE_TO_PC_IN_PRISON:
            {
                Injury_RemoveAllInjuriesFromParty();
                UT_DoAreaTransition(DEN_AR_FORT, DEN_WP_CAPTURED_PLAYER_START);
                break;
            }
            case DEN_CAPTURED_PC_AWAKE:
            {
                object oPrisoner = UT_GetNearestCreatureByTag(oPC, DEN_CR_PRISONER);
                object oSpeaker = oPrisoner;
                WR_SetWorldMapPlayerLocation(oCityMap, oCM_Fort);
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                    oSpeaker = oAlistair;
                }
                else
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                }

                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_CAMP, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_CAMP, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_CAMP, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_CAMP, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_CAMP, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_CAMP, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_CAMP, TRUE, TRUE);
                }

                UT_Talk(oSpeaker, oPC, DEN_CONV_PC_PRISON);
                break;
            }
            case DEN_CAPTURED_PC_ESCAPING:
            {
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                    UT_LocalJump(oAlistair, DEN_WP_CAPTURED_ALISTAIR_RESCUE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED))
                {
                    object oDog = Party_GetFollowerByTag(GEN_FL_DOG);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
                    UT_LocalJump(oDog, DEN_WP_CAPTURED_DOG);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED))
                {
                    object oLeliana = Party_GetFollowerByTag(GEN_FL_LELIANA);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_CAMP, TRUE, TRUE);
                    UT_LocalJump(oLeliana, DEN_WP_CAPTURED_LELIANA);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED))
                {
                    object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_CAMP, TRUE, TRUE);
                    UT_LocalJump(oMorrigan, DEN_WP_CAPTURED_MORRIGAN);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED))
                {
                    object oOghren = Party_GetFollowerByTag(GEN_FL_OGHREN);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_CAMP, TRUE, TRUE);
                    UT_LocalJump(oOghren, DEN_WP_CAPTURED_OGHREN);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_RECRUITED))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_CAMP, TRUE, TRUE);
                    UT_LocalJump(oShale, DEN_WP_CAPTURED_SHALE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_RECRUITED))
                {
                    object oSten = Party_GetFollowerByTag(GEN_FL_STEN);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_CAMP, TRUE, TRUE);
                    UT_LocalJump(oSten, DEN_WP_CAPTURED_STEN);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED))
                {
                    object oWynne = Party_GetFollowerByTag(GEN_FL_WYNNE);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_CAMP, TRUE, TRUE);
                    UT_LocalJump(oWynne, DEN_WP_CAPTURED_WYNNE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_RECRUITED))
                {
                    object oZevran = Party_GetFollowerByTag(GEN_FL_ZEVRAN);
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_CAMP, TRUE, TRUE);
                    UT_LocalJump(oZevran, DEN_WP_CAPTURED_ZEVRAN);
                }

                SetPlaceableState(oRearHallDoor, PLC_STATE_DOOR_UNLOCKED);
                SetPlaceableState(oFrontHallDoor, PLC_STATE_DOOR_UNLOCKED);
                SetPlaceableState(oReceptionDoor, PLC_STATE_DOOR_UNLOCKED);
                SetPlaceableState(oBarracksDoor, PLC_STATE_DOOR_UNLOCKED);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_KENNEL, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_EQUIPMENT_ROOM, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_GUARD_POST, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_COLONEL, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_STORAGE, TRUE);
                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_BALLISTAE, FALSE, OBJECT_TYPE_PLACEABLE);
                SetObjectInteractive(oExit, TRUE);
                //UT_AddItemToInventory(DEN_IM_CAPTURED_RECEPTION_KEY, 1, oCaptain);
                UT_RemoveItemFromInventory(DEN_IM_CAPTURED_FRONT_HALL_KEY, 1, oCaptain);
                UT_RemoveItemFromInventory(DEN_IM_CAPTURED_RECEPTION_KEY, 1, oFrontGuard1);
                UT_RemoveItemFromInventory(DEN_IM_CAPTURED_REAR_HALL_KEY, 1, oSergeant);

                UT_TeamAppears(DEN_TEAM_CAPTURED_JAILOR_2, FALSE);

                // Store all unequipped inventory
                DEN_StoreInventory();


                object oPlayerChest = UT_GetNearestObjectByTag(oMainControlled, DEN_IP_PLAYER_STORAGE_CHEST);
                SetObjectInteractive(oPlayerChest, FALSE);

                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_ESCAPING, TRUE, FALSE);
                UT_TeamAppears(DEN_TEAM_CAPTURED_DEAD_PRISONERS);
                DoAutoSave();

                break;
            }
            /*case DEN_CAPTURED_PARTY_SELECTION:
            {
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                {
                    //WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                    WR_SetFollowerState(oAlistair, FOLLOWER_STATE_UNAVAILABLE);
                    SetGroupId(oAlistair, GROUP_NEUTRAL);
                }


                SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);
                ShowPartyPickerGUI();
                break;
            }
            case DEN_CAPTURED_PARTY_SELECTED:
            {

                object[] arrParty = GetPartyList();
                int nPartyMembers = GetArraySize(arrParty);
                int bNoTalkers = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY)
                                 && WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_PARTY);
                nPartyMembers--; // account for the player

                if (bNoTalkers || (nPartyMembers != 2))
                {
                    SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);
                    ShowPartyPickerGUI();
                }
                else
                {
                    object oNewLeader;
                    object oPartyMember;
                    int n;
                    for (n = 0; n < nPartyMembers && oNewLeader == OBJECT_INVALID; n++)
                    {
                        oPartyMember = arrParty[n];
                        if (!IsHero(oPartyMember))
                        {
                            oNewLeader = oPartyMember;
                        }
                    }
                    SetPartyLeader(oNewLeader);

                    Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName(), "New leader is: " + GetTag(oNewLeader));

                    WR_SetFollowerState(oPC, FOLLOWER_STATE_UNAVAILABLE);
                    SetGroupId(oPC, GROUP_NEUTRAL);

                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_COMING_IN, TRUE, TRUE);

                }
                break;
            }   */

            case DEN_CAPTURED_ZEVRAN_AND_WYNNE_RESCUE:
            {
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY, TRUE, TRUE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY, TRUE, TRUE);

                break;
            }
            case DEN_CAPTURED_PARTY_COMING_IN:
            {
                // Need to remove Alistair so he isn't flagged as the party leader
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                    WR_SetObjectActive(oAlistair, TRUE);
                    SetGroupId(oAlistair, GROUP_NEUTRAL);
                }

                object[] arrParty = GetPartyList();
                int nPartyMembers = GetArraySize(arrParty);
                object oNewLeader;
                object oPartyMember;
                int n;

                for (n = 0; n < nPartyMembers && oNewLeader == OBJECT_INVALID; n++)
                {
                    oPartyMember = arrParty[n];
                    if (!IsHero(oPartyMember))
                    {
                        oNewLeader = oPartyMember;
                    }
                }
                SetPartyLeader(oNewLeader);

                Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName(), "New leader is: " + GetTag(oNewLeader));

                WR_SetFollowerState(oPC, FOLLOWER_STATE_UNAVAILABLE);

                SetGroupId(oPC, GROUP_NEUTRAL);

                int nPriests = 0;
                int nPerformers = 0;
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_PARTY))
                {
                    nPriests++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY))
                {
                    nPriests++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY))
                {
                    nPriests++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_PARTY))
                {
                    nPerformers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY)
                     || WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_PARTY))
                {
                    nPerformers++;
                }

                if (nPriests >= 2)
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_DISGUISED_AS_PRIESTS, TRUE, TRUE);
                }
                else if (nPerformers >= 2)
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_DISGUISED_AS_CIRCUS_PERFORMERS, TRUE, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_DELIVERING_SHALE, TRUE);
                }
                else if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_DELIVERING_DOG, TRUE);
                }
                else
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_DISGUISED_AS_MERCHANTS, TRUE);
                }
                // Qwinn - Turning off party picker, it just glitches.
                // SetPartyPickerGUIStatus(PP_GUI_STATUS_READ_ONLY);
                SetPartyPickerGUIStatus(PP_GUI_STATUS_NO_USE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_KENNEL, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_EQUIPMENT_ROOM, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_GUARD_POST, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_COLONEL, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_STORAGE, TRUE);

                UT_TeamMerge(DEN_TEAM_CAPTURED_JAILOR_2, DEN_TEAM_CAPTURED_JAILOR);

                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_JAILOR, TRUE);

                UT_TeamAppears(DEN_TEAM_CAPTURED_ARMOR_RACK, FALSE, OBJECT_TYPE_PLACEABLE);
                UT_TeamAppears(DEN_TEAM_CAPTURED_DEAD_PRISONERS);


                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_DELIVERING_SHALE))
                {
                    UT_LocalJump(oMainControlled, DEN_WP_CAPTURED_ENTRANCE, FALSE, FALSE, TRUE, TRUE);


                }

                 // jump rest of party
                object [] arRescueParty = GetPartyList();
                int i;
                int nSize = GetArraySize(arRescueParty);
                object oCurrent;
                for(i = 0; i < nSize; i++)
                {
                    oCurrent = arRescueParty[i];
                    if(GetFollowerState(oCurrent) == FOLLOWER_STATE_ACTIVE && oCurrent != oMainControlled)
                        UT_LocalJump(oCurrent, DEN_WP_CAPTURED_ENTRANCE, FALSE, FALSE, TRUE, TRUE);
                }

                // **IMPORTANT** this must be cleared or it may mess up later plots
                DEN_SetPartyDialogOverride(DEN_CONV_PARTY_CLICKED);

                UT_RemoveItemFromInventory(DEN_IM_CAPTURED_PASSWORD_LIST, 1, oStorageGuard1);

                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_COMING_IN, TRUE, FALSE);

                // This messed up the outfits, replaced with an autsave trigger at entrance
                //DoAutoSave();


                break;
            }
            case DEN_CAPTURED_PARTY_DISGUISED_AS_PRIESTS:
            {
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_PARTY))
                {
                    DEN_EquipFollowerDisguise(GEN_FL_LELIANA, DEN_IM_CAPTURED_CHANTRY_ROBE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY))
                {
                    DEN_EquipFollowerDisguise(GEN_FL_WYNNE, DEN_IM_CAPTURED_CHANTRY_ROBE);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY))
                {
                    DEN_EquipFollowerDisguise(GEN_FL_MORRIGAN, DEN_IM_CAPTURED_CHANTRY_ROBE);
                }
                break;
            }
            case DEN_CAPTURED_PARTY_DISGUISED_AS_CIRCUS_PERFORMERS:
            {
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_PARTY))
                {
                    DEN_EquipFollowerDisguise(GEN_FL_OGHREN, DEN_IM_CAPTURED_CIRCUS_OUTFIT_1);
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY))
                {
                    DEN_EquipFollowerDisguise(GEN_FL_ZEVRAN, DEN_IM_CAPTURED_CIRCUS_OUTFIT_2);
                }
                if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_PARTY))
                {
                    DEN_EquipFollowerDisguise(GEN_FL_STEN, DEN_IM_CAPTURED_CIRCUS_OUTFIT_2);
                }
                break;
            }

            case DEN_CAPTURED_GUARD_FETCHES_CAPTAIN:
            {
                UT_LocalJump(oMainControlled, DEN_WP_CAPTURED_WAITING_ROOM, TRUE, FALSE, FALSE, TRUE);
                UT_TeamAppears(DEN_TEAM_CAPTURED_FRONT_GUARDS, TRUE);

                // **IMPORTANT** this must be cleared or it may mess up later plots
                DEN_SetPartyDialogOverride(INVALID_RESOURCE);
                // Qwinn:  This didn't work right if 2nd character selected
                //  UT_Talk(oMainControlled, oFrontGuard1, DEN_CONV_RESCUE_PARTY);
                UT_Talk(GetPartyLeader(), oFrontGuard1, DEN_CONV_RESCUE_PARTY);
                break;
            }

            case DEN_CAPTURED_FRONT_GUARDS_ATTACKED:
            {
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_ESCAPING))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_FINAL_FIGHT, TRUE, TRUE);
                }
                else
                {
                    int bPartyIsStealthy = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY)
                                        || WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_PARTY);

                    UT_TeamGoesHostile(DEN_TEAM_CAPTURED_FRONT_GUARDS);
                    if(WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_REJOINS))
                    {
                        SetPlaceableState(oBarracksDoor, PLC_STATE_DOOR_OPEN);
                        UT_TeamMove(DEN_TEAM_CAPTURED_BARRACKS, DEN_WP_CAPTURED_FRONT_GUARDS);
                        UT_TeamGoesHostile(DEN_TEAM_CAPTURED_BARRACKS);
                    }
                    else
                    {
                       if (bPartyIsStealthy)
                       {
                            UT_TeamAppears(DEN_TEAM_CAPTURED_BARRACKS, FALSE);
                       }
                       else
                       {
                            SetPlaceableState(oBarracksDoor, PLC_STATE_DOOR_OPEN);
                            UT_TeamMove(DEN_TEAM_CAPTURED_BARRACKS, DEN_WP_CAPTURED_FRONT_GUARDS);
                            UT_TeamGoesHostile(DEN_TEAM_CAPTURED_BARRACKS);
                       }
                    }

                }

                break;
            }
            case DEN_CAPTURED_CAPTAIN_ARRIVES:
            {
                object oFrontGuard1 = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_CAPTURED_FRONT_GUARD_1);
                WR_SetObjectActive(oFrontGuard1, TRUE);
                UT_LocalJump(oCaptain, DEN_WP_CAPTURED_WAITING_ROOM);
                UT_Talk(oCaptain, oMainControlled);
                break;
            }

            case DEN_CAPTURED_CAPTAIN_ATTACKED:
            {
                Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName() + ".DEN_CAPTURED_CAPTAIN_ATTACKED");

                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_CAPTAIN);
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_COMING_OUT, TRUE))
                {
                    Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName() + ".DEN_CAPTURED_CAPTAIN_ATTACKED", "DEN_CAPTURED_PC_COMING_OUT == TRUE");

                    if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISED, TRUE))
                    {
                        Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName() + ".DEN_CAPTURED_CAPTAIN_ATTACKED", "DEN_CAPTURED_PC_DISGUISED == TRUE");
                        WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_REMOVED, TRUE, TRUE);
                    }
                }
                else if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_GUARD_FETCHES_CAPTAIN))
                {
                    Log_Trace(LOG_CHANNEL_TEMP, GetCurrentScriptName() + ".DEN_CAPTURED_CAPTAIN_ATTACKED", "DEN_CAPTURED_GUARD_FETCHES_CAPTAIN == TRUE");
                    UT_TeamGoesHostile(DEN_TEAM_CAPTURED_FRONT_GUARDS);
                    // Barracks deactivated
                    UT_TeamAppears(DEN_TEAM_CAPTURED_BARRACKS, FALSE);
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_FRONT_GUARDS_ATTACKED, TRUE, FALSE);
                }
                break;
            }
            case DEN_CAPTURED_CAPTAIN_BLUFFED:
            {
                SetPlaceableState(oFrontHallDoor, PLC_STATE_DOOR_OPEN);
                SetPlaceableState(oReceptionDoor, PLC_STATE_DOOR_OPEN);
                UT_LocalJump(oCaptain, DEN_WP_CAPTURED_CAPTAIN);
                break;
            }
            case DEN_CAPTURED_AUGUSTINE_UNSELECTABLE:
            {
                SetObjectInteractive(oAugustine, FALSE);
                break;
            }
            case DEN_CAPTURED_AUGUSTINE_LEAVES:
            {
                UT_ExitDestroy(oAugustine, FALSE, DEN_WP_CAPTURED_ENTRANCE);
                break;
            }
            case DEN_CAPTURED_AUGUSTINE_TURNS:
            {
                float fAngle    = GetAngleBetweenObjects(oAugustine, oMainControlled);
                // Compensate for broken GetFacing....
                fAngle = GetFacing(oAugustine, FALSE);
                fAngle +=180.0;

                if (fAngle > 180.0)
                {
                    fAngle - 360.0;
                }
                Ambient_Stop(oAugustine);
                SetObjectInteractive(oAugustine, FALSE);
                WR_ClearAllCommands(oAugustine, TRUE);
                WR_AddCommand(oAugustine, CommandTurn(fAngle), TRUE, FALSE, COMMAND_ADDBEHAVIOR_HARDCLEAR);
                WR_AddCommand(oAugustine, CommandPlayAnimation(3007), FALSE, FALSE, COMMAND_ADDBEHAVIOR_DONTCLEAR);
                break;
            }
            case DEN_CAPTURED_AUGUSTINE_RUNS:
            {
                // open all doors
                SetPlaceableState(oReceptionDoor, PLC_STATE_DOOR_OPEN);

                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_ESCAPING))
                {
                    if (!WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_FINAL_FIGHT))
                    {
                        WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_FINAL_FIGHT, TRUE, TRUE);
                        WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_REJOINS, TRUE, TRUE);
                    }
                }
                else
                {
                    SetPlaceableState(oCaptainsDoor, PLC_STATE_DOOR_OPEN);

                    // Front guards joins the fray
                    UT_TeamMove(DEN_TEAM_CAPTURED_FRONT_GUARDS, DEN_WP_CAPTURED_AUGUSTINE, TRUE);
                    UT_TeamGoesHostile(DEN_TEAM_CAPTURED_FRONT_GUARDS);
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_FRONT_GUARDS_ATTACKED, TRUE, FALSE);

                    // Captain joins the fray
                    UT_TeamMove(DEN_TEAM_CAPTURED_CAPTAIN, DEN_WP_CAPTURED_AUGUSTINE, TRUE);
                    UT_TeamGoesHostile(DEN_TEAM_CAPTURED_CAPTAIN);
                    UT_TeamMerge(DEN_TEAM_CAPTURED_CAPTAIN, DEN_TEAM_CAPTURED_FRONT_GUARDS);

                    UT_TeamGoesHostile(DEN_TEAM_CAPTURED_BARRACKS);
                }

                UT_ExitDestroy(oAugustine, TRUE, DEN_WP_CAPTURED_ENTRANCE);
                break;
            }
            case DEN_CAPTURED_THINK_OF_A_PLAN:
            {
                if (nValue)
                {
                    // the flag should be set when the conversation starts
                    WR_SetPlotFlag(strPlot, DEN_CAPTURED_THINK_OF_A_PLAN, TRUE);
                    // **IMPORTANT** this must be cleared or it may mess up later plots
                    DEN_SetPartyDialogOverride(INVALID_RESOURCE);
                    // Qwinn:  This didn't work properly if 2nd character selected
                    // UT_Talk(oMainControlled, oSergeant, DEN_CONV_RESCUE_PARTY);
                    UT_Talk(GetPartyLeader(), oSergeant, DEN_CONV_RESCUE_PARTY);
                }
                break;
            }
            case DEN_CAPTURED_OFF_DUTY_GUARDS_FIGHT:
            {
                SetGroupId(oOffDuty1, DEN_GROUP_OFFDUTY_1);
                SetGroupId(oOffDuty2, DEN_GROUP_OFFDUTY_2);
                SetImmortal(oOffDuty1, TRUE);
                SetImmortal(oOffDuty2, TRUE);
                SwitchWeaponSet(oOffDuty1);
                SwitchWeaponSet(oOffDuty2);
                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_MAIN_HALL, FALSE);
                UT_CombatStart(oOffDuty1, oOffDuty2);
                UT_Talk(oSergeant, oOffDuty2);

                SetTeamId(oOffDuty1, -1);
                SetTeamId(oOffDuty2, -1);

                object oTeamMember;
                int nIndex;

                object[] arTeam = UT_GetTeam(DEN_TEAM_CAPTURED_MAIN_HALL);
                for ( nIndex = 0; nIndex < GetArraySize(arTeam); nIndex++ )
                {
                    oTeamMember = arTeam[nIndex];
                    UT_QuickMoveObject(oTeamMember, "1", TRUE, FALSE, TRUE);
                    Ambient_Start(oTeamMember, AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID,
                                                AMBIENT_MOVE_PREFIX_NONE, 124 + Random(4));
                }
                SetTeamId(oOffDuty1, DEN_TEAM_CAPTURED_MAIN_HALL);
                SetTeamId(oOffDuty2, DEN_TEAM_CAPTURED_MAIN_HALL);

                Ambient_Start(oSergeant, AMBIENT_SYSTEM_ENABLED, AMBIENT_MOVE_INVALID,
                                                AMBIENT_MOVE_PREFIX_NONE,  AMBIENT_ANIM_PATTERN_LECTURER_1);

                // **IMPORTANT** this must be cleared or it may mess up later plots
                DEN_SetPartyDialogOverride(INVALID_RESOURCE);
                UT_Talk(oMainControlled, oSergeant, DEN_CONV_RESCUE_PARTY);
                SetPlaceableState(oRearHallDoor, PLC_STATE_DOOR_UNLOCKED);

                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_BALLISTAE, FALSE, OBJECT_TYPE_PLACEABLE);
                break;
            }
            case DEN_CAPTURED_BALLISTA_WRECKED:
            {
                // moving in den400ip_ballista_2.nss instead
                //UT_TeamMove(DEN_TEAM_CAPTURED_MAIN_HALL, DEN_WP_CAPTURED_WRECKED_BALLISTA, TRUE, 1.5, TRUE);
                SetPlaceableState(oRearHallDoor, PLC_STATE_DOOR_UNLOCKED);
                UT_Talk(oOffDuty1, oOffDuty2);
                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_MAIN_HALL, FALSE);

                break;
            }
            case DEN_CAPTURED_SERGEANT_ATTACKED:
            {
                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_MAIN_HALL, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_MAIN_HALL);
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISED, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_REMOVED, TRUE, TRUE);
                }

                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_BALLISTAE, FALSE, OBJECT_TYPE_PLACEABLE);
                break;
            }
            case DEN_CAPTURED_SERGEANT_LEAVES:
            {
                UT_ExitDestroy(oSergeant, FALSE, DEN_WP_CAPTURED_ENTRANCE);
                SetPlaceableState(oRearHallDoor, PLC_STATE_DOOR_UNLOCKED);
                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_MAIN_HALL, FALSE);
                UT_Talk(oOffDuty1, oOffDuty1);

                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_BALLISTAE, FALSE, OBJECT_TYPE_PLACEABLE);

                break;
            }
            case DEN_CAPTURED_SERGEANT_PASSED:
            {
                object oPostGuard1 = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_POST_GUARD_1);
                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_SERGEANT_PASSED, TRUE);

                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_COMING_IN))
                {
                    // **IMPORTANT** this must be cleared or it may mess up later plots
                    DEN_SetPartyDialogOverride(INVALID_RESOURCE);
                    UT_Talk(oMainControlled, oPostGuard1, DEN_CONV_RESCUE_PARTY);
                }
                break;
            }
            case DEN_CAPTURED_MAIN_HALL_LEAVES:
            {
                UT_TeamExit(DEN_TEAM_CAPTURED_MAIN_HALL, FALSE, DEN_WP_CAPTURED_ENTRANCE);
                break;
            }
            case DEN_CAPTURED_STORAGE_ATTACKS:
            {
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_CAN_CONTINUE, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_ABANDONED, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISED, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_REMOVED, TRUE, TRUE);
                }
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_STORAGE);
                break;
            }
            case DEN_CAPTURED_STORAGE_KILLED:
            {
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_CAN_CONTINUE, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_ABANDONED, TRUE, TRUE);
                }

                break;
            }
            case DEN_CAPTURED_JAILOR_ATTACK_SOUND_START:
            {
                AudioTriggerPlotEvent(28);

                break;
            }
            case DEN_CAPTURED_JAILOR_ILLNESS_FAKED:
            {
                object oJailor      = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_JAILOR);
                UT_LocalJump(oJailor, DEN_WP_CAPTURED_JAILOR_IN_CELL);
                DEN_Escape(TRUE, TRUE, TRUE);

                break;
            }

            case DEN_CAPTURED_JAILOR_GRABBED:
            {
                /*
                //  jailor is knocked down and goes hostile. PC gets keys
                effect eKnockdown = EffectKnockdown(oPC, 0);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_JAILOR);
                UT_AddItemToInventory(DEN_IM_CAPTURED_CAGE_KEY);
                ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, eKnockdown, oJailor, 10.0, oPC);
                */
                object oJailor      = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_JAILOR);
                KillCreature(oJailor, oPC);

                DEN_Escape(FALSE, FALSE, TRUE);
                break;
            }
            case DEN_CAPTURED_JAILOR_SEDUCTION_FAILED:
            {
                object oJailor      = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_JAILOR);
                UT_LocalJump(oJailor, DEN_WP_CAPTURED_JAILOR_IN_CELL);
                DEN_Escape(TRUE, FALSE, TRUE);
                break;
            }
            case DEN_CAPTURED_JAILOR_SEDUCTION_JUMPED:
            {
                object oJailor      = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_JAILOR);
                UT_LocalJump(oJailor, DEN_WP_CAPTURED_JAILOR_IN_CELL);
                DEN_Escape(TRUE, TRUE, TRUE);
                break;
            }
            case DEN_CAPTURED_JAILOR_SEDUCTION_STRIPPED:
            {
                object oJailor      = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_JAILOR);
                object[] arrEquipment = GetItemsInInventory(oJailor, GET_ITEMS_OPTION_EQUIPPED);
                int n;
                for (n = 0; n < GetArraySize(arrEquipment); n++)
                {
                    if(GetItemEquipSlot(arrEquipment[n]) != INVENTORY_SLOT_HEAD)
                    {
                        RemoveItem(arrEquipment[n]);
                    }
                }

                //UT_LocalJump(oJailor, DEN_WP_CAPTURED_JAILOR_IN_CELL);
                DEN_Escape(TRUE, TRUE, TRUE);

                break;
            }


            case DEN_CAPTURED_JAILOR_LOCKED_UP:
            {
                object oJailor      = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_JAILOR);
                SetPlaceableState(oCage, PLC_STATE_DOOR_LOCKED);

                UT_LocalJump(oJailor, DEN_WP_CAPTURED_JAILOR_IN_CELL);
                UT_LocalJump(oPC, DEN_WP_CAPTURED_PLAYER_OUTSIDE_CELL, TRUE, FALSE, FALSE, TRUE);

                DEN_Escape(FALSE, TRUE, FALSE);

                break;
            }
            case DEN_CAPTURED_JAILOR_RUNS_AWAY:
            {
                SetPlaceableState(oCage, PLC_STATE_DOOR_OPEN);
                UT_TeamAppears(DEN_TEAM_CAPTURED_JAILOR, FALSE);

                DEN_Escape(FALSE, FALSE, TRUE);

                break;
            }
            case DEN_CAPTURED_JAILOR_PC_OPENED_DOOR:
            {
                // UT_Talk is called in den400ip_cage.nss
                DEN_Escape(TRUE, FALSE, TRUE);

                break;
            }
            case DEN_CAPTURED_JAILOR_KILLED:
            {
                if(WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_ESCAPING))
                {
                    object oPlayerChest = UT_GetNearestObjectByTag(oMainControlled, DEN_IP_PLAYER_STORAGE_CHEST);
                    SetObjectInteractive(oPlayerChest, TRUE);

                }
                break;
            }
            case DEN_CAPTURED_PRISONER_RELEASED:
            {
                object oPrisoner = UT_GetNearestCreatureByTag(oPC, DEN_CR_PRISONER);
                WR_SetObjectActive(oPrisoner, FALSE);
                break;
            }

            case DEN_CAPTURED_PC_DISGUISE_EQUIPPED:
            {
                WR_SetPlotFlag(PLT_TUT_DISGUISE, TUT_DISGUISE_0, TRUE, TRUE);
                Captured_TeamsGoHostile(FALSE);

                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_REMOVED))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_REMOVED, FALSE, FALSE);
                }
                Qw_DEN_CreateDisguises();
                // Qwinn added for CE3504
                UnequipItem(oStorageGuard1, GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oStorageGuard1));
                UnequipItem(oStorageGuard2, GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oStorageGuard2));
                UnequipItem(oStorageGuard1, GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oStorageGuard1));
                UnequipItem(oStorageGuard2, GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oStorageGuard2));

                break;
            }
            case DEN_CAPTURED_PC_DISGUISE_REMOVED:
            {
                DEN_RemoveDisguises();
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_FOLLOWING_PLAYER, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_REMOVED, TRUE, TRUE);
                }

                Captured_TeamsGoHostile(TRUE);
                break;
            }
            case DEN_CAPTURED_GUARD_POST_ATTACKS:
            {
                object oPostGuard1 = UT_GetNearestCreatureByTag(oMainControlled, DEN_CR_POST_GUARD_1);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_GUARD_POST);
                UT_CombatStart(oPostGuard1, GetPartyLeader(), TRUE);

                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_CAN_CONTINUE, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_ABANDONED, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISED, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_REMOVED, TRUE, TRUE);
                }
                break;
            }
            case DEN_CAPTURED_GUARD_POST_KILLED:
            {
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_CAN_CONTINUE, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_ABANDONED, TRUE, TRUE);
                }
                break;
            }
            case DEN_CAPTURED_EQUIPMENT_GUY_PC_GIVES_ACID_FLASK:
            {
                UT_RemoveItemFromInventory(DEN_IM_ACID_FLASK);
                break;
            }
            case DEN_CAPTURED_EQUIPMENT_GUY_PC_GIVES_ACID_COATING:
            {
                UT_RemoveItemFromInventory(DEN_IM_ACID_COATING);
                break;
            }
            case DEN_CAPTURED_EQUIPMENT_GUY_LEAVES:
            {
                UT_TeamAppears(DEN_TEAM_CAPTURED_EQUIPMENT_ROOM, FALSE);
                break;
            }
            case DEN_CAPTURED_EQUIPMENT_GUY_GONE:
            {
                if (nValue == 1)
                {
                    UT_SetTeamInteractive(DEN_TEAM_CAPTURED_EQUIPMENT_ROOM, TRUE, OBJECT_TYPE_PLACEABLE);
                }
                break;
            }
            case DEN_CAPTURED_EQUIPMENT_GUY_BRIBED:
            {
                UT_MoneyTakeFromObject(oPC, 0, 0, DEN_MONEY_EQUIPMENT_GUY_BRIBE_GOLD);
                break;
            }
            case DEN_CAPTURED_EQUIPMENT_GUY_ATTACKED:
            {
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_EQUIPMENT_ROOM);
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_FOLLOWING_PLAYER, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_ABANDONED, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISED, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_REMOVED, TRUE, TRUE);
                }
                break;
            }
            case DEN_CAPTURED_EQUIPMENT_GUY_KILLED:
            {
                break;
            }
            case DEN_CAPTURED_GUARD_POST_DOOR_OPEN:
            {
                break;
            }
            case DEN_CAPTURED_INSPECTION_COLONEL_ATTACKS:
            {
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_COLONEL);
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_CAN_CONTINUE, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_ABANDONED, TRUE, TRUE);
                }
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISED, TRUE))
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_REMOVED, TRUE, TRUE);
                }
                break;
            }

            case DEN_CAPTURED_INSPECTION_READY:
            {
                object oSword = UT_AddItemToInventory(DEN_IM_CAPTURED_REGULATION_SWORD);
                object oSwordRack = UT_GetNearestObjectByTag(oPC, DEN_IP_CAPTURED_SWORD_STAND);

                if (GetObjectInteractive(oSwordRack))
                {
                    SetObjectInteractive(oSwordRack, FALSE);
                }
                EquipItem(oPC, oSword);
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                {
                    oSword = UT_AddItemToInventory(DEN_IM_CAPTURED_REGULATION_SWORD);
                    EquipItem(oAlistair, oSword);
                }
                oSword = UT_AddItemToInventory(DEN_IM_CAPTURED_REGULATION_SWORD, 1, oStorageGuard1);
                EquipItem(oStorageGuard1, oSword);
                oSword = UT_AddItemToInventory(DEN_IM_CAPTURED_REGULATION_SWORD, 1, oStorageGuard2);
                EquipItem(oStorageGuard2, oSword);

                break;
            }
            case DEN_CAPTURED_INSPECTION_FAILED:
            {
                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_REMOVED, TRUE, TRUE);
                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_ABANDONED, TRUE, FALSE);
                UT_TeamJump(DEN_TEAM_CAPTURED_STORAGE, DEN_WP_CAPTURED_STORAGE_GUARDS);
                UT_LocalJump(oPC, DEN_WP_CAPTURED_INSPECTION_FAILED, TRUE, FALSE, FALSE, TRUE);

                break;
            }
            case DEN_CAPTURED_INSPECTION_PASSED:
            {
                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_ARMOR_RACK, FALSE, OBJECT_TYPE_PLACEABLE);

                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_CAPTAIN, FALSE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_FRONT_GUARDS, FALSE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_COLONEL, FALSE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_EQUIPMENT_ROOM, FALSE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_GUARD_POST, FALSE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_MAIN_HALL, FALSE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_STORAGE, FALSE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_KENNEL, FALSE);
                break;
            }
            case DEN_CAPTURED_INSPECTION_GUARDS_JOINED:
            {
                object[] arTeam = UT_GetTeam(DEN_TEAM_CAPTURED_STORAGE);
                int n;
                for (n=0; n<GetArraySize(arTeam); n++)
                {
                    Ambient_Stop(arTeam[n]);
                }
                DEN_TeamFollow(DEN_TEAM_CAPTURED_STORAGE, TRUE);

                break;
            }
            case DEN_CAPTURED_INSPECTION_SHOT_DOWN_BY_EQUIPMENT_GUY:
            {
                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_REMOVED, TRUE, TRUE);
                UT_TeamJump(DEN_TEAM_CAPTURED_STORAGE, DEN_WP_CAPTURED_STORAGE_GUARDS);
                //UT_LocalJump(oPC, DEN_WP_CAPTURED_INSPECTION_FAILED, TRUE, FALSE, FALSE, TRUE);
                break;
            }
            case DEN_CAPTURED_INSPECTION_ABANDONED:
            {
                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_EQUIPMENT_ROOM, FALSE, OBJECT_TYPE_PLACEABLE);
                break;
            }
            case DEN_CAPTURED_INSPECTION_GUARDS_REMOVED:
            {
                DEN_TeamFollow(DEN_TEAM_CAPTURED_STORAGE, FALSE);
                break;
            }
            case DEN_CAPTURED_RECEPTION_DOOR_OPENED:
            {
                if (!WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_FRONT_GUARDS_ATTACKED))
                {
                    UT_Talk(oFrontGuard1, oMainControlled, DEN_CONV_FRONT_GUARDS);
                    if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_ESCAPING)
                        && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_PASSED))
                    {
                        WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_REJOINS, TRUE, TRUE);
                    }
                }
                break;
            }
            case DEN_CAPTURED_FRONT_GUARDS_DEFEATED:
            {
                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_HAS_REJOINED))
                {
                    UT_Talk(oMainControlled, oMainControlled, DEN_CONV_RESCUE_PARTY);
                }
                if (!WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_COMING_OUT, TRUE)
                    && !IsPartyPerceivingHostiles(oMainControlled))
                {
                    UT_TeamGoesHostile(DEN_TEAM_CAPTURED_MAIN_HALL, FALSE);
                }
                break;
            }

            case DEN_CAPTURED_PARTY_REJOINS:
            {
                object[] arrPool = GetPartyPoolList();
                int n;
                int nFollowers = 0;
                int nPoolSize = GetArraySize(arrPool);
                for(n = 0; n < nPoolSize; n++)
                {
                    if (GetFollowerState(arrPool[n]) == FOLLOWER_STATE_UNAVAILABLE)
                    {
                        WR_SetFollowerState(arrPool[n], FOLLOWER_STATE_AVAILABLE);
                    }
                }
                if (!WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED)
                    && WR_GetPlotFlag(PLT_GEN00PT_COMBOS, GEN_ALISTAIR_RECRUITED_AND_WARM, TRUE))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                    WR_ClearAllCommands(oAlistair, TRUE);
                    nFollowers++;
                }

                if (nFollowers < 2
                    && WR_GetPlotFlag(PLT_GEN00PT_COMBOS, GEN_MORRIGAN_RECRUITED_AND_WARM, TRUE))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY, TRUE, TRUE);
                    object oMorrigan    = Party_GetFollowerByTag(GEN_FL_MORRIGAN);
                    WR_ClearAllCommands(oMorrigan, TRUE);
                    nFollowers++;
                }
                if (nFollowers < 2
                    && WR_GetPlotFlag(PLT_GEN00PT_COMBOS, GEN_LELIANA_RECRUITED_AND_WARM, TRUE))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_PARTY, TRUE, TRUE);
                    object oLeliana    = Party_GetFollowerByTag(GEN_FL_LELIANA);
                    WR_ClearAllCommands(oLeliana, TRUE);
                    nFollowers++;
                }
                if (nFollowers < 2
                    && WR_GetPlotFlag(PLT_GEN00PT_COMBOS, GEN_ZEVRAN_RECRUITED_AND_WARM, TRUE))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_PARTY, TRUE, TRUE);
                    object oZevran    = Party_GetFollowerByTag(GEN_FL_ZEVRAN);
                    WR_ClearAllCommands(oZevran, TRUE);
                    nFollowers++;
                }
                if (nFollowers < 2
                    && WR_GetPlotFlag(PLT_GEN00PT_COMBOS, GEN_WYNNE_RECRUITED_AND_WARM, TRUE))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY, TRUE, TRUE);
                    object oWynne    = Party_GetFollowerByTag(GEN_FL_WYNNE);
                    WR_ClearAllCommands(oWynne, TRUE);
                    nFollowers++;
                }
                if (nFollowers < 2
                    && WR_GetPlotFlag(PLT_GEN00PT_COMBOS, GEN_STEN_RECRUITED_AND_WARM, TRUE))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_PARTY, TRUE, TRUE);
                    object oSten    = Party_GetFollowerByTag(GEN_FL_STEN);
                    WR_ClearAllCommands(oSten, TRUE);
                    nFollowers++;
                }
                if (nFollowers < 2
                    && WR_GetPlotFlag(PLT_GEN00PT_COMBOS, GEN_OGHREN_RECRUITED_AND_WARM, TRUE))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_PARTY, TRUE, TRUE);
                    object oOghren    = Party_GetFollowerByTag(GEN_FL_OGHREN);
                    WR_ClearAllCommands(oOghren, TRUE);
                    nFollowers++;
                }
                if (nFollowers == 1
                    && WR_GetPlotFlag(PLT_GEN00PT_COMBOS, GEN_DOG_RECRUITED_AND_WARM, TRUE))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY, TRUE, TRUE);
                    object oDog    = Party_GetFollowerByTag(GEN_FL_DOG);
                    WR_ClearAllCommands(oDog, TRUE);
                    nFollowers++;
                }
                if (nFollowers < 2
                    && WR_GetPlotFlag(PLT_GEN00PT_COMBOS, GEN_SHALE_RECRUITED_AND_WARM, TRUE))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_PARTY, TRUE, TRUE);
                    WR_ClearAllCommands(oShale, TRUE);
                    nFollowers++;
                }

                if (nFollowers)
                {
                    WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PARTY_HAS_REJOINED, TRUE);
                }

                break;
            }
            case DEN_CAPTURED_PC_REJOINS:
            {
                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_JAILOR_ATTACK_SOUND_START, TRUE, TRUE);

                SetObjectInteractive(oExit, TRUE);
                // **IMPORTANT** this must be cleared or it may mess up later plots
                DEN_SetPartyDialogOverride(INVALID_RESOURCE);

                UT_TeamAppears(DEN_TEAM_CAPTURED_MAIN_HALL, FALSE);
                SetPlaceableState(oReceptionDoor, PLC_STATE_DOOR_UNLOCKED);

                WR_SetFollowerState(oPC, FOLLOWER_STATE_ACTIVE);
                SetPartyLeader(oPC);
                //object oPlayerChest = UT_GetNearestObjectByTag(oMainControlled, DEN_IP_PLAYER_STORAGE_CHEST);
                //SetObjectInteractive(oPlayerChest, TRUE);

                DEN_RestoreInventory(oPC);

                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                {
                    DEN_RestoreInventory(oAlistair);
                }



                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                {
                    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY, TRUE, TRUE);
                }



                break;
            }
            case DEN_CAPTURED_FINAL_FIGHT:
            {
                SetPlaceableState(oBarracksDoor, PLC_STATE_DOOR_OPEN);
                SetPlaceableState(oCaptainsDoor, PLC_STATE_DOOR_OPEN);

                // Front guards joins the fray
                UT_TeamMove(DEN_TEAM_CAPTURED_FRONT_GUARDS, DEN_WP_CAPTURED_AUGUSTINE, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_FRONT_GUARDS);
                WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_FRONT_GUARDS_ATTACKED, TRUE, FALSE);

                // Captain joins the fray
                UT_TeamMove(DEN_TEAM_CAPTURED_CAPTAIN, DEN_WP_CAPTURED_AUGUSTINE, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_CAPTAIN);
                UT_TeamMerge(DEN_TEAM_CAPTURED_CAPTAIN, DEN_TEAM_CAPTURED_FRONT_GUARDS);

                // Barracks guards joins the fray
                DEN_TeamHelp(DEN_TEAM_CAPTURED_FRONT_GUARDS, TRUE);
                UT_TeamMove(DEN_TEAM_CAPTURED_BARRACKS, DEN_WP_CAPTURED_AUGUSTINE, TRUE);
                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_BARRACKS);
                UT_TeamMerge(DEN_TEAM_CAPTURED_BARRACKS, DEN_TEAM_CAPTURED_FRONT_GUARDS);


                UT_TeamGoesHostile(DEN_TEAM_CAPTURED_MAIN_HALL);
                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_MAIN_HALL, TRUE);

                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_COMING_OUT, TRUE))
                {
                    UT_TeamAppears(DEN_TEAM_CAPTURED_COLONEL, FALSE);
                    UT_TeamAppears(DEN_TEAM_CAPTURED_EQUIPMENT_ROOM, FALSE);
                    UT_TeamAppears(DEN_TEAM_CAPTURED_GUARD_POST, FALSE);
                    UT_TeamAppears(DEN_TEAM_CAPTURED_JAILOR, FALSE);
                    UT_TeamAppears(DEN_TEAM_CAPTURED_KENNEL, FALSE);
                    if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISED, TRUE))
                    {
                        WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_REMOVED, TRUE, TRUE);
                    }
                    else
                    {
                        UT_TeamAppears(DEN_TEAM_CAPTURED_STORAGE, FALSE);
                    }
                }


                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_ARMOR_RACK, FALSE, OBJECT_TYPE_PLACEABLE);
                UT_SetTeamInteractive(DEN_TEAM_CAPTURED_EQUIPMENT_ROOM, FALSE, OBJECT_TYPE_PLACEABLE);

                break;
            }
            case DEN_CAPTURED_PLOT_COMPLETE:
            {
                // **IMPORTANT** this must be cleared or it may mess up later plots
                DEN_SetPartyDialogOverride(INVALID_RESOURCE);

                if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISED, TRUE))
                {
                    DEN_RemoveDisguises();
                    if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_FOLLOWING_PLAYER, TRUE))
                    {
                        WR_SetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_REMOVED, TRUE, TRUE);
                    }
                }

                if (!WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_GOT_EQUIPMENT_BACK))
                {
                    DEN_RestoreInventory(oPC);

                    if (WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                    {
                        DEN_RestoreInventory(oAlistair);
                    }

                    DEN_RestoreInventory();
                }
                // Remove all party disguises
                object[] arParty = GetPartyList();
                int n;

                for (n = 0; n < GetArraySize(arParty); n++)
                {
                    UT_RemoveItemFromInventory(R"", -1, arParty[n], DEN_IT_CAPTURED_DISGUISE);
                    // Qwinn added, for Alistair
                    object[] oItems = GetItemsInInventory(arParty[n], GET_ITEMS_OPTION_EQUIPPED);
                    int nItem, nItems = GetArraySize(oItems);
                    for(nItem = 0; nItem < nItems; nItem++)
                    {
                        if(GetTag(oItems[nItem]) == "den400im_regulation_sword")
                           UnequipItem(arParty[n], oItems[nItem]);
                    }
                }

                UT_RemoveItemFromInventory(DEN_IM_CAPTURED_FRONT_HALL_KEY,2);
                UT_RemoveItemFromInventory(DEN_IM_CAPTURED_RECEPTION_KEY);
                UT_RemoveItemFromInventory(DEN_IM_CAPTURED_REAR_HALL_KEY);
                UT_RemoveItemFromInventory(DEN_IM_CAPTURED_CAGE_KEY, 10);
                UT_RemoveItemFromInventory(DEN_IM_CAPTURED_REGULATION_SWORD, 10);
                UT_RemoveItemFromInventory(DEN_IM_CAPTURED_PASSWORD_LIST);
                WR_SetWorldMapLocationStatus(oCM_Fort, WM_LOCATION_COMPLETE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_14);

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case DEN_CAPTURED_ALISTAIR_IN_PARTY_BUT_NOT_CAPTURED:
            {
                nResult = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY)
                         && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED);
                break;
            }
            case DEN_CAPTURED_PC_HAS_BEEN_IN_PRISON:
            {
                nResult = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_COMMONER)
                          || WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE);
                break;
            }
            case DEN_CAPTURED_PC_HUMAN_NEVER_IN_PRISON:
            {
                nResult = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_COMMONER)
                          || WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE)
                          || WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_CIRCLE);
                break;
            }
            case DEN_CAPTURED_STEN_OR_SHALE_IN_PARTY:
            {
                nResult = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_PARTY)
                            || WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_PARTY);
                break;
            }
            case DEN_CAPTURED_PARTY_COVERED_IN_GORE:
            {
                object[] arrParty = GetPartyList();
                int n = 0;
                object oPartyMember = arrParty[n];

                while (IsObjectValid(oPartyMember))
                {
                    if (GetCreatureGoreLevel(oPartyMember) > 0.01)
                    {
                        nResult = TRUE;
                        break; // exit loop
                    }
                    n++;
                    oPartyMember = arrParty[n];
                }
                break;
            }
            case DEN_CAPTURED_MALE_PC_SURRENDERED:
            {
                nResult = WR_GetPlotFlag(PLT_GEN00PT_COMBOS, GEN_HUMAN_MALE, TRUE)
                          && WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_SURRENDERED);
                break;
            }
            case DEN_CAPTURED_PC_CANT_BE_RESCUED:
            {
                int nPartyMembers   = 0;
                int nTalkers        = 0;

                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED))
                {
                    nPartyMembers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_RECRUITED))
                {
                    nPartyMembers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED)
                    && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }

                if (nPartyMembers < 2
                    || nTalkers < 1)
                {
                    nResult = TRUE;
                }
                break;
            }

            case DEN_CAPTURED_PC_CAN_BE_RESCUED_BY_SHALE:
            {
                int nPartyMembers   = 0;
                int nTalkers        = 0;
                int bShaleRecruited = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_RECRUITED);

                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED))
                {
                    nPartyMembers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED)
                    && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_ALISTAIR_CAPTURED))
                {
                    nPartyMembers++;
                    nTalkers++;
                }

                if (bShaleRecruited
                    && nPartyMembers < 2
                    && nTalkers == 1)
                {
                    nResult = TRUE;
                }
                break;
            }
            case DEN_CAPTURED_ACTIVE:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_CAPTURED)
                        && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PLOT_COMPLETE);
                break;
            }
            case DEN_CAPTURED_PC_DISGUISED:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_EQUIPPED)
                          && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_DISGUISE_REMOVED);
                break;
            }
            case DEN_CAPTURED_PC_COMING_OUT:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_ESCAPING)
                          || WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PC_REJOINS);
                break;
            }
            case DEN_CAPTURED_PC_HAS_MONEY_FOR_EQUIMPENT_GUY:
            {
                nResult = UT_MoneyCheck(oPC, 0, 0, DEN_MONEY_EQUIPMENT_GUY_BRIBE_GOLD);
                break;
            }
            case DEN_CAPTURED_PASSWORD_CAN_BE_USED:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_PASSWORD_ACQUIRED)
                          && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_FOLLOWING_PLAYER, TRUE);
                break;
            }
            case DEN_CAPTURED_INSPECTION_CAN_CONTINUE:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_ASSIGNED)
                          && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_ABANDONED)
                          && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_SHOT_DOWN_BY_EQUIPMENT_GUY)
                          && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_FAILED);
                break;
            }
            case DEN_CAPTURED_INSPECTION_GUARDS_FOLLOWING_PLAYER:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_JOINED)
                          && !WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_REMOVED);
                break;
            }
            case DEN_CAPTURED_INSPECTIONS_GUARDS_FOLLOWING_EQUIPMENT_GUY_LEFT:
            {
                int bEquipmentGuyGone = WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_EQUIPMENT_GUY_LEAVES)
                                        || WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_EQUIPMENT_GUY_KILLED);

                nResult = bEquipmentGuyGone
                          && WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_INSPECTION_GUARDS_FOLLOWING_PLAYER, TRUE);
                break;
            }
            case DEN_CAPTURED_MAIN_HALL_DISTRACTED_DEAD_FIGHTING_OR_GONE:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_MAIN_HALL_LEAVES)
                          || WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_SERGEANT_ATTACKED)
                          || WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_BALLISTA_WRECKED)
                          || WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_SERGEANT_LEAVES);
                break;
            }
            case DEN_CAPTURED_EQUIPMENT_GUY_PC_HAS_ACIDIC_COATING:
            {
                nResult = UT_CountItemInInventory(DEN_IM_ACID_COATING) >= 1;
                break;
            }
            case DEN_CAPTURED_EQUIPMENT_GUY_PC_HAS_ACIDIC_FLASK:
            {
                nResult = UT_CountItemInInventory(DEN_IM_ACID_FLASK) >= 1;
                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}