#include "placeable_h"
#include "events_h"
#include "utility_h"
#include "wrappers_h"
#include "plt_sc_leli_soaps"

const resource BATH_HUMAN_MALE   = R"hm_leli_bath.cut";
const resource BATH_HUMAN_FEMALE = R"hf_leli_bath.cut";
const resource BATH_ELF_FEMALE = R"ef_leli_bath.cut";
const resource BATH_ELF_MALE = R"em_leli_bath.cut";
void main()
{
    event ev          = GetCurrentEvent();
    int nEventType    = GetEventType(ev);
    int bEventHandled = FALSE;

    switch (nEventType)
    {
        case EVENT_TYPE_USE:
        {
            object  oUser           = GetEventCreator(ev);
            int     nAction         = GetPlaceableAction(OBJECT_SELF);
            int     nVariation      = GetEventInteger(ev, 0);
            int     nActionResult   = TRUE;
            object oPC = GetHero();
            int nGender = GetCreatureGender(oPC);
            int nRace = GetCreatureRacialType(oPC);
            resource rCutscene;

            switch (nAction)
            {
                case PLACEABLE_ACTION_EXAMINE:
                {
                        if(nGender == GENDER_FEMALE){
                        if(nRace == RACE_ELF) rCutscene = BATH_ELF_FEMALE;
                        if(nRace == RACE_HUMAN) rCutscene = BATH_HUMAN_FEMALE;
                        } else {
                        if(nRace == RACE_ELF) rCutscene = BATH_ELF_MALE;
                        if(nRace == RACE_HUMAN) rCutscene = BATH_HUMAN_MALE;
                        }
                        if(!WR_GetPlotFlag(PLT_SC_LELI_SOAPS, SC_LELI_SOAPS_GIVEN)){
                        UT_AddItemToInventory(R"sc_leli_soaps.uti", 1);
                        WR_SetPlotFlag(PLT_SC_LELI_SOAPS, SC_LELI_SOAPS_GIVEN, TRUE);}
                        CS_LoadCutscene(rCutscene);
                        }
                }
        }
    }
}
