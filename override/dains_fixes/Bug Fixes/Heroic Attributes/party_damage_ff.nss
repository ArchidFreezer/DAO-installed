#include "events_h"

void main()
{
    event ev = GetCurrentEvent();
    int nEventType = GetEventType(ev);

    if (nEventType = EVENT_TYPE_DAMAGED)
    {
        object oDamager = GetEventCreator(ev);
        object oTarget = GetEventTarget(ev);

        if (IsPartyMember(oDamager) && IsPartyMember(oTarget))
        {
            object oHero = GetHero();
            float fDamage = GetEventFloat(ev, 0);

            // 2002 is HERO_STAT_PARTY_DAMAGE_DEALT
            float fNewParty = GetCreatureProperty(oHero, 2002) - fDamage;
            SetCreatureProperty(oHero, 2002, fNewParty);
        }
    }
}