#include "core_h"

// if the DOT flag is somehow set true while the heartbeat is inactive, DOTs will never apply, thus the existence of this script
void main() {
    object[] arObjects = GetObjectsInArea(GetArea(GetHero()));
    int nSize = GetArraySize(arObjects);
    int i;
    for (i = 0; i < nSize; i++) {
        if (GetObjectType(arObjects[i]) == OBJECT_TYPE_CREATURE) {
            SetCreatureFlag(arObjects[i],CREATURE_RULES_FLAG_DOT,FALSE);
        }
    }
}