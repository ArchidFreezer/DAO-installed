#include "wrappers_h"  

int nBridgeFail = WR_GetPlotFlag("A1A5BB98E378445785E4F1FA2841948D", 3); // bridge given to Liza, persuading Derren fails
object oDerren = GetObjectByTag("vgk215cr_derren"); 
object oGuy = GetObjectByTag("vgk215cr_guy");
object oCrony = GetObjectByTag("vgk215cr_esmerelle_crony");

void main()
{
    SetCreatureRank(oGuy, 3);
    SetCreatureRank(oCrony, 2);
    
    if (nBridgeFail)                                   // Setting Derren active if Liza given bridge and persuade attempt failed
    {                                                  // default: shows up if not given bridge and no persuade attempt made
        SetObjectActive(oDerren, 1);
        SetTeamId(oDerren, 40202);
    }
}