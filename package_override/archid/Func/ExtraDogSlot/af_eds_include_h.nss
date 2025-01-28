#include "ability_h"
#include "ability_summon_h"
#include "af_eds_constants_h"
#include "af_logging_h"
#include "sys_rewards_h"

const int TABLE_PARTY_PICKER = 113;

// =============================================================
// UTILITIES METHODS
// =============================================================
string gameModeToString(int gm)
{
    string sGameMode = "UNKNOWN";
    switch (gm) {
        case GM_CHARGEN:
            sGameMode = "GM_CHARGEN";
            break;
        case GM_COMBAT:
            sGameMode = "GM_COMBAT";
            break;
        case GM_CUTSCENE:
            sGameMode = "GM_CUTSCENE";
            break;
        case GM_DEAD:
            sGameMode = "GM_DEAD";
            break;
        case GM_DIALOG:
            sGameMode = "GM_DIALOG";
            break;
        case GM_EXPLORE:
            sGameMode = "GM_EXPLORE";
            break;
        case GM_FIXED:
            sGameMode = "GM_FIXED";
            break;
        case GM_FLYCAM:
            sGameMode = "GM_FLYCAM";
            break;
        case GM_GUI:
            sGameMode = "GM_GUI";
            break;
        case GM_LOADING:
            sGameMode = "GM_LOADING";
            break;
        case GM_MOVIE:
            sGameMode = "GM_MOVIE";
            break;
        case GM_PARTYPICKER:
            sGameMode = "GM_PARTYPICKER";
            break;
        case GM_PREGAME:
            sGameMode = "GM_PREGAME";
            break;
    }
    return sGameMode;
}

int eds_IsSummon(object oCreature)
{
    afLogDebug("eds_IsSummon called", AF_LOGGING_EDS);

    // A different take. Instead of looking for a flag, we see if their
    // tag is one of the registered party members from the party_picker
    // 2DA file. We could also just compare to the tags of the
    // GetPartyPoolList array, but what if we have lost a companions (they
    // might have become diconnected).

    int nRows = GetM2DARows(TABLE_PARTY_PICKER);
    string sTag = GetTag(oCreature);
    int i;
    for (i = 0; i < nRows; i++) {
        if (GetM2DAString(TABLE_PARTY_PICKER,"Tag",i) == sTag) {
            afLogDebug("eds_IsSummon: Creature tag matches entry [" + ToString(i) + "]. Returning false", AF_LOGGING_EDS);
            return FALSE;
        }
    }
    afLogDebug("eds_IsSummon: Creature tag did not match any party members. Returning true", AF_LOGGING_EDS);
    return TRUE;
}

int eds_RemoveParyMember(object oMember)
{
    if (FALSE == eds_IsSummon(oMember)) {
        string sTag = GetTag(oMember);
        int nParty;
        int nCamp;
        int nRecruited;

        if (GEN_FL_ALISTAIR == sTag) {
            nParty  = GEN_ALISTAIR_IN_PARTY;
            nCamp  = GEN_ALISTAIR_IN_CAMP;
            nRecruited = GEN_ALISTAIR_RECRUITED;
        } else if (GEN_FL_DOG == sTag) {
            nParty  = GEN_DOG_IN_PARTY;
            nCamp  = GEN_DOG_IN_CAMP;
            nRecruited = GEN_DOG_RECRUITED;
        } else if (GEN_FL_LELIANA == sTag) {
            nParty  = GEN_LELIANA_IN_PARTY;
            nCamp  = GEN_LELIANA_IN_CAMP;
            nRecruited = GEN_LELIANA_RECRUITED;
        } else if (GEN_FL_LOGHAIN == sTag) {
            nParty  = GEN_LOGHAIN_IN_PARTY;
            nCamp  = GEN_LOGHAIN_IN_CAMP;
            nRecruited = GEN_LOGHAIN_RECRUITED;
        } else if (GEN_FL_MORRIGAN == sTag) {
            nParty  = GEN_MORRIGAN_IN_PARTY;
            nCamp  = GEN_MORRIGAN_IN_CAMP;
            nRecruited = GEN_MORRIGAN_RECRUITED;
        } else if (GEN_FL_OGHREN == sTag) {
            nParty  = GEN_OGHREN_IN_PARTY;
            nCamp  = GEN_OGHREN_IN_CAMP;
            nRecruited = GEN_OGHREN_RECRUITED;
        } else if (GEN_FL_SHALE == sTag) {
            nParty  = GEN_SHALE_IN_PARTY;
            nCamp  = GEN_SHALE_IN_CAMP;
            nRecruited = GEN_SHALE_RECRUITED;
        } else if (GEN_FL_STEN == sTag) {
            nParty  = GEN_STEN_IN_PARTY;
            nCamp  = GEN_STEN_IN_CAMP;
            nRecruited = GEN_STEN_RECRUITED;
        } else if (GEN_FL_WYNNE == sTag) {
            nParty  = GEN_WYNNE_IN_PARTY;
            nCamp  = GEN_WYNNE_IN_CAMP;
            nRecruited = GEN_WYNNE_RECRUITED;
        } else if (GEN_FL_ZEVRAN == sTag) {
            nParty  = GEN_ZEVRAN_IN_PARTY;
            nCamp  = GEN_ZEVRAN_IN_CAMP;
            nRecruited = GEN_ZEVRAN_RECRUITED;
        }
                
        if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, nRecruited)) {
            if(WR_GetPlotFlag(PLT_GEN00PT_PARTY, nParty) == TRUE) {
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, nCamp, TRUE, TRUE);
                return TRUE;
            }
        }
    }
    return FALSE;
}

// Referenced By: (Recompile both if you change this file)
//   eds_dheu_module_core
//   eds_dheu_events_override
//

