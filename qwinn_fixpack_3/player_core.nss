#include "ability_h"
#include "effects_h"
#include "events_h"
#include "config_h"
#include "ai_main_h_2"
#include "global_objects_h"
#include "sys_injury"
#include "sys_autoscale_h"
#include "sys_itemsets_h"
#include "sys_traps_h"
#include "approval_h"
#include "sys_autolevelup_h"
#include "sys_rewards_h"
#include "tutorials_h"

#include "plt_tut_combat_salve"
#include "plt_tut_fatigue"
#include "plt_tut_armor_archer"
#include "plt_tut_first_gift"

#include "stats_core_h"

const int APPROVAL_DEATH_PENALTY = -3;

void   _ScheduleResurrectionAttempt(object oCreature)
{
    DelayEvent(6.0f, oCreature, Event(EVENT_TYPE_PARTY_MEMBER_RES_TIMER));
}



// -----------------------------------------------------------------------------
// @brief: Post resurrection event. Trigger soundset on player, add injury and
// approval penalties
// @author: Georg
// -----------------------------------------------------------------------------
int HandleEvent_Resurrection(object oCreature, event ev)
{
    int bApplyInjury = GetEventInteger(ev,0);
    if (bApplyInjury)
    {
        PlaySoundSet(oCreature, SS_EXPLORE_HEAL_ME);
        Injury_DetermineInjury(oCreature);
    }

    // redo itemset bonuses
    ItemSet_Update(oCreature);

    // CUT!
    //int nFollower = Approval_GetFollowerIndex(OBJECT_SELF);
    //if(nFollower != -1)
    //    Approval_ChangeApproval(nFollower, APPROVAL_DEATH_PENALTY);

    return TRUE;

}

// -----------------------------------------------------------------------------
// Spawn Event Handler
//
// Purpose:
// -- Set Stats
// -- Add Abilities
//
// -----------------------------------------------------------------------------
int HandleEvent_Spawn(event ev);
int HandleEvent_Spawn(event ev)
{

    if (!IsHero(OBJECT_SELF))
    {
        AS_InitCreature(OBJECT_SELF);
    }
    else
    {
        // ---------------------------------------------------------------------
        // Hero character gets his heartbeat event initialized here.
        // Followers get theirs when they are hired.
        // ---------------------------------------------------------------------
        InitHeartbeat(OBJECT_SELF, CONFIG_CONSTANT_HEARTBEAT_RATE);
    }

    return TRUE;

}

// -----------------------------------------------------------------------------
// Perception Disappear Event Handler
// Parameters:
// -- Obj(0): Creature appearing
//
// Purpose:
// -- Ends Delayed shout loop
// -- Sets combat mode to false if no hostiles are around anymore
// -----------------------------------------------------------------------------
int HandleEvent_PerceptionDisappear(event ev);
int HandleEvent_PerceptionDisappear(event ev)
{

    object oDisappearer = GetEventObject(ev, 0); //GetEventCreator(ev);

    // -----------------------------------------------------------------
    // If we unperceive a hostile object, and it's the last perceived
    // hostile, drop out of combat.
    // -----------------------------------------------------------------
    if (IsObjectHostile(oDisappearer,OBJECT_SELF))
    {
        Combat_HandleCreatureDisappear(OBJECT_SELF, oDisappearer);
    }
    else if(!IsObjectValid(oDisappearer)) // For cases where creatures are destroyed when dead (spirit, explodes)
    {
        if (!IsPartyPerceivingHostiles(OBJECT_SELF))
        {

            if (!IsPartyDead())
            {
                #ifdef DEBUG
                Log_Trace(LOG_CHANNEL_COMBAT, "HandleEvent_PerceptionDisappear", "STOPPING COMBAT FOR PARTY!");
                #endif
               /* ResurrectPartyMembers();

                // ------------------------------------------------------------------
                // ... we switch the game back to explore mode.
                // Note: This switches CombatState on all party members as party of
                //       the GameModeChange Module Level Event
                // ------------------------------------------------------------------
                WR_SetGameMode(GM_EXPLORE);*/
                DelayEvent(1.0f, GetModule(), Event(EVENT_TYPE_DELAYED_GM_CHANGE));
            }
        }
    }

    // -------------------------------------------------------------
    // Event was fully handled, do not fall through to rules_core
    // -------------------------------------------------------------
    return TRUE;
}

