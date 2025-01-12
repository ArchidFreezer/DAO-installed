//==============================================================================
/*

    Follower Scripting
     -> Oghren Main Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: May 18, 2007
//==============================================================================

#include "plt_genpt_oghren_main"
#include "plt_genpt_oghren_events"

#include "orz_constants_h"
#include "urn_constants_h"
#include "cir_constants_h"

#include "campaign_h"
#include "wrappers_h"
#include "utility_h"
#include "plot_h"
#include "sys_ambient_h"

#include "plt_cod_cha_oghren"
#include "plt_genpt_app_oghren"
#include "plt_mnp000pt_autoss_main2"

int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evParms = GetCurrentEvent();            // Contains input parameters
    int     nType   = GetEventType(evParms);        // GET or SET call
    string  sPlot   = GetEventString(evParms, 0);   // Plot GUID
    int     nFlag   = GetEventInteger(evParms, 1);  // The bit flag # affected
    object  oOwner  = GetEventCreator(evParms);     // Script plot table owner

    // Grab Player, Set Default return to FALSE
    object  oPC     = GetHero();
    int     bResult = FALSE;
    object oFelsi =  UT_GetNearestCreatureByTag(oPC,URN_CR_FELSI);
    object oOghren = UT_GetNearestObjectByTag(oPC,GEN_FL_OGHREN);

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evParms);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    //--------------------------------------------------------------------------

    if( nType == EVENT_TYPE_SET_PLOT )
    {

        int nOldValue   = GetEventInteger(evParms, 3);  // Old flag value
        int nNewValue   = GetEventInteger(evParms, 2);  // New flag value

        // Check for which flag was set
        switch(nFlag)
        {
            case OGHREN_MAIN_PARAGON_LEAVES_FOR_TAPSTERS:
            {

                //--------------------------------------------------------------
                // ACTION:  Oghren and the PC's Party are teleported to the
                //          Deeproads Map
                //--------------------------------------------------------------

                //--------------------------------------------------------------

                object oLoilinar = GetObjectByTag( ORZ_CR_LOILINAR );

                SetObjectInteractive( oLoilinar, TRUE );

                //WR_SetObjectActive( oOghren, FALSE );
                UT_ExitDestroy( oOghren );

                break;

            }

            case OGHREN_MAIN_PARAGON_TELEPORT_TO_UNDERMAP:
            {

                //--------------------------------------------------------------
                // ACTION:  Oghren and the PC's Party are teleported to the
                //          Deeproads Map
                //--------------------------------------------------------------

                // Qwinn:  Added this so player can't use this to travel to world map,
                // it should be limited to deep roads until coronation.
                object oInvalid = OBJECT_INVALID;
                WR_SetWorldMapSecondary( oInvalid );

                SetWorldMapGuiStatus(WM_GUI_STATUS_USE);
                OpenPrimaryWorldMap();

                break;

            }
            case OGHREN_MAIN_PICKUP_INCREMENT_2:
            {
                //--------------------------------------------------------------
                // checks the old value and sets the new
                //--------------------------------------------------------------
                int nPickup = GetLocalInt(oFelsi,CREATURE_COUNTER_1)+2;
                SetLocalInt(oFelsi,CREATURE_COUNTER_1,nPickup);
                break;
            }
            case OGHREN_MAIN_PICKUP_INCREMENT_1:
            {
                //--------------------------------------------------------------
                // checks the old value and sets the new
                //--------------------------------------------------------------
                int nPickup = GetLocalInt(oFelsi,CREATURE_COUNTER_1)+1;
                SetLocalInt(oFelsi,CREATURE_COUNTER_1,nPickup);
                break;
            }
            case OGHREN_MAIN_PICKUP_DECREMENT_1:
            {
                //--------------------------------------------------------------
                // checks the old value and sets the new
                //--------------------------------------------------------------
                int nPickup = GetLocalInt(oFelsi,CREATURE_COUNTER_1)-1;
                SetLocalInt(oFelsi,CREATURE_COUNTER_1,nPickup);
                break;
            }
            case OGHREN_MAIN_APPROACHES_FELSI:
            {
                UT_Talk(oFelsi,oPC);
                break;
            }
            case OGHREN_MAIN_FELSI_QUEST_FAILED:
            {
                object oArea = GetArea(oPC);
                string sAreaTag = GetTag(oArea);
                //--------------------------------------------------------------
                // if the PC is in the inn
                // and Felsi is active
                // set her inactive
                //--------------------------------------------------------------
                if (sAreaTag == CIR_AR_INN)
                {
                    if(GetObjectActive(oFelsi) == TRUE)
                    {
                        WR_SetObjectActive(oFelsi,FALSE);
                    }
                }
                break;
            }
            case OGHREN_MAIN_BERSERKER_CLASS_UNLOCKED:
            {
                //--------------------------------------------------------------
                // unlock the berserker class for the PC
                // if they haven't got it yet
                //--------------------------------------------------------------
                int nBerzerker = RW_HasSpecialization(SPEC_WARRIOR_BERSERKER);
                if(nBerzerker == FALSE)
                {
                    RW_UnlockSpecializationTrainer(SPEC_WARRIOR_BERSERKER);
                }
                break;
            }
            case OGHREN_MAIN_LEAVES_FOR_GOOD:
            {
                WR_SetPlotFlag(PLT_GEN00PT_PARTY,GEN_OGHREN_RECRUITED,FALSE, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_OGHREN,COD_CHA_OGHREN_FIRED,TRUE,TRUE);

                WR_SetObjectActive(oOghren,FALSE);
                break;
            }
            case OGHREN_MAIN_FIGHTS_PLAYER:
            {
                //ACTION: Oghren attacks the player.

                SetGroupId(oOghren, 46);
                // Set Surrender Flags for Oghren (variable table)
                WR_SetPlotFlag(PLT_GENPT_OGHREN_EVENTS, OGHREN_EVENT_ON, TRUE);
                SetImmortal(oOghren,FALSE);
                UT_SetSurrenderFlag(oOghren, TRUE, PLT_GENPT_OGHREN_EVENTS, OGHREN_EVENT_CRISIS_FIGHT_LOST, TRUE);

                // Set Oghren Hostile
                UT_CombatStart(oOghren, oPC);
                break;
            }
            case OGHREN_MAIN_KILLED:
            {
                //Take an automatic screenshot
                WR_SetPlotFlag(PLT_MNP000PT_AUTOSS_MAIN2, AUTOSS_OGH_KILLED_BY_PLAYER, TRUE, TRUE);

                //ACTION: Combat ensues, Oghren does not defend himself, one hit kills him.
                
                //ACTION: Oghren goes hostile for final time (adapted from Zevran's similar script)
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED, FALSE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_CAMP, FALSE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_PARTY, FALSE);

                WR_SetFollowerState(oOghren, FOLLOWER_STATE_INVALID, TRUE);
                SetGroupId(oOghren, 46);
                SetImmortal(oOghren,FALSE);

                object[] arInventory = GetItemsInInventory(oOghren);
                int nInventorySize = GetArraySize(arInventory);
                int nIndex = 0;
                for (nIndex = 0; nIndex < nInventorySize; nIndex++)
                   SetItemDroppable(arInventory[nIndex],TRUE);
                UT_CombatStart(oOghren, oPC);
                WR_SetPlotFlag(PLT_COD_CHA_OGHREN,COD_CHA_OGHREN_GIFT, FALSE, TRUE);
                WR_SetPlotFlag(PLT_COD_CHA_OGHREN,COD_CHA_OGHREN_KILLED,TRUE,TRUE);
                break;
            }

            case OGHREN_MAIN_PARAGON_SAW_OGHREN_BICKERING_WITH_LOLINAR:
            {
                //WR_SetPlotFlag( PLT_GENPT_OGHREN_EVENTS, OGHREN_EVENT_ON, FALSE );
                break;
            }
            case OGHREN_MAIN_GOT_HIS_MOJO_BACK:
            {
                WR_SetPlotFlag(PLT_GENPT_APP_OGHREN,APP_OGHREN_FRIENDLY_ELIGIBLE,TRUE,TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COMPANIONS_4);

                break;
            }
            case OGHREN_MAIN_PASSES_OUT:
            {
                Ambient_OverrideBehaviour(oOghren,110,-1.0,1);
                break;
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

    return bResult;

}