#include "plt_mush_plot"
#include "wrappers_h"

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    string sArea = GetTag(oArea);
    int nPlaced;

    if (sArea == "lot100ar_lothering")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 0);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(384.065,304.404,1.02725), 0.0));
            WR_SetPlotFlag("mush_plot", 0, 1);
        }
    }

    if (sArea == "bhm250ar_spider_cave")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 1);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(-6.58635,-94.841,-0.0596612), 0.0));
            WR_SetPlotFlag("mush_plot", 1, 1);
        }
    }

    if (sArea == "bed110ar_elven_ruins")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 2);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(-30.5361,-50.2337,-0.000340901), 0.0));
            WR_SetPlotFlag("mush_plot", 2, 1);
        }
    }

    if (sArea == "bdc120ar_berahts_hideout")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 3);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(143.943,-208.502,-7.92654), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(97.0657,-123.909,-0.311534), 90.0));
            WR_SetPlotFlag("mush_plot", 3, 1);
        }
    }

    if (sArea == "bdn200ar_ruined_taig")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 4);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(-361.444,8.29197,4.39959), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(-476.43,-68.3062,-0.0392104), 90.0));
            WR_SetPlotFlag("mush_plot", 4, 1);
        }
    }

    if (sArea == "bdn400ar_deep_road_outskirt")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 5);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(35.1193,-85.3455,0.29706), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(75.7985,-23.7636,0.0431643), 180.0));
            WR_SetPlotFlag("mush_plot", 5, 1);
        }
    }

    if (sArea == "urn210ar_wyrmlings_lair")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 6);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(23.3287,375.325,9.25462), 90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-200.618,313.43,22.8219), 0.0));
            WR_SetPlotFlag("mush_plot", 6, 1);
        }
    }

    if (sArea == "ntb310ar_top_level")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 7);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(23.3287,375.325,9.25462), 0.0));
            WR_SetPlotFlag("mush_plot", 7, 1);
        }
    }

    if (sArea == "ntb330ar_lair_of_the_undead")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 8);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-204.968,200.116,-10.0003), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(6.82043,259.819,-5.01709), -90.0));
            WR_SetPlotFlag("mush_plot", 8, 1);
        }
    }
}

