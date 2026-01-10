# Version 3.4

- Pap gun reticle patch is now only active on Origins, and the reticle can be selected per player, see readme for more info
- Added some aliases to chat commands
- Deprecate legacy Plutonium versions support
- Improve Plutonium version detection
- Add explicit saving of updated bank balance in player stats

# Version 3.3

- Added ability to manage custom splits file via chat messages for Modern Plutonium (4516+)
- Changed the behavior of permaperk system to prevent possible stat/script state mismatch
- Fix unresolved external error from no hud release

# Version 3.2

- New dvar anticheat version (less allocations) for new Plutonium update (5162+)
- Changed watermarks to be a bit more readable
- Changed fps limiter for new Plutonium update (5162+)
- Fixed rare occurrence of false detection of duplicated patch which can terminate the game

# Version 3.1

- Network frame fix now isn't applied on Pluto versions >2905
- Restore change from 3.7 with `ai_corpseCount`, it's now again set to 5
    * For a bit of context, the DVAR game definition does set it to 8, but in another place the game adjusts it to 5 (specifically during the first launch process), so effectively all record games are historically played on 5. This setting will not apply after Plutonium update R5140 as they'll adjust their DVAR logic to this discovery and GSC adjustment won't be necessary.

# Version 3.0

- Added UTC timestamp to split print for versions that don't have game identifier
- Added link to WaW communtiy patch to the readme
- Changed structure of welcome prints and added bunch of info about game state
- Locked client FPS (it's set to 332, as in-game limiter is highly inaccurate, this allows people to go up to 250 via their own locker, which is currently max fps allowed)
- Anticheat now triggers Plutos cheat state (star) as well as the watermark
- Removed all remaining hooks for B2 extensions
- Added option to define custom splits via text file
- Added viewmodel customization (independend from setting characters, it only changes character hands but allows for use mid game and has no conflicts in coop games)
- Optimized logic for calculating Semtex prenades
- Optimized patch allocations

# Version 2.3

- Add enabling `cg_drawIdentifier` dvar for future Pluto update

# Version 2.2

- Restore correct default value for `ai_corpseCount` dvar

# Version 2.1

- Adjusted patch logic to make dvar management comaptibile with Plutonium R4542
- Changed implementation of the character system (after old one was found to cause issues with some in-game elements, such as Origins challenge crates) and re-enabled it
- Fixed accuracy of splits (will now show exact time of red round number at any round)
- Simplified logic for flashing patch checksums

# Version 2.0

- Patch now shows currently detected Plutonium version on load (may be inaccurate in older Plutonium versions)
- On Plutonium R4516+, the patch no longer applies the trap fix, instead enabling Plutonium fix. For older versions (R2905) the fix is still enabled.
- On Plutonium 4522+, the patch manages automatic display of patch and memory checksums
- Added some optimizations to variable and thread allocations
- Added new system for setting playable character (check readme for details)
- Updated compilation script to match version from B2OP
- Preprocessor directives refactor (not affecting the gameplay directly)

# Version 1.7

- Tweaks to anticheat
- Updated compilation script to match version from B2OP

# Version 1.6

- Added `velocity_meter` dvar for toggling the visibility of velocity meter

# Version 1.5

- Added `scr_skip_devblock 1` to fix dev debug code rendering stuff on player screen in R3904

# Version 1.4

- Fixed splits showing up early
- Increased split frequency

# Version 1.3

- Fixed prenades showing up in a regular Nuketown First Room game
- Fixed delayed split prints

# Version 1.2

- Fixed velocity meter while in the air (thanks [JBleezy](https://github.com/Jbleezy))
- Removed DOF

# Version 1.1

- Fixed gameplay reminders
- Fixed rare possibility of the game failing to restart after awarding permaperks
- Dvar sequence has been slightly delayed, which should reduce the emount of foreing scripts triggering the integrity checks
- Added back dvar rules from V6, including pre-patch recoil and aim assist
- Added text placeholder for round timer before round 1

# Version 1.0

This version marks moving from old First Room Fix codebase (again) to one built for [B2OP](https://github.com/B2ORG/T6-B2OP-PATCH), the two now have similar core functionality (adjusted for each respective category they're meant for). Only most important changes from First Room Fix V6 to B2FR V1 from player perspective are listed here, but under the hood almost all the code has been replaced.

## Fixes

- Fixed a bug where mannequins were not being removed from the map
- Fixed various issues with extensions
- Fixed bounds check in Nuketown Yellow House challenge controller
- Fixed hud timer to no longer cover BO2 native FPS counter (it is now the same as B2OP)
- Fixed hud elements positioning on aspect ratios other than 16:9

## Changes

- Changed extension handles so both B2OP and B2FR can use same extensions
- Removed powerup stats and moved that into a separate extension
- Removed the entire first box functionality (officially voted in 5th First Room vote). Only the check for foreign first box system remains in place
- Added bank refill upon connecting to the game
- Changed the compilation script
- Reintroduced split versions for HUD & NO HUD
- Dropped support for Redacted and Ancient Plutonium
- Added gameplay reminder for game host (it will also warn players at the beginning of the game that they'll have Juggernog on Nuketown, so everyone will need full gameplay, players can use this information to restart such game as well)
- RayGun permaperk (nube) is now actively removed on Tranzit and Die Rise (officially voted in 5th First Room vote)

# First Room Fix v6.0

## Fixes

- Fixed a bug where First Box module would not count box hits properly on Redacted
- Fixed rare issue where harmless config change could trigger noprint warning
- Changed most functions to optimize child variable allocation to fix potential child variable error
- Reworked permaperk system to fix problems with permaperk misbehavior
- Permaperks tracker will now work for players reconnecting to the game
- Fixed horde count tryint to display on leaper round
- Fixed mannequin remover leaving collision behind

## Changes

- Main patch can now be used with Redacted and Ancient Pluto (with slightly limited functionality)
- Pointdrop watching function now stops on round 50
- Implemented hooks for various plugins (hud properties, zones etc)
- Compilation scripts are now available in the repository
- Changed fridge system to work similar to first box (chat commands)
- Semtex prenades are now calculated up to the max round (via dynamically calculated values on higher rounds)
- Replaced some HUD elements with iprints (horde count, prenades, splits)
- Prenades and horde size can now be invoked at any point via chat message
- Box and Fridge systems now accept actual weapon codes in trigger chat messages
- Yellow House and Top Barn challenges are now supported and are triggering automatically if all of the conditions are met
