//////////////////////////////////////////////////////////////////
//
// Description: WRK_RESPEC merchant vendor character spawning script
// Owner: Peter `weriK` Kovacs
// Date: 11/10/2009 @ 3:08 PM
//
// Quiet a lot borrowed from Craig Graff's Storage Chest mod
// to make this work. Including one of the XLS files for calling
// this spawn script upon loading of the camp area. He knows sekretz! :)
//
/////////////////////////////////////////////////////////////////
#include "af_respec_utility_h"

void main()
{
    object oCharacter   = GetMainControlled();
    object oVendor      = UT_GetNearestObjectByTag(oCharacter, AF_CRE_RESPEC_RAVEN);
    object oArea        = GetArea(oCharacter);

    // Retrieve the area tag
    string sLocationTag = GetTag(oArea);

    afLogDebug("Entering new area: " + sLocationTag, AF_LOGGROUP_CHAR_RESPEC);
    // If there is no vendor spawned yet in this area, do that now
    if (!IsObjectValid(oVendor)) {
        afLogDebug("Respec raven not found", AF_LOGGROUP_CHAR_RESPEC);
        // King's Camp at Ostagaar, Day & Night, Behind the fire next to Duncan
        if ( FindSubString( sLocationTag, "pre100ar_kings_camp", 0 ) >= 0 ) {
            location lSpawn = Location(oArea, Vector(562.17, 498.52, -0.49), -92.5);
            object oTest    = CreateObject(OBJECT_TYPE_CREATURE, AF_CRR_RESPEC_RAVEN, lSpawn);
        }
        // Outside of Flemeth's hut, next to the old statue
        else if ( sLocationTag == "pre210ar_flemeths_hut_ext" ) {
            location lSpawn = Location(oArea, Vector(209.53, 509.91, -0.68), 50.0);
            object oTest    = CreateObject(OBJECT_TYPE_CREATURE, AF_CRR_RESPEC_RAVEN, lSpawn);
        }
        // In Lothering, near the tawern on the fence pole
        else if ( sLocationTag == "lot100ar_lothering" ) {
            location lSpawn = Location(oArea, Vector(309.39, 254.3, 0.72), -94.1);
            object oTest    = CreateObject(OBJECT_TYPE_CREATURE, AF_CRR_RESPEC_RAVEN, lSpawn);
            SetPosition(oTest, Vector(308.79, 254.4, 2.72), FALSE);
        }
        // In Redcliffe Village, at the town square next to a cart Day & Night
        else if ( sLocationTag == "arl100ar_redcliffe_village" || sLocationTag == "arl101ar_redcliffe_night" ) {
            location lSpawn = Location(oArea, Vector(264.82, 311.54, 1.59), 70.0);
            object oTest    = CreateObject(OBJECT_TYPE_CREATURE, AF_CRR_RESPEC_RAVEN, lSpawn);
            SetPosition(oTest, Vector(265.3, 311.74, 3.59), FALSE);
        }
        // In Denerim Market District, on top of three barrels
        else if ( sLocationTag == "den200ar_market" ) {
            location lSpawn = Location(oArea, Vector(72.14, 45.76, 0.0), -147.0);
            object oTest    = CreateObject(OBJECT_TYPE_CREATURE, AF_CRR_RESPEC_RAVEN, lSpawn);
            SetPosition(oTest, Vector(71.6, 45.6, 0.97), FALSE);
        }
        // In the Daligh Camp, on the pile of wood next to the smith
        else if ( FindSubString( sLocationTag, "_dalish_camp", 0 ) >= 0 ) {
            location lSpawn = Location(oArea, Vector(265.44, 247.93, 6.31), -80.0);
            object oTest    = CreateObject(OBJECT_TYPE_CREATURE, AF_CRR_RESPEC_RAVEN, lSpawn);
            SetPosition(oTest, Vector(264.74, 247.8, 7.85), FALSE);
        }
        // In the Circle of Magi docks, on the wooden poles near the fire
        else if ( sLocationTag == "cir100ar_docks" ) {
            location lSpawn = Location(oArea, Vector(128.41, 191.2, 1.0), 180.0);
            object oTest    = CreateObject(OBJECT_TYPE_CREATURE, AF_CRR_RESPEC_RAVEN, lSpawn);
            SetPosition(oTest, Vector(128.55, 190.6, 1.52), FALSE);
        }
        // Frostback Mountain Pass, near the white striped tent
        else if ( sLocationTag == "orz100ar_mountain_pass" ) {
            location lSpawn = Location(oArea, Vector(219.0, 345.0, 13.4), 50.0);
            object oTest    = CreateObject(OBJECT_TYPE_CREATURE, AF_CRR_RESPEC_RAVEN, lSpawn);
        }
        // The three camp areas, next to the fallen tree on top of a rock
        else if ( FindSubString( sLocationTag, "ar_camp_", 0 ) >= 0 ) {
            // First we set the location where we want to position it
            // We want to put it in the same area the character is now
            // At X = 115.77, Y = 115.68, Z = -0.94 coordinates
            // Rotated by an angle of -85 degrees
            location lSpawn = Location(GetArea(oCharacter), Vector(115.77, 115.68, -0.94), -85.0);

            // We create a creature object at the location
            CreateObject(OBJECT_TYPE_CREATURE, AF_CRR_RESPEC_RAVEN, lSpawn);
        }
    }
}