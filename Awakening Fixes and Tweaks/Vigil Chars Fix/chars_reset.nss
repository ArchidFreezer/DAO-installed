#include "wrappers_h"

void main()
{
    // party members check
    int nAnders = WR_GetPlotFlag("E3F7CA9BE9C543378764CD4D5AFC00A3", 7);
    int nJustice = WR_GetPlotFlag("E3F7CA9BE9C543378764CD4D5AFC00A3", 5);
    int nNathaniel = WR_GetPlotFlag("E3F7CA9BE9C543378764CD4D5AFC00A3", 10);
    int nOghren = WR_GetPlotFlag("E3F7CA9BE9C543378764CD4D5AFC00A3", 13);
    int nSigrun = WR_GetPlotFlag("E3F7CA9BE9C543378764CD4D5AFC00A3", 16);
    int nVelanna = WR_GetPlotFlag("E3F7CA9BE9C543378764CD4D5AFC00A3", 2);

    // Amaranthine saved
    int nAmaranth = WR_GetPlotFlag("1C7395DEAAC14F889A5D41F86854F48B", 7);

    if (nAmaranth) // if not party of party now, must not have been at Amaranthine
    {
        if (!nAnders)
        {
            WR_SetPlotFlag("1BA3C1D88BD4454289459F4B46796804", 0, FALSE);
        }
        if (!nJustice)
        {
            WR_SetPlotFlag("6957EC86F54A40A9BE39457612399853", 0, FALSE);
        }
        if (!nNathaniel)
        {
            WR_SetPlotFlag("5BEE8FEFF2AC44788A13AD590C96E67A", 10, FALSE);
        }
        if (!nOghren)
        {
            WR_SetPlotFlag("6F08DC1CF4984FF699D7DC3CAD18B753", 0, FALSE);
        }
        if (!nSigrun)
        {
            WR_SetPlotFlag("75CDCA72E1684341AAB7B65AD32BBF63", 0, FALSE);
        }
        if (!nVelanna)
        {
            WR_SetPlotFlag("38428DC092224D6BA4FF30C4A6CB3356", 0, FALSE);
        }
    }
}