object eds_GetPartyPoolMemberByTag(string sTag)
{
    afLogDebug("eds_GetPartyPoolMemberByTag Called", AF_LOGGING_EDS);
    object [] arParty = GetPartyPoolList();
    int i;
    int nSize = GetArraySize(arParty);
    for(i = 0; i < nSize; i++) {
        if (sTag == GetTag(arParty[i])) return arParty[i];
    }
    return OBJECT_INVALID;
}

object eds_GetPartyMemberByTag(string sTag)
{
    afLogDebug("eds_GetPartyMemberByTag Called", AF_LOGGING_EDS);
    object [] arParty = GetPartyList();
    int i;
    int nSize = GetArraySize(arParty);
    for(i = 0; i < nSize; i++) {
        if (sTag == GetTag(arParty[i])) return arParty[i];
    }
    return OBJECT_INVALID;
}

// Checks the PC inventory and gives a dog whistle
// if PC doesn't already have one (And the dog has
// been recruited).
void giveDogWhistle()
{
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED)) {
        object oPC = GetHero();
        int nHasDW = CountItemsByTag(oPC, AF_ITM_EDS_DOG_WHISTLE);
        if ( nHasDW == 0 ) {
            if  (IsObjectValid(oPC)) {
                object dw = CreateItemOnObject(AF_ITR_EDS_WHISTLE,oPC,1);
                if (OBJECT_INVALID == dw) {
                    afLogDebug("eds_dheu_module_core : Dog Whistle was NOT Created", AF_LOGGING_EDS);
                } else {
                    afLogDebug("eds_dheu_module_core : Dog Whistle created", AF_LOGGING_EDS);
                }
            }
        }
    } else {
        afLogDebug("eds_dheu_module_core : Dog Not member of party. Whistle was NOT Created", AF_LOGGING_EDS);
    }
}

// Checks the NPC To see if they have one of our
// AF_ABI_EDS_DOG_SUMMONED upkeep effects present.
int isDogAttached(object oCaster)
{
    effect[] eUpKept = GetEffects(oCaster, EFFECT_TYPE_UPKEEP, AF_ABI_EDS_DOG_SUMMONED);
    int nSize = GetArraySize(eUpKept);

    // A redundant check is needed incase AF_ABI_EDS_DOG_SUMMONED is 0, which is
    // also the wildcard value for the GetEffects Query above.

    if (0 != nSize) {
        int i;
        int id;
        for (i = 0; i < nSize; i++) {
            id = GetEffectAbilityID(eUpKept[i]);
            if (AF_ABI_EDS_DOG_SUMMONED == id) {
                // eds_Log("AF_ABI_EDS_DOG_SUMMONED Found on [" + GetTag(oCaster) + "]");
                // Need to include util if we uncomment this.
                // PrintEffectProperties(eUpKept[i]);
                return TRUE;
            }
        }
    }
    return FALSE;
}

// Returns True if dog is a member of the active party. False otherwise
int isDogInParty()
{
    afLogDebug("isDogInParty Called", AF_LOGGING_EDS);
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED)) {
        object oDog = eds_GetPartyMemberByTag(GEN_FL_DOG);
        if (IsObjectValid(oDog)) return TRUE;
    }
    // afLogDebug("isDogInParty: Dog is not a member of the active party.]", AF_LOGGING_EDS);
    return FALSE;
}

// Used to retrieve dog owner during combat when UPKEEP effect may have
// ended due to death. Also used when party picker closed event fires
// to see if PC removed companion that the dog was attached to.
string getStoredDogOwner()
{
    afLogDebug("getStoredDogOwner Called", AF_LOGGING_EDS);
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED)) {
        return GetLocalString(GetModule(),DOG_OWNER);
    } else {
        afLogDebug("getStoredDogOwner : GEN_DOG_RECRUITED not set", AF_LOGGING_EDS);
    }
    return "";
}

// scans ACTIVE party members for UPKEEP effect that has matching
// AF_ABI_EDS_DOG_SUMMONED abilityID.
object getDogOwner()
{
    afLogDebug("getDogOwner Called", AF_LOGGING_EDS);
    if (isDogInParty()) {
        object [] arParty = GetPartyList();
        int i;
        int nSize = GetArraySize(arParty);
        object oCurrent;
        for(i = 0; i < nSize; i++) {
            oCurrent = arParty[i];
            // eds_Log("getDogOwner(): Checking PartyList[" + ToString(i) + "] tag [" +  GetTag(oCurrent) + "]");
            if (isDogAttached(oCurrent)) return oCurrent;
        }
    }
    return OBJECT_INVALID;
}

location GetLocationBehindCreature(object oCreature, float distance = -7.5)
{
    float facing = GetFacingFromLocation(GetLocation(oCreature));
    float rFacing = ToRadians(facing);
    vector pos = GetPositionFromLocation(GetLocation(oCreature));

    // trace line
    float xoffset = distance * cos(rFacing);
    float yoffset = distance * sin(rFacing);
    vector traceLine = Vector(pos.x + xoffset, pos.y + yoffset, pos.z);

    location behindMe = Location(GetArea(oCreature),traceLine,facing);
    return GetSafeLocation(behindMe);
}

