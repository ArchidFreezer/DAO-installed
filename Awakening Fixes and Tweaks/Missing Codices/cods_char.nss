#include "wrappers_h"

void main()
{
    // mother flags
    int nMother0 = WR_GetPlotFlag("BFAF30BF3AE449E1BC8AF517CB52C666", 0);  // main
    int nMother1 = WR_GetPlotFlag("BFAF30BF3AE449E1BC8AF517CB52C666", 1);  // against Architect
    int nMother2 = WR_GetPlotFlag("BFAF30BF3AE449E1BC8AF517CB52C666", 2);  // creepy children
    //int nMother3 = WR_GetPlotFlag("BFAF30BF3AE449E1BC8AF517CB52C666", 3);  // why crazy; set during final convo

    // architect flags
    //int nArch0 = WR_GetPlotFlag("90CA2AAEF09C4635A8C9D6FA9EA610BA", 0); // main, dialog in silverite mine, TRP
    //int nArch1 = WR_GetPlotFlag("90CA2AAEF09C4635A8C9D6FA9EA610BA", 1); // Utha, ""
    int nArch2 = WR_GetPlotFlag("90CA2AAEF09C4635A8C9D6FA9EA610BA", 2); // against Mother
    //int nArch3 = WR_GetPlotFlag("90CA2AAEF09C4635A8C9D6FA9EA610BA", 3); // grand plans, during first DoD dialog; also unlocks last Disciples codex
    //int nArch4 = WR_GetPlotFlag("90CA2AAEF09C4635A8C9D6FA9EA610BA", 4); // PC agrees to ally, again in dialog
    //int nArch5 = WR_GetPlotFlag("90CA2AAEF09C4635A8C9D6FA9EA610BA", 5); // PC kills him, ""

    //children flag
    int nChilder3 = WR_GetPlotFlag("8BCE77B523EA40D587784C7B61583FB3", 3);
    
    int nLTL = WR_GetPlotFlag("F257AEF5B9384AB1AEC559D617C0C86C", 4); // LTL complete
    int nSTB = WR_GetPlotFlag("78D19D7452684516B3FFAAEF2D670CFE", 7); // STB complete
    int nTRP = WR_GetPlotFlag("08A15707C7964BE2A2E0A91442EEEB82", 2); // TRP complete

    if ((nLTL || nSTB) && !nMother0)
    {
        WR_SetPlotFlag("BFAF30BF3AE449E1BC8AF517CB52C666", 0, TRUE);  // main appears after either STB or LTL
        WR_SetPlotFlag("8BCE77B523EA40D587784C7B61583FB3", 3, TRUE);  // going to put children here, too, because lazy
    }

    if (nSTB && !nMother1)
    {
        WR_SetPlotFlag("BFAF30BF3AE449E1BC8AF517CB52C666", 1, TRUE); // mother after STB
    }

    if (nLTL && !nMother2)
    {
        WR_SetPlotFlag("BFAF30BF3AE449E1BC8AF517CB52C666", 2, TRUE); // after LTL
    }

    if (nSTB && nTRP && !nArch2)
    {
        WR_SetPlotFlag("90CA2AAEF09C4635A8C9D6FA9EA610BA", 2, TRUE); // Architect gets 3rd update after STB & TRP
    }

}