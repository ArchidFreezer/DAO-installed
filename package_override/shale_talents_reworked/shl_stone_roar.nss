//*=============================================================================
// AB: script for Shale's Stone Roar
//*=============================================================================

#include "abi_templates"
#include "combat_h"

void _HandleImpact(struct EventSpellScriptImpactStruct stEvent)
{
    // make sure there is a location, just in case
    if (IsObjectValid(stEvent.oTarget) == TRUE)
    {
        stEvent.lTarget = GetLocation(stEvent.oTarget);
    }

    // impact VFX on target; not used (or not played) in vanilla
    ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oTarget, 105407, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

    // extra threat toward target
    float fThreatInc = 40.0;

    // clear target's threat table
    int nNumEnemies = GetThreatTableSize(stEvent.oTarget);
    int i = 0;
    object oCurrent;
    float fCurrentThreat;
    float fThreatChange;
    for(i = 0; i < nNumEnemies; i++)
    {
        oCurrent = GetThreatEnemy(stEvent.oTarget, i);
        if (oCurrent != stEvent.oCaster) // leave Shale's threat unchanged
        {
            fCurrentThreat = GetThreatValueByIndex(stEvent.oTarget, i);
            fThreatChange = -1.0 * (fCurrentThreat - 1.0);
            AI_Threat_UpdateCreatureThreat(stEvent.oTarget, oCurrent, fThreatChange);
        }
    }

    // clear target-switching counter so target can change target immediately
    SetLocalInt(stEvent.oTarget, AI_THREAT_TARGET_SWITCH_COUNTER, 0);
    AI_Threat_UpdateCreatureThreat(stEvent.oTarget, stEvent.oCaster, fThreatInc);
}

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_PENDING:
        {
            Ability_SetSpellscriptPendingEventResult(COMMAND_RESULT_SUCCESS);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            // VFX
            ApplyEffectVisualEffect(stEvent.oCaster, stEvent.oCaster, 105405, EFFECT_DURATION_TYPE_INSTANT, 0.0f, stEvent.nAbility);

            // we just hand this through to cast_impact
            int nTarget = PROJECTILE_TARGET_INVALID;
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult, nTarget);

            break;
        }

        case EVENT_TYPE_SPELLSCRIPT_IMPACT:
        {
            //--------------------------------------------------------------
            // Get a structure with the event parameters
            //--------------------------------------------------------------
            struct EventSpellScriptImpactStruct stEvent = Events_GetEventSpellScriptImpactParameters(ev);

            _HandleImpact(stEvent);

            break;
        }
    }
}