// Called from deactivate_DogSlot (below)
// Called from eds_dheu_dying_override.nss
// bForceStoredRemoval -> Primarily used by EVENT_PARTY_MEMBER_FIRED
object unAttachDogFromPartyMember(object oCaster, int bRes = TRUE, int bForceStoredRemoval = FALSE)
{
    afLogDebug("UnAttachDogFromPartyMember Called", AF_LOGGING_EDS);
    object oDog = eds_GetPartyMemberByTag(GEN_FL_DOG);
    int noHealth = (1.0 > GetCurrentHealth(oCaster));
    if (IsDead(oCaster) || noHealth) {
        afLogDebug("UnAttachDogFromPartyMember : oCaster is dead or health is 0", AF_LOGGING_EDS);
        if (bRes && (IsDead(oDog) || IsDying(oDog))) {
            float health = GetMaxHealth(oDog) * 0.5;
            int stamina  = GetCreatureMaxStamina(oDog);

            SetCurrentHealth(oDog,health);
            SetCreatureStamina(oDog, stamina);
            SetAILevel(oDog, CSERVERAIMASTER_AI_LEVEL_INVALID);
            SetCreatureFlag(oDog,CREATURE_RULES_FLAG_DYING,FALSE);
        }


        // To get the new variables to work, I had
        // to make my own var_module.gda file and
        // declare my variable names/types.

        SetLocalString(GetModule(),DOG_OWNER,"");
        return oDog;
    }

    effect[] eUpKept = GetEffects(oCaster, EFFECT_TYPE_UPKEEP, AF_ABI_EDS_DOG_SUMMONED);
    int nSize = GetArraySize(eUpKept);

    // A redundant check is needed incase AF_ABI_EDS_DOG_SUMMONED is 0, which is
    // also the wildcard value for the GetEffects Query above.

    int i;
    int id;
    for (i = 0; i < nSize; i++) {
        id = GetEffectAbilityID(eUpKept[i]);
        if (AF_ABI_EDS_DOG_SUMMONED == id) {
            float health = GetCurrentHealth(oDog);
            int stamina = GetCreatureStamina(oDog);

            SetLocalString(GetModule(),DOG_OWNER,"");
            // Set ByPass... The RemoveEffect will kill the
            // dog, an event that is normally caught and
            // handled by EVENT_DYING... So we need to set
            // the Bypass flag so that we dont handle it.

            // Unfortunately, as a threaded event, we dont
            // know when it will fire, so if we set bypass
            // to FALSE towards the end of this method,
            // it may or may not be true when the dying
            // event fires.
            //
            // So.. we only set it to true here and let
            // the dying event set it back to false.
            //
            // As a backup measure, we set bypass to
            // false when the use clicks on the whistle
            // as well.

            // To get the new variables to work, I had
            // to make my own var_module.gda file and
            // declare my variable names/types.

            SetLocalInt(GetModule(),DOG_BYPASS,TRUE);
            RemoveEffect(oCaster,eUpKept[i]);

            // They are still in the party, but when we removed the effect, we just
            // killed the dog. Need to resurect so that the dog isn't dead when we
            // get back to camp or if we re-summon.

            // FROM effect_resurrection:
            SetCurrentHealth(oDog,health);
            SetCreatureStamina(oDog, stamina);
            SetAILevel(oDog, CSERVERAIMASTER_AI_LEVEL_INVALID);
            SetCreatureFlag(oDog,CREATURE_RULES_FLAG_DYING,FALSE);
            // afLogDebug("Setting Bypass To False", AF_LOGGING_EDS);
            // SetLocalInt(GetModule(),DOG_BYPASS,FALSE);
            return oDog;
        }
    }
    if (bForceStoredRemoval) {
        SetLocalString(GetModule(),DOG_OWNER,"");
        return oDog;
    }
    return OBJECT_INVALID;
}

void removeDog(int bOnlyIfAttached=FALSE)
{
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED)) {
        // Make sure the dog is not attached to anyone
        int bForceStoredFlag = FALSE;
        object oOwner = getDogOwner();
        if (!IsObjectValid(oOwner)) {
            string sOwner = getStoredDogOwner();
            if ("" != sOwner) {
                oOwner = eds_GetPartyPoolMemberByTag(sOwner);
                if (!isDogAttached(oOwner)) {
                    bForceStoredFlag = TRUE;
                    object oDog = eds_GetPartyPoolMemberByTag(GEN_FL_DOG);
                    if (IsObjectValid(oDog)) {
                        SetCurrentHealth(oDog,GetMaxHealth(oDog));
                        SetCreatureStamina(oDog, GetCreatureMaxStamina(oDog));
                    }
                }
            }
        }
        if (IsObjectValid(oOwner)) {
            unAttachDogFromPartyMember(oOwner,TRUE,bForceStoredFlag);
            WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
        } else if (FALSE == bOnlyIfAttached) {
            WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
        }
    }
}

// This causes the dog to run away. If you want a
// more instant verision, see removeDog().
void deactivate_DogSlot(object oCaster)
{
    afLogDebug("deactivate_DogSlot called", AF_LOGGING_EDS);

    object oDog = unAttachDogFromPartyMember(oCaster);
    if (IsObjectValid(oDog)) {
        location offScreen = GetLocationBehindCreature(oCaster,-40.0);
        command cRunAway = CommandMoveToLocation(offScreen, TRUE);
        WR_AddCommand(oDog, cRunAway);

        // DOESNT WORK:
        // command cRunAway = CommandMoveAwayFromObject(arParty[pm], 40.0);

        // Update variables (checked when party-change events fire).
        afLogDebug("Setting NODOGSLOT to TRUE", AF_LOGGING_EDS);
        SetLocalInt(GetModule(),NODOGSLOT,TRUE);

        // Give him two seconds and then remove him:
        event eRunAway = Event(EVENT_DOG_RAN_AWAY);
        DelayEvent(1.5, GetModule(), eRunAway);

        // Handled in eds_dheu_module_core : EVENT_DOG_RAN_AWAY
        // if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED))
        //    WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);

    }
}

object fixBrokenDog()
{
    afLogDebug("WARNING : fixBrokenDog() called.", AF_LOGGING_EDS);

