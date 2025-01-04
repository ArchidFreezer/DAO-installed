//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Sheryl
//:: Created On: Feb 27th, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "arl_constants_h"
#include "arl_functions_h"

#include "plt_arl300pt_fade"
#include "plt_arl200pt_remove_demon"
#include "plt_gen00pt_party"

#include "plt_cod_cha_isolde"
#include "plt_cod_cha_connor"

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
    object oConnor = UT_GetNearestCreatureByTag(oPC, ARL_CR_FAKE_CONNOR);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
        case ARL_FADE_FADE_ENTERED:
        {
            //This is triggered once when the player enters the fade.

            int bMorriganActive = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_MORRIGAN_IN_FADE);
            int bWynneActive = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_WYNNE_IN_FADE);
            int bJowanActive = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_JOWAN_IN_FADE);
            int bIrvingActive = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_IRVING_IN_FADE);
            object oMorrigan = UT_GetNearestCreatureByTag(oPC, GEN_FL_MORRIGAN);
            object oWynne = UT_GetNearestCreatureByTag(oPC, GEN_FL_WYNNE);
            object oJowan = UT_GetNearestCreatureByTag(oPC, ARL_CR_JOWAN);
            object oIrving = UT_GetNearestCreatureByTag(oPC, ARL_CR_IRVING);

            object oPartyInventoryStorage = UT_GetNearestObjectByTag(oPC, ARL_IP_FADE_PARTY_INVENTORY_STORAGE);

            object [] arParty = GetPartyList(GetHero());
            int nSize = GetArraySize(arParty);
            int nIndex;
            object oCurrent;

            //Remove all party members from the party and store them to be added later.
            UT_PartyStore();


            //set all (former) party members other than the hero, Wynne and Morrigan to inactive.
            for(nIndex = 0; nIndex < nSize; nIndex++)
            {
                oCurrent = arParty[nIndex];

                if ((IsHero(oCurrent) == FALSE) && (oCurrent != oWynne) && (oCurrent != oMorrigan))
                {
                    WR_SetObjectActive(oCurrent, FALSE);
                }
            }

            //Add Morrigan to the party if she was sent, otherwise set her inactive.
            if (bMorriganActive == TRUE)
            {
                WR_SetFollowerState(oMorrigan, FOLLOWER_STATE_ACTIVE);
                SetPartyLeader(oMorrigan);
                WR_SetFollowerState(oPC, FOLLOWER_STATE_UNAVAILABLE);
                WR_SetObjectActive(oPC, FALSE);

            }
            else if (IsObjectValid(oMorrigan) == TRUE)
            {
                WR_SetObjectActive(oMorrigan, FALSE);
            }

            //Add Wynne to the party if she was sent, otherwise set her inactive.
            if (bWynneActive == TRUE)
            {
                WR_SetFollowerState(oWynne, FOLLOWER_STATE_ACTIVE);
                SetPartyLeader(oWynne);
                WR_SetFollowerState(oPC, FOLLOWER_STATE_UNAVAILABLE);
                WR_SetObjectActive(oPC, FALSE);
            }
            else if (IsObjectValid(oWynne) == TRUE)
            {
                WR_SetObjectActive(oWynne, FALSE);
            }

            //Add Jowan to the party if he was sent, otherwise set him inactive.
            if (bJowanActive == TRUE)
            {
                StorePartyInventory(oPartyInventoryStorage);
                WR_SetObjectActive(oJowan, TRUE);
                UT_HireFollower(oJowan);
                SetPartyLeader(oJowan);
                object oMagicStaff = CreateItemOnObject(ARL_R_IT_JOWAN_FADE_STAFF, oJowan, 1, "", TRUE);
                EquipItem(oJowan, oMagicStaff, INVENTORY_SLOT_MAIN);
                WR_SetFollowerState(oPC, FOLLOWER_STATE_UNAVAILABLE);
                WR_SetObjectActive(oPC, FALSE);

            }
            else
            {
                WR_SetObjectActive(oJowan, FALSE);
            }

            //Add Irving to the party if he was sent, otherwise set him inactive.
            if (bIrvingActive == TRUE)
            {
                StorePartyInventory(oPartyInventoryStorage);
                WR_SetObjectActive(oIrving, TRUE);
                UT_HireFollower(oIrving);
                SetPartyLeader(oIrving);
                WR_SetFollowerState(oPC, FOLLOWER_STATE_UNAVAILABLE);
                WR_SetObjectActive(oPC, FALSE);

            }
            else
            {
                WR_SetObjectActive(oIrving, FALSE);
            }

            //Activate the first door.
            object[] oDoorArray = GetTeam(ARL_TEAM_DEMON_1, OBJECT_TYPE_PLACEABLE);
            object oDoor = oDoorArray[0];
            //VFX 1093 is divine restoration
            RemoveEffectsByParameters(oDoor, EFFECT_TYPE_VISUAL_EFFECT);
            ApplyEffectVisualEffect(oPC, oDoor, ARL_VFX_FADE_ACTIVE_PORTAL, EFFECT_DURATION_TYPE_PERMANENT, 0.0);

            //Make the ambient eamons and connors ghosts.
            object[] oGhostsArray = GetTeam(ARL_TEAM_FADE_GHOSTS);
            nSize = GetArraySize(oGhostsArray);
            for (nIndex = 0; nIndex < nSize; nIndex++)
            {
                object oGhost = oGhostsArray[nIndex];
                SetCreatureIsGhost(oGhost, TRUE);
                ApplyEffectVisualEffect(oPC, oGhost, VFX_CRUST_GHOST, EFFECT_DURATION_TYPE_PERMANENT, 0.0);
            }

            DoAutoSave();

        }
        break;

        case ARL_FADE_DEMON_FIGHT_1:
        {
            WR_SetObjectActive(oConnor, FALSE);
            UT_LocalJump(oConnor, ARL_WP_CONNOR_2);
            UT_TeamAppears(ARL_TEAM_DEMON_1, TRUE);
        }
        break;

        case ARL_FADE_DEMON_FIGHT_2:
        {
            WR_SetObjectActive(oConnor, FALSE);
            UT_LocalJump(oConnor, ARL_WP_CONNOR_3);
            UT_TeamAppears(ARL_TEAM_DEMON_2, TRUE);
        }
        break;

        case ARL_FADE_DEMON_FIGHT_3:
        {
            WR_SetObjectActive(oConnor, FALSE);
            UT_TeamAppears(ARL_TEAM_DEMON_3, TRUE);
        }
        break;

        case ARL_FADE_DEMON_FIGHT_FINAL:
        {
            UT_TeamGoesHostile(ARL_TEAM_DEMON_4, TRUE);
        }
        break;

        case ARL_FADE_DEMON_OFFER_BLOOD_MAGIC:
        {
            //Player asked for blood magic.
            RW_UnlockSpecializationTrainer(SPC_BLOOD_MAGE);
        }
        break;

        case ARL_FADE_DEMON_OFFER_TALENT:
        {
            //Player asked for Talent point
            UT_AddItemToInventory(ARL_R_IT_FADE_REWARD_TOME);
        }
        break;

        case ARL_FADE_RESOLVED:
        {
            object oMorrigan = UT_GetNearestCreatureByTag(oPC, GEN_FL_MORRIGAN);
            object oWynne = UT_GetNearestCreatureByTag(oPC, GEN_FL_WYNNE);
            object oJowan = UT_GetNearestCreatureByTag(oPC, ARL_CR_JOWAN);
            object oIrving = UT_GetNearestCreatureByTag(oPC, ARL_CR_IRVING);

            object oFollower1 = GetLocalObject(GetModule(), PARTY_STORE_SLOT_1);
            object oFollower2 = GetLocalObject(GetModule(), PARTY_STORE_SLOT_2);
            object oFollower3 = GetLocalObject(GetModule(), PARTY_STORE_SLOT_3);

            object oPartyInventoryStorage = UT_GetNearestObjectByTag(oPC, ARL_IP_FADE_PARTY_INVENTORY_STORAGE);
            object oInventoryDump = UT_GetNearestObjectByTag(oPC, ARL_IP_FADE_BORROWED_INVENTORY_DUMP);

            int bMorriganActive = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_MORRIGAN_IN_FADE);
            int bWynneActive = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_WYNNE_IN_FADE);

            //Restore the PC as party leader (could be redundant)
            WR_SetObjectActive(oPC, TRUE);
            WR_SetFollowerState(oPC, FOLLOWER_STATE_ACTIVE);
            SetPartyLeader(oPC);

            //Remove Morrigan and Wynne from the active party
            if (bMorriganActive == TRUE)
            {
                WR_SetFollowerState(oMorrigan, FOLLOWER_STATE_UNAVAILABLE);
            }
            if (bWynneActive == TRUE)
            {
                WR_SetFollowerState(oWynne, FOLLOWER_STATE_UNAVAILABLE);
            }

            //Activate all of the stored followers.
            if (IsObjectValid(oFollower1) == TRUE)
            {
                WR_SetObjectActive(oFollower1, TRUE);
            }
            if (IsObjectValid(oFollower2) == TRUE)
            {
                WR_SetObjectActive(oFollower2, TRUE);
            }
            if (IsObjectValid(oFollower3) == TRUE)
            {
                WR_SetObjectActive(oFollower3, TRUE);
            }

            //If Jowan was used, get rid of him.
            if (WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_JOWAN_IN_FADE) == TRUE)
            {
                StorePartyInventory(oInventoryDump);
                //ARL_DestroyAllItemsInIventory(oJowan);
                UT_FireFollower(oJowan, TRUE, FALSE);

                RestorePartyInventory(oPartyInventoryStorage);
                WR_SetObjectActive(oJowan, FALSE);
            }

            //If Irving was used, get rid of him.
            if (WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_IRVING_IN_FADE) == TRUE)
            {
                StorePartyInventory(oInventoryDump);
                //ARL_DestroyAllItemsInIventory(oJowan);
                UT_FireFollower(oIrving, TRUE, FALSE);
                RestorePartyInventory(oPartyInventoryStorage);
                WR_SetObjectActive(oIrving, FALSE);
            }


            UT_PartyRestore();

            //Update the codex
            int bCircleDoesRitual = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_CIRCLE_DOES_RITUAL);
            // Qwinn: The following line was checking for TRUE originally, which made the entries the opposite of what they should have been.
            // if (bCircleDoesRitual == TRUE)
            if (bCircleDoesRitual == FALSE)
            {
                WR_SetPlotFlag(PLT_COD_CHA_ISOLDE, COD_CHA_ISOLDE_DIES, TRUE, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_CONNOR, COD_CHA_CONNOR_ISOLDE_DIES, TRUE, TRUE);
            }
            else
            {
                WR_SetPlotFlag(PLT_COD_CHA_ISOLDE, COD_CHA_ISOLDE_CIRCLE_TO_THE_RESCUE, TRUE, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_CONNOR, COD_CHA_CONNOR_AND_ISOLDE_SAVED, TRUE, TRUE);
            }

            WR_SetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_CONNOR_FREED, TRUE, TRUE);
            WR_SetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_DEMON_DEALT_WITH, TRUE, TRUE);
            //Jumping to cutscene instead of
            //UT_DoAreaTransition(ARL_AR_CASTLE_UPSTAIRS, ARL_WP_BY_EAMON);
            WR_SetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_START_FUNERAL_CUTSCENE, TRUE, TRUE);

            //percentage complete plot tracking
            ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_5f);
        }
        break;

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case ARL_FADE_NPC_IN_FADE:
            {
                // IF ARL_FADE_JOWAN_IN_FADE
                // OR
                // IF ARL_FADE_MORRIGAN_IN_FADE
                // OR
                // IF ARL_FADE_WYNNE_IN_FADE

                int bJowanGoes = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_JOWAN_IN_FADE);
                int bMorriganGoes = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_MORRIGAN_IN_FADE);
                int bWynneGoes = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_WYNNE_IN_FADE);
                int bIrvingGoes = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_IRVING_IN_FADE);

                nResult = (bJowanGoes == TRUE) || (bMorriganGoes == TRUE) || (bWynneGoes == TRUE) || (bIrvingGoes == TRUE);

            }
            break;

            case ARL_FADE_CONNOR_WILL_BE_REPOSSESSED:
            {
                int bDealAccepted = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_OFFER_ACCEPTED_FROM_DEMON);
                int bDemonIntimidated = WR_GetPlotFlag(PLT_ARL300PT_FADE, ARL_FADE_DEMON_INTIMIDATED);

                nResult = (bDealAccepted == TRUE) && (bDemonIntimidated == FALSE);
            }
            break;

        }


    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}