#include "var_constants_h"
#include "sys_itemsets_h"
void main()
{
    if (GetLocalInt(OBJECT_SELF, FOLLOWER_SCALED))
        ItemSet_Update(OBJECT_SELF);
}