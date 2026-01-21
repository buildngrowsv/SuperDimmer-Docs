How to know which space you're on. Potential options


Advanced Member
Member
 462
Posted June 27, 2024
@gedeyenite You can find your current Desktop Space by looking at the "com.apple.spaces" plist. It's located at "~/Library/Preferences/com.apple.spaces.plist", but you can read it from Terminal or a shell script using the "defaults read com.apple.spaces" command.

 

Each Space has a name/uuid (they're one in the same). There's a "Current Space" field that contains the uuid of the current Space, and a "Space Properties" field that contains the name of all the Spaces currently available. If you can figure out a script that matches the "Current Space" uuid with that of whichever Space your app is in, you should have a good basis for the workflow you're trying to accomplish.

Floating.Point, giovanni and zeitlings
Like 3
5 weeks later...
Floating.Point
Floating.PointMember
Member
 194
Posted July 27, 2024
Another option is to use Hammerspoon (which can of course be called from Alfred if desired)

https://www.hammerspoon.org/docs/hs.spaces.html


