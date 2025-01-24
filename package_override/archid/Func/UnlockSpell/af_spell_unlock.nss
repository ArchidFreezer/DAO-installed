#include "abi_templates"
#include "spell_constants_h"
#include "placeable_h"
#include "af_constants_h"
#include "af_logging_h"

// This must match the row in the logging_ m2da table
const int AF_LOG_UNLOCK_SPELL = 2;

// String references
const int AF_STR_MAGIC_UNLOCK_FAIL = 6610014;
const int AF_STR_MAGIC_UNLOCK_INVALID = 6610015;
const int AF_STR_MAGIC_UNLOCK_INVALID_PLACEABLE_TYPE = 6610016;
const int AF_STR_MAGIC_UNLOCK_TARGET_UNLOCKED = 6610017;

const float SPELL_UNLOCK_1_POWER = 10.0f;
const float SPELL_UNLOCK_2_POWER = 25.0f;
const float SPELL_UNLOCK_3_POWER = 40.0f;

/**
 * @brief Attempt to unlock the container using the spell
 *
 * @param ev     The event messaged to the spellscript
 **/
void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{

    object oTarget = stEvent.oTarget;
    object oCaster = stEvent.oCaster;
    float fSpellpower = GetCreatureProperty(oCaster, PROPERTY_ATTRIBUTE_SPELLPOWER, PROPERTY_VALUE_TOTAL);

    afLogInfo("Spell Unlock : EVENT_TYPE_SPELLSCRIPT_IMPACT - Handling impact", AF_LOG_UNLOCK_SPELL);

    // make sure there is a location, just in case
    if (IsObjectValid(oTarget))
        stEvent.lTarget = GetLocation(oTarget);
    else
        return;

    // Get the lock difficulty
    float fCasterLevel;
    float fLockLevel = IntToFloat(GetPlaceablePickLockLevel(oTarget));
    afLogDebug("Spell Unlock - SPELL_UNLOCK - Lock level: " + FloatToString(fLockLevel), AF_LOG_UNLOCK_SPELL);
    switch (stEvent.nAbility)
    {
        case AF_ABI_SPELL_UNLOCK_1: {
            fCasterLevel = (SPELL_UNLOCK_1_POWER + (fSpellpower * 0.5f));
            afLogDebug("Spell Unlock - SPELL_UNLOCK_1 - Caster level: " + FloatToString(fCasterLevel), AF_LOG_UNLOCK_SPELL);
            break;
        }
        case AF_ABI_SPELL_UNLOCK_2: {
            fCasterLevel = (SPELL_UNLOCK_2_POWER + (fSpellpower * 0.5f));
            afLogDebug("Spell Unlock - SPELL_UNLOCK_2 - Caster level: " + FloatToString(fCasterLevel), AF_LOG_UNLOCK_SPELL);
            break;
        }
        case AF_ABI_SPELL_UNLOCK_3: {
            fCasterLevel = (SPELL_UNLOCK_3_POWER + fSpellpower);
            afLogDebug("Spell Unlock - SPELL_UNLOCK_3 - Caster level: " + FloatToString(fCasterLevel), AF_LOG_UNLOCK_SPELL);
            break;
        }
    }

    event evResult;
    if (fCasterLevel >= fLockLevel) {
        afLogDebug("Spell Unlock : Unlock success", AF_LOG_UNLOCK_SPELL);
        UI_DisplayMessage(oTarget, UI_MESSAGE_UNLOCKED);
        PlaySound(oTarget, GetM2DAString(TABLE_PLACEABLE_TYPES, "PickLockSuccess", GetAppearanceType(oTarget)));
        evResult = Event(EVENT_TYPE_UNLOCKED);
    } else {
        afLogDebug("Spell Unlock : Unlock fail", AF_LOG_UNLOCK_SPELL);
        DisplayFloatyMessage(oTarget, GetStringByStringId(AF_STR_MAGIC_UNLOCK_FAIL));
        PlaySound(oTarget, GetM2DAString(TABLE_PLACEABLE_TYPES, "PickLockFailure", GetAppearanceType(oTarget)));
        evResult = Event(EVENT_TYPE_UNLOCK_FAILED);
    }

    evResult = SetEventObject(evResult, 0, oCaster);
    SignalEvent(oTarget, evResult);

}

/**
 * @brief Check if the spell is possible against this target
 *
 * @param ev     The event messaged to the spellscript
 **/
int checkTargetIsValid(event ev) {

    object oTarget = GetEventObject(ev, 1);    int nLockLevel = GetPlaceablePickLockLevel(oTarget);

    int bTargetValid = TRUE;

    // We only deal with 3 types of locked objects: Door, Cage & Container
    string sStateTable = GetPlaceableStateCntTable(oTarget);
    if (sStateTable != PLC_STATE_CNT_CAGE && sStateTable != PLC_STATE_CNT_CONTAINER && sStateTable != PLC_STATE_CNT_DOOR) {
        afLogDebug("Spell Unlock : checkTarget - target incorrect type", AF_LOG_UNLOCK_SPELL);
        DisplayFloatyMessage(oTarget, GetStringByStringId(AF_STR_MAGIC_UNLOCK_INVALID_PLACEABLE_TYPE));
        bTargetValid = FALSE;
    } else if (sStateTable == PLC_STATE_CNT_CAGE && GetPlaceableState(oTarget) != PLC_STATE_CAGE_LOCKED ||
               sStateTable == PLC_STATE_CNT_CONTAINER && GetPlaceableState(oTarget) != PLC_STATE_CONTAINER_LOCKED ||
               sStateTable == PLC_STATE_CNT_DOOR && GetPlaceableState(oTarget) != PLC_STATE_DOOR_LOCKED) {
        afLogDebug("Spell Unlock : checkTarget - target already unlocked", AF_LOG_UNLOCK_SPELL);
        DisplayFloatyMessage(oTarget, GetStringByStringId(AF_STR_MAGIC_UNLOCK_TARGET_UNLOCKED));
        bTargetValid = FALSE;
    } else if (!GetPlaceableKeyRequired(oTarget) && nLockLevel < DEVICE_DIFFICULTY_IMPOSSIBLE) {
        afLogDebug("Spell Unlock : checkTarget - target cannot be unlocked", AF_LOG_UNLOCK_SPELL);
        DisplayFloatyMessage(oTarget, GetStringByStringId(AF_STR_MAGIC_UNLOCK_INVALID));
        bTargetValid = FALSE;
   }

    return bTargetValid;
}

/* -------------------
 * Entry point for script
 */
void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    afLogInfo("Spell Unlock : entered ability script", AF_LOG_UNLOCK_SPELL);

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            afLogDebug("Spell Unlock : EVENT_TYPE_SPELLSCRIPT_PENDING", AF_LOG_UNLOCK_SPELL);
            Ability_SetSpellscriptPendingEventResult(checkTargetIsValid(ev) ? COMMAND_RESULT_SUCCESS : COMMAND_RESULT_INVALID);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            afLogDebug("Spell Unlock : EVENT_TYPE_SPELLSCRIPT_CAST", AF_LOG_UNLOCK_SPELL);

            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // Hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            afLogDebug("Spell Unlock : EVENT_TYPE_SPELLSCRIPT_IMPACT", AF_LOG_UNLOCK_SPELL);

            // Get a structure with the event parameters
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            // Handle impact
            _HandleImpact(stEvent);

            break;
        }
    }
}