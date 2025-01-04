#include "effects_h"

const int TABLE_EFFECT_OVERRIDE = 700524475;
const int TABLE_EFFECT_MANAGER = 739227090;

int CheckCriterion(int nRow, string sCol, int nComparison) {
    int nVal = GetM2DAInt(TABLE_EFFECT_MANAGER, sCol, nRow);
    return nVal == -1 || nVal == nComparison;
}

void main() {
    // Get event
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    // Get effect
    effect ef = GetCurrentEffect();
    int nEffectType = GetEffectType(ef);

    // Prep override and listeners
    string sOverride = GetM2DAString(TABLE_EFFECT_OVERRIDE, "Script", nEffectType);
    string[] arListeners;
    int nListeners = 0;

    // Parse m2da
    int i, nRows = GetM2DARows(TABLE_EFFECT_MANAGER);
    for (i = 0; i < nRows; i++) {
        int nRow = GetM2DARowIdFromRowIndex(TABLE_EFFECT_MANAGER, i);
        if (CheckCriterion(nRow, "EffectType", nEffectType))
            if (CheckCriterion(nRow, "DurationType", GetEffectDurationType(ef)))
                if (CheckCriterion(nRow, "Event", nEventType))
                    if (CheckCriterion(nRow, "AbilityId", GetEffectAbilityID(ef))) {
                        int nMode = GetM2DAInt(TABLE_EFFECT_MANAGER, "Mode", nRow);
                        string sScript = GetM2DAString(TABLE_EFFECT_MANAGER, "Script", nRow);
                        if (nMode)
                            arListeners[nListeners++] = sScript;
                        else
                            sOverride = sScript;
                    }
    }

    // Execute override if present or else default functionality
    if (sOverride != "")
        HandleEvent_String(ev, sOverride);
    else if (nEventType == 33)
        Effects_HandleApplyEffect();
    else if (nEventType == 34)
        Effects_HandleRemoveEffect();

    // Handle listeners
    for (i = 0; i < nListeners; i++)
        HandleEvent_String(ev, arListeners[i]);
}