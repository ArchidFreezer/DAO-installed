//==============================================================================
/*

    Paragon of Her Kind
     -> Chamber Assemly Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: February 14, 2007
//==============================================================================

#include "plt_orz340pt_assembly"
#include "plt_orzpt_talked_to"
#include "plt_orzpt_main"

#include "orz_constants_h"
#include "orz_functions_h"

#include "wrappers_h"
#include "utility_h"
#include "cutscenes_h"
#include "plot_h"

// Qwinn added
#include "plt_orzpt_wfharrow"

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

            case ORZ_ASSEMBLY_DEACTIVATE_SHAPER:
            {
                object  oShaper= UT_GetNearestCreatureByTag(oPC,ORZ_CR_SHAPER);
                WR_SetObjectActive(oShaper,FALSE);
                break;
            }

            case ORZ_ASSEMBLY_EQUIP_CROWN_BHELEN:
            {
                //--------------------------------------------------------------
                // ACTION:  Give Bhelen his crown and rename him
                //--------------------------------------------------------------
                object      oBhelen     = UT_GetNearestCreatureByTag(oPC,ORZ_CR_BHELEN);
                object      oSteward    = UT_GetNearestCreatureByTag(oPC,ORZ_CR_STEWARD);
                object []   arCrown     = GetItemsInInventory(oBhelen,GET_ITEMS_OPTION_BACKPACK,0,ORZ_IM_KINGS_CROWN_EQUIP);

                if (IsObjectValid(arCrown[0]))
                {
                    WR_ClearAllCommands(oBhelen,TRUE);
                    EquipItem(oBhelen,arCrown[0]);
                }
                SetLocName(oBhelen,396030);

                if (!WR_GetPlotFlag(PLT_ORZPT_MAIN,ORZ_MAIN___PLOT_04_BHELEN_CROWNED))
                    UT_Talk(oSteward,oPC);

                break;
            }

            case ORZ_ASSEMBLY_EQUIP_CROWN_HARROW:
            {
                //--------------------------------------------------------------
                // ACTION:  Give Harrowmont his crown and rename him
                //--------------------------------------------------------------
                object      oHarrowmont = UT_GetNearestCreatureByTag(oPC,ORZ_CR_HARROWMONT);
                object      oSteward    = UT_GetNearestCreatureByTag(oPC,ORZ_CR_STEWARD);
                object []   arCrown     = GetItemsInInventory(oHarrowmont,GET_ITEMS_OPTION_BACKPACK,0,ORZ_IM_KINGS_CROWN_EQUIP);

                if (IsObjectValid(arCrown[0]))
                {
                    WR_ClearAllCommands(oHarrowmont,TRUE);
                    EquipItem(oHarrowmont,arCrown[0]);
                }
                SetLocName(oHarrowmont,396031);

                if (!WR_GetPlotFlag(PLT_ORZPT_MAIN,ORZ_MAIN___PLOT_04_HARROW_CROWNED))
                {
                    UT_Talk(oSteward,oPC);
                    // Vartag should no longer be present at this point.
                    object oVartag = UT_GetNearestCreatureByTag(oPC,ORZ_CR_VARTAG);
                    SetPlotGiver(oVartag,FALSE);
                    WR_SetObjectActive(oVartag,FALSE);
                }

                break;
            }


            case ORZ_ASSEMBLY_PC_SAW:
            {
                //--------------------------------------------------------------
                // PLOT:    PC saw the initial argument in the assembly
                // ACTION:  Assembly Deshyrs leave for recess
                //--------------------------------------------------------------
                object oSteward = UT_GetNearestCreatureByTag( oPC, ORZ_CR_STEWARD );

                UT_LocalJump( oSteward, ORZ_WP_ASSEMBLY_STEWARD_POST_INTRO, TRUE );
                UT_LocalJump( oPC, ORZ_WP_ASSEMBLY_PC_POST_INTRO, TRUE );

                break;
            }

            case ORZ_ASSEMBLY_CLOSED:
            {

                //--------------------------------------------------------------
                // PLOT:    PC saw the initial argument in the assembly
                // ACTION:  Assembly Deshyrs leave for recess
                //--------------------------------------------------------------

                int         bAssemblyPlotAccepted;
                object      oRica;
                object      oVartag;
                object      oSteward;
                object      oAssemblyDoor;

                //--------------------------------------------------------------

                bAssemblyPlotAccepted = WR_GetPlotFlag(sPlot,ORZ_ASSEMBLY___PLOT_01_ACCEPTED);
                oRica                 = UT_GetNearestCreatureByTag( oPC, ORZ_CR_RICA );
                oVartag               = UT_GetNearestCreatureByTag( oPC, ORZ_CR_VARTAG );
                oSteward              = UT_GetNearestCreatureByTag( oPC, ORZ_CR_STEWARD );
                oAssemblyDoor         = UT_GetNearestObjectByTag( oPC, ORZ_IP_ASSEMBLY_DOOR );

                //--------------------------------------------------------------

                if ( bAssemblyPlotAccepted )
                    WR_SetPlotFlag(sPlot,ORZ_ASSEMBLY___PLOT_02_COMPLETED,TRUE);

                UT_LocalJump( oSteward, ORZ_WP_ASSEMBLY_CLOSED_STEWARD, TRUE );
                UT_LocalJump( oVartag, ORZ_WP_ASSEMBLY_CLOSED_VARTAG, TRUE );
                UT_LocalJump( oRica, ORZ_WP_ASSEMBLY_CLOSED_RICA, TRUE );
                // Grant - Aug 13, 08: Jump the player's party out as well.
                UT_LocalJump( oPC, ORZ_WP_ASSEMBLY_CLOSED_PC, TRUE, FALSE, FALSE, TRUE );
                SetPlaceableState( oAssemblyDoor, PLC_STATE_DOOR_LOCKED );

                break;

            }


            case ORZ_ASSEMBLY_PC_ENTERS_ASSEMBLY:
            {

                //--------------------------------------------------------------
                // PLOT:    The player is entering the assembly after resolving
                //          the anvil plot.
                // ACTION:  The underground world map should be reset.
                //--------------------------------------------------------------

                object oAssemblyPin = GetObjectByTag(WML_UND_ORZAMMAR_ASSEMBLY);
                object oCommonsPin  = GetObjectByTag(WML_UND_ORZAMMAR_COMMONS);

                WR_SetWorldMapLocationStatus(oAssemblyPin, WM_LOCATION_INACTIVE);
                WR_SetWorldMapLocationStatus(oCommonsPin,  WM_LOCATION_ACTIVE);

                break;

            }


            case ORZ_ASSEMBLY_FINAL_SCENE_BHELEN_REVOLTS_AFTER_VOTE:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has completed the Working for Harrowmont plot,
                //          with Harrowmont becoming the new king of Orzammar.
                //          Bhelen doesn't like this one bit!
                // ACTION:  Bhelen and his followers go hostile and attack the
                //          PC and Harrowmont
                //--------------------------------------------------------------
                object      oBhelen     = UT_GetNearestCreatureByTag( oPC, ORZ_CR_BHELEN );
                object      oHarrow     = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HARROWMONT );
                int         size, i;
                object      oWP, oDeshyr;
                object []   arDeshyrs;


                // Qwinn:  Added the following to fulfill the intent as described in the Steward dialogue that the numbers on
                // each side in the fight should be determined by the level of Harrowmont support.
                if ( WR_GetPlotFlag(PLT_ORZPT_WFHARROW,ORZ_WFH_SUPPORT_IS_LOW) == FALSE)
                {
                   oDeshyr = UT_GetNearestCreatureByTag(oPC,"orz340cr_deshyr_8");
                   SetTeamId(oDeshyr,ORZ_TEAM_ASSEMBLY_DESHYRS_BHELEN );
                   SetGroupId(oDeshyr,ORZ_GROUP_BHELEN);
                   oDeshyr = UT_GetNearestCreatureByTag(oPC,"orz340cr_deshyr_9");
                   SetTeamId(oDeshyr,ORZ_TEAM_ASSEMBLY_DESHYRS_BHELEN );
                   SetGroupId(oDeshyr,ORZ_GROUP_BHELEN);
                   oDeshyr = UT_GetNearestCreatureByTag(oPC,"orz340cr_deshyr_11");
                   SetTeamId(oDeshyr,ORZ_TEAM_ASSEMBLY_DESHYRS_BHELEN );
                   SetGroupId(oDeshyr,ORZ_GROUP_BHELEN);
                   oDeshyr = UT_GetNearestCreatureByTag(oPC,"orz340cr_deshyr_12");
                   SetTeamId(oDeshyr,ORZ_TEAM_ASSEMBLY_DESHYRS_BHELEN);
                   SetGroupId(oDeshyr,ORZ_GROUP_BHELEN);
                }

                if ( WR_GetPlotFlag(PLT_ORZPT_WFHARROW,ORZ_WFH_SUPPORT_IS_MED) == TRUE)
                {  // I tried to have Bhelen supporters switch teams but that makes for just too many Harrow supporters.  Combat
                   // gets crazy with 12 NPC Harrow supporters trying to kill Bhelen all at once, party can hardly get in to hit
                   // him, and that can be true even without this fix.  They also tend to walk through Harrowmont during his final
                   // talk as they leave the area. Will just take them out of their team and deactivate - they run rather than
                   // help either side.
                   oDeshyr = UT_GetNearestCreatureByTag(oPC,"orz340cr_deshyr_0");
                   SetTeamId(oDeshyr,-1);
                   SetObjectActive(oDeshyr,FALSE);
                   oDeshyr = UT_GetNearestCreatureByTag(oPC,"orz340cr_deshyr_2");
                   SetTeamId(oDeshyr,-1);
                   SetObjectActive(oDeshyr,FALSE);
                   oDeshyr = UT_GetNearestCreatureByTag(oPC,"orz340cr_deshyr_5");
                   SetTeamId(oDeshyr,-1);
                   SetObjectActive(oDeshyr,FALSE);
                }


                // ** ASSEMBLY ** //
                if ( WR_GetPlotFlag(PLT_ORZ340PT_ASSEMBLY,ORZ_ASSEMBLY___PLOT_ACTIVE) )
                    WR_SetPlotFlag( PLT_ORZ340PT_ASSEMBLY, ORZ_ASSEMBLY___PLOT_FAILED, TRUE );

                // Make the deshyr's equip melee weapons.
                arDeshyrs = UT_GetTeam(ORZ_TEAM_ASSEMBLY_DESHYRS_BHELEN);
                size = GetArraySize(arDeshyrs);
                for (i=0;i<size;i++)
                {
                    oDeshyr = arDeshyrs[i];
                    UT_RemoveItemFromInventory(ORZ_IM_DESHYR_STAFF_R, 1, oDeshyr);
                    SwitchWeaponSet(oDeshyr);
                }

                arDeshyrs = UT_GetTeam(ORZ_TEAM_ASSEMBLY_DESHYRS_HARROW);
                size = GetArraySize(arDeshyrs);
                for (i=0;i<size;i++)
                {
                    oDeshyr = arDeshyrs[i];
                    UT_RemoveItemFromInventory(ORZ_IM_DESHYR_STAFF_R, 1, oDeshyr);
                    SwitchWeaponSet(oDeshyr);
                    SetLocalInt(oDeshyr,AMBIENT_ANIM_PATTERN,(GetCreatureGender(oDeshyr)?19:25));
                    oWP = UT_GetNearestObjectByTag(oPC,"orz340wp_postplot_bd_"+ToString(GetLocalInt(oDeshyr,CREATURE_COUNTER_1)));
                    if (IsObjectValid(oWP))
                        Rubber_SetHome(oDeshyr,oWP);
                    else
                        Rubber_SetHome(oDeshyr,UT_GetNearestObjectByTag(oDeshyr,GENERIC_EXIT));
                }

                UT_LocalJump( oBhelen, ORZ_WP_ASSEMBLY_CENTER, TRUE, TRUE, TRUE );
                UT_CombatStart( oBhelen, oHarrow );
                UT_CombatStart( oBhelen, oPC );

                break;

            }


            case ORZ_ASSEMBLY_FINAL_SCENE_BHELEN_DEFEATED_AFTER_VOTE:
            {
                //--------------------------------------------------------------
                // ORZ_MAIN_BHELEN_DEFEATED_AFTER_VOTE
                //--------------------------------------------------------------
                object      oBhelen     = UT_GetNearestCreatureByTag( oPC, ORZ_CR_BHELEN );
                object      oHarrow     = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HARROWMONT );
                object      oDeshyr;

                UT_CombatStop( oBhelen, oHarrow );
                UT_CombatStop( oBhelen, oPC );

                WR_ClearAllCommands( oPC );
                WR_ClearAllCommands( oHarrow );
                UT_Talk( oHarrow, oPC );

                break;
            }


            case ORZ_ASSEMBLY_FINAL_SCENE_CROWNING_CEREMONY_DELAY:
            {

                //--------------------------------------------------------------
                // PLOT:    PC tells the commander he doesn't want to return to
                //          Orzammar
                // ACTION:  PC is teleported back outside the talk trigger
                //--------------------------------------------------------------

                if ( nNewValue )
                    UT_LocalJump(oPC,ORZ_WP_COMMANDER_DELAY);

                break;

            }


            case ORZ_ASSEMBLY_FINAL_SCENE_CROWNING_CEREMONY_START:
            {

                //--------------------------------------------------------------
                // PLOT:    PC has agreed to go to see harrowmont/bhelen
                //          in the Orzammar Assembly.
                //--------------------------------------------------------------

                // Port the PC to the assembly
                UT_DoAreaTransition( ORZ_AR_ASSEMBLY, ORZ_WP_ASSEMBLY_PC_FINAL_SCENE );

                // Restore the underground world map state
                object oAssemblyPin = GetObjectByTag(WML_UND_ORZAMMAR_ASSEMBLY);
                object oCommonsPin  = GetObjectByTag(WML_UND_ORZAMMAR_COMMONS);

                WR_SetWorldMapLocationStatus(oAssemblyPin, WM_LOCATION_INACTIVE);
                WR_SetWorldMapLocationStatus(oCommonsPin,  WM_LOCATION_ACTIVE);

                break;

            }

            case ORZ_ASSEMBLY___PLOT_02_COMPLETED:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ORZAMMAR_1);

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


            case ORZ_ASSEMBLY___PLOT_ACTIVE:
            {

                //--------------------------------------------------------------
                // COND:    Plot accepted, but not done.
                //--------------------------------------------------------------

                int         bPlotAccepted;
                int         bPlotCompleted;
                int         bPlotFailed;

                //--------------------------------------------------------------

                bPlotAccepted  = WR_GetPlotFlag(sPlot,ORZ_ASSEMBLY___PLOT_01_ACCEPTED);
                bPlotCompleted = WR_GetPlotFlag(sPlot,ORZ_ASSEMBLY___PLOT_02_COMPLETED);
                bPlotFailed    = WR_GetPlotFlag(sPlot,ORZ_ASSEMBLY___PLOT_FAILED);

                //--------------------------------------------------------------

                if ( bPlotAccepted && !(bPlotCompleted||bPlotFailed) )
                    bResult = TRUE;

                break;

            }


            case ORZ_ASSEMBLY_PC_CAN_ACCEPT_PLOT:
            {

                //--------------------------------------------------------------
                // COND:    Player has not accepted the plot yet and also not
                //          yet seen steward bandelor.
                //--------------------------------------------------------------

                int         bPlotAccepted;
                int         bPlotCompleted;
                int         bPlotFailed;
                int         bTTSteward;

                //--------------------------------------------------------------

                bPlotAccepted  = WR_GetPlotFlag(sPlot,ORZ_ASSEMBLY___PLOT_01_ACCEPTED);
                bPlotCompleted = WR_GetPlotFlag(sPlot,ORZ_ASSEMBLY___PLOT_02_COMPLETED);
                bPlotFailed    = WR_GetPlotFlag(sPlot,ORZ_ASSEMBLY___PLOT_FAILED);
                bTTSteward     = WR_GetPlotFlag(PLT_ORZPT_TALKED_TO,ORZ_TT_STEWARD);

                //--------------------------------------------------------------

                if ( !(bPlotAccepted||bPlotCompleted||bPlotFailed) && !bTTSteward )
                    bResult = TRUE;

                break;

            }


        }
    }

    return bResult;

}