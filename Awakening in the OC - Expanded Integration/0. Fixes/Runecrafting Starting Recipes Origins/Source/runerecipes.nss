//include utility_h for the UT_AddItemToInventory() function.
#include "utility_h"

void main()
{
    if (IsUsingEP1Resources() == TRUE)
    {
        UT_AddItemToInventory(R"gxa_im_cft_run_102.uti", 1, OBJECT_INVALID, "", TRUE);
        UT_AddItemToInventory(R"gxa_im_cft_run_103.uti", 1, OBJECT_INVALID, "", TRUE);
        UT_AddItemToInventory(R"gxa_im_cft_run_111.uti", 1, OBJECT_INVALID, "", TRUE);
    }
}