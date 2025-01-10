//==============================================================================
/*

    orz550tr_gangue_shade

    Checks to see if the player, or one of the player's party, has equiped the
    legion of the dead armour. If so activates the Gangue Shade.

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: October 27, 2008
//==============================================================================

#include "utility_h"

#include "orz_constants_h"

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evCurEvent  = GetCurrentEvent();           // Event parameters
    int     nEventType  = GetEventType(evCurEvent);    // Event type triggered
    object  oEventOwner = GetEventCreator(evCurEvent); // Triggering character
    object  oPC         = GetHero();                   // Player character

    //--------------------------------------------------------------------------
    // Events
    //--------------------------------------------------------------------------

    switch(nEventType)
    {


        case EVENT_TYPE_ENTER:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_ENTER
            // SENT BY: Engine
            //------------------------------------------------------------------

            object [] arParty;
            object oArmor, oHelmet, oGloves, oBoots, oPartyMember, oShade;

            int bArmor, bHelmet, bGloves, bBoots;
            int nNth, nPartySize, bLegion;

            //------------------------------------------------------------------

            arParty     = GetPartyList();
            nPartySize  = GetArraySize( arParty );
            bLegion     = FALSE;

            // Test for the armor

            for ( nNth = 0; nNth < nPartySize; ++nNth )
            {

                oPartyMember = arParty[nNth];

                if (IsObjectValid(GetItemInEquipSlot(INVENTORY_SLOT_BITE, oPartyMember)))
                {  oArmor  = GetItemInEquipSlot( INVENTORY_SLOT_BITE, oPartyMember ); }
                else
                {  oArmor  = GetItemInEquipSlot( INVENTORY_SLOT_CHEST, oPartyMember ); }
      
                if (IsObjectValid(GetItemInEquipSlot(INVENTORY_SLOT_CLOAK, oPartyMember)))
                {  oHelmet  = GetItemInEquipSlot( INVENTORY_SLOT_CLOAK, oPartyMember ); }
                else
                {  oHelmet  = GetItemInEquipSlot( INVENTORY_SLOT_HEAD, oPartyMember ); }
      
                if (IsObjectValid(GetItemInEquipSlot(INVENTORY_SLOT_SHALE_SHOULDERS, oPartyMember)))
                {  oGloves  = GetItemInEquipSlot( INVENTORY_SLOT_SHALE_SHOULDERS, oPartyMember ); }
                else
                {  oGloves  = GetItemInEquipSlot( INVENTORY_SLOT_GLOVES, oPartyMember ); }
      
                if (IsObjectValid(GetItemInEquipSlot(INVENTORY_SLOT_SHALE_LEFTARM, oPartyMember)))
                {  oBoots  = GetItemInEquipSlot( INVENTORY_SLOT_SHALE_LEFTARM, oPartyMember ); }
                else
                {  oBoots  = GetItemInEquipSlot( INVENTORY_SLOT_BOOTS, oPartyMember ); }
      
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

            }

            break;

        }

    }

    // Send event to trigger_core
    HandleEvent( evCurEvent, RESOURCE_SCRIPT_TRIGGER_CORE );

}