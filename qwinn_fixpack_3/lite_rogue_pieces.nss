//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for the "Solving Problems" (Box of Certain Interests)
*/
//:://////////////////////////////////////////////
//:: Created By: Joshua
//:: Created On: Jan 14th, 2009
//:://////////////////////////////////////////////


// Qwinn:  Completely rewrote on 03/27/2017
// The original used two placeables for each dead drop, a "DEAD_DROP_1" and a "BARREL_1", and the
// latter would replace the former when making a delivery.  No idea why it was done this way.  The
// DEAD_DROP version was invisible, probably because, if both were visible you would get bizarre
// graphical glitches on the barrel even if one of the versions was deactivated.  There is no need
// for two placeables, can do everything needed by just flipping interactive on and off.  Keeping the
// DEAD_DROP version rather than the BARRELs because it has all the plot markers assigned to it.
// All references to the "BARREL" version of the placeable are removed.
// Resulting code is MUCH MUCH simpler, doesn't cause graphical glitches, and works.
// Does require changing the appearance of placeable liteip_rogue_deaddrop.utp to "Barrel, Oil (Examinable)"

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "lit_constants_h"

#include "sys_injury"

#include "plt_lite_rogue_pieces"

void _Disarm(object oConversationOwner)
{
    string sTag = GetTag(oConversationOwner);
    if (sTag==LITE_IP_ROGUE_DEAD_DROP_1)
        WR_SetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_DISARMED_1,TRUE);
    else if (sTag==LITE_IP_ROGUE_DEAD_DROP_2)
        WR_SetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_DISARMED_2,TRUE);
    else if (sTag==LITE_IP_ROGUE_DEAD_DROP_3)
        WR_SetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_DISARMED_3,TRUE);
    else if (sTag==LITE_IP_ROGUE_DEAD_DROP_4)
        WR_SetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_DISARMED_4,TRUE);

    if (WR_GetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_DISARMED_1)&&
        WR_GetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_DISARMED_2)&&
        WR_GetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_DISARMED_3)&&
        WR_GetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_DISARMED_4))
        WR_SetPlotFlag(PLT_LITE_ROGUE_PIECES,PIECES_DISARM_CLOSED,TRUE,TRUE);
}

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int nResult = FALSE; // used to return value for DEFINED GET events
    object oPC = GetHero();

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case PIECES_PLOT_ACCEPTED:
            case PIECES_PLOT_SETUP:
            {
                int bPlotAccepted   = WR_GetPlotFlag(strPlot,PIECES_PLOT_ACCEPTED);
                int bPlotClosed     = WR_GetPlotFlag(strPlot,PIECES_PLOT_CLOSED);
                int bPlotFailed     = WR_GetPlotFlag(strPlot,PIECES_TERMINATED_K_DEAD);
                int bPlotActive     = bPlotAccepted && !(bPlotClosed||bPlotFailed);
                
                object oDeadDrop1   = UT_GetNearestObjectByTag(oPC, LITE_IP_ROGUE_DEAD_DROP_1);
                object oDeadDrop2   = UT_GetNearestObjectByTag(oPC, LITE_IP_ROGUE_DEAD_DROP_2);
                object oDeadDrop3   = UT_GetNearestObjectByTag(oPC, LITE_IP_ROGUE_DEAD_DROP_3);
                object oDeadDrop4   = UT_GetNearestObjectByTag(oPC, LITE_IP_ROGUE_DEAD_DROP_4);
                
                int bDisarmed1      = WR_GetPlotFlag(strPlot,PIECES_DISARMED_1);
                int bDisarmed2      = WR_GetPlotFlag(strPlot,PIECES_DISARMED_2);
                int bDisarmed3      = WR_GetPlotFlag(strPlot,PIECES_DISARMED_3);
                int bDisarmed4      = WR_GetPlotFlag(strPlot,PIECES_DISARMED_4);

                WR_SetObjectActive(oDeadDrop1, bPlotActive && !bDisarmed1);
                WR_SetObjectActive(oDeadDrop2, bPlotActive && !bDisarmed2);
                WR_SetObjectActive(oDeadDrop3, bPlotActive && !bDisarmed3);
                WR_SetObjectActive(oDeadDrop4, bPlotActive && !bDisarmed4);                

                if (bPlotActive)
                {
                   int bDelivered1     = WR_GetPlotFlag(strPlot,PIECES_DELIVERED_1);
                   int bDelivered2     = WR_GetPlotFlag(strPlot,PIECES_DELIVERED_2);
                   int bDelivered3     = WR_GetPlotFlag(strPlot,PIECES_DELIVERED_3);
                   int bDelivered4     = WR_GetPlotFlag(strPlot,PIECES_DELIVERED_4);
                   int bPlotCompleted  = WR_GetPlotFlag(strPlot,PIECES_PLOT_COMPLETED);

                   SetObjectInteractive(oDeadDrop1,(!bDelivered1 || (bPlotCompleted && !bDisarmed1)));
                   SetObjectInteractive(oDeadDrop2,(!bDelivered2 || (bPlotCompleted && !bDisarmed2)));
                   SetObjectInteractive(oDeadDrop3,(!bDelivered3 || (bPlotCompleted && !bDisarmed3)));
                   SetObjectInteractive(oDeadDrop4,(!bDelivered4 || (bPlotCompleted && !bDisarmed4)));                   
                }
                break;
            }
            case PIECES_EXPLODE:
            {
                _Disarm(oConversationOwner);
                if (!WR_GetPlotFlag(strPlot,PIECES_PLOT_COMPLETED))
                {
                    WR_SetPlotFlag(strPlot,PIECES_PLOT_COMPLETED,TRUE);
                    WR_SetPlotFlag(strPlot,PIECES_PLOT_SETUP,TRUE,TRUE);
                }
                Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_TEMPORARY,EffectVisualEffect(18),GetLocation(oConversationOwner),2.0f);
                Injury_DetermineInjury(oPC);
                WR_SetObjectActive(oConversationOwner,FALSE);
                break;
            }
            case PIECES_DISARM:
            {
                _Disarm(oConversationOwner);
                SetObjectInteractive(oConversationOwner,FALSE);
                break;
            }
            case PIECES_DELIVER:
            {
                object oDeadDrop;
                string sTag = GetTag(oConversationOwner);
                if (sTag==LITE_IP_ROGUE_DEAD_DROP_1)
                {
                    oDeadDrop = UT_GetNearestObjectByTag(oPC, LITE_IP_ROGUE_DEAD_DROP_1);
                    SetObjectInteractive(oDeadDrop,FALSE);
                    WR_SetPlotFlag(strPlot,PIECES_DELIVERED_1,TRUE);
                }
                else if (sTag==LITE_IP_ROGUE_DEAD_DROP_2)
                {
                    oDeadDrop = UT_GetNearestObjectByTag(oPC, LITE_IP_ROGUE_DEAD_DROP_2);
                    SetObjectInteractive(oDeadDrop,FALSE);
                    WR_SetPlotFlag(strPlot,PIECES_DELIVERED_2,TRUE);
                }
                else if (sTag==LITE_IP_ROGUE_DEAD_DROP_3)
                {
                    oDeadDrop = UT_GetNearestObjectByTag(oPC, LITE_IP_ROGUE_DEAD_DROP_3);
                    SetObjectInteractive(oDeadDrop,FALSE);
                    WR_SetPlotFlag(strPlot,PIECES_DELIVERED_3,TRUE);
                }
                else if (sTag==LITE_IP_ROGUE_DEAD_DROP_4)
                {
                    oDeadDrop = UT_GetNearestObjectByTag(oPC, LITE_IP_ROGUE_DEAD_DROP_4);
                    SetObjectInteractive(oDeadDrop,FALSE);
                    WR_SetPlotFlag(strPlot,PIECES_DELIVERED_4,TRUE);
                }
                break;
            }

            case PIECES_PLOT_CLOSED:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ROGUE_6);

                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case PIECES_FINAL_DELIVERY:
            {
                int nTotal = 0;
                if (WR_GetPlotFlag(strPlot,PIECES_DELIVERED_1)) nTotal++;
                if (WR_GetPlotFlag(strPlot,PIECES_DELIVERED_2)) nTotal++;
                if (WR_GetPlotFlag(strPlot,PIECES_DELIVERED_3)) nTotal++;
                if (WR_GetPlotFlag(strPlot,PIECES_DELIVERED_4)) nTotal++;
                if (nTotal>=4)
                    nResult = TRUE;
                break;
            }

            case PIECES_CAN_DISARM:
            {
                if (WR_GetPlotFlag(strPlot,PIECES_PLOT_COMPLETED)&&!WR_GetPlotFlag(strPlot,PIECES_DISARM_CLOSED))
                    nResult = TRUE;
                break;
            }
        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}