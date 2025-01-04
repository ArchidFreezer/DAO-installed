#include "utility_h"

#include "plt_arl100pt_equip_militia"
#include "plt_arl130pt_recruit_dwyn"
#include "plt_arl150pt_tavern_drinks"
#include "plt_arl100pt_siege_prep"
#include "plt_arl100pt_activate_shale"
#include "plt_arl100pt_holy_amulet"

//Returns the current value of the morale of the militia in the Arl Eamon plot.
//Morale is determined by a number of actions of the player in preparing for the
//seige.
//Morale can range from -4 to +4. -2 or less is considered low, +2 or more is considered high.
int Arl_GetMilitiaMorale();
int Arl_GetMilitiaMorale()
{
    //Positive factors
    int bOwenWorking = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_OWEN_MAKING_WEAPONS);
    int bDwynHelping = WR_GetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_DWYN_HELPING);
    int bConvincedVictory = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_MURDOCK_CONVINCED_THEY_COULD_WIN);
    int bFreeDrinks = WR_GetPlotFlag(PLT_ARL150PT_TAVERN_DRINKS, ARL_TAVERN_DRINKS_MILITIA_DRINKS_FREE);

    //negative factors
    int bConvincedDefeat = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_MURDOCK_DISCOURAGE);
    int bOwenDead = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_MURDOCK_KNOWS_OWEN_DEAD);
    int bDwynDead = WR_GetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_MURDOCK_KNOWS_DWYN_DEAD);
    int bStashDenied = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_MURDOCK_DENIED_STASH);

    int nPositive = bOwenWorking + bDwynHelping + bConvincedVictory + bFreeDrinks;
    int nNegative = bConvincedDefeat + bOwenDead + bDwynDead + bStashDenied;

    int nMorale = nPositive - nNegative;
    return nMorale;
}


//Returns the current value of the morale of the knights in the Arl Eamon plot.
//Morale is determined by a number of actions of the player in preparing for the
//seige.
//Morale can range from -1 (low) to +1 (high)
/* Qwinn:  Disabled, no longer used
int Arl_GetKnightsMorale();
int Arl_GetKnightsMorale()
{
    //positive factors
    int bGaveAmulets = WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PERTH_HAS_AMULETS);
    int bSentShale = WR_GetPlotFlag(PLT_ARL100PT_ACTIVATE_SHALE, ARL_ACTIVATE_SHALE_SHALE_HELPING_PERTH);

    int nMorale = bGaveAmulets +  bSentShale;

    return nMorale;
}
*/



void ARL_SiegeGiveItemAndEquip(resource rItem, object oCreature, int nEquipmentSlot, int nWeaponSet = INVALID_WEAPON_SET, int nStackSize = 1);
void ARL_SiegeGiveItemAndEquip(resource rItem, object oCreature, int nEquipmentSlot, int nWeaponSet = INVALID_WEAPON_SET, int nStackSize = 1)
{
    if (rItem != INVALID_RESOURCE)
    {
        object oItem = UT_AddItemToInventory(rItem, nStackSize, oCreature);
        EquipItem(oCreature, oItem, nEquipmentSlot, nWeaponSet);
        // Qwinn added:
        SetItemDroppable(oItem,FALSE);
        SetItemIrremovable(oItem,TRUE);
    }
}

void ARL_SiegeEquipMilitiaMember(object oCreature, resource rMilitiaMoraleAmulet = INVALID_RESOURCE);
void ARL_SiegeEquipMilitiaMember(object oCreature, resource rMilitiaMoraleAmulet = INVALID_RESOURCE)
{
    int bOwenWorking = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_OWEN_MAKING_WEAPONS);
    int bStashGiven = WR_GetPlotFlag(PLT_ARL100PT_EQUIP_MILITIA, ARL_EQUIP_MILITIA_MURDOCK_GIVEN_STASH);

    resource rMilitiaBoots = INVALID_RESOURCE;
    resource rMilitiaArmor = INVALID_RESOURCE;
    resource rMilitiaGloves = INVALID_RESOURCE;
    resource rMilitiaHelmet = INVALID_RESOURCE;
    resource rMiltiaWeapon = INVALID_RESOURCE;
    resource rMiltiaBow = INVALID_RESOURCE;

    if (bOwenWorking == TRUE)
    {
        rMilitiaBoots = ARL_R_IT_MILITIA_BOOTS_GOOD;
        rMilitiaArmor = ARL_R_IT_MILITIA_ARMOR_GOOD;
        rMilitiaGloves = ARL_R_IT_MILITIA_GLOVES_GOOD;
        rMilitiaHelmet = ARL_R_IT_MILITIA_HELMET_GOOD;
        rMiltiaWeapon = ARL_R_IT_MILITIA_WEAPON_GOOD;
        rMiltiaBow = ARL_R_IT_MILITIA_BOW_GOOD;
    }
    else if (bStashGiven == TRUE)
    {
        rMilitiaBoots = ARL_R_IT_MILITIA_BOOTS_STANDARD;
        rMilitiaArmor = ARL_R_IT_MILITIA_ARMOR_STANDARD;
        rMilitiaGloves = ARL_R_IT_MILITIA_GLOVES_STANDARD;
        rMilitiaHelmet = ARL_R_IT_MILITIA_HELMET_STANDARD;
        rMiltiaWeapon = ARL_R_IT_MILITIA_WEAPON_STANDARD;
        rMiltiaBow = ARL_R_IT_MILITIA_BOW_STANDARD;
    }

    ARL_SiegeGiveItemAndEquip(rMilitiaMoraleAmulet, oCreature, INVENTORY_SLOT_NECK);
    ARL_SiegeGiveItemAndEquip(rMilitiaBoots, oCreature, INVENTORY_SLOT_BOOTS);
    ARL_SiegeGiveItemAndEquip(rMilitiaArmor, oCreature, INVENTORY_SLOT_CHEST);
    ARL_SiegeGiveItemAndEquip(rMilitiaGloves, oCreature, INVENTORY_SLOT_GLOVES);
    ARL_SiegeGiveItemAndEquip(rMilitiaHelmet, oCreature, INVENTORY_SLOT_HEAD);
    // Version 3.5 - for whatever reason, switch weapon set stopped working and they would not switch to it as weapon set 1
    // Bows are now weapon set 0.  They do still switch to other weapon if engaged in melee.
    //ARL_SiegeGiveItemAndEquip(rMiltiaWeapon, oCreature, INVENTORY_SLOT_MAIN, 0);
    //ARL_SiegeGiveItemAndEquip(rMiltiaBow, oCreature, INVENTORY_SLOT_MAIN, 1);
    ARL_SiegeGiveItemAndEquip(rMiltiaBow, oCreature, INVENTORY_SLOT_MAIN, 0);
    ARL_SiegeGiveItemAndEquip(rMiltiaWeapon, oCreature, INVENTORY_SLOT_MAIN, 1);

    // Qwinn added
    SetLocalInt(oCreature, FLAG_STOLEN_FROM, TRUE);
    SetLocalInt(oCreature, "TS_TREASURE_GENERATED", -1);
}
