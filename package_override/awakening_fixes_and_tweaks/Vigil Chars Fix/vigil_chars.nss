#include "wrappers_h"

void main()
{
    int nAmaranth = WR_GetPlotFlag("1C7395DEAAC14F889A5D41F86854F48B", 22); // Amaranthine attack started
    int nStrong = WR_GetPlotFlag("542D51BDE496410FAE275169B06ABF3E", 257); //Vigil's Keep walls completed

    if (nAmaranth && nStrong)
    {
        // all party members counted as part of Amaranthine party
        WR_SetPlotFlag("1BA3C1D88BD4454289459F4B46796804", 0, TRUE); // Anders
        WR_SetPlotFlag("6957EC86F54A40A9BE39457612399853", 0, TRUE); // Justice
        WR_SetPlotFlag("5BEE8FEFF2AC44788A13AD590C96E67A", 10, TRUE); // Nathaniel - NOT a typo, Nate is different for some reason
        WR_SetPlotFlag("6F08DC1CF4984FF699D7DC3CAD18B753", 0, TRUE); // Oghren
        WR_SetPlotFlag("75CDCA72E1684341AAB7B65AD32BBF63", 0, TRUE); // Sigrun
        WR_SetPlotFlag("38428DC092224D6BA4FF30C4A6CB3356", 0, TRUE); // Velanna
   }
}
