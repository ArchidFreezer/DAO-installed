////////////////////////////////////////////////////////////////////////////////
//  placeable_h
//  Copyright © 2007 BioWare Corp.
////////////////////////////////////////////////////////////////////////////////
/*
    Default event handler functions for placeables objects.
*/
////////////////////////////////////////////////////////////////////////////////

#include "ui_h"
#include "sys_traps_h"
#include "design_tracking_h"
#include "sys_rewards_h"
#include "sys_treasure_h"

#include "plt_tut_inventory"
#include "plt_tut_placeable_locked"

#include "achievement_core_h"
#include "af_autoloot_h"
#include "af_camp_merch_chest_h"

const string STRING_VAR_NONE  = "none";

const string PLC_TAG_BIG_BALLISTA = "genip_ballista_big";

/**-----------------------------------------------------------------------------
* @brief Area transition based on placeable's local variables.
*-----------------------------------------------------------------------------*/
void Placeable_DoAreaTransition(object oPlc)
{
    string sDest_WP      = GetLocalString(oPlc, PLC_AT_DEST_TAG);
    string sDest_Area    = GetLocalString(oPlc, PLC_AT_DEST_AREA_TAG);
    string sWorldMapLoc1 = GetLocalString(oPlc, PLC_AT_WORLD_MAP_ACTIVE_1);
    string sWorldMapLoc2 = GetLocalString(oPlc, PLC_AT_WORLD_MAP_ACTIVE_2);
    string sWorldMapLoc3 = GetLocalString(oPlc, PLC_AT_WORLD_MAP_ACTIVE_3);
    string sWorldMapLoc4 = GetLocalString(oPlc, PLC_AT_WORLD_MAP_ACTIVE_4);
    string sWorldMapLoc5 = GetLocalString(oPlc, PLC_AT_WORLD_MAP_ACTIVE_5);
    UT_PCJumpOrAreaTransition(sDest_Area, sDest_WP, sWorldMapLoc1, sWorldMapLoc2, sWorldMapLoc3, sWorldMapLoc4, sWorldMapLoc5);
}


/**-----------------------------------------------------------------------------
* @brief Area transition confirmation popup.
*-----------------------------------------------------------------------------*/
void Placeable_PromptAreaTransition()
{
    if (GetObjectInteractive(OBJECT_SELF))
    {
        int nGM = GetGameMode();
        if (nGM != GM_COMBAT && nGM != GM_GUI)
        {
            ShowPopup(321167, 1, OBJECT_SELF);     // Result event is handled in module_core
        }
    }
}

/**-----------------------------------------------------------------------------
* @brief Handles the EVENT_TYPE_POPUP_RESULT event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandlePopupResult(event ev)
{
    object oOwner = GetEventObject(ev, 0);      // owner of popup
    int nPopupID  = GetEventInteger(ev, 0);     // popup ID (index into popup.xls)
    int nButton   = GetEventInteger(ev, 1);     // button result (1 - 4)

    switch (nPopupID)
    {
        case 1:     // Placeable area transition
        {
            if (nButton == 1)
                Placeable_DoAreaTransition(oOwner);
            break;
        }
        default:
            Log_Trace(LOG_CHANNEL_EVENTS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandlePopupResult()", "*** Unhandled popup ID: " + ToString(nPopupID));
    }
}


/**-----------------------------------------------------------------------------
* @brief Displays the codex entry (if any) associated with a placeable.
*-----------------------------------------------------------------------------*/
void Placeable_ShowCodexEntry(object oPlc)
{
    string sCodexPlot = GetLocalString(oPlc, PLC_CODEX_PLOT);
    int nCodexFlag    = GetLocalInt(oPlc, PLC_CODEX_FLAG);

    if (sCodexPlot != "" && nCodexFlag >= 0)
    {
        string sSummary = GetPlotSummary(sCodexPlot, nCodexFlag);

        Log_Trace( LOG_CHANNEL_EVENTS_PLACEABLES, GetCurrentScriptName()+ ".Placeable_ShowCodexEntry()", "Codex plot: " + sCodexPlot + ", Codex flag: " + IntToString(nCodexFlag));
        if (!WR_GetPlotFlag(sCodexPlot, nCodexFlag))
        {
            WR_SetPlotFlag(sCodexPlot, nCodexFlag, TRUE, TRUE);
            RewardXPParty(XP_CODEX, XP_TYPE_CODEX, OBJECT_INVALID, GetHero());
        }
        UI_DisplayCodexMessage(oPlc, sSummary);
        SetObjectInteractive(oPlc, FALSE);
    }
}


