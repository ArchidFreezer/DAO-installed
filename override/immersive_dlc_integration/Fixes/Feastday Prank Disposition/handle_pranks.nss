#include "wrappers_h"
#include "approval_h"

//Bug fix: Fixes prank incorrectly setting disposition to neutral
//         when it should be warm or friendly

void SetWarm(string follower);

void main()
{
  event ev = GetCurrentEvent();
  int nEventType = GetEventType(ev); //extract event type from current event

  switch(nEventType)
  {
    case EVENT_TYPE_INVENTORY_REMOVED:
    {
      object oNewOwner = GetEventCreator(ev); // new owner of the item, OBJECT_INVALID if item is being destroyed on object
      int bImmediate = GetEventInteger(ev, 0); // If 0, the event is queued. If 1, it is processed immediately.
      object oItem = GetEventObject(ev, 0); // item being removed

      //only necessary after pranks
      if (
        GetTag(oItem) != "val_im_gift_sermon" &&
        GetTag(oItem) != "val_im_gift_chant" &&
        GetTag(oItem) != "val_im_gift_skull" &&
        GetTag(oItem) != "val_im_gift_pigeon" &&
        GetTag(oItem) != "val_im_gift_boots" &&
        GetTag(oItem) != "val_im_gift_chastity" &&
        GetTag(oItem) != "val_im_gift_stick" &&
        GetTag(oItem) != "val_im_gift_soap" &&
        GetTag(oItem) != "val_im_gift_mask"
      )
      {
        return;
      }

      SetWarm("gen00fl_alistair");
      SetWarm("gen00fl_leliana");
      SetWarm("gen00fl_loghain");
      SetWarm("gen00fl_morrigan");
      SetWarm("gen00fl_oghren");
      SetWarm("gen00fl_shale");
      SetWarm("gen00fl_sten");
      SetWarm("gen00fl_wynne");
      SetWarm("gen00fl_zevran");

      int i;
      for (i = 1; i < 10; i++)
      {
        Approval_ChangeApproval(i, 0);
      }
    }
  }
}

//Assign warm first for edge cases where Approval_ChangeApproval() fails to change disposition to Friendly
void SetWarm(string follower)
{
  object oFollower = Party_GetFollowerByTag(follower);
  if (IsObjectValid(oFollower))
  {
    int bApproval = GetFollowerApproval(oFollower);
    if (bApproval > APP_RANGE_WARM)
    {
      int nStringRef = GetM2DAInt(TABLE_APPROVAL_NORMAL_RANGES, "StringRef", APP_RANGE_WARM);
      SetFollowerApprovalDescription(oFollower, nStringRef);
    }
  }
}