//==============================================================================
/*

    Prelude
     -> Light Beacon Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Yaron
// Created On: July 21st, 2006
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "sys_ambient_h"

#include "plt_gen00pt_backgrounds"
#include "pre_objects_h"
#include "pre100_bridge_attack_h"
#include "plt_prept_generic_actions"
#include "plt_pre100pt_darkspn_blood"
#include "plt_pre100pt_the_cache"
#include "plt_prept_defined_cond"

// Merchant Scaling
#include "af_scalestorefix_h"

int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent = GetCurrentEvent();            // Contains input parameters
    int     nType   = GetEventType(evEvent);        // GET or SET call
    string  sPlot   = GetEventString(evEvent, 0);   // Plot GUID
    int     nFlag   = GetEventInteger(evEvent, 1);  // The bit flag # affected
    object  oOwner  = GetEventCreator(evEvent);     // Script plot table owner

    // Grab Player, Set Default return to FALSE
    object  oPC     = GetHero();
    int     bResult = FALSE;

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evEvent);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    // IMPORTANT:   The flag value on a SET event is set only AFTER this script
    //              finishes running!
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger(evEvent, 3);  // Old flag value
        int nNewValue   = GetEventInteger(evEvent, 2);  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {


            case PRE_GA_END_CAILAN_CONVERSATION:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_END_CAILAN_CONVERSATION
                // ACTION:  King and guards walk off
                //          Close gate
                //          Duncan initiates conversation
                //--------------------------------------------------------------

                object      oCailan;
                object      oDuncan;
                object      oGuard1;
                object      oGuard2;
                object      oOpenGate;
                object      oClosedGate;

                //--------------------------------------------------------------

                oCailan     = UT_GetNearestCreatureByTag(oPC, PRE_CR_CAILAN);
                oDuncan     = UT_GetNearestCreatureByTag(oPC, PRE_CR_DUNCAN);
                oGuard1     = UT_GetNearestCreatureByTag(oPC, PRE_CR_KINGS_GUARD_1);
                oGuard2     = UT_GetNearestCreatureByTag(oPC, PRE_CR_KINGS_GUARD_2);

                //--------------------------------------------------------------

                WR_SetObjectActive(oGuard1, FALSE);
                WR_SetObjectActive(oGuard2, FALSE);
                WR_SetObjectActive(oCailan, FALSE);

                UT_Talk(oDuncan, oPC);

                break;

            }


            case PRE_GA_BLOOD_ACCEPTED_AND_CACHE_ACCEPTED:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_BLOOD_ACCEPTED_AND_CACHE_ACCEPTED
                // PLOT:    Darkspawn Blood and Cache plots both accepted
                //--------------------------------------------------------------

                //object      oDaveth;
                //object      oJory;

                //--------------------------------------------------------------

                //oDaveth = UT_GetNearestCreatureByTag(oPC, PRE_CR_DAVETH);
                //oJory   = UT_GetNearestCreatureByTag(oPC, PRE_CR_JORY);

                //--------------------------------------------------------------

                WR_SetPlotFlag( PLT_PRE100PT_DARKSPN_BLOOD, PRE_BLOOD_PLOT_ACCEPTED, TRUE, TRUE);
                WR_SetPlotFlag( PLT_PRE100PT_THE_CACHE, PRE_CACHE_PLOT_ACCEPTED, TRUE, TRUE);

                //UT_HireFollower(oDaveth, TRUE);
                //UT_HireFollower(oJory, TRUE);

                break;

            }

            case PRE_GA_JORY_AND_DAVETH_JOIN:
            {
                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_JORY_AND_DAVETH_JOIN
                // ACTION:  Jory and Daveth join party
                //--------------------------------------------------------------

                object      oDaveth;
                object      oJory;

                //--------------------------------------------------------------

                oDaveth = UT_GetNearestCreatureByTag(oPC, PRE_CR_DAVETH);
                oJory   = UT_GetNearestCreatureByTag(oPC, PRE_CR_JORY);

                //--------------------------------------------------------------

                UT_HireFollower(oDaveth, TRUE);
                UT_HireFollower(oJory, TRUE);

                break;

            }


            case PRE_GA_BLOOD_DONE_AND_CACHE_DONE:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_BLOOD_DONE_AND_CACHE_DONE
                //--------------------------------------------------------------

                WR_SetPlotFlag( PLT_PRE100PT_DARKSPN_BLOOD, PRE_BLOOD_PLOT_DONE, TRUE, TRUE);
                WR_SetPlotFlag( PLT_PRE100PT_THE_CACHE, PRE_CACHE_PLOT_DONE, TRUE, TRUE);

                break;

            }


            case PRE_GA_ARGUE_WIZARD_LEAVE:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_ARGUE_WIZARD_LEAVE
                //--------------------------------------------------------------

                object      oArgueWizard;

                //--------------------------------------------------------------

                oArgueWizard = UT_GetNearestCreatureByTag(oPC, PRE_CR_ARGUE_WIZARD);

                //--------------------------------------------------------------

                WR_SetObjectActive(oArgueWizard, FALSE);

                break;

            }


            case PRE_GA_JUMP_DAVETH_TO_DUNCANS_FIRE:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_JUMP_DAVETH_TO_DUNCANS_FIRE
                //--------------------------------------------------------------

                object      oDaveth;

                //--------------------------------------------------------------

                oDaveth = UT_GetNearestCreatureByTag(oPC, PRE_CR_DAVETH);

                //--------------------------------------------------------------

                UT_LocalJump(oDaveth, PRE_WP_DUNCANS_FIRE_DAVETH);

                // The soldier near Daveth starts ambient behavior at this point.
                //AMB_StartAmbientAI(oDavethSoldier);

                break;

            }


            case PRE_GA_JUMP_JORY_TO_DUNCANS_FIRE:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_JUMP_JORY_TO_DUNCANS_FIRE
                //--------------------------------------------------------------

                object      oJory;

                //--------------------------------------------------------------

                oJory = UT_GetNearestCreatureByTag(oPC, PRE_CR_JORY);

                //--------------------------------------------------------------

                UT_LocalJump(oJory, PRE_WP_DUNCANS_FIRE_JORY);

                break;

            }


            case PRE_GA_OPEN_STORE_GENTLE:
            {

                if (!nNewValue)
                    break;

                break;

            }


            case PRE_GA_LOGHAIN_RETURN_TO_TENT:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_LOGHAIN_RETURN_TO_TENT
                // ACTION:  Deactive Loghain
                //--------------------------------------------------------------

                object      oLoghain;

                //--------------------------------------------------------------

                oLoghain = UT_GetNearestCreatureByTag(oPC, PRE_CR_LOGHAIN);

                //--------------------------------------------------------------

                WR_SetObjectActive(oLoghain, FALSE);

                break;

            }


            case PRE_GA_OPEN_STORE_QUARTERMASTER:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_OPEN_STORE_QUARTERMASTER
                // ACTION:  Open Store
                //--------------------------------------------------------------

                object      oStore;

                //--------------------------------------------------------------

                oStore = UT_GetNearestObjectByTag(oPC, PRE_SR_QUARTERMASTER);

                //--------------------------------------------------------------
                ScaleStoreEdited(oStore); // Merchant Scaling
                OpenStore(oStore);

                break;

            }


            case PRE_GA_OPEN_STORE_QUARTERMASTER_SPECIAL:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_OPEN_STORE_QUARTERMASTER_SPECIAL
                // ACTION:  Open Store
                //--------------------------------------------------------------

                object      oStore;

                //--------------------------------------------------------------

                oStore = UT_GetNearestObjectByTag(oPC, PRE_SR_QUARTERMASTER_SPECIAL);

                //--------------------------------------------------------------
                ScaleStoreEdited(oStore); // Merchant Scaling
                OpenStore(oStore);

                break;

            }


            case PRE_GA_LOGHAIN_EXIT_TENT:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_LOGHAIN_EXIT_TENT
                // ACTION:  Jump Loghain to outside of tent
                //          Activate Loghain + Dialog
                //--------------------------------------------------------------

                object      oLoghain;

                //--------------------------------------------------------------

                oLoghain = UT_GetNearestCreatureByTag(oPC, PRE_CR_LOGHAIN);

                //--------------------------------------------------------------

                UT_LocalJump(oLoghain, PRE_WP_LOGHAIN_TENT);
                WR_SetObjectActive(oLoghain, TRUE);
                UT_Talk(oLoghain, oPC);

                break;

            }


            case PRE_GA_TOWER_GUARD_JOINS:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_TOWER_GUARD_JOINS
                //--------------------------------------------------------------

                object      oTowerGuard1;
                object      oTowerGuard2;
                object      oTowerGuard3;

                //--------------------------------------------------------------

                oTowerGuard1 = UT_GetNearestObjectByTag(oPC, PRE_CR_TOWER_GUARD);
                oTowerGuard2 = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER);
                oTowerGuard3 = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER_MAGE);

                //--------------------------------------------------------------

                // first red shirt joins
                // @joshua: if not human noble, other redshirt joins
                if (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_HUMAN_NOBLE))
                {
                    WR_SetObjectActive(oTowerGuard2, FALSE);
                    UT_HireFollower(oTowerGuard3, TRUE);
                    UT_ExitDestroy(oTowerGuard1, TRUE, "pre100ip_bridge_gate");

                }
                else if (GetCreatureCoreClass(oPC) == CLASS_WIZARD)
                {
                    WR_SetObjectActive(oTowerGuard3, FALSE);
                    UT_HireFollower(oTowerGuard1, TRUE);
                    UT_HireFollower(oTowerGuard2, TRUE);

                }
                else
                {
                    WR_SetObjectActive(oTowerGuard2, FALSE);
                    UT_HireFollower(oTowerGuard1, TRUE);
                    UT_HireFollower(oTowerGuard3, TRUE);

                }


                break;

            }


            case PRE_GA_TOWER_GUARD_LEAVES:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_END_CAILAN_CONVERSATION
                //--------------------------------------------------------------

                object      oTowerGuard1;
                object      oTowerGuard2;
                object      oTowerGuard3;

                //--------------------------------------------------------------

                oTowerGuard1 = UT_GetNearestObjectByTag(oPC, PRE_CR_TOWER_GUARD);
                oTowerGuard2 = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER);
                oTowerGuard3 = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER_MAGE);

                //--------------------------------------------------------------

                // second red shirt leaves
                UT_FireFollower(oTowerGuard1, TRUE, FALSE);
                WR_SetObjectActive(oTowerGuard1, FALSE);

                 if (UT_IsFollowerInParty(oTowerGuard2) == TRUE)
                    {
                        // second red shirt leaves
                        UT_FireFollower(oTowerGuard2, TRUE, FALSE);
                        WR_SetObjectActive(oTowerGuard2, FALSE);
                    }

                if (UT_IsFollowerInParty(oTowerGuard3) == TRUE)
                    {
                        // mage red shirt leaves
                        UT_FireFollower(oTowerGuard3, TRUE, FALSE);
                        WR_SetObjectActive(oTowerGuard3, FALSE);
                    }

                break;

            }


            case PRE_GA_TOWER_GUARD_2_LEAVES:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_END_CAILAN_CONVERSATION
                //--------------------------------------------------------------

                object      oTowerGuard2;
                object      oTowerGuard3;

                //--------------------------------------------------------------

                oTowerGuard2 = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER);
                oTowerGuard3 = UT_GetNearestObjectByTag(oPC, PRE_CR_HELPER_MAGE);

                //--------------------------------------------------------------

                if (UT_IsFollowerInParty(oTowerGuard2) == TRUE)
                    {
                        // second red shirt leaves
                        UT_FireFollower(oTowerGuard2, TRUE, FALSE);
                        WR_SetObjectActive(oTowerGuard2, FALSE);
                    }

                if (UT_IsFollowerInParty(oTowerGuard3) == TRUE)
                    {
                        // mage red shirt leaves
                        UT_FireFollower(oTowerGuard3, TRUE, FALSE);
                        WR_SetObjectActive(oTowerGuard3, FALSE);
                    }

                break;

            }


            case PRE_GA_SPAWN_SPRITE_ARMY:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_SPAWN_SPRITE_ARMY
                //--------------------------------------------------------------

                int         nIndex;
                int         nArraySize;
                int         nVFX;
                string      sTag;
                object      oCurrent;
                object []   arSprites;

                //--------------------------------------------------------------

                arSprites  = UT_GetTeam(PRE_TEAM_SPRITE_ARMY,OBJECT_TYPE_PLACEABLE);
                nArraySize = GetArraySize(arSprites);

                //--------------------------------------------------------------

                for ( nIndex = 0; nIndex < nArraySize; nIndex++)
                {
                    oCurrent = arSprites[nIndex];
                    sTag = GetTag(oCurrent);
                    nVFX = 0;
                    if (sTag=="pre100ip_sa_darkspawn_army")     nVFX = 10004;
                    else if (sTag=="pre100ip_sa_dead_army")     nVFX = 10006;
                    else if (sTag=="pre100ip_sa_fight_close")   nVFX = 10008;
                    else if (sTag=="pre100ip_sa_fire")          nVFX = 27;
                    else if (sTag=="pre100ip_sa_good_army")     nVFX = 10003;
                    else if (sTag=="pre100ip_sa_torches")       nVFX = 10001;
                    else if (sTag=="pre100ip_sa_ogre")          nVFX = 10010;
                    if(nVFX)
                    {
                        location lLoc = GetLocation(oCurrent);
                        vector vO = GetOrientationFromLocation(lLoc);
                        LogTrace(LOG_CHANNEL_TEMP,ToString(vO.x)+":"+ToString(vO.y)+":"+ToString(vO.z),oCurrent);
                        Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_PERMANENT, EffectVisualEffect(nVFX),GetLocation(oCurrent));
                    }
                }

                // Set that the sprite army is currently visible
                WR_SetPlotFlag( sPlot, PRE_GA_SPRITE_ARMY_ON, TRUE );

                break;

            }


            case PRE_GA_BRIDGE_DEFENSE_START_IMPACTS:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_BRIDGE_DEFENSE_START_IMPACTS
                //--------------------------------------------------------------

                PRE_BridgeAttack_Start();

                break;

            }

            case PRE_GA_PLAYER_REEQUIPPED_IN_HUT:
            {
                if (!nNewValue)
                    break;

                object oPC;
                object oFootLocker;

                //--------------------------------------------------------------

                oPC = GetHero();
                oFootLocker = UT_GetNearestObjectByTag(oPC, PRE_IP_FOOTLOCKER);

                //--------------------------------------------------------------

                RestoreFollowerInventory(oPC, oFootLocker);

                break;
            }




            case PRE_GA_MORRIGAN_BRINGS_BELONGING:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_END_CAILAN_CONVERSATION
                //--------------------------------------------------------------

                object oMorrigan;

                //--------------------------------------------------------------

                oMorrigan = UT_GetNearestCreatureByTag(oPC, GEN_FL_MORRIGAN);

                //--------------------------------------------------------------

                // CUTSCENE: Morrigan goes into the house - fade to black - fade out of black<END CUTSCENE>
                UT_Talk(oMorrigan, oPC);

                break;

            }


            case PRE_GA_MORRIGAN_COMES_OUT_OF_HUT:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_MORRIGAN_COMES_OUT_OF_HUT
                //--------------------------------------------------------------

                object oMorrigan;

                //--------------------------------------------------------------

                oMorrigan = UT_GetNearestCreatureByTag(oPC, GEN_FL_MORRIGAN);

                //--------------------------------------------------------------

                // Morrigan comes out of the hut and inits dialog

                WR_SetObjectActive(oMorrigan, TRUE);
                UT_Talk(oMorrigan, oPC);

                break;

            }


            case PRE_GA_MORRIGAN_ESCORTS_OUT_OF_WILDS:
            {

                if (!nNewValue)
                    break;

                //--------------------------------------------------------------
                // PRE_GA_END_CAILAN_CONVERSATION
                //--------------------------------------------------------------

                int     bPCHasBloodAndDocs;

                //--------------------------------------------------------------

                bPCHasBloodAndDocs = WR_GetPlotFlag(PLT_PREPT_DEFINED_COND, PRE_DEFINED_GOT_BLOOD_AND_DOCUMENTS, TRUE);

                //--------------------------------------------------------------

                // Change: party is transported back to King's camp
                if (bPCHasBloodAndDocs)
                    UT_DoAreaTransition(PRE_AR_KINGS_CAMP_NIGHT, PRE_WP_FROM_WILDS);
                else
                    UT_DoAreaTransition(PRE_AR_KINGS_CAMP, PRE_WP_FROM_WILDS);

                break;

            }

            case PRE_GA_AMBIENT_DAVETH_STOP:
            {
                object oDaveth = UT_GetNearestCreatureByTag(oPC, PRE_CR_DAVETH);

                Ambient_Stop(oDaveth);
                WR_AddCommand(oDaveth, CommandPlayAnimation(1), TRUE);

                break;
            }

            case PRE_GA_STEALING_KNIGHT_RETURNS:
            {
                 UT_QuickMove(PRE_CR_KNIGHT_STEALING, PRE_WP_KNIGHT_STEALING_BY_TENT, TRUE);
                 break;
            }

            case PRE_GA_DAVETHS_WOMAN_LEAVES:
            {
                object oWoman = UT_GetNearestCreatureByTag(oPC, PRE_CR_SOLDIER_FEM_1);

                UT_ExitDestroy(oWoman, FALSE, "mp_pre100cr_soldier_fem_1");
            }

        }
    }

    //--------------------------------------------------------------------------
    // Conditions -> defined flags only (GET DEFINED)
    //--------------------------------------------------------------------------

    else
    {

        // Check for which flag was checked
        switch(nFlag)
        {
        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}