// -----------------------------------------------------------------------------
// Item Equip Event Handler
// -- sets 'prefer ranged' flag is equipping a ranged weapon in the main hand
//
//  Params:
//      int (0) - the inventory slot the item was equipped to
//      obj (0) - the item
// -----------------------------------------------------------------------------
int HandleEvent_Equip(event ev);
int HandleEvent_Equip(event ev)
{
    object oItem = GetEventObject(ev, 0);
    int nEquipByPlayer = GetEventInteger(ev, 1);

    #ifdef DEBUG
    Log_Trace(LOG_CHANNEL_TEMP,"player_core","itm:" + ToString(oItem) +" abi:" + ToString(GetItemAbilityId(oItem)));
    #endif

    #ifdef SKYNET
    TrackItemEvent(GetEventType(ev),OBJECT_SELF,oItem);
    #endif

    // Handle Item Set Tracking here
    ItemSet_Update(OBJECT_SELF);

    if(nEquipByPlayer)
    {
        if(GetBaseItemType(oItem) == BASE_ITEM_TYPE_ARMOR_HEAVY ||
            GetBaseItemType(oItem) == BASE_ITEM_TYPE_ARMOR_LIGHT ||
            GetBaseItemType(oItem) == BASE_ITEM_TYPE_ARMOR_MASSIVE ||
            GetBaseItemType(oItem) == BASE_ITEM_TYPE_ARMOR_MEDIUM)
                WR_SetPlotFlag(PLT_TUT_FATIGUE, TUT_FATIGUE_1, TRUE);
        if(GetBaseItemType(oItem) == BASE_ITEM_TYPE_ARMOR_HEAVY ||
                GetBaseItemType(oItem) == BASE_ITEM_TYPE_ARMOR_MASSIVE)
                WR_SetPlotFlag(PLT_TUT_ARMOR_ARCHER, TUT_ARMOR_ARCHER_1, TRUE);
    }



     // ------------------------------------------------------------------------
     // Temporary item enchantment code
     // ------------------------------------------------------------------------
     int nSlot = GetEventInteger(ev,0);
     if (nSlot == INVENTORY_SLOT_MAIN || (nSlot == INVENTORY_SLOT_OFFHAND && GetItemType(oItem) == ITEM_TYPE_WEAPON_MELEE) )
     {
         if (HasEnchantments(OBJECT_SELF))
         {
             EffectEnchantment_HandleEquip(oItem, OBJECT_SELF);
         }
     }


     return FALSE; // FALSE IS IMPORTANT HERE! DO NOT CHANGE!
}


// -----------------------------------------------------------------------------
// Item UnEquip Event Handler
//
//  Params:
//      int (0) - the inventory slot the item was removed from
//      obj (0) - the item
// -----------------------------------------------------------------------------
int HandleEvent_UnEquip(event ev);
int HandleEvent_UnEquip(event ev)
{
    object oItem = GetEventObject(ev, 0);

    #ifdef SKYNET
    TrackItemEvent(GetEventType(ev),OBJECT_SELF,oItem);
    #endif

    // Handle Item Set Tracking here
    ItemSet_Update(OBJECT_SELF);


     // ------------------------------------------------------------------------
     // Temporary item enchantment code
     // ------------------------------------------------------------------------
     int nSlot = GetEventInteger(ev,0);
     if (nSlot == INVENTORY_SLOT_MAIN || (nSlot == INVENTORY_SLOT_OFFHAND && GetItemType(oItem) == ITEM_TYPE_WEAPON_MELEE) )
     {
        if (HasEnchantments(OBJECT_SELF))
         {
             EffectEnchantment_HandleUnEquip(oItem, OBJECT_SELF);
         }
     }

    // -------------------------------------------------------------------------
    // Disable modal abilities that have their condition changed.
    // #define ABILITY_CONDITION_NONE          0x0
    // #define ABILITY_CONDITION_MELEEWEAPON   0x1
    // #define ABILITY_CONDITION_SHIELD        0x2
    // #define ABILITY_CONDITION_RANGEDWEAPON  0x4
    // #define ABILITY_CONDITION_BEHINDTARGET  0x8
    // #define ABILITY_CONDITION_DUALWEAPONS 0x040
    // #define ABILITY_CONDITION_2HWEAPON 0x080

    // -------------------------------------------------------------------------
    int[] abi = GetConditionedAbilities(OBJECT_SELF, 0xC7);
    int nSize = GetArraySize(abi);
    int i;
    for (i = 0; i < nSize; i++)
    {
        Effects_RemoveUpkeepEffect(OBJECT_SELF,abi[i]);
    }


     if (nSlot == INVENTORY_SLOT_CHEST)
     {
         #ifdef DEBUG
         Log_Trace(LOG_CHANNEL_COMBAT_GORE,"player_core:HandleEquip", "All gore removed due to changing armor");
         #endif

        Gore_RemoveAllGore(OBJECT_SELF);
     }




     return FALSE; // FALSE IS IMPORTANT HERE! DO NOT CHANGE!
}

