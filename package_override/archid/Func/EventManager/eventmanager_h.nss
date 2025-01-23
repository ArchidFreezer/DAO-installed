/*
    EventManager : Listen or Override events without destroying the planet

    event -> object -> EventManager --> object
                            |   \-----> object
                            \---------> object

    See the end of this file for examples.
*/

const int TABLE_EVENT_MANAGER = 6610002;

/* This variable need to be an integer in the original var_module 2da table */
const string EVENT_MANAGER_LOCK = "MODULE_COUNTER_3";

/**
* @brief Get a lock for overriding an event.
*
* Each time an event is broadcasted, the lock is released. The first module that overrides the event locks it.
*
* @returns  A boolean. TRUE if you got the lock and can override the event. FALSE means an other module has already overrided this event.
*
* @author Anakin
**/
int EventManager_GetLock()
{
    int nLock = GetLocalInt(GetModule(), EVENT_MANAGER_LOCK);

    if (nLock == 0)
    {
        SetLocalInt(GetModule(), EVENT_MANAGER_LOCK, 1);
        return TRUE;
    }

    return FALSE;
}

/**
* @brief Releases the override lock.
*
* By releasing the lock, you allow other module to override the event. Do this
* if you override an event and want other override event handlers to trigger.
*
* @author Anakin
**/
void EventManager_ReleaseLock()
{
    SetLocalInt(GetModule(), EVENT_MANAGER_LOCK, 0);
}

/**
* @brief Broadcast an event.
*
* The broadcast events are send to all script defined in eventmanager 2DA table.
*
* @param ev The event to broadcast
*
* @author Anakin
**/
void EventManager_Broadcast(event ev)
{
    int nCurrentEventType = GetEventType(ev);

    string[] arOverride;
    string[] arPreListeners;
    string[] arPostListeners;
    int overi = 0;
    int prei = 0;
    int posti = 0;

    int nCurrentRow;
    int nEventType;
    int nMode;

    int nRows = GetM2DARows(TABLE_EVENT_MANAGER);

    int i;
    for (i = 0; i < nRows; i++)
    {
        nCurrentRow = GetM2DARowIdFromRowIndex(TABLE_EVENT_MANAGER, i);

        nEventType = GetM2DAInt(TABLE_EVENT_MANAGER, "EventType", nCurrentRow);

        if (nEventType == nCurrentEventType)
        {
            nMode = GetM2DAInt(TABLE_EVENT_MANAGER, "Mode", nCurrentRow);

            if (nMode == 0)
                arOverride[overi++] = GetM2DAString(TABLE_EVENT_MANAGER, "Script", nCurrentRow);
            else if (nMode == 1)
                arPreListeners[prei++] = GetM2DAString(TABLE_EVENT_MANAGER, "Script", nCurrentRow);
            else if (nMode == 2)
                arPostListeners[posti++] = GetM2DAString(TABLE_EVENT_MANAGER, "Script", nCurrentRow);
        }
    }

    EventManager_ReleaseLock();

    int nPreSize = GetArraySize(arPreListeners);

    for (i = 0; i < nPreSize; i++)
        HandleEvent_String(ev, arPreListeners[i]);

    int nOverSize = GetArraySize(arOverride);
    for (i = 0; i < nOverSize; i++)
        if (EventManager_GetLock()) HandleEvent_String(ev, arOverride[i]);

    if (EventManager_GetLock())
        HandleEvent(ev);

    int nPostSize = GetArraySize(arPostListeners);
    for (i = 0; i < nPostSize; i++)
        HandleEvent_String(ev, arPostListeners[i]);
}

/*
    EXAMPLES
*/

/* # How to listen/override an event with the Event Manager ?

You don't need to change your habits concerning overriding events in engineevents.GDA
So fill the engineevents.GDA with all events you want to listen or override.
But redirect them to eventmanager.

For example, we say that we want to override EVENT_TYPE_DYING and listen
EVENT_TYPE_MEMBER_HIRED in a mod called my_mod

So my .gda file will looks like this :

ID    Label                                Script
1023  EVENT_TYPE_DYING                     eventmanager
1028  EVENT_TYPE_PARTY_MEMBER_HIRED        eventmanager



Then create a new .xls file following the example in the archive. Its name is eventmanager_my_mod.xls.
It is a new M2DA table that need to be extend. Choose a random ID as big as you want for your mod.
Here you have to enter what the name of the scripts that will handler the events.

ID  EventType  Label                          Script        Mode
X   1023       EVENT_TYPE_DYING               my_mod_dying  0
Y   1028       EVENT_TYPE_PARTY_MEMBER_HIRED  my_mod_pmh    1

Look at comments in the xls file to know how to fill it properly. Mode are :
0 : You override the event. Your script replace the default handler.
1 : You are listening for the event. The default handler is called before your script.
2 : You are listening for the event. The default handler is called after your script.


and ... finished ! You script will be called each time the event appear.
my_mod_dying script looks like this :

void main()
{
    event ev = GetCurrentEvent();

    // bla bla bla ...
}



# Side Note

If you override an event, it is because you don't want to call the default
handler. Your code will replace the default handler and all other mods that are
listening for this event will be processed before or after depending of their mode.

If you listen for an event, it is because you want to call the default handler
for this event before or after your script. The default handler can be the original or
a modified version by an other mod, you cannot be sure.
Listener are called in a "random" order.
If you listen an event, never, never, call HandleEvent(ev). It is already done.



# About EventManager_ReleaseLock()

This function help to partially override an event. For example, if you have want
to override an event ONLY for followers, you will do something like this in your
script :

#include "eventmanager_h"

void main()
{
    if (IsFollower(OBJECT_SELF) == FALSE)
    {
        EventManager_ReleaseLock();
        return;
    }

    event ev = GetCurrentEvent();

    // bla bla bla ...
}

It allows other mod to also override this event for an other type of object. In
the example of EVENT_TYPE_DYING, it mean the Mod X can override it for followers
and the mod Y can override it for other creatures.
You don't need to use ReleaseLock function is you are just listening for the event.


# How do I need to include in the player package of my mod ?

You have to embed the Event Manager in case you are the only mod of the player :
Include eventmanager.ncs
Include 2da_eventmanager.GDA

In addition, you have to include your event table : eventmanager_my_mod.GDA

I personally included these file in my_mod/core/override/toolsetexport. So I
know it is working from here. I didn't make the test for
my_mod/module/override/toolsetexport
*/
