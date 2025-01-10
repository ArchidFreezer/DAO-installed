// -----------------------------------------------------------------------------
// ss_dheu_grease_override.ncs - Grease Override spell script
// -----------------------------------------------------------------------------
/*
    Area of effect that slows all creatures in it and gives them a small increase
    in mana regeneration. This version is a duplicate of the 1.01 version 
    with additional checking for the Skill SpellShaping.
    
    Redirection handled by impact event interception in ss_dheu_impact.nss
*/
// -----------------------------------------------------------------------------
// PeterT - 15/1/2008
// -----------------------------------------------------------------------------

#include "log_h"
#include "aoe_effects_h"
#include "spell_constants_h"
#include "effect_dot2_h"
#include "ss_dheu_constants_h"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev); // CAST (directly from engine) or COMMAND_PENDING (re-directed by rules_core)

    switch(nEventType)
    {
        case EVENT_TYPE_SPELLSCRIPT_CAST:
        {
            //PrintToLog("Spell Shaping : EVENT_TYPE_SPELLSCRIPT_CAST (ss_dheu_grease_override) caught");
            // Get a structure with the event parameters
            struct EventSpellScriptCastStruct stEvent = Events_GetEventSpellScriptCastParameters(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_SPELLSCRIPT_CAST");

            // we just hand this through to cast_impact
            SetAbilityResult(stEvent.oCaster, stEvent.nResistanceCheckResult);

            break;
        }

        case EVENT_TYPE_ENTER:
        {
            //PrintToLog("Spell Shaping : EVENT_TYPE_ENTER (ss_dheu_grease_override) caught");
            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_ENTER " + ToString(oTarget));

            DEBUG_PrintToScreen("Entering Grease: " + ToString(oTarget));

            if (HasAbility(oCreator,IMPROVED_SPELLSHAPING))
            {
                //PrintToLog("Spell Shaping : EVENT_TYPE_ENTER (ss_dheu_grease_override) Has SpellShaping");

                if (HasAbility(oCreator,MASTER_SPELLSHAPING))
                {                    
                    if (IsObjectValid(oTarget))
                    {
                        // Maybe consider GetHero if oCreator isn't working
                        if (IsObjectHostile(oTarget,oCreator))
                        {
                            if (CheckSpellResistance(oTarget, oCreator, nAbility) == FALSE)
                            {
                                if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
                                {
                                    ApplyAOEEffect_Grease(oTarget, oCreator, nAbility, OBJECT_SELF);
                                }
                            } 
                            else
                            {
                                UI_DisplayMessage(oTarget, UI_MESSAGE_RESISTED);
                            }
                        }
                        // else ignore
                    }
                }
                else if (IsObjectValid(oTarget))
                {
                    // Code for expert is the same as improved since expert only
                    // protects allies from damage and that is handled elsewhere.

                    if (!IsPartyMember(oTarget))
                    {
                       if (CheckSpellResistance(oTarget, oCreator, nAbility) == FALSE)
                        {
                            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
                            {
                                ApplyAOEEffect_Grease(oTarget, oCreator, nAbility, OBJECT_SELF);
                            }
                        } 
                        else
                        {
                            UI_DisplayMessage(oTarget, UI_MESSAGE_RESISTED);
                        }
                    }
                    // else ignore
                }
            }
            else
            {
                //PrintToLog("Spell Shaping : EVENT_TYPE_ENTER (ss_dheu_grease_override) NO SpellShaping");

                // Default (orignial) implementation
                if (CheckSpellResistance(oTarget, oCreator, nAbility) == FALSE)
                {
                    if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
                    {
                        ApplyAOEEffect_Grease(oTarget, oCreator, nAbility, OBJECT_SELF);
                    }
                } else
                {
                    UI_DisplayMessage(oTarget, UI_MESSAGE_RESISTED);
                }
            }
            //---
            break;
        }

        case EVENT_TYPE_AOE_HEARTBEAT:
        {
            //PrintToLog("Spell Shaping : EVENT_TYPE_AOE_HEARTBEAT (ss_dheu_grease_override) caught");
            int nAbility = GetEventInteger(ev,0);
            object oCreator = GetEventCreator(ev);

             int nFlag = GetAOEFlags(OBJECT_SELF);
            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " - Grease EVENT_TYPE_HEARTBEAT " + ToString(oCreator));


            if ((nFlag & AOE_FLAG_DESTRUCTION_PENDING) == AOE_FLAG_DESTRUCTION_PENDING)
            {
                Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_HEARTBEAT aborted, flagged for deletion");
                return;
            }


            object[] targets = GetCreaturesInAOE(OBJECT_SELF);
            int nSize = GetArraySize(targets);
            int i;

            for (i= 0; i < nSize && i < 10 /*max targets for performance reasons*/; i++)
            {

                if (HasDotEffectOfType(targets[i], DAMAGE_TYPE_FIRE))
                {

                    object oIgniter =targets[i];

                    // Now try to figure out who created the fire in the first place
                    effect[] dot = GetDotEffectByDamageType(targets[i], DAMAGE_TYPE_FIRE);
                    if (GetArraySize(dot))
                    {
                        oIgniter = GetEffectCreator(dot[0]);
                    }

                    Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_HEARTBEAT: Igniting grease");
                    IgniteGreaseAoe(OBJECT_SELF, targets[i]);

                    break;
                }
            }


            if (IsObjectValid(OBJECT_SELF))
            {
                // signal next heartbeat
                DelayEvent(GREASE_INTERVAL_DURATION, OBJECT_SELF, ev);
            }


            break;
        }

        case EVENT_TYPE_EXIT:
        {
            //PrintToLog("Spell Shaping : EVENT_TYPE_EXIT (ss_dheu_grease_override) caught");

            int nAbility = GetEventInteger(ev,0);
            object oTarget = GetEventTarget(ev);
            object oCreator = GetEventCreator(ev);

            Log_Trace(LOG_CHANNEL_EVENTS, GetCurrentScriptName() + " EVENT_TYPE_EXIT " + ToString(oTarget));

            if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE)
            {
                RemoveStackingEffects(oTarget, oCreator, nAbility);
            }

            break;
        }
        default:
            //PrintToLog("Spell Shaping : (ss_dheu_grease_override) UNHANDLED EVENTTYPE CAUGHT[" + ToString(nEventType) + "]");
        
    }
}