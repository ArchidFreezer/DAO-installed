#include "sys_autoscale_h"
#include "sys_rewards_h"
#include "approval_h"
#include "sys_autolevelup_h"

void main() {
    event ev = GetCurrentEvent();
    int nScaled = GetLocalInt(OBJECT_SELF, FOLLOWER_SCALED);
    int nShowPartyPicker = GetEventInteger(ev, 0);
    int nMinLevel = GetEventInteger(ev, 1);
    int bPreventLevelup = GetEventInteger(ev, 2);
    int bSummoned = IsSummoned(OBJECT_SELF);

    if(!nScaled && !bSummoned && !IsHero(OBJECT_SELF))
    {
        SetLocalInt(OBJECT_SELF, FOLLOWER_SCALED, 1);
        int nPackage = GetPackage(OBJECT_SELF);
        int nPackageClass = GetM2DAInt(TABLE_PACKAGES, "StartingClass", nPackage);

        // set behavior
        int nBehavior = GetM2DAInt(TABLE_PACKAGES, "FollowerBehavior", nPackage);
        if(nBehavior >= 0)
            SetAIBehavior(OBJECT_SELF, nBehavior);

        // -------------------------------------------------------------
        // <scaling>
        //
        // NOTE: creature was scaled already in creature_core - in here
        // we clear him completely and reconstruct from scratch
        // -------------------------------------------------------------
        Chargen_InitializeCharacter(OBJECT_SELF);

        // -------------------------------------------------------------
        // Apply race and class modifiers.
        // -------------------------------------------------------------
        Chargen_SelectRace(OBJECT_SELF,GetCreatureRacialType(OBJECT_SELF));
        Chargen_SelectCoreClass(OBJECT_SELF,GetCreatureCoreClass(OBJECT_SELF));

        // -------------------------------------------------------------
        // yaron: Scale followers to level.
        // -------------------------------------------------------------
        int nTargetLevel;
        int nPlayerLevel = GetLevel(GetHero());
        if(nPlayerLevel >= 13 || nPlayerLevel == 1 || !_UT_GetIsPlotFollower(OBJECT_SELF))
            nTargetLevel = nPlayerLevel;
        else
            nTargetLevel = nPlayerLevel + 1;
        int nMinLevel = GetM2DAInt(TABLE_PACKAGES, "MinLevel", nPackage);
        if(nMinLevel > 0 && nMinLevel > nTargetLevel)
            nTargetLevel = nMinLevel;
        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_EVENTS, "player_core.EVENT_TYPE_PARTY_MEMBER_HIRED",
                "Target level: " + IntToString(nTargetLevel));
        #endif

        int nScaleTargetLevel = Min(nTargetLevel, 7);
        int nXp = RW_GetXPNeededForLevel(Max(nScaleTargetLevel, 1));

        if(nPackageClass != CLASS_MONSTER_ANIMAL)
        {
            // -------------------------------------------------------------
            // Follower leveled one level higher than the player unless the player
            // is too high level.
            // -------------------------------------------------------------

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, "player_core.EVENT_TYPE_PARTY_MEMBER_HIRED",
                    "Giving XP: " + IntToString(nXp));
            #endif

            int nState = GetFollowerState(OBJECT_SELF);
            string sFollowerState = _GetFollowerStateName(nState);

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, "player_core.EVENT_TYPE_PARTY_MEMBER_HIRED",
                    "Follower state: " + sFollowerState);
            #endif
            RewardXP(OBJECT_SELF, nXp, FALSE, FALSE);
        }

        // -------------------------------------------------------------
        // add hidden approval talents
        // -------------------------------------------------------------
        int nIndex = Approval_GetFollowerIndex(OBJECT_SELF);
        Approval_AddFollowerBonusAbility(nIndex, 0);

        // Find specialization
        int nSpecAbility = GetM2DAInt(TABLE_PACKAGES, "switch1_class", nPackage); // followers can have only 1 advanced class
        if(nSpecAbility > 0)
        {
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, "player_core.EVENT_TYPE_PARTY_MEMBER_HIRED",
                "Adding spec ability: " + IntToString(nSpecAbility));
            #endif
            AddAbility(OBJECT_SELF, nSpecAbility);
        }

        // -------------------------------------------------------------
        // This spends all available attribute and stat points on the
        // creature according to the levelup table.
        // -------------------------------------------------------------

        AL_DoAutoLevelUp(OBJECT_SELF, TRUE);

        if(nPackageClass != CLASS_MONSTER_ANIMAL && nTargetLevel > nScaleTargetLevel)
        {
            int newXp = RW_GetXPNeededForLevel(Max(nTargetLevel, 1));
            if (newXp > nXp)
                RewardXP(OBJECT_SELF, newXp - nXp, FALSE, FALSE);
        }

        if(bPreventLevelup)
        {
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, "player_core.EVENT_TYPE_PARTY_MEMBER_HIRED",
                "Preventing creature from levelling up");
            #endif
            SetLocalInt(OBJECT_SELF, CREATURE_REWARD_FLAGS, 1);
        }

        // load tactics
        int nTableID = GetM2DAInt(TABLE_PACKAGES, "FollowerTacticsTable", nPackage);
        if (nTableID != -1)
        {
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, "player_core.EVENT_TYPE_PARTY_MEMBER_HIRED",
                "Loading follower tactics from table: " + IntToString(nTableID));
            #endif
            int nRows = GetM2DARows(nTableID);
            int nMaxTactics = GetNumTactics(OBJECT_SELF);
            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, "player_core.EVENT_TYPE_PARTY_MEMBER_HIRED",
                "Loading follower tactics from table: " + IntToString(nTableID) + ", row: " + IntToString(nRows));
            #endif

            int nTacticsEntry = 1;
            int i;
            for (i = 1; i <= nRows && nTacticsEntry <= nMaxTactics; ++i)
            {
                int bAddEntry = FALSE;
                int nTargetType = GetM2DAInt(nTableID, "TargetType", i);
                int nCondition = GetM2DAInt(nTableID, "Condition", i);
                int nCommandType = GetM2DAInt(nTableID, "Command", i);
                int nCommandParam = GetM2DAInt(nTableID, "SubCommand", i);

                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_EVENTS, "player_core.EVENT_TYPE_PARTY_MEMBER_HIRED",
                    "adding tactics: " + IntToString(i));
                #endif
                int nUseType = GetM2DAInt(TABLE_COMMAND_TYPES, "UseType", nCommandType);
                if (nUseType == 0)
                {
                    bAddEntry = TRUE;
                }
                else
                {
                    bAddEntry = HasAbility(OBJECT_SELF, nCommandParam);
                }

                if (bAddEntry)
                {
                    SetTacticEntry(OBJECT_SELF, nTacticsEntry, TRUE, nTargetType, nCondition, nCommandType, nCommandParam);
                    ++nTacticsEntry;
                }
            }
        }

        // @author yaron
        // DEBUG - scale items
        #ifdef DEBUG
        if(GetLocalInt(GetModule(), DEBUG_ENABLE_PARTY_ITEM_SCALING) == 1)
        {

            Log_Trace(LOG_CHANNEL_EVENTS, "player_core.EVENT_TYPE_PARTY_MEMBER_HIRED",
                "DEBUG - scaling items - THIS CODE SHOULD NOT RUN NORMALLY");
            DEBUG_ScaleFolloweItems(OBJECT_SELF);
        }
        #endif
        //if this is Alistair - show the tutorial
        if (GetTag(OBJECT_SELF) == "gen00fl_alistair")
        {
            BeginTrainingMode(TRAINING_SESSION_FOLLOWERS_AND_TACTICS);
        }
    }

}