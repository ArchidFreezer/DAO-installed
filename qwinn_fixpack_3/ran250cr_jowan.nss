// Jowan random encounter

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "ran_constants_h"
#include "plt_ranpt_generic_actions"

// Qwinn added
#include "plt_lite_chant_rand_jowan"

void main()
{
    event   ev              = GetCurrentEvent();
    int     nEventType      = GetEventType(ev);
    string  sDebug;
    object  oPC             = GetHero();
    object  oParty          = GetParty(oPC);
    int     nEventHandled   = FALSE;
    object  oArea           = GetArea(oPC);

    // Characters
    object oJowan           = GetObjectByTag(RND_CR_JOWAN);
    object oRefugee_A       = GetObjectByTag(RND_CR_250_REFUGEE_A);
    object oRefugee_B       = GetObjectByTag(RND_CR_250_REFUGEE_B);
    object oRefugee_C       = GetObjectByTag(RND_CR_250_REFUGEE_C);

    command cWave               = CommandPlayAnimation(606,1);
    command cSurprised          = CommandPlayAnimation(600,1);
    command cDistressed         = CommandPlayAnimation(602,1);
    command cCrouch_Start       = CommandPlayAnimation(905,1);
    command cCrouch_Loop        = CommandPlayAnimation(907,1);
    command cCrouch_Exit        = CommandPlayAnimation(906,1);


    switch(nEventType)
    {

        case EVENT_TYPE_AREALOAD_POSTLOADEXIT:
        {

            // Declare event
            event eAmbushWave1;
            event eAmbushWave2;
            event eAmbushWave3;
            event eJowanBark;

            eAmbushWave1 = Event(EVENT_TYPE_CUSTOM_EVENT_01);
            eAmbushWave2 = Event(EVENT_TYPE_CUSTOM_EVENT_02);
            eAmbushWave3 = Event(EVENT_TYPE_CUSTOM_EVENT_03);
            eJowanBark   = Event(EVENT_TYPE_CUSTOM_EVENT_04);

            DelayEvent(2.0, oArea, eAmbushWave1);
            DelayEvent(4.0, oArea, eJowanBark);
            DelayEvent(10.0, oArea, eAmbushWave2);
            DelayEvent(22.0, oArea, eAmbushWave3);

            // Jowan Waves
            AddCommand(oJowan, cWave, FALSE, TRUE);

            break;
        }
        // Ambush Start -
        case EVENT_TYPE_CUSTOM_EVENT_01:
        {
            // First wave of wolves and bears run towards Jowan
            // Then go hostile
            UT_TeamAppears(RAN_TEAM_250_WAVE_1, TRUE);
            break;
        }

        case EVENT_TYPE_CUSTOM_EVENT_02:
        {
            // Second Wave
            UT_TeamAppears(RAN_TEAM_250_WAVE_2, TRUE);
            break;
        }

        case EVENT_TYPE_CUSTOM_EVENT_03:
        {
            // Second Wave
            UT_TeamAppears(RAN_TEAM_250_WAVE_3, TRUE);
            break;
        }

        case EVENT_TYPE_CUSTOM_EVENT_04:
        {
            // Jowan Barks
            UT_Talk(oJowan, oPC);
            break;
        }


        case EVENT_TYPE_COMBAT_END:
        {
            UT_Talk(OBJECT_SELF, oPC);
            break;
        }
        case EVENT_TYPE_DEATH:
        {
            // Set Jowan dead (for epilogue)
            object oKiller = GetEventCreator(ev);

            if (IsDead(oJowan))
            {
                WR_SetPlotFlag(PLT_RANPT_GENERIC_ACTIONS, RAN_JOWAN_DEAD, TRUE);
                // Qwinn added, in case he's killed but not by the player
                if (!WR_GetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN,JOWAN_PLOT_COMPLETED_DEAD))
                   WR_SetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN,JOWAN_PLOT_COMPLETED,TRUE);
            }

            break;
        }
        case EVENT_TYPE_TEAM_DESTROYED:
        {

            int nTeamID = GetEventInteger( ev, 0 );

            // Monster Waves dead and Jowan dead booleans
            int bWave1;
            int bWave2;
            int bWave3;
            int bJowanDead;

            if (nTeamID == RAN_TEAM_250_WAVE_1)
            {
                WR_SetPlotFlag(PLT_RANPT_GENERIC_ACTIONS, RAN_250_WAVE_DEAD_1, TRUE);
            }

            if (nTeamID == RAN_TEAM_250_WAVE_2)
            {
                WR_SetPlotFlag(PLT_RANPT_GENERIC_ACTIONS, RAN_250_WAVE_DEAD_2, TRUE);
            }

            if (nTeamID == RAN_TEAM_250_WAVE_3)
            {
                WR_SetPlotFlag(PLT_RANPT_GENERIC_ACTIONS, RAN_250_WAVE_DEAD_3, TRUE);
            }

            bWave1      = WR_GetPlotFlag(PLT_RANPT_GENERIC_ACTIONS, RAN_250_WAVE_DEAD_1);
            bWave2      = WR_GetPlotFlag(PLT_RANPT_GENERIC_ACTIONS, RAN_250_WAVE_DEAD_2);
            bWave3      = WR_GetPlotFlag(PLT_RANPT_GENERIC_ACTIONS, RAN_250_WAVE_DEAD_3);
            bJowanDead  = IsDead(oJowan);

            // If All waves now dead, and Jowan alive trigger talk
            if (bWave1 && bWave2 && bWave3 && !bJowanDead)
            {
                UT_Talk(oJowan, oPC);
            }


        }


    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}