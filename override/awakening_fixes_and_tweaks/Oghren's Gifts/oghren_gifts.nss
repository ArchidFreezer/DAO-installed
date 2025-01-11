#include "wrappers_h"

void main()
{
    int nReset = WR_GetPlotFlag("89F38F31D3824B5F9313F901D6E0CB59", 0);
    object oModule = GetModule();
    
    int nRecruited = IsFollower(GetObjectByTag("gxa000fl_oghren"));

    if (nReset == FALSE && nRecruited == TRUE)
    {
        SetLocalInt(oModule, "APP_APPROVAL_GIFT_COUNT_OGHREN", 0);
        WR_SetPlotFlag("89F38F31D3824B5F9313F901D6E0CB59", 0, TRUE);
    }
}

