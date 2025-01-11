#include "wrappers_h"

void main()
{
    int nWynneDead = WR_GetPlotFlag("26FDFC026321452EB7177B523D43C17E", 28);
    int nPlotAccepted = WR_GetPlotFlag("6B6BBFA0663548E3BD09C1E0E1B8825F", 1); 
    
    if (nWynneDead && !nPlotAccepted)
    {
        WR_SetPlotFlag("6B6BBFA0663548E3BD09C1E0E1B8825F", 0, 1);
    }
    
    if (nPlotAccepted)
    {
        WR_SetPlotFlag("6B6BBFA0663548E3BD09C1E0E1B8825F", 0, 0);
    }
}
