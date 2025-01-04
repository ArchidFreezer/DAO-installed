#include "utility_h"
#include "wrappers_h"
#include "sys_rewards_h"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    object oPC = GetHero();
    object oDog = GetObjectByTag("vgk310cr_dog");
    object oArea = GetArea(OBJECT_SELF);
    location lNote = Location(oArea, Vector(11.46, -28.1, -3.93), -157.87);
    int nResult = FALSE;

    object oNote = GetItemPossessedBy(oPC, "vgk310im_adria_note");
    object oNotePlaceable = GetObjectByTag("vgk320_adria_note");

    if(nType == EVENT_TYPE_SET_PLOT)
    {
        int nValue = GetEventInteger(eParms, 2);
        int nOldValue = GetEventInteger(eParms, 3);
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!

        switch(nFlag)
        {
            case 0:
            {
                SetPlotGiver(oDog, FALSE);
                RewardDistibuteByPlotFlag(strPlot, 0);
                SetObjectActive(oNotePlaceable, FALSE);
                if (WR_GetPlotFlag(strPlot, 5))
                {
                    SetObjectInteractive(oDog, FALSE);
                }
                break;
            }

            case 1:
            {
                if (WR_GetPlotFlag(strPlot, 5) == FALSE)
                {
                    KillCreature(oDog, OBJECT_INVALID);
                    SetObjectInteractive(oDog, FALSE);
                }
                break;
            }

            case 2:
            {
                SetPlotGiver(oDog, FALSE);
                KillCreature(oDog, OBJECT_INVALID);
                SetCreatureGoreLevel(oPC, 0.05f);
                if (WR_GetPlotFlag(strPlot, 0) == FALSE)
                {
                    oNotePlaceable = CreateObject(OBJECT_TYPE_PLACEABLE, R"vgk320_adria_note.utp", lNote);
                    SetPlotGiver(oNotePlaceable, TRUE);
                }
                break;
            }

            case 3:
            {
                SetPlotGiver(oDog, FALSE);
                UT_TeamGoesHostile(40110, TRUE);
                break;
            }

            case 5:
            {
                RewardDistibuteByPlotFlag(strPlot, 5);
                if (WR_GetPlotFlag(strPlot, 0))
                {
                    SetObjectInteractive(oDog, FALSE);
                }
                break;
            }
        }
     }

    return nResult;
}