    // Normally when this happens, the effect is still attached to the
    // player which can make other function fail. So we start by
    // making sure there is no DOG effect attached to player

    object oCaster = GetHero();
    effect[] eUpKept = GetEffects(oCaster, EFFECT_TYPE_UPKEEP, AF_ABI_EDS_DOG_SUMMONED);
    int nSize = GetArraySize(eUpKept);

    // A redundant check is needed incase AF_ABI_EDS_DOG_SUMMONED is 0, which is
    // also the wildcard value for the GetEffects Query above.

    int i;
    int id;
    for (i = 0; i < nSize; i++) {
        id = GetEffectAbilityID(eUpKept[i]);
        if (AF_ABI_EDS_DOG_SUMMONED == id) {
            SetLocalString(GetModule(),DOG_OWNER,"");
            RemoveEffect(oCaster,eUpKept[i]);
        }
    }

    // STEP 2 : See if the dog is in the local area. If so, grab him...
    object [] oDogs = GetNearestObjectByTag(GetMainControlled(),GEN_FL_DOG, OBJECT_TYPE_CREATURE,1);
    if (GetArraySize(oDogs) > 0) {
        afLogDebug("SUCCESS! Found dog in current map.", AF_LOGGING_EDS);
        string sDogName = GetLocalString(GetModule(),EDS_DOG_NAME);
        if ("" != sDogName) {
            SetName(oDogs[0],sDogName);
        }

        return oDogs[0];
    }

    // STEP 3 : Couldn't find old dog, so create new. Based on the
    // presence of the dogs name in persistent storage, we will
    // either make a barnd new dog or a clone of the old dog.

    afLogDebug("Attempting to Restore lost dog", AF_LOGGING_EDS);

    resource rDog = GEN_FLR_DOG;
    object oDog = CreateObject(OBJECT_TYPE_CREATURE, rDog, GetLocation(OBJECT_SELF));

    // Provide Access to dog talents:
    AddAbility(oDog,ABILITY_TALENT_HIDDEN_DOG);

    // WR_SetObjectActive(oDog,TRUE);
    WR_SetFollowerState(oDog, FOLLOWER_STATE_ACTIVE, TRUE);

    object oModule = GetModule();
    string sDogName = GetLocalString(oModule,EDS_DOG_NAME);
    if ("" != sDogName) {
        // We dont want to autolevel, but the autoscale functions
        // do a lot of setup work. By scaling to a lower level
        // we ensure Race, class and other important character
        // traits are set.
        AS_CommenceAutoScaling(oDog, 2);

        // When added to party, this tracks if it is the
        // first time. If FALSE, it autolevels the creature.
        SetLocalInt(oDog, FOLLOWER_SCALED, TRUE);

        SetName(oDog,sDogName);
        float exp       = GetLocalFloat(oModule,EDS_DOG_XP);
        float level     = GetLocalFloat(oModule,EDS_DOG_LEVEL);
        float xtr_attr = GetLocalFloat(oModule,EDS_DOG_XTRA_ATTRIBUTES);
        float xtr_skil = GetLocalFloat(oModule,EDS_DOG_XTRA_SKILLS);
        float xtr_tal = GetLocalFloat(oModule,EDS_DOG_XTRA_TALENTS);

        exp = GetCreatureProperty(GetHero(),PROPERTY_SIMPLE_EXPERIENCE);
        afLogDebug("Updating XP on dogto match PC", AF_LOGGING_EDS);
        SetCreatureProperty(oDog,PROPERTY_SIMPLE_EXPERIENCE,exp);
        SetCreatureProperty(oDog,PROPERTY_SIMPLE_LEVEL,level);
        SetCreatureProperty(oDog,PROPERTY_SIMPLE_ATTRIBUTE_POINTS,xtr_attr);
        SetCreatureProperty(oDog,PROPERTY_SIMPLE_SKILL_POINTS,xtr_skil);
        SetCreatureProperty(oDog,PROPERTY_SIMPLE_TALENT_POINTS,xtr_tal);

        string sCollar = GetLocalString(oModule,EDS_DOG_EQUIP_COLLAR);
        string sPaint = GetLocalString(oModule,EDS_DOG_EQUIP_WARPAINT);

        float con = GetLocalFloat(oModule,EDS_DOG_CON);
        float dex = GetLocalFloat(oModule,EDS_DOG_DEX);
        float itl = GetLocalFloat(oModule,EDS_DOG_INT);
        float mag = GetLocalFloat(oModule,EDS_DOG_MAG);
        float str = GetLocalFloat(oModule,EDS_DOG_STR);
        float wil = GetLocalFloat(oModule,EDS_DOG_WIL);

        if (0.0 != con) {
            // eds_Log("Updating CON on dog clone to [" + ToString(con) + "]");
            SetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_CONSTITUTION,con);
        }
        if (0.0 != dex) {
            // eds_Log("Updating DEX on dog clone to [" + ToString(dex) + "]");
            SetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_DEXTERITY,dex);
        }
        if (0.0 != itl) {
            // eds_Log("Updating INT on dog clone to [" + ToString(itl) + "]");
            SetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_INTELLIGENCE,itl);
        }
        if (0.0 != mag) {
            // eds_Log("Updating MAG on dog clone to [" + ToString(mag) + "]");
            SetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_MAGIC,mag);
        }
        if (0.0 != str) {
            // eds_Log("Updating STR on dog clone to [" + ToString(str) + "]");
            SetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_STRENGTH,str);
        }
        if (0.0 != wil) {
            // eds_Log("Updating WIL on dog clone to [" + ToString(wil) + "]");
            SetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_WILLPOWER,wil);
        }


        if (GetLocalInt(oModule,EDS_DOG_HAS_GROWL)) {
            afLogDebug("Updating Growl Talent]", AF_LOGGING_EDS);
            AddAbility(oDog,ABILITY_TALENT_MONSTER_DOG_GROWL);
            SetQuickslot(oDog, -1, ABILITY_TALENT_MONSTER_DOG_GROWL);
        }
        if (GetLocalInt(oModule,EDS_DOG_HAS_HOWL)) {
            afLogDebug("Updating Howl Talent]", AF_LOGGING_EDS);
            AddAbility(oDog,ABILITY_TALENT_MONSTER_MABARI_HOWL);
            SetQuickslot(oDog, -1, ABILITY_TALENT_MONSTER_MABARI_HOWL);
        }
        if (GetLocalInt(oModule,EDS_DOG_HAS_COMBAT)) {
            afLogDebug("Updating Combat Talent]", AF_LOGGING_EDS);
            AddAbility(oDog,ABILITY_TALENT_MONSTER_DOG_COMBAT_TRAINING);
        }
        if (GetLocalInt(oModule,EDS_DOG_HAS_OVERWHELM)) {
            afLogDebug("Updating Overwhelm Talent]", AF_LOGGING_EDS);
            AddAbility(oDog,ABILITY_TALENT_MONSTER_DOG_OVERWHELM);
            SetQuickslot(oDog, -1, ABILITY_TALENT_MONSTER_DOG_OVERWHELM);
        }

        if (GetLocalInt(oModule,EDS_DOG_HAS_SHRED)) {
            afLogDebug("Updating Shred Talent]", AF_LOGGING_EDS);
            AddAbility(oDog,ABILITY_TALENT_MONSTER_DOG_SHRED);
            SetQuickslot(oDog, -1, ABILITY_TALENT_MONSTER_DOG_SHRED);
        }
        if (GetLocalInt(oModule,EDS_DOG_HAS_CHARGE))
        {
            afLogDebug("Updating Charge Talent]", AF_LOGGING_EDS);
            AddAbility(oDog,ABILITY_TALENT_MONSTER_DOG_CHARGE);
            SetQuickslot(oDog, -1, ABILITY_TALENT_MONSTER_DOG_CHARGE);
        }
        if (GetLocalInt(oModule,EDS_DOG_HAS_FORT))
        {
            afLogDebug("Updating Fort Talent]", AF_LOGGING_EDS);
            AddAbility(oDog,ABILITY_TALENT_MONSTER_DOG_FORTITUDE);
        }
        if (GetLocalInt(oModule,EDS_DOG_HAS_NEMESIS))
        {
            afLogDebug("Updating Nemesis Talent]", AF_LOGGING_EDS);
            AddAbility(oDog,ABILITY_TALENT_MONSTER_DOG_NEMESIS);
        }
    } else {
        afLogDebug("Previous Record Not Found. Using Defaults", AF_LOGGING_EDS);

        // When added to party, this tracks if it is the
        // first time and if so, autolevels the creature.
        //
        // see player_core, EVENT_TYPE_PARTY_MEMBER_HIRED
        SetLocalInt(oDog, FOLLOWER_SCALED, FALSE);
        AddAbility(oDog,ABILITY_TALENT_HIDDEN_DOG);

        // AS_ = AutoScale functions
        AS_InitCreature(oDog);

        int p_exp = FloatToInt(GetCreatureProperty(GetHero(),PROPERTY_SIMPLE_EXPERIENCE));
        int d_exp = FloatToInt(GetCreatureProperty(oDog,PROPERTY_SIMPLE_EXPERIENCE));
        if (p_exp-d_exp > 0) {
            RewardXP(oDog,p_exp-d_exp);
        }
    }
    return oDog;
}

