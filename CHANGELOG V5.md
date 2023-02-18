# CHANGELOG OF FIRST ROOM FIX V5

## Version 5.1
- Added built in semtex prenades info
- Added code for timer coop pause (it's not available in 5.1)
- Added debug prints for powerups (to possibly narrow down what happens with powerup glitch when they stop appearing)
- Added various rules to anticheat to verify proper gamerules and better way of displaying it
- Added first box module
- Fixed mannequins removal on Nuketown
- Added fridge and bank autofill
- Added color coding to velocity meter (from mw2 patch)
- Added a dvar for changing size of velocity meter

## Version 5.2
- Fixed Tickrate fix (check README)

## Version 5.3
- Fixed initial prints not showing for players who connect after host finished loading
- Changed GitHub link to the updated one
- Implemented Vanilla version

## Version 5.4
- Changed paths in code to follow GSC convension (enforced by Xensik's compiler)
- Fixed Blue Eyes functionality
- Removed No Fog option
- Added Innit patch detection

## Version 5.5
- Added a hook for custom script for changning HUD postion (/Misc/frfix_hud_override.gsc)
- Added some optimizations to Round Time displaying function
- Added time prints to Pluto CLI
- Fixed init sequence for DVARs (mainly for fix regarding prepatch recoil)

## Version 5.6
- Code refactor for some core functions
- Changed the logic of resizing velocity meter, it can now be done for each player separately via chat command
- Changed the logic of First Box module, it can now be used by all players (also works with redacted) as it's operated by chat commands, not dvar
- Changed watermarks to be a bit more visible (were blending in on ttv footage)
- Fixed round splits not showing up
- Fixed issues related to permaperks

## Version 5.7
- Completely disabled PermaPerk functionalities, until issues are resolved (most likely version 6.0)