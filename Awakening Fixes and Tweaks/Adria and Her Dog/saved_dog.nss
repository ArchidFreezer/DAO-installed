#include "wrappers_h"

void main()
{
    object oKeep = GetArea(OBJECT_SELF);
    string sKeep = GetTag(oKeep);
    vector vDog = Vector(66.96, 178.94, 3.63);

    int nDogCured = WR_GetPlotFlag("90D303BF94CC400A84B4B3B44A7DF42B", 5); // dog was "cared for"
    int nKeep0 = WR_GetPlotFlag("D037766C5BDD4B15B588FFB72E7FAEC1", 0);
    int nKeep1 = WR_GetPlotFlag("D037766C5BDD4B15B588FFB72E7FAEC1", 1);
    int nKeep2 = WR_GetPlotFlag("D037766C5BDD4B15B588FFB72E7FAEC1", 2);
    int nDeep3Started = WR_GetPlotFlag("CD313C9BA0E841E8A8699963A7ECF175", 7); // 3rd deep roads quest started (for time)
    
    /* there are 3 versions of the keep exterior. 
    I think:  0 (raining) = first exit from interior
              1 (sun to south) = 0-1 main quests done
              2 (sun to east) = 2+ main quests done
    but idk for sure */
    
    if (nDeep3Started && nDogCured)
    {
        if (sKeep == "vgk100ar_exterior" && !nKeep0)
        {
            CreateObject(OBJECT_TYPE_CREATURE, R"dog_mabari_cured.utc", Location(oKeep, vDog, 89.18));
            WR_SetPlotFlag("D037766C5BDD4B15B588FFB72E7FAEC1", 0, TRUE);
        }

        if (sKeep == "vgk101ar_exterior" && !nKeep1)
        {
            CreateObject(OBJECT_TYPE_CREATURE, R"dog_mabari_cured.utc", Location(oKeep, vDog, 89.18));
            WR_SetPlotFlag("D037766C5BDD4B15B588FFB72E7FAEC1", 1, TRUE);
        }

     if (sKeep == "vgk102ar_exterior" && !nKeep2)
        {
            CreateObject(OBJECT_TYPE_CREATURE, R"dog_mabari_cured.utc", Location(oKeep, vDog, 89.18));
            WR_SetPlotFlag("D037766C5BDD4B15B588FFB72E7FAEC1", 2, TRUE);
        }
    }
}