int hasSummonedCompanions(object oCaster)
{
    effect[] eSummons = GetEffects(oCaster, EFFECT_TYPE_SUMMON, 0, oCaster);
    int nSize = GetArraySize(eSummons);
    if (0 == nSize) return FALSE;

    // Confirm Summon is not the dog.
    object oSummon = GetCurrentSummon(oCaster);
    if (IsObjectValid(oSummon)) {
        if (GetTag(oSummon) != GEN_FL_DOG) {
            return TRUE;
        }
    }
    return FALSE;
}

int getNumNonSummonedPartyMembers()
{
    object [] theParty = GetPartyList();
    int nSize = GetArraySize(theParty);
    int total = GetArraySize(theParty);

    afLogDebug("Beginning Search for companions with no summons", AF_LOGGING_EDS);

    // Some party members may have summoned
    // companions. So we scan all party members
    // and if someone has a summoned effect,
    // we subtract 1 from the total.

    int j;
    for (j = 0; j < nSize; j++) {
        if (hasSummonedCompanions(theParty[j])) {
            // eds_Log("[" + GetTag(theParty[j]) + "] has a summon");
            total--;
        }
        // else
        // {
        //    eds_Log("[" + GetTag(theParty[j]) + "] does not have a summon");
        // }
    }
    // eds_Log("Examined [" + ToString(nSize) + "] Party Members. Final Total = [" + ToString(total) + "]");
    return total;
}

// Returns dog object or OBJECT_INVALID on Failure
object summonDog()
{
    object oArea = GetArea(GetPartyLeader());
    string sArea = GetTag(oArea);
    // eds_Log("summonDog() Called in area = [" + sArea + "]");

