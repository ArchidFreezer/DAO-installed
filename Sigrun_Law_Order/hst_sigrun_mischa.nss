//#include "hst_util_h"



const string SIGRUN_MISCHA_PLOT = "81316D33694B45CF8B632F625B8AF4FC";
const string LAW_AND_ORDER_PLOT = "241BDD39381C4F509333A6B1150BEF06";



const int COD_CHA_SIGRUN_MEETS_MISCHA = 4;
const int COA_CITYGUARD_SHADYFIGURE_ATTACKS = 9;
const int COA_CITYGUARD_MARKET_SMUGGLER_TEAM_ONE_DEAD = 10;
const int COA_CITYGUARD_MARKET_SMUGGLER_TEAM_TWO_DEAD = 11;
const int COA_CITYGUARD_MARKET_SMUGGLER_TEAM_THREE_DEAD = 12;
const int COA_CITYGUARD_MARKET_SMUGGLER_TEAM_FOUR_DEAD = 13;



void main ()
{
    object oParty = GetParty(GetHero());
    object oMischa = GetObjectByTag("gxa000cr_sigrun_barton");
    object oMischaTrigger = GetObjectByTag("coa100tr_sigrun_barton"); 
    string sResRefMischaPlot = GetPlotResRef(SIGRUN_MISCHA_PLOT);
    string sLawOrderPlot = GetPlotResRef(LAW_AND_ORDER_PLOT);
    int nSigrunMeetsMischa = GetPartyPlotFlag(oParty, sResRefMischaPlot, COD_CHA_SIGRUN_MEETS_MISCHA);
    int bMischaTriggerActive = GetObjectActive(oMischaTrigger);
    int nTeam1 = GetPartyPlotFlag(oParty, sLawOrderPlot, COA_CITYGUARD_MARKET_SMUGGLER_TEAM_ONE_DEAD);
    int nTeam2 = GetPartyPlotFlag(oParty, sLawOrderPlot, COA_CITYGUARD_MARKET_SMUGGLER_TEAM_TWO_DEAD);
    int nTeam3 = GetPartyPlotFlag(oParty, sLawOrderPlot, COA_CITYGUARD_MARKET_SMUGGLER_TEAM_THREE_DEAD);
    int nTeam4 = GetPartyPlotFlag(oParty, sLawOrderPlot, COA_CITYGUARD_MARKET_SMUGGLER_TEAM_FOUR_DEAD);
    
    /*
    HSTTellAndPrint2("Team 1 = " + IntToString(nTeam1));
    HSTTellAndPrint2("Team 2 = " + IntToString(nTeam2));
    HSTTellAndPrint2("Team 3 = " + IntToString(nTeam3));
    HSTTellAndPrint2("Team 4 = " + IntToString(nTeam4));
    HSTTellAndPrint2("Sigrun meets Mischa = " + IntToString(nSigrunMeetsMischa));
    HSTTellAndPrint2("Mischa Trigger Active = " + IntToString(bMischaTriggerActive));
    */
    
    if (nTeam1 && nTeam2 && nTeam3 && nTeam4 && nSigrunMeetsMischa == 0 && bMischaTriggerActive == FALSE)
    {
        SetObjectActive(oMischaTrigger, TRUE);
        SetObjectActive(oMischa, TRUE);
    }
}