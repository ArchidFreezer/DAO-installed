#include "plt_mush_plot_dlcs"
#include "wrappers_h"

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    string sArea = GetTag(oArea);
    int nPlaced;

    if (sArea == "ltl100ar_deep_road_entrance")
    {
        nPlaced = WR_GetPlotFlag("mush_plot_dlcs", 0);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(52.63, 243.28, -21.57), -90.0));
            WR_SetPlotFlag("mush_plot_dlcs", 0, 1);
        }
    }

    if (sArea == "ltl200ar_kal_hirol_entrance")
    {
        nPlaced = WR_GetPlotFlag("mush_plot_dlcs", 1);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(54.98, 48.78, -8.63), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(185.72, 38.25, -7.5), -90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(109.86, 81.13, -8.94), 90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(129.02, 142.01, 1.27), 0.0));
            WR_SetPlotFlag("mush_plot_dlcs", 1, 1);
        }
    }

    if (sArea == "ltl400ar_kal_hirol_smith")
    {
        nPlaced = WR_GetPlotFlag("mush_plot_dlcs", 2);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(45.61, -50.1, -5.17), 180.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(71.53, -35.48, -10.8), 90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(42.96, 98.58, -16.54), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(-46.78, 19.26, 0.61), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush4.utp", Location(oArea, Vector(-14.42, 74.67, 0.25), -90.0));
            WR_SetPlotFlag("mush_plot_dlcs", 2, 1);
        }
    }

    if (sArea == "ltl300ar_kal_hirol_upper")
    {
        nPlaced = WR_GetPlotFlag("mush_plot_dlcs", 3);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(223.54, 48.89, -15.84), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(241.61, -53.77, -12.06), -90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(183.58, -106.86, -10.58), 180.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(21.43, 40.41, 6.96), 90.0));
            WR_SetPlotFlag("mush_plot_dlcs", 3, 1);
        }
    }

    if (sArea == "vgk330ar_deeproads")
    {
        nPlaced = WR_GetPlotFlag("mush_plot_dlcs", 4);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-135.8, -11.35, 0.6), 180.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-61.07, -37.08, -1.29), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush4.utp", Location(oArea, Vector(-71.1, 11.8, -0.98), 0.0));
            WR_SetPlotFlag("mush_plot_dlcs", 4, 1);
        }
    }

    if (sArea == "trp200ar_silverite_mine")
    {
        nPlaced = WR_GetPlotFlag("mush_plot_dlcs", 5);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(19.7, -193.5, 0.54), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-99.4, -57.82, -0.55), 90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush4.utp", Location(oArea, Vector(71.31, -125.79, -0.56), 90.0));
            WR_SetPlotFlag("mush_plot_dlcs", 5, 1);
        }
    }
    
    if (sArea == "str300ar_elven_ruins")
    {
        nPlaced = WR_GetPlotFlag("mush_plot_dlcs", 6);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush5.utp", Location(oArea, Vector(-30.5361,-50.2337,-0.000340901), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush4.utp", Location(oArea, Vector(-51.87, 13.62, 0.17), 180.0));
            WR_SetPlotFlag("mush_plot_dlcs", 6, 1);
        }
    }
    
    if (sArea == "str400ar_cadash_thaig")
    {
        nPlaced = WR_GetPlotFlag("mush_plot_dlcs", 7);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(82.94, 61.85, 0.41), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(163.67, 74.68, 1.26), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush4.utp", Location(oArea, Vector(156.25, 89.52, 0.72), -90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush5.utp", Location(oArea, Vector(242.45, 78.97, 1.75), 90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(111.91, 59.78, 0.86), 90.0));
            WR_SetPlotFlag("mush_plot_dlcs", 7, 1);
        }
    }
}