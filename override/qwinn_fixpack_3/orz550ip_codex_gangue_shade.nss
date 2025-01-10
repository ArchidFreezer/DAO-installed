//==============================================================================
/*

    orz550ip_codex_gangue_shade

    Checks to see if the player, or one of the player's party, has equiped the
    legion of the dead armour. If so activates the Gangue Shade.

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: October 27, 2008
//==============================================================================

#include "utility_h"        
#include "placeable_h"

#include "orz_constants_h"

#include "plt_cod_hst_orz_gangue"

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evCurEvent  = GetCurrentEvent();           // Event parameters
    int     nEventType  = GetEventType(evCurEvent);    // Event type triggered
    object  oEventOwner = GetEventCreator(evCurEvent); // Triggering character
    object  oThis       = OBJECT_SELF;                 // Object running this
    object  oPC         = GetHero();                   // Player character

    int bEventHandled = FALSE;

    //--------------------------------------------------------------------------
    // Events
    //--------------------------------------------------------------------------

    switch(nEventType)
    {

        case EVENT_TYPE_PLACEABLE_ONCLICK:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_PLACEABLE_ONCLICK
            // SENT BY: Engine
            //------------------------------------------------------------------

            string sCodexPlot, sPlotSummary;
            int nCodexFlag, nCodexName;

            sCodexPlot = PLT_COD_HST_ORZ_GANGUE;
            nCodexFlag = COD_ORZ_GANGUE;

            sPlotSummary = GetPlotSummary(sCodexPlot, nCodexFlag);

            if ( !WR_GetPlotFlag(sCodexPlot, nCodexFlag) )
            {

                object oMapPin;

                oMapPin = GetObjectByTag( ORZ_WP_GANGUE_SHADE );

                SetMapPinState( oMapPin, TRUE );
                WR_SetPlotFlag( sCodexPlot, nCodexFlag, TRUE, TRUE );
                
                UI_DisplayCodexMessage( OBJECT_SELF, sPlotSummary );
                
                // Qwinn added
                RewardXPParty(XP_CODEX, XP_TYPE_CODEX, OBJECT_INVALID, GetHero()); 
            
                //SetLocalString( OBJECT_SELF, PLC_CODEX_PLOT, "" );
                //SetLocalInt( OBJECT_SELF, PLC_CODEX_FLAG, -1 );

                bEventHandled = TRUE;

            }

            break;

        }

        case EVENT_TYPE_USE:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_USE
            // SENT BY: Engine
            //------------------------------------------------------------------

            object [] arParty;
            object oArmor, oHelmet, oGloves, oBoots, oPartyMember, oShade;

            int bArmor, bHelmet, bGloves, bBoots;
            int nNth, nPartySize, bLegion;

            arParty     = GetPartyList();
            nPartySize  = GetArraySize( arParty );
            bLegion     = FALSE;

            // Test for the armor

            for ( nNth = 0; nNth < nPartySize; ++nNth )
            {

                oPartyMember = arParty[nNth];

                oArmor  = GetItemInEquipSlot( INVENTORY_SLOT_CHEST,  oPartyMember );
                oHelmet = GetItemInEquipSlot( INVENTORY_SLOT_HEAD,   oPartyMember );
                oGloves = GetItemInEquipSlot( INVENTORY_SLOT_GLOVES, oPartyMember );
                oBoots  = GetItemInEquipSlot( INVENTORY_SLOT_BOOTS,  oPartyMember );

                bArmor  = GetTag( oArmor  ) == ORZ_IM_LEGION_ARMOR;
                bHelmet = GetTag( oHelmet ) == ORZ_IM_LEGION_HELMET;
                bGloves = GetTag( oGloves ) == ORZ_IM_LEGION_GLOVES;
                bBoots  = GetTag( oBoots  ) == ORZ_IM_LEGION_BOOTS;

                if ( bArmor && bHelmet && bGloves && bBoots )
                {

                    bLegion = TRUE;
                    break;

                }

            }

            // Spawn the shade

            if ( bLegion )
            {

                oShade = GetObjectByTag( ORZ_CR_GANGUE_SHADE );
                WR_SetObjectActive( oShade, TRUE );
                SetObjectInteractive( oThis, FALSE );
                bEventHandled = TRUE;

            }

            break;

        }

    }

    // Send event to placeables_core
    if (!bEventHandled)
        HandleEvent( evCurEvent, RESOURCE_SCRIPT_PLACEABLE_CORE );

}