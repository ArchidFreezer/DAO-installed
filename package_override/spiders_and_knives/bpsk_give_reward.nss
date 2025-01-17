// This script is to handle giving of rewards by Ser Arbither, callable from dialogue.
//

//--------------------------------------------------------------------------------------------------
// MAIN
//--------------------------------------------------------------------------------------------------

#include "utility_h"
#include "wrappers_h"
#include "plt_gen00pt_class_race_gend"
#include "plt_bp_spiders_knives"
#include "plt_bpsk_rescue_knives"
#include "plt_bpsk_retake_manor"

void main()
{
    object oPC = GetHero();
    int nReward = 0;

    //Reward for rescuing Ser Arbither
    if ((WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_FOUND)) &&
        !(WR_GetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_REWARD_GIVEN)))
    {
        nReward += 10000;                    //1 gold.
        WR_SetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_REWARD_GIVEN,TRUE,TRUE);
    }

    //Reward for returning her father's things
    if ((WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BLADES_RETURNED)) &&
        !(WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_REWARD_GIVEN)))
    {
        nReward += 40000;                    //4 gold.
        WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_REWARD_GIVEN,TRUE,TRUE);
        WR_SetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_REWARD_GIVEN,TRUE);
    }

    //Reward for helping retake Knife Edge
    if ((WR_GetPlotFlag(PLT_BPSK_RETAKE_MANOR,MANOR_RETAKEN)) &&
        !(WR_GetPlotFlag(PLT_BPSK_RETAKE_MANOR,MANOR_REWARD_GIVEN)))
    {
        if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BLADES_RETURNED))
        {
            if (WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_CLASS_MAGE))
            {
                UT_AddItemToInventory(R"bpsk_knotwood_staff_low.uti");
            }
            if (WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_CLASS_ROGUE))
            {
                UT_AddItemToInventory(R"bpsk_ashyera_dagger.uti");
            }
            if (WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_CLASS_WARRIOR))
            {
                int nWeaponStyle = GetWeaponStyle(oPC);
                if (nWeaponStyle == 3)      // Two-handed
                {
                    UT_AddItemToInventory(R"bpsk_hjorrmikill_low.uti");
                }else{
                    UT_AddItemToInventory(R"bpsk_thunderer.uti");
                }
            }

            nReward += 20000;                    //2 gold as well
        }else{
            nReward += 20000;                    //just 2 gold
        }
        WR_SetPlotFlag(PLT_BPSK_RETAKE_MANOR,MANOR_REWARD_GIVEN,TRUE,TRUE);
        WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_QUEST_COMPLETE,TRUE);
    }
    //Reward for Defending Knife Edge 
    // NB This code is duplicated in bpsk_knife-edge.nss as AddItem doesn't appear to work during/after the cutscene
    if ((WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_MANOR_DEFENDED)) &&
        !(WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_DEF_REWARD_GIVEN)))
    {
        nReward += 60000;                    //6 gold.

        if (WR_GetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_BLADES_RETURNED))
        {
//            UT_AddItemToInventory(R"bpsk_amulet_hi.uti",1);   // Recovered amulet
            object oTest = UT_AddItemToInventory(R"bpsk_amulet_hi.uti",1);   // Recovered amulet
            if (oTest == OBJECT_INVALID)
            {
                DisplayFloatyMessage(oPC,"Amulet NOT received.",FLOATY_MESSAGE,0xff0000,10.0);
            }
            // Upgrade previously given weapon, if used
            int iCount = UT_CountItemInInventory(R"bpsk_knotwood_staff_low.uti");
            if (iCount > 0)
            {
                UT_RemoveItemFromInventory(R"bpsk_knotwood_staff_low.uti");
                UT_AddItemToInventory(R"bpsk_knotwood_staff_hi.uti");
            }
            iCount = UT_CountItemInInventory(R"bpsk_ashyera_dagger.uti");
            if (iCount > 0)
            {
                UT_RemoveItemFromInventory(R"bpsk_ashyera_dagger.uti");
                UT_AddItemToInventory(R"bpsk_ashyera_dagger_hi.uti",1);
            }
            iCount = UT_CountItemInInventory(R"bpsk_hjorrmikill_low.uti");
            if (iCount > 0)
            {
                UT_RemoveItemFromInventory(R"bpsk_hjorrmikill_low.uti");
                UT_AddItemToInventory(R"bpsk_hjorrmikill_hi.uti");
            }
            iCount = UT_CountItemInInventory(R"bpsk_thunderer.uti");
            if (iCount > 0)
            {
                UT_RemoveItemFromInventory(R"bpsk_thunderer.uti");
                UT_AddItemToInventory(R"bpsk_thunderer_hi.uti");
            }
         }
        WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_DEF_REWARD_GIVEN,TRUE,TRUE);
    }


    if (nReward > 0)
    {
        AddCreatureMoney(nReward, oPC, TRUE);
    }
    // Reward given, so clear plot marker
    object oKnives = GetObjectByTag("bpsk_knives");
    SetPlotGiver(oKnives,FALSE);
}