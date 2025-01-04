//==============================================================================
/*

    Coronation Ceremony
     -> Epilogue Coronation Ceremony (Plays when area loads)

*/
//------------------------------------------------------------------------------
// Created By: Mark Barazzuol
// Created On: May 27, 2008
//==============================================================================

#include "utility_h"
#include "epi_constants_h"
#include "epi_attendees_h"
#include "cutscenes_h"

#include "plt_epipt_main"
#include "plt_denpt_main"
#include "plt_denpt_alistair"
#include "plt_mnp00pt_ssf_epilogue"
#include "plt_gen00pt_party"

#include "approval_h"

// This will determine which cutscene to jump to after the coronation,
// either the funeral, or the post coronation.
void Epi_CutsceneSelect(resource rCutscene);

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Constants


    // Load Event Variables
    event   evEvent         = GetCurrentEvent();            // Event
    int     nEventType      = GetEventType(evEvent);        // Event Type
    object  oEventCreator   = GetEventCreator(evEvent);     // Event Creator

    // Standard Stuff
    object  oPC             = GetHero();
    object  oParty          = GetParty( oPC );
    int     bEventHandled   = FALSE;


    //--------------------------------------------------------------------------
    // Area Events
    //--------------------------------------------------------------------------

    switch ( nEventType )
    {


        case EVENT_TYPE_AREALOAD_PRELOADEXIT:
        {

            object oPC = GetHero();

            // Dress Alistair Properly
            EPI_EquipAlistair();
            break;
        }


        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {
            int         bAreaLoadedOnce;
            int         bKingOnly, bKingAndQueen, bQueenOnly, bPlayerMarryAlistair, bAlistairDead;

            //------------------------------------------------------------------

            bAreaLoadedOnce         = GetLocalInt( OBJECT_SELF, AREA_COUNTER_1 );
            bKingOnly               = WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_ALISTAIR_DELIVER_SPEECH);
            bKingAndQueen           = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_ANORA);
            bQueenOnly              = WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_ANORA_DELIVER_SPEECH);
            bPlayerMarryAlistair    = WR_GetPlotFlag(PLT_DENPT_ALISTAIR, DEN_ALISTAIR_MARRYING_PLAYER);
            // Qwinn fixed
            // bAlistairDead           = WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_ALISTAIR_DELIVER_SPEECH);
            bAlistairDead =          (WR_GetPlotFlag(PLT_CLIPT_ARCHDEMON,CLIMAX_ARCHDEMON_ALISTAIR_KILLS_ARCHDEMON) ||
                                      WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_ALISTAIR_KILLED));


            //------------------------------------------------------------------

            // First time initial coronation scene plays
            if( !bAreaLoadedOnce )
            {

                // Mark Story so far plot
                WR_SetPlotFlag(PLT_MNP00PT_SSF_EPILOGUE,SSF_EPI_POST_CORONATION,TRUE, TRUE);
                
                // Qwinn added
                string sGiftCountVar = Approval_GetFollowerGiftCountVar(APP_FOLLOWER_OGHREN);
                SetLocalInt(GetModule(), sGiftCountVar, 0);

                SaveGamePostCampaign();

                // Removes the player's party
                EPI_RemoveParty();

                // Remove effects on player
                Effects_RemoveUpkeepEffect(oPC, 0);
                RemoveEffectsDueToPlotEvent(oPC);

                // Unequip PC weapons
                UnequipItem(oPC, GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oPC));
                UnequipItem(oPC, GetItemInEquipSlot(INVENTORY_SLOT_OFFHAND, oPC));
                UnequipItem(oPC, GetItemInEquipSlot(INVENTORY_SLOT_RANGEDAMMO, oPC));

                SetLocalInt( OBJECT_SELF, AREA_COUNTER_1, TRUE );



                // Alistair to give the speech if he is the sole King
                // OR if he is married to Anora.

                // Qwinn: Alistair wouldn't be crowned if Loghain joined party
                /*
                if (bKingOnly)
                {
                    if(bKingAndQueen)
                        Epi_CutsceneSelect(CUTSCENE_EPI_CORONATION_KING_QUEEN);
                    else
                        Epi_CutsceneSelect(CUTSCENE_EPI_CORONATION_KING_ONLY);
                }
                else    // Anora to give the speech if she is the sole Queen.
                    Epi_CutsceneSelect(CUTSCENE_EPI_CORONATION_QUEEN_ONLY);
                */
                if (bKingAndQueen && !bAlistairDead)
                   Epi_CutsceneSelect(CUTSCENE_EPI_CORONATION_KING_QUEEN);
                else if (bKingOnly)
                   Epi_CutsceneSelect(CUTSCENE_EPI_CORONATION_KING_ONLY);
                else
                   Epi_CutsceneSelect(CUTSCENE_EPI_CORONATION_QUEEN_ONLY);
            }
            break;

        }

    }

    //--------------------------------------------------------------------------
    // Pass any unhandled events to area_core
    //--------------------------------------------------------------------------

    if ( !bEventHandled )
        HandleEvent( evEvent, AREA_CORE );

}

void Epi_CutsceneSelect(resource rCutscene)
{
    int bPlayerIsDead = WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_PLAYER_IS_DEAD);

    if (bPlayerIsDead)
    {
        // Jump to funeral
        CS_LoadCutscene(rCutscene, PLT_EPIPT_MAIN, EPI_JUMP_TO_FUNERAL);
    }

    else
    {
        // Jump to post coronation
        CS_LoadCutscene(rCutscene, PLT_EPIPT_MAIN, EPI_JUMP_TO_POST_CORONATION);

    }
}