/**-----------------------------------------------------------------------------
* @brief Handles the EVENT_TYPE_SPAWN placeable event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleSpawned(event ev)
{
    // Database spawn tracking. High volume event so disabled by default.
    if (TRACKING_TRACK_SPAWN_EVENTS)
    {
        TrackPlaceableEvent(GetEventType(ev), OBJECT_SELF, OBJECT_INVALID, GetAppearanceType(OBJECT_SELF));
    }

    if(GetLocalInt(OBJECT_SELF, PLC_SPAWN_NON_INTERACTIVE) == 1)
    {
        Log_Trace(LOG_CHANNEL_EVENTS_PLACEABLES, GetCurrentScriptName() + "Spawning placeable non-interactive");
        SetObjectInteractive(OBJECT_SELF, FALSE);
    }

    //Codex placeables will spawn non-interactive if the player already has the entry.
    string sCodexPlot = GetLocalString(OBJECT_SELF, PLC_CODEX_PLOT);
    int nCodexFlag = GetLocalInt(OBJECT_SELF, PLC_CODEX_FLAG);

    if ((nCodexFlag >= 0) && (sCodexPlot != ""))
    {
        if (WR_GetPlotFlag(sCodexPlot, nCodexFlag) == TRUE)
        {
            SetObjectInteractive(OBJECT_SELF, FALSE);
        }
    }

    // Generate random treasure
    if (GetPlaceableBaseType(OBJECT_SELF) == PLACEABLE_TYPE_CHEST)
    {
        TreasureGenerate(OBJECT_SELF);
    }

    // Automatically arm trap if no owner.
    if (GetObjectActive(OBJECT_SELF)
        && Trap_GetType(OBJECT_SELF) > 0
        && !IsObjectValid(Trap_GetOwner(OBJECT_SELF)))
    {
        Trap_ArmTrap(OBJECT_SELF, OBJECT_INVALID, 0.0f);
    }

    // Set initial health
    if (GetMaxHealth(OBJECT_SELF) <= 1.1f)
    {
        int nHealth = GetM2DAInt(TABLE_PLACEABLE_TYPES, "Health", GetAppearanceType(OBJECT_SELF));
        if (nHealth > 1)
            SetMaxHealth(OBJECT_SELF, nHealth);
    }

    // Apply crust effect
    int nCrustEffect = GetM2DAInt(TABLE_PLACEABLE_TYPES, "CrustVFX", GetAppearanceType(OBJECT_SELF));
    if (nCrustEffect)
    {
        Log_Trace(LOG_CHANNEL_EVENTS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleSpawned()", " Applying CrustVFX: " + ToString(nCrustEffect));
        ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, nCrustEffect, EFFECT_DURATION_TYPE_PERMANENT, 0.0);
    }
}


/**-----------------------------------------------------------------------------
* @brief Handles the EVENT_TYPE_USE placeable event.
*
* This event handler uses GetPlaceableAction() to identify the specific action
* that triggered the event (i.e. placeable was used, opened, unlocked, etc.) and
* SetPlaceableActionResult() to trigger a state change based on the result of
* the action.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleUsed(event ev)
{
    object  oThis         = OBJECT_SELF;
    object  oUser         = GetEventCreator(ev);
    int     nAction       = GetPlaceableAction(OBJECT_SELF);
    int     nActionResult = TRUE;
    int     bVariation    = GetEventInteger(ev, 0); // if true, Success0A column chosen in 2DA
                                                    // (used to make door always open away from player)
    if (!GetObjectActive(OBJECT_SELF))
        return;

    Placeable_ShowCodexEntry(OBJECT_SELF);

    switch (nAction)
    {
        case PLACEABLE_ACTION_USE:
        {
            break;
        }

        case PLACEABLE_ACTION_OPEN:
        {
            Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleUsed()", "Variation: " + ToString(bVariation));

            // For doors, bVariation is 1/0 to indicate the player is using it from the front/back.
            // However, the Success0 column should be used by SetPlaceableActionResult() if the player
            // is using the door from the front and Success0A column if from the back. To facilitate
            // this logic, simply invert the value of bVariation.
            bVariation = !bVariation;

            // Prevent use of containers during combat.
            string sController = GetPlaceableStateCntTable(OBJECT_SELF);
            if (GetGameMode() == GM_COMBAT &&
                (sController == PLC_STATE_CNT_CONTAINER_STATIC ||
                sController == PLC_STATE_CNT_CONTAINER ||
                sController == PLC_STATE_CNT_BODYBAG))
            {
                UI_DisplayMessage(oUser, UI_MESSAGE_CANT_DO_IN_COMBAT);
                nActionResult = FALSE;
            }
            else
            {
                SendEventOpened(OBJECT_SELF, oUser);
            }
            break;
        }

        case PLACEABLE_ACTION_CLOSE:
        {
            break;
        }

        case PLACEABLE_ACTION_AREA_TRANSITION:
        {
            Placeable_DoAreaTransition(OBJECT_SELF);
            break;
        }

        case PLACEABLE_ACTION_DIALOG:
        {
            if (HasConversation(OBJECT_SELF) && !GetCombatState(oUser))
            {
                BeginConversation(oUser, OBJECT_SELF);
            }
            break;
        }

        case PLACEABLE_ACTION_EXAMINE:
        {
            if (!UI_DisplayPopupText(OBJECT_SELF, OBJECT_SELF))
            {
                if (HasConversation(OBJECT_SELF) && !GetCombatState(oUser))
                    BeginConversation(oUser, OBJECT_SELF);
            }
            break;
        }

        case PLACEABLE_ACTION_TRIGGER_TRAP:
        {
            break;
        }

        case PLACEABLE_ACTION_DISARM:
        {
            if (!HasAbility(oUser, ABILITY_TALENT_HIDDEN_ROGUE))
            {
                // Only rogues can disarm traps
                nActionResult = FALSE;
            }

            // Trap detection difficulty property is used instead of trap disarm property
            // because as a rule any trap you can detect you should be able to disarm.
            // It's easier to enforce this in screipt than check every trap placed in
            // every level of the game.
            int nTargetScore = GetTrapDisarmDifficulty(OBJECT_SELF);
            int nPlayerScore = FloatToInt(GetDisableDeviceLevel(oUser));

            if (nActionResult)
            {
                if (Trap_GetOwner(OBJECT_SELF) == oUser)
                {
                    // Can always disarm your own traps
                    nActionResult = TRUE;
                }
                else
                {
                    Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName(), "Player score: " + ToString(nPlayerScore) + " vs Disarm Level: " + ToString(nTargetScore));

                    nActionResult = (nPlayerScore >= nTargetScore);
                }

                WR_AddCommand(oUser, CommandPlayAnimation(904));

                if (nActionResult)
                {
                    // Can only disarm a trap once.
                    if (!GetLocalInt(OBJECT_SELF, PLC_DO_ONCE_A))
                    {
                        SetLocalInt(OBJECT_SELF, PLC_DO_ONCE_A, TRUE);

                        // Slight delay to account for disarm animation.
                        Trap_SignalDisarmEvent(OBJECT_SELF, oUser, 3.0f);
                    }
                }
                else
                {
                    if (nTargetScore >= DEVICE_DIFFICULTY_IMPOSSIBLE)
                    {
                        UI_DisplayMessage(oUser, UI_MESSAGE_DISARM_NOT_POSSIBLE);
                    }
                    else
                    {
                        UI_DisplayMessage(oUser, TRAP_DISARM_FAILED);
                        SSPartyMemberComment(CLASS_ROGUE, SOUND_SITUATION_SKILL_FAILURE, oUser);
                    }
                    Trap_SignalTeam(OBJECT_SELF);
                    PlaySound(OBJECT_SELF, SOUND_TRAP_DISARM_FAILURE);
                }
            }
            else
            {
                UI_DisplayMessage(oUser, TRAP_DISARM_FAILED);
                Trap_SignalTeam(OBJECT_SELF);
            }

            break;
        }

        case PLACEABLE_ACTION_UNLOCK:
        {
            int     nLockLevel   = GetPlaceablePickLockLevel(OBJECT_SELF);
            int     bRemoveKey   = GetPlaceableAutoRemoveKey(OBJECT_SELF);
            int     bKeyRequired = GetPlaceableKeyRequired(OBJECT_SELF);
            string  sKeyTag      = GetPlaceableKeyTag(OBJECT_SELF);
            int     bUsedKey     = FALSE;

            if (IsPartyMember(oUser))
            {
                WR_SetPlotFlag(PLT_TUT_PLACEABLE_LOCKED, TUT_PLACEABLE_LOCKED_ENCOUNTER_1, TRUE);
            }

            // Set ActionResult to reflect the 'unlocked' state
            nActionResult = FALSE;

            // Attempt to use key
            if (sKeyTag != "")
            {
                object oKey = GetItemPossessedBy(oUser, sKeyTag);
                if (IsObjectValid(oKey))
                {
                    bUsedKey = TRUE;
                    nActionResult = TRUE;
                    if (bRemoveKey)
                        DestroyObject(oKey, 0);
                }
            }

            int bLockPickable = (nLockLevel < DEVICE_DIFFICULTY_IMPOSSIBLE);
            if (bLockPickable)
            {
                // If still locked and key not required then rogues can attempt to pick lock.
                if (!nActionResult && !bKeyRequired && HasAbility(oUser, ABILITY_TALENT_HIDDEN_ROGUE))
                {
                    // player score
                    float fPlayerScore = GetDisableDeviceLevel(oUser);
                    float fTargetScore = IntToFloat(nLockLevel);

                    Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName(), "nLockLevel = " + ToString(nLockLevel));
                    Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName(), "Final Value = " + ToString(fPlayerScore));

                    nActionResult = (fPlayerScore >= fTargetScore);
                }
            }

            if (nActionResult)
            {
                // Success
                UI_DisplayMessage(OBJECT_SELF, (bUsedKey ? UI_MESSAGE_UNLOCKED_BY_KEY : UI_MESSAGE_UNLOCKED));
                PlaySound(OBJECT_SELF, GetM2DAString(TABLE_PLACEABLE_TYPES, "PickLockSuccess", GetAppearanceType(OBJECT_SELF)));

                if (!bKeyRequired)
                    AwardDisableDeviceXP(oUser, nLockLevel);
            }
            else
            {
                if (bKeyRequired)
                {
                    UI_DisplayMessage(OBJECT_SELF, UI_MESSAGE_KEY_REQUIRED);
                }
                else
                {
                    if (!bLockPickable)
                    {
                        UI_DisplayMessage(oUser, UI_MESSAGE_LOCKPICK_NOT_POSSIBLE);
                    }
                    else
                    {
                        UI_DisplayMessage(oUser, UI_MESSAGE_UNLOCK_SKILL_LOW);
                        SSPartyMemberComment(CLASS_ROGUE, SOUND_SITUATION_SKILL_FAILURE, oUser);
                    }
                }
                PlaySound(OBJECT_SELF, GetM2DAString(TABLE_PLACEABLE_TYPES, "PickLockFailure", GetAppearanceType(OBJECT_SELF)));
            }

            //increment unlocking achievement
            if(nActionResult && !bUsedKey)
            {
                ACH_LockpickAchievement(oUser);
            }

            // Signal result to self.
            event evResult = Event(nActionResult ? EVENT_TYPE_UNLOCKED : EVENT_TYPE_UNLOCK_FAILED);
            evResult = SetEventObject(evResult, 0, oUser);
            SignalEvent(OBJECT_SELF, evResult);

            break;
        }

        case PLACEABLE_ACTION_OPEN_INVENTORY:
        {
            SendEventOpened(OBJECT_SELF, oUser);

            if (FindSubString(GetTag(OBJECT_SELF), "_autoloot") >= 0)
                MoveAllItems(OBJECT_SELF, oUser);
            else if (GetTag(OBJECT_SELF) == AF_IP_CAMP_MERCH_CHEST || HasImportantItems(OBJECT_SELF) || LootObject(OBJECT_SELF, oUser) != LOOT_RETURN_OK)
                OpenInventory(OBJECT_SELF, oUser);

            if(GetLocalInt(GetModule(), TUTORIAL_ENABLED))
                WR_SetPlotFlag(PLT_TUT_INVENTORY, TUT_INVENTORY_1, TRUE);

            break;
        }

        case PLACEABLE_ACTION_FLIP_COVER:
        {
            break;
        }

        case PLACEABLE_ACTION_USE_COVER:
        {
            // Store user so they can be un-crouched if placeable is destroyed.
            SetLocalObject(OBJECT_SELF, PLC_FLIP_COVER_CREATURE_1, oUser);

            break;
        }

        case PLACEABLE_ACTION_LEAVE_COVER:
        {
            SetLocalObject(OBJECT_SELF, PLC_FLIP_COVER_CREATURE_1, OBJECT_INVALID);
            break;
        }

        case PLACEABLE_ACTION_TOPPLE:
        {
            break;
        }

        case PLACEABLE_ACTION_DESTROY:
        {

            // Remove stealth
            if (IsStealthy(oUser))
                SetStealthEnabled(oUser, FALSE);

            // Make user attack placeable
            WR_AddCommand(oUser, CommandAttack(OBJECT_SELF));

            // Return (instead of break) since the action result for the
            // destroy action is set by the death event handler (i.e. the
            // destroy action succeeds when the placeable reaches 0 health).
            return;
        }

        case PLACEABLE_ACTION_TURN_LEFT:
        {
            // large ballista rotation (activated on base)
            // Find nearest large ballista object and rotate to match base rotation
            object oTop = UT_GetNearestObjectByTag(OBJECT_SELF, PLC_TAG_BIG_BALLISTA);
            if (IsObjectValid(oTop))
            {
                SetFacing(oTop, GetFacing(oTop) - 15.0f);
            }
            PlaySound(OBJECT_SELF, "glo_fly_plc/placeables/ballista_mount/ballista_mount");
            break;
        }

        case PLACEABLE_ACTION_TURN_RIGHT:
        {
            // large ballista rotation (activated on base)
            // Find nearest large ballista object and rotate to match base rotation
            object oTop = UT_GetNearestObjectByTag(OBJECT_SELF, PLC_TAG_BIG_BALLISTA);
            if (IsObjectValid(oTop))
            {
                SetFacing(oTop, GetFacing(oTop) + 15.0f);
            }
            PlaySound(OBJECT_SELF, "glo_fly_plc/placeables/ballista_mount/ballista_mount");
            break;
        }

        default:
        {
            Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleUsed", "PLACEABLE_ACTION (" + ToString(nAction) + ") *** Unhandled action ***");
        }
    }

    TrackPlaceableEvent(GetEventType(ev), OBJECT_SELF, oUser, nAction, nActionResult);

    // Action result determines next state transition.
    SetPlaceableActionResult(OBJECT_SELF, nAction, nActionResult, bVariation);
}


/**-----------------------------------------------------------------------------
* @brief Handles the EVENT_TYPE_DIALOGUE placeable event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleDialog(event ev)
{
    object oInitiator      = GetEventCreator(ev);      // Player or NPC to talk to.
    resource rConversation = GetEventResource(ev, 0);  // Conversation to play.

    if (!GetCombatState(oInitiator))
    {
        UT_Talk(OBJECT_SELF, oInitiator);
    }
}


/**-----------------------------------------------------------------------------
* @brief Handles EVENT_TYPE_INVENTORY_* placeable events.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleInventory(event ev)
{
    object oOwner = GetEventCreator(ev);      // Previous owner
    object oItem  = GetEventObject(ev, 0);    // item added/removed

    switch (GetEventType(ev))
    {
        case EVENT_TYPE_INVENTORY_ADDED:
        {
            break;
        }
        case EVENT_TYPE_INVENTORY_REMOVED:
        {
            break;
        }
    }
}



/**----------------------------------------------------------------------------
* @brief Handles the EVENT_TYPE_ATTACKED placeable event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleAttacked(event ev)
{
    object oAttacker = GetEventCreator(ev);
}


/**-----------------------------------------------------------------------------
* @brief Handles the EVENT_TYPE_DAMAGED placeable event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleDamaged(event ev)
{
    object oDamager = GetEventCreator(ev);
    float fDamage   = GetEventFloat(ev, 0);
    int nDamageType = GetEventInteger(ev, 0);


    // Outside of combat, force damager to continue bashing placeable
    if (GetGameMode() == GM_EXPLORE && GetCurrentHealth(OBJECT_SELF) > 0.0f)
    {
        WR_AddCommand(oDamager, CommandAttack(OBJECT_SELF));
    }

}


/**-----------------------------------------------------------------------------
* @brief Handles the EVENT_TYPE_DEATH placeable event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleDeath(event ev)
{
    object oKiller = GetEventCreator(ev);

    // Play death visual effect
    int nType = GetAppearanceType(OBJECT_SELF);
    int nVFX  = GetM2DAInt(TABLE_PLACEABLE_TYPES, "DestroyVFX", nType);
    if (nVFX)
    {
        ApplyEffectVisualEffect(OBJECT_SELF, OBJECT_SELF, nVFX, EFFECT_DURATION_TYPE_TEMPORARY, 1.5);
    }

    // Determine angle to last attacker for doors and set variation accordingly.
    int bVariation = TRUE;
    if (GetPlaceableStateCntTable(OBJECT_SELF) == PLC_STATE_CONTROLLER_DOOR)
    {
        float fAngle = GetAngleBetweenObjects(OBJECT_SELF, oKiller);
        Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleDeath()", "fAngle: " + ToString(fAngle));
        if (fAngle < 90.0f || fAngle > 270.0f)
            bVariation = FALSE;
    }

    // The result of the destroy action is set in the death event handler since
    // the destroy action 'succeeds' only when the placeable reaches 0 health.
    //SetPlaceableActionResult(OBJECT_SELF, PLACEABLE_ACTION_DESTROY, TRUE, bVariation);
    string sStateTable = GetPlaceableStateCntTable(OBJECT_SELF);
    int nDeathState;
    if(sStateTable == "StateCnt_Furniture" || sStateTable == "StateCnt_Puzzle" || sStateTable == "StateCnt_Static")
        nDeathState = 1;
    else if(sStateTable == "StateCnt_AOE" || sStateTable == "StateCnt_FlipCover" || sStateTable == "StateCnt_Selectable_Trap"
        || sStateTable == "StateCnt_Container_Static" || sStateTable == "StateCnt_Trigger" || sStateTable == "StateCnt_Door_Secret")
        nDeathState = 2;
    else if(sStateTable == "StateCnt_Cage" || sStateTable == "StateCnt_Container" || sStateTable == "StateCnt_BBase" || sStateTable == "StateCnt_Door")
        nDeathState = 3;

    SetPlaceableState(OBJECT_SELF, nDeathState);

    // If killer is not in combat, stop attacking placeable.
    if (GetGameMode() == GM_EXPLORE)
    {

        //WR_ClearAllCommands(oKiller);
        WR_AddCommand(oKiller, CommandWait(2.0f));
        WR_AddCommand(oKiller, CommandSheatheWeapons());
    }

    // Damage contents of containers.
    object[] aItems = GetItemsInInventory(OBJECT_SELF);
    int nItems = GetArraySize(aItems);
    if (nItems > 0)
    {
        int i;
        for (i = 0; i < nItems; i++)
        {
            int n = GetItemStackSize(aItems[i]);
            if (n > 1)
            {
                SetItemStackSize(aItems[i], n/2);
            }
            else if (!IsPlot(aItems[i]) && GetItemEquipSlotMask(GetBaseItemType(aItems[i])) && Random(2))
            {
                SetItemDamaged(aItems[i], TRUE);
            }
        }
    }

    // Debug - set inactive
    if(GetPlaceableBaseType(OBJECT_SELF) == 220)
        SetObjectActive(OBJECT_SELF, FALSE);


    // Track death for game metrics
    TrackObjectDeath(ev);
}


/**-----------------------------------------------------------------------------
* @brief Handles EVENT_TYPE_COMMAND_COMPLETE placeable event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleCommandCompleted(event ev)
{
//    int nLastCommandType = GetEventInteger(ev, 0);
//    int nCommandStatus   = GetEventInteger(ev, 1);
//    int nLastSubCommand  = GetEventInteger(ev, 2);
}



/**-----------------------------------------------------------------------------
* @brief Handles EVENT_TYPE_UNLOCK_FAILED placeable event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleUnlockFailed(event ev)
{
    // play unlock failed sound
    string sSound = GetM2DAString(TABLE_PLACEABLE_TYPES, "PickLockFailure", GetAppearanceType(OBJECT_SELF));
    PlaySound(OBJECT_SELF, sSound);
/*
    object oPlc = OBJECT_SELF;
    if (!IsPlot(oPlc))
    {
        // Try bashing it open instead.
        object oUser = GetEventObject(ev, 0);
        WR_AddCommand(oUser, CommandAttack(oPlc));
    }
*/
}


