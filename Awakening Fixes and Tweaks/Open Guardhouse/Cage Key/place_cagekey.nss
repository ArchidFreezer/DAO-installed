#include "utility_h" 
#include "plt_jacen_key"

void main()
{
    int nKeyMoved = WR_GetPlotFlag("jacen_key", 0);
    int nGuardsQuest = WR_GetPlotFlag("EA0188BF295F43B08202E9E8DDEAC2F9", 10);  // player is locked out of smuggler questline
    object oArea = GetObjectByTag("coa100ar_city");
    location lKeySatchel = Location(oArea, Vector(56.5201,202.794,26.6337), 0.0);
    
    if (!nKeyMoved && nGuardsQuest)
    {
        object oLieutenant = GetObjectByTag("coa100cr_lieutenant");
        object oKey = GetItemPossessedBy(oLieutenant, "coa100im_sniper_cage_key");
        object oSatchel = CreateObject(OBJECT_TYPE_PLACEABLE, R"aft_keysatchel.utp", lKeySatchel);
        SetLocation(oSatchel, lKeySatchel);
        
        MoveItem(oLieutenant, oSatchel, oKey); 
        
        WR_SetPlotFlag("jacen_key", 0, 1);
    }                                     
}
    