    object oDog = OBJECT_INVALID;
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED)) {
        // Area checks : We dont allow the whistle to work in all locations
        // Not in fade
        if (GetAreaFlag(oArea,AREA_FLAG_IS_FADE)) {
            UI_DisplayMessage(GetMainControlled(),UI_MESSAGE_NOT_AT_THIS_LOCATION);
            return OBJECT_INVALID;
        }

        // not in combat
        if (GM_COMBAT == GetGameMode()) {
            UI_DisplayMessage(GetMainControlled(),UI_MESSAGE_CANT_DO_IN_COMBAT);
            return OBJECT_INVALID;
        }

        // Not when the PC is playing solo... (Like at the pearl)
        if (1 == getNumNonSummonedPartyMembers()) {
            UI_DisplayMessage(GetMainControlled(),UI_MESSAGE_NOT_AT_THIS_LOCATION);
            return OBJECT_INVALID;
        }

        // sArea == "pre200ar_korcari_wilds" ||
        // sArea == "pre100ar_kings_camp_night" ||

        // Specific area checks
        // sArea == "cam100ar_camp_plains" -> Covered by solo check

        if (sArea == "pre100ar_kings_camp" ||
            sArea == "pre211ar_flemeths_hut_int" ||
            sArea == "pre210ar_flemeths_hut_ext" ||
            sArea == "ran405ar_highway_dog") {
            UI_DisplayMessage(GetMainControlled(),UI_MESSAGE_NOT_AT_THIS_LOCATION);
            return OBJECT_INVALID;
        }

        oDog = eds_GetPartyPoolMemberByTag(GEN_FL_DOG);

        if (!IsObjectValid(oDog)) {
            // Dog recruited, but instance not found (this is bad).
            // Maybe it was destroyed or died somehow? Anyway, need code
            // to restore the dog instance. Appears to be in some area
            // transition handler somewhere (leave camp, select dog. If
            // dog is dead, a new instance is created when you enter
            // new area...) Need to trace through scripts and find code
            // to do this, but haven't found time yet.

            oDog = fixBrokenDog();
            if (IsObjectValid(oDog)) {
                // if name is "gen00fl_dog" or "dog", request new name.
                string s_oldname = StringLowerCase(GetName(oDog));
                if ("dog" == s_oldname || "gen00fl_dog" == s_oldname) {
                    SetLocalInt(GetModule(), EDS_GET_DOG_NAME, 1);

                    // Result of event will go to the OBJECT field (module)
                    // as an EVENT_TYPE_POPUP_RESULT. The input string will
                    // be reflected as string event parameter 0.
                    ShowPopup(362390,2,GetModule(),TRUE);
                }
            }

        }

        if (IsObjectValid(oDog)) {
            afLogDebug("Found Dog", AF_LOGGING_EDS);
            WR_SetObjectActive(oDog,TRUE);
            // location behindPC = GetFollowerWouldBeLocation(GetPartyLeader());
            location behindPC = GetLocation(GetMainControlled());
            command cJump = CommandJumpToLocation(behindPC);
            WR_SetFollowerState(oDog, FOLLOWER_STATE_ACTIVE, TRUE);
            WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY, TRUE, TRUE);
            WR_AddCommand(oDog, cJump);
        } else {
            afLogDebug("ERROR : Dog instance not found and could not be created (This is bad).", AF_LOGGING_EDS);
            UI_DisplayMessage(GetMainControlled(),UI_MESSAGE_ABILITY_CONDITION_NOT_MET);
        }
    }
    return oDog;
}

// Scan party and find someone without a companion/familiar.
// then attach dog to them. Yes... since party members may cast
// spells that add companions, those spells must be changed to
// check for the dog and move them if need be.

void attachDogToParty(object oDog)
{
    afLogDebug("attachDogToParty() Called", AF_LOGGING_EDS);
    if (IsObjectValid(oDog)) {
        object [] arParty = GetPartyList();
        int nSize = GetArraySize(arParty);
        int i;
        int notFound = TRUE;
        for (i = 0; i < nSize && notFound; i++) {
            // Yes, you can attach a portrait of someone to themself
            // so we have to check for this...
            if (GetTag(arParty[i]) != GEN_FL_DOG) {
                if (!hasSummonedCompanions(arParty[i])) {
                    int hasHealth = (0.0 < GetCurrentHealth(arParty[i]));
                    if  (!IsDead(arParty[i]) && hasHealth) {
                        notFound = FALSE;
                        effect eSummon = EffectSummon(arParty[i], oDog);

                        // The upkeep affect associated with eSummon places a
                        // picture of the eSummon creature next to the eSummon
                        // owner
                        Ability_ApplyUpkeepEffect(arParty[i], AF_ABI_EDS_DOG_SUMMONED, eSummon);

                        // This effect turns the associaed creature into a "SUMMONED"
                        // creature. The issue is that when the engine removes the
                        // effect, it deletes the creature associated with it. So
                        // we dont want to invoke this effect on the dog.
                        // ApplyEffectOnObject(EFFECT_DURATION_TYPE_PERMANENT, eSummon, oDog, 0.0f, oCaster, 0);

                        // Must set most properties AFTER we apply the effect
                        // as the effect itself will set some of these properties
                        SetLocalInt(oDog, IS_SUMMONED_CREATURE,FALSE);
                        // eds_Log("Attempting to Set dog owner tag to [" + GetTag(arParty[i]) + "]");
                        SetLocalString(GetModule(), DOG_OWNER, GetTag(arParty[i]));
                    }
                }
            }
        }
    }
}

