// This script is called from dialogue, when Knives decides to take her swords by force.
// It recreates the Templars team as hostile combatants, then sets them all to attack the PC.
//
#include "utility_h"
#include "wrappers_h"
#include "plt_bp_spiders_knives"

void main()
{

        object oPC = GetHero();
        // Knives attacks
        object oKnives = GetObjectByTag("bpsk_knives");
        SetPlotGiver(oKnives,FALSE);
        UT_TeamGoesHostile(9);
        // Recreate the Templars - they may not all be present, but Bryant always is
        object oBryant = GetObjectByTag("lot110cr_bryant");
        location lBryant = GetLocation(oBryant);
        WR_SetObjectActive(oBryant,FALSE);
        oBryant = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_bryant.utc",lBryant);
        AddCommand(oBryant,CommandAttack(oPC));

        object oVaral = GetObjectByTag("lot110cr_templar");
        if (IsObjectValid(oVaral))
        {
            location lVaral = GetLocation(oVaral);
            WR_SetObjectActive(oVaral,FALSE);
            oVaral = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_varal.utc",lVaral);
        }else{
            DisplayFloatyMessage(oPC,"Bryant not valid!",FLOATY_MESSAGE,0xff0000,10.0);
            location lVaral = GetLocation(oBryant);
            oVaral = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_varal.utc",lVaral);
        }
        AddCommand(oVaral,CommandAttack(oPC));

        object oMatron = GetObjectByTag("lot110cr_matronguard");
        location lMatron = GetLocation(oMatron);
        WR_SetObjectActive(oMatron,FALSE);
        oMatron = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_matron_guard.utc",lMatron);
        AddCommand(oMatron,CommandAttack(oPC));
        oMatron = GetObjectByTag("lot110cr_matronguard_2");
        lMatron = GetLocation(oMatron);
        WR_SetObjectActive(oMatron,FALSE);
        oMatron = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_matron_guard.utc",lMatron);
        AddCommand(oMatron,CommandAttack(oPC));

        object oTemplar1 = GetObjectByTag("lot110cr_templar");
        if (IsObjectValid(oTemplar1))
        {
            location lTemplar1 = GetLocation(oTemplar1);
            WR_SetObjectActive(oTemplar1,FALSE);
            oTemplar1 = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_templar.utc",lTemplar1);
        }else{
            location lTemplar1 = GetLocation(GetObjectByTag("mp_lot110cr_templar_0"));
            oTemplar1 = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_templar.utc",lTemplar1);
        }
        AddCommand(oTemplar1,CommandAttack(oPC));
        object oTemplar2 = GetObjectByTag("lot110cr_generictemplar");
        if (IsObjectValid(oTemplar2))
        {
            location lTemplar2 = GetLocation(oTemplar2);
            WR_SetObjectActive(oTemplar2,FALSE);
            oTemplar2 = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_templar.utc",lTemplar2);
        }else{
            location lTemplar2 = GetLocation(GetObjectByTag("mp_lot110cr_generictemplar_0"));
            oTemplar2 = CreateObject(OBJECT_TYPE_CREATURE,R"bpsk_templar.utc",lTemplar2);
        }
        AddCommand(oTemplar2,CommandAttack(oPC));
        UT_TeamGoesHostile(8);
}