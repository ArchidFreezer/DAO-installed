//==============================================================================
/*

    Item Acquired Event Script
     -> Urn of Sacred Ashes

*/
//------------------------------------------------------------------------------
// Created By: Grant Mackay
// Created On: Sept 08
//==============================================================================

#include "utility_h"
#include "events_h"
#include "sys_audio_h"

#include "plt_urnpt_main"
#include "plt_urn100pt_haven"
#include "urn_functions_h"
#include "urn_dragon_h"

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent     = GetCurrentEvent();
    int     nEventType  = GetEventType(evEvent);

    // Grab Player, set default event handled to false
    object  oPC           = GetHero();
    int     bEventHandled = FALSE;

    Log_Events(GetCurrentScriptName(),evEvent);

    //--------------------------------------------------------------------------

    switch(nEventType)
    {


        case EVENT_TYPE_CAMPAIGN_ITEM_ACQUIRED:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_CAMPAIGN_ITEM_ACQUIRED
            //------------------------------------------------------------------
            // Sent by: Scripting
            // When:    Item is added to inventory that has
            //          ITEM_SEND_ACQUIRED_EVENT set to TRUE
            //------------------------------------------------------------------

            string      sItemTag;
            object      oItem;
            object      oAcquirer;

            //------------------------------------------------------------------

            oAcquirer = GetEventCreator(evEvent);
            oItem     = GetEventObject(evEvent, 0);
            sItemTag  = GetTag(oItem);

            //------------------------------------------------------------------

                          
            // Qwinn:  Disabled here, this will be set when Genitivi is informed that you have it
            /*
            if ( sItemTag == URN_IT_MEDALLION )
            {

                if ( WR_GetPlotFlag(PLT_URN100PT_HAVEN, PC_NEEDS_MEDALLION) )
                    WR_SetPlotFlag( PLT_URN100PT_HAVEN, PC_ACQUIRED_MEDALLION, TRUE, TRUE );

            }

            else */ if ( sItemTag == URN_IT_RESEARCH )
            {

                WR_SetPlotFlag( PLT_URNPT_MAIN, HAVEN_OPENED, TRUE, TRUE );

            }

            else if ( sItemTag == URN_IT_PEARL || sItemTag == URN_IT_TAPER )
            {
                URN_ItemAcquired();
            }


            bEventHandled = TRUE;
            break;

        }


        case EVENT_TYPE_UNIQUE_POWER:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_UNIQUE_POWER
            //------------------------------------------------------------------
            // Sent by: Scripting
            // When:    A unique power for an item is used
            //------------------------------------------------------------------

            int         nAbility;
            string      sItemTag;
            object      oItem;
            object      oCaster;
            object      oTarget;

            //------------------------------------------------------------------

            nAbility = GetEventInteger(evEvent,0);
            oItem    = GetEventObject(evEvent, 0);
            oCaster  = GetEventObject(evEvent, 1);
            oTarget  = GetEventObject(evEvent, 2);
            sItemTag = GetTag(oItem);

            //------------------------------------------------------------------

            if ( sItemTag == URN_IT_DRAGON_HORN )
            {

                object oDragon  = UT_GetNearestObjectByTag( oCaster, URN_CR_DRAGON );
                float fDistance = GetDistanceBetween( oCaster, oDragon );

                if ( fDistance < 80.0 )
                {

                    UHD_SetState( oDragon, UHD_STATE_ATTACK );

                    DestroyObject( OBJECT_SELF );


                }

                object oSound = GetObjectByTag( "sfx_dragonhorn_sgl" );
                PlaySoundObject( oSound );

            }

            bEventHandled = TRUE;
            break;

        }


    }

    if (!bEventHandled)
        HandleEvent(evEvent, RESOURCE_SCRIPT_MODULE_CORE);

}