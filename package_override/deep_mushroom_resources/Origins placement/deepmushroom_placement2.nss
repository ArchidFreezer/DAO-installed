#include "plt_mush_plot"
#include "wrappers_h"

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    string sArea = GetTag(oArea);
    int nPlaced;

    if (sArea == "ntb340ar_lair_of_werewolves")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 9);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(-204.276,143.188,-3.45156), 90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush3.utp", Location(oArea, Vector(-173.237,4.15403,-16.4824), 0.0));
            WR_SetPlotFlag("mush_plot", 9, 1);
        }
    }

    if (sArea == "ran210ar_forest_spiders")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 10);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(124.246,93.2881,1.65392), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(129.409,139.173,3.83757), 90.0));
            WR_SetPlotFlag("mush_plot", 10, 1);
        }
    }

    if (sArea == "ran250ar_forest_jowan")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 11);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(129.736,52.343,-8.71824), 0.0));
            object oDeathroot = GetObjectByTag("genip_herb_04_autoloot", 0);
            SetLocation(oDeathroot, Location(oArea, Vector(110.598,68.3893,-8.88755), 0.0));
            WR_SetPlotFlag("mush_plot", 11, 1);
            
        }
    }

    if (sArea == "ran270ar_forest_ambush")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 12);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(84.8845,143.111,0.344009), -90.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(129.264,127.751,3.56325), 0.0));
            WR_SetPlotFlag("mush_plot", 12, 1);
        }
    }

    if (sArea == "ran290ar_forest_ntb_steal")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 13);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(90.277,51.6026,0.212399), 0.0));
            WR_SetPlotFlag("mush_plot", 13, 1);
        }
    }

    if (sArea == "ran310ar_plains_beasts")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 14);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(351.73,145.293,17.7352), 0.0));
            WR_SetPlotFlag("mush_plot", 14, 1);
        }
    }

    if (sArea == "ran520ar_hw_army_elves")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 15);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(351.723,145.307,17.7359), 0.0));
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(315.518,144.35,16.0239), 180.0));
            WR_SetPlotFlag("mush_plot", 15, 1);
        }
    }

    if (sArea == "ran530ar_hw_army_werewolves")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 16);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush1.utp", Location(oArea, Vector(351.523,145.262,17.7208), 0.0));
            WR_SetPlotFlag("mush_plot", 16, 1);
        }
    }

    if (sArea == "orz100ar_mountain_pass")
    {
        nPlaced = WR_GetPlotFlag("mush_plot", 17);
        if (!nPlaced)
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, R"genip_herb_deepmush2.utp", Location(oArea, Vector(204.444,294.726,6.04715), 0.0));
            WR_SetPlotFlag("mush_plot", 17, 1);
        }
    }
}

