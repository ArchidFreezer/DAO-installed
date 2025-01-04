#include "2da_constants_h"
#include "global_objects_h"
#include "var_constants_h"
void main() {
    if (GetTag(OBJECT_SELF) == GEN_FL_DOG && GetLocalInt(OBJECT_SELF, FOLLOWER_SCALED)) {    
        int i;
        for (i = 1; i <= 4; i++) {
            string sColumn = "bonus" + IntToString(i);
            int nAbility = GetM2DAInt(TABLE_APP_FOLLOWER_BONUSES, sColumn, 2);
            if(!HasAbility(OBJECT_SELF, nAbility))
                AddAbility(OBJECT_SELF, nAbility);
        }
    }
}