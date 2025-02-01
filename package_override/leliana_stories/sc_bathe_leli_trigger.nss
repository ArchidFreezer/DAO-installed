#include "wrappers_h"
#include "plt_genpt_app_leliana"

void main()
{
     if(WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_ACTIVE)){

        //trigger flower Placement
        object oArea1 = GetObjectByTag("cam100ar_camp_plains"); //Camp
        vector vFlower = Vector(142.621,153.453,0.457722);
        location flowerLocation = Location(oArea1, vFlower, 0.0);
        object Flower = CreateObject(
                    OBJECT_TYPE_PLACEABLE,
                    R"leli_bath_trig.utp",
                    flowerLocation
                    );
     }
}