// Do any of these cases break if we did a "is dog in party" check first.
//
// Called when party selection screen ends
// Called when summoned companion is unsummoned or dies.
// Called when entering a new area
// called at end of combat to correct position of dog if another summon fell
// Called from activate_dogSlot once dog is summoned.
void checkDogSlot(int markSlot = FALSE)
{
    if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED)) {
        int total = getNumNonSummonedPartyMembers();
        if (total > 4) {
            object [] arParty = GetPartyList();
            if (GetTag(arParty[4]) != GEN_FL_DOG) {
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP, TRUE, TRUE);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_PARTY, TRUE, TRUE);
            }
            object oOwner = getDogOwner();
            if (!IsObjectValid(oOwner)) {
                string sOwner = getStoredDogOwner();
                if ("" != sOwner) {
                    oOwner = eds_GetPartyPoolMemberByTag(sOwner);
                }
            }
            if (IsObjectValid(oOwner)) {
                // eds_Log("Owner Found... [" + GetTag(oOwner) + "[");
                if ("player" != GetTag(oOwner)) {
                    afLogDebug("Owner is not player. Moving...", AF_LOGGING_EDS);
                    // Even if PC has a summon, this code will
                    // shift the dog up as far as we can toward
                    // the top.
                    object oDog = unAttachDogFromPartyMember(oOwner);

                    if (IsObjectValid(oDog)) {
                        // Attempt to re-attach to someone who isn't dead....
                        if (markSlot) {
                            afLogDebug("Setting NODOGSLOT to FALSE", AF_LOGGING_EDS);
                            SetLocalInt(GetModule(),NODOGSLOT,FALSE);
                        }
                        attachDogToParty(oDog);
                    }
                }
            } else {
                object oDog = eds_GetPartyMemberByTag(GEN_FL_DOG);
                if (!IsObjectValid(oDog)) {
                    oDog = fixBrokenDog();
                    if (IsObjectValid(oDog)) {
                        // if name is "gen00fl_dog" or "dog", request new name.
                        string s_oldname = StringLowerCase(GetName(oDog));
                        if ("dog" == s_oldname || "gen00fl_dog" == s_oldname) {
                            SetLocalInt(GetModule(), EDS_GET_DOG_NAME, 1);

                           // Result of event will go to the OBJECT field (module)
                            // as an EVENT_TYPE_POPUP_RESULT. The input string will
                            // be reflected as string event parameter 0.
                            ShowPopup(362390,2,GetModule(),TRUE);
                        }
                    }
                }
                if (IsObjectValid(oDog)) {
                    // Attempt to re-attach to someone who isn't dead....
                    if (markSlot) {
                        afLogDebug("Setting NODOGSLOT to FALSE", AF_LOGGING_EDS);
                        SetLocalInt(GetModule(),NODOGSLOT,FALSE);
                    }
                    attachDogToParty(oDog);
                }
            }
        } else {
            // If dog is in party, ensure they do not have an owner.
            if (isDogInParty()) {
                object oOwner = getDogOwner();
                if (IsObjectValid(oOwner)) {
                    unAttachDogFromPartyMember(oOwner);
                }
            }
        }
    }
}

void eds_DogSnapShot()
{
        object oDog = eds_GetPartyMemberByTag(GEN_FL_DOG);
        if (IsObjectValid(oDog)) {
            string sDogName = GetName(oDog);
            float exp = GetCreatureProperty(oDog,PROPERTY_SIMPLE_EXPERIENCE);
            float level = GetCreatureProperty(oDog,PROPERTY_SIMPLE_LEVEL);
            float xtr_attr = GetCreatureProperty(oDog,PROPERTY_SIMPLE_ATTRIBUTE_POINTS);
            float xtr_skil = GetCreatureProperty(oDog,PROPERTY_SIMPLE_SKILL_POINTS);
            float xtr_tal = GetCreatureProperty(oDog,PROPERTY_SIMPLE_TALENT_POINTS);

            string sCollar = "";
            object oCollar = GetItemInEquipSlot(INVENTORY_SLOT_DOG_COLLAR,oDog);
            if (IsObjectValid(oCollar)) sCollar = GetTag(oCollar);

            string sPaint = "";
            object oPaint = GetItemInEquipSlot(INVENTORY_SLOT_DOG_WARPAINT,oDog);
            if (IsObjectValid(oPaint)) sPaint = GetTag(oPaint);

            float con = GetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_CONSTITUTION);
            float dex = GetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_DEXTERITY);
            float itl = GetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_INTELLIGENCE);
            float mag = GetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_MAGIC);
            float str = GetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_STRENGTH);
            float wil = GetCreatureProperty(oDog,PROPERTY_ATTRIBUTE_WILLPOWER);

            int hasCharge = HasAbility(oDog, ABILITY_TALENT_MONSTER_DOG_CHARGE);
            int hasCombat = HasAbility(oDog, ABILITY_TALENT_MONSTER_DOG_COMBAT_TRAINING);
            int hasFort   = HasAbility(oDog, ABILITY_TALENT_MONSTER_DOG_FORTITUDE);
            int hasGrowl  = HasAbility(oDog, ABILITY_TALENT_MONSTER_DOG_GROWL);
            int hasNemes  = HasAbility(oDog, ABILITY_TALENT_MONSTER_DOG_NEMESIS);
            int hasOver   = HasAbility(oDog, ABILITY_TALENT_MONSTER_DOG_OVERWHELM);
            int hasShred  = HasAbility(oDog, ABILITY_TALENT_MONSTER_DOG_SHRED);
            int hasHowl   = HasAbility(oDog, ABILITY_TALENT_MONSTER_MABARI_HOWL);