// -----------------------------------------------------------------------------
// Inventory Event Handler
// -- Does nothing right now
// -----------------------------------------------------------------------------

int HandleEvent_InventoryEvent(event ev);
int HandleEvent_InventoryEvent(event ev)
{
    int nEventType = GetEventType(ev);
    object oOwner = GetEventCreator(ev);
    object oItem = GetEventObject(ev, 0);

    // -------------------------------------------------------------------------
    // Georg: Stores process their inventory events immediately, even while the
    //        gamestate is paused. We need to pass this information on to
    //        any sub events generated by the equip script or they'll get
    //        queued up until after the UI quits, causing all kind of havok
    // -------------------------------------------------------------------------
    int bProcessImmediate = GetEventInteger(ev,0);


    switch(nEventType)
    {
        case EVENT_TYPE_INVENTORY_ADDED:
        {


            //If the item acquired has the ITEM_SEND_ACQUIRED_EVENT variable set,
            //send an event to the module so that custom scripting can be done.
            int bSendCampaignEvent = GetLocalInt(oItem, ITEM_SEND_ACQUIRED_EVENT);
            if ( bSendCampaignEvent != 0 )
            {
                SendEventCampaignItemAcquired(GetModule(), oItem, bProcessImmediate);
            }

            if(GetBaseItemType(oItem) == BASE_ITEM_TYPE_QUICK)
            {
                int nItemAbility = GetItemAbilityId(oItem);
                if(nItemAbility == ITEM_ABILITY_HEALING_SALVE ||
                   nItemAbility == ITEM_ABILITY_HEALING_SALVE_1 ||
                   nItemAbility == ITEM_ABILITY_HEALING_SALVE_2 ||
                   nItemAbility == ITEM_ABILITY_HEALING_SALVE_3 ||
                   nItemAbility == ITEM_ABILITY_HEALING_SALVE_4)
                    WR_SetPlotFlag(PLT_TUT_COMBAT_SALVE, TUT_COMBAT_SALVE_1, TRUE);
            }
            else if(GetBaseItemType(oItem) == BASE_ITEM_TYPE_GIFT)
                WR_SetPlotFlag(PLT_TUT_FIRST_GIFT, TUT_FIRST_GIFT_1, TRUE);

            break;
        }
        case EVENT_TYPE_INVENTORY_REMOVED:
        {

            // If the item removed has ITEM_SEND_LOST_EVENT set send the event.
            int bSendCampaignEvent = GetLocalInt( oItem, ITEM_SEND_LOST_EVENT );

            if ( bSendCampaignEvent )
                SendEventCampaignItemLost( GetModule(), oItem, bProcessImmediate );

            break;

        }
    }
    return TRUE;
}


