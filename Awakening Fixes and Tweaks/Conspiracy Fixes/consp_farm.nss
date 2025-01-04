#include "wrappers_h"  
#include "plt_farm_replacements"

int nPeopleSwapped = WR_GetPlotFlag("farm_replacements", 0);
int nTamraSource = WR_GetPlotFlag("30B910B5E129485294CB26EBD4AB7A02", 14);  // Tamra involved
int nTemmReleased = WR_GetPlotFlag("D2BCCEE372A748EA961BC5816274A762", 0);  // Temmerly released 
int nTemmExecuted = WR_GetPlotFlag("D2BCCEE372A748EA961BC5816274A762", 1);  // Temmerly executed 
int nThroneDone = WR_GetPlotFlag("EB385F05039244BBAE059162B68ACD43", 1);    // throne room assassination attempt done
int nBridgeDerren = WR_GetPlotFlag("A1A5BB98E378445785E4F1FA2841948D", 1);  // bridge given to Derren 
int nBridgePC = WR_GetPlotFlag("A1A5BB98E378445785E4F1FA2841948D", 4);      // Warden claimed bridge
int nGuyExecuted = WR_GetPlotFlag("ECA1A8213F68402A93F932B99E57F0A6", 1);   // Guy executed
int nGuyPersuaded = WR_GetPlotFlag("ECA1A8213F68402A93F932B99E57F0A6", 2);  // Guy persuaded
int nOrlesian = WR_GetPlotFlag("A29AAAF18A7A42F38A4A6CED9B689AE5", 0);      // Orlesian warden

object oTemm = GetObjectByTag("vgk215cr_temmerly");                         // default is INACTIVE
object oLiza = GetObjectByTag("vgk215cr_liza");                             // creature with her tag must be present for dialog/combat trigger
object oGuy = GetObjectByTag("vgk215cr_guy");                               // default is ACTIVE, but really shouldn't be
object oCrony = GetObjectByTag("vgk215cr_esmerelle_crony");                 // creature with his tag must be present for dialog/combat trigger
object oCrow = GetObjectByTag("vgk215cr_crow_assassin");                    // replace with assassin after throne attempt
object oMerc = GetObjectByTag("merc_human_archer", 0);                      // replace with Crow before throne attempt, also he's at rank 13
object oMerc2 = GetObjectByTag("merc_human_archer", 1);                     // replace with Crow before throne attempt

location lTemmLoc = GetLocation(oTemm);
location lLizaLoc = GetLocation(oLiza);
location lGuyLoc = GetLocation(oGuy);
location lCronyLoc = GetLocation(oCrony);
location lCrowLoc = GetLocation(oCrow);
location lMercLoc = GetLocation(oMerc);
location lMerc2Loc = GetLocation(oMerc2);

object oTemmRepl;
object oLizaRepl;
object oGuyRepl;
object oCronyRepl;
object oCrowRepl;
object oMercRepl;
object oMerc2Repl;

void main()
{  
    // because of dialog trigger, Liza & Timothy must be there (or replacements with the same tag)      
    if (!nPeopleSwapped)
    {
        if (nThroneDone)
        {
            Safe_Destroy_Object(oLiza);
            Safe_Destroy_Object(oCrony);
            oLizaRepl = CreateObject(OBJECT_TYPE_CREATURE, R"vgk215cr_liza_replacement.utc", lLizaLoc); 
            oCronyRepl = CreateObject(OBJECT_TYPE_CREATURE, R"vgk215cr_crony_replacement.utc", lCronyLoc);
            SetTeamId(oLizaRepl, 40004);
            SetTeamId(oCronyRepl, 40004);
        
            // replace Temmerly if he was present at throne room, or was executed
            if (nTemmReleased || nTemmExecuted || !nTamraSource)
            {
                Safe_Destroy_Object(oTemm);
                oTemmRepl = CreateObject(OBJECT_TYPE_CREATURE, R"vgk215cr_temm_replacement.utc", lTemmLoc);
                SetTeamId(oTemmRepl, 40004);
            }
        
            // replace Guy if he was present at throne room or was executed, otherwise just remove
            Safe_Destroy_Object(oGuy);        
            if (nOrlesian && (!nGuyPersuaded || nGuyExecuted))
            {
                oGuyRepl = CreateObject(OBJECT_TYPE_CREATURE, R"vgk215cr_guy_replacement.utc", lGuyLoc);
                SetTeamId(oGuyRepl, 40004);
            }
        
            // finally, replace Crow assassin with mercenary
            Safe_Destroy_Object(oCrow);
            oCrowRepl = CreateObject(OBJECT_TYPE_CREATURE, R"merc_human_captain.utc", lCrowLoc);
            SetTeamId(oCrowRepl, 40004); 
        
            // and fix that one mercenary's rank
            SetCreatureRank(oMerc, 2);
        }
        else
        {
            // if Liza got the bridge, or 'A Day in Court' hasn't happened yet, replace her
            if (!nBridgeDerren && !nBridgePC)
            {
                Safe_Destroy_Object(oLiza);
                oLizaRepl = CreateObject(OBJECT_TYPE_CREATURE, R"vgk215cr_liza_replacement.utc", lLizaLoc);
                SetTeamId(oLizaRepl, 40004); 
            }
        
            // activate Temmerly if he was released during court, or his case didn't/won't come up
            if (nTemmReleased || !nTamraSource)
            {
                SetObjectActive(oTemm, TRUE);
                SetTeamId(oTemm, 40004);
            }
            // if he's executed/imprisoned, or could still appear in court, replace him
            else                
            {
                Safe_Destroy_Object(oTemm);
                oTemmRepl = CreateObject(OBJECT_TYPE_CREATURE, R"vgk215cr_temm_replacement.utc", lTemmLoc);
                SetTeamId(oTemmRepl, 40004);
            }
        
            // remove Guy if he wouldn't be at the throne room
            if (nGuyExecuted || nGuyPersuaded || !nOrlesian)
            {
                Safe_Destroy_Object(oGuy);
                // replace him with Morag if he was executed
                if (nGuyExecuted)
                {
                    oGuyRepl = CreateObject(OBJECT_TYPE_CREATURE, R"vgk215cr_guy_crony.utc", lGuyLoc);
                    SetTeamId(oGuyRepl, 40004);
                }
            }
        
            // finally, replace mercenaries with Crows
            Safe_Destroy_Object(oMerc);
            Safe_Destroy_Object(oMerc2);
            oMercRepl = CreateObject(OBJECT_TYPE_CREATURE, R"merc_replacement.utc", lMercLoc);
            oMerc2Repl = CreateObject(OBJECT_TYPE_CREATURE, R"merc2_replacement.utc", lMerc2Loc);
            SetTeamId(oMercRepl, 40004);
            SetTeamId(oMerc2Repl, 40004);
        }
        
        WR_SetPlotFlag("farm_replacements", 0, 1);
    }
}