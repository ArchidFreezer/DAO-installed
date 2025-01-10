//==============================================================================
/*

    Dwarf Commoner
     -> Defined Flag Plot Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: October 19, 2007
//==============================================================================

#include "plt_bdcpt_main"
#include "plt_bdcpt_defined_cond"
#include "plt_bdc130pt_oskias"
#include "plt_bdc120pt_cell"
#include "plt_bdc200pt_leske"
#include "plt_gen00pt_skills"

#include "bdc_constants_h"

#include "utility_h"
#include "plot_h"

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
    object  oParty  = GetParty( oPC );
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


            case BDC_DEFINED_PC_HAS_ONE_OR_TWO_NUGGETS:
            {

                //--------------------------------------------------------------
                // COND: PC is currently wearing Everds Armor (Chest + Helm)
                //--------------------------------------------------------------

                // PC has ore, any amount


                if( UT_CountItemInInventory(BDC_IM_LYRIUM_ORE_R) )
                    bResult = TRUE;

                break;
            }

            case BDC_DEFINED_PC_HAS_ONE_NUGGET:
            {

                //--------------------------------------------------------------
                // COND: PC is currently wearing Everds Armor (Chest + Helm)
                //--------------------------------------------------------------

                // PC has exactly one nugget


                if( UT_CountItemInInventory(BDC_IM_LYRIUM_ORE_R) == 1 )
                    bResult = TRUE;

                break;
            }

            case BDC_DEFINED_PC_HAS_TWO_NUGGETS:
            {

                //--------------------------------------------------------------
                // COND: PC is currently wearing Everds Armor (Chest + Helm)
                //--------------------------------------------------------------

                // PC has exactly two nuggets


                if( UT_CountItemInInventory(BDC_IM_LYRIUM_ORE_R) == 2 )
                    bResult = TRUE;

                break;
            }


            case BDC_DEFINED_PC_HAS_EVERDS_ARMOR_HELMET_EQUIPPED:
            {

                //--------------------------------------------------------------
                // COND: PC is currently wearing Everds Armor (Chest + Helm)
                //--------------------------------------------------------------

                object      oPCArmor; 
                object      oPCBite;
                object      oPCHelm;
                object      oPCCloak;

                //--------------------------------------------------------------

                oPCArmor    = GetItemInEquipSlot( INVENTORY_SLOT_CHEST, oPC );
                oPCHelm     = GetItemInEquipSlot( INVENTORY_SLOT_HEAD, oPC );
                oPCBite     = GetItemInEquipSlot( INVENTORY_SLOT_BITE, oPC );
                oPCCloak    = GetItemInEquipSlot( INVENTORY_SLOT_CLOAK, oPC );

                //--------------------------------------------------------------

                if ( (  (GetTag(oPCArmor) == ResourceToTag(BDC_IM_EVERD_ARMOR_R))
                      ||(GetTag(oPCBite) == ResourceToTag(BDC_IM_EVERD_ARMOR_R)) )
                      &&
                     (  (GetTag(oPCHelm)  == ResourceToTag(BDC_IM_EVERD_HELM_R))
                      ||(GetTag(oPCCloak)  == ResourceToTag(BDC_IM_EVERD_HELM_R)) ) )
                {
                   bResult = TRUE;
                }

                break;

            }


            case BDC_DEFINED_PC_HAS_CELL_KEY:
            {

                //--------------------------------------------------------------
                // COND: PC is currently wearing Everds Armor (Chest + Helm)
                //--------------------------------------------------------------


                if( UT_CountItemInInventory(BDC_IM_CELL_KEY_R) )
                    bResult = TRUE;

                break;
            }


            case BDC_DEFINED_PC_HAS_LOCKPICK:
            {

                //--------------------------------------------------------------
                // COND: PC is currently wearing Everds Armor (Chest + Helm)
                //--------------------------------------------------------------


                if( UT_CountItemInInventory(BDC_IM_LOCK_PICK_R) )
                    bResult = TRUE;

                break;
            }


            case BDC_DEFINED_PC_KILLED_OSKIAS_AND_DID_NOT_TAKE_NUGGETS:
            {

                //--------------------------------------------------------------
                // COND: PC killed Oskias and also has some lyrium left on him.
                //--------------------------------------------------------------

                int         bPCKilledOskias;
                int         bPCLootedOskias;

                //--------------------------------------------------------------

                bPCKilledOskias = WR_GetPlotFlag( PLT_BDC130PT_OSKIAS, BDC_OSKIAS___PLOT_03A_OSKIAS_KILLED );
                bPCLootedOskias = WR_GetPlotFlag( PLT_BDC130PT_OSKIAS, BDC_OSKIAS_PC_DID_LOOT_LYRIUM );

                //--------------------------------------------------------------

                if( bPCKilledOskias && !bPCLootedOskias )
                    bResult = TRUE;

                break;

            }


            case BDC_DEFINED_PC_KILLED_OSKIAS_AND_HAS_NUGGETS:
            {

                //--------------------------------------------------------------
                // COND: PC killed Oskias and also has some lyrium left on him.
                //--------------------------------------------------------------

                int         bPCKilledOskias;
                int         bPCHasLyriumNugget;

                //--------------------------------------------------------------

                bPCKilledOskias     = WR_GetPlotFlag( PLT_BDC130PT_OSKIAS, BDC_OSKIAS___PLOT_03A_OSKIAS_KILLED );
                bPCHasLyriumNugget  = UT_CountItemInInventory( BDC_IM_LYRIUM_ORE_R ) >= 2;

                //--------------------------------------------------------------

                if( bPCKilledOskias && bPCHasLyriumNugget )
                    bResult = TRUE;

                break;

            }


            case BDC_DEFINED_PC_CAN_SELL_LYRIUM_TO_OLINDA:
            {

                //--------------------------------------------------------------
                // COND: PC killed Oskias and also has some lyrium left on him.
                //--------------------------------------------------------------

                int         bPCBribed_50_50;
                int         bPCBribed_25_75;
                int         bPCHasLyriumNugget;

                //--------------------------------------------------------------

                bPCBribed_50_50     = WR_GetPlotFlag( PLT_BDC130PT_OSKIAS, BDC_OSKIAS_BRIBE_50_50 );
                bPCBribed_25_75     = WR_GetPlotFlag( PLT_BDC130PT_OSKIAS, BDC_OSKIAS_BRIBE_25_75 );
                bPCHasLyriumNugget  = UT_CountItemInInventory( BDC_IM_LYRIUM_ORE_R );

                //--------------------------------------------------------------

                if( (bPCBribed_50_50||bPCBribed_25_75) && bPCHasLyriumNugget )
                    bResult = TRUE;

                break;

            }

            case BDC_DEFINED_PC_DID_NOT_KILL_OSKIAS_AND_HAS_NUGGETS:
            {

                //--------------------------------------------------------------
                // COND: PC did not kill Oskias and also has some lyrium left on him.
                //--------------------------------------------------------------

                int         bPCKilledOskias;
                int         bPCHasLyriumNugget;

                //--------------------------------------------------------------

                bPCKilledOskias     = WR_GetPlotFlag( PLT_BDC130PT_OSKIAS, BDC_OSKIAS___PLOT_03A_OSKIAS_KILLED );
                bPCHasLyriumNugget  = UT_CountItemInInventory( BDC_IM_LYRIUM_ORE_R ) >= 2;

                //--------------------------------------------------------------

                if( !bPCKilledOskias && bPCHasLyriumNugget )
                    bResult = TRUE;

                break;
            }

            case BDC_DEFINED_PC_CAN_STEAL_KEY_FROM_GUARD:
            {
                //--------------------------------------------------------------
                // COND: PC has not aquired the key from the guard and has enough skill.
                //--------------------------------------------------------------

                int bPCHasKey = UT_CountItemInInventory(BDC_IM_CELL_KEY_R) >= 1;
                int bPCHasSkill = WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_STEALING_LOW, TRUE);

                if ( (bPCHasKey == FALSE) && (bPCHasSkill == TRUE) )
                {
                    bResult = TRUE;
                }
                break;
            }

            case BDC_DEFINED_PC_CAN_TRY_AND_FOOL_GUARD:
            {
                int bPCHasKey = UT_CountItemInInventory(BDC_IM_CELL_KEY_R) >= 1;
                int bFailedOnce = WR_GetPlotFlag(PLT_BDC120PT_CELL, BDC_CELL_PC_FAILED_TO_FOOL_GUARD);

                if ( (bPCHasKey == FALSE) && (bFailedOnce == FALSE) )
                {
                    bResult = TRUE;
                }

                break;
            }

        }
    }

    // Plot Debug / Global Operations
    plot_OutputDefinedFlag( evEvent, bResult );

    return bResult;

}