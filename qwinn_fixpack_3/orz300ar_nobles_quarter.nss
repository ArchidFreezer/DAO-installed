//==============================================================================
/*

    Paragon of Her Kind
     -> Orzammar Noble's Quarter Area Script

*/
//------------------------------------------------------------------------------
// Created By: joshua
// Created On: February 28, 2007
//==============================================================================

#include "plt_genpt_oghren_defined"
#include "plt_gen00pt_party"

#include "plt_orzpt_carta"
#include "plt_orzpt_generic"
#include "plt_orzpt_defined"
#include "plt_orzpt_events"
#include "plt_orzpt_main"
#include "plt_orzpt_talked_to"
#include "plt_orzpt_wfbhelen"
#include "plt_orzpt_wfharrow"
#include "plt_orzpt_wfbhelen_da"
#include "plt_orzpt_wfharrow_da"
#include "plt_orz300pt_nobhunter"
#include "plt_orz300pt_rica"
#include "plt_orz330pt_dulin"
#include "plt_orz340pt_find_lord_dace"
#include "plt_orz550pt_kardol"

#include "orz_constants_h"
#include "orz_functions_h"

#include "wrappers_h"
#include "utility_h"
#include "plot_h"

// Qwinn added
#include "plt_gen00pt_backgrounds"
#include "plt_orzpt_wfbhelen_t2"
#include "plt_orzpt_wfharrow_t2"
#include "plt_genpt_oghren_events"
#include "plt_orz200pt_wrangler"

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


        case EVENT_TYPE_AREALOAD_SPECIAL:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_AREALOAD_SPECIAL:
            // Sent by: The engine
            // When: it is for playing things like cutscenes and movies when
            // you enter an area, things that do not involve AI or actual
            // game play.
            //------------------------------------------------------------------

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

            int         bHarrowKing         = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_HARROWMONT );
            int         bBhelenKing         = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_04_COMPLETED_KING_IS_BHELEN );
            int         bDulinActive        = WR_GetPlotFlag( PLT_ORZ330PT_DULIN, ORZ_DULIN_IS_IN_NOBLES_QUARTER );
            int         bKardolActive       = (bHarrowKing||bBhelenKing) && !WR_GetPlotFlag( PLT_ORZ550PT_KARDOL, ORZ_KARDOL_APPEARS_POST_PLOT );
            int         bLordDaceActive     = WR_GetPlotFlag( PLT_ORZ340PT_FIND_LORD_DACE, ORZ_DACE___PLOT_04_COMPLETED );
            int         bNeravActive        = WR_GetPlotFlag( PLT_ORZPT_TALKED_TO, ORZ_TT_NERAV );
            int         bNobleHunterActive  = (WR_GetPlotFlag( PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER_IS_IN_NOBLES_QUARTER ) &&
                                               !WR_GetPlotFlag(PLT_ORZ300PT_NOBHUNTER,ORZ_NOBHUNTER___PLOT_04_COMPLETED));
            int         bOghrenActive       = WR_GetPlotFlag( PLT_GENPT_OGHREN_DEFINED, OGHREN_DEFINED_PARAGON_OGHREN_IS_IN_NOBLES_QUARTER );
            int         bOghrenInParty      = WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_OGHREN_RECRUITED );
            int         bTaskOneAccepted    = WR_GetPlotFlag( PLT_ORZPT_DEFINED, ORZ_DEFINED_EITHER_TASK_1_ACCEPTED );
            int         bBhelenFanatics     = WR_GetPlotFlag( PLT_ORZPT_DEFINED, ORZ_DEFINED_FANATICS_BHELEN_ACTIVE, TRUE );
            int         bHarrowFanatics     = WR_GetPlotFlag( PLT_ORZPT_DEFINED, ORZ_DEFINED_FANATICS_HARROW_ACTIVE, TRUE );
            object      oDulin              = UT_GetNearestCreatureByTag( oPC, ORZ_CR_DULIN );
            object      oKardol             = UT_GetNearestCreatureByTag( oPC, ORZ_CR_KARDOL );
            object      oLoilinar           = UT_GetNearestCreatureByTag( oPC, ORZ_CR_LOILINAR );
            object      oLordDace           = UT_GetNearestCreatureByTag( oPC, ORZ_CR_LORD_DACE );
            object      oNerav              = UT_GetNearestCreatureByTag( oPC, ORZ_CR_NERAV );
            object      oNobleHunter        = UT_GetNearestCreatureByTag( oPC, ORZ_CR_MARDY );
            object      oOghren             = UT_GetNearestCreatureByTag( oPC, ORZ_CR_OGHREN );
            object      oNobleBiyatch       = UT_GetNearestCreatureByTag( oPC, ORZ_CR_NOBLEBIYATCH ); // .. Oh, Joshua.
            object      oHopefulNoble_1     = UT_GetNearestCreatureByTag( oPC, ORZ_CR_HOPEFULENOBLE_1 );
            object      oHopefulNoble_2     = UT_GetNearestObjectByTag( oPC, ORZ_CR_HOPEFULENOBLE_2 );
            object      oCrierBhelenTrigger = UT_GetNearestObjectByTag( oPC, ORZ_TR_CRIER_BHELEN );
            object      oCrierHarrowTrigger = UT_GetNearestObjectByTag( oPC, ORZ_TR_CRIER_HARROW );
            object      oCrierBhelen        = UT_GetNearestCreatureByTag( oPC, ORZ_CR_CRIER_BHELEN );
            object      oCrierHarrow        = UT_GetNearestCreatureByTag( oPC, ORZ_CR_CRIER_HARROW );
            object []   arDaceMen           = GetNearestObjectByTag( oPC, ORZ_CR_DACEMAN, OBJECT_TYPE_CREATURE, MAX_GETNEAREST_OBJECTS );
            int         i, size;
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

            //------------------------------------------------------------------

            // AREA EVENT: Supporter Fight
            WR_SetPlotFlag( PLT_ORZPT_EVENTS, ORZ_EVENT_NOBLES_QUARTER_SUPPORTER_FIGHT__SETUP, TRUE, TRUE ) ;

            // AREA EVENT: Rica visits Dwarven Commoner PC
            WR_SetPlotFlag( PLT_ORZ300PT_RICA, ORZ_RICA__EVENT_RICA_IN_NOBLES_QUARTER__SETUP, TRUE, TRUE );

            //------------------------------------------------------------------


            // Noble's Quarter Criers
            WR_SetObjectActive( oCrierBhelen, !bHarrowKing );
            WR_SetObjectActive( oCrierHarrow, !bBhelenKing );

            // Reset Both Crier Triggers
            SetLocalInt( oCrierBhelenTrigger, TRIG_TALK_DISABLED, FALSE );
            WR_SetObjectActive( oCrierBhelenTrigger, TRUE );
            SetLocalInt( oCrierHarrowTrigger, TRIG_TALK_DISABLED, FALSE );
            WR_SetObjectActive( oCrierHarrowTrigger, TRUE );

            // Dulin could show up to introduce himself to the player after
            // leaving the assembly
            WR_SetObjectActive( oDulin, bDulinActive );
            if (bDulinActive)
                PlaySoundSet(oDulin,SS_SOMETHING_TO_SAY,1.0f);

            // Kardol will show up if the PC just exits from the ending scene
            // in the Assembly and has helped the Legion retake Bownammar
            WR_SetObjectActive( oKardol, bKardolActive );
            if (bKardolActive)
            {
                if (bBhelenKing && IsObjectValid(GetObjectByTag(ORZ_WP_KARDOL_BHELEN)))
                    UT_LocalJump(oKardol,ORZ_WP_KARDOL_BHELEN,TRUE,TRUE);
                WR_SetPlotFlag( PLT_ORZ550PT_KARDOL, ORZ_KARDOL_APPEARS_POST_PLOT, TRUE );
                WR_SetPlotFlag( PLT_ORZ550PT_KARDOL, ORZ_KARDOL_POST_PLOT_AMBIENT, TRUE );
                UT_Talk(oKardol,oKardol);
            }

            // If player has accepted either first task, Lolinar is active
            WR_SetObjectActive( oLoilinar, bTaskOneAccepted );
            SetObjectInteractive( oLoilinar, !bOghrenActive );

            // Check if Lord Dace has come here yet
            WR_SetObjectActive( oLordDace, bLordDaceActive );
            size = GetArraySize(arDaceMen);
            for (i=0;i<size;i++)
                WR_SetObjectActive( arDaceMen[i], bLordDaceActive );

            // If player talked to Nerav in the Commons, he is active
            WR_SetObjectActive( oNerav, bNeravActive );

            // If PC slept with noble hunters, Mardy is active
            WR_SetObjectActive( oNobleHunter, bNobleHunterActive );

            // Teams of political fanatics show up
            UT_TeamAppears( ORZ_TEAM_BHELEN_FANATIC_WAVE_1, bBhelenFanatics );
            UT_TeamAppears( ORZ_TEAM_HARROW_FANATIC_WAVE_1, bHarrowFanatics );

            // If the PC has not seen Oghren arguing with Lolinar, he is active
            if (bOghrenInParty && IsPartyMember(oOghren))
                oOghren = UT_GetNearestCreatureByTag(oOghren,ORZ_CR_OGHREN);

            WR_SetObjectActive( oOghren, bOghrenActive );
            SetObjectInteractive( oOghren, FALSE );
            UnequipItem(oOghren,GetItemInEquipSlot(INVENTORY_SLOT_MAIN,oOghren));

            // Qwinn added:  four Bhelen supporters whose dialogue is only appropriate under bBhelenSupporters condition above
            object      oBhelenSupporter1   = UT_GetNearestCreatureByTag( oPC, "orz300cr_amb_f_1" );
            object      oBhelenSupporter2   = UT_GetNearestCreatureByTag( oPC, "orz320cr_amb_f_2" );
            object      oBhelenSupporter3   = UT_GetNearestCreatureByTag( oPC, "orz320cr_amb_m_1" );
            object      oBhelenSupporter4   = UT_GetNearestCreatureByTag( oPC, "orz320cr_amb_m_2" );
            SetObjectInteractive (oBhelenSupporter1, bBhelenSupporters);
            SetObjectInteractive (oBhelenSupporter2, bBhelenSupporters);
            SetObjectInteractive (oBhelenSupporter3, bBhelenSupporters);
            SetObjectInteractive (oBhelenSupporter4, bBhelenSupporters);

            // Qwinn:  Restored Oghren's may I join dialogue.  He should always be in party but just in case
            if ((bHarrowKing || bBhelenKing) &&
                 WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_PARTY) &&
                 !WR_GetPlotFlag(PLT_GENPT_OGHREN_EVENTS,OGHREN_EVENT_OFFERS_TO_JOIN_PARTY))
            {
               WR_SetPlotFlag(PLT_GENPT_OGHREN_EVENTS,OGHREN_EVENT_ON,TRUE);
               WR_SetPlotFlag(PLT_GENPT_OGHREN_EVENTS,OGHREN_EVENT_OFFERS_TO_JOIN_PARTY,TRUE,TRUE);
            }
            
            // Qwinn added
            if (WR_GetPlotFlag(PLT_ORZ200PT_WRANGLER,ORZ_WRANGLER_PLOT_ACCEPTED))
            {
               UT_TeamAppears( ORZ_TEAM_ESCAPED_NUGS );
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

            DoAutoSave();

            break;
        }
    }

    //--------------------------------------------------------------------------
    // Pass any unhandled events to orzar_core ( Paragon Area Core )
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, ORZ_RESOURCE_SCRIPT_AREA_CORE );

}