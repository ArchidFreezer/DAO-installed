// Climax story so far include

#include "plt_mnp00pt_ssf_climax"
#include "plt_clipt_main"
#include "plt_clipt_morrigan_ritual"
#include "wrappers_h"

#include "plt_qwinn"

void CLI_HandleStorySoFar()
{
    int nPCKnowsAboutArchdemon = WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_RIORDAN_GAVE_ARCHDEMON_INFO);
    // int nPCKnowsAboutRitual = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_KNOWN);
    int nPCKnowsAboutRitual = WR_GetPlotFlag(PLT_QWINN,CLI_PC_KNOWS_ABOUT_DARK_RITUAL);
    int nRitualRefused = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_REFUSED);
    int nRitualAlistair = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_WITH_ALISTAIR);
    int nRitualLoghain = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_WITH_LOGHAIN);
    int nRitualPlayer = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_WITH_PLAYER);
    int nInDenerim = WR_GetPlotFlag(PLT_CLIPT_MAIN, CLI_MAIN_AT_CITY_GATES);

    if(!nPCKnowsAboutArchdemon)
        return;

    if(nInDenerim)
        WR_SetPlotFlag(PLT_MNP00PT_SSF_CLIMAX, SSF_CLIMAX_IN_DENERIM, TRUE);
    else if(nRitualRefused)
        WR_SetPlotFlag(PLT_MNP00PT_SSF_CLIMAX, SSF_CLIMAX_RITUAL_REFUSED, TRUE);
    else if(nRitualAlistair)
        WR_SetPlotFlag(PLT_MNP00PT_SSF_CLIMAX, SSF_CLIMAX_RITUAL_ALISTAIR, TRUE);
    else if(nRitualLoghain)
        WR_SetPlotFlag(PLT_MNP00PT_SSF_CLIMAX, SSF_CLIMAX_RITUAL_LOGHAIN, TRUE);
    else if(nRitualPlayer)
        WR_SetPlotFlag(PLT_MNP00PT_SSF_CLIMAX, SSF_CLIMAX_RITUAL_PLAYER, TRUE);
    else if(nPCKnowsAboutRitual)
        WR_SetPlotFlag(PLT_MNP00PT_SSF_CLIMAX, SSF_CLIMAX_PC_KNOWS_ABOUT_RITUAL, TRUE);
    // Qwinn added the else, without it none of the above ever works.    
    else    
    if(nPCKnowsAboutArchdemon)
        WR_SetPlotFlag(PLT_MNP00PT_SSF_CLIMAX, SSF_CLIMAX_PC_KNOWS_ABOUT_ARCHDEMON, TRUE);


}