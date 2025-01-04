#include "wrappers_h"
#include "plt_gxa_aer"

void main()
{
    object oModule = GetModule();     
    string sModule = GetName(oModule);
    string sString = GetLocalString(GetModule(),"RUNSCRIPT_VAR");                          
    
    int nResetDone = WR_GetPlotFlag("gxa_aer", 0);
    
    if (sModule == "DAO_PRC_EP_1" && (sString == "go" || !nResetDone))
    {    
        SetLocalInt(oModule, "RAND_PLAINS_ENCOUNTERS_SET", 0);      // plains
        SetLocalInt(oModule, "RAND_FOREST_ENCOUNTERS_SET", 0);      // forest
        SetLocalInt(oModule, "RAND_HIGHWAY_ENCOUNTERS_SET", 0);     // farm
        SetLocalInt(oModule, "RAND_MOUNTAIN_ENCOUNTERS_SET", 0);    // canyon
        SetLocalInt(oModule, "RAND_UNDERGROUND_ENCOUNTERS_SET", 0); // beach 
        
        WR_SetPlotFlag("gxa_aer", 0, 1);
    }
}
