#include "ability_h"
#include "af_constants_h"
/*
 * Checks if a target is protected by SpellShaping from the effects of a spell
 * oCaster - The person casting the spell
 * oTarget - The object to test whether it is protected by spell shaping
 *
 * Returns TRUE if the target is protected; FALSE otherwise
 */
int IsSpellShapingTarget(object oCaster, object oTarget) {
    // Both caster and target need to be valid and the caster must have spellshaping active
   if (!IsObjectValid(oCaster) || !IsObjectValid(oTarget) || !Ability_IsAbilityActive(oCaster, AF_ABI_SPELLSHAPING))
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