// -----------------------------------------------------------------------------
// Death Event andler.
// Purpose:
// -- Clears AI target.
// -- Prints log message.
// -----------------------------------------------------------------------------
int HandleEvent_Death(event ev);
int HandleEvent_Death(event ev)
{
    // -------------------------------------------------------------------------
    // The death effect has been applied to this creature, either by losing hit points
    // or by explicit calling of the effect.
    // -------------------------------------------------------------------------
    object oKiller = GetEventCreator(ev);
    int    bPartyWipe = IsPartyDead();

    SetCreatureFlag(OBJECT_SELF,CREATURE_RULES_FLAG_DYING,FALSE);

    // -------------------------------------------------------------------------
    // SkyNet creature death tracking event.
    // -------------------------------------------------------------------------
    #ifdef SKYNET
    TrackObjectDeath(ev);
    #endif

    // -------------------------------------------------------------------------
    // Clear the object's perception list
    // -------------------------------------------------------------------------
    ClearPerceptionList(OBJECT_SELF);

    AI_Threat_UpdateDeath(OBJECT_SELF);

    // -------------------------------------------------------------------------
    // If the party was wiped, set gamemode dead.
    // -------------------------------------------------------------------------
    if (bPartyWipe)
    {

        int iDeathHint = GetLocalInt(GetModule(), DEATH_HINT);

        //If module variable "DEATH_HINT" is not zero, use it.
        if(iDeathHint != 0)
        {
            SetDeathHint(iDeathHint, 205);
        }
        else
        {
            //If DEATH_HINT is zero, use loop to determine statistics on party.
            object[] oParty = GetPartyList(GetHero());
            int nSize = GetArraySize(oParty);
            int i;
            int iLevelCounter;
//          int iTacticCounter;
//          int iStaminaCounter;
            object oCurrent;
            for(i = 0; i < nSize; i++)
            {
                oCurrent = oParty[i];
                if(GetCanLevelUp(oCurrent) == TRUE)
                {iLevelCounter += 1;}
            }
            //Fire if party member needs to level up.
            if(iLevelCounter > 0)
            {
                  SetDeathHint(2, 205);
            }else
            {
            //Random Death hint
                int iRows = GetM2DARows(272);
                int nRand = Random(iRows) + 1;
                nRand = GetM2DARowIdFromRowIndex(272, nRand);
                SetDeathHint(nRand, 272);
            }
            SetLocalInt(GetModule(), DEATH_HINT, 0);
        }

        #ifdef DEBUG
        Log_Trace(LOG_CHANNEL_COMBAT_DEATH, "player_core.HandleOnDeath","Everyone dead, changing game mode...");
        #endif
        WR_SetGameMode(GM_DEAD);
    }
    else
    {
        // ---------------------------------------------------------------------
        // handle any plot-specific logic for a follower death
        // currently needed only for Wynne's special ability
        // ---------------------------------------------------------------------
        SendModuleHandleFollowerDeath(OBJECT_SELF);

        SetCombatState(OBJECT_SELF,FALSE);

        // ---------------------------------------------------------------------
        // If we are in explore mode, schedule auto resurrection
        // ---------------------------------------------------------------------
        if (GetGameMode() == GM_EXPLORE)
        {
            //------------------------------------------------------------------
            // Sorry, summoned creatures can't be revived.
            //------------------------------------------------------------------
            if (!IsSummoned(OBJECT_SELF))
            {
                _ScheduleResurrectionAttempt(OBJECT_SELF);
            }
        }

        // ---------------------------------------------------------------------
        // This handles the 'party member slain' message;
        // ---------------------------------------------------------------------
        object[] aAlly = GetNearestObjectByGroup(OBJECT_SELF, GetGroupId(OBJECT_SELF), OBJECT_TYPE_CREATURE,1, 1, 0, 0);
        if (GetArraySize(aAlly)>0)
        {
            SSPlaySituationalSound(aAlly[0],SOUND_SITUATION_PARTY_MEMBER_SLAIN, oKiller);
        }

    }

    return TRUE;
}


