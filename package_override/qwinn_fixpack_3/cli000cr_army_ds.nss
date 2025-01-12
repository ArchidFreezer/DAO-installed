// Generic DS army soldier

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "cli_constants_h"
#include "ai_constants_h"
#include "ai_main_h_2"

#include "plt_clipt_generic_actions"
#include "plt_clipt_general_alienage"
#include "plt_clipt_general_market"

#include "plt_clipt_archdemon"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    string sDebug;
    object oPC = GetHero();
    object oParty = GetParty(oPC);
    int nEventHandled = FALSE;

    switch(nEventType)
    {

        ////////////////////////////////////////////////////////////////////////
        // Sent by: AI scripts
        // When: The current creature dies
        ////////////////////////////////////////////////////////////////////////
        case EVENT_TYPE_DEATH:
        {
            object oKiller = GetEventCreator(ev);
            object oArea = GetArea(OBJECT_SELF);
            int nSoldierID = GetLocalInt(OBJECT_SELF, CREATURE_COUNTER_1);
            int nArmyID = GetLocalInt(OBJECT_SELF, CREATURE_COUNTER_2);

            if(GetTag(OBJECT_SELF) == "cli600cr_alien_ds_leader")
            {
                WR_SetPlotFlag(PLT_CLIPT_GENERIC_ACTIONS, CLI_ACTIONS_GENERAL_DEAD_ALIENAGE, TRUE);
                WR_SetPlotFlag(PLT_CLIPT_GENERAL_ALIENAGE, CLIPT_GENERAL_ALIENAGE_KILLED, TRUE);
                // Qwinn added
                if(SubString(GetTag(GetArea(oPC)),0,6) == "cli600")
                {
                   object oRetreatExit = UT_GetNearestObjectByTag(oPC, "wmt_cli_generic");
                   SetObjectInteractive(oRetreatExit, FALSE);
                   SetObjectActive(oRetreatExit, FALSE);
                }
            }
            else if(GetTag(OBJECT_SELF) == "cli700cr_market_ds_leader")
            {
                WR_SetPlotFlag(PLT_CLIPT_GENERIC_ACTIONS, CLI_ACTIONS_GENERAL_DEAD_MARKET, TRUE);
                WR_SetPlotFlag(PLT_CLIPT_GENERAL_MARKET, CLIPT_GENERAL_MARKET_KILLED, TRUE);
            }

            if(WR_GetPlotFlag(PLT_CLIPT_ARCHDEMON, CLIMAX_ARCHDEMON_DEFEATED, TRUE))
            {
                Log_Trace(LOG_CHANNEL_PLOT, "DS ARMY SOLDIER DEATH EVENT", "ARCHDEMON DEFEATED - not spawning more DS");
                break;
            }

            if(nArmyID <= 0)
                nArmyID = GetTeamId(OBJECT_SELF);

            // Find what side this darkspawn belongs to:
            //  if nearest to city gates waypoint when died - counter_1
            //  if nearest to market waypoint when died - counter_2
            object oSpawnWP;

            int nArmyTable = GetM2DAInt(TABLE_CLIMAX_ARMIES, "ArmyTable", nArmyID);
            string sArmySpawnWP = GetM2DAString(TABLE_CLIMAX_ARMIES, "ArmySpawnWP", nArmyID);
            int nArmyBufferMax = GetM2DAInt(TABLE_CLIMAX_ARMIES, "ArmyBufferMax", nArmyID);
            string sArmyBufferVar = GetM2DAString(TABLE_CLIMAX_ARMIES, "ArmyBufferVar", nArmyID);
            int nArmyTotalMax = GetM2DAInt(TABLE_CLIMAX_ARMIES, "ArmyTotalMax", nArmyID);
            string sArmyTotalVar = GetM2DAString(TABLE_CLIMAX_ARMIES, "ArmyTotalVar", nArmyID);
            int nCurrentBuffer = GetLocalInt(oArea, sArmyBufferVar);
            int nCurrentDSCount = GetLocalInt(oArea, sArmyTotalVar);

             // Decrease buffer size

            nCurrentBuffer--;
            SetLocalInt(oArea, sArmyBufferVar, nCurrentBuffer);
            Log_Trace(LOG_CHANNEL_PLOT, "DS ARMY SOLDIER DEATH EVENT", "Army ID: " + IntToString(nArmyID) +
                                                                    ", Spawn WP: " + sArmySpawnWP +
                                                                    ", Buffer Max: " + IntToString(nArmyBufferMax) +
                                                                    ", Buffer Cur: " + IntToString(nCurrentBuffer) +
                                                                    ", Total Max: " + IntToString(nArmyTotalMax) +
                                                                    ", Total Cur: " + IntToString(nCurrentDSCount));




            // spawn new one if did not pass max ds number allowed

            if(nCurrentDSCount < nArmyTotalMax)
            {
                nCurrentDSCount++;
                SetLocalInt(oArea, sArmyTotalVar, nCurrentDSCount);
                nCurrentBuffer++;
                SetLocalInt(oArea, sArmyBufferVar, nCurrentBuffer);

                event evSpawnDS = Event(EVENT_TYPE_CUSTOM_EVENT_04);
                evSpawnDS = SetEventInteger(evSpawnDS, 0, nSoldierID);
                evSpawnDS = SetEventInteger(evSpawnDS, 1, nArmyTable);
                evSpawnDS = SetEventInteger(evSpawnDS, 2, nArmyID);
                evSpawnDS = SetEventString(evSpawnDS, 0, sArmySpawnWP);

                float fDelay = RandFF(CLI_ARMY_SPAWN_DELAY_MAX - CLI_ARMY_SPAWN_DELAY_MIN, CLI_ARMY_SPAWN_DELAY_MIN);
                DelayEvent(fDelay, oArea, evSpawnDS);
            }
            else
                Log_Trace(LOG_CHANNEL_PLOT, "DS ARMY SOLDIER DEATH EVENT", "ALL DARKSPAWN CREATED - not spawning any more");

            // update death count:
            string sDeathCountVar = GetM2DAString(TABLE_CLIMAX_ARMIES, "ArmyDeathCountVar", nArmyID);
            if(sDeathCountVar != "")
            {
                int nDeathCount = GetLocalInt(oArea, sDeathCountVar);
                nDeathCount++;
                SetLocalInt(oArea, sDeathCountVar, nDeathCount);
                Log_Trace(LOG_CHANNEL_PLOT, "DS ARMY SOLDIER DEATH EVENT", "Death count: " + IntToString(nDeathCount));
                if(nDeathCount == nArmyTotalMax)
                {
                    Log_Trace(LOG_CHANNEL_PLOT, "DS ARMY SOLDIER DEATH EVENT", "All DS army soldiers died. Firing event to area");
                    event evArmyDead = Event(EVENT_TYPE_CUSTOM_EVENT_05);
                    evArmyDead = SetEventInteger(evArmyDead, 0, nArmyID);
                    SignalEvent(oArea, evArmyDead);
                }
            }


            break;
        }
        case EVENT_TYPE_HANDLE_CUSTOM_AI:
        {
            // AI flag set active so the CUSTOM_COMMAND_COMPLETE will be sent
            object oLastTarget = GetEventObject(ev, 0);
            int nLastCommand = GetEventInteger(ev, 1);
            int nLastCommandStatus = GetEventInteger(ev, 2);
            int nLastSubCommand = GetEventInteger(ev, 3);
            int nAITargetType = GetEventInteger(ev, 4);
            int nAIParameter = GetEventInteger(ev, 5);
            int nTacticID = GetEventInteger(ev, 6);

            AI_DetermineCombatRound(oLastTarget, nLastCommand, nLastCommandStatus, nLastSubCommand);
            break;
        }
        case EVENT_TYPE_CUSTOM_COMMAND_COMPLETE:
        {
            // simple run to the center
            Log_Trace(LOG_CHANNEL_PLOT, "DS ARMY SOLDIER CUSTOM_COMMAND_COMPLETE", "START");
            int nLastCommandType = GetEventInteger(ev, 0);
            int nCommandStatus = GetEventInteger(ev, 1);
            if(nCommandStatus == COMMAND_SUCCESSFUL)
            {
                object oCenter = UT_GetNearestObjectByTag(OBJECT_SELF, "cli400wp_center");
                if(IsObjectValid(oCenter))
                {
                    command cMove = CommandMoveToObject(oCenter, TRUE);
                    WR_AddCommand(OBJECT_SELF, cMove);
                    Log_Trace(LOG_CHANNEL_PLOT, "DS ARMY SOLDIER CUSTOM_COMMAND_COMPLETE", "Moving to center");
                }

            }
            else
            {
                command cWait = CommandWait(2.0);
                WR_AddCommand(OBJECT_SELF, cWait);
            }
            break;
        }
        /*case EVENT_TYPE_COMMAND_COMPLETE:
        {
            int nLastCommandType = GetEventInteger(ev, 0);
            int nCommandStatus   = GetEventInteger(ev, 1);
            int nLastSubCommand  = GetEventInteger(ev, 2);
            object oLastTarget   = OBJECT_INVALID;
            object oBlockingObject = GetEventObject(ev, 2);

            int nQSize = GetCommandQueueSize(OBJECT_SELF);
            if(nQSize == 0)
            {
                int nArmyID = GetLocalInt(OBJECT_SELF, CREATURE_COUNTER_2);
                if(nArmyID <= 0)
                    nArmyID = GetTeamId(OBJECT_SELF);
                string sArmySpawnWP = GetM2DAString(TABLE_CLIMAX_ARMIES, "ArmySpawnWP", nArmyID);
                object oWP = UT_GetNearestObjectByTag(OBJECT_SELF, sArmySpawnWP);
                float fDistance = GetDistanceBetween(OBJECT_SELF, oWP);
                // if too far from a move-to wp then try to move again. If last command failed then wait.
                if(nCommandStatus < 0) // command failed
                {
                    Log_Trace(LOG_CHANNEL_PLOT, "DS ARMY SOLDIER COMMAND_COMPLETE EVENT", "last command failed - waiting");
                    command cWait = CommandWait(2.0);
                    WR_AddCommand(OBJECT_SELF, cWait);
                }
                else if(fDistance < 3.0)// command not failed and too far from move-to wp -> try to move there again
                {
                    Log_Trace(LOG_CHANNEL_PLOT, "DS ARMY SOLDIER COMMAND_COMPLETE EVENT", "too far from move-to wp - moving closer");
                    command cMove = CommandMoveToObject(oWP, TRUE);
                    WR_AddCommand(OBJECT_SELF, cMove);
               }
            }
            break;
        }*/
    }
    if (!nEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_CREATURE_CORE);
    }
}