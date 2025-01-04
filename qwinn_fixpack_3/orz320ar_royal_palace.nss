//==============================================================================
/*

    Paragon of Her Kind
     -> Royal Estate Area Script

*/
//------------------------------------------------------------------------------
// Created By: Joshua Stiksma
// Created On: March 6, 2007
//==============================================================================

#include "plt_orzpt_generic"
#include "plt_orzpt_main"
#include "plt_orzpt_talked_to"
#include "plt_orzpt_wfbhelen"
#include "plt_orz340pt_assembly"

#include "plt_orz300pt_rica"
#include "plt_orz320pt_bhelen"
#include "plt_orz330pt_harrowmont"
#include "plt_orz340pt_vartag"

#include "plt_den200pt_assassin_orz"

#include "orz_constants_h"

#include "utility_h"

// Qwinn added
#include "plt_orz300pt_nobhunter"
#include "plt_gen00pt_backgrounds"
#include "plt_orzpt_wfbhelen_t2"
#include "plt_orzpt_wfharrow_t2"

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent         = GetCurrentEvent();            // Event
    int     nEventType      = GetEventType(evEvent);        // Event Type
    object  oEventCreator   = GetEventCreator(evEvent);     // Event Creator

    // Standard Variables
    object  oPC             = GetHero();
    object  oParty          = GetParty( oPC );
    int     bEventHandled   = FALSE;

    //--------------------------------------------------------------------------
    // Area Events
    //--------------------------------------------------------------------------

    switch ( nEventType )
    {

        case EVENT_TYPE_AREALOADSAVE_PRELOADEXIT:
        {
            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_PRELOADEXIT:
            // Sent by: The engine
            // When: for things you want to happen while the load screen is
            // still up, things like moving creatures around.
            //------------------------------------------------------------------
            // Crowning/Name changes for Bhelen/Harrowmont
            if (WR_GetPlotFlag(PLT_ORZPT_MAIN,ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN))
                WR_SetPlotFlag( PLT_ORZ340PT_ASSEMBLY, ORZ_ASSEMBLY_EQUIP_CROWN_BHELEN, TRUE, TRUE );

            if (WR_GetPlotFlag(PLT_ORZPT_MAIN,ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT))
                WR_SetPlotFlag( PLT_ORZ340PT_ASSEMBLY, ORZ_ASSEMBLY_EQUIP_CROWN_HARROW, TRUE, TRUE );

            break;
        }

        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_PRELOADEXIT:
            // Sent by: The engine
            // When: for things you want to happen while the load screen is
            // still up, things like moving creatures around.
            //------------------------------------------------------------------
            int         bBhelenCrowned      = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_BHELEN_CROWNED );
            int         bBhelenKing         = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN );
            int         bHarrowKing         = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT );
            int         bParagonDone        = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_DONE );
            int         bBhelenActive       = WR_GetPlotFlag( PLT_ORZ320PT_BHELEN, ORZ_BHELEN_IS_IN_ROYAL_PALACE );
            int         bHarrowActive       = WR_GetPlotFlag( PLT_ORZ330PT_HARROWMONT, ORZ_HARROW_IS_IN_THRONE_ROOM );
            int         bRicaActive         = WR_GetPlotFlag( PLT_ORZ300PT_RICA, ORZ_RICA_IS_IN_ROYAL_ESTATE );
            int         bVartagActive       = WR_GetPlotFlag( PLT_ORZ340PT_VARTAG, ORZ_VARTAG_IS_IN_ROYAL_ESTATE );
            object      oBhelen             = UT_GetNearestCreatureByTag( oPC, ORZ_CR_BHELEN );
            object      oHarrow             = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HARROWMONT );
            object      oMother             = UT_GetNearestCreatureByTag( oPC, ORZ_CR_MOTHER );
            object      oRica               = UT_GetNearestCreatureByTag( oPC, ORZ_CR_RICA );
            object      oVartag             = UT_GetNearestCreatureByTag( oPC, ORZ_CR_VARTAG );
            object      oEstateDoor         = UT_GetNearestObjectByTag( oPC, ORZ_IP_ROYAL_ESTATE_DOOR );
            object []   arBGuards           = UT_GetAllObjectsInAreaByTag( ORZ_CR_BHELEN_GUARD, OBJECT_TYPE_CREATURE );
            object []   arHGuards           = UT_GetAllObjectsInAreaByTag( ORZ_CR_HARROWMONT_GUARD, OBJECT_TYPE_CREATURE );
            object      oThrone             = UT_GetNearestObjectByTag( oPC, ORZ_IP_CAGED_THRONE);
            int         size, i;

            int         nIndex;
            object      oArea               = GetArea(GetHero());
            effect []   arAreaEffects       = GetEffects(oArea);
            int         nArraySize          = GetArraySize(arAreaEffects);


            // Should the estate door be open?
            if ( (bVartagActive||bParagonDone) && GetPlaceableState(oEstateDoor) == PLC_STATE_DOOR_LOCKED )
            {
                SetPlaceableActionResult( oEstateDoor, PLACEABLE_ACTION_UNLOCK, TRUE );
                WR_SetObjectActive(UT_GetNearestCreatureByTag(oPC,ORZ_CR_BHELEN_ESTATE_GUARD),FALSE);
            }

            // Check to see if Rica/Mother is here
            WR_SetObjectActive( oRica,   bRicaActive );
            WR_SetObjectActive( oMother, bRicaActive );

            // Qwinn:  Add Mardy here if Bhelen crowned and he accepts her
            object oMardy = UT_GetNearestCreatureByTag(oPC, ORZ_CR_MARDY);            
            if (WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER,ORZ_NOBHUNTER___PLOT_02B_BHELEN_AGREED) &&
                WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER,ORZ_NOBHUNTER___PLOT_04_COMPLETED))
            {
                WR_SetObjectActive(oMardy,TRUE);
                object oClothes = GetItemInEquipSlot(INVENTORY_SLOT_CHEST, oMardy);
                if (GetTag(oClothes) != "gen_im_cth_nob_f03")
                {
                   object oRobes = UT_AddItemToInventory(R"gen_im_cth_nob_f03.uti",1,oMardy,"gen_im_cth_cha_f03");
                   EquipItem(oMardy, oRobes, INVENTORY_SLOT_CHEST);
                }
            }
            else
                WR_SetObjectActive(oMardy,FALSE);  // Only needed due to a bug in 3.0 beta
            
                                     
            // Qwinn added.  These Bhelen supporter dialogues only work IF Harrowmont is not king AND one of the following:
            // Bhelen is king OR
            // dwarf noble OR
            // dwarf commoner and haven't commited yet to Harrowmont publicly OR
            // working for Bhelen publicly            
            int         bBhelenSupporters   = ((bBhelenKing) ||
                                               (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_DWARF_NOBLE)) ||
                                               (WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_DWARF_COMMONER) && !(WR_GetPlotFlag(PLT_ORZPT_WFHARROW_T2,ORZ_WFHT2___PLOT_01_ACCEPTED))) ||
                                               (WR_GetPlotFlag(PLT_ORZPT_WFBHELEN_T2,ORZ_WFBT2___PLOT_01_ACCEPTED))
                                              ) && !bHarrowKing ;
            UT_SetTeamInteractive( ORZ_TEAM_POST_PLOT_NOT_DONE, bBhelenSupporters );




            // Check to see if Vartag is here, and where he needs to be
            // Also disable his plot giver status.
            WR_SetObjectActive( oVartag, bVartagActive );
            SetPlotGiver( oVartag, FALSE );

            // Is bhelen here?
            WR_SetObjectActive( oBhelen,  bBhelenActive );

            //------------------------------------------------------------------

            // If Paragon is done and there is a king...
            if ( bBhelenCrowned||bParagonDone )
            {
                UT_LocalJump( oVartag, ORZ_WP_VARTAG_MOVETO );
                UT_TeamAppears(ORZ_TEAM_POST_PLOT_DONE,TRUE,OBJECT_TYPE_PLACEABLE);
            }

            //------------------------------------------------------------------

            if ( bBhelenCrowned )
            {
                // Bhelen is King
                // Crowning/Name changes for Bhelen/Harrowmont
                WR_SetPlotFlag( PLT_ORZ340PT_ASSEMBLY, ORZ_ASSEMBLY_EQUIP_CROWN_BHELEN, TRUE, TRUE );

                //Light Content - throne no longer available
                SetObjectInteractive(oThrone, FALSE);

                UT_LocalJump( oBhelen, ORZ_WP_BHELEN_KING );
                size = GetArraySize( arBGuards );
                for (i=0;i<size;i++)
                    WR_SetObjectActive( arBGuards[i], TRUE );
                WR_SetObjectActive( arHGuards[i], TRUE );

                // Qwinn:  Added to remove blood puddle from Caged In Stone
                for ( nIndex = 0; nIndex < nArraySize; nIndex++ )
                {
                   if (GetVisualEffectID(arAreaEffects[nIndex]) == VFX_GROUND_BLOODPOOL_L)
                      RemoveEffect(oArea,arAreaEffects[nIndex]);
                }
            }

            else if ( bHarrowKing )
            {
                // Harrowmont is King
                WR_SetPlotFlag( PLT_ORZ340PT_ASSEMBLY, ORZ_ASSEMBLY_EQUIP_CROWN_HARROW, TRUE, TRUE );
                //Light Content - throne no longer available
                SetObjectInteractive(oThrone, FALSE);

                WR_SetObjectActive( oHarrow,  bHarrowActive );
                size = GetArraySize( arHGuards );
                for (i=0;i<size;i++)
                    WR_SetObjectActive( arHGuards[i], TRUE );

                UT_TeamAppears( ORZ_TEAM_POST_PLOT_NOT_DONE, FALSE );

                // Qwinn:  Added to remove blood puddle from Caged In Stone
                for ( nIndex = 0; nIndex < nArraySize; nIndex++ )
                {
                   if (GetVisualEffectID(arAreaEffects[nIndex]) == VFX_GROUND_BLOODPOOL_L)
                      RemoveEffect(oArea,arAreaEffects[nIndex]);
                }
            }

            // LC: Make the Ambassador show up for Denerim assassination quest
            if ( WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_ORZ, ASSASSIN_ORZ_QUEST_ACCEPTED) &&
                !WR_GetPlotFlag(PLT_DEN200PT_ASSASSIN_ORZ, AMBASSADOR_KILLED) )
            {
                UT_TeamAppears(ORZ_TEAM_AMBASSADOR);
            }

            break;
        }


        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_POSTLOADEXIT:
            // Sent by: The engine
            // When: fires at the same time that the load screen is going away,
            // and can be used for things that you want to make sure the player
            // sees.
            //------------------------------------------------------------------
            int         bBhelenCrowned  = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_BHELEN_CROWNED );
            int         bBhelenKing     = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN );
            int         bTeleported     = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN, ORZ_WFB_PC_TELEPORTED_TO_BHELEN );
            int         bTTBhelen       = WR_GetPlotFlag( PLT_ORZPT_TALKED_TO, ORZ_TT_BHELEN ) || WR_GetPlotFlag( PLT_ORZPT_TALKED_TO, ORZ_TT_BHELEN_DA );
            object      oBhelen         = GetObjectByTag( ORZ_CR_BHELEN );

            if (bBhelenCrowned && !bBhelenKing)
                UT_Talk(oBhelen,oPC);
            else if ( bTeleported && !bTTBhelen )
                UT_Talk( oBhelen, oPC );

            break;
        }


        case EVENT_TYPE_ENTER:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_ENTER:
            // Sent by: The engine
            // When: A creature enters the area.
            //------------------------------------------------------------------

            break;

        }


        case EVENT_TYPE_EXIT:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_EXIT:
            // Sent by: The engine
            // When: A creature exits the area.
            //------------------------------------------------------------------

            break;

        }

    }

    //--------------------------------------------------------------------------
    // Pass any unhandled events to orzar_core ( Paragon Area Core )
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, ORZ_RESOURCE_SCRIPT_AREA_CORE );

}