/**-----------------------------------------------------------------------------
* @brief Handles EVENT_TYPE_UNLOCKED placeable event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleUnlocked(event ev)
{
    // play unlock success sound
    string sSound = GetM2DAString(TABLE_PLACEABLE_TYPES, "PickLockSuccess", GetAppearanceType(OBJECT_SELF));
    PlaySound(OBJECT_SELF, sSound);

    // Automatically open doors/containers when they are unlocked.
    object oUser            = GetEventObject(ev, 0);
    string sStateController = GetPlaceableStateCntTable(OBJECT_SELF);
    if (sStateController == PLC_STATE_CONTROLLER_CONTAINER)
    {
        AddCommand(oUser, CommandUseObject(OBJECT_SELF, PLACEABLE_ACTION_OPEN_INVENTORY));
    }
/*  else if (sStateController == PLC_STATE_CONTROLLER_DOOR)
    {
        AddCommand(oUser, CommandUseObject(OBJECT_SELF, PLACEABLE_ACTION_OPEN));
    }
*/
}

/**-----------------------------------------------------------------------------
* @brief Handles EVENT_TYPE_COMMAND_COMPLETE placeable event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleCastAt(event ev)
{
}


/**-----------------------------------------------------------------------------
* @brief Handles EVENT_TYPE_PLACEABLE_ONCLICK placeable event.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleClicked(event ev)
{
}


/**-----------------------------------------------------------------------------
* @brief Handles EVENT_TYPE_ATTACK_IMPACT placeable event.
*
* The EVENT_TYPE_ATTACK_IMPACT event is triggered when a projectile fired by
* the placeable strikes something (creature, placeable, surface, etc). The
* event fires once for all targets hit in a single frame.
*
* @param    ev  The event being handled.
*-----------------------------------------------------------------------------*/
void Placeable_HandleImpact(event ev)
{
    int i;
    object[] arTarget;
    for (i = 1; IsObjectValid(GetEventObject(ev, i)); i++)
    {
        Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleImpact()", "Target [" + IntToString(i) + "]: " + GetTag(GetEventObject(ev, i)));

        arTarget[i-1] = GetEventObject(ev, i);
        if(i >= 2 && arTarget[i-1] == arTarget[i-2])
        {
            arTarget[i-1] = OBJECT_INVALID;
            break;
        }
    }
    object oAttacker = GetEventObject(ev, 0);
    int    nTargets        = GetArraySize(arTarget);
    int    nCombatResult   = GetEventInteger(ev, 0);
    int    nProjectileType = GetEventInteger(ev, 2);

    location lImpact       = GetEventLocation(ev, 0);  // position
    location lMissile      = GetEventLocation(ev, 1);  // orientation

    for (i = 0; i < nTargets; i++)
    {
        if(!IsObjectValid(arTarget[i]))
            break;

        // Apply damage to targets based on projectile type
        float fDamage;
        switch (nProjectileType)
        {
            case 51: // ballista bolt (from BITM_base.xls)
            {
                fDamage = 7.0 + RandomF(4, 1) * GetLevel(arTarget[i]);   // base damage
                fDamage = DmgGetArmorMitigatedDamage(fDamage, 2.0f, arTarget[i]);

                break;
            }
            case 54: // big ballista bolt
            case 58: // same, climax only
            {
                // checking only first target as the archdemon ended up being hit 3 times
                // by the same bolt.
                fDamage = 50.0 + RandomF(4, 1) * GetLevel(arTarget[i]);   // base damage
                fDamage = DmgGetArmorMitigatedDamage(fDamage, 5.0f, arTarget[i]);

                break;
            }
            default:
                Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleImpact()", ToString(nProjectileType) + " *** Unhandled projectile type ***");
        }

        effect eDamage = EffectDamage(fDamage, DAMAGE_TYPE_PHYSICAL, DAMAGE_EFFECT_FLAG_UPDATE_GORE | DAMAGE_EFFECT_FLAG_CRITICAL);
        ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eDamage, arTarget[i]);
        if(GetAppearanceType(arTarget[i]) == APP_TYPE_ARCHDEMON )
        {
            if(nProjectileType == 54 || nProjectileType == 58)
            {
                oAttacker = GetLocalObject(oAttacker, PLC_FLIP_COVER_CREATURE_1);
                Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleImpact()", "attacker: " + GetTag(oAttacker));
            }
            Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleImpact()", "ARCHDEMON!");
            WR_ClearAllCommands(arTarget[i], TRUE);
            command cScream = CommandPlayAnimation(149);
            //command cScream = CommandUseAbility(MONSTER_HIGH_DRAGON_ROAR, arTarget[i]);
            WR_AddCommand(arTarget[i], cScream, TRUE);

            // jump somewhere
            //object [] arWPs = GetNearestObjectByTag(arTarget[i], AI_WP_MOVE, OBJECT_TYPE_WAYPOINT, 2);
            //Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleImpact()", "Jump wps found: " + IntToString(GetArraySize(arWPs)));
            //object oWP = arWPs[1]; // second farthest
            //if(IsObjectValid(oWP))
            //{
            //        Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleImpact()", "JUMPING");
            //        command cJump = CommandFly(GetLocation(oWP));
            //        WR_AddCommand(arTarget[i], cJump, FALSE);
            //}

            // generate tons of threat against the shooter (from archdemon and anyone else around
            float fThreatChange = 150.0;
            // Not updating for archdemon (too brutal)
            //AI_Threat_UpdateCreatureThreat(arTarget[i], oAttacker, fThreatChange);
            object [] arEnemies = GetNearestObjectByGroup(OBJECT_SELF, GROUP_HOSTILE, OBJECT_TYPE_CREATURE, 10, TRUE);
            int nSize = GetArraySize(arEnemies);
            Log_Trace(LOG_CHANNEL_SYSTEMS_PLACEABLES, GetCurrentScriptName() + ".Placeable_HandleImpact()", "found enemies: " + IntToString(nSize));
            int i;
            object oCurrent;
            for(i = 0; i < nSize; i++)
            {
                oCurrent = arEnemies[i];
                if(oCurrent != arTarget[i])
                    AI_Threat_UpdateCreatureThreat(oCurrent, oAttacker, fThreatChange);
            }

        }
        else
        {
            effect eKnockdown = EffectKnockdown(OBJECT_SELF, 0);
            ApplyEffectOnObject(EFFECT_DURATION_TYPE_INSTANT, eKnockdown, arTarget[i]);
        }
    }
}