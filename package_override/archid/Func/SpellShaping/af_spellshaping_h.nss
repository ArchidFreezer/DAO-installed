#include "ability_h"
#include "af_ability_h"

const int SPELLSHAPING_WARNING_STRREFID = 6610059;
const int AF_LOGGROUP_SPELLSHAPING = 9;

/*
 * Checks if a target is protected by SpellShaping from the effects of a spell
 * oCaster - The person casting the spell
 * oTarget - The object to test whether it is protected by spell shaping
 *
 * Returns TRUE if the target is protected; FALSE otherwise
 */
int IsSpellShapingTarget(object oCaster, object oTarget) {
    // Both caster and target need to be valid and the caster must have spellshaping active
   if (!IsObjectValid(oCaster) || !IsObjectValid(oTarget) || !Ability_IsAbilityActive(oCaster, AF_ABI_SPELLSHAPING_1))
        return FALSE;

    // All higher level skills are passive upgrades so we can check in descending order.
    if (HasAbility(oCaster,AF_ABI_SPELLSHAPING_4) && IsObjectHostile(oTarget,oCaster))
        return TRUE;
    else if (HasAbility(oCaster,AF_ABI_SPELLSHAPING_2) && !IsPartyMember(oTarget))
        // Code for expert is the same as improved since expert only protects allies from damage and that is handled elsewhere.
        return TRUE;
    else if (oTarget != oCaster)
        return TRUE;
    else
        return FALSE;
}

/**
* @brief check that the event manager dependencies
*
* This function is called by the module event handler to ensure that th eevent manager config is valid.
* It shows a popup to the player if there is an issue detected
*
**/
void SpellShapingCheckConfig() {
    string appStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_APPLY_EFFECT);
    string ablStr = GetM2DAString(TABLE_EVENTS, "Script", EVENT_TYPE_ABILITY_CAST_IMPACT);

    if (ablStr != "af_ablity_cast_impact" && ablStr != "eventmanager")
        ShowPopup(SPELLSHAPING_WARNING_STRREFID, 1, OBJECT_INVALID, FALSE, 0);
}

