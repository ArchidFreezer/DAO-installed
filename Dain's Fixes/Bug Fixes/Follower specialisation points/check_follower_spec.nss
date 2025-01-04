#include "2da_constants_h"
#include "var_constants_h"
#include "events_h"

int CanSpecialise(object oCreature = OBJECT_SELF) {
    return IsHumanoid(oCreature) && !GetLocalInt(oCreature,IS_SUMMONED_CREATURE);
}

int IsScaled(object oCreature = OBJECT_SELF) {
    return GetLocalInt(oCreature, FOLLOWER_SCALED) && !IsHero(oCreature);
}

int MissingSpecPoints(object oCreature = OBJECT_SELF) {
    int i;
    int nSpecPoints = FloatToInt(-1.0*GetCreatureProperty(oCreature, 38));
    int nLevel = GetLevel(oCreature);
    for (i = 1; i <= nLevel; i++) {
        if (GetM2DAInt(TABLE_EXPERIENCE, "SpecPoint", i)) {
            nSpecPoints++;
        }
    }
    if (nSpecPoints <= 0) {
        return 0;
    }
    int nRows = GetM2DARows(TABLE_RULES_CLASSES);
    for (i = 0; i < nRows; i++) {
        int nRow = GetM2DARowIdFromRowIndex(TABLE_RULES_CLASSES, i);
        // Specialisations have base class set, all other classes don't
        if (GetM2DAInt(TABLE_RULES_CLASSES, "BaseClass", nRow)) {
            int nAbility = GetM2DAInt(TABLE_RULES_CLASSES, "StartingAbility1", nRow);
            if (HasAbility(oCreature, nAbility)) {
                nSpecPoints -= 1;
                if (nSpecPoints <= 0) {
                    return 0;
                }
            }
        }
    }
    return nSpecPoints;
}

void CheckSpec(object oCreature = OBJECT_SELF) {
    if (IsScaled(oCreature) && CanSpecialise(oCreature)) {
        int nMissing = MissingSpecPoints(oCreature);
        if (nMissing > 0) {
            float fPoints = GetCreatureProperty(oCreature, 38) + IntToFloat(nMissing);
            SetCreatureProperty(oCreature, 38, fPoints);
        }
    }
}

void main() {
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);
    if (nEventType == EVENT_TYPE_PARTY_MEMBER_HIRED) {
        CheckSpec(OBJECT_SELF);
    } else {
        object[] arFollowers = GetPartyList();
        int i, nSize = GetArraySize(arFollowers);
        for (i = 0; i < nSize; i++) {
            CheckSpec(arFollowers[i]);
        }
    }
}