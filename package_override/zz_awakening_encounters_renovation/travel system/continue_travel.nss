#include "utility_h"

void main()
{

    string sArea = GetLocalString(GetModule(), WM_STORED_AREA);
    string sWP = GetLocalString(GetModule(), WM_STORED_WP);

    UT_DoAreaTransition(sArea, sWP);
}