AGPushNote
==========

Custom view for easily displaying in-app push notification that feels like default iOS banners.

![Demo](https://github.com/relaxone22/AGPushNote/blob/master/Resources/push_ex.gif)

* Will look like iOS7 on iOS7 and will (try to) look like iOS6 on iOS6.
* Both block and protocol ways are available to control the action of tapping the message and showing/dismissing the view.
* Automatic handling for more than 1 push - Try calling `showWithNotificationMessage:` repeatedly to see how this works (Shown in the example app).
* Action block for tapping the message can be changed at any time - even after the view is already on screen! (Use `setMessageAction:` to set it). 
* Optionaly hide the view after X seconds (Default is 5), remove comment in code the make this work...