/*
            afLogDebug("Dog SnapShot : ", AF_LOGGING_EDS);
            afLogDebug("", AF_LOGGING_EDS);
            afLogDebug("  Name       : " + sDogName, AF_LOGGING_EDS);
            afLogDebug("  Experience : " + ToString(exp), AF_LOGGING_EDS);
            afLogDebug("  Level      : " + ToString(level), AF_LOGGING_EDS);
            afLogDebug("  Skill Pts  : " + ToString(xtr_skil), AF_LOGGING_EDS);
            afLogDebug("  Talent Pts : " + ToString(xtr_tal), AF_LOGGING_EDS);
            afLogDebug("  Attr Pts   : " + ToString(xtr_attr), AF_LOGGING_EDS);
            afLogDebug("", AF_LOGGING_EDS);
            afLogDebug("  Collar     : [" + sCollar + "]", AF_LOGGING_EDS);
            afLogDebug("  Paint      : [" + sPaint  + "]", AF_LOGGING_EDS);
            afLogDebug("", AF_LOGGING_EDS);
            afLogDebug("  Con        : " + ToString(con), AF_LOGGING_EDS);
            afLogDebug("  Dex        : " + ToString(dex), AF_LOGGING_EDS);
            afLogDebug("  Int        : " + ToString(itl), AF_LOGGING_EDS);
            afLogDebug("  Mag        : " + ToString(mag), AF_LOGGING_EDS);
            afLogDebug("  Str        : " + ToString(str), AF_LOGGING_EDS);
            afLogDebug("  Wil        : " + ToString(wil), AF_LOGGING_EDS);
            afLogDebug("", AF_LOGGING_EDS);
            afLogDebug("  hasCharge  : " + ToString(hasCharge), AF_LOGGING_EDS);
            afLogDebug("  hasCombat  : " + ToString(hasCombat), AF_LOGGING_EDS);
            afLogDebug("  hasFort    : " + ToString(hasFort), AF_LOGGING_EDS);
            afLogDebug("  hasGrowl   : " + ToString(hasGrowl), AF_LOGGING_EDS);
            afLogDebug("  hasNemes   : " + ToString(hasNemes), AF_LOGGING_EDS);
            afLogDebug("  hasOver    : " + ToString(hasOver), AF_LOGGING_EDS);
            afLogDebug("  hasShred   : " + ToString(hasShred), AF_LOGGING_EDS);
            afLogDebug("  hasHowl    : " + ToString(hasHowl), AF_LOGGING_EDS);
*/
            // Now store everything in module variables
            object oModule = GetModule();
            SetLocalString(oModule,EDS_DOG_NAME,sDogName);
            SetLocalFloat(oModule,EDS_DOG_XP,exp);
            SetLocalFloat(oModule,EDS_DOG_LEVEL,level);
            SetLocalFloat(oModule,EDS_DOG_XTRA_ATTRIBUTES,xtr_attr);
            SetLocalFloat(oModule,EDS_DOG_XTRA_SKILLS,xtr_skil);
            SetLocalFloat(oModule,EDS_DOG_XTRA_TALENTS,xtr_tal);

            SetLocalString(oModule,EDS_DOG_EQUIP_COLLAR,sCollar);
            SetLocalString(oModule,EDS_DOG_EQUIP_WARPAINT,sPaint);

            SetLocalFloat(oModule,EDS_DOG_CON,con);
            SetLocalFloat(oModule,EDS_DOG_DEX,dex);
            SetLocalFloat(oModule,EDS_DOG_INT,itl);
            SetLocalFloat(oModule,EDS_DOG_MAG,mag);
            SetLocalFloat(oModule,EDS_DOG_STR,str);
            SetLocalFloat(oModule,EDS_DOG_WIL,wil);

            SetLocalInt(oModule,EDS_DOG_HAS_CHARGE,hasCharge);
            SetLocalInt(oModule,EDS_DOG_HAS_COMBAT,hasCombat);
            SetLocalInt(oModule,EDS_DOG_HAS_FORT,hasFort);
            SetLocalInt(oModule,EDS_DOG_HAS_GROWL,hasGrowl);
            SetLocalInt(oModule,EDS_DOG_HAS_NEMESIS,hasNemes);
            SetLocalInt(oModule,EDS_DOG_HAS_OVERWHELM,hasOver);
            SetLocalInt(oModule,EDS_DOG_HAS_SHRED,hasShred);
            SetLocalInt(oModule,EDS_DOG_HAS_HOWL,hasHowl);
        }
}

void activate_DogSlot(object oCaster, int markSlot=TRUE)
{
    afLogDebug("activate_DogSlot Called", AF_LOGGING_EDS);

    // No matter what, we summon the dog and
    // add to the party
    object oDog = summonDog();
    if (IsObjectValid(oDog))
        checkDogSlot(markSlot);
    else
        afLogDebug("Summon Dog returned invalid object", AF_LOGGING_EDS);
}

void handle_DogWhistle(event ev)
{
    // See unAttachDogFromPartyMember above for explantion of
    // BYPASS variable.
    SetLocalInt(GetModule(),DOG_BYPASS,FALSE);
    object oItem = GetEventObject(ev, 0);
    // object oTarget = GetEventObject(ev, 2);

    if (OBJECT_INVALID != oItem && GetTag(oItem) == AF_ITM_EDS_DOG_WHISTLE) {
        if(WR_GetPlotFlag( PLT_GEN00PT_PARTY, GEN_DOG_RECRUITED)) {
            object oDog = eds_GetPartyPoolMemberByTag(GEN_FL_DOG);
            if (IsObjectValid(oDog)) {
                // if name is "gen00fl_dog" or "dog", request new name.
                string s_oldname = StringLowerCase(GetName(oDog));
                if ("dog" == s_oldname || "gen00fl_dog" == s_oldname || "" == s_oldname) {
                    SetLocalInt(GetModule(), EDS_GET_DOG_NAME, 1);

                    // Result of event will go to the OBJECT field (module)
                    // as an EVENT_TYPE_POPUP_RESULT. The input string will
                    // be reflected as string event parameter 0.
                    ShowPopup(362390,2,GetModule(),TRUE);
                }
            }
        }

        object oOwner = getDogOwner();
        if (IsObjectValid(oOwner)) {
            deactivate_DogSlot(oOwner);
        } else if (FALSE == isDogInParty()) {
            object oCaster = GetEventObject(ev, 1);
            activate_DogSlot(oCaster);
        }
    }
}