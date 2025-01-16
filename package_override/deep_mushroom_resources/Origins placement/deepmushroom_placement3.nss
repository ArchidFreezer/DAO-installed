#include "plt_mush_plot"
#include "wrappers_h"

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    string sArea = GetTag(oArea);
    int nPlaced;

    if (sArea == "orz230ar_gangsters_hideout")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 18);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(97.3649,-233.399,-10.0739), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(100.271,-128.191,-0.0107007), 90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(148.796,-129.986,-1.70084), 0.0));
            WR_SetPlotFlag("mush_plot", 18, 1);
        }
    }
    
    if (sArea == "orz510ar_caridins_cross")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 19);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-159.624,-57.7068,0.465045), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-210.533,-98.7832,0.339684), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(163.533,-257.926,0.151949), 180.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(35.1716,-208.414,0.00457937), -90.0));
            WR_SetPlotFlag("mush_plot", 19, 1);
        }
    } 
    
    if (sArea == "orz520ar_aeducan_thaig")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 20);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-360.764,8.5136,4.31807), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-304.361,-41.7938,8.33502), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(-305.047,-112.409,8.17671), 180.0));
            WR_SetPlotFlag("mush_plot", 20, 1);
        }
    }
    
    if (sArea == "orz530ar_ortan_thaig")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 21);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-155.128,-318.828,-0.168755), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-19.3497,-198.602,0.566611), -90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(-90.3574,-168.007,0.7823), 90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(69.4126,-70.7185,-18.9564), 0.0));
            WR_SetPlotFlag("mush_plot", 21, 1);
        }
    }
    
    if (sArea == "orz540ar_anvil_of_the_void")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 22);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(106.874,-8.56824,-15.4695), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(191.472,-55.7364,-15.9701), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(270.784,100.157,-15.1926), 90.0));
            WR_SetPlotFlag("mush_plot", 22, 1);
        }
    } 
    
    if (sArea == "orz550ar_dead_trenches")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 23);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-55.106,-3.97282,-5.04237), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(203.036,-67.5324,5.0), -90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(255.094,-143.375,4.65319), 0.0)); 
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(412.158,122.62,8.97722), 180.0)); 
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(341.157,55.8712,4.80511), 90.0));
            WR_SetPlotFlag("mush_plot", 23, 1);
        }
    }
     
    if (sArea == "shl300ar_cadash_thaig")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 24);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(82.94, 61.85, 0.41), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(163.67, 74.68, 1.26), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(156.25, 89.52, 0.72), -90.0)); 
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(164.13, 99.86, 0.67), 0.0)); 
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(242.45, 78.97, 1.75), 90.0)); 
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(111.91, 59.78, 0.86), 90.0));
            WR_SetPlotFlag("mush_plot", 24, 1);
        }
    }

    if (sArea == "kcc300ar_tunnel")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 25);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(-67.73, -35.44, 0.06), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-44.23, 47.39, 0.1), 90.0));
            WR_SetPlotFlag("mush_plot", 25, 1);
        }
    }
}