// -----------------------------------------------------------------------------
// Load tactics event handler
// -- Currently this just uses a naive method to populate tactics with valid
// -- skills.
// -----------------------------------------------------------------------------
int HandleEvent_LoadTactics(object oCreature, event ev);
int HandleEvent_LoadTactics(object oCreature, event ev)
{
    int nPresetID = GetEventInteger(ev, 0);
    Chargen_LoadPresetsTable(oCreature, nPresetID);

    return TRUE;
}

// -----------------------------------------------------------------------------
// Use ability immediately.
// -- Some player abilities are used immediately, bypassing the ai command queue
// -- in order to process them while the game is paused.
// -- Currently this is only used for the crafting GUI.
// -----------------------------------------------------------------------------
int HandleEvent_UseAbilityImmediate(object oCreature, event ev);
int HandleEvent_UseAbilityImmediate(object oCreature, event ev)
{

    int nAbility = GetEventInteger(ev, 0);
    ShowCraftingGUI(nAbility);

    return TRUE;
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    // Setting this to true will prevent the script from invoking rules_core
    int bEventHandled = FALSE;

    // Prevent log spam
    #ifdef DEBUG
    if (nEventType != EVENT_TYPE_HEARTBEAT2)
        Log_Events("", ev);
    #endif

    switch(nEventType)
    {
        // ---------------------------------------------------------------------
        // Fired by engine when creature is spawned.
        // ---------------------------------------------------------------------
        case EVENT_TYPE_SPAWN:
        {
            // Only do this once...
            if(!GetLocalInt(OBJECT_SELF, CREATURE_SPAWNED))
            {
                SetLocalInt(OBJECT_SELF, CREATURE_SPAWNED, 1);
                bEventHandled = HandleEvent_Spawn(ev);
            }
            break;
        }

        // ---------------------------------------------------------------------
        // Handle Inventory Added / Removed Events
        //  Params:
        //      int (0) - the inventory slot the item added or removed from
        //      obj (0) - the item
        // ---------------------------------------------------------------------
        case EVENT_TYPE_INVENTORY_REMOVED:
        case EVENT_TYPE_INVENTORY_ADDED:
        {
            bEventHandled = HandleEvent_InventoryEvent(ev);
            break;
        }

        // ---------------------------------------------------------------------
        // Handle Perception Disappear Events
        // ---------------------------------------------------------------------
        case EVENT_TYPE_PERCEPTION_DISAPPEAR:
        {
            bEventHandled = HandleEvent_PerceptionDisappear(ev);
            break;
        }

        // -----------------------------------------------------------------
        // Damage over time tick event.
        // This is activated from EffectDOT and keeps rescheduling itself
        // while DOTs are in effect on the creature
        // -----------------------------------------------------------------
        case EVENT_TYPE_DOT_TICK:
        {
            if (!IsDead() && !IsDying())
            {
              Effects_HandleCreatureDotTickEvent();
            }

            bEventHandled = TRUE;
            break;
        }

        // ---------------------------------------------------------------------
        // @brief Heartbeat event generated by engine in response to InitHeartbeat()
        // ---------------------------------------------------------------------
        case EVENT_TYPE_HEARTBEAT2:
        {
             // No heartbeat for dead people
             if (IsDeadOrDying(OBJECT_SELF))
               return;

            // gradual mana/stamina regen in combat
            if(GetGameMode() == GM_COMBAT)
            {
                float fCurrentManaStamina = GetCurrentManaStamina(OBJECT_SELF);
                float fCurrentStaminaRegen = GetCreatureProperty(OBJECT_SELF, PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, PROPERTY_VALUE_BASE);
                float fNewStaminaRegen = fCurrentStaminaRegen;
                if(fCurrentManaStamina <= 25.0) // fastest regen
                    fNewStaminaRegen = REGENERATION_STAMINA_COMBAT_DEFAULT + 3.5;
                else if(fCurrentManaStamina <= 50.0) // mid regen
                    fNewStaminaRegen = REGENERATION_STAMINA_COMBAT_DEFAULT + 1.0;

                else // more than 50 -> slowest regen
                    fNewStaminaRegen = REGENERATION_STAMINA_COMBAT_DEFAULT + 0.5;

                SetCreatureProperty(OBJECT_SELF, PROPERTY_ATTRIBUTE_REGENERATION_STAMINA_COMBAT, fNewStaminaRegen);
            }

            // Check for traps
            Trap_RunDetectionPulse(OBJECT_SELF);


            // Track movements for stats
          //  if (IsHero(OBJECT_SELF)) STATS_TrackWalkedDistance();


             // ----------------------------------------------------------------
             // Generate SkyNet Position Tracking Event
             // http://georg/SkyNetWeb - Talk to georg if you have questions
             // Note: For development telemetry only - will not work in SHIP exectuables.
             // ----------------------------------------------------------------
             #ifdef SKYNET
             if (IsHero(OBJECT_SELF))
             {
                TrackPos();
             }
             #endif

             if (LOG_ENABLED)
             {
                if (IsImmortal(OBJECT_SELF))
                {
                    command cCommand = GetCurrentCommand(OBJECT_SELF);
                    if(GetCommandType(cCommand) != 38) // death blow command (engine turns follower immortal during death blows)
                    {
                     //   Warning ("Warning: " + ToString(OBJECT_SELF) + " seems to be immortal, which is probably a bug. Hero tag: " + GetTag(GetHero())+"Please file a bug through SkyNet to Yaron");
                        DEBUG_PrintToScreen("Warning: PC object " + ToString(OBJECT_SELF) + " is immortal!", 15 + Random(2), 2.0f);
                    }
                }
                DEBUG_PrintToScreen("Difficulty " + ToString(GetGameDifficulty()) + "", 11, 2.0f);
             }


             bEventHandled = TRUE;
             break;
        }

        // -----------------------------------------------------------------
        // Legacy Heartbeat event. Left for the consumption of modders.
        // Be careful with it, it's not nice to run on a lot of creatures...
        // -----------------------------------------------------------------
        case EVENT_TYPE_HEARTBEAT:
        {
             bEventHandled = TRUE;
             break;
        }

        case EVENT_TYPE_EQUIP:
        {
            bEventHandled = HandleEvent_Equip(ev);
            break;
        }

        case EVENT_TYPE_UNEQUIP:
        {
            bEventHandled = HandleEvent_UnEquip(ev);
            break;
        }

        // ---------------------------------------------------------------------
        // Fires first time a party member is added to the party
        // For plot followers: follower recruited (added to pool)
        // For other followers: UT_Hire called
        // Owner: Yaron
        // ---------------------------------------------------------------------
        case EVENT_TYPE_PARTY_MEMBER_HIRED:
        {
            int nScaled = GetLocalInt(OBJECT_SELF, FOLLOWER_SCALED);
            int nShowPartyPicker = GetEventInteger(ev, 0);
            int nMinLevel = GetEventInteger(ev, 1);
            int bPreventLevelup = GetEventInteger(ev, 2);

            #ifdef DEBUG
            Log_Trace(LOG_CHANNEL_EVENTS, "player_core.EVENT_TYPE_PARTY_MEMBER_HIRED",
                "show party picker: " + IntToString(nShowPartyPicker));
            #endif

            int bSummoned  =  IsSummoned(OBJECT_SELF);

            // -----------------------------------------------------------------
            // @author georg Initialize Follower Heartbeat.
            // Note: This is terminated in EVENT_TYPE_PARTY_MEMBER_FIRED.
            // -----------------------------------------------------------------
            if (!bSummoned)
            {
                // Heartbeat check moved to WR_SetFollowerState
                //InitHeartbeat(OBJECT_SELF, CONFIG_CONSTANT_HEARTBEAT_RATE);

                // checking tactics presets
                // It is fine to do this more than once
                Chargen_EnableTacticsPresets(OBJECT_SELF);
            }

            // -----------------------------------------------------------------
            // @author yaron
            // This can fire only once - when first hired
            // -----------------------------------------------------------------
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

                if(nPackageClass != CLASS_MONSTER_ANIMAL)
                {
                    // -------------------------------------------------------------
                    // Follower leveled one level higher than the player unless the player
                    // is too high level.
                    // -------------------------------------------------------------

                    int nXp = RW_GetXPNeededForLevel(Max(nTargetLevel, 1));

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

            if(nShowPartyPicker && GetLocalInt(GetArea(OBJECT_SELF), AREA_DEBUG) == FALSE)
            {
                SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);
                ShowPartyPickerGUI();
            }

            bEventHandled = TRUE;
            break;
        }


        // ---------------------------------------------------------------------
        // Fires an active or locked-active party member is removed from the
        // active party
        // ---------------------------------------------------------------------
        case EVENT_TYPE_PARTY_MEMBER_FIRED:
        {
            // NOTE: this event actually does not fire in many cases
            // follower-fired code in better put in WR_SetFollowerState

            break;
        }

        // ---------------------------------------------------------------------
        // Sent by engine when henchman or player is selected.
        // ---------------------------------------------------------------------
        case EVENT_TYPE_ON_SELECT:
        {
            SSPlaySituationalSound(OBJECT_SELF, SOUND_SITUATION_SELECTED);
            bEventHandled = TRUE;
            break;
        }

        // ---------------------------------------------------------------------
        // Sent by engine when henchman or player is given an order.
        // ---------------------------------------------------------------------
/*        case EVENT_TYPE_ON_ORDER_RECEIVED:
        {
            SSPlaySituationalSound(OBJECT_SELF, SOUND_SITUATION_ORDER_RECEIVED,GetEventTarget(ev));
            bEventHandled = TRUE;
            break;
        }*/
        case 94 : /*EVENT_TYPE_PLAYER_COMMAND_ADDED:*/
        {
            SSPlaySituationalSound(OBJECT_SELF, SOUND_SITUATION_ORDER_RECEIVED, GetEventTarget(ev), GetEventInteger(ev, 0));
            bEventHandled = TRUE;
            break;
        }




        // ---------------------------------------------------------------------
        // Sent by engine when creature is killed.
        // ---------------------------------------------------------------------
        case EVENT_TYPE_DEATH:
        {
            bEventHandled = HandleEvent_Death(ev);
            break;
        }

        // ---------------------------------------------------------------------
        // Resurrection timer used if a creature dies in explore mode.
        // ---------------------------------------------------------------------
        case EVENT_TYPE_PARTY_MEMBER_RES_TIMER:
        {
            if (GetGameMode() == GM_EXPLORE)
            {
                ResurrectCreature(OBJECT_SELF);
            }
            break;
        }

        // ---------------------------------------------------------------------
        // Creature is resurrected. Fired by effect_resurrection.OnApply
        // ---------------------------------------------------------------------
        case EVENT_TYPE_RESURRECTION:
        {
            bEventHandled = HandleEvent_Resurrection(OBJECT_SELF, ev);
            break;
        }

        // ---------------------------------------------------------------------
        // Creature is spawned. Fired by sys_rewards_h.RewardXP
        // ---------------------------------------------------------------------
        case EVENT_TYPE_PLAYER_LEVELUP:
        {
            #ifdef SKYNET
            TrackPartyMemberEvent(nEventType, OBJECT_SELF, OBJECT_INVALID, GetLevel(OBJECT_SELF));
            #endif

            UI_DisplayMessage(OBJECT_SELF, UI_MESSAGE_LEVELUP);
            break;
        }

        case EVENT_TYPE_LOAD_TACTICS_PRESET:
        {
            bEventHandled = HandleEvent_LoadTactics(OBJECT_SELF, ev);
            break;
        }

        //----------------------------------------------------------------------
        // Sent by engine when player clicks on object.
        //----------------------------------------------------------------------
        case EVENT_TYPE_PLACEABLE_ONCLICK:
        {
            // Pass event along to the placeable being clicked on.
            SignalEvent(GetEventTarget(ev), ev);
            bEventHandled = TRUE;
            break;
        }

        case EVENT_TYPE_USE_ABILITY_IMMEDIATE:
        {
            bEventHandled = HandleEvent_UseAbilityImmediate(OBJECT_SELF, ev);
            break;
        }

    }


    if (!bEventHandled)
    {
        HandleEvent(ev, RESOURCE_SCRIPT_RULES_CORE);
    }
}