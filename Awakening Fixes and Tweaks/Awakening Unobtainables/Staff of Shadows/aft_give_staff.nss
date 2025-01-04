#include "utility_h"
#include "plt_aft_staff_shadows"

object oArea = GetArea(GetHero());
string sArea = GetTag(oArea);

object oGenlock = GetObjectByTag("genlock_emissary_off");
object oWeapon = GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oGenlock);  

object oHerren = GetObjectByTag("store_vgk100cr_herren");

int nStaffGiven = WR_GetPlotFlag("aft_staff_shadows", 0);

void main()
{
    if (!nStaffGiven && sArea == "int100ar_exterior" && !IsDead(oGenlock))
    {
        object oStaff = CreateItemOnObject(R"gxa_im_wep_mag_sta_pl2.uti", oGenlock);
        EquipItem(oGenlock, oStaff);
        RemoveItem(oWeapon);  
        
        oStaff = GetItemPossessedBy(oGenlock, "gxa_im_wep_mag_sta_pl2");
        if (IsObjectValid(oStaff)) 
        {
            WR_SetPlotFlag("aft_staff_shadows", 0, 1); 
        }
    }
    
    if (!nStaffGiven && (sArea == "vgk100ar_exterior") || sArea == "vgk101ar_exterior" || sArea == "vgk102ar_exterior")
    {
        CreateItemOnObject(R"gxa_im_wep_mag_sta_pl2.uti", oHerren);
        
        object oStaff = GetItemPossessedBy(oHerren, "gxa_im_wep_mag_sta_pl2");
        if (IsObjectValid(oStaff))
        {
            WR_SetPlotFlag("aft_staff_shadows", 0, 1);
        }
    }        
}
