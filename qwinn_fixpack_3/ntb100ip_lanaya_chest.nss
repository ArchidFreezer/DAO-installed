// All placeable events for Lanaya's chest

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"

#include "ntb_constants_h"
#include "plt_ntb100pt_lanaya"
#include "plt_ntb000pt_main"

#include "plt_qwinn"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);


    switch(nEventType)
    {
        ////////////////////////////////////////////////////////////////////////
        // Sent by: The engine
        // When: A creature has clicked on this placeable
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_USE:
        {
            object oUser = GetEventCreator(ev);
            object oLanaya = UT_GetNearestCreatureByTag(oPC,NTB_CR_LANAYA);
            int nChest = WR_GetPlotFlag(PLT_NTB100PT_LANAYA,NTB_LANAYA_GIVES_PC_CHEST_WARNING);
            int nAngry = WR_GetPlotFlag(PLT_NTB100PT_LANAYA,NTB_LANAYA_ANGRIER_AT_PC);
            int nElfAlliance = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE);
            int nCanOpen = WR_GetPlotFlag(PLT_QWINN,NTB_LANAYA_PC_CAN_OPEN_CHEST);
            // -----------------------------------------------------
            // if you haven't been given the warning yet
            // set that you're trying to open the chest
            // -----------------------------------------------------
            //if it is post plot - you can just open the chest
            if(nElfAlliance == TRUE)
            {
                HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
            }
            else if(nCanOpen == TRUE)
            {
                HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
            }
            else if(nChest == FALSE)
            {
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA,NTB_LANAYA_PC_TRIED_TO_OPEN_CHEST_NEARBY,TRUE);
                UT_Talk(oLanaya,oPC);
            }
            // -----------------------------------------------------
            // if Lanaya is not yet angrier at you
            // set that she starts being angry
            // -----------------------------------------------------
            else if(nAngry == FALSE)
            {
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA,NTB_LANAYA_SPEAKS_TO_ZATHRIAN,FALSE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA,NTB_LANAYA_ANGRY_AT_PC,TRUE);
                WR_SetPlotFlag(PLT_NTB100PT_LANAYA,NTB_LANAYA_RETURNS_TO_POST_AFTER_ZATHRIAN,FALSE);
                SetObjectInteractive(oLanaya, TRUE);
                UT_Talk(oLanaya,oPC);
            }
            // -----------------------------------------------------
            // Else just open the chest
            // -----------------------------------------------------
            else
            {
                HandleEvent(ev, RESOURCE_SCRIPT_PLACEABLE_CORE);
            }

            break;
        }
        // Effects

    }

}