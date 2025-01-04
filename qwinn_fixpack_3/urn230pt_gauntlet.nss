//==============================================================================
/*

    urn230pt_gauntlet
        -> Gauntlet plot scripting.

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: January 07
//==============================================================================

#include "cutscenes_h"
#include "wrappers_h"
#include "utility_h"
#include "plot_h"

#include "plt_urn230pt_gauntlet"
#include "urn_functions_h"


int StartingConditional()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evParms = GetCurrentEvent();             // Contains input parameters
    int     nType   = GetEventType( evParms );       // GET or SET call
    int     nFlag   = GetEventInteger( evParms, 1 ); // The bit flag # affected
    string  sPlot   = GetEventString( evParms, 0 );  // Plot GUID

    // Set Default return to FALSE
    int     bResult = FALSE;

    // Generic Variables
    object  oThis   = GetEventObject(evParms, 0); // Owner on the conversation, if any;
    object  oPC     = GetHero();

    // Plot Debug / Global Operations
    plot_GlobalPlotHandler(evParms);

    //--------------------------------------------------------------------------
    // Actions -> normal flags only (SET)
    //--------------------------------------------------------------------------

    if(nType == EVENT_TYPE_SET_PLOT)
    {

        int nNewValue = GetEventInteger( evParms, 2 );  // New flag value
        int nOldValue = GetEventInteger( evParms, 3 );  // Old flag value

        switch(nFlag)
        {


            //------------------------------------------------------------------
            // URN230_TRIAL_ALTAR
            //------------------------------------------------------------------

            // This removes the player's equipment or equips it
            case EQUIPMENT_REMOVED:
            {

                object []   oParty;
                object      oAltar, oStore, oFollower;
                int         nSize, nIndex;

                oAltar = UT_GetNearestObjectByTag( oPC, URN_IP_GAUNTLET_ALTAR );
                oParty = GetPartyList();

                nSize  = GetArraySize( oParty );

                // Set to TRUE, remove equipment.
                if ( nNewValue )
                {
                    StorePartyInventory( oAltar );
                }
                // Set to FALSE, return equipment.
                else
                {
                    RestorePartyInventory( oAltar );
                }


                for ( nIndex = 0; nIndex < nSize; ++nIndex )
                {

                    oStore = GetObjectByTag( URN_IP_INV_STORE + IntToString( nIndex ) );
                    oFollower = oParty[ nIndex ];

                    if ( nNewValue )
                        StoreFollowerInventory( oFollower, oStore );
                    else
                        RestoreFollowerInventory( oFollower, oStore );

                    SetObjectInteractive( oStore, FALSE );

                }

                break;

            }

            //------------------------------------------------------------------
            // URN230_GUARDIAN
            //------------------------------------------------------------------

            // Guardian goes to the Urn Chamber
            case GAUNTLET_OPEN:
            {

                object oGuardian    = UT_GetNearestCreatureByTag( oThis, URN_CR_GUARDIAN, TRUE );
                object oDoor        = UT_GetNearestObjectByTag( oThis, URN_IP_GAUNTLET_DOOR );

                UT_LocalJump( oGuardian, "230" ); // ?
                UT_OpenDoor( oDoor, oDoor );

                SetObjectActive( oGuardian, FALSE );

                break;

            }

            // Guardian goes hostile and attacks
            case GUARDIAN_ATTACKS:
            {

                UT_CombatStart( oThis, oPC );
                UT_TeamAppears( URN_TEAM_GUARDIAN );

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_URN_2);

                break;

            }


            // Gaurdian fades away.
            case GAUNTLET_QUEST_DONE:
            {

                WR_SetObjectActive( oThis, FALSE );
                WR_SetPlotFlag( sPlot, EQUIPMENT_REMOVED, FALSE, TRUE );

                object []   arParty = GetPartyList();
                object      oParty;

                int nSize = GetArraySize( arParty );
                int nIndex;

                for ( nIndex = 0; nIndex < nSize; ++nIndex )
                {
                    oParty = arParty[nIndex];
                    ApplyEffectVisualEffect( oThis, oParty, 10, EFFECT_DURATION_TYPE_INSTANT, 0.0 );
                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_URN_2);

                break;

            }

            //------------------------------------------------------------------
            // VARIOUS
            //------------------------------------------------------------------

            // PC gains weapon or armor.
            case PC_GETS_WEAPON_OR_ARMOR:
            {

                UT_AddItemToInventory( URN_IT_REWARD_R, 1 );

                break;

            }

            // The illusion's door is opened.
            case RIDDLE_OPEN_RIGHT_DOOR:
            {

                // For XP purposes have the player 'kill' the wraith.
                string sTag    = GetTag( oThis ) + "_w";
                object oWraith = GetObjectByTag( sTag );

                float fReward = RewardGetXPValue( oWraith );
                int nReward = FloatToInt( fReward * 1.1 );
                RewardXPParty( nReward, XP_TYPE_PLOT );

                URN_RiddleIncrement( oThis );

                break;

            }

            // An Ash Wraith attacks.
            case RIDDLE_OPEN_WRONG_DOOR:
            {

                string sTag    = GetTag( oThis ) + "_w";
                object oWraith = GetObjectByTag( sTag );

                SetObjectActive( oWraith, TRUE );
                SetObjectActive( oThis, FALSE );

                break;

            }

            case PC_PAST_THE_FIRE:
            {
                // Qwinn added:
                object []   oParty = GetPartyList();
                int         nIndex, nSize  = GetArraySize( oParty );
                object      oFollower;
                for ( nIndex = 0; nIndex < nSize; ++nIndex )
                {   oFollower = oParty[ nIndex ];
                    Gore_RemoveAllGore(oFollower);
                }

                object oGuardian = GetObjectByTag( URN_CR_GUARDIAN );
                SetObjectActive( oGuardian, TRUE );
                // disable the altar
                object oAltar = GetObjectByTag( URN_IP_GAUNTLET_ALTAR );
                SetObjectInteractive( oAltar, FALSE );
                break;
            }

            case PC_APPROACHING_GAUNTLET:
            {

                int bCutscene = WR_GetPlotFlag( PLT_URN230PT_GAUNTLET, PC_AT_URN_POST_CUTSCENE );

                if ( !GetCombatState( oPC ) && !bCutscene )
                    CS_LoadCutscene( R"urn230cs_approach_urn.cut", PLT_URN230PT_GAUNTLET, PC_AT_URN_POST_CUTSCENE  );

                break;

            }

            case PC_AT_URN_POST_CUTSCENE:
            {
                object oUrn = GetObjectByTag( URN_IP_SACRED_ASHES );
                UT_Talk( oUrn, oPC );
                break;
            }

        }
     }

    //--------------------------------------------------------------------------
    // Conditions -> defined flags only (GET DEFINED)
    //--------------------------------------------------------------------------

     else
     {

        switch(nFlag)
        {

            // See if the PC has any companions that can talk with him
            case PC_HAS_SPEAKING_PARTY:
            {

                int bCondition1 = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_PLAYER_HAS_PARTY );

                bResult = bCondition1;

                break;

            }

            // Alistair is with you and has not spoken
            case ALREADY_SPOKEN_ALISTAIR:
            {

                int bCondition1 = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_PARTY );
                int bCondition2 = WR_GetPlotFlag( PLT_URN230PT_GAUNTLET, INTERJECTION_BY_ALISTAIR );

                bResult = bCondition1 && !bCondition2;

                break;

            }

            // Morrigan is with you and has not spoken
            case ALREADY_SPOKEN_MORRIGAN:
            {

                int bCondition1 = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_PARTY );
                int bCondition2 = WR_GetPlotFlag( PLT_URN230PT_GAUNTLET, INTERJECTION_BY_MORRIGAN );

                bResult = bCondition1 && !bCondition2;

                break;

            }

            // Wynne is with you and has not spoken
            case ALREADY_SPOKEN_WYNNE:
            {

                int bCondition1 = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_WYNNE_IN_PARTY );
                int bCondition2 = WR_GetPlotFlag( PLT_URN230PT_GAUNTLET, INTERJECTION_BY_WYNNE );

                bResult = bCondition1 && !bCondition2;

                break;

            }

        }

    }

    return bResult;

}