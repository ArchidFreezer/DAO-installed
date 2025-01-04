#include "plot_h" 
#include "wrappers_h"

void main()
{
    int nRewardGiven = WR_GetPlotFlag("DF1F834FA55E433A981F60D7B1EB7855", 0);
    int nDSCoveDone = WR_GetPlotFlag("7574013860104EC58B4F7323DA815FC3", 3);
    
    if (nDSCoveDone && !nRewardGiven)
    {
        RewardDistibuteByPlotFlag("7574013860104EC58B4F7323DA815FC3", 3);
        WR_SetPlotFlag("DF1F834FA55E433A981F60D7B1EB7855", 0, TRUE);
    }
}