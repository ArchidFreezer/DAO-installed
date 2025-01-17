// Test script - currently gets armour for testing.
//
#include "wrappers_h"
#include "utility_h"

void main()
{
    object oPC = GetHero();
    object oVaylise = UT_AddItemToInventory(R"bpsk_vaylise_armor.uti");
    object oAmulet = UT_AddItemToInventory(R"bpsk_amulet_hi.uti");
    object oWeapon = UT_AddItemToInventory(R"bpsk_crane_low.uti");
    oWeapon = UT_AddItemToInventory(R"bpsk_crow_low.uti");
    oWeapon = UT_AddItemToInventory(R"bpsk_ashyera_dagger.uti");
    oWeapon = UT_AddItemToInventory(R"bpsk_hjorrmikill_low.uti");
    oWeapon = UT_AddItemToInventory(R"bpsk_knotwood_staff_low.uti");
    oWeapon = UT_AddItemToInventory(R"bpsk_thunderer.uti");
    DisplayFloatyMessage(oPC,"Items added to inventory.",FLOATY_MESSAGE,0xff0000,10.0);

}