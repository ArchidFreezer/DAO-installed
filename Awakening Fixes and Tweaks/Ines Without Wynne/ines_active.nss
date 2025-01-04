#include "wrappers_h"

void main()
{
    int nBoard = WR_GetPlotFlag("6B6BBFA0663548E3BD09C1E0E1B8825F", 1); //job board
    int nComplete = WR_GetPlotFlag("5033A5169AFD4D268124B068CA07323C", 3);  //original quest
    object oInes = GetObjectByTag("trp100cr_ines");

    if (nBoard == 1 && nComplete == 0)
    {
        SetObjectActive(oInes, 1);
    }
}
