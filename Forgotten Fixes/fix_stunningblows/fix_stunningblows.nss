#include "core_h"
#include "2da_constants_h"
#include "effects_h"

void main()
{
    event  ev = GetCurrentEvent();
    int    nAbility  = GetEventInteger(ev, 1);
    object oAttacker = GetEventCreator(ev);
    object oTarget = OBJECT_SELF;
    


    if (HasAbility(oAttacker, ABILITY_TALENT_STUNNING_BLOWS) && IsMeleeWeapon2Handed(GetItemInEquipSlot(INVENTORY_SLOT_MAIN, oAttacker)))
            {
              // autoattack, or else ability requires melee or 2h weapon
              if (nAbility == 0 || (GetM2DAInt(TABLE_ABILITIES_SPELLS,"conditions",nAbility) & 129) > 0)
              {
                // ~50%
                if(RandomFloat()<0.5)
                {
                   if (!GetHasEffects(oTarget, EFFECT_TYPE_STUN))
                    {
                        Engine_ApplyEffectOnObject(EFFECT_DURATION_TYPE_TEMPORARY, EffectStun(),oTarget,1.5f + (RandomFloat()*2.5),oAttacker,ABILITY_TALENT_STUNNING_BLOWS);
                        #ifdef DEBUG
                        _LogDamage("DAMAGE-Combat-Efffect: STUNNING_BLOWS");
                        #endif

                     }
                }
